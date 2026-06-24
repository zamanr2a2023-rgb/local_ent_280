import * as admin from "firebase-admin";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { assertManagerPermission } from "../shared/auth/managerPermissionClaims";
import {
  requireAuthenticatedUid,
  resolveCallerRole,
  type RbacRole,
} from "../shared/auth/rbacRoleResolver";
import { CALLABLE_RUNTIME_OPTIONS, OPERATION_CURRENCY_CODE } from "../shared/constants";
import {
  dispatchNotificationToTargets,
  fetchNotificationTargetsByRoles,
} from "../shared/notifications/fcmFanout";
import { type TripsFunctions } from "../trips/buildTripsFunctions";
import {
  buildLocalDayKey,
  getLocalDateParts,
} from "./tripPackageTime";
import {
  TRIP_PACKAGE_APPROVAL_DECISIONS,
  TRIP_PACKAGE_ACTIVATION_LEAD_MINUTES,
  TRIP_PACKAGE_ASSIGNMENT_RETRY_MINUTES,
  TRIP_PACKAGE_ASSIGNMENT_WINDOW_LEAD_MINUTES,
  TRIP_PACKAGE_BOOKING_STATUSES,
  TRIP_PACKAGE_CANCELLATION_REASON_CODES,
  TRIP_PACKAGE_OPS_ISSUE_CODES,
  TRIP_PACKAGE_OPS_QUEUE_BUCKETS,
  TRIP_PACKAGE_OPERATION_TIMEZONE,
  TRIP_PACKAGE_REFUND_STATUSES,
  buildTripPackageActivationAt,
  buildNextTripPackageAssignmentAttemptAt,
  buildTripPackageAssignmentWindowStartsAt,
  buildTripPackageBookingOperationId,
  buildTripPackageBookingRequestHash,
  buildTripPackageChargeLedgerId,
  buildTripPackageClientCancellationClosesAt,
  buildTripPackageRefundLedgerId,
  isTripPackagePurchaseAllowed,
  canClientCancelTripPackageBooking,
  deriveTripPackageOpsQueueBucket,
  isTripPackageBookingActionable,
  isTripPackageBookingTerminal,
  normalizeTripPackageBookingStatus,
  type TripPackageApprovalDecision,
  type TripPackageBookingStatus,
  type TripPackageOpsIssueCode,
  type TripPackageOpsQueueBucket,
} from "./tripPackagePolicy";

const RESERVATION_STATUS_SCHEDULED = "scheduled";
const RESERVATION_STATUS_PENDING = "pending";
const RESERVATION_STATUS_CONFIRMED = "confirmed";
const RESERVATION_STATUS_CANCELLED = "cancelled";
const ACTIVE_RESERVATION_STATUSES = [
  RESERVATION_STATUS_SCHEDULED,
  RESERVATION_STATUS_PENDING,
  RESERVATION_STATUS_CONFIRMED,
] as const;
const JOB_BATCH_LIMIT = 50;
const TRIP_PACKAGE_MIN_MULTIPLIER_BASIS_POINTS = 5000;
const TRIP_PACKAGE_MAX_MULTIPLIER_BASIS_POINTS = 30000;
const DRIVER_STATUS_COLLECTION = "driverStatus";
const PACKAGE_SOURCE = "package";
const AVERAGE_SPEED_KMH = 35;
const MIN_OPERATION_WINDOW_MINUTES = 15;
const TRIP_PACKAGE_ASSIGNMENT_STATUSES = {
  pending: "pending",
  assigned: "assigned",
  failed: "failed",
} as const;
const ACTIVE_TRIP_STATUSES = new Set<string>([
  "REQUESTED",
  "DRIVER_ASSIGNED_WAITING_ACCEPTANCE",
  "DRIVER_ACCEPTED",
  "DRIVER_EN_ROUTE",
  "DRIVER_ARRIVED",
  "IN_TRIP",
  "ARRIVED_DESTINATION",
  "EXTENSION_WINDOW",
  "COMPLETED",
]);
const INACTIVE_TRIP_STATUSES = new Set<string>([
  "CHARGE_APPLIED",
  "CANCELLED_BY_CLIENT",
  "CANCELLED_BY_DRIVER",
  "NO_SHOW",
  "NO_DRIVERS_AVAILABLE",
]);

type MoneyPayload = {
  amountMinor: number;
  currency: string;
};

type TripLocationPayload = {
  latitude: number;
  longitude: number;
  address: string;
};

type TransportSnapshotPayload = {
  id: string;
  name: string;
  packagePriceMultiplierBasisPoints: number;
};

type TripPackageTemplateDocument = {
  name: string;
  photoUrl: string;
  description: string;
  destination: TripLocationPayload;
  price: MoneyPayload;
  allowedTransportTypes: TransportSnapshotPayload[];
  isActive: boolean;
  snapshotVersion: number;
  archivedAt: Timestamp | null;
  createdAt?: Timestamp | null;
  updatedAt?: Timestamp | null;
};

type TripPackageSnapshotDocument = {
  packageId: string;
  snapshotVersion: number;
  name: string;
  photoUrl: string;
  description: string;
  destination: TripLocationPayload;
  price: MoneyPayload;
  allowedTransportTypes: TransportSnapshotPayload[];
};

type TripPackageBookingDocument = {
  clientId: string;
  packageId: string;
  reservationId: string;
  tripId?: string | null;
  assignedDriverId?: string | null;
  assignedVehicleId?: string | null;
  packageSnapshot: TripPackageSnapshotDocument;
  pickup: TripLocationPayload;
  destinationSnapshot: TripLocationPayload;
  scheduledAt: Timestamp;
  transportType: TransportSnapshotPayload;
  price: MoneyPayload;
  priceAdjustmentMinor: number;
  clientCancellationClosesAt: Timestamp;
  status: string;
  refundStatus: string;
  chargedAmount: MoneyPayload;
  refundedAmount: MoneyPayload;
  assignmentStatus?: string;
  assignmentWindowStartsAt?: Timestamp | null;
  nextAssignmentAttemptAt?: Timestamp | null;
  lastAssignmentAttemptAt?: Timestamp | null;
  assignmentAttemptsCount?: number;
  approval?: {
    requestedAt?: Timestamp | null;
    decidedAt?: Timestamp | null;
    decidedByUserId?: string | null;
    decidedByRole?: string | null;
    decision?: string | null;
    reason?: string | null;
  } | null;
  opsQueueBucket?: string | null;
  opsNextActionAt?: Timestamp | null;
  opsIsActionable?: boolean;
  opsLastIssueCode?: string | null;
  cancellation?: {
    reasonCode: string;
    reasonLabel?: string;
    cancelledAt?: Timestamp;
    cancelledBy?: string;
  } | null;
  createdAt?: Timestamp | null;
  updatedAt?: Timestamp | null;
};

type TripPackageBookingOperationDocument = {
  clientId: string;
  idempotencyKey: string;
  requestHash: string;
  status: "pending" | "succeeded" | "failed";
  bookingId?: string | null;
  errorCode?: string | null;
  createdAt?: Timestamp | null;
  updatedAt?: Timestamp | null;
};

type BalanceDocument = {
  balance: MoneyPayload;
  debtLimit: MoneyPayload;
};

type ParsedTripPackageBooking = {
  id: string;
  clientId: string;
  packageId: string;
  reservationId: string;
  tripId: string | null;
  assignedDriverId: string | null;
  assignedVehicleId: string | null;
  packageSnapshot: TripPackageSnapshotDocument;
  pickup: TripLocationPayload;
  destinationSnapshot: TripLocationPayload;
  scheduledAt: Date;
  transportType: TransportSnapshotPayload;
  price: MoneyPayload;
  priceAdjustmentMinor: number;
  clientCancellationClosesAt: Date;
  status: TripPackageBookingStatus;
  refundStatus: string;
  chargedAmount: MoneyPayload;
  refundedAmount: MoneyPayload;
  assignmentStatus: string;
  assignmentWindowStartsAt: Date | null;
  nextAssignmentAttemptAt: Date | null;
  lastAssignmentAttemptAt: Date | null;
  assignmentAttemptsCount: number;
  approval: {
    requestedAt: Date | null;
    decidedAt: Date | null;
    decidedByUserId: string | null;
    decidedByRole: string | null;
    decision: TripPackageApprovalDecision;
    reason: string | null;
  };
  opsQueueBucket: TripPackageOpsQueueBucket;
  opsNextActionAt: Date | null;
  opsIsActionable: boolean;
  opsLastIssueCode: TripPackageOpsIssueCode | null;
  cancellation: TripPackageBookingDocument["cancellation"];
};

type ParsedReservationDocument = {
  id: string;
  clientId: string;
  source: string;
  packageId: string | null;
  packageBookingId: string | null;
  scheduledAt: Date;
  status: string;
  pickup: TripLocationPayload;
  destination: TripLocationPayload;
  transportType: TransportSnapshotPayload;
  assignedDriverId: string | null;
  vehicleId: string | null;
  tripId: string | null;
};

type TripPackageBookingOpsMetadata = {
  opsQueueBucket: TripPackageOpsQueueBucket;
  opsNextActionAt: Date | null;
  opsIsActionable: boolean;
  opsLastIssueCode: TripPackageOpsIssueCode | null;
};

type DriverCandidate = {
  driverId: string;
  vehicleId: string;
  isAvailable: boolean;
  isBusy: boolean;
  currentTripId: string | null;
};

type BookingRequestInput = {
  packageId: string;
  pickup: TripLocationPayload;
  scheduledAt: Date;
  transportType: TransportSnapshotPayload;
  idempotencyKey: string;
};

type TripPackageFunctions = {
  saveTripPackageTemplate: ReturnType<typeof onCall>;
  archiveTripPackageTemplate: ReturnType<typeof onCall>;
  deleteTripPackageTemplate: ReturnType<typeof onCall>;
  confirmTripPackageBooking: ReturnType<typeof onCall>;
  approveTripPackageBooking: ReturnType<typeof onCall>;
  rejectTripPackageBooking: ReturnType<typeof onCall>;
  cancelTripPackageBooking: ReturnType<typeof onCall>;
  adminCancelTripPackageBooking: ReturnType<typeof onCall>;
  syncTripPackageReservationLifecycle: ReturnType<typeof onDocumentUpdated>;
  syncTripPackageTripLifecycle: ReturnType<typeof onDocumentUpdated>;
  activateDueTripPackageBookingsJob: () => Promise<void>;
};

export function buildTripPackageFunctions(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
  tripsFunctions: TripsFunctions;
}): TripPackageFunctions {
  const { firestore, messaging, tripsFunctions } = params;

  const saveTripPackageTemplate = onCall(
    CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      assertTripPackageManagerAccess({
        role: callerRole,
        authToken: request.auth?.token ?? null,
        context: "saveTripPackageTemplate",
      });

      const payload = parseTemplateWriteInput(request.data);
      const now = Timestamp.now();
      const packageId =
        payload.id ?? firestore.collection("tripPackages").doc().id;
      const packageRef = firestore.doc(`tripPackages/${packageId}`);
      const existingSnapshot = await packageRef.get();
      const existing = existingSnapshot.exists ?
        parseTemplateDocument(packageId, existingSnapshot.data()) :
        null;
      const document: TripPackageTemplateDocument = {
        name: payload.name,
        photoUrl: payload.photoUrl,
        description: payload.description,
        destination: payload.destination,
        price: payload.price,
        allowedTransportTypes: payload.allowedTransportTypes,
        isActive: payload.isActive,
        snapshotVersion: existing == null ? 1 : existing.snapshotVersion + 1,
        archivedAt: payload.archivedAt ?? existing?.archivedAt ?? null,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      };

      await packageRef.set(document, { merge: true });
      logger.info("Trip package template saved.", {
        packageId,
        snapshotVersion: document.snapshotVersion,
        isActive: document.isActive,
        allowedTransportTypes: document.allowedTransportTypes.map(
          (transportType) => transportType.id,
        ),
      });
      return { packageId };
    },
  );

  const archiveTripPackageTemplate = onCall(
    CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      assertTripPackageManagerAccess({
        role: callerRole,
        authToken: request.auth?.token ?? null,
        context: "archiveTripPackageTemplate",
      });
      const packageId = requireNonEmptyString(
        asRecord(request.data).packageId,
        "packageId",
      );
      await firestore.doc(`tripPackages/${packageId}`).set(
        {
          isActive: false,
          archivedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      logger.info("Trip package template archived.", { packageId });
      return { archived: true };
    },
  );

  const deleteTripPackageTemplate = onCall(
    CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      assertTripPackageManagerAccess({
        role: callerRole,
        authToken: request.auth?.token ?? null,
        context: "deleteTripPackageTemplate",
      });
      const packageId = requireNonEmptyString(
        asRecord(request.data).packageId,
        "packageId",
      );
      await firestore.doc(`tripPackages/${packageId}`).delete();
      logger.info("Trip package template deleted. Existing bookings kept.", {
        packageId,
      });
      return {
        cancelledDeparturesCount: 0,
        refundedBookingsCount: 0,
      };
    },
  );

  const confirmTripPackageBooking = onCall(
    CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const clientId = requireAuthenticatedUid(request.auth);
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      if (callerRole !== "client") {
        throw new HttpsError("permission-denied", "Permissões insuficientes.");
      }

      const payload = parseBookingRequest(request.data);
      const operationId = buildTripPackageBookingOperationId({
        clientId,
        idempotencyKey: payload.idempotencyKey,
      });
      const requestHash = buildTripPackageBookingRequestHash({
        packageId: payload.packageId,
        pickup: payload.pickup,
        scheduledAt: payload.scheduledAt.toISOString(),
        transportType: payload.transportType,
      });
      const operationRef = firestore.doc(
        `tripPackageBookingOperations/${operationId}`,
      );
      const reusedBookingId = await claimBookingOperation({
        operationRef,
        clientId,
        idempotencyKey: payload.idempotencyKey,
        requestHash,
      });
      if (reusedBookingId) {
        return { bookingId: reusedBookingId };
      }

      try {
        const bookingId = await confirmTripPackageBookingCore({
          firestore,
          messaging,
          clientId,
          payload,
        });
        await operationRef.set(
          {
            status: "succeeded",
            bookingId,
            errorCode: FieldValue.delete(),
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
        return { bookingId };
      } catch (error) {
        await markBookingOperationFailure({
          operationRef,
          error,
        });
        throw error;
      }
    },
  );

  const cancelTripPackageBooking = onCall(
    CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const clientId = requireAuthenticatedUid(request.auth);
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      if (callerRole !== "client") {
        throw new HttpsError("permission-denied", "Permissões insuficientes.");
      }
      const bookingId = requireNonEmptyString(
        asRecord(request.data).bookingId,
        "bookingId",
      );
      await cancelTripPackageBookingPreExecution({
        firestore,
        messaging,
        bookingId,
        expectedClientId: clientId,
        cancellationReasonCode:
          TRIP_PACKAGE_CANCELLATION_REASON_CODES.clientCancelled,
        cancellationReasonLabel: "Cancelado pelo cliente antes da execução.",
        cancelledBy: clientId,
        enforceClientCancellationWindow: true,
        terminalStatus: TRIP_PACKAGE_BOOKING_STATUSES.cancelled,
        opsIssueCode: null,
      });
      return { cancelled: true };
    },
  );

  const approveTripPackageBooking = onCall(
    CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      assertTripPackageManagerAccess({
        role: callerRole,
        authToken: request.auth?.token ?? null,
        context: "approveTripPackageBooking",
      });
      const bookingId = requireNonEmptyString(
        asRecord(request.data).bookingId,
        "bookingId",
      );
      await approveTripPackageBookingCore({
        firestore,
        messaging,
        tripsFunctions,
        bookingId,
        approvedByUserId: request.auth?.uid ?? "system",
        approvedByRole: callerRole,
      });
      return { approved: true };
    },
  );

  const rejectTripPackageBooking = onCall(
    CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      assertTripPackageManagerAccess({
        role: callerRole,
        authToken: request.auth?.token ?? null,
        context: "rejectTripPackageBooking",
      });
      const payload = asRecord(request.data);
      const bookingId = requireNonEmptyString(payload.bookingId, "bookingId");
      const reason = requireNonEmptyString(payload.reason, "reason");
      await rejectTripPackageBookingCore({
        firestore,
        messaging,
        bookingId,
        rejectedByUserId: request.auth?.uid ?? "system",
        rejectedByRole: callerRole,
        reason,
      });
      return { rejected: true };
    },
  );

  const adminCancelTripPackageBooking = onCall(
    CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      assertTripPackageManagerAccess({
        role: callerRole,
        authToken: request.auth?.token ?? null,
        context: "adminCancelTripPackageBooking",
      });
      const payload = asRecord(request.data);
      const bookingId = requireNonEmptyString(payload.bookingId, "bookingId");
      const rawReasonCode = optionalNonEmptyString(payload.reasonCode);
      const cancellationReasonCode =
        rawReasonCode ===
            TRIP_PACKAGE_CANCELLATION_REASON_CODES.packageDeleted ?
          TRIP_PACKAGE_CANCELLATION_REASON_CODES.packageDeleted :
          TRIP_PACKAGE_CANCELLATION_REASON_CODES.adminCancelled;
      await cancelTripPackageBookingPreExecution({
        firestore,
        messaging,
        bookingId,
        cancellationReasonCode,
        cancellationReasonLabel:
          optionalNonEmptyString(payload.reasonLabel) ??
          "Cancelado administrativamente antes da execução.",
        cancelledBy: request.auth?.uid ?? "system",
        enforceClientCancellationWindow: false,
        terminalStatus: TRIP_PACKAGE_BOOKING_STATUSES.cancelled,
        opsIssueCode: null,
      });
      return { cancelled: true };
    },
  );

  const syncTripPackageReservationLifecycle = onDocumentUpdated(
    {
      document: "reservations/{reservationId}",
      region: "europe-southwest1",
    },
    async (event) => {
      const afterData = event.data?.after.data();
      if (!afterData || afterData.source !== PACKAGE_SOURCE) {
        return;
      }
      const reservation = parseReservationDocument(
        event.params.reservationId,
        afterData,
      );
      if (!reservation.packageBookingId) {
        return;
      }

      const bookingRef = firestore.doc(
        `tripPackageBookings/${reservation.packageBookingId}`,
      );
      const bookingSnapshot = await bookingRef.get();
      if (!bookingSnapshot.exists) {
        logger.warn("Package reservation points to missing booking.", {
          reservationId: reservation.id,
          packageBookingId: reservation.packageBookingId,
        });
        return;
      }
      const booking = parseBookingDocument(
        reservation.packageBookingId,
        bookingSnapshot.data(),
      );

      if (reservation.tripId && booking.tripId !== reservation.tripId) {
        await bookingRef.set(
          {
            tripId: reservation.tripId,
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
      }

      if (
        reservation.assignedDriverId != null &&
        (booking.assignedDriverId !== reservation.assignedDriverId ||
            booking.assignedVehicleId !== reservation.vehicleId ||
            booking.assignmentStatus !==
                TRIP_PACKAGE_ASSIGNMENT_STATUSES.assigned)
      ) {
        const opsMetadata = buildTripPackageOpsMetadata({
          status: TRIP_PACKAGE_BOOKING_STATUSES.driverAssigned,
          scheduledAt: booking.scheduledAt,
          assignmentWindowStartsAt: booking.assignmentWindowStartsAt,
          nextAssignmentAttemptAt: buildTripPackageActivationAt(booking.scheduledAt),
          now: new Date(),
          opsLastIssueCode: null,
        });
        await bookingRef.set(
          {
            status:
              isTripPackageBookingTerminal(booking.status) ?
                booking.status :
                TRIP_PACKAGE_BOOKING_STATUSES.driverAssigned,
            assignedDriverId: reservation.assignedDriverId,
            assignedVehicleId: reservation.vehicleId,
            assignmentStatus: TRIP_PACKAGE_ASSIGNMENT_STATUSES.assigned,
            nextAssignmentAttemptAt: null,
            opsQueueBucket: opsMetadata.opsQueueBucket,
            opsNextActionAt:
              opsMetadata.opsNextActionAt == null ?
                null :
                Timestamp.fromDate(opsMetadata.opsNextActionAt),
            opsIsActionable: opsMetadata.opsIsActionable,
            opsLastIssueCode: null,
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
      }

      if (
        reservation.status === RESERVATION_STATUS_CANCELLED &&
        !isTripPackageBookingTerminal(booking.status) &&
        reservation.tripId == null
      ) {
        await cancelTripPackageBookingPreExecution({
          firestore,
          messaging,
          bookingId: booking.id,
          cancellationReasonCode:
            TRIP_PACKAGE_CANCELLATION_REASON_CODES.adminCancelled,
          cancellationReasonLabel:
            "Reserva operacional cancelada antes da execução.",
          cancelledBy: "system",
          enforceClientCancellationWindow: false,
          terminalStatus: TRIP_PACKAGE_BOOKING_STATUSES.cancelled,
          opsIssueCode: TRIP_PACKAGE_OPS_ISSUE_CODES.operationalPreExecutionFailed,
        });
      }
    },
  );

  const syncTripPackageTripLifecycle = onDocumentUpdated(
    {
      document: "trips/{tripId}",
      region: "europe-southwest1",
    },
    async (event) => {
      const beforeData = event.data?.before.data();
      const afterData = event.data?.after.data();
      if (!afterData) {
        return;
      }
      const previousTripStatus = normalizeTripStatus(beforeData?.status);
      const nextTripStatus = normalizeTripStatus(afterData.status);
      const previousBookingId =
        optionalNonEmptyString(beforeData?.packageBookingId) ?? "";
      const bookingId =
        optionalNonEmptyString(afterData.packageBookingId) ?? "";
      if (previousTripStatus === nextTripStatus && previousBookingId === bookingId) {
        logger.info("cost_profile", {
          functionName: "syncTripPackageTripLifecycle",
          operation: "trigger_skipped_diff_guard",
          tripId: event.params.tripId,
        });
        return;
      }
      if (!bookingId) {
        return;
      }
      const bookingRef = firestore.doc(`tripPackageBookings/${bookingId}`);
      const bookingSnapshot = await bookingRef.get();
      if (!bookingSnapshot.exists) {
        logger.warn("Trip package booking missing during trip sync.", {
          bookingId,
          tripId: event.params.tripId,
        });
        return;
      }
      const booking = parseBookingDocument(bookingId, bookingSnapshot.data());
      const updatePayload: Record<string, unknown> = {
        tripId: event.params.tripId,
        updatedAt: FieldValue.serverTimestamp(),
      };
      if (
        nextTripStatus === "COMPLETED" ||
        nextTripStatus === "CHARGE_APPLIED"
      ) {
        updatePayload.status = TRIP_PACKAGE_BOOKING_STATUSES.completed;
      }
      if (
        booking.status !== TRIP_PACKAGE_BOOKING_STATUSES.cancelled ||
        updatePayload.status != null ||
        booking.tripId !== event.params.tripId
      ) {
        await bookingRef.set(updatePayload, { merge: true });
      }
      if (
        nextTripStatus === "DRIVER_ACCEPTED" &&
        previousTripStatus !== "DRIVER_ACCEPTED"
      ) {
        await sendOpsNotificationBestEffort({
          firestore,
          messaging,
          type: "ops.package_booking_driver_accepted",
          title: "Motorista aceitou o package",
          body: `O package ${booking.packageSnapshot.name} já foi aceite pelo motorista.`,
          data: {
            bookingId,
            tripId: event.params.tripId,
            packageId: booking.packageId,
            type: "ops.package_booking_driver_accepted",
          },
          context: "trip_package_driver_accepted_ops",
        });
      }
      if (
        updatePayload.status === TRIP_PACKAGE_BOOKING_STATUSES.completed &&
        booking.status !== TRIP_PACKAGE_BOOKING_STATUSES.completed
      ) {
        await sendOpsNotificationBestEffort({
          firestore,
          messaging,
          type: "ops.package_booking_completed",
          title: "Package concluído",
          body: `O package ${booking.packageSnapshot.name} foi concluído.`,
          data: {
            bookingId,
            tripId: event.params.tripId,
            packageId: booking.packageId,
            type: "ops.package_booking_completed",
          },
          context: "trip_package_completed_ops",
        });
      }
    },
  );

  async function activateDueTripPackageBookingsJob(): Promise<void> {
    const now = new Date();
    const assignmentCutoff = new Date(
      now.getTime() +
        TRIP_PACKAGE_ASSIGNMENT_WINDOW_LEAD_MINUTES * 60 * 1000,
    );
    const activationCutoff = new Date(
      now.getTime() + TRIP_PACKAGE_ACTIVATION_LEAD_MINUTES * 60 * 1000,
    );
    logger.info("Scanning due trip package reservations for assignment/activation.", {
      now: now.toISOString(),
      assignmentCutoff: assignmentCutoff.toISOString(),
      activationCutoff: activationCutoff.toISOString(),
    });
    const snapshot = await firestore
      .collection("reservations")
      .where("source", "==", PACKAGE_SOURCE)
      .where("status", "==", RESERVATION_STATUS_SCHEDULED)
      .where(
        "scheduledAt",
        "<=",
        Timestamp.fromDate(assignmentCutoff),
      )
      .orderBy("scheduledAt")
      .limit(JOB_BATCH_LIMIT)
      .get();
    if (snapshot.empty) {
      logger.info("No due trip package reservations found.");
      return;
    }

    for (const reservationDoc of snapshot.docs) {
      const bookingId = optionalNonEmptyString(
        reservationDoc.data().packageBookingId,
      );
      if (!bookingId) {
        logger.warn("Skipping package reservation without packageBookingId.", {
          reservationId: reservationDoc.id,
        });
        continue;
      }
      try {
        await processTripPackageReservationJobItem({
          firestore,
          messaging,
          tripsFunctions,
          bookingId,
          reservationId: reservationDoc.id,
          now,
          activationCutoff,
        });
      } catch (error) {
        logger.error("Trip package activation job item failed.", {
          bookingId,
          reservationId: reservationDoc.id,
          error,
        });
      }
    }
  }

  return {
    saveTripPackageTemplate,
    archiveTripPackageTemplate,
    deleteTripPackageTemplate,
    confirmTripPackageBooking,
    approveTripPackageBooking,
    rejectTripPackageBooking,
    cancelTripPackageBooking,
    adminCancelTripPackageBooking,
    syncTripPackageReservationLifecycle,
    syncTripPackageTripLifecycle,
    activateDueTripPackageBookingsJob,
  };
}

async function confirmTripPackageBookingCore(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
  clientId: string;
  payload: BookingRequestInput;
}): Promise<string> {
  const { firestore, messaging, clientId, payload } = params;
  const now = new Date();
  if (!isTripPackagePurchaseAllowed({ scheduledAt: payload.scheduledAt, now })) {
    throw new HttpsError(
      "failed-precondition",
      "A compra só está disponível até 15 minutos antes da viagem.",
    );
  }

  const packageRef = firestore.doc(`tripPackages/${payload.packageId}`);
  const packageSnapshot = await packageRef.get();
  const packageDocument = parseTemplateDocument(
    payload.packageId,
    packageSnapshot.data(),
  );
  validatePackageAvailableForSale(packageDocument);
  const selectedTransportType = resolveAllowedTransportType({
    selectedTransportType: payload.transportType,
    allowedTransportTypes: packageDocument.allowedTransportTypes,
  });

  const bookingRef = firestore.collection("tripPackageBookings").doc();
  const reservationRef = firestore.collection("reservations").doc();
  const bookingId = bookingRef.id;
  const reservationId = reservationRef.id;
  const chargeLedgerRef = firestore.doc(
    `balance_adjustments/${buildTripPackageChargeLedgerId(bookingId)}`,
  );
  const balanceRef = firestore.doc(`balances/${clientId}`);
  const packageSnapshotDocument = buildPackageSnapshot({
    packageId: payload.packageId,
    packageDocument,
  });
  const clientCancellationClosesAt =
    buildTripPackageClientCancellationClosesAt(payload.scheduledAt);
  const assignmentWindowStartsAt = buildTripPackageAssignmentWindowStartsAt(
    payload.scheduledAt,
  );
  const shouldAttemptImmediateAssignment =
    assignmentWindowStartsAt.getTime() <= now.getTime();
  let immediateAssignmentProbe:
    | { driverId: string; vehicleId: string }
    | null = null;
  if (shouldAttemptImmediateAssignment) {
    logger.error("CRITICAL: package purchase entered immediate assignment path.", {
      packageId: payload.packageId,
      scheduledAt: payload.scheduledAt.toISOString(),
      reservationId,
      assignmentWindowStartsAt: assignmentWindowStartsAt.toISOString(),
    });
    immediateAssignmentProbe = await selectActivationAssignment({
      firestore,
      reservationId,
      scheduledAt: payload.scheduledAt,
      pickup: payload.pickup,
      destination: packageDocument.destination,
      transportType: selectedTransportType,
      preferredDriverId: null,
      preferredVehicleId: null,
    });
    if (immediateAssignmentProbe == null) {
      throw new HttpsError(
        "failed-precondition",
        "Não existem motoristas disponíveis para confirmar este package " +
          "com menos de 1 hora de antecedência.",
        {
          reasonCode: "no_immediate_package_assignment_available",
        },
      );
    }
  }
  const zeroAmount = buildMoneyPayload(0);

  await firestore.runTransaction(async (transaction) => {
    const [freshPackageSnapshot, balanceSnapshot] = await Promise.all([
      transaction.get(packageRef),
      transaction.get(balanceRef),
    ]);
    const freshPackage = parseTemplateDocument(
      payload.packageId,
      freshPackageSnapshot.data(),
    );
    validatePackageAvailableForSale(freshPackage);
    const freshSelectedTransportType = resolveAllowedTransportType({
      selectedTransportType: payload.transportType,
      allowedTransportTypes: freshPackage.allowedTransportTypes,
    });
    const chargedAmount = computeChargedAmount({
      basePrice: freshPackage.price,
      transportType: freshSelectedTransportType,
    });
    const priceAdjustmentMinor =
      chargedAmount.amountMinor - freshPackage.price.amountMinor;
    const balance = parseBalanceDocument(balanceSnapshot.data());
    assertMoneyCurrencyOrThrow({
      value: chargedAmount,
      expectedCurrency: balance.balance.currency,
      fieldName: "chargedAmount",
    });
    assertBalanceLimit({
      balance,
      debitAmountMinor: chargedAmount.amountMinor,
      operation: "confirm_trip_package_booking",
    });
    const approval = buildPendingApprovalPayload(now);
    const opsMetadata = buildTripPackageOpsMetadata({
      status: TRIP_PACKAGE_BOOKING_STATUSES.pendingApproval,
      scheduledAt: payload.scheduledAt,
      assignmentWindowStartsAt,
      nextAssignmentAttemptAt: null,
      now,
      opsLastIssueCode: null,
    });

    transaction.set(bookingRef, {
      clientId,
      packageId: payload.packageId,
      reservationId,
      packageSnapshot: buildPackageSnapshot({
        packageId: payload.packageId,
        packageDocument: freshPackage,
      }),
      pickup: payload.pickup,
      destinationSnapshot: freshPackage.destination,
      scheduledAt: payload.scheduledAt,
      transportType: freshSelectedTransportType,
      price: freshPackage.price,
      priceAdjustmentMinor,
      clientCancellationClosesAt,
      status: TRIP_PACKAGE_BOOKING_STATUSES.pendingApproval,
      refundStatus: TRIP_PACKAGE_REFUND_STATUSES.none,
      chargedAmount,
      refundedAmount: zeroAmount,
      assignmentStatus: TRIP_PACKAGE_ASSIGNMENT_STATUSES.pending,
      assignmentWindowStartsAt,
      nextAssignmentAttemptAt: null,
      lastAssignmentAttemptAt: null,
      assignmentAttemptsCount: 0,
      approval,
      opsQueueBucket: opsMetadata.opsQueueBucket,
      opsNextActionAt:
        opsMetadata.opsNextActionAt == null ?
          null :
          Timestamp.fromDate(opsMetadata.opsNextActionAt),
      opsIsActionable: opsMetadata.opsIsActionable,
      opsLastIssueCode: opsMetadata.opsLastIssueCode,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    } satisfies Record<string, unknown>);

    const scheduledDayKey = buildLocalDayKey(
      payload.scheduledAt,
      TRIP_PACKAGE_OPERATION_TIMEZONE,
    );
    const scheduledMinutesLocal = buildScheduledMinutesLocal(payload.scheduledAt);
    transaction.set(reservationRef, {
      source: PACKAGE_SOURCE,
      clientId,
      scheduledAt: payload.scheduledAt,
      scheduledDayKey,
      scheduledMinutesLocal,
      status: RESERVATION_STATUS_SCHEDULED,
      pickup: payload.pickup,
      destination: freshPackage.destination,
      transportType: freshSelectedTransportType,
      assignedDriverId: null,
      vehicleId: null,
      packageId: payload.packageId,
      packageBookingId: bookingId,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    } satisfies Record<string, unknown>);

    transaction.set(
      balanceRef,
      {
        balance: buildMoneyPayload(
          balance.balance.amountMinor - chargedAmount.amountMinor,
        ),
        debtLimit: balance.debtLimit,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    transaction.set(chargeLedgerRef, {
      clientId,
      adminId: "system",
      delta: buildMoneyPayload(-chargedAmount.amountMinor),
      reason: "Cobrança do package",
      tripPackageBookingId: bookingId,
      createdAt: FieldValue.serverTimestamp(),
    });
  });

  await sendClientNotificationBestEffort({
    firestore,
    messaging,
    clientId,
    type: "client.package_booking_pending_approval",
    title: "Package em aprovação",
    body: buildPendingApprovalNotificationBody({
      packageSnapshot: packageSnapshotDocument,
      scheduledAt: payload.scheduledAt,
    }),
    data: {
      bookingId,
      packageId: payload.packageId,
      type: "client.package_booking_pending_approval",
    },
    context: "trip_package_booking_pending_approval",
  });

  await sendOpsNotificationBestEffort({
    firestore,
    messaging,
    type: "ops.package_booking_pending_approval",
    title: "Package pendente de aprovação",
    body: `O package ${packageSnapshotDocument.name} aguarda aprovação operacional.`,
    data: {
      bookingId,
      packageId: payload.packageId,
      type: "ops.package_booking_pending_approval",
    },
    context: "trip_package_booking_pending_approval_ops",
  });

  logger.info("Trip package booking confirmed.", {
    bookingId,
    clientId,
    packageId: payload.packageId,
    reservationId,
    scheduledAt: payload.scheduledAt.toISOString(),
    transportTypeId: selectedTransportType.id,
    assignmentProbeAvailable: immediateAssignmentProbe != null,
    status: TRIP_PACKAGE_BOOKING_STATUSES.pendingApproval,
  });
  return bookingId;
}

async function approveTripPackageBookingCore(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
  tripsFunctions: TripsFunctions;
  bookingId: string;
  approvedByUserId: string;
  approvedByRole: RbacRole;
}): Promise<void> {
  const {
    firestore,
    messaging,
    tripsFunctions,
    bookingId,
    approvedByUserId,
    approvedByRole,
  } = params;
  const bookingRef = firestore.doc(`tripPackageBookings/${bookingId}`);
  let nextStatus: TripPackageBookingStatus | null = null;

  await firestore.runTransaction(async (transaction) => {
    const bookingSnapshot = await transaction.get(bookingRef);
    const booking = parseBookingDocument(bookingId, bookingSnapshot.data());
    if (booking.status === TRIP_PACKAGE_BOOKING_STATUSES.pendingApproval) {
      nextStatus =
        booking.assignmentWindowStartsAt != null &&
            booking.assignmentWindowStartsAt.getTime() <= Date.now() ?
          TRIP_PACKAGE_BOOKING_STATUSES.awaitingDriverAcceptance :
          TRIP_PACKAGE_BOOKING_STATUSES.approved;
      const approval = {
        requestedAt:
          booking.approval.requestedAt == null ?
            FieldValue.serverTimestamp() :
            Timestamp.fromDate(booking.approval.requestedAt),
        decidedAt: FieldValue.serverTimestamp(),
        decidedByUserId: approvedByUserId,
        decidedByRole: approvedByRole,
        decision: TRIP_PACKAGE_APPROVAL_DECISIONS.approved,
        reason: FieldValue.delete(),
      };
      const opsMetadata = buildTripPackageOpsMetadata({
        status: nextStatus,
        scheduledAt: booking.scheduledAt,
        assignmentWindowStartsAt: booking.assignmentWindowStartsAt,
        nextAssignmentAttemptAt:
          nextStatus === TRIP_PACKAGE_BOOKING_STATUSES.awaitingDriverAcceptance ?
            booking.nextAssignmentAttemptAt ?? new Date() :
            booking.assignmentWindowStartsAt,
        now: new Date(),
        opsLastIssueCode: null,
      });
      transaction.set(
        bookingRef,
        {
          status: nextStatus,
          approval,
          opsQueueBucket: opsMetadata.opsQueueBucket,
          opsNextActionAt:
            opsMetadata.opsNextActionAt == null ?
              null :
              Timestamp.fromDate(opsMetadata.opsNextActionAt),
          opsIsActionable: opsMetadata.opsIsActionable,
          opsLastIssueCode: null,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      return;
    }
    if (
      booking.status === TRIP_PACKAGE_BOOKING_STATUSES.approved ||
      booking.status === TRIP_PACKAGE_BOOKING_STATUSES.awaitingDriverAcceptance ||
      booking.status === TRIP_PACKAGE_BOOKING_STATUSES.driverAssigned ||
      booking.status === TRIP_PACKAGE_BOOKING_STATUSES.activationInProgress ||
      booking.status === TRIP_PACKAGE_BOOKING_STATUSES.completed
    ) {
      nextStatus = booking.status;
      return;
    }
    throw new HttpsError(
      "failed-precondition",
      "Este package já não pode ser aprovado.",
    );
  });

  if (nextStatus == null) {
    return;
  }
  const resolvedBookingSnapshot = await bookingRef.get();
  const resolvedBooking = parseBookingDocument(
    bookingId,
    resolvedBookingSnapshot.data(),
  );

  await sendClientNotificationBestEffort({
    firestore,
    messaging,
    clientId: resolvedBooking.clientId,
    type: "client.package_booking_approved",
    title: "Package aprovado",
    body: buildApprovedBookingNotificationBody({
      packageSnapshot: resolvedBooking.packageSnapshot,
      scheduledAt: resolvedBooking.scheduledAt,
    }),
    data: {
      bookingId,
      packageId: resolvedBooking.packageId,
      type: "client.package_booking_approved",
    },
    context: "trip_package_booking_approved",
  });

  await sendOpsNotificationBestEffort({
    firestore,
    messaging,
    type: "ops.package_booking_approved",
    title: "Package aprovado",
    body: `O package ${resolvedBooking.packageSnapshot.name} foi aprovado.`,
    data: {
      bookingId,
      packageId: resolvedBooking.packageId,
      type: "ops.package_booking_approved",
    },
    context: "trip_package_booking_approved_ops",
  });

  if (nextStatus === TRIP_PACKAGE_BOOKING_STATUSES.awaitingDriverAcceptance) {
    await sendOpsNotificationBestEffort({
      firestore,
      messaging,
      type: "ops.package_booking_awaiting_driver_acceptance",
      title: "Package entrou em operação",
      body:
        `O package ${resolvedBooking.packageSnapshot.name} ` +
        "já pode seguir para aceitação do motorista.",
      data: {
        bookingId,
        packageId: resolvedBooking.packageId,
        type: "ops.package_booking_awaiting_driver_acceptance",
      },
      context: "trip_package_booking_awaiting_driver_acceptance",
    });
    const activationCutoff = new Date(
      Date.now() + TRIP_PACKAGE_ACTIVATION_LEAD_MINUTES * 60 * 1000,
    );
    await processTripPackageReservationJobItem({
      firestore,
      messaging,
      tripsFunctions,
      bookingId,
      reservationId: resolvedBooking.reservationId,
      now: new Date(),
      activationCutoff,
    });
  }
}

async function rejectTripPackageBookingCore(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
  bookingId: string;
  rejectedByUserId: string;
  rejectedByRole: RbacRole;
  reason: string;
}): Promise<void> {
  const {
    firestore,
    messaging,
    bookingId,
    rejectedByUserId,
    rejectedByRole,
    reason,
  } = params;
  await cancelTripPackageBookingPreExecution({
    firestore,
    messaging,
    bookingId,
    cancellationReasonCode:
      TRIP_PACKAGE_CANCELLATION_REASON_CODES.adminCancelled,
    cancellationReasonLabel: reason,
    cancelledBy: rejectedByUserId,
    enforceClientCancellationWindow: false,
    terminalStatus: TRIP_PACKAGE_BOOKING_STATUSES.rejected,
    approvalDecision: TRIP_PACKAGE_APPROVAL_DECISIONS.rejected,
    approvalReason: reason,
    approvalActorRole: rejectedByRole,
    opsIssueCode: null,
  });
}

async function processTripPackageReservationJobItem(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
  tripsFunctions: TripsFunctions;
  bookingId: string;
  reservationId: string;
  now: Date;
  activationCutoff: Date;
}): Promise<void> {
  const {
    firestore,
    messaging,
    tripsFunctions,
    bookingId,
    reservationId,
    now,
    activationCutoff,
  } = params;
  const bookingSnapshot = await firestore.doc(`tripPackageBookings/${bookingId}`).get();
  if (!bookingSnapshot.exists) {
    logger.warn("Trip package job skipped: booking missing.", {
      bookingId,
      reservationId,
    });
    return;
  }
  const booking = parseBookingDocument(bookingId, bookingSnapshot.data());
  if (isTripPackageBookingTerminal(booking.status)) {
    return;
  }
  if (
    booking.status === TRIP_PACKAGE_BOOKING_STATUSES.pendingApproval ||
    booking.status === TRIP_PACKAGE_BOOKING_STATUSES.rejected
  ) {
    return;
  }
  let actionableBooking = booking;
  if (booking.status === TRIP_PACKAGE_BOOKING_STATUSES.approved) {
    if (
      booking.assignmentWindowStartsAt == null ||
      booking.assignmentWindowStartsAt.getTime() > now.getTime()
    ) {
      return;
    }
    actionableBooking = await markTripPackageBookingAwaitingDriverAcceptance({
      firestore,
      messaging,
      booking,
      context: "scheduled_job",
      notifyOps: true,
    });
  }
  if (booking.tripId) {
    return;
  }

  if (actionableBooking.tripId) {
    return;
  }

  if (actionableBooking.assignedDriverId) {
    if (actionableBooking.scheduledAt.getTime() <= activationCutoff.getTime()) {
      await activateTripPackageBooking({
        firestore,
        messaging,
        tripsFunctions,
        bookingId,
        trigger: "schedule",
      });
    }
    return;
  }

  if (actionableBooking.scheduledAt.getTime() <= now.getTime()) {
    logger.error("CRITICAL: package booking reached scheduledAt without driver assignment.", {
      bookingId,
      reservationId,
      scheduledAt: actionableBooking.scheduledAt.toISOString(),
    });
    await cancelTripPackageBookingPreExecution({
      firestore,
      messaging,
      bookingId,
      cancellationReasonCode:
        TRIP_PACKAGE_CANCELLATION_REASON_CODES.operationalPreExecutionFailed,
      cancellationReasonLabel:
        "Falha operacional antes da execução: não foi possível atribuir " +
        "um motorista até à hora marcada.",
      cancelledBy: "system",
      enforceClientCancellationWindow: false,
      terminalStatus: TRIP_PACKAGE_BOOKING_STATUSES.cancelled,
      opsIssueCode: TRIP_PACKAGE_OPS_ISSUE_CODES.activationWindowMissed,
    });
    return;
  }

  if (
    actionableBooking.assignmentWindowStartsAt == null ||
    actionableBooking.assignmentWindowStartsAt.getTime() > now.getTime()
  ) {
    return;
  }
  if (
    actionableBooking.nextAssignmentAttemptAt != null &&
    actionableBooking.nextAssignmentAttemptAt.getTime() > now.getTime()
  ) {
    return;
  }

  logger.error("CRITICAL: package booking entering assignment retry.", {
    bookingId,
    reservationId,
    scheduledAt: actionableBooking.scheduledAt.toISOString(),
    retryNumber: actionableBooking.assignmentAttemptsCount + 1,
    retryIntervalMinutes: TRIP_PACKAGE_ASSIGNMENT_RETRY_MINUTES,
  });
  await attemptTripPackageAssignment({
    firestore,
    messaging,
    booking: actionableBooking,
    now,
  });
}

async function activateTripPackageBooking(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
  tripsFunctions: TripsFunctions;
  bookingId: string;
  trigger: "immediate" | "schedule";
}): Promise<void> {
  const { firestore, messaging, tripsFunctions, bookingId, trigger } = params;
  const bookingRef = firestore.doc(`tripPackageBookings/${bookingId}`);
  const bookingSnapshot = await bookingRef.get();
  if (!bookingSnapshot.exists) {
    logger.warn("Trip package activation skipped: booking missing.", {
      bookingId,
      trigger,
    });
    return;
  }
  const booking = parseBookingDocument(bookingId, bookingSnapshot.data());
  const reservationRef = firestore.doc(`reservations/${booking.reservationId}`);
  const reservationSnapshot = await reservationRef.get();
  if (!reservationSnapshot.exists) {
    await cancelTripPackageBookingPreExecution({
      firestore,
      messaging,
      bookingId,
      cancellationReasonCode:
        TRIP_PACKAGE_CANCELLATION_REASON_CODES.operationalPreExecutionFailed,
      cancellationReasonLabel:
        "Falha operacional antes da execução: reserva operacional indisponível.",
      cancelledBy: "system",
      enforceClientCancellationWindow: false,
      terminalStatus: TRIP_PACKAGE_BOOKING_STATUSES.cancelled,
      opsIssueCode: TRIP_PACKAGE_OPS_ISSUE_CODES.activationCreationFailed,
    });
    return;
  }
  const reservation = parseReservationDocument(
    booking.reservationId,
    reservationSnapshot.data(),
  );
  if (!isTripPackageBookingActionable(booking.status)) {
    logger.info("Trip package activation skipped due to booking status.", {
      bookingId,
      bookingStatus: booking.status,
      trigger,
    });
    return;
  }
  if (reservation.tripId) {
    await bookingRef.set(
      {
        tripId: reservation.tripId,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    return;
  }
  if (reservation.status !== RESERVATION_STATUS_SCHEDULED) {
    logger.info("Trip package activation skipped due to reservation status.", {
      bookingId,
      reservationStatus: reservation.status,
      trigger,
    });
    return;
  }

  const assignment = await selectActivationAssignment({
    firestore,
    reservationId: reservation.id,
    scheduledAt: booking.scheduledAt,
    pickup: booking.pickup,
    destination: booking.destinationSnapshot,
    transportType: booking.transportType,
    preferredDriverId: reservation.assignedDriverId,
    preferredVehicleId: reservation.vehicleId,
  });
  if (assignment == null) {
    await cancelTripPackageBookingPreExecution({
      firestore,
      messaging,
      bookingId,
      cancellationReasonCode:
        TRIP_PACKAGE_CANCELLATION_REASON_CODES.operationalPreExecutionFailed,
      cancellationReasonLabel:
        "Falha operacional antes da execução: sem motorista ou viatura disponível.",
      cancelledBy: "system",
      enforceClientCancellationWindow: false,
      terminalStatus: TRIP_PACKAGE_BOOKING_STATUSES.cancelled,
      opsIssueCode: TRIP_PACKAGE_OPS_ISSUE_CODES.activationCreationFailed,
    });
    return;
  }

  const activationOpsMetadata = buildTripPackageOpsMetadata({
    status: TRIP_PACKAGE_BOOKING_STATUSES.activationInProgress,
    scheduledAt: booking.scheduledAt,
    assignmentWindowStartsAt: booking.assignmentWindowStartsAt,
    nextAssignmentAttemptAt: buildTripPackageActivationAt(booking.scheduledAt),
    now: new Date(),
    opsLastIssueCode: null,
  });
  await bookingRef.set(
    {
      status: TRIP_PACKAGE_BOOKING_STATUSES.activationInProgress,
      assignedDriverId: assignment.driverId,
      assignedVehicleId: assignment.vehicleId,
      assignmentStatus: TRIP_PACKAGE_ASSIGNMENT_STATUSES.assigned,
      opsQueueBucket: activationOpsMetadata.opsQueueBucket,
      opsNextActionAt:
        activationOpsMetadata.opsNextActionAt == null ?
          null :
          Timestamp.fromDate(activationOpsMetadata.opsNextActionAt),
      opsIsActionable: activationOpsMetadata.opsIsActionable,
      opsLastIssueCode: null,
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  const tripId = await tripsFunctions.createPackageCoveredTripFromReservation({
    reservationId: reservation.id,
    clientId: booking.clientId,
    pickup: booking.pickup,
    destination: booking.destinationSnapshot,
    transportType: booking.transportType,
    scheduledAt: booking.scheduledAt,
    assignedDriverId: assignment.driverId,
    vehicleId: assignment.vehicleId,
    bookingId,
    packageId: booking.packageId,
    packageSnapshotVersion: booking.packageSnapshot.snapshotVersion,
  });
  if (!tripId) {
    const refreshedReservationSnapshot = await reservationRef.get();
    const refreshedTripId = optionalNonEmptyString(
      refreshedReservationSnapshot.data()?.tripId,
    );
    if (refreshedTripId) {
      await bookingRef.set(
        {
          tripId: refreshedTripId,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      return;
    }
    await cancelTripPackageBookingPreExecution({
      firestore,
      messaging,
      bookingId,
      cancellationReasonCode:
        TRIP_PACKAGE_CANCELLATION_REASON_CODES.operationalPreExecutionFailed,
      cancellationReasonLabel:
        "Falha operacional antes da execução: não foi possível criar a viagem.",
      cancelledBy: "system",
      enforceClientCancellationWindow: false,
      terminalStatus: TRIP_PACKAGE_BOOKING_STATUSES.cancelled,
      opsIssueCode: TRIP_PACKAGE_OPS_ISSUE_CODES.activationCreationFailed,
    });
    return;
  }

  await Promise.all([
    reservationRef.set(
      {
        assignedDriverId: assignment.driverId,
        vehicleId: assignment.vehicleId,
        tripId,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    ),
    bookingRef.set(
      {
        tripId,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    ),
  ]);

  await sendClientNotificationBestEffort({
    firestore,
    messaging,
    clientId: booking.clientId,
    type: "client.package_operational_update",
    title: "Viagem operacional preparada",
    body: "O package já tem ativação operacional em curso.",
    data: {
      bookingId,
      tripId,
      type: "client.package_operational_update",
    },
    context: "trip_package_operational_update",
  });

  await sendDriverNotificationBestEffort({
    firestore,
    messaging,
    driverId: assignment.driverId,
    bookingId,
    scheduledAt: booking.scheduledAt,
    pickupAddress: booking.pickup.address,
    destinationAddress: booking.destinationSnapshot.address,
    type: "driver.package_booking_acceptance_requested",
    title: "Aceitação do package necessária",
    body:
      `A viagem do package para ${booking.destinationSnapshot.address} ` +
      "está pronta para aceitação.",
    context: "trip_package_driver_acceptance_requested",
    extraData: { tripId },
  });

  await sendOpsNotificationBestEffort({
    firestore,
    messaging,
    type: "ops.package_booking_activation_started",
    title: "Ativação operacional iniciada",
    body: `O package ${booking.packageSnapshot.name} entrou em ativação operacional.`,
    data: {
      bookingId,
      tripId,
      packageId: booking.packageId,
      type: "ops.package_booking_activation_started",
    },
    context: "trip_package_activation_started_ops",
  });

  logger.info("Trip package activation completed.", {
    bookingId,
    tripId,
    assignedDriverId: assignment.driverId,
    vehicleId: assignment.vehicleId,
    trigger,
  });
}

async function attemptTripPackageAssignment(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
  booking: ParsedTripPackageBooking;
  now: Date;
}): Promise<void> {
  const { firestore, messaging, booking, now } = params;
  const assignment = await selectActivationAssignment({
    firestore,
    reservationId: booking.reservationId,
    scheduledAt: booking.scheduledAt,
    pickup: booking.pickup,
    destination: booking.destinationSnapshot,
    transportType: booking.transportType,
    preferredDriverId: null,
    preferredVehicleId: null,
  });

  const bookingRef = firestore.doc(`tripPackageBookings/${booking.id}`);
  const reservationRef = firestore.doc(`reservations/${booking.reservationId}`);
  const nextAttemptsCount = booking.assignmentAttemptsCount + 1;
  const activationAt = buildTripPackageActivationAt(booking.scheduledAt);
  if (assignment == null) {
    const nextAttemptAt = buildNextTripPackageAssignmentAttemptAt(now);
    const opsMetadata = buildTripPackageOpsMetadata({
      status: TRIP_PACKAGE_BOOKING_STATUSES.awaitingDriverAcceptance,
      scheduledAt: booking.scheduledAt,
      assignmentWindowStartsAt: booking.assignmentWindowStartsAt,
      nextAssignmentAttemptAt: nextAttemptAt,
      now,
      opsLastIssueCode: TRIP_PACKAGE_OPS_ISSUE_CODES.noEligibleDriversFound,
    });
    await bookingRef.set(
      {
        status: TRIP_PACKAGE_BOOKING_STATUSES.awaitingDriverAcceptance,
        assignmentStatus: TRIP_PACKAGE_ASSIGNMENT_STATUSES.pending,
        lastAssignmentAttemptAt: now,
        nextAssignmentAttemptAt: nextAttemptAt,
        assignmentAttemptsCount: nextAttemptsCount,
        opsQueueBucket: opsMetadata.opsQueueBucket,
        opsNextActionAt: Timestamp.fromDate(nextAttemptAt),
        opsIsActionable: opsMetadata.opsIsActionable,
        opsLastIssueCode: TRIP_PACKAGE_OPS_ISSUE_CODES.noEligibleDriversFound,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    logger.error("CRITICAL: package assignment retry did not find a candidate.", {
      bookingId: booking.id,
      reservationId: booking.reservationId,
      nextAssignmentAttemptAt: nextAttemptAt.toISOString(),
      assignmentAttemptsCount: nextAttemptsCount,
    });
    if (booking.opsLastIssueCode !== TRIP_PACKAGE_OPS_ISSUE_CODES.noEligibleDriversFound) {
      await sendOpsNotificationBestEffort({
        firestore,
        messaging,
        type: "ops.package_booking_driver_acceptance_failed",
        title: "Sem motoristas elegíveis",
        body:
          `O package ${booking.packageSnapshot.name} ainda não encontrou ` +
          "motoristas elegíveis.",
        data: {
          bookingId: booking.id,
          packageId: booking.packageId,
          issueCode: TRIP_PACKAGE_OPS_ISSUE_CODES.noEligibleDriversFound,
          type: "ops.package_booking_driver_acceptance_failed",
        },
        context: "trip_package_driver_acceptance_failed_no_eligible",
      });
    }
    return;
  }

  const opsMetadata = buildTripPackageOpsMetadata({
    status: TRIP_PACKAGE_BOOKING_STATUSES.driverAssigned,
    scheduledAt: booking.scheduledAt,
    assignmentWindowStartsAt: booking.assignmentWindowStartsAt,
    nextAssignmentAttemptAt: activationAt,
    now,
    opsLastIssueCode: null,
  });
  await Promise.all([
    reservationRef.set(
      {
        assignedDriverId: assignment.driverId,
        vehicleId: assignment.vehicleId,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    ),
    bookingRef.set(
      {
        status: TRIP_PACKAGE_BOOKING_STATUSES.driverAssigned,
        assignedDriverId: assignment.driverId,
        assignedVehicleId: assignment.vehicleId,
        assignmentStatus: TRIP_PACKAGE_ASSIGNMENT_STATUSES.assigned,
        lastAssignmentAttemptAt: now,
        nextAssignmentAttemptAt: null,
        assignmentAttemptsCount: nextAttemptsCount,
        opsQueueBucket: opsMetadata.opsQueueBucket,
        opsNextActionAt: Timestamp.fromDate(activationAt),
        opsIsActionable: opsMetadata.opsIsActionable,
        opsLastIssueCode: null,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    ),
  ]);

  logger.error("CRITICAL: package assignment completed.", {
    bookingId: booking.id,
    reservationId: booking.reservationId,
    assignedDriverId: assignment.driverId,
    vehicleId: assignment.vehicleId,
    assignmentAttemptsCount: nextAttemptsCount,
  });
  await sendDriverNotificationBestEffort({
    firestore,
    messaging,
    driverId: assignment.driverId,
    bookingId: booking.id,
    scheduledAt: booking.scheduledAt,
    pickupAddress: booking.pickup.address,
    destinationAddress: booking.destinationSnapshot.address,
    type: "driver.package_booking_assigned",
    title: "Nova reserva de package atribuída",
    body:
      `Recolha em ${booking.pickup.address} com destino ` +
      `${booking.destinationSnapshot.address}.`,
    context: "trip_package_driver_assignment",
    extraData: {
      packageId: booking.packageId,
    },
  });

  await sendOpsNotificationBestEffort({
    firestore,
    messaging,
    type: "ops.package_booking_driver_assigned",
    title: "Motorista atribuído",
    body: `O package ${booking.packageSnapshot.name} já tem motorista atribuído.`,
    data: {
      bookingId: booking.id,
      packageId: booking.packageId,
      driverId: assignment.driverId,
      type: "ops.package_booking_driver_assigned",
    },
    context: "trip_package_driver_assigned_ops",
  });
}

async function cancelTripPackageBookingPreExecution(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
  bookingId: string;
  cancellationReasonCode: string;
  cancellationReasonLabel: string;
  cancelledBy: string;
  expectedClientId?: string;
  enforceClientCancellationWindow: boolean;
  terminalStatus: TripPackageBookingStatus;
  approvalDecision?: TripPackageApprovalDecision;
  approvalReason?: string;
  approvalActorRole?: RbacRole;
  opsIssueCode?: TripPackageOpsIssueCode | null;
}): Promise<void> {
  const {
    firestore,
    messaging,
    bookingId,
    cancellationReasonCode,
    cancellationReasonLabel,
    cancelledBy,
    expectedClientId,
    enforceClientCancellationWindow,
    terminalStatus,
    approvalDecision,
    approvalReason,
    approvalActorRole,
    opsIssueCode,
  } = params;
  const bookingRef = firestore.doc(`tripPackageBookings/${bookingId}`);

  let bookingForNotification:
    | ParsedTripPackageBooking
    | null = null;
  let isOperationalFailureRefund = false;

  await firestore.runTransaction(async (transaction) => {
    const bookingSnapshot = await transaction.get(bookingRef);
    const booking = parseBookingDocument(bookingId, bookingSnapshot.data());
    if (expectedClientId && booking.clientId !== expectedClientId) {
      throw new HttpsError("permission-denied", "Permissões insuficientes.");
    }
    if (isTripPackageBookingTerminal(booking.status)) {
      bookingForNotification = booking;
      isOperationalFailureRefund =
        booking.cancellation?.reasonCode ===
        TRIP_PACKAGE_CANCELLATION_REASON_CODES.operationalPreExecutionFailed;
      return;
    }
    if (
      enforceClientCancellationWindow &&
      !canClientCancelTripPackageBooking({
        clientCancellationClosesAt: booking.clientCancellationClosesAt,
        now: new Date(),
      })
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Já não é possível cancelar este package.",
      );
    }
    const reservationRef = firestore.doc(`reservations/${booking.reservationId}`);
    const refundLedgerRef = firestore.doc(
      `balance_adjustments/${buildTripPackageRefundLedgerId(bookingId)}`,
    );
    const balanceRef = firestore.doc(`balances/${booking.clientId}`);
    const [reservationSnapshot, refundLedgerSnapshot, balanceSnapshot] =
      await Promise.all([
        transaction.get(reservationRef),
        transaction.get(refundLedgerRef),
        transaction.get(balanceRef),
      ]);
    const reservation = reservationSnapshot.exists ?
      parseReservationDocument(booking.reservationId, reservationSnapshot.data()) :
      null;
    if (reservation?.tripId || booking.tripId) {
      throw new HttpsError(
        "failed-precondition",
        "A execução operacional já foi iniciada.",
      );
    }
    if (
      reservation != null &&
      reservation.status !== RESERVATION_STATUS_SCHEDULED &&
      reservation.status !== RESERVATION_STATUS_CANCELLED
    ) {
      throw new HttpsError(
        "failed-precondition",
        "A reserva já não está num estado cancelável.",
      );
    }
    const balance = parseBalanceDocument(balanceSnapshot.data());
    assertMoneyCurrencyOrThrow({
      value: booking.chargedAmount,
      expectedCurrency: balance.balance.currency,
      fieldName: "chargedAmount",
    });
    if (!refundLedgerSnapshot.exists) {
      transaction.set(
        balanceRef,
        {
          balance: buildMoneyPayload(
            balance.balance.amountMinor + booking.chargedAmount.amountMinor,
          ),
          debtLimit: balance.debtLimit,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      transaction.set(refundLedgerRef, {
        clientId: booking.clientId,
        adminId: "system",
        delta: buildMoneyPayload(booking.chargedAmount.amountMinor),
        reason: "Reembolso total do package",
        tripPackageBookingId: booking.id,
        createdAt: FieldValue.serverTimestamp(),
      });
    }

    const nextApprovalDecision =
      approvalDecision ??
      booking.approval.decision;
    const nextApproval = {
      requestedAt:
        booking.approval.requestedAt == null ?
          FieldValue.serverTimestamp() :
          Timestamp.fromDate(booking.approval.requestedAt),
      decidedAt:
        approvalDecision == null ?
          (booking.approval.decidedAt == null ?
            FieldValue.delete() :
            Timestamp.fromDate(booking.approval.decidedAt)) :
          FieldValue.serverTimestamp(),
      decidedByUserId:
        approvalDecision == null ?
          (booking.approval.decidedByUserId == null ?
            FieldValue.delete() :
            booking.approval.decidedByUserId) :
          cancelledBy,
      decidedByRole:
        approvalDecision == null ?
          (booking.approval.decidedByRole == null ?
            FieldValue.delete() :
            booking.approval.decidedByRole) :
          (approvalActorRole ?? "admin"),
      decision: nextApprovalDecision,
      reason:
        approvalReason == null ?
          (booking.approval.reason == null ?
            FieldValue.delete() :
            booking.approval.reason) :
          approvalReason,
    };
    const opsMetadata = buildTripPackageOpsMetadata({
      status: terminalStatus,
      scheduledAt: booking.scheduledAt,
      assignmentWindowStartsAt: booking.assignmentWindowStartsAt,
      nextAssignmentAttemptAt: null,
      now: new Date(),
      opsLastIssueCode: opsIssueCode ?? null,
    });
    transaction.set(
      bookingRef,
      {
        status: terminalStatus,
        refundStatus: TRIP_PACKAGE_REFUND_STATUSES.full,
        refundedAmount: booking.chargedAmount,
        assignmentStatus:
          cancellationReasonCode ===
              TRIP_PACKAGE_CANCELLATION_REASON_CODES
                .operationalPreExecutionFailed ?
            TRIP_PACKAGE_ASSIGNMENT_STATUSES.failed :
            booking.assignmentStatus,
        nextAssignmentAttemptAt: null,
        approval: nextApproval,
        opsQueueBucket: opsMetadata.opsQueueBucket,
        opsNextActionAt:
          opsMetadata.opsNextActionAt == null ?
            null :
            Timestamp.fromDate(opsMetadata.opsNextActionAt),
        opsIsActionable: opsMetadata.opsIsActionable,
        opsLastIssueCode: opsIssueCode ?? null,
        cancellation: {
          reasonCode: cancellationReasonCode,
          reasonLabel: cancellationReasonLabel,
          cancelledAt: FieldValue.serverTimestamp(),
          cancelledBy,
        },
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    if (reservation != null) {
      transaction.set(
        reservationRef,
        {
          status: RESERVATION_STATUS_CANCELLED,
          failedAt:
            cancellationReasonCode ===
                TRIP_PACKAGE_CANCELLATION_REASON_CODES
                  .operationalPreExecutionFailed ?
              FieldValue.serverTimestamp() :
              FieldValue.delete(),
          failureReason: cancellationReasonLabel,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }
    bookingForNotification = {
      ...booking,
      status: terminalStatus,
      refundStatus: TRIP_PACKAGE_REFUND_STATUSES.full,
      refundedAmount: booking.chargedAmount,
      approval: {
        ...booking.approval,
        decidedAt:
          approvalDecision == null ? booking.approval.decidedAt : new Date(),
        decidedByUserId:
          approvalDecision == null ?
            booking.approval.decidedByUserId :
            cancelledBy,
        decidedByRole:
          approvalDecision == null ?
            booking.approval.decidedByRole :
            (approvalActorRole ?? "admin"),
        decision: nextApprovalDecision,
        reason: approvalReason ?? booking.approval.reason,
      },
      opsQueueBucket: opsMetadata.opsQueueBucket,
      opsNextActionAt: opsMetadata.opsNextActionAt,
      opsIsActionable: opsMetadata.opsIsActionable,
      opsLastIssueCode: opsIssueCode ?? null,
      cancellation: {
        reasonCode: cancellationReasonCode,
        reasonLabel: cancellationReasonLabel,
      },
    };
    isOperationalFailureRefund =
      cancellationReasonCode ===
      TRIP_PACKAGE_CANCELLATION_REASON_CODES.operationalPreExecutionFailed;
  });

  if (bookingForNotification == null) {
    return;
  }
  const notificationBooking: ParsedTripPackageBooking = bookingForNotification;

  if (isOperationalFailureRefund) {
    await sendClientNotificationBestEffort({
      firestore,
      messaging,
      clientId: notificationBooking.clientId,
      type: "client.package_booking_refunded_pre_execution_failure",
      title: "Package cancelado com reembolso",
      body:
        notificationBooking.cancellation?.reasonLabel ??
        "O package foi cancelado antes da execução e o valor foi reembolsado.",
      data: {
        bookingId,
        type: "client.package_booking_refunded_pre_execution_failure",
      },
      context: "trip_package_refunded_pre_execution_failure",
    });
    await sendOpsNotificationBestEffort({
      firestore,
      messaging,
      type: "ops.package_booking_refunded_pre_execution_failure",
      title: "Package reembolsado por falha operacional",
      body:
        notificationBooking.cancellation?.reasonLabel ??
        "O package foi reembolsado por falha operacional antes da execução.",
      data: {
        bookingId,
        packageId: notificationBooking.packageId,
        issueCode: notificationBooking.opsLastIssueCode ?? "",
        type: "ops.package_booking_refunded_pre_execution_failure",
      },
      context: "trip_package_refunded_pre_execution_failure_ops",
    });
    if (
      notificationBooking.opsLastIssueCode ===
        TRIP_PACKAGE_OPS_ISSUE_CODES.activationCreationFailed ||
      notificationBooking.opsLastIssueCode ===
        TRIP_PACKAGE_OPS_ISSUE_CODES.activationWindowMissed
    ) {
      await sendOpsNotificationBestEffort({
        firestore,
        messaging,
        type: "ops.package_booking_activation_failed",
        title: "Falha na ativação operacional",
        body:
          notificationBooking.cancellation?.reasonLabel ??
          "O package falhou durante a ativação operacional.",
        data: {
          bookingId,
          packageId: notificationBooking.packageId,
          issueCode: notificationBooking.opsLastIssueCode ?? "",
          type: "ops.package_booking_activation_failed",
        },
        context: "trip_package_activation_failed_ops",
      });
    }
    return;
  }

  await sendClientNotificationBestEffort({
    firestore,
    messaging,
    clientId: notificationBooking.clientId,
    type: "client.package_booking_cancelled",
    title: "Package cancelado",
    body:
      notificationBooking.cancellation?.reasonLabel ??
      "O package foi cancelado.",
    data: {
      bookingId,
      type: "client.package_booking_cancelled",
    },
    context: "trip_package_booking_cancelled",
  });

  await sendOpsNotificationBestEffort({
    firestore,
    messaging,
    type:
      notificationBooking.status === TRIP_PACKAGE_BOOKING_STATUSES.rejected ?
        "ops.package_booking_rejected" :
        "ops.package_booking_cancelled",
    title:
      notificationBooking.status === TRIP_PACKAGE_BOOKING_STATUSES.rejected ?
        "Package rejeitado" :
        "Package cancelado",
    body:
      notificationBooking.cancellation?.reasonLabel ??
      "O package foi encerrado antes da execução.",
    data: {
      bookingId,
      packageId: notificationBooking.packageId,
      type:
        notificationBooking.status === TRIP_PACKAGE_BOOKING_STATUSES.rejected ?
          "ops.package_booking_rejected" :
          "ops.package_booking_cancelled",
    },
    context:
      notificationBooking.status === TRIP_PACKAGE_BOOKING_STATUSES.rejected ?
        "trip_package_booking_rejected_ops" :
        "trip_package_booking_cancelled_ops",
  });
}

async function selectActivationAssignment(params: {
  firestore: admin.firestore.Firestore;
  reservationId: string;
  scheduledAt: Date;
  pickup: TripLocationPayload;
  destination: TripLocationPayload;
  transportType: TransportSnapshotPayload;
  preferredDriverId: string | null;
  preferredVehicleId: string | null;
}): Promise<{ driverId: string; vehicleId: string } | null> {
  const {
    firestore,
    reservationId,
    scheduledAt,
    pickup,
    destination,
    transportType,
    preferredDriverId,
    preferredVehicleId,
  } = params;
  const snapshot = await firestore
    .collection(DRIVER_STATUS_COLLECTION)
    .where("isActive", "==", true)
    .where("availabilityEnabled", "==", true)
    .where("isAvailable", "==", true)
    .get();
  if (snapshot.empty) {
    return null;
  }
  const vehicleCache = new Map<string, VehicleSnapshot | null>();
  const window = buildReservationWindow({ start: scheduledAt, pickup, destination });
  const candidates = snapshot.docs
    .map((doc) => parseDriverCandidate(doc.id, doc.data()))
    .filter((candidate): candidate is DriverCandidate => candidate != null)
    .sort((left, right) => left.driverId.localeCompare(right.driverId));

  if (preferredDriverId && preferredVehicleId) {
    const preferredCandidate = candidates.find(
      (candidate) =>
        candidate.driverId === preferredDriverId &&
        candidate.vehicleId === preferredVehicleId,
    );
    if (
      preferredCandidate &&
      await isCandidateUsableForActivation({
        firestore,
        candidate: preferredCandidate,
        transportType,
        window,
        reservationId,
        vehicleCache,
      })
    ) {
      return {
        driverId: preferredCandidate.driverId,
        vehicleId: preferredCandidate.vehicleId,
      };
    }
  }

  for (const candidate of candidates) {
    if (
      await isCandidateUsableForActivation({
        firestore,
        candidate,
        transportType,
        window,
        reservationId,
        vehicleCache,
      })
    ) {
      return {
        driverId: candidate.driverId,
        vehicleId: candidate.vehicleId,
      };
    }
  }
  return null;
}

async function isCandidateUsableForActivation(params: {
  firestore: admin.firestore.Firestore;
  candidate: DriverCandidate;
  transportType: TransportSnapshotPayload;
  window: ReservationWindow;
  reservationId: string;
  vehicleCache: Map<string, VehicleSnapshot | null>;
}): Promise<boolean> {
  const { firestore, candidate, transportType, window, reservationId, vehicleCache } =
    params;
  if (candidate.isBusy) {
    return false;
  }
  const compatibleVehicle = await resolveCompatibleVehicle({
    firestore,
    vehicleId: candidate.vehicleId,
    expectedTransportTypeId: transportType.id,
    cache: vehicleCache,
  });
  if (!compatibleVehicle) {
    return false;
  }
  if (await hasCurrentTripConflict({ firestore, candidate })) {
    return false;
  }
  if (
    await hasAssignedOperationalConflict({
      firestore,
      candidate,
      window,
      excludeReservationId: reservationId,
    })
  ) {
    return false;
  }
  return true;
}

async function hasAssignedOperationalConflict(params: {
  firestore: admin.firestore.Firestore;
  candidate: DriverCandidate;
  window: ReservationWindow;
  excludeReservationId?: string;
}): Promise<boolean> {
  const { firestore, candidate, window, excludeReservationId } = params;
  const scheduledDayKey = buildLocalDayKey(
    window.start,
    TRIP_PACKAGE_OPERATION_TIMEZONE,
  );
  const snapshots = await Promise.all([
    firestore
      .collection("reservations")
      .where("assignedDriverId", "==", candidate.driverId)
      .where("status", "in", [...ACTIVE_RESERVATION_STATUSES])
      .where("scheduledDayKey", "==", scheduledDayKey)
      .get(),
    firestore
      .collection("reservations")
      .where("vehicleId", "==", candidate.vehicleId)
      .where("status", "in", [...ACTIVE_RESERVATION_STATUSES])
      .where("scheduledDayKey", "==", scheduledDayKey)
      .get(),
  ]);
  const seenIds = new Set<string>();
  for (const snapshot of snapshots) {
    for (const doc of snapshot.docs) {
      if (doc.id === excludeReservationId || seenIds.has(doc.id)) {
        continue;
      }
      seenIds.add(doc.id);
      const reservation = parseReservationDocument(doc.id, doc.data());
      const reservationWindow = buildReservationWindow({
        start: reservation.scheduledAt,
        pickup: reservation.pickup,
        destination: reservation.destination,
      });
      if (windowsOverlap(window, reservationWindow)) {
        return true;
      }
    }
  }
  return false;
}

async function hasCurrentTripConflict(params: {
  firestore: admin.firestore.Firestore;
  candidate: DriverCandidate;
}): Promise<boolean> {
  const { firestore, candidate } = params;
  if (!candidate.currentTripId) {
    return candidate.isBusy;
  }
  const tripSnapshot = await firestore.doc(`trips/${candidate.currentTripId}`).get();
  const tripStatus = normalizeTripStatus(tripSnapshot.data()?.status);
  if (tripStatus == null) {
    return candidate.isBusy;
  }
  return !INACTIVE_TRIP_STATUSES.has(tripStatus);
}

async function resolveCompatibleVehicle(params: {
  firestore: admin.firestore.Firestore;
  vehicleId: string;
  expectedTransportTypeId: string;
  cache: Map<string, VehicleSnapshot | null>;
}): Promise<VehicleSnapshot | null> {
  const { firestore, vehicleId, expectedTransportTypeId, cache } = params;
  if (cache.has(vehicleId)) {
    const cached = cache.get(vehicleId);
    return cached?.defaultTransportType?.id === expectedTransportTypeId ?
      cached :
      null;
  }
  const snapshot = await firestore.doc(`vehicles/${vehicleId}`).get();
  if (!snapshot.exists) {
    cache.set(vehicleId, null);
    return null;
  }
  const data = snapshot.data() ?? {};
  const vehicle: VehicleSnapshot = {
    id: vehicleId,
    isActive: data.isActive !== false,
    defaultTransportType: parseOptionalTransportSnapshot(
      data.defaultTransportType,
    ),
  };
  cache.set(vehicleId, vehicle);
  if (!vehicle.isActive) {
    return null;
  }
  return vehicle.defaultTransportType?.id === expectedTransportTypeId ?
    vehicle :
    null;
}

async function claimBookingOperation(params: {
  operationRef: admin.firestore.DocumentReference;
  clientId: string;
  idempotencyKey: string;
  requestHash: string;
}): Promise<string | null> {
  const { operationRef, clientId, idempotencyKey, requestHash } = params;
  return operationRef.firestore.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(operationRef);
    if (!snapshot.exists) {
      const document: TripPackageBookingOperationDocument = {
        clientId,
        idempotencyKey,
        requestHash,
        status: "pending",
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      };
      transaction.set(operationRef, document);
      return null;
    }
    const operation = parseBookingOperationDocument(snapshot.data());
    if (operation.clientId !== clientId) {
      throw new HttpsError("permission-denied", "Permissões insuficientes.");
    }
    if (operation.requestHash !== requestHash) {
      throw new HttpsError(
        "invalid-argument",
        "A chave de idempotência já foi usada com outro pedido.",
      );
    }
    if (operation.status === "succeeded" && operation.bookingId) {
      return operation.bookingId;
    }
    if (operation.status === "pending") {
      throw new HttpsError(
        "aborted",
        "O pedido já está a ser processado.",
      );
    }
    throw new HttpsError(
      "failed-precondition",
      "O pedido anterior falhou. Use uma nova chave de idempotência.",
      {
        errorCode: operation.errorCode ?? null,
      },
    );
  });
}

async function markBookingOperationFailure(params: {
  operationRef: admin.firestore.DocumentReference;
  error: unknown;
}): Promise<void> {
  const errorCode = resolveHttpsErrorCode(params.error);
  try {
    await params.operationRef.set(
      {
        status: "failed",
        errorCode,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  } catch (writeError) {
    logger.error("Failed to mark trip package booking operation failure.", {
      operationId: params.operationRef.id,
      errorCode,
      writeError,
    });
  }
}

async function sendClientNotificationBestEffort(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
  clientId: string;
  type: string;
  title: string;
  body: string;
  data: Record<string, string>;
  context: string;
}): Promise<void> {
  const { firestore, messaging, clientId, type, title, body, data, context } =
    params;
  try {
    const tokens = await fetchUserNotificationTokens({
      firestore,
      userId: clientId,
    });
    if (tokens.length === 0) {
      logger.info("Trip package notification skipped: no client tokens.", {
        clientId,
        context,
      });
      return;
    }
    await dispatchNotificationToTargets({
      firestore,
      messaging,
      targets: [
        {
          userId: clientId,
          tokens,
        },
      ],
      message: {
        notification: {
          title,
          body,
        },
        data: {
          ...data,
          type,
        },
      },
      context,
    });
  } catch (error) {
    logger.error("Trip package notification failed but was ignored.", {
      clientId,
      context,
      error,
    });
  }
}

async function sendDriverNotificationBestEffort(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
  driverId: string;
  bookingId: string;
  scheduledAt: Date;
  pickupAddress: string;
  destinationAddress: string;
  type: string;
  title: string;
  body: string;
  context: string;
  extraData?: Record<string, string>;
}): Promise<void> {
  const {
    firestore,
    messaging,
    driverId,
    bookingId,
    scheduledAt,
    pickupAddress,
    destinationAddress,
    type,
    title,
    body,
    context,
    extraData,
  } = params;
  try {
    const tokens = await fetchUserNotificationTokens({
      firestore,
      userId: driverId,
    });
    if (tokens.length === 0) {
      logger.info("Trip package driver notification skipped: no driver tokens.", {
        driverId,
        bookingId,
      });
      return;
    }
    await dispatchNotificationToTargets({
      firestore,
      messaging,
      targets: [
        {
          userId: driverId,
          tokens,
        },
      ],
      message: {
        notification: {
          title,
          body,
        },
        data: {
          bookingId,
          scheduledAt: scheduledAt.toISOString(),
          pickupAddress,
          destinationAddress,
          type,
          ...(extraData ?? {}),
        },
      },
      context,
    });
  } catch (error) {
    logger.error("Trip package driver notification failed but was ignored.", {
      driverId,
      bookingId,
      error,
    });
  }
}

async function sendOpsNotificationBestEffort(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
  type: string;
  title: string;
  body: string;
  data: Record<string, string>;
  context: string;
}): Promise<void> {
  const { firestore, messaging, type, title, body, data, context } = params;
  try {
    const targets = await fetchTripPackageOpsTargets({ firestore });
    if (targets.length === 0) {
      logger.info("Trip package ops notification skipped: no staff targets.", {
        context,
      });
      return;
    }
    await dispatchNotificationToTargets({
      firestore,
      messaging,
      targets,
      message: {
        notification: {
          title,
          body,
        },
        data: {
          ...data,
          type,
        },
      },
      context,
    });
  } catch (error) {
    logger.error("Trip package ops notification failed but was ignored.", {
      context,
      error,
    });
  }
}

async function fetchUserNotificationTokens(params: {
  firestore: admin.firestore.Firestore;
  userId: string;
}): Promise<string[]> {
  const snapshot = await params.firestore
    .collection(`users/${params.userId}/fcmTokens`)
    .where("enabled", "==", true)
    .get();
  if (snapshot.empty) {
    return [];
  }
  return Array.from(
    new Set(
      snapshot.docs
        .map((doc) => doc.data().token)
        .filter((value): value is string => typeof value === "string")
        .map((value) => value.trim())
        .filter((value) => value.length > 0),
    ),
  );
}

async function fetchTripPackageOpsTargets(params: {
  firestore: admin.firestore.Firestore;
}) {
  const baseTargets = await fetchNotificationTargetsByRoles({
    firestore: params.firestore,
    roles: ["admin", "manager"],
  });
  if (baseTargets.length === 0) {
    return [];
  }
  const snapshots = await Promise.all(
    baseTargets.map((target) => params.firestore.doc(`users/${target.userId}`).get()),
  );
  return baseTargets.filter((target, index) => {
    const data = snapshots[index].data() ?? {};
    const role = typeof data.role === "string" ? data.role.trim().toLowerCase() : "";
    if (role === "admin") {
      return true;
    }
    const managerPermissions = data.managerPermissions;
    if (!managerPermissions || typeof managerPermissions !== "object") {
      return false;
    }
    return (managerPermissions as Record<string, unknown>).tp === true;
  });
}

function buildPendingApprovalPayload(now: Date) {
  return {
    requestedAt: Timestamp.fromDate(now),
    decidedAt: null,
    decidedByUserId: null,
    decidedByRole: null,
    decision: TRIP_PACKAGE_APPROVAL_DECISIONS.pending,
    reason: null,
  };
}

function buildTripPackageOpsMetadata(params: {
  status: TripPackageBookingStatus;
  scheduledAt: Date;
  assignmentWindowStartsAt: Date | null;
  nextAssignmentAttemptAt: Date | null;
  now: Date;
  opsLastIssueCode: TripPackageOpsIssueCode | null;
}): TripPackageBookingOpsMetadata {
  const {
    status,
    scheduledAt,
    assignmentWindowStartsAt,
    nextAssignmentAttemptAt,
    now,
    opsLastIssueCode,
  } = params;
  let opsNextActionAt: Date | null;
  if (status === TRIP_PACKAGE_BOOKING_STATUSES.pendingApproval) {
    opsNextActionAt = now;
  } else if (status === TRIP_PACKAGE_BOOKING_STATUSES.approved) {
    opsNextActionAt = assignmentWindowStartsAt;
  } else if (status === TRIP_PACKAGE_BOOKING_STATUSES.driverAssigned) {
    opsNextActionAt = buildTripPackageActivationAt(scheduledAt);
  } else if (status === TRIP_PACKAGE_BOOKING_STATUSES.activationInProgress) {
    opsNextActionAt = scheduledAt;
  } else if (status === TRIP_PACKAGE_BOOKING_STATUSES.awaitingDriverAcceptance) {
    opsNextActionAt = nextAssignmentAttemptAt ?? now;
  } else {
    opsNextActionAt = null;
  }
  return {
    opsQueueBucket: deriveTripPackageOpsQueueBucket({
      status,
      opsLastIssueCode,
    }),
    opsNextActionAt,
    opsIsActionable:
      status === TRIP_PACKAGE_BOOKING_STATUSES.pendingApproval ||
      isTripPackageBookingActionable(status),
    opsLastIssueCode,
  };
}

function resolveTripPackageBookingOpsMetadata(params: {
  status: TripPackageBookingStatus;
  scheduledAt: Date;
  assignmentWindowStartsAt: Date | null;
  nextAssignmentAttemptAt: Date | null;
  opsQueueBucket: string | null;
  opsNextActionAt: Date | null;
  opsIsActionable: boolean | null;
  opsLastIssueCode: TripPackageOpsIssueCode | null;
}): TripPackageBookingOpsMetadata {
  const fallback = buildTripPackageOpsMetadata({
    status: params.status,
    scheduledAt: params.scheduledAt,
    assignmentWindowStartsAt: params.assignmentWindowStartsAt,
    nextAssignmentAttemptAt: params.nextAssignmentAttemptAt,
    now: params.nextAssignmentAttemptAt ?? params.assignmentWindowStartsAt ?? params.scheduledAt,
    opsLastIssueCode: params.opsLastIssueCode,
  });
  return {
    opsQueueBucket:
      params.opsQueueBucket != null &&
          Object.values(TRIP_PACKAGE_OPS_QUEUE_BUCKETS).includes(
            params.opsQueueBucket as TripPackageOpsQueueBucket,
          ) ?
        (params.opsQueueBucket as TripPackageOpsQueueBucket) :
        fallback.opsQueueBucket,
    opsNextActionAt: params.opsNextActionAt ?? fallback.opsNextActionAt,
    opsIsActionable: params.opsIsActionable ?? fallback.opsIsActionable,
    opsLastIssueCode: params.opsLastIssueCode ?? fallback.opsLastIssueCode,
  };
}

function parseApprovalPayload(
  value: unknown,
): ParsedTripPackageBooking["approval"] {
  if (!value || typeof value !== "object") {
    return {
      requestedAt: null,
      decidedAt: null,
      decidedByUserId: null,
      decidedByRole: null,
      decision: TRIP_PACKAGE_APPROVAL_DECISIONS.pending,
      reason: null,
    };
  }
  const record = value as Record<string, unknown>;
  const rawDecision = optionalNonEmptyString(record.decision);
  const decision =
    rawDecision != null &&
        Object.values(TRIP_PACKAGE_APPROVAL_DECISIONS).includes(
          rawDecision as TripPackageApprovalDecision,
        ) ?
      (rawDecision as TripPackageApprovalDecision) :
      TRIP_PACKAGE_APPROVAL_DECISIONS.pending;
  return {
    requestedAt: parseOptionalDateLike(record.requestedAt),
    decidedAt: parseOptionalDateLike(record.decidedAt),
    decidedByUserId: optionalNonEmptyString(record.decidedByUserId),
    decidedByRole: optionalNonEmptyString(record.decidedByRole),
    decision,
    reason: optionalNonEmptyString(record.reason),
  };
}

function parseOptionalOpsIssueCode(value: unknown): TripPackageOpsIssueCode | null {
  const normalized = optionalNonEmptyString(value);
  if (
    normalized != null &&
    Object.values(TRIP_PACKAGE_OPS_ISSUE_CODES).includes(
      normalized as TripPackageOpsIssueCode,
    )
  ) {
    return normalized as TripPackageOpsIssueCode;
  }
  return null;
}

async function markTripPackageBookingAwaitingDriverAcceptance(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
  booking: ParsedTripPackageBooking;
  context: string;
  notifyOps: boolean;
}): Promise<ParsedTripPackageBooking> {
  const { firestore, messaging, booking, context, notifyOps } = params;
  if (booking.status !== TRIP_PACKAGE_BOOKING_STATUSES.approved) {
    return booking;
  }
  const opsMetadata = buildTripPackageOpsMetadata({
    status: TRIP_PACKAGE_BOOKING_STATUSES.awaitingDriverAcceptance,
    scheduledAt: booking.scheduledAt,
    assignmentWindowStartsAt: booking.assignmentWindowStartsAt,
    nextAssignmentAttemptAt: null,
    now: new Date(),
    opsLastIssueCode: null,
  });
  await firestore.doc(`tripPackageBookings/${booking.id}`).set(
    {
      status: TRIP_PACKAGE_BOOKING_STATUSES.awaitingDriverAcceptance,
      opsQueueBucket: opsMetadata.opsQueueBucket,
      opsNextActionAt:
        opsMetadata.opsNextActionAt == null ?
          null :
          Timestamp.fromDate(opsMetadata.opsNextActionAt),
      opsIsActionable: opsMetadata.opsIsActionable,
      opsLastIssueCode: null,
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  if (notifyOps) {
    await sendOpsNotificationBestEffort({
      firestore,
      messaging,
      type: "ops.package_booking_awaiting_driver_acceptance",
      title: "Package pronto para motorista",
      body:
        `O package ${booking.packageSnapshot.name} está pronto para seguir ` +
        "para aceitação do motorista.",
      data: {
        bookingId: booking.id,
        packageId: booking.packageId,
        type: "ops.package_booking_awaiting_driver_acceptance",
      },
      context: `trip_package_awaiting_driver_acceptance_${context}`,
    });
  }
  return {
    ...booking,
    status: TRIP_PACKAGE_BOOKING_STATUSES.awaitingDriverAcceptance,
    opsQueueBucket: opsMetadata.opsQueueBucket,
    opsNextActionAt: opsMetadata.opsNextActionAt,
    opsIsActionable: opsMetadata.opsIsActionable,
    opsLastIssueCode: null,
  };
}

function validatePackageAvailableForSale(
  packageDocument: TripPackageTemplateDocument,
): void {
  if (!packageDocument.isActive || packageDocument.archivedAt != null) {
    throw new HttpsError(
      "failed-precondition",
      "O package não está disponível para novas compras.",
    );
  }
}

function resolveAllowedTransportType(params: {
  selectedTransportType: TransportSnapshotPayload;
  allowedTransportTypes: TransportSnapshotPayload[];
}): TransportSnapshotPayload {
  const matched = params.allowedTransportTypes.find(
    (transportType) => transportType.id === params.selectedTransportType.id,
  );
  if (!matched) {
    throw new HttpsError(
      "failed-precondition",
      "O transporte escolhido não é permitido para este package.",
    );
  }
  return matched;
}

function buildPackageSnapshot(params: {
  packageId: string;
  packageDocument: TripPackageTemplateDocument;
}): TripPackageSnapshotDocument {
  return {
    packageId: params.packageId,
    snapshotVersion: params.packageDocument.snapshotVersion,
    name: params.packageDocument.name,
    photoUrl: params.packageDocument.photoUrl,
    description: params.packageDocument.description,
    destination: params.packageDocument.destination,
    price: params.packageDocument.price,
    allowedTransportTypes: params.packageDocument.allowedTransportTypes,
  };
}

function parseTemplateWriteInput(value: unknown): {
  id?: string;
  name: string;
  photoUrl: string;
  description: string;
  destination: TripLocationPayload;
  price: MoneyPayload;
  allowedTransportTypes: TransportSnapshotPayload[];
  isActive: boolean;
  archivedAt: Timestamp | null;
} {
  const record = asRecord(value);
  const allowedTransportTypes = parseTransportSnapshotList(
    record.allowedTransportTypes,
    "allowedTransportTypes",
  );
  if (allowedTransportTypes.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "allowedTransportTypes não pode estar vazio.",
    );
  }
  return {
    id: optionalNonEmptyString(record.id) ?? undefined,
    name: requireNonEmptyString(record.name, "name"),
    photoUrl: requireNonEmptyString(record.photoUrl, "photoUrl"),
    description: requireNonEmptyString(record.description, "description"),
    destination: parseLocationPayload(record.destination, "destination"),
    price: parseMoneyPayload(record.price, "price"),
    allowedTransportTypes,
    isActive: parseBoolean(record.isActive, "isActive"),
    archivedAt: parseOptionalTimestamp(record.archivedAt),
  };
}

function parseBookingRequest(value: unknown): BookingRequestInput {
  const record = asRecord(value);
  return {
    packageId: requireNonEmptyString(record.packageId, "packageId"),
    pickup: parseLocationPayload(record.pickup, "pickup"),
    scheduledAt: parseDateLike(record.scheduledAt, "scheduledAt"),
    transportType: parseTransportSnapshot(
      record.transportType,
      "transportType",
    ),
    idempotencyKey: requireNonEmptyString(
      record.idempotencyKey,
      "idempotencyKey",
    ),
  };
}

function parseTemplateDocument(
  packageId: string,
  data: FirebaseFirestore.DocumentData | undefined,
): TripPackageTemplateDocument {
  if (!data) {
    throw new HttpsError("failed-precondition", "Package indisponível.");
  }
  const document: TripPackageTemplateDocument = {
    name: requireNonEmptyString(data.name, "name"),
    photoUrl: requireNonEmptyString(data.photoUrl, "photoUrl"),
    description: requireNonEmptyString(data.description, "description"),
    destination: parseLocationPayload(data.destination, "destination"),
    price: parseMoneyPayload(data.price, "price"),
    allowedTransportTypes: parseStoredTransportSnapshotList(
      data.allowedTransportTypes,
      "allowedTransportTypes",
    ),
    isActive: data.isActive === true,
    snapshotVersion: parseIntegerLike(data.snapshotVersion, "snapshotVersion"),
    archivedAt: parseOptionalTimestamp(data.archivedAt),
    createdAt: parseOptionalTimestamp(data.createdAt),
    updatedAt: parseOptionalTimestamp(data.updatedAt),
  };
  assertMoneyCurrencyOrThrow({
    value: document.price,
    expectedCurrency: OPERATION_CURRENCY_CODE,
    fieldName: "price",
  });
  if (document.allowedTransportTypes.length === 0) {
    throw new HttpsError(
      "failed-precondition",
      "O package tem allowedTransportTypes vazio.",
    );
  }
  logger.debug("Trip package template parsed.", {
    packageId,
    snapshotVersion: document.snapshotVersion,
    isActive: document.isActive,
    archived: document.archivedAt != null,
  });
  return document;
}

function parseBookingDocument(
  bookingId: string,
  data: FirebaseFirestore.DocumentData | undefined,
): ParsedTripPackageBooking {
  if (!data) {
    throw new HttpsError("failed-precondition", "Booking indisponível.");
  }
  const normalizedStatus = normalizeTripPackageBookingStatus(
    requireNonEmptyString(data.status, "status"),
  );
  const approval = parseApprovalPayload(data.approval);
  const opsMetadata = resolveTripPackageBookingOpsMetadata({
    status: normalizedStatus,
    scheduledAt: parseDateLike(data.scheduledAt, "scheduledAt"),
    assignmentWindowStartsAt: parseOptionalDateLike(data.assignmentWindowStartsAt),
    nextAssignmentAttemptAt: parseOptionalDateLike(data.nextAssignmentAttemptAt),
    opsQueueBucket: optionalNonEmptyString(data.opsQueueBucket),
    opsNextActionAt: parseOptionalDateLike(data.opsNextActionAt),
    opsIsActionable: typeof data.opsIsActionable === "boolean" ?
      data.opsIsActionable :
      null,
    opsLastIssueCode: parseOptionalOpsIssueCode(data.opsLastIssueCode),
  });
  return {
    id: bookingId,
    clientId: requireNonEmptyString(data.clientId, "clientId"),
    packageId: requireNonEmptyString(data.packageId, "packageId"),
    reservationId: requireNonEmptyString(data.reservationId, "reservationId"),
    tripId: optionalNonEmptyString(data.tripId),
    assignedDriverId: optionalNonEmptyString(data.assignedDriverId),
    assignedVehicleId: optionalNonEmptyString(data.assignedVehicleId),
    packageSnapshot: parsePackageSnapshotDocument(data.packageSnapshot),
    pickup: parseLocationPayload(data.pickup, "pickup"),
    destinationSnapshot: parseLocationPayload(
      data.destinationSnapshot,
      "destinationSnapshot",
    ),
    scheduledAt: parseDateLike(data.scheduledAt, "scheduledAt"),
    transportType: parseTransportSnapshot(data.transportType, "transportType"),
    price: parseMoneyPayload(data.price, "price"),
    priceAdjustmentMinor: parseIntegerLike(
      data.priceAdjustmentMinor,
      "priceAdjustmentMinor",
    ),
    clientCancellationClosesAt: parseDateLike(
      data.clientCancellationClosesAt,
      "clientCancellationClosesAt",
    ),
    status: normalizedStatus,
    refundStatus: requireNonEmptyString(data.refundStatus, "refundStatus"),
    chargedAmount: parseMoneyPayload(data.chargedAmount, "chargedAmount"),
    refundedAmount: parseMoneyPayload(data.refundedAmount, "refundedAmount"),
    assignmentStatus:
      optionalNonEmptyString(data.assignmentStatus) ??
      TRIP_PACKAGE_ASSIGNMENT_STATUSES.pending,
    assignmentWindowStartsAt: parseOptionalDateLike(data.assignmentWindowStartsAt),
    nextAssignmentAttemptAt: parseOptionalDateLike(data.nextAssignmentAttemptAt),
    lastAssignmentAttemptAt: parseOptionalDateLike(data.lastAssignmentAttemptAt),
    assignmentAttemptsCount: parseOptionalIntegerLike(data.assignmentAttemptsCount) ?? 0,
    approval,
    opsQueueBucket: opsMetadata.opsQueueBucket,
    opsNextActionAt: opsMetadata.opsNextActionAt,
    opsIsActionable: opsMetadata.opsIsActionable,
    opsLastIssueCode: opsMetadata.opsLastIssueCode,
    cancellation: parseCancellationPayload(data.cancellation),
  };
}

function parseReservationDocument(
  reservationId: string,
  data: FirebaseFirestore.DocumentData | undefined,
): ParsedReservationDocument {
  if (!data) {
    throw new HttpsError("failed-precondition", "Reserva indisponível.");
  }
  return {
    id: reservationId,
    clientId: requireNonEmptyString(data.clientId, "clientId"),
    source: requireNonEmptyString(data.source, "source"),
    packageId: optionalNonEmptyString(data.packageId),
    packageBookingId: optionalNonEmptyString(data.packageBookingId),
    scheduledAt: parseDateLike(data.scheduledAt, "scheduledAt"),
    status: requireNonEmptyString(data.status, "status"),
    pickup: parseLocationPayload(data.pickup, "pickup"),
    destination: parseLocationPayload(data.destination, "destination"),
    transportType: parseTransportSnapshot(data.transportType, "transportType"),
    assignedDriverId: optionalNonEmptyString(data.assignedDriverId),
    vehicleId: optionalNonEmptyString(data.vehicleId),
    tripId: optionalNonEmptyString(data.tripId),
  };
}

function parsePackageSnapshotDocument(
  value: unknown,
): TripPackageSnapshotDocument {
  const record = asRecord(value);
  return {
    packageId: requireNonEmptyString(record.packageId, "packageSnapshot.packageId"),
    snapshotVersion: parseIntegerLike(
      record.snapshotVersion,
      "packageSnapshot.snapshotVersion",
    ),
    name: requireNonEmptyString(record.name, "packageSnapshot.name"),
    photoUrl: requireNonEmptyString(record.photoUrl, "packageSnapshot.photoUrl"),
    description: requireNonEmptyString(
      record.description,
      "packageSnapshot.description",
    ),
    destination: parseLocationPayload(
      record.destination,
      "packageSnapshot.destination",
    ),
    price: parseMoneyPayload(record.price, "packageSnapshot.price"),
    allowedTransportTypes: parseTransportSnapshotList(
      record.allowedTransportTypes,
      "packageSnapshot.allowedTransportTypes",
    ),
  };
}

function parseBalanceDocument(
  data: FirebaseFirestore.DocumentData | undefined,
): BalanceDocument {
  if (!data) {
    throw new HttpsError("failed-precondition", "Saldo indisponível.");
  }
  const balance = parseMoneyPayload(data.balance, "balance");
  const debtLimit = parseMoneyPayload(data.debtLimit, "debtLimit");
  if (balance.currency !== debtLimit.currency) {
    throw new HttpsError(
      "failed-precondition",
      "Saldo e limite de crédito têm moedas diferentes.",
    );
  }
  return { balance, debtLimit };
}

function parseBookingOperationDocument(
  data: FirebaseFirestore.DocumentData | undefined,
): TripPackageBookingOperationDocument {
  if (!data) {
    throw new HttpsError("failed-precondition", "Operação indisponível.");
  }
  const status = requireNonEmptyString(data.status, "status");
  if (!["pending", "succeeded", "failed"].includes(status)) {
    throw new HttpsError("failed-precondition", "Estado de operação inválido.");
  }
  return {
    clientId: requireNonEmptyString(data.clientId, "clientId"),
    idempotencyKey: requireNonEmptyString(data.idempotencyKey, "idempotencyKey"),
    requestHash: requireNonEmptyString(data.requestHash, "requestHash"),
    status: status as TripPackageBookingOperationDocument["status"],
    bookingId: optionalNonEmptyString(data.bookingId),
    errorCode: optionalNonEmptyString(data.errorCode),
    createdAt: parseOptionalTimestamp(data.createdAt),
    updatedAt: parseOptionalTimestamp(data.updatedAt),
  };
}

function parseDriverCandidate(
  driverId: string,
  value: unknown,
): DriverCandidate | null {
  const record = asRecord(value);
  const vehicleId = optionalNonEmptyString(record.vehicleId);
  if (!vehicleId) {
    return null;
  }
  return {
    driverId,
    vehicleId,
    isAvailable: record.isAvailable === true,
    isBusy: record.isBusy === true,
    currentTripId: optionalNonEmptyString(record.currentTripId),
  };
}

function parseMoneyPayload(value: unknown, fieldName: string): MoneyPayload {
  const record = asRecord(value);
  const amountMinor = parseIntegerLike(record.amountMinor, `${fieldName}.amountMinor`);
  const currency = requireNonEmptyString(record.currency, `${fieldName}.currency`);
  return { amountMinor, currency };
}

function parseLocationPayload(
  value: unknown,
  fieldName: string,
): TripLocationPayload {
  const record = asRecord(value);
  const latitude = parseNumberLike(record.latitude, `${fieldName}.latitude`);
  const longitude = parseNumberLike(record.longitude, `${fieldName}.longitude`);
  const address = requireNonEmptyString(record.address, `${fieldName}.address`);
  return { latitude, longitude, address };
}

function parseTransportSnapshot(
  value: unknown,
  fieldName: string,
): TransportSnapshotPayload {
  const record = asRecord(value);
  return {
    id: requireNonEmptyString(record.id, `${fieldName}.id`),
    name: requireNonEmptyString(record.name, `${fieldName}.name`),
    packagePriceMultiplierBasisPoints: parseMultiplierBasisPoints(
      record.packagePriceMultiplierBasisPoints,
      `${fieldName}.packagePriceMultiplierBasisPoints`,
    ),
  };
}

function parseOptionalTransportSnapshot(
  value: unknown,
): TransportSnapshotPayload | null {
  if (!value || typeof value !== "object") {
    return null;
  }
  const record = value as Record<string, unknown>;
  const id = optionalNonEmptyString(record.id);
  const name = optionalNonEmptyString(record.name);
  const packagePriceMultiplierBasisPoints = parseOptionalMultiplierBasisPoints(
    record.packagePriceMultiplierBasisPoints,
  );
  if (!id || !name || packagePriceMultiplierBasisPoints == null) {
    return null;
  }
  return { id, name, packagePriceMultiplierBasisPoints };
}

function parseTransportSnapshotList(
  value: unknown,
  fieldName: string,
): TransportSnapshotPayload[] {
  if (!Array.isArray(value)) {
    throw new HttpsError("invalid-argument", `${fieldName} inválido.`);
  }
  return value.map((entry, index) =>
    parseTransportSnapshot(entry, `${fieldName}[${index}]`),
  );
}

function parseStoredTransportSnapshotList(
  value: unknown,
  fieldName: string,
): TransportSnapshotPayload[] {
  if (!Array.isArray(value)) {
    throw new HttpsError("invalid-argument", `${fieldName} inválido.`);
  }
  return value.map((entry, index) =>
    parseStoredTransportSnapshot(entry, `${fieldName}[${index}]`),
  );
}

function parseStoredTransportSnapshot(
  value: unknown,
  fieldName: string,
): TransportSnapshotPayload {
  const record = asRecord(value);
  const packagePriceMultiplierBasisPoints =
    parseOptionalMultiplierBasisPoints(
      record.packagePriceMultiplierBasisPoints,
    ) ?? 10000;
  if (record.packagePriceMultiplierBasisPoints == null) {
    logger.warn("Stored trip package transport snapshot missing multiplier.", {
      fieldName,
      fallbackPackagePriceMultiplierBasisPoints:
        packagePriceMultiplierBasisPoints,
    });
  }
  return {
    id: requireNonEmptyString(record.id, `${fieldName}.id`),
    name: requireNonEmptyString(record.name, `${fieldName}.name`),
    packagePriceMultiplierBasisPoints,
  };
}

function parseDateLike(value: unknown, fieldName: string): Date {
  if (value instanceof Timestamp) {
    return value.toDate();
  }
  if (value instanceof Date) {
    return value;
  }
  if (typeof value === "string" && value.trim().length > 0) {
    const parsed = new Date(value);
    if (!Number.isNaN(parsed.getTime())) {
      return parsed;
    }
  }
  throw new HttpsError("invalid-argument", `${fieldName} inválido.`);
}

function parseOptionalDateLike(value: unknown): Date | null {
  if (value == null) {
    return null;
  }
  try {
    return parseDateLike(value, "optionalDate");
  } catch (_) {
    return null;
  }
}

function parseOptionalTimestamp(
  value: unknown,
): Timestamp | null {
  if (value instanceof Timestamp) {
    return value;
  }
  return null;
}

function parseOptionalIntegerLike(value: unknown): number | null {
  if (value == null) {
    return null;
  }
  try {
    return parseIntegerLike(value, "optionalInteger");
  } catch (_) {
    return null;
  }
}

function parseMultiplierBasisPoints(value: unknown, fieldName: string): number {
  const parsed = parseIntegerLike(value, fieldName);
  if (
    parsed < TRIP_PACKAGE_MIN_MULTIPLIER_BASIS_POINTS ||
    parsed > TRIP_PACKAGE_MAX_MULTIPLIER_BASIS_POINTS
  ) {
    throw new HttpsError("invalid-argument", `${fieldName} inválido.`);
  }
  return parsed;
}

function parseOptionalMultiplierBasisPoints(value: unknown): number | null {
  if (value == null) {
    return null;
  }
  try {
    return parseMultiplierBasisPoints(value, "optionalMultiplierBasisPoints");
  } catch (_) {
    return null;
  }
}

function parseCancellationPayload(
  value: unknown,
): ParsedTripPackageBooking["cancellation"] {
  if (!value || typeof value !== "object") {
    return null;
  }
  const record = value as Record<string, unknown>;
  const reasonCode = optionalNonEmptyString(record.reasonCode);
  if (!reasonCode) {
    return null;
  }
  return {
    reasonCode,
    reasonLabel: optionalNonEmptyString(record.reasonLabel) ?? undefined,
    cancelledBy: optionalNonEmptyString(record.cancelledBy) ?? undefined,
    cancelledAt: parseOptionalTimestamp(record.cancelledAt) ?? undefined,
  };
}

function buildMoneyPayload(amountMinor: number): MoneyPayload {
  return {
    amountMinor,
    currency: OPERATION_CURRENCY_CODE,
  };
}

function computeChargedAmount(params: {
  basePrice: MoneyPayload;
  transportType: TransportSnapshotPayload;
}): MoneyPayload {
  const amountMinor = roundHalfUpIntegerDivision(
    BigInt(params.basePrice.amountMinor) *
      BigInt(params.transportType.packagePriceMultiplierBasisPoints),
    BigInt(10000),
  );
  return {
    amountMinor: Number(amountMinor),
    currency: params.basePrice.currency,
  };
}

function roundHalfUpIntegerDivision(
  numerator: bigint,
  denominator: bigint,
): bigint {
  const quotient = numerator / denominator;
  const remainder = numerator % denominator;
  if (remainder === BigInt(0)) {
    return quotient;
  }
  return remainder * BigInt(2) >= denominator ? quotient + BigInt(1) : quotient;
}

function assertMoneyCurrencyOrThrow(params: {
  value: MoneyPayload;
  expectedCurrency: string;
  fieldName: string;
}): void {
  if (params.value.currency !== params.expectedCurrency) {
    throw new HttpsError(
      "failed-precondition",
      `${params.fieldName} com moeda incompatível.`,
    );
  }
}

function assertBalanceLimit(params: {
  balance: BalanceDocument;
  debitAmountMinor: number;
  operation: string;
}): void {
  if (params.balance.balance.currency !== OPERATION_CURRENCY_CODE) {
    throw new HttpsError("failed-precondition", "Moeda de operação inválida.");
  }
  const creditLimitMinor = Math.abs(params.balance.debtLimit.amountMinor);
  const balanceAfterMinor =
    params.balance.balance.amountMinor - params.debitAmountMinor;
  if (balanceAfterMinor < -creditLimitMinor) {
    throw new HttpsError(
      "failed-precondition",
      "Limite de crédito excedido.",
      {
        reason: "LIMIT_EXCEEDED",
        operation: params.operation,
        currency: params.balance.balance.currency,
        balanceBeforeMinor: params.balance.balance.amountMinor,
        debitAmountMinor: params.debitAmountMinor,
        balanceAfterMinor,
        creditLimitMinor,
      },
    );
  }
}

function buildScheduledMinutesLocal(value: Date): number {
  const parts = getLocalDateParts(value, TRIP_PACKAGE_OPERATION_TIMEZONE);
  return parts.hour * 60 + parts.minute;
}

type ReservationWindow = {
  start: Date;
  end: Date;
};

type VehicleSnapshot = {
  id: string;
  isActive: boolean;
  defaultTransportType: TransportSnapshotPayload | null;
};

function buildReservationWindow(params: {
  start: Date;
  pickup: TripLocationPayload;
  destination: TripLocationPayload;
}): ReservationWindow {
  const durationMinutes = estimateDurationMinutes({
    pickup: params.pickup,
    destination: params.destination,
  });
  return {
    start: params.start,
    end: new Date(params.start.getTime() + durationMinutes * 60 * 1000),
  };
}

function estimateDurationMinutes(params: {
  pickup: TripLocationPayload;
  destination: TripLocationPayload;
}): number {
  const distanceKm = calculateDistanceKm(params.pickup, params.destination);
  const durationMinutes =
    distanceKm === 0 ? 0 : Math.ceil((distanceKm / AVERAGE_SPEED_KMH) * 60);
  return Math.max(durationMinutes, MIN_OPERATION_WINDOW_MINUTES);
}

function windowsOverlap(left: ReservationWindow, right: ReservationWindow): boolean {
  return left.start < right.end && right.start < left.end;
}

function calculateDistanceKm(
  pickup: TripLocationPayload,
  destination: TripLocationPayload,
): number {
  const earthRadiusKm = 6371;
  const latDelta = degreesToRadians(destination.latitude - pickup.latitude);
  const lonDelta = degreesToRadians(destination.longitude - pickup.longitude);
  const lat1 = degreesToRadians(pickup.latitude);
  const lat2 = degreesToRadians(destination.latitude);
  const a =
    Math.sin(latDelta / 2) * Math.sin(latDelta / 2) +
    Math.cos(lat1) *
      Math.cos(lat2) *
      Math.sin(lonDelta / 2) *
      Math.sin(lonDelta / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return earthRadiusKm * c;
}

function degreesToRadians(value: number): number {
  return value * (Math.PI / 180);
}

function normalizeTripStatus(value: unknown): string | null {
  if (typeof value !== "string" || value.trim().length === 0) {
    return null;
  }
  const normalized = value.trim().toUpperCase();
  return ACTIVE_TRIP_STATUSES.has(normalized) ||
      INACTIVE_TRIP_STATUSES.has(normalized) ?
    normalized :
    normalized;
}

function buildPendingApprovalNotificationBody(params: {
  packageSnapshot: TripPackageSnapshotDocument;
  scheduledAt: Date;
}): string {
  const local = getLocalDateParts(
    params.scheduledAt,
    TRIP_PACKAGE_OPERATION_TIMEZONE,
  );
  return `${params.packageSnapshot.name} ficou em análise para ${local.day
    .toString()
    .padStart(2, "0")}/${local.month
    .toString()
    .padStart(2, "0")} às ${local.hour
    .toString()
    .padStart(2, "0")}:${local.minute
    .toString()
    .padStart(2, "0")}. Será notificado após a aprovação.`;
}

function buildApprovedBookingNotificationBody(params: {
  packageSnapshot: TripPackageSnapshotDocument;
  scheduledAt: Date;
}): string {
  const local = getLocalDateParts(
    params.scheduledAt,
    TRIP_PACKAGE_OPERATION_TIMEZONE,
  );
  return `${params.packageSnapshot.name} foi aprovado para ${local.day
    .toString()
    .padStart(2, "0")}/${local.month
    .toString()
    .padStart(2, "0")} às ${local.hour
    .toString()
    .padStart(2, "0")}:${local.minute
    .toString()
    .padStart(2, "0")}.`;
}

function requireNonEmptyString(value: unknown, fieldName: string): string {
  if (typeof value === "string" && value.trim().length > 0) {
    return value.trim();
  }
  throw new HttpsError("invalid-argument", `${fieldName} inválido.`);
}

function optionalNonEmptyString(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

function parseIntegerLike(value: unknown, fieldName: string): number {
  if (typeof value === "number" && Number.isInteger(value)) {
    return value;
  }
  if (typeof value === "number" && !Number.isNaN(value)) {
    return Math.trunc(value);
  }
  throw new HttpsError("invalid-argument", `${fieldName} inválido.`);
}

function parseNumberLike(value: unknown, fieldName: string): number {
  if (typeof value === "number" && !Number.isNaN(value)) {
    return value;
  }
  throw new HttpsError("invalid-argument", `${fieldName} inválido.`);
}

function parseBoolean(value: unknown, fieldName: string): boolean {
  if (typeof value === "boolean") {
    return value;
  }
  throw new HttpsError("invalid-argument", `${fieldName} inválido.`);
}

function asRecord(value: unknown): Record<string, unknown> {
  if (value && typeof value === "object") {
    return value as Record<string, unknown>;
  }
  throw new HttpsError("invalid-argument", "Payload inválido.");
}

function resolveHttpsErrorCode(error: unknown): string {
  const httpError = error as Partial<HttpsError> | undefined;
  if (typeof httpError?.code === "string" && httpError.code.trim().length > 0) {
    return httpError.code;
  }
  return "internal";
}

function assertTripPackageManagerAccess(params: {
  role: RbacRole;
  authToken: Record<string, unknown> | null | undefined;
  context: string;
}): void {
  if (params.role === "admin") {
    return;
  }
  assertManagerPermission({
    role: params.role,
    authToken: params.authToken,
    permission: "tp",
    context: params.context,
  });
}
