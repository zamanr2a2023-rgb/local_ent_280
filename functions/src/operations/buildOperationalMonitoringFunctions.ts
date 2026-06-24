import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { onValueWritten } from "firebase-functions/v2/database";
import * as admin from "firebase-admin";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import {
  assertCallerIsOps,
  resolveCallerRole,
  requireAuthenticatedUid,
  type RbacRole,
} from "../shared/auth/rbacRoleResolver";
import { assertManagerPermission } from "../shared/auth/managerPermissionClaims";
import { STANDARD_CALLABLE_RUNTIME_OPTIONS } from "../shared/constants";
import {
  hasOperationalBaseConfig,
  loadOperationalMonitoringConfig,
} from "./operationalMonitoringConfig";
import {
  appendReplaySample,
  decodePolyline,
  distanceToPolylineMeters,
  haversineDistanceMeters,
  isInsideCircularGeofence,
} from "./operationalMonitoringMath";
import {
  buildRouteKey,
  fetchExpectedRoute,
} from "./operationalMonitoringRoutes";
import {
  OPERATIONAL_APPROVAL_STATUSES,
  OPERATIONAL_INCIDENT_STATUSES,
  OPERATIONAL_INCIDENT_TYPES,
  OPERATIONAL_MONITORING_COLLECTIONS,
  OPERATIONAL_MONITORING_EVENT_ACTIONS,
  OPERATIONAL_STATES,
  OPERATIONAL_WINDOW_TYPES,
  type CircularGeofence,
  type DriverOperationalStateDocument,
  type GeoPointLiteral,
  type LocationSnapshot,
  type OperationalIncidentDocument,
  type OperationalIncidentStatus,
  type OperationalMovementApprovalDocument,
  type OperationalMonitoringConfig,
  type OperationalState,
  type OperationalWindowType,
  type ReplaySample,
  type TripOperationalMetricsDocument,
} from "./operationalMonitoringTypes";

export type OperationalMonitoringFunctions = {
  syncOperationalTripContext: ReturnType<typeof onDocumentUpdated>;
  syncOperationalLocationState: ReturnType<typeof onValueWritten>;
  reviewOperationalIncident: ReturnType<typeof onCall>;
  approveOperationalReposition: ReturnType<typeof onCall>;
  evaluateOperationalMonitoringJob: () => Promise<void>;
  cleanupOperationalMonitoringRetentionJob: () => Promise<void>;
};

type DriverStatusSnapshot = {
  driverId: string;
  isActive: boolean;
  isAvailable: boolean;
  availabilityEnabled: boolean;
  vehicleId: string | null;
  currentTripId: string | null;
  isBusy: boolean;
};

type TripSnapshot = {
  id: string;
  status: string;
  assignedDriverId: string | null;
  vehicleId: string | null;
  pickup: GeoPointLiteral | null;
  pickupAddress: string | null;
  destination: GeoPointLiteral | null;
  destinationAddress: string | null;
  meteringDistanceKm: number | null;
  startedAt: Date | null;
  arrivedDestinationAt: Date | null;
  completedAt: Date | null;
  postChargeExtensionActive: boolean;
};

type AssignmentSnapshot = {
  assignmentId: string;
  pickup: GeoPointLiteral;
  pickupAddress?: string | null;
  scheduledAt?: Date | null;
  source: "trip" | "reservation";
};

type ResolvedOperationalApproval = OperationalMovementApprovalDocument & {
  id: string;
};

const FUNCTIONS_REGION = "europe-southwest1";
const DATABASE_TRIGGER_REGION = "europe-west1";
const RETENTION_BATCH_SIZE = 25;
const MAX_STATE_REPLAY_SAMPLES = 60;
const MAX_INCIDENT_REPLAY_SAMPLES = 120;
const MAX_APPROVAL_REASON_LENGTH = 300;
const APPROVAL_MINUTES_MIN = 5;
const APPROVAL_MINUTES_MAX = 240;

export function buildOperationalMonitoringFunctions(params: {
  firestore: admin.firestore.Firestore;
  realtimeDb: admin.database.Database;
  auth: admin.auth.Auth;
}): OperationalMonitoringFunctions {
  const { firestore, realtimeDb } = params;

  const syncOperationalTripContext = onDocumentUpdated(
    {
      document: "trips/{tripId}",
      region: FUNCTIONS_REGION,
    },
    async (event) => {
      const tripId = event.params.tripId;
      const beforeData = event.data?.before.data();
      const afterData = event.data?.after.data();
      if (!afterData) {
        return;
      }
      if (
        beforeData?.status === afterData.status &&
        beforeData?.assignedDriverId === afterData.assignedDriverId &&
        beforeData?.vehicleId === afterData.vehicleId &&
        beforeData?.startedAt?.isEqual?.(afterData.startedAt) === true &&
        beforeData?.arrivedDestinationAt?.isEqual?.(
          afterData.arrivedDestinationAt,
        ) === true &&
        JSON.stringify(beforeData?.meteringSnapshot ?? null) ===
          JSON.stringify(afterData.meteringSnapshot ?? null)
      ) {
        logger.info("cost_profile", {
          functionName: "syncOperationalTripContext",
          operation: "trigger_skipped_diff_guard",
          tripId,
        });
        return;
      }
      const trip = parseTripSnapshot(tripId, afterData);
      if (!trip.assignedDriverId) {
        return;
      }
      const config = await loadOperationalMonitoringConfig({ firestore });
      if (!config.enabled) {
        return;
      }
      const stateRef = firestore.doc(
        `${OPERATIONAL_MONITORING_COLLECTIONS.driverOperationalStates}/${trip.assignedDriverId}`,
      );
      const state = await readDriverOperationalState(stateRef);
      const driverSummary = await fetchDriverSummary({
        firestore,
        driverId: trip.assignedDriverId,
      });
      const vehicleSummary = await fetchVehicleSummary({
        firestore,
        vehicleId: trip.vehicleId,
      });

      if (trip.status === "IN_TRIP") {
        const operationalWindowId = buildActiveTripOperationalWindowId(tripId);
        const expectedRoute = await resolveRouteForActiveTrip({
          trip,
          operationalWindowId,
          existingRoute: state.cachedExpectedRoute ?? null,
        });
        await stateRef.set(
          {
            driverId: trip.assignedDriverId,
            driverName: driverSummary?.name ?? state.driverName ?? null,
            vehicleId: trip.vehicleId,
            vehiclePlate: vehicleSummary?.plate ?? state.vehiclePlate ?? null,
            tripId,
            linkedTripId: tripId,
            operationalWindowId,
            operationalWindowType: OPERATIONAL_WINDOW_TYPES.activeTrip,
            currentState: OPERATIONAL_STATES.onActiveTrip,
            monitoringSuppressed: false,
            suppressionReason: null,
            cachedExpectedRoute: toExpectedRoutePayload(expectedRoute),
            windowStartedAt:
              trip.startedAt ??
              state.windowStartedAt ??
              FieldValue.serverTimestamp(),
            nonCompliantSinceAt: FieldValue.delete(),
            compliantSinceAt: FieldValue.delete(),
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
        await upsertTripOperationalMetrics({
          firestore,
          trip,
          update: {
            driverId: trip.assignedDriverId,
            vehicleId: trip.vehicleId,
            activeTripOperationalWindowId: operationalWindowId,
            expectedTripDistanceKm: expectedRoute?.distanceKm ?? null,
            expectedTripPolyline: expectedRoute?.encodedPolyline ?? null,
            startedAt: trip.startedAt,
          },
        });
        logger.info("Operational active-trip context synced.", {
          tripId,
          driverId: trip.assignedDriverId,
          operationalWindowId,
        });
        return;
      }

      if (trip.arrivedDestinationAt) {
        const operationalWindowId = buildPostDropoffOperationalWindowId({
          tripId,
          arrivedDestinationAt: trip.arrivedDestinationAt,
        });
        const expectedRoute = await resolveRouteForPostDropoff({
          config,
          trip,
          operationalWindowId,
          existingRoute:
            state.operationalWindowId === operationalWindowId
              ? (state.cachedExpectedRoute ?? null)
              : null,
        });
        await stateRef.set(
          {
            driverId: trip.assignedDriverId,
            driverName: driverSummary?.name ?? state.driverName ?? null,
            vehicleId: trip.vehicleId,
            vehiclePlate: vehicleSummary?.plate ?? state.vehiclePlate ?? null,
            tripId,
            linkedTripId: tripId,
            operationalWindowId,
            operationalWindowType: OPERATIONAL_WINDOW_TYPES.postDropoff,
            currentState: OPERATIONAL_STATES.postDropoffWaiting,
            monitoringSuppressed: false,
            suppressionReason: null,
            cachedExpectedRoute: toExpectedRoutePayload(expectedRoute),
            replaySamples: [],
            actualWindowDistanceKm: 0,
            windowStartedAt: trip.arrivedDestinationAt,
            windowAnchorLocation: trip.destination,
            dropoffLocation: trip.destination,
            dropoffAt: trip.arrivedDestinationAt,
            graceEndsAt: Timestamp.fromDate(
              addMinutes(
                trip.arrivedDestinationAt,
                config.postDropoffGracePeriodMinutes,
              ),
            ),
            nonCompliantSinceAt: FieldValue.delete(),
            compliantSinceAt: FieldValue.delete(),
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
        await upsertTripOperationalMetrics({
          firestore,
          trip,
          update: {
            driverId: trip.assignedDriverId,
            vehicleId: trip.vehicleId,
            postDropoffOperationalWindowId: operationalWindowId,
            expectedPostDropoffDistanceKm: expectedRoute?.distanceKm ?? 0,
            expectedPostDropoffPolyline: expectedRoute?.encodedPolyline ?? null,
            arrivedDestinationAt: trip.arrivedDestinationAt,
            postDropoffWindowStartedAt: trip.arrivedDestinationAt,
          },
        });
        logger.info("Operational post-dropoff context synced.", {
          tripId,
          driverId: trip.assignedDriverId,
          operationalWindowId,
        });
      }
    },
  );

  const syncOperationalLocationState = onValueWritten(
    {
      ref: "/driverLocations/{driverId}",
      region: DATABASE_TRIGGER_REGION,
    },
    async (event) => {
      const driverId = event.params.driverId;
      const afterValue = event.data.after.val();
      if (!afterValue || typeof afterValue !== "object") {
        return;
      }
      const location = parseRealtimeLocation(afterValue);
      if (!location) {
        logger.warn(
          "Operational location sync skipped due to invalid payload.",
          {
            driverId,
          },
        );
        return;
      }
      const stateRef = firestore.doc(
        `${OPERATIONAL_MONITORING_COLLECTIONS.driverOperationalStates}/${driverId}`,
      );
      const state = await readDriverOperationalState(stateRef);
      if (
        !state.operationalWindowId ||
        state.currentState === OPERATIONAL_STATES.offDuty
      ) {
        logger.info("cost_profile", {
          functionName: "syncOperationalLocationState",
          operation: "operational_monitoring_skipped_before_config_load",
          driverId,
        });
        return;
      }
      const config = await loadOperationalMonitoringConfig({ firestore });
      if (!config.enabled) {
        return;
      }

      const samples = state.replaySamples ?? [];
      const latestLocation = state.latestLocation ?? null;
      const shouldAppendSample = shouldAppendReplaySample({
        previousLocation: latestLocation,
        nextLocation: location,
        config,
      });
      const nextSamples = shouldAppendSample
        ? appendReplaySample({
            samples,
            nextSample: toReplaySample(location),
            maxSamples: MAX_STATE_REPLAY_SAMPLES,
          })
        : samples;

      const updatePayload: Record<string, unknown> = {
        latestLocation: toLocationSnapshotPayload(location),
        lastProcessedRtdbTimestamp: Timestamp.fromDate(
          location.recordedAt,
        ),
        replaySamples: nextSamples.map(toReplaySamplePayload),
        updatedAt: FieldValue.serverTimestamp(),
      };

      if (
        state.operationalWindowType === OPERATIONAL_WINDOW_TYPES.postDropoff ||
        state.operationalWindowType ===
          OPERATIONAL_WINDOW_TYPES.noTripOperational
      ) {
        const previousPoint =
          latestLocation ??
          (state.replaySamples && state.replaySamples.length > 0
            ? {
                ...state.replaySamples[state.replaySamples.length - 1],
                recordedAt:
                  state.replaySamples[state.replaySamples.length - 1]
                    .recordedAt,
              }
            : null);
        const deltaKm = calculatePathDeltaKm({
          previousLocation: previousPoint,
          nextLocation: location,
          config,
        });
        if (deltaKm > 0) {
          updatePayload.actualWindowDistanceKm = roundKm(
            (state.actualWindowDistanceKm ?? 0) + deltaKm,
          );
        }
      }

      await stateRef.set(updatePayload, { merge: true });
    },
  );

  const reviewOperationalIncident = onCall(
    STANDARD_CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);
      const role = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      assertCallerIsOps(role);
      assertManagerReviewPermission({
        role,
        authToken: request.auth?.token ?? null,
        context: "reviewOperationalIncident",
      });

      const payload = request.data as Record<string, unknown> | null;
      const incidentId =
        typeof payload?.incidentId === "string"
          ? payload.incidentId.trim()
          : "";
      const action =
        typeof payload?.action === "string" ? payload.action.trim() : "";
      const note = typeof payload?.note === "string" ? payload.note.trim() : "";
      if (!incidentId) {
        throw new HttpsError("invalid-argument", "Incidente inválido.");
      }
      if (
        !["acknowledge", "dismiss", "confirm", "approve_exception"].includes(
          action,
        )
      ) {
        throw new HttpsError("invalid-argument", "Ação inválida.");
      }
      if (
        ["dismiss", "confirm", "approve_exception"].includes(action) &&
        note.length == 0
      ) {
        throw new HttpsError(
          "invalid-argument",
          "Nota obrigatória para esta ação.",
        );
      }

      const incidentRef = firestore.doc(
        `${OPERATIONAL_MONITORING_COLLECTIONS.operationalIncidents}/${incidentId}`,
      );
      const incidentSnapshot = await incidentRef.get();
      if (!incidentSnapshot.exists) {
        throw new HttpsError("not-found", "Incidente não encontrado.");
      }
      const incident = parseOperationalIncident(
        incidentId,
        incidentSnapshot.data() ?? {},
      );
      if (!incident) {
        throw new HttpsError("failed-precondition", "Incidente inválido.");
      }

      let linkedApprovalId: string | null = null;
      if (action === "approve_exception") {
        const approval = await createOperationalApproval({
          firestore,
          requesterId,
          requesterRole: role === "admin" ? "admin" : "manager",
          driverId: incident.driverId,
          incidentId,
          operationalWindowId: incident.operationalWindowId,
          operationalWindowType: incident.operationalWindowType,
          tripId: incident.tripId ?? null,
          payload,
        });
        linkedApprovalId = approval.id;
      }

      const updatePayload: Record<string, unknown> = {
        updatedAt: FieldValue.serverTimestamp(),
        reviewNote: note || FieldValue.delete(),
      };
      if (action === "acknowledge") {
        updatePayload.status = OPERATIONAL_INCIDENT_STATUSES.acknowledged;
      } else if (action === "dismiss") {
        updatePayload.status = OPERATIONAL_INCIDENT_STATUSES.dismissed;
        updatePayload.resolvedAt = FieldValue.serverTimestamp();
        updatePayload.resolutionSource = "reviewer";
        updatePayload.resolutionReason = "dismissed_by_reviewer";
      } else if (action === "confirm") {
        updatePayload.status = OPERATIONAL_INCIDENT_STATUSES.confirmed;
        updatePayload.resolvedAt = FieldValue.serverTimestamp();
        updatePayload.resolutionSource = "reviewer";
        updatePayload.resolutionReason = "confirmed_by_reviewer";
      } else if (action === "approve_exception") {
        updatePayload.status = OPERATIONAL_INCIDENT_STATUSES.approved;
        updatePayload.resolvedAt = FieldValue.serverTimestamp();
        updatePayload.resolutionSource = "reviewer";
        updatePayload.resolutionReason = "approved_exception";
      }
      await incidentRef.set(updatePayload, { merge: true });
      await appendIncidentEvent({
        incidentRef,
        action:
          action === "acknowledge"
            ? OPERATIONAL_MONITORING_EVENT_ACTIONS.acknowledged
            : action === "dismiss"
              ? OPERATIONAL_MONITORING_EVENT_ACTIONS.dismissed
              : action === "confirm"
                ? OPERATIONAL_MONITORING_EVENT_ACTIONS.confirmed
                : OPERATIONAL_MONITORING_EVENT_ACTIONS.approvedException,
        actorId: requesterId,
        actorRole: role,
        note,
        metadata: linkedApprovalId ? { linkedApprovalId } : undefined,
      });
      return {
        ok: true,
        linkedApprovalId,
      };
    },
  );

  const approveOperationalReposition = onCall(
    STANDARD_CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);
      const role = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      assertCallerIsOps(role);
      assertManagerReviewPermission({
        role,
        authToken: request.auth?.token ?? null,
        context: "approveOperationalReposition",
      });
      const payload = request.data as Record<string, unknown> | null;
      const driverId =
        typeof payload?.driverId === "string" ? payload.driverId.trim() : "";
      if (!driverId) {
        throw new HttpsError("invalid-argument", "Motorista inválido.");
      }
      const stateRef = firestore.doc(
        `${OPERATIONAL_MONITORING_COLLECTIONS.driverOperationalStates}/${driverId}`,
      );
      const state = await readDriverOperationalState(stateRef);
      if (!state.operationalWindowId || !state.operationalWindowType) {
        throw new HttpsError(
          "failed-precondition",
          "Sem janela operacional elegível.",
        );
      }
      if (state.currentState === OPERATIONAL_STATES.offDuty) {
        throw new HttpsError(
          "failed-precondition",
          "Motorista fora de serviço.",
        );
      }
      if (state.operationalWindowType === OPERATIONAL_WINDOW_TYPES.activeTrip) {
        throw new HttpsError(
          "failed-precondition",
          "Aprovação preventiva indisponível em viagem ativa.",
        );
      }
      if (
        !state.lastProcessedRtdbTimestamp ||
        Date.now() - state.lastProcessedRtdbTimestamp.getTime() >
          (await loadOperationalMonitoringConfig({ firestore }))
            .staleTelemetryThresholdSeconds *
            1000
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Localização operacional desatualizada.",
        );
      }
      const approval = await createOperationalApproval({
        firestore,
        requesterId,
        requesterRole: role === "admin" ? "admin" : "manager",
        driverId,
        incidentId: null,
        operationalWindowId: state.operationalWindowId,
        operationalWindowType: state.operationalWindowType,
        tripId: state.tripId ?? state.linkedTripId ?? null,
        payload,
      });
      return {
        ok: true,
        approvalId: approval.id,
      };
    },
  );

  async function evaluateOperationalMonitoringJob(): Promise<void> {
    const config = await loadOperationalMonitoringConfig({ firestore });
    if (!config.enabled) {
      logger.info("Operational monitoring evaluation skipped; disabled.");
      return;
    }
    const statesSnapshot = await firestore
      .collection(OPERATIONAL_MONITORING_COLLECTIONS.driverOperationalStates)
      .where("operationalWindowId", "!=", null)
      .get();
    if (statesSnapshot.empty) {
      logger.info(
        "Operational monitoring evaluation skipped; no active states.",
      );
      return;
    }
    const approvalsMap = await loadActiveApprovalsByDriver({ firestore });

    for (const stateDoc of statesSnapshot.docs) {
      const stateRef = firestore.doc(
        `${OPERATIONAL_MONITORING_COLLECTIONS.driverOperationalStates}/${stateDoc.id}`,
      );
      const state = parseDriverOperationalState(stateDoc.id, stateDoc.data());
      if (
        !state.operationalWindowId ||
        state.currentState === OPERATIONAL_STATES.offDuty
      ) {
        continue;
      }
      const driverStatusSnapshot = await firestore
        .doc(`driverStatus/${state.driverId}`)
        .get();
      const driverStatus = parseDriverStatusSnapshot(
        state.driverId,
        driverStatusSnapshot.data() ?? {},
      );
      const latestLocation = await readRealtimeLocation({
        realtimeDb,
        driverId: driverStatus.driverId,
      });
      const activeApproval = approvalsMap.get(driverStatus.driverId) ?? null;
      await evaluateDriverOperationalState({
        firestore,
        stateRef,
        driverStatus,
        state,
        latestLocation,
        activeApproval,
        config,
      });
    }
  }

  async function cleanupOperationalMonitoringRetentionJob(): Promise<void> {
    const now = new Date();
    await cleanupRetentionBatch({
      firestore,
      collection:
        OPERATIONAL_MONITORING_COLLECTIONS.operationalMovementApprovals,
      field: "retentionExpiresAt",
      now,
    });
    await cleanupRetentionBatch({
      firestore,
      collection: OPERATIONAL_MONITORING_COLLECTIONS.tripOperationalMetrics,
      field: "retentionExpiresAt",
      now,
    });
    const incidentSnapshot = await firestore
      .collection(OPERATIONAL_MONITORING_COLLECTIONS.operationalIncidents)
      .where(
        "retentionExpiresAt",
        "<=",
        Timestamp.fromDate(now),
      )
      .limit(RETENTION_BATCH_SIZE)
      .get();
    for (const doc of incidentSnapshot.docs) {
      const events = await doc.ref.collection("events").get();
      const batch = firestore.batch();
      for (const eventDoc of events.docs) {
        batch.delete(eventDoc.ref);
      }
      batch.delete(doc.ref);
      await batch.commit();
    }
  }

  return {
    syncOperationalTripContext,
    syncOperationalLocationState,
    reviewOperationalIncident,
    approveOperationalReposition,
    evaluateOperationalMonitoringJob,
    cleanupOperationalMonitoringRetentionJob,
  };
}

async function evaluateDriverOperationalState(params: {
  firestore: admin.firestore.Firestore;
  stateRef: admin.firestore.DocumentReference;
  driverStatus: DriverStatusSnapshot;
  state: DriverOperationalStateDocument;
  latestLocation: LocationSnapshot | null;
  activeApproval: ResolvedOperationalApproval | null;
  config: OperationalMonitoringConfig;
}): Promise<void> {
  const {
    firestore,
    stateRef,
    driverStatus,
    state,
    latestLocation,
    activeApproval,
    config,
  } = params;
  const currentTrip = driverStatus.currentTripId
    ? await fetchTripSnapshot({
        firestore,
        tripId: driverStatus.currentTripId,
      })
    : null;
  const tripForWindow =
    currentTrip ??
    (state.tripId
      ? await fetchTripSnapshot({
          firestore,
          tripId: state.tripId,
        })
      : null);
  const nextAssignment = await fetchUpcomingAssignment({
    firestore,
    driverId: driverStatus.driverId,
    currentTripId: currentTrip?.id ?? null,
    lookaheadMinutes: config.nextAssignmentSuppressionLookaheadMinutes,
  });

  const monitoringEnabled = isMonitoringEnabled({
    driverStatus,
    currentTrip,
    activeApproval,
    tripForWindow,
  });
  if (!monitoringEnabled) {
    await maybeAutoResolveCurrentIncident({
      firestore,
      state,
      reason: "went_off_duty",
      clearanceThresholdSeconds: config.incidentClearanceThresholdSeconds,
    });
    await completeActiveApprovalIfNeeded({
      firestore,
      approval: activeApproval,
    });
    await stateRef.set(
      buildOffDutyStatePayload({
        driverStatus,
        state,
        latestLocation,
      }),
      { merge: true },
    );
    if (state.linkedTripId) {
      await markTripOperationalWindowEnded({
        firestore,
        tripId: state.linkedTripId,
        field: "offDutyAt",
      });
    }
    return;
  }

  const staleTelemetry = isTelemetryStale({
    latestLocation,
    config,
  });
  if (staleTelemetry) {
    await maybeAutoResolveCurrentIncident({
      firestore,
      state,
      reason: "monitoring_suppressed_due_to_stale_telemetry",
      clearanceThresholdSeconds: config.incidentClearanceThresholdSeconds,
    });
    await stateRef.set(
      {
        monitoringSuppressed: true,
        suppressionReason: "stale_telemetry",
        latestLocation: latestLocation
          ? toLocationSnapshotPayload(latestLocation)
          : FieldValue.delete(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    return;
  }

  if (
    currentTrip &&
    currentTrip.status === "IN_TRIP" &&
    state.operationalWindowType !== OPERATIONAL_WINDOW_TYPES.activeTrip
  ) {
    const route = await resolveRouteForActiveTrip({
      trip: currentTrip,
      operationalWindowId: buildActiveTripOperationalWindowId(currentTrip.id),
      existingRoute: null,
    });
    await stateRef.set(
      {
        tripId: currentTrip.id,
        linkedTripId: currentTrip.id,
        operationalWindowId: buildActiveTripOperationalWindowId(currentTrip.id),
        operationalWindowType: OPERATIONAL_WINDOW_TYPES.activeTrip,
        currentState: OPERATIONAL_STATES.onActiveTrip,
        cachedExpectedRoute: toExpectedRoutePayload(route),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    await upsertTripOperationalMetrics({
      firestore,
      trip: currentTrip,
      update: {
        activeTripOperationalWindowId: buildActiveTripOperationalWindowId(
          currentTrip.id,
        ),
        expectedTripDistanceKm: route?.distanceKm ?? null,
        expectedTripPolyline: route?.encodedPolyline ?? null,
      },
    });
  }

  if (
    state.operationalWindowType === OPERATIONAL_WINDOW_TYPES.postDropoff &&
    hasReachedPostDropoffCutoff({
      state,
      latestLocation,
      config,
      nextAssignment,
    })
  ) {
    await maybeAutoResolveCurrentIncident({
      firestore,
      state,
      reason: resolvePostDropoffResolutionReason({
        state,
        latestLocation,
        config,
        nextAssignment,
      }),
      clearanceThresholdSeconds: config.incidentClearanceThresholdSeconds,
    });
    await completeActiveApprovalIfNeeded({
      firestore,
      approval: activeApproval,
    });
    await markTripOperationalWindowEnded({
      firestore,
      tripId: state.linkedTripId ?? state.tripId ?? "",
      field: isAtBase({ latestLocation, config })
        ? "baseArrivedAt"
        : nextAssignment
          ? "nextAssignmentAt"
          : null,
    });
    if (driverStatus.isAvailable) {
      const noTripWindowId = buildNoTripOperationalWindowId({
        driverId: driverStatus.driverId,
        startedAt: latestLocation?.recordedAt ?? new Date(),
      });
      await stateRef.set(
        buildNoTripWindowPayload({
          state,
          driverStatus,
          latestLocation,
          activeApproval,
          operationalWindowId: noTripWindowId,
        }),
        { merge: true },
      );
    }
    return;
  }

  if (
    state.operationalWindowType !== OPERATIONAL_WINDOW_TYPES.activeTrip &&
    state.operationalWindowType !== OPERATIONAL_WINDOW_TYPES.postDropoff
  ) {
    const noTripWindowId =
      state.operationalWindowType ===
        OPERATIONAL_WINDOW_TYPES.noTripOperational && state.operationalWindowId
        ? state.operationalWindowId
        : buildNoTripOperationalWindowId({
            driverId: driverStatus.driverId,
            startedAt: latestLocation?.recordedAt ?? new Date(),
          });
    await stateRef.set(
      buildNoTripWindowPayload({
        state,
        driverStatus,
        latestLocation,
        activeApproval,
        operationalWindowId: noTripWindowId,
      }),
      { merge: true },
    );
  }

  const refreshedState = await readDriverOperationalState(stateRef);
  await refreshMetrics({
    firestore,
    state: refreshedState,
    trip: tripForWindow,
    nextAssignment,
    config,
  });
  await evaluateComplianceAndIncident({
    firestore,
    stateRef,
    state: refreshedState,
    latestLocation,
    trip: tripForWindow,
    nextAssignment,
    activeApproval,
    config,
  });
}

async function evaluateComplianceAndIncident(params: {
  firestore: admin.firestore.Firestore;
  stateRef: admin.firestore.DocumentReference;
  state: DriverOperationalStateDocument;
  latestLocation: LocationSnapshot | null;
  trip: TripSnapshot | null;
  nextAssignment: AssignmentSnapshot | null;
  activeApproval: ResolvedOperationalApproval | null;
  config: OperationalMonitoringConfig;
}): Promise<void> {
  const {
    firestore,
    stateRef,
    state,
    latestLocation,
    trip,
    nextAssignment,
    activeApproval,
    config,
  } = params;
  if (
    !latestLocation ||
    !state.operationalWindowId ||
    !state.operationalWindowType
  ) {
    return;
  }

  const suppressionReason = resolveSuppressionReason({
    state,
    activeApproval,
    nextAssignment,
    latestLocation,
    config,
    trip,
  });
  if (suppressionReason) {
    await maybeAutoResolveCurrentIncident({
      firestore,
      state,
      reason:
        suppressionReason === "approval"
          ? "approval_became_active"
          : suppressionReason === "next_assignment"
            ? "next_assignment_started"
            : "entered_service_geofence",
      clearanceThresholdSeconds: config.incidentClearanceThresholdSeconds,
    });
    await stateRef.set(
      {
        monitoringSuppressed: true,
        suppressionReason,
        currentState:
          suppressionReason === "approval"
            ? OPERATIONAL_STATES.approvedReposition
            : isAtBase({ latestLocation, config })
              ? OPERATIONAL_STATES.atBase
              : state.currentState,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    return;
  }

  const evaluation = evaluateViolationState({
    state,
    latestLocation,
    trip,
    config,
  });
  const currentState = resolveCurrentOperationalState({
    state,
    latestLocation,
    config,
    activeApproval,
  });
  await stateRef.set(
    {
      currentState,
      monitoringSuppressed: false,
      suppressionReason: FieldValue.delete(),
      lastDistanceToTripDestinationMeters:
        trip?.destination != null
          ? haversineDistanceMeters(latestLocation, trip.destination)
          : FieldValue.delete(),
      lastDistanceToBaseMeters:
        config.baseGeofence != null
          ? haversineDistanceMeters(latestLocation, config.baseGeofence.center)
          : FieldValue.delete(),
      nonCompliantSinceAt: evaluation.nonCompliantSinceAt
        ? Timestamp.fromDate(evaluation.nonCompliantSinceAt)
        : FieldValue.delete(),
      compliantSinceAt: evaluation.compliantSinceAt
        ? Timestamp.fromDate(evaluation.compliantSinceAt)
        : FieldValue.delete(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  if (!evaluation.shouldOpenIncident) {
    await maybeAutoResolveCurrentIncident({
      firestore,
      state: {
        ...state,
        currentState,
      },
      reason: evaluation.complianceReason,
      clearanceThresholdSeconds: config.incidentClearanceThresholdSeconds,
    });
    return;
  }

  const openIncident =
    state.currentOpenIncidentId != null
      ? await fetchOperationalIncident({
          firestore,
          incidentId: state.currentOpenIncidentId,
        })
      : null;
  if (openIncident && !openIncident.resolvedAt) {
    await updateOperationalIncident({
      firestore,
      incidentId: openIncident.id,
      state: {
        ...state,
        currentState,
      },
      latestLocation,
    });
    return;
  }
  const incidentId = await createOperationalIncident({
    firestore,
    state: {
      ...state,
      currentState,
    },
    trip,
    latestLocation,
    subreason: evaluation.subreason,
  });
  await stateRef.set(
    {
      currentOpenIncidentId: incidentId,
      nonCompliantSinceAt: evaluation.nonCompliantSinceAt
        ? Timestamp.fromDate(evaluation.nonCompliantSinceAt)
        : FieldValue.delete(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
}

function evaluateViolationState(params: {
  state: DriverOperationalStateDocument;
  latestLocation: LocationSnapshot;
  trip: TripSnapshot | null;
  config: OperationalMonitoringConfig;
}): {
  shouldOpenIncident: boolean;
  nonCompliantSinceAt: Date | null;
  compliantSinceAt: Date | null;
  subreason: string;
  complianceReason: string;
} {
  const { state, latestLocation, trip, config } = params;
  const now = latestLocation.recordedAt;

  if (state.operationalWindowType === OPERATIONAL_WINDOW_TYPES.activeTrip) {
    const destination = trip?.destination;
    const route = state.cachedExpectedRoute;
    if (!destination || !route?.encodedPolyline) {
      return {
        shouldOpenIncident: false,
        nonCompliantSinceAt: null,
        compliantSinceAt: now,
        subreason: "missing_expected_route",
        complianceReason: "returned_to_compliant_path",
      };
    }
    const distanceToRoute = distanceToPolylineMeters({
      point: latestLocation,
      polyline: decodePolyline(route.encodedPolyline),
    });
    const distanceToTarget = haversineDistanceMeters(
      latestLocation,
      destination,
    );
    const previousDistance = state.lastDistanceToTripDestinationMeters ?? null;
    const movingAway =
      previousDistance != null && distanceToTarget >= previousDistance - 25;
    if (distanceToRoute > config.routeDeviationCorridorMeters && movingAway) {
      const startedAt = state.nonCompliantSinceAt ?? now;
      return {
        shouldOpenIncident:
          now.getTime() - startedAt.getTime() >=
          config.sustainedDeviationThresholdSeconds * 1000,
        nonCompliantSinceAt: startedAt,
        compliantSinceAt: null,
        subreason: "sustained_route_deviation",
        complianceReason: "returned_to_compliant_path",
      };
    }
    return {
      shouldOpenIncident: false,
      nonCompliantSinceAt: null,
      compliantSinceAt: state.compliantSinceAt ?? now,
      subreason: "sustained_route_deviation",
      complianceReason: "returned_to_compliant_path",
    };
  }

  if (state.operationalWindowType === OPERATIONAL_WINDOW_TYPES.postDropoff) {
    if (state.graceEndsAt && now.getTime() < state.graceEndsAt.getTime()) {
      return {
        shouldOpenIncident: false,
        nonCompliantSinceAt: null,
        compliantSinceAt: now,
        subreason: "post_dropoff_outside_allowed_context",
        complianceReason: "entered_waiting_zone",
      };
    }
    const waitingAllowed =
      state.dropoffLocation != null &&
      haversineDistanceMeters(latestLocation, state.dropoffLocation) <=
        config.dropoffWaitingRadiusMeters;
    const onBasePath = isOnCachedRoute({
      location: latestLocation,
      state,
      config,
    });
    if (waitingAllowed || onBasePath || isAtBase({ latestLocation, config })) {
      return {
        shouldOpenIncident: false,
        nonCompliantSinceAt: null,
        compliantSinceAt: state.compliantSinceAt ?? now,
        subreason: "post_dropoff_outside_allowed_context",
        complianceReason: waitingAllowed
          ? "entered_waiting_zone"
          : isAtBase({ latestLocation, config })
            ? "entered_base"
            : "returned_to_compliant_path",
      };
    }
    const startedAt = state.nonCompliantSinceAt ?? now;
    return {
      shouldOpenIncident:
        now.getTime() - startedAt.getTime() >=
        config.sustainedDeviationThresholdSeconds * 1000,
      nonCompliantSinceAt: startedAt,
      compliantSinceAt: null,
      subreason:
        state.currentState === OPERATIONAL_STATES.returningToBase
          ? "abandoned_return_to_base"
          : "post_dropoff_outside_allowed_context",
      complianceReason: "returned_to_compliant_path",
    };
  }

  const anchor = state.windowAnchorLocation;
  const insideAnchor =
    anchor != null &&
    haversineDistanceMeters(latestLocation, anchor) <=
      config.dropoffWaitingRadiusMeters;
  if (insideAnchor || isAtBase({ latestLocation, config })) {
    return {
      shouldOpenIncident: false,
      nonCompliantSinceAt: null,
      compliantSinceAt: state.compliantSinceAt ?? now,
      subreason: "no_trip_unauthorized_operational_movement",
      complianceReason: insideAnchor ? "entered_waiting_zone" : "entered_base",
    };
  }
  if (
    (state.actualWindowDistanceKm ?? 0) <= config.noTripLocalMovementAllowanceKm
  ) {
    return {
      shouldOpenIncident: false,
      nonCompliantSinceAt: null,
      compliantSinceAt: now,
      subreason: "no_trip_unauthorized_operational_movement",
      complianceReason: "returned_to_compliant_path",
    };
  }
  const startedAt = state.nonCompliantSinceAt ?? now;
  return {
    shouldOpenIncident:
      now.getTime() - startedAt.getTime() >=
      config.sustainedDeviationThresholdSeconds * 1000,
    nonCompliantSinceAt: startedAt,
    compliantSinceAt: null,
    subreason: "no_trip_unauthorized_operational_movement",
    complianceReason: "returned_to_compliant_path",
  };
}

function resolveSuppressionReason(params: {
  state: DriverOperationalStateDocument;
  activeApproval: ResolvedOperationalApproval | null;
  nextAssignment: AssignmentSnapshot | null;
  latestLocation: LocationSnapshot;
  config: OperationalMonitoringConfig;
  trip: TripSnapshot | null;
}): "approval" | "next_assignment" | "service_geofence" | null {
  const { activeApproval, nextAssignment, latestLocation, config, trip } =
    params;
  if (trip?.postChargeExtensionActive) {
    return "next_assignment";
  }
  if (activeApproval) {
    return "approval";
  }
  if (nextAssignment) {
    return "next_assignment";
  }
  const inServiceGeofence = config.serviceGeofences.some((geofence) =>
    isInsideCircularGeofence({ point: latestLocation, geofence }),
  );
  return inServiceGeofence ? "service_geofence" : null;
}

function resolveCurrentOperationalState(params: {
  state: DriverOperationalStateDocument;
  latestLocation: LocationSnapshot;
  config: OperationalMonitoringConfig;
  activeApproval: ResolvedOperationalApproval | null;
}): OperationalState {
  const { state, latestLocation, config, activeApproval } = params;
  if (activeApproval) {
    return OPERATIONAL_STATES.approvedReposition;
  }
  if (isAtBase({ latestLocation, config })) {
    return OPERATIONAL_STATES.atBase;
  }
  if (state.operationalWindowType === OPERATIONAL_WINDOW_TYPES.activeTrip) {
    return OPERATIONAL_STATES.onActiveTrip;
  }
  if (state.operationalWindowType === OPERATIONAL_WINDOW_TYPES.postDropoff) {
    if (
      state.dropoffLocation &&
      haversineDistanceMeters(latestLocation, state.dropoffLocation) <=
        config.dropoffWaitingRadiusMeters
    ) {
      return OPERATIONAL_STATES.postDropoffWaiting;
    }
    if (isOnCachedRoute({ location: latestLocation, state, config })) {
      return OPERATIONAL_STATES.returningToBase;
    }
    return OPERATIONAL_STATES.postDropoffWaiting;
  }
  return OPERATIONAL_STATES.operationalIdle;
}

async function refreshMetrics(params: {
  firestore: admin.firestore.Firestore;
  state: DriverOperationalStateDocument;
  trip: TripSnapshot | null;
  nextAssignment: AssignmentSnapshot | null;
  config: OperationalMonitoringConfig;
}): Promise<void> {
  const { firestore, state, trip, nextAssignment, config } = params;
  const tripId = state.linkedTripId ?? trip?.id ?? null;
  if (!tripId) {
    return;
  }
  const metricsRef = firestore.doc(
    `${OPERATIONAL_MONITORING_COLLECTIONS.tripOperationalMetrics}/${tripId}`,
  );
  const currentMetrics = parseTripOperationalMetrics(
    tripId,
    (await metricsRef.get()).data() ?? {},
  );
  const expectedTripDistanceKm = currentMetrics.expectedTripDistanceKm ?? null;
  const actualTripDistanceKm =
    trip?.meteringDistanceKm ?? currentMetrics.actualTripDistanceKm ?? null;
  const expectedPostDropoffDistanceKm = resolveExpectedPostDropoffKm({
    state,
    config,
    nextAssignment,
  });
  const actualPostDropoffDistanceKm =
    state.operationalWindowType === OPERATIONAL_WINDOW_TYPES.postDropoff
      ? (state.actualWindowDistanceKm ??
        currentMetrics.actualPostDropoffDistanceKm ??
        0)
      : (currentMetrics.actualPostDropoffDistanceKm ?? 0);
  const expectedNoTripDistanceKm =
    state.operationalWindowType === OPERATIONAL_WINDOW_TYPES.noTripOperational
      ? config.noTripLocalMovementAllowanceKm
      : (currentMetrics.expectedNoTripDistanceKm ?? null);
  const actualNoTripDistanceKm =
    state.operationalWindowType === OPERATIONAL_WINDOW_TYPES.noTripOperational
      ? (state.actualWindowDistanceKm ??
        currentMetrics.actualNoTripDistanceKm ??
        0)
      : (currentMetrics.actualNoTripDistanceKm ?? null);

  const tripVariance = computeVariance({
    expectedKm: expectedTripDistanceKm,
    actualKm: actualTripDistanceKm,
  });
  const postDropoffVariance = computeVariance({
    expectedKm: expectedPostDropoffDistanceKm,
    actualKm: actualPostDropoffDistanceKm,
  });
  const noTripVariance = computeVariance({
    expectedKm: expectedNoTripDistanceKm,
    actualKm: actualNoTripDistanceKm,
  });
  const totalExpected =
    sumNullable([
      expectedTripDistanceKm,
      expectedPostDropoffDistanceKm,
      expectedNoTripDistanceKm,
    ]) ?? null;
  const totalActual =
    sumNullable([
      actualTripDistanceKm,
      actualPostDropoffDistanceKm,
      actualNoTripDistanceKm,
    ]) ?? null;
  const totalVariance = computeVariance({
    expectedKm: totalExpected,
    actualKm: totalActual,
  });

  await metricsRef.set(
    {
      tripId,
      driverId: trip?.assignedDriverId ?? currentMetrics.driverId ?? null,
      vehicleId: trip?.vehicleId ?? currentMetrics.vehicleId ?? null,
      expectedTripDistanceKm,
      actualTripDistanceKm,
      tripDistanceVarianceKm: tripVariance.deltaKm,
      tripDistanceVariancePct: tripVariance.deltaPct,
      expectedPostDropoffDistanceKm,
      actualPostDropoffDistanceKm,
      postDropoffVarianceKm: postDropoffVariance.deltaKm,
      postDropoffVariancePct: postDropoffVariance.deltaPct,
      expectedNoTripDistanceKm,
      actualNoTripDistanceKm,
      noTripVarianceKm: noTripVariance.deltaKm,
      noTripVariancePct: noTripVariance.deltaPct,
      totalExpectedDistanceKm: totalExpected,
      totalActualDistanceKm: totalActual,
      totalVarianceKm: totalVariance.deltaKm,
      totalVariancePct: totalVariance.deltaPct,
      latestNoTripOperationalWindowId:
        state.operationalWindowType ===
        OPERATIONAL_WINDOW_TYPES.noTripOperational
          ? state.operationalWindowId
          : (currentMetrics.latestNoTripOperationalWindowId ?? null),
      retentionExpiresAt: Timestamp.fromDate(
        addDays(new Date(), 90),
      ),
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
}

async function maybeAutoResolveCurrentIncident(params: {
  firestore: admin.firestore.Firestore;
  state: DriverOperationalStateDocument;
  reason: string;
  clearanceThresholdSeconds: number;
}): Promise<void> {
  const { firestore, state, reason, clearanceThresholdSeconds } = params;
  if (!state.currentOpenIncidentId) {
    return;
  }
  const incident = await fetchOperationalIncident({
    firestore,
    incidentId: state.currentOpenIncidentId,
  });
  if (
    !incident ||
    incident.resolvedAt ||
    (incident.status !== OPERATIONAL_INCIDENT_STATUSES.open &&
      incident.status !== OPERATIONAL_INCIDENT_STATUSES.acknowledged)
  ) {
    return;
  }
  const clearanceStartedAt = incident.clearanceCandidateStartedAt ?? new Date();
  if (
    Date.now() - clearanceStartedAt.getTime() <
    clearanceThresholdSeconds * 1000
  ) {
    await firestore
      .doc(
        `${OPERATIONAL_MONITORING_COLLECTIONS.operationalIncidents}/${incident.id}`,
      )
      .set(
        {
          clearanceCandidateStartedAt:
            Timestamp.fromDate(clearanceStartedAt),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    return;
  }
  await firestore
    .doc(
      `${OPERATIONAL_MONITORING_COLLECTIONS.operationalIncidents}/${incident.id}`,
    )
    .set(
      {
        resolvedAt: FieldValue.serverTimestamp(),
        resolutionSource: "system",
        resolutionReason: reason,
        retentionExpiresAt: Timestamp.fromDate(
          addDays(new Date(), 90),
        ),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  await appendIncidentEvent({
    incidentRef: firestore.doc(
      `${OPERATIONAL_MONITORING_COLLECTIONS.operationalIncidents}/${incident.id}`,
    ),
    action: OPERATIONAL_MONITORING_EVENT_ACTIONS.autoResolved,
    actorId: "system",
    actorRole: "admin",
    note: reason,
  });
  await firestore
    .doc(
      `${OPERATIONAL_MONITORING_COLLECTIONS.driverOperationalStates}/${state.driverId}`,
    )
    .set(
      {
        currentOpenIncidentId: FieldValue.delete(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
}

async function createOperationalIncident(params: {
  firestore: admin.firestore.Firestore;
  state: DriverOperationalStateDocument;
  trip: TripSnapshot | null;
  latestLocation: LocationSnapshot;
  subreason: string;
}): Promise<string> {
  const { firestore, state, trip, latestLocation, subreason } = params;
  const operationalWindowId = state.operationalWindowId;
  const operationalWindowType = state.operationalWindowType;
  if (!operationalWindowId || !operationalWindowType) {
    throw new Error("Operational incident requires an active window.");
  }
  const incidentRef = firestore
    .collection(OPERATIONAL_MONITORING_COLLECTIONS.operationalIncidents)
    .doc();
  const metrics = state.linkedTripId
    ? parseTripOperationalMetrics(
        state.linkedTripId,
        (
          await firestore
            .doc(
              `${OPERATIONAL_MONITORING_COLLECTIONS.tripOperationalMetrics}/${state.linkedTripId}`,
            )
            .get()
        ).data() ?? {},
      )
    : createEmptyMetrics();
  const incidentType =
    operationalWindowType === OPERATIONAL_WINDOW_TYPES.activeTrip
      ? OPERATIONAL_INCIDENT_TYPES.activeTripRouteDeviation
      : OPERATIONAL_INCIDENT_TYPES.postDropoffUnauthorizedMovement;
  const payload: OperationalIncidentDocument = {
    operationalWindowId,
    operationalWindowType,
    driverId: state.driverId,
    driverName: state.driverName,
    vehicleId: state.vehicleId ?? null,
    vehiclePlate: state.vehiclePlate ?? null,
    tripId: state.tripId ?? null,
    incidentType,
    subreason,
    status: OPERATIONAL_INCIDENT_STATUSES.open,
    startedAt: state.nonCompliantSinceAt ?? latestLocation.recordedAt,
    currentState: state.currentState,
    originCoordinates: latestLocation,
    latestCoordinates: latestLocation,
    expectedPolyline: state.cachedExpectedRoute?.encodedPolyline ?? null,
    actualPathSamples: resolveIncidentReplaySamples({
      operationalWindowType,
      driverId: state.driverId,
      tripId: trip?.id ?? null,
      tripPathSamples:
        operationalWindowType === OPERATIONAL_WINDOW_TYPES.activeTrip &&
        trip?.id != null
          ? await readTripPathSamples({ firestore, tripId: trip.id })
          : [],
      replaySamples: state.replaySamples ?? [],
    }),
    expectedTripDistanceKm: metrics.expectedTripDistanceKm ?? null,
    actualTripDistanceKm: metrics.actualTripDistanceKm ?? null,
    tripDistanceVarianceKm: metrics.tripDistanceVarianceKm ?? null,
    tripDistanceVariancePct: metrics.tripDistanceVariancePct ?? null,
    expectedPostDropoffDistanceKm:
      metrics.expectedPostDropoffDistanceKm ?? null,
    actualPostDropoffDistanceKm: metrics.actualPostDropoffDistanceKm ?? null,
    postDropoffVarianceKm: metrics.postDropoffVarianceKm ?? null,
    postDropoffVariancePct: metrics.postDropoffVariancePct ?? null,
    expectedNoTripDistanceKm: metrics.expectedNoTripDistanceKm ?? null,
    actualNoTripDistanceKm: metrics.actualNoTripDistanceKm ?? null,
    noTripVarianceKm: metrics.noTripVarianceKm ?? null,
    noTripVariancePct: metrics.noTripVariancePct ?? null,
    totalExpectedDistanceKm: metrics.totalExpectedDistanceKm ?? null,
    totalActualDistanceKm: metrics.totalActualDistanceKm ?? null,
    totalVarianceKm: metrics.totalVarianceKm ?? null,
    totalVariancePct: metrics.totalVariancePct ?? null,
    tripStartedAt: trip?.startedAt ?? null,
    dropoffAt: state.dropoffAt ?? null,
    postDropoffWindowStartedAt: state.windowStartedAt ?? null,
    createdAt: new Date(),
    updatedAt: new Date(),
  };
  await incidentRef.set(toOperationalIncidentPayload(payload));
  await appendIncidentEvent({
    incidentRef,
    action: OPERATIONAL_MONITORING_EVENT_ACTIONS.created,
    actorId: "system",
    actorRole: "admin",
    note: subreason,
  });
  return incidentRef.id;
}

async function updateOperationalIncident(params: {
  firestore: admin.firestore.Firestore;
  incidentId: string;
  state: DriverOperationalStateDocument;
  latestLocation: LocationSnapshot;
}): Promise<void> {
  const { firestore, incidentId, state, latestLocation } = params;
  await firestore
    .doc(
      `${OPERATIONAL_MONITORING_COLLECTIONS.operationalIncidents}/${incidentId}`,
    )
    .set(
      {
        latestCoordinates: toLocationSnapshotPayload(latestLocation),
        currentState: state.currentState,
        actualPathSamples: (state.replaySamples ?? [])
          .slice(-MAX_INCIDENT_REPLAY_SAMPLES)
          .map(toReplaySamplePayload),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
}

async function createOperationalApproval(params: {
  firestore: admin.firestore.Firestore;
  requesterId: string;
  requesterRole: "admin" | "manager";
  driverId: string;
  incidentId: string | null;
  operationalWindowId: string;
  operationalWindowType: OperationalWindowType;
  tripId: string | null;
  payload: Record<string, unknown> | null;
}): Promise<{ id: string }> {
  const {
    firestore,
    requesterId,
    requesterRole,
    driverId,
    incidentId,
    operationalWindowId,
    operationalWindowType,
    tripId,
    payload,
  } = params;
  const reason =
    typeof payload?.reason === "string" ? payload.reason.trim() : "";
  if (!reason || reason.length > MAX_APPROVAL_REASON_LENGTH) {
    throw new HttpsError("invalid-argument", "Motivo inválido.");
  }
  const expiresAt = parseApprovalExpiry(payload?.expiresAt);
  const now = new Date();
  const durationMinutes = (expiresAt.getTime() - now.getTime()) / 60000;
  if (
    durationMinutes < APPROVAL_MINUTES_MIN ||
    durationMinutes > APPROVAL_MINUTES_MAX
  ) {
    throw new HttpsError("invalid-argument", "Expiração inválida.");
  }
  const destination = parseOptionalDestination(payload?.destination);
  const allowedArea = parseOptionalAllowedArea(payload?.allowedArea);
  if (destination && allowedArea) {
    throw new HttpsError(
      "invalid-argument",
      "Destino e área permitida são mutuamente exclusivos.",
    );
  }

  const stateRef = firestore.doc(
    `${OPERATIONAL_MONITORING_COLLECTIONS.driverOperationalStates}/${driverId}`,
  );
  const state = await readDriverOperationalState(stateRef);
  const approvalRef = firestore
    .collection(OPERATIONAL_MONITORING_COLLECTIONS.operationalMovementApprovals)
    .doc();
  const route =
    destination && state.latestLocation
      ? await fetchExpectedRoute({
          origin: state.latestLocation,
          destination,
          routeKey: buildRouteKey({
            operationalWindowId,
            origin: state.latestLocation,
            destination,
          }),
        })
      : null;
  const approval: OperationalMovementApprovalDocument = {
    operationalWindowId,
    operationalWindowType,
    driverId,
    driverName: state.driverName,
    vehicleId: state.vehicleId ?? null,
    vehiclePlate: state.vehiclePlate ?? null,
    tripId,
    reason,
    expiresAt,
    destination,
    allowedArea,
    approvedBy: requesterId,
    approvedByRole: requesterRole,
    status: OPERATIONAL_APPROVAL_STATUSES.active,
    incidentId,
    createdAt: now,
    updatedAt: now,
    retentionExpiresAt: addDays(expiresAt, 90),
  };
  await approvalRef.set(toOperationalApprovalPayload(approval));
  await stateRef.set(
    {
      activeApprovalSummary: {
        approvalId: approvalRef.id,
        reason,
        expiresAt: Timestamp.fromDate(expiresAt),
        destinationLabel: destination?.address ?? null,
      },
      currentState: OPERATIONAL_STATES.approvedReposition,
      monitoringSuppressed: true,
      suppressionReason: "approval",
      ...(route ? { cachedExpectedRoute: toExpectedRoutePayload(route) } : {}),
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  if (incidentId) {
    await appendIncidentEvent({
      incidentRef: firestore.doc(
        `${OPERATIONAL_MONITORING_COLLECTIONS.operationalIncidents}/${incidentId}`,
      ),
      action: OPERATIONAL_MONITORING_EVENT_ACTIONS.approvalCreated,
      actorId: requesterId,
      actorRole: requesterRole,
      note: reason,
      metadata: { approvalId: approvalRef.id },
    });
  }
  return { id: approvalRef.id };
}

async function resolveRouteForActiveTrip(params: {
  trip: TripSnapshot;
  operationalWindowId: string;
  existingRoute: DriverOperationalStateDocument["cachedExpectedRoute"] | null;
}) {
  const { trip, operationalWindowId, existingRoute } = params;
  if (!trip.pickup || !trip.destination) {
    return null;
  }
  const routeKey = buildRouteKey({
    operationalWindowId,
    origin: trip.pickup,
    destination: trip.destination,
  });
  if (existingRoute?.routeKey === routeKey) {
    return existingRoute;
  }
  return fetchExpectedRoute({
    origin: trip.pickup,
    destination: trip.destination,
    routeKey,
  });
}

async function resolveRouteForPostDropoff(params: {
  config: OperationalMonitoringConfig;
  trip: TripSnapshot;
  operationalWindowId: string;
  existingRoute: DriverOperationalStateDocument["cachedExpectedRoute"] | null;
}) {
  const { config, trip, operationalWindowId, existingRoute } = params;
  if (
    !hasOperationalBaseConfig(config) ||
    !trip.destination ||
    !config.baseGeofence
  ) {
    return null;
  }
  const routeKey = buildRouteKey({
    operationalWindowId,
    origin: trip.destination,
    destination: config.baseGeofence.center,
  });
  if (existingRoute?.routeKey === routeKey) {
    return existingRoute;
  }
  return fetchExpectedRoute({
    origin: trip.destination,
    destination: config.baseGeofence.center,
    routeKey,
  });
}

async function fetchUpcomingAssignment(params: {
  firestore: admin.firestore.Firestore;
  driverId: string;
  currentTripId: string | null;
  lookaheadMinutes: number;
}): Promise<AssignmentSnapshot | null> {
  const { firestore, driverId, currentTripId, lookaheadMinutes } = params;
  const now = new Date();
  const lookahead = addMinutes(now, lookaheadMinutes);
  const reservations = await firestore
    .collection("reservations")
    .where("assignedDriverId", "==", driverId)
    .where("status", "in", ["scheduled", "pending", "confirmed"])
    .where("scheduledAt", ">=", Timestamp.fromDate(now))
    .where("scheduledAt", "<=", Timestamp.fromDate(lookahead))
    .limit(1)
    .get();
  if (!reservations.empty) {
    const data = reservations.docs[0].data();
    const pickup = parseLocationWithAddress(data.pickup);
    if (pickup) {
      return {
        assignmentId: reservations.docs[0].id,
        pickup,
        pickupAddress: pickup.address ?? null,
        scheduledAt: parseDate(data.scheduledAt),
        source: "reservation",
      };
    }
  }

  const trips = await firestore
    .collection("trips")
    .where("assignedDriverId", "==", driverId)
    .orderBy("updatedAt", "desc")
    .limit(5)
    .get();
  for (const doc of trips.docs) {
    if (doc.id === currentTripId) {
      continue;
    }
    const trip = parseTripSnapshot(doc.id, doc.data());
    if (
      [
        "DRIVER_ASSIGNED_WAITING_ACCEPTANCE",
        "DRIVER_ACCEPTED",
        "DRIVER_EN_ROUTE",
        "DRIVER_ARRIVED",
      ].includes(trip.status) &&
      trip.pickup
    ) {
      return {
        assignmentId: trip.id,
        pickup: trip.pickup,
        pickupAddress: trip.pickupAddress,
        source: "trip",
      };
    }
  }
  return null;
}

async function loadActiveApprovalsByDriver(params: {
  firestore: admin.firestore.Firestore;
}): Promise<Map<string, ResolvedOperationalApproval>> {
  const { firestore } = params;
  const snapshot = await firestore
    .collection(OPERATIONAL_MONITORING_COLLECTIONS.operationalMovementApprovals)
    .where("status", "==", OPERATIONAL_APPROVAL_STATUSES.active)
    .get();
  const now = Date.now();
  const result = new Map<string, ResolvedOperationalApproval>();
  for (const doc of snapshot.docs) {
    const approval = parseOperationalApproval(doc.id, doc.data());
    if (!approval) {
      continue;
    }
    if (approval.expiresAt.getTime() <= now) {
      await doc.ref.set(
        {
          status: OPERATIONAL_APPROVAL_STATUSES.expired,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      continue;
    }
    result.set(approval.driverId, approval);
  }
  return result;
}

async function cleanupRetentionBatch(params: {
  firestore: admin.firestore.Firestore;
  collection: string;
  field: string;
  now: Date;
}): Promise<void> {
  const { firestore, collection, field, now } = params;
  const snapshot = await firestore
    .collection(collection)
    .where(field, "<=", Timestamp.fromDate(now))
    .limit(RETENTION_BATCH_SIZE)
    .get();
  if (snapshot.empty) {
    return;
  }
  const batch = firestore.batch();
  for (const doc of snapshot.docs) {
    batch.delete(doc.ref);
  }
  await batch.commit();
}

async function completeActiveApprovalIfNeeded(params: {
  firestore: admin.firestore.Firestore;
  approval: ResolvedOperationalApproval | null;
}): Promise<void> {
  const { firestore, approval } = params;
  if (!approval) {
    return;
  }
  await firestore
    .doc(
      `${OPERATIONAL_MONITORING_COLLECTIONS.operationalMovementApprovals}/${approval.id}`,
    )
    .set(
      {
        status: OPERATIONAL_APPROVAL_STATUSES.completed,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
}

async function appendIncidentEvent(params: {
  incidentRef: admin.firestore.DocumentReference;
  action: string;
  actorId: string;
  actorRole: RbacRole | "admin";
  note?: string;
  metadata?: Record<string, unknown>;
}): Promise<void> {
  const { incidentRef, action, actorId, actorRole, note, metadata } = params;
  await incidentRef.collection("events").add({
    action,
    actorId,
    actorRole,
    ...(note ? { note } : {}),
    ...(metadata ? { metadata } : {}),
    createdAt: FieldValue.serverTimestamp(),
    retentionExpiresAt: Timestamp.fromDate(
      addDays(new Date(), 90),
    ),
  });
}

async function upsertTripOperationalMetrics(params: {
  firestore: admin.firestore.Firestore;
  trip: TripSnapshot;
  update: Partial<TripOperationalMetricsDocument>;
}): Promise<void> {
  const { firestore, trip, update } = params;
  await firestore
    .doc(
      `${OPERATIONAL_MONITORING_COLLECTIONS.tripOperationalMetrics}/${trip.id}`,
    )
    .set(
      {
        tripId: trip.id,
        driverId: trip.assignedDriverId,
        vehicleId: trip.vehicleId,
        ...toTripOperationalMetricsPayload(update),
        retentionExpiresAt: Timestamp.fromDate(
          addDays(new Date(), 90),
        ),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
}

async function readDriverOperationalState(
  ref: admin.firestore.DocumentReference,
): Promise<DriverOperationalStateDocument> {
  const snapshot = await ref.get();
  return parseDriverOperationalState(snapshot.id, snapshot.data() ?? {});
}

async function fetchTripSnapshot(params: {
  firestore: admin.firestore.Firestore;
  tripId: string;
}): Promise<TripSnapshot | null> {
  const snapshot = await params.firestore.doc(`trips/${params.tripId}`).get();
  if (!snapshot.exists) {
    return null;
  }
  return parseTripSnapshot(params.tripId, snapshot.data() ?? {});
}

async function fetchOperationalIncident(params: {
  firestore: admin.firestore.Firestore;
  incidentId: string;
}): Promise<(OperationalIncidentDocument & { id: string }) | null> {
  const snapshot = await params.firestore
    .doc(
      `${OPERATIONAL_MONITORING_COLLECTIONS.operationalIncidents}/${params.incidentId}`,
    )
    .get();
  if (!snapshot.exists) {
    return null;
  }
  const incident = parseOperationalIncident(snapshot.id, snapshot.data() ?? {});
  return incident ? { ...incident, id: snapshot.id } : null;
}

async function fetchDriverSummary(params: {
  firestore: admin.firestore.Firestore;
  driverId: string;
}): Promise<{ name: string } | null> {
  const snapshot = await params.firestore.doc(`users/${params.driverId}`).get();
  const name = snapshot.data()?.name;
  return typeof name === "string" && name.trim().length > 0
    ? { name: name.trim() }
    : null;
}

async function fetchVehicleSummary(params: {
  firestore: admin.firestore.Firestore;
  vehicleId: string | null;
}): Promise<{ plate: string } | null> {
  if (!params.vehicleId) {
    return null;
  }
  const snapshot = await params.firestore
    .doc(`vehicles/${params.vehicleId}`)
    .get();
  const plate = snapshot.data()?.plate;
  return typeof plate === "string" && plate.trim().length > 0
    ? { plate: plate.trim() }
    : null;
}

async function readRealtimeLocation(params: {
  realtimeDb: admin.database.Database;
  driverId: string;
}): Promise<LocationSnapshot | null> {
  const snapshot = await params.realtimeDb
    .ref(`driverLocations/${params.driverId}`)
    .get();
  return parseRealtimeLocation(snapshot.val());
}

async function readTripPathSamples(params: {
  firestore: admin.firestore.Firestore;
  tripId: string;
}): Promise<ReplaySample[]> {
  const snapshot = await params.firestore
    .collection(`trips/${params.tripId}/pathPoints`)
    .orderBy("timestamp", "desc")
    .limit(MAX_INCIDENT_REPLAY_SAMPLES)
    .get();
  return snapshot.docs
    .map((doc) => {
      const data = doc.data();
      const timestamp = parseDate(data.timestamp);
      const latitude = parseNumber(data.latitude);
      const longitude = parseNumber(data.longitude);
      if (!timestamp || latitude == null || longitude == null) {
        return null;
      }
      return {
        latitude,
        longitude,
        recordedAt: timestamp,
      };
    })
    .filter((sample): sample is ReplaySample => sample != null)
    .reverse();
}

export function resolveIncidentReplaySamples(params: {
  operationalWindowType: OperationalWindowType;
  driverId: string;
  tripId: string | null;
  tripPathSamples: ReplaySample[];
  replaySamples: ReplaySample[];
}): ReplaySample[] {
  const {
    operationalWindowType,
    driverId,
    tripId,
    tripPathSamples,
    replaySamples,
  } = params;
  if (operationalWindowType !== OPERATIONAL_WINDOW_TYPES.activeTrip) {
    return replaySamples.slice(-MAX_INCIDENT_REPLAY_SAMPLES);
  }
  if (tripPathSamples.length > 0) {
    return tripPathSamples.slice(-MAX_INCIDENT_REPLAY_SAMPLES);
  }
  logger.warn(
    "Active trip incident has no trip path points; using replay samples fallback.",
    {
      driverId,
      tripId,
      replaySampleCount: replaySamples.length,
    },
  );
  return replaySamples.slice(-MAX_INCIDENT_REPLAY_SAMPLES);
}

function buildOffDutyStatePayload(params: {
  driverStatus: DriverStatusSnapshot;
  state: DriverOperationalStateDocument;
  latestLocation: LocationSnapshot | null;
}): Record<string, unknown> {
  const { driverStatus, state, latestLocation } = params;
  return {
    driverId: driverStatus.driverId,
    vehicleId: driverStatus.vehicleId,
    linkedTripId: state.linkedTripId ?? null,
    currentState: OPERATIONAL_STATES.offDuty,
    operationalWindowId: FieldValue.delete(),
    operationalWindowType: FieldValue.delete(),
    monitoringSuppressed: true,
    suppressionReason: "off_duty",
    replaySamples: [],
    actualWindowDistanceKm: 0,
    currentOpenIncidentId: FieldValue.delete(),
    activeApprovalSummary: FieldValue.delete(),
    latestLocation: latestLocation
      ? toLocationSnapshotPayload(latestLocation)
      : FieldValue.delete(),
    nonCompliantSinceAt: FieldValue.delete(),
    compliantSinceAt: FieldValue.delete(),
    updatedAt: FieldValue.serverTimestamp(),
  };
}

function buildNoTripWindowPayload(params: {
  state: DriverOperationalStateDocument;
  driverStatus: DriverStatusSnapshot;
  latestLocation: LocationSnapshot | null;
  activeApproval: ResolvedOperationalApproval | null;
  operationalWindowId: string;
}): Record<string, unknown> {
  const {
    state,
    driverStatus,
    latestLocation,
    activeApproval,
    operationalWindowId,
  } = params;
  return {
    driverId: driverStatus.driverId,
    vehicleId: driverStatus.vehicleId,
    tripId: FieldValue.delete(),
    operationalWindowId,
    operationalWindowType: OPERATIONAL_WINDOW_TYPES.noTripOperational,
    currentState: activeApproval
      ? OPERATIONAL_STATES.approvedReposition
      : OPERATIONAL_STATES.operationalIdle,
    monitoringSuppressed: false,
    suppressionReason: FieldValue.delete(),
    windowStartedAt:
      state.operationalWindowId === operationalWindowId && state.windowStartedAt
        ? Timestamp.fromDate(state.windowStartedAt)
        : Timestamp.fromDate(
            latestLocation?.recordedAt ?? new Date(),
          ),
    windowAnchorLocation:
      state.operationalWindowId === operationalWindowId &&
      state.windowAnchorLocation
        ? state.windowAnchorLocation
        : latestLocation
          ? {
              latitude: latestLocation.latitude,
              longitude: latestLocation.longitude,
            }
          : FieldValue.delete(),
    actualWindowDistanceKm:
      state.operationalWindowId === operationalWindowId
        ? (state.actualWindowDistanceKm ?? 0)
        : 0,
    replaySamples:
      state.operationalWindowId === operationalWindowId
        ? (state.replaySamples ?? []).map(toReplaySamplePayload)
        : [],
    activeApprovalSummary: activeApproval
      ? {
          approvalId: activeApproval.id,
          reason: activeApproval.reason,
          expiresAt: Timestamp.fromDate(
            activeApproval.expiresAt,
          ),
          destinationLabel: activeApproval.destination?.address ?? null,
        }
      : FieldValue.delete(),
    updatedAt: FieldValue.serverTimestamp(),
  };
}

function buildActiveTripOperationalWindowId(tripId: string): string {
  return `trip:${tripId}:active`;
}

function buildPostDropoffOperationalWindowId(params: {
  tripId: string;
  arrivedDestinationAt: Date;
}): string {
  return `trip:${params.tripId}:postdropoff:${params.arrivedDestinationAt.getTime()}`;
}

function buildNoTripOperationalWindowId(params: {
  driverId: string;
  startedAt: Date;
}): string {
  return `driver:${params.driverId}:idle:${params.startedAt.getTime()}`;
}

function hasReachedPostDropoffCutoff(params: {
  state: DriverOperationalStateDocument;
  latestLocation: LocationSnapshot | null;
  config: OperationalMonitoringConfig;
  nextAssignment: AssignmentSnapshot | null;
}): boolean {
  const { state, latestLocation, config, nextAssignment } = params;
  if (!latestLocation) {
    return false;
  }
  return (
    nextAssignment != null ||
    isAtBase({ latestLocation, config }) ||
    (state.currentState === OPERATIONAL_STATES.postDropoffWaiting &&
      state.graceEndsAt != null &&
      latestLocation.recordedAt.getTime() > state.graceEndsAt.getTime() &&
      state.dropoffLocation != null &&
      haversineDistanceMeters(latestLocation, state.dropoffLocation) <=
        config.dropoffWaitingRadiusMeters)
  );
}

function resolvePostDropoffResolutionReason(params: {
  state: DriverOperationalStateDocument;
  latestLocation: LocationSnapshot | null;
  config: OperationalMonitoringConfig;
  nextAssignment: AssignmentSnapshot | null;
}): string {
  const { state, latestLocation, config, nextAssignment } = params;
  if (nextAssignment) {
    return "next_assignment_started";
  }
  if (latestLocation && isAtBase({ latestLocation, config })) {
    return "entered_base";
  }
  if (
    latestLocation &&
    state.dropoffLocation &&
    haversineDistanceMeters(latestLocation, state.dropoffLocation) <=
      config.dropoffWaitingRadiusMeters
  ) {
    return "entered_waiting_zone";
  }
  return "went_off_duty";
}

function resolveExpectedPostDropoffKm(params: {
  state: DriverOperationalStateDocument;
  config: OperationalMonitoringConfig;
  nextAssignment: AssignmentSnapshot | null;
}): number | null {
  const { state, config, nextAssignment } = params;
  if (nextAssignment && state.dropoffLocation) {
    return roundKm(
      haversineDistanceMeters(state.dropoffLocation, nextAssignment.pickup) /
        1000,
    );
  }
  if (
    state.currentState === OPERATIONAL_STATES.postDropoffWaiting ||
    state.currentState === OPERATIONAL_STATES.atBase
  ) {
    return config.postDropoffLocalMovementAllowanceKm;
  }
  return state.cachedExpectedRoute?.distanceKm ?? null;
}

function isMonitoringEnabled(params: {
  driverStatus: DriverStatusSnapshot;
  currentTrip: TripSnapshot | null;
  activeApproval: ResolvedOperationalApproval | null;
  tripForWindow: TripSnapshot | null;
}): boolean {
  const { driverStatus, currentTrip, activeApproval, tripForWindow } = params;
  return (
    driverStatus.isActive &&
    driverStatus.availabilityEnabled &&
    !!driverStatus.vehicleId &&
    (driverStatus.isAvailable ||
      currentTrip != null ||
      activeApproval != null ||
      tripForWindow?.postChargeExtensionActive === true)
  );
}

function isTelemetryStale(params: {
  latestLocation: LocationSnapshot | null;
  config: OperationalMonitoringConfig;
}): boolean {
  if (!params.latestLocation) {
    return true;
  }
  return (
    Date.now() - params.latestLocation.recordedAt.getTime() >
    params.config.staleTelemetryThresholdSeconds * 1000
  );
}

function isAtBase(params: {
  latestLocation: GeoPointLiteral | null;
  config: OperationalMonitoringConfig;
}): boolean {
  if (!params.latestLocation || !params.config.baseGeofence) {
    return false;
  }
  return isInsideCircularGeofence({
    point: params.latestLocation,
    geofence: params.config.baseGeofence,
  });
}

function isOnCachedRoute(params: {
  location: GeoPointLiteral;
  state: DriverOperationalStateDocument;
  config: OperationalMonitoringConfig;
}): boolean {
  const { location, state, config } = params;
  if (!state.cachedExpectedRoute?.encodedPolyline) {
    return false;
  }
  return (
    distanceToPolylineMeters({
      point: location,
      polyline: decodePolyline(state.cachedExpectedRoute.encodedPolyline),
    }) <= config.routeDeviationCorridorMeters
  );
}

function shouldAppendReplaySample(params: {
  previousLocation: LocationSnapshot | null;
  nextLocation: LocationSnapshot;
  config: OperationalMonitoringConfig;
}): boolean {
  const { previousLocation, nextLocation, config } = params;
  if (!previousLocation) {
    return true;
  }
  const deltaMs =
    nextLocation.recordedAt.getTime() - previousLocation.recordedAt.getTime();
  const deltaMeters = haversineDistanceMeters(previousLocation, nextLocation);
  return (
    deltaMs >= config.replaySampleMinIntervalSeconds * 1000 ||
    deltaMeters >= config.replaySampleMinDistanceMeters
  );
}

function calculatePathDeltaKm(params: {
  previousLocation: (GeoPointLiteral & { recordedAt?: Date }) | null;
  nextLocation: LocationSnapshot;
  config: OperationalMonitoringConfig;
}): number {
  const { previousLocation, nextLocation, config } = params;
  if (!previousLocation?.recordedAt) {
    return 0;
  }
  if (
    nextLocation.recordedAt.getTime() - previousLocation.recordedAt.getTime() >
    config.staleTelemetryThresholdSeconds * 1000
  ) {
    return 0;
  }
  return roundKm(
    haversineDistanceMeters(previousLocation, nextLocation) / 1000,
  );
}

function parseDriverStatusSnapshot(
  driverId: string,
  data: Record<string, unknown>,
): DriverStatusSnapshot {
  return {
    driverId,
    isActive: data.isActive !== false,
    isAvailable: data.isAvailable === true,
    availabilityEnabled: data.availabilityEnabled !== false,
    vehicleId: normalizeOptionalString(data.vehicleId),
    currentTripId: normalizeOptionalString(data.currentTripId),
    isBusy: data.isBusy === true,
  };
}

function parseTripSnapshot(
  tripId: string,
  data: Record<string, unknown>,
): TripSnapshot {
  return {
    id: tripId,
    status: normalizeStatus(data.status),
    assignedDriverId: normalizeOptionalString(data.assignedDriverId),
    vehicleId: normalizeOptionalString(data.vehicleId),
    pickup: parseLocation(data.pickup),
    pickupAddress: parseLocationWithAddress(data.pickup)?.address ?? null,
    destination: parseLocation(data.destination),
    destinationAddress:
      parseLocationWithAddress(data.destination)?.address ?? null,
    meteringDistanceKm: parseMeteringDistance(data.meteringSnapshot),
    startedAt: parseDate(data.startedAt),
    arrivedDestinationAt: parseDate(data.arrivedDestinationAt),
    completedAt: parseDate(data.completedAt),
    postChargeExtensionActive:
      parseBooleanFromNested(data.postChargeExtension, "isActive") === true,
  };
}

function parseDriverOperationalState(
  driverId: string,
  data: Record<string, unknown>,
): DriverOperationalStateDocument {
  return {
    driverId,
    driverName: normalizeOptionalString(data.driverName) ?? undefined,
    vehicleId: normalizeOptionalString(data.vehicleId),
    vehiclePlate: normalizeOptionalString(data.vehiclePlate),
    tripId: normalizeOptionalString(data.tripId),
    linkedTripId: normalizeOptionalString(data.linkedTripId),
    operationalWindowId: normalizeOptionalString(data.operationalWindowId),
    operationalWindowType: normalizeWindowType(data.operationalWindowType),
    currentState:
      normalizeOperationalState(data.currentState) ??
      OPERATIONAL_STATES.offDuty,
    monitoringSuppressed: data.monitoringSuppressed === true,
    suppressionReason: normalizeOptionalString(data.suppressionReason),
    latestLocation: parseLocationSnapshot(data.latestLocation),
    lastProcessedRtdbTimestamp: parseDate(data.lastProcessedRtdbTimestamp),
    currentOpenIncidentId: normalizeOptionalString(data.currentOpenIncidentId),
    activeApprovalSummary: parseActiveApprovalSummary(
      data.activeApprovalSummary,
    ),
    cachedExpectedRoute: parseExpectedRoute(data.cachedExpectedRoute),
    replaySamples: parseReplaySamples(data.replaySamples),
    actualWindowDistanceKm: parseNumber(data.actualWindowDistanceKm) ?? 0,
    windowStartedAt: parseDate(data.windowStartedAt),
    windowAnchorLocation: parseLocation(data.windowAnchorLocation),
    dropoffLocation: parseLocation(data.dropoffLocation),
    dropoffAt: parseDate(data.dropoffAt),
    graceEndsAt: parseDate(data.graceEndsAt),
    lastDistanceToTripDestinationMeters: parseNumber(
      data.lastDistanceToTripDestinationMeters,
    ),
    lastDistanceToBaseMeters: parseNumber(data.lastDistanceToBaseMeters),
    nonCompliantSinceAt: parseDate(data.nonCompliantSinceAt),
    compliantSinceAt: parseDate(data.compliantSinceAt),
    updatedAt: parseDate(data.updatedAt),
  };
}

function parseOperationalIncident(
  incidentId: string,
  data: Record<string, unknown>,
): (OperationalIncidentDocument & { id: string }) | null {
  const operationalWindowId = normalizeOptionalString(data.operationalWindowId);
  const operationalWindowType = normalizeWindowType(data.operationalWindowType);
  const driverId = normalizeOptionalString(data.driverId);
  const incidentType = normalizeIncidentType(data.incidentType);
  const status = normalizeIncidentStatus(data.status);
  const startedAt = parseDate(data.startedAt);
  const originCoordinates = parseLocationSnapshot(data.originCoordinates);
  const latestCoordinates = parseLocationSnapshot(data.latestCoordinates);
  const currentState = normalizeOperationalState(data.currentState);
  if (
    !operationalWindowId ||
    !operationalWindowType ||
    !driverId ||
    !incidentType ||
    !status ||
    !startedAt ||
    !originCoordinates ||
    !latestCoordinates ||
    !currentState
  ) {
    return null;
  }
  return {
    id: incidentId,
    operationalWindowId,
    operationalWindowType,
    driverId,
    driverName: normalizeOptionalString(data.driverName) ?? undefined,
    vehicleId: normalizeOptionalString(data.vehicleId),
    vehiclePlate: normalizeOptionalString(data.vehiclePlate),
    tripId: normalizeOptionalString(data.tripId),
    incidentType,
    subreason: normalizeOptionalString(data.subreason),
    status,
    startedAt,
    resolvedAt: parseDate(data.resolvedAt),
    resolutionSource:
      data.resolutionSource === "system" || data.resolutionSource === "reviewer"
        ? data.resolutionSource
        : null,
    resolutionReason: normalizeOptionalString(data.resolutionReason),
    currentState,
    originCoordinates,
    latestCoordinates,
    expectedPolyline: normalizeOptionalString(data.expectedPolyline),
    actualPathSamples: parseReplaySamples(data.actualPathSamples),
    expectedTripDistanceKm: parseNumber(data.expectedTripDistanceKm),
    actualTripDistanceKm: parseNumber(data.actualTripDistanceKm),
    tripDistanceVarianceKm: parseNumber(data.tripDistanceVarianceKm),
    tripDistanceVariancePct: parseNumber(data.tripDistanceVariancePct),
    expectedPostDropoffDistanceKm: parseNumber(
      data.expectedPostDropoffDistanceKm,
    ),
    actualPostDropoffDistanceKm: parseNumber(data.actualPostDropoffDistanceKm),
    postDropoffVarianceKm: parseNumber(data.postDropoffVarianceKm),
    postDropoffVariancePct: parseNumber(data.postDropoffVariancePct),
    expectedNoTripDistanceKm: parseNumber(data.expectedNoTripDistanceKm),
    actualNoTripDistanceKm: parseNumber(data.actualNoTripDistanceKm),
    noTripVarianceKm: parseNumber(data.noTripVarianceKm),
    noTripVariancePct: parseNumber(data.noTripVariancePct),
    totalExpectedDistanceKm: parseNumber(data.totalExpectedDistanceKm),
    totalActualDistanceKm: parseNumber(data.totalActualDistanceKm),
    totalVarianceKm: parseNumber(data.totalVarianceKm),
    totalVariancePct: parseNumber(data.totalVariancePct),
    tripStartedAt: parseDate(data.tripStartedAt),
    dropoffAt: parseDate(data.dropoffAt),
    postDropoffWindowStartedAt: parseDate(data.postDropoffWindowStartedAt),
    baseArrivedAt: parseDate(data.baseArrivedAt),
    nextAssignmentAt: parseDate(data.nextAssignmentAt),
    offDutyAt: parseDate(data.offDutyAt),
    reviewNote: normalizeOptionalString(data.reviewNote),
    clearanceCandidateStartedAt: parseDate(data.clearanceCandidateStartedAt),
    retentionExpiresAt: parseDate(data.retentionExpiresAt),
    createdAt: parseDate(data.createdAt),
    updatedAt: parseDate(data.updatedAt),
  };
}

function parseOperationalApproval(
  approvalId: string,
  data: Record<string, unknown>,
): (OperationalMovementApprovalDocument & { id: string }) | null {
  const operationalWindowId = normalizeOptionalString(data.operationalWindowId);
  const operationalWindowType = normalizeWindowType(data.operationalWindowType);
  const driverId = normalizeOptionalString(data.driverId);
  const reason = normalizeOptionalString(data.reason);
  const expiresAt = parseDate(data.expiresAt);
  const approvedBy = normalizeOptionalString(data.approvedBy);
  const approvedByRole =
    data.approvedByRole === "admin" || data.approvedByRole === "manager"
      ? data.approvedByRole
      : null;
  const status =
    data.status === OPERATIONAL_APPROVAL_STATUSES.active ||
    data.status === OPERATIONAL_APPROVAL_STATUSES.expired ||
    data.status === OPERATIONAL_APPROVAL_STATUSES.completed ||
    data.status === OPERATIONAL_APPROVAL_STATUSES.revoked
      ? data.status
      : null;
  if (
    !operationalWindowId ||
    !operationalWindowType ||
    !driverId ||
    !reason ||
    !expiresAt ||
    !approvedBy ||
    !approvedByRole ||
    !status
  ) {
    return null;
  }
  return {
    id: approvalId,
    operationalWindowId,
    operationalWindowType,
    driverId,
    driverName: normalizeOptionalString(data.driverName) ?? undefined,
    vehicleId: normalizeOptionalString(data.vehicleId),
    vehiclePlate: normalizeOptionalString(data.vehiclePlate),
    tripId: normalizeOptionalString(data.tripId),
    reason,
    expiresAt,
    destination: parseOptionalDestination(data.destination),
    allowedArea: parseOptionalAllowedArea(data.allowedArea),
    approvedBy,
    approvedByRole,
    status,
    incidentId: normalizeOptionalString(data.incidentId),
    createdAt: parseDate(data.createdAt),
    updatedAt: parseDate(data.updatedAt),
    retentionExpiresAt: parseDate(data.retentionExpiresAt),
  };
}

function parseTripOperationalMetrics(
  tripId: string,
  data: Record<string, unknown>,
): TripOperationalMetricsDocument {
  return {
    tripId,
    driverId: normalizeOptionalString(data.driverId),
    vehicleId: normalizeOptionalString(data.vehicleId),
    activeTripOperationalWindowId: normalizeOptionalString(
      data.activeTripOperationalWindowId,
    ),
    postDropoffOperationalWindowId: normalizeOptionalString(
      data.postDropoffOperationalWindowId,
    ),
    latestNoTripOperationalWindowId: normalizeOptionalString(
      data.latestNoTripOperationalWindowId,
    ),
    expectedTripDistanceKm: parseNumber(data.expectedTripDistanceKm),
    actualTripDistanceKm: parseNumber(data.actualTripDistanceKm),
    tripDistanceVarianceKm: parseNumber(data.tripDistanceVarianceKm),
    tripDistanceVariancePct: parseNumber(data.tripDistanceVariancePct),
    expectedPostDropoffDistanceKm: parseNumber(
      data.expectedPostDropoffDistanceKm,
    ),
    actualPostDropoffDistanceKm: parseNumber(data.actualPostDropoffDistanceKm),
    postDropoffVarianceKm: parseNumber(data.postDropoffVarianceKm),
    postDropoffVariancePct: parseNumber(data.postDropoffVariancePct),
    expectedNoTripDistanceKm: parseNumber(data.expectedNoTripDistanceKm),
    actualNoTripDistanceKm: parseNumber(data.actualNoTripDistanceKm),
    noTripVarianceKm: parseNumber(data.noTripVarianceKm),
    noTripVariancePct: parseNumber(data.noTripVariancePct),
    totalExpectedDistanceKm: parseNumber(data.totalExpectedDistanceKm),
    totalActualDistanceKm: parseNumber(data.totalActualDistanceKm),
    totalVarianceKm: parseNumber(data.totalVarianceKm),
    totalVariancePct: parseNumber(data.totalVariancePct),
    expectedTripPolyline: normalizeOptionalString(data.expectedTripPolyline),
    expectedPostDropoffPolyline: normalizeOptionalString(
      data.expectedPostDropoffPolyline,
    ),
    startedAt: parseDate(data.startedAt),
    arrivedDestinationAt: parseDate(data.arrivedDestinationAt),
    postDropoffWindowStartedAt: parseDate(data.postDropoffWindowStartedAt),
    postDropoffWindowEndedAt: parseDate(data.postDropoffWindowEndedAt),
    baseArrivedAt: parseDate(data.baseArrivedAt),
    nextAssignmentAt: parseDate(data.nextAssignmentAt),
    offDutyAt: parseDate(data.offDutyAt),
    noTripWindowStartedAt: parseDate(data.noTripWindowStartedAt),
    noTripWindowEndedAt: parseDate(data.noTripWindowEndedAt),
    retentionExpiresAt: parseDate(data.retentionExpiresAt),
    updatedAt: parseDate(data.updatedAt),
  };
}

function createEmptyMetrics(): TripOperationalMetricsDocument {
  return { tripId: "" };
}

function computeVariance(params: {
  expectedKm: number | null | undefined;
  actualKm: number | null | undefined;
}): { deltaKm: number | null; deltaPct: number | null } {
  const { expectedKm, actualKm } = params;
  if (expectedKm == null || actualKm == null) {
    return { deltaKm: null, deltaPct: null };
  }
  const deltaKm = roundKm(actualKm - expectedKm);
  if (expectedKm <= 0) {
    return { deltaKm, deltaPct: null };
  }
  return {
    deltaKm,
    deltaPct: roundPct((deltaKm / expectedKm) * 100),
  };
}

function sumNullable(values: Array<number | null | undefined>): number | null {
  const filtered = values.filter((value): value is number => value != null);
  if (filtered.length === 0) {
    return null;
  }
  return roundKm(filtered.reduce((sum, value) => sum + value, 0));
}

function markTripOperationalWindowEnded(params: {
  firestore: admin.firestore.Firestore;
  tripId: string;
  field: "baseArrivedAt" | "nextAssignmentAt" | "offDutyAt" | null;
}): Promise<void> {
  if (!params.tripId) {
    return Promise.resolve();
  }
  return params.firestore
    .doc(
      `${OPERATIONAL_MONITORING_COLLECTIONS.tripOperationalMetrics}/${params.tripId}`,
    )
    .set(
      {
        ...(params.field
          ? { [params.field]: FieldValue.serverTimestamp() }
          : {}),
        postDropoffWindowEndedAt: FieldValue.serverTimestamp(),
        retentionExpiresAt: Timestamp.fromDate(
          addDays(new Date(), 90),
        ),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    )
    .then(() => undefined);
}

function assertManagerReviewPermission(params: {
  role: RbacRole;
  authToken: Record<string, unknown> | null;
  context: string;
}): void {
  const { role, authToken, context } = params;
  if (role !== "manager") {
    return;
  }
  assertManagerPermission({
    role,
    authToken,
    permission: "ts",
    context,
  });
}

function toExpectedRoutePayload(
  route:
    | DriverOperationalStateDocument["cachedExpectedRoute"]
    | null
    | undefined,
) {
  if (!route) {
    return FieldValue.delete();
  }
  return {
    routeKey: route.routeKey,
    origin: route.origin,
    destination: route.destination,
    encodedPolyline: route.encodedPolyline,
    distanceKm: route.distanceKm,
    durationMinutes: route.durationMinutes,
    isFallback: route.isFallback,
    fetchedAt: Timestamp.fromDate(route.fetchedAt),
  };
}

function toLocationSnapshotPayload(location: LocationSnapshot) {
  return {
    latitude: location.latitude,
    longitude: location.longitude,
    ...(location.heading != null ? { heading: location.heading } : {}),
    ...(location.speed != null ? { speed: location.speed } : {}),
    recordedAt: Timestamp.fromDate(location.recordedAt),
  };
}

function toReplaySample(location: LocationSnapshot): ReplaySample {
  return {
    latitude: location.latitude,
    longitude: location.longitude,
    recordedAt: location.recordedAt,
  };
}

function toReplaySamplePayload(sample: ReplaySample) {
  return {
    latitude: sample.latitude,
    longitude: sample.longitude,
    recordedAt: Timestamp.fromDate(sample.recordedAt),
  };
}

function toOperationalIncidentPayload(
  incident: OperationalIncidentDocument,
): Record<string, unknown> {
  return {
    operationalWindowId: incident.operationalWindowId,
    operationalWindowType: incident.operationalWindowType,
    driverId: incident.driverId,
    ...(incident.driverName ? { driverName: incident.driverName } : {}),
    ...(incident.vehicleId ? { vehicleId: incident.vehicleId } : {}),
    ...(incident.vehiclePlate ? { vehiclePlate: incident.vehiclePlate } : {}),
    ...(incident.tripId ? { tripId: incident.tripId } : {}),
    incidentType: incident.incidentType,
    ...(incident.subreason ? { subreason: incident.subreason } : {}),
    status: incident.status,
    startedAt: Timestamp.fromDate(incident.startedAt),
    currentState: incident.currentState,
    originCoordinates: toLocationSnapshotPayload(incident.originCoordinates),
    latestCoordinates: toLocationSnapshotPayload(incident.latestCoordinates),
    ...(incident.expectedPolyline
      ? { expectedPolyline: incident.expectedPolyline }
      : {}),
    actualPathSamples: incident.actualPathSamples
      .slice(-MAX_INCIDENT_REPLAY_SAMPLES)
      .map(toReplaySamplePayload),
    ...(incident.expectedTripDistanceKm != null
      ? { expectedTripDistanceKm: incident.expectedTripDistanceKm }
      : {}),
    ...(incident.actualTripDistanceKm != null
      ? { actualTripDistanceKm: incident.actualTripDistanceKm }
      : {}),
    ...(incident.tripDistanceVarianceKm != null
      ? { tripDistanceVarianceKm: incident.tripDistanceVarianceKm }
      : {}),
    ...(incident.tripDistanceVariancePct != null
      ? { tripDistanceVariancePct: incident.tripDistanceVariancePct }
      : {}),
    ...(incident.expectedPostDropoffDistanceKm != null
      ? {
          expectedPostDropoffDistanceKm: incident.expectedPostDropoffDistanceKm,
        }
      : {}),
    ...(incident.actualPostDropoffDistanceKm != null
      ? { actualPostDropoffDistanceKm: incident.actualPostDropoffDistanceKm }
      : {}),
    ...(incident.postDropoffVarianceKm != null
      ? { postDropoffVarianceKm: incident.postDropoffVarianceKm }
      : {}),
    ...(incident.postDropoffVariancePct != null
      ? { postDropoffVariancePct: incident.postDropoffVariancePct }
      : {}),
    ...(incident.expectedNoTripDistanceKm != null
      ? { expectedNoTripDistanceKm: incident.expectedNoTripDistanceKm }
      : {}),
    ...(incident.actualNoTripDistanceKm != null
      ? { actualNoTripDistanceKm: incident.actualNoTripDistanceKm }
      : {}),
    ...(incident.noTripVarianceKm != null
      ? { noTripVarianceKm: incident.noTripVarianceKm }
      : {}),
    ...(incident.noTripVariancePct != null
      ? { noTripVariancePct: incident.noTripVariancePct }
      : {}),
    ...(incident.totalExpectedDistanceKm != null
      ? { totalExpectedDistanceKm: incident.totalExpectedDistanceKm }
      : {}),
    ...(incident.totalActualDistanceKm != null
      ? { totalActualDistanceKm: incident.totalActualDistanceKm }
      : {}),
    ...(incident.totalVarianceKm != null
      ? { totalVarianceKm: incident.totalVarianceKm }
      : {}),
    ...(incident.totalVariancePct != null
      ? { totalVariancePct: incident.totalVariancePct }
      : {}),
    ...(incident.tripStartedAt
      ? {
          tripStartedAt: Timestamp.fromDate(
            incident.tripStartedAt,
          ),
        }
      : {}),
    ...(incident.dropoffAt
      ? { dropoffAt: Timestamp.fromDate(incident.dropoffAt) }
      : {}),
    ...(incident.postDropoffWindowStartedAt
      ? {
          postDropoffWindowStartedAt: Timestamp.fromDate(
            incident.postDropoffWindowStartedAt,
          ),
        }
      : {}),
    createdAt: Timestamp.fromDate(
      incident.createdAt ?? new Date(),
    ),
    updatedAt: Timestamp.fromDate(
      incident.updatedAt ?? new Date(),
    ),
  };
}

function toOperationalApprovalPayload(
  approval: OperationalMovementApprovalDocument,
): Record<string, unknown> {
  return {
    operationalWindowId: approval.operationalWindowId,
    operationalWindowType: approval.operationalWindowType,
    driverId: approval.driverId,
    ...(approval.driverName ? { driverName: approval.driverName } : {}),
    ...(approval.vehicleId ? { vehicleId: approval.vehicleId } : {}),
    ...(approval.vehiclePlate ? { vehiclePlate: approval.vehiclePlate } : {}),
    ...(approval.tripId ? { tripId: approval.tripId } : {}),
    reason: approval.reason,
    expiresAt: Timestamp.fromDate(approval.expiresAt),
    ...(approval.destination ? { destination: approval.destination } : {}),
    ...(approval.allowedArea ? { allowedArea: approval.allowedArea } : {}),
    approvedBy: approval.approvedBy,
    approvedByRole: approval.approvedByRole,
    status: approval.status,
    ...(approval.incidentId ? { incidentId: approval.incidentId } : {}),
    createdAt: Timestamp.fromDate(
      approval.createdAt ?? new Date(),
    ),
    updatedAt: Timestamp.fromDate(
      approval.updatedAt ?? new Date(),
    ),
    retentionExpiresAt: Timestamp.fromDate(
      approval.retentionExpiresAt ?? addDays(approval.expiresAt, 90),
    ),
  };
}

function toTripOperationalMetricsPayload(
  update: Partial<TripOperationalMetricsDocument>,
): Record<string, unknown> {
  const payload: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(update)) {
    if (value == null) {
      continue;
    }
    payload[key] =
      value instanceof Date ? Timestamp.fromDate(value) : value;
  }
  return payload;
}

function parseRealtimeLocation(value: unknown): LocationSnapshot | null {
  if (!value || typeof value !== "object") {
    return null;
  }
  const source = value as Record<string, unknown>;
  const coords = Array.isArray(source.l) ? source.l : [];
  const latitude = parseNumber(coords[0]);
  const longitude = parseNumber(coords[1]);
  const recordedAt = parseDate(source.ts);
  if (latitude == null || longitude == null || !recordedAt) {
    return null;
  }
  return {
    latitude,
    longitude,
    heading: parseNumber(source.heading) ?? undefined,
    speed: parseNumber(source.speed) ?? undefined,
    recordedAt,
  };
}

function parseLocation(value: unknown): GeoPointLiteral | null {
  if (!value || typeof value !== "object") {
    return null;
  }
  const source = value as Record<string, unknown>;
  const latitude = parseNumber(source.latitude);
  const longitude = parseNumber(source.longitude);
  if (latitude == null || longitude == null) {
    return null;
  }
  return { latitude, longitude };
}

function parseLocationWithAddress(
  value: unknown,
): (GeoPointLiteral & { address?: string | null }) | null {
  const location = parseLocation(value);
  if (!location) {
    return null;
  }
  const source = value as Record<string, unknown>;
  return {
    ...location,
    address: normalizeOptionalString(source.address),
  };
}

function parseOptionalDestination(
  value: unknown,
): (GeoPointLiteral & { address?: string }) | null {
  if (!value || typeof value !== "object") {
    return null;
  }
  const source = value as Record<string, unknown>;
  const latitude = parseNumber(source.latitude);
  const longitude = parseNumber(source.longitude);
  const address = normalizeOptionalString(source.address);
  if (latitude == null || longitude == null) {
    return null;
  }
  return {
    latitude,
    longitude,
    ...(address ? { address } : {}),
  };
}

function parseOptionalAllowedArea(value: unknown): CircularGeofence | null {
  if (!value || typeof value !== "object") {
    return null;
  }
  const source = value as Record<string, unknown>;
  const center = parseLocation(source.center);
  const radiusMeters = parseNumber(source.radiusMeters);
  if (!center || radiusMeters == null) {
    return null;
  }
  return {
    label: normalizeOptionalString(source.label) ?? undefined,
    center,
    radiusMeters,
  };
}

function parseLocationSnapshot(value: unknown): LocationSnapshot | null {
  if (!value || typeof value !== "object") {
    return null;
  }
  const source = value as Record<string, unknown>;
  const location = parseLocation(source);
  const recordedAt = parseDate(source.recordedAt);
  if (!location || !recordedAt) {
    return null;
  }
  return {
    ...location,
    heading: parseNumber(source.heading) ?? undefined,
    speed: parseNumber(source.speed) ?? undefined,
    recordedAt,
  };
}

function parseActiveApprovalSummary(
  value: unknown,
): DriverOperationalStateDocument["activeApprovalSummary"] | null {
  if (!value || typeof value !== "object") {
    return null;
  }
  const source = value as Record<string, unknown>;
  const approvalId = normalizeOptionalString(source.approvalId);
  const reason = normalizeOptionalString(source.reason);
  const expiresAt = parseDate(source.expiresAt);
  if (!approvalId || !reason || !expiresAt) {
    return null;
  }
  return {
    approvalId,
    reason,
    expiresAt,
    destinationLabel: normalizeOptionalString(source.destinationLabel),
  };
}

function parseExpectedRoute(
  value: unknown,
): DriverOperationalStateDocument["cachedExpectedRoute"] | null {
  if (!value || typeof value !== "object") {
    return null;
  }
  const source = value as Record<string, unknown>;
  const routeKey = normalizeOptionalString(source.routeKey);
  const origin = parseLocation(source.origin);
  const destination = parseLocation(source.destination);
  const encodedPolyline = normalizeOptionalString(source.encodedPolyline);
  const distanceKm = parseNumber(source.distanceKm);
  const durationMinutes = parseNumber(source.durationMinutes);
  const fetchedAt = parseDate(source.fetchedAt);
  const isFallback = source.isFallback === true;
  if (
    !routeKey ||
    !origin ||
    !destination ||
    !encodedPolyline ||
    distanceKm == null ||
    durationMinutes == null ||
    !fetchedAt
  ) {
    return null;
  }
  return {
    routeKey,
    origin,
    destination,
    encodedPolyline,
    distanceKm,
    durationMinutes,
    isFallback,
    fetchedAt,
  };
}

function parseReplaySamples(value: unknown): ReplaySample[] {
  if (!Array.isArray(value)) {
    return [];
  }
  return value
    .map((entry) => {
      if (!entry || typeof entry !== "object") {
        return null;
      }
      const source = entry as Record<string, unknown>;
      const latitude = parseNumber(source.latitude);
      const longitude = parseNumber(source.longitude);
      const recordedAt = parseDate(source.recordedAt);
      if (latitude == null || longitude == null || !recordedAt) {
        return null;
      }
      return {
        latitude,
        longitude,
        recordedAt,
      };
    })
    .filter((entry): entry is ReplaySample => entry != null);
}

function parseApprovalExpiry(value: unknown): Date {
  const parsed = parseDate(value);
  if (!parsed) {
    throw new HttpsError("invalid-argument", "Expiração inválida.");
  }
  return parsed;
}

function parseMeteringDistance(value: unknown): number | null {
  if (!value || typeof value !== "object") {
    return null;
  }
  return parseNumber((value as Record<string, unknown>).totalDistanceKm);
}

function parseBooleanFromNested(value: unknown, key: string): boolean | null {
  if (!value || typeof value !== "object") {
    return null;
  }
  const nestedValue = (value as Record<string, unknown>)[key];
  return typeof nestedValue === "boolean" ? nestedValue : null;
}

function normalizeStatus(value: unknown): string {
  return typeof value === "string" ? value.trim().toUpperCase() : "";
}

function normalizeOptionalString(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }
  const normalized = value.trim();
  return normalized.length > 0 ? normalized : null;
}

function normalizeWindowType(value: unknown): OperationalWindowType | null {
  return value === OPERATIONAL_WINDOW_TYPES.activeTrip ||
    value === OPERATIONAL_WINDOW_TYPES.postDropoff ||
    value === OPERATIONAL_WINDOW_TYPES.noTripOperational
    ? value
    : null;
}

function normalizeOperationalState(value: unknown): OperationalState | null {
  return Object.values(OPERATIONAL_STATES).includes(value as OperationalState)
    ? (value as OperationalState)
    : null;
}

function normalizeIncidentType(value: unknown) {
  return Object.values(OPERATIONAL_INCIDENT_TYPES).includes(value as never)
    ? (value as OperationalIncidentDocument["incidentType"])
    : null;
}

function normalizeIncidentStatus(
  value: unknown,
): OperationalIncidentStatus | null {
  return Object.values(OPERATIONAL_INCIDENT_STATUSES).includes(value as never)
    ? (value as OperationalIncidentStatus)
    : null;
}

function parseDate(value: unknown): Date | null {
  if (!value) {
    return null;
  }
  if (value instanceof Date) {
    return value;
  }
  if (typeof value === "number" && Number.isFinite(value)) {
    return new Date(value);
  }
  if (
    typeof value === "object" &&
    "toDate" in (value as Record<string, unknown>)
  ) {
    const maybeDate = (value as { toDate?: () => Date }).toDate?.();
    return maybeDate instanceof Date ? maybeDate : null;
  }
  return null;
}

function parseNumber(value: unknown): number | null {
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

function roundKm(value: number): number {
  return Math.round(value * 1000) / 1000;
}

function roundPct(value: number): number {
  return Math.round(value * 10) / 10;
}

function addMinutes(value: Date, minutes: number): Date {
  return new Date(value.getTime() + minutes * 60 * 1000);
}

function addDays(value: Date, days: number): Date {
  return new Date(value.getTime() + days * 24 * 60 * 60 * 1000);
}
