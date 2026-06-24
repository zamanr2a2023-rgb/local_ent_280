import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import {
  CRITICAL_CALLABLE_RUNTIME_OPTIONS,
  STANDARD_CALLABLE_RUNTIME_OPTIONS,
} from "../shared/constants";
import {
  requireAuthenticatedUid,
  resolveCallerRole,
} from "../shared/auth/rbacRoleResolver";
import { assertManagerPermission } from "../shared/auth/managerPermissionClaims";
import {
  buildTripCallableIdempotencyPath,
  parseOptionalIdempotencyKey,
  resolveTripCallableIdempotencyKey,
  runTripCallableIdempotent,
} from "./callableIdempotency";

type TripCriticalCallablesDeps = {
  firestore: admin.firestore.Firestore;
  auth: admin.auth.Auth;
  validTripStatuses: ReadonlySet<string>;
  normalizeTripStatus: (value: unknown) => string;
  enforceTripUpdatePayload: (params: {
    payload: Record<string, unknown>;
    context: string;
  }) => void;
  enforceTripEventPayload: (params: {
    payload: Record<string, unknown>;
    context: string;
  }) => void;
  finalizeTripPayment: (params: {
    tripId: string;
    clientId: string;
    reason: "manual" | "on_completion";
  }) => Promise<void>;
};

function toSnakeCaseStatus(status: string): string {
  return status.toLowerCase();
}

const TRIP_EVENT_TTL_DAYS = 90;
const OPERATION_CURRENCY_CODE = "EUR";

type MoneyPayload = {
  amountMinor: number;
  currency: string;
};

const TRIP_STATE_MACHINE: Record<string, ReadonlySet<string>> = {
  REQUESTED: new Set([
    "DRIVER_ASSIGNED_WAITING_ACCEPTANCE",
    "NO_DRIVERS_AVAILABLE",
    "CANCELLED_BY_CLIENT",
  ]),
  DRIVER_ASSIGNED_WAITING_ACCEPTANCE: new Set([
    "DRIVER_ACCEPTED",
    "DRIVER_DECLINED",
    "CANCELLED_BY_CLIENT",
    "CANCELLED_BY_DRIVER",
    "NO_SHOW",
  ]),
  DRIVER_ACCEPTED: new Set([
    "DRIVER_EN_ROUTE",
    "CANCELLED_BY_CLIENT",
    "CANCELLED_BY_DRIVER",
    "NO_SHOW",
  ]),
  DRIVER_DECLINED: new Set([
    "DRIVER_ASSIGNED_WAITING_ACCEPTANCE",
    "NO_DRIVERS_AVAILABLE",
  ]),
  DRIVER_EN_ROUTE: new Set([
    "DRIVER_ARRIVED",
    "CANCELLED_BY_CLIENT",
    "CANCELLED_BY_DRIVER",
    "NO_SHOW",
  ]),
  DRIVER_ARRIVED: new Set([
    "IN_TRIP",
    "CANCELLED_BY_CLIENT",
    "CANCELLED_BY_DRIVER",
    "NO_SHOW",
  ]),
  IN_TRIP: new Set(["ARRIVED_DESTINATION", "CANCELLED_BY_DRIVER"]),
  ARRIVED_DESTINATION: new Set(["EXTENSION_WINDOW", "COMPLETED"]),
  EXTENSION_WINDOW: new Set(["COMPLETED"]),
  COMPLETED: new Set(["CHARGE_APPLIED"]),
  CHARGE_APPLIED: new Set(),
  CANCELLED_BY_CLIENT: new Set(),
  CANCELLED_BY_DRIVER: new Set(),
  NO_SHOW: new Set(),
  NO_DRIVERS_AVAILABLE: new Set(),
};

const SUPPORT_CANCEL_ALLOWED_STATUSES = new Set<string>([
  "REQUESTED",
  "DRIVER_ASSIGNED_WAITING_ACCEPTANCE",
  "DRIVER_ACCEPTED",
  "DRIVER_DECLINED",
  "DRIVER_EN_ROUTE",
  "DRIVER_ARRIVED",
]);

function assertTransitionAllowed(
  fromStatus: string,
  toStatus: string,
  context: string,
): void {
  const allowed = TRIP_STATE_MACHINE[fromStatus];
  if (!allowed?.has(toStatus)) {
    logger.warn("Trip transition blocked by state machine.", {
      context,
      fromStatus,
      toStatus,
    });
    throw new HttpsError(
      "failed-precondition",
      "Transição de estado inválida.",
    );
  }
}

function assertSupportCancellationAllowed(status: string): void {
  if (SUPPORT_CANCEL_ALLOWED_STATUSES.has(status)) {
    return;
  }
  logger.warn("Support cancellation blocked for trip state.", {
    status,
    reason: "cannot_cancel_after_trip_started",
  });
  throw new HttpsError(
    "failed-precondition",
    "Cancelamento indisponível no estado atual.",
    {
      reason: "cannot_cancel_after_trip_started",
      currentStatus: status,
    },
  );
}

function buildTripEventTtlDate(): Timestamp {
  const ttlDate = new Date(
    Date.now() + TRIP_EVENT_TTL_DAYS * 24 * 60 * 60 * 1000,
  );
  return Timestamp.fromDate(ttlDate);
}

function buildTripEventPayload(params: {
  fromStatus: string;
  toStatus: string;
  actorId: string;
  eventType: string;
  metadata?: Record<string, unknown>;
}): Record<string, unknown> {
  const { fromStatus, toStatus, actorId, eventType, metadata } = params;
  return {
    fromState: toSnakeCaseStatus(fromStatus),
    toState: toSnakeCaseStatus(toStatus),
    actorId,
    eventType,
    ...(metadata ? { metadata } : {}),
    createdAt: FieldValue.serverTimestamp(),
    tripEventExpiresAt: buildTripEventTtlDate(),
  };
}

function buildAuditPayload(params: {
  actionType: string;
  actorId: string;
  actorEmail?: string | null;
  subject: string;
  reason: string;
  before?: Record<string, unknown>;
  after?: Record<string, unknown>;
}): Record<string, unknown> {
  const { actionType, actorId, actorEmail, subject, reason, before, after } =
    params;
  return {
    actionType,
    adminId: actorId,
    ...(actorEmail != null && actorEmail.trim().length > 0
      ? { adminEmail: actorEmail.trim() }
      : {}),
    reason,
    ...(before ? { before } : {}),
    ...(after ? { after } : {}),
    subject,
    createdAt: FieldValue.serverTimestamp(),
  };
}

async function resolveAuditActorEmail(params: {
  auth: admin.auth.Auth;
  authToken: Record<string, unknown> | null | undefined;
  actorId: string;
  context: string;
}): Promise<string | null> {
  const tokenEmail =
    typeof params.authToken?.email === "string"
      ? params.authToken.email.trim()
      : "";
  if (tokenEmail.length > 0) {
    return tokenEmail;
  }
  try {
    const user = await params.auth.getUser(params.actorId);
    const email = user.email?.trim();
    if (!email) {
      return null;
    }
    return email;
  } catch (error) {
    logger.warn("Failed to resolve audit actor email.", {
      context: params.context,
      actorId: params.actorId,
      error,
    });
    return null;
  }
}

function parseTripId(data: Record<string, unknown> | null): string {
  const tripId = typeof data?.tripId === "string" ? data.tripId.trim() : "";
  if (!tripId) {
    throw new HttpsError("invalid-argument", "Viagem inválida.");
  }
  return tripId;
}

function parseOptionalEventId(
  data: Record<string, unknown> | null,
): string | null {
  const eventId = typeof data?.eventId === "string" ? data.eventId.trim() : "";
  if (!eventId) {
    return null;
  }
  return eventId;
}

function isMoneyPayload(value: unknown): value is MoneyPayload {
  if (!value || typeof value !== "object") {
    return false;
  }
  const payload = value as Record<string, unknown>;
  return (
    typeof payload.amountMinor === "number" &&
    typeof payload.currency === "string" &&
    payload.currency.trim().length > 0
  );
}

function parseRequiredMoneyPayload(
  value: unknown,
  fieldName: string,
): MoneyPayload {
  if (!isMoneyPayload(value)) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} inválido. Use o contrato Money { amountMinor, currency }.`,
    );
  }
  return {
    amountMinor: value.amountMinor,
    currency: value.currency.trim().toUpperCase(),
  };
}

function assertOperationCurrency(value: MoneyPayload, fieldName: string): void {
  if (value.currency !== OPERATION_CURRENCY_CODE) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName}.currency inválida.`,
      {
        reason: "CURRENCY_MISMATCH",
        fieldName,
        expectedCurrency: OPERATION_CURRENCY_CODE,
        receivedCurrency: value.currency,
      },
    );
  }
}

function parseStoredMoneyPayload(value: unknown): MoneyPayload | null {
  if (!isMoneyPayload(value)) {
    return null;
  }
  return {
    amountMinor: value.amountMinor,
    currency: value.currency.trim().toUpperCase(),
  };
}

export function buildTripStateMachineCallables(
  deps: TripCriticalCallablesDeps,
) {
  const {
    firestore,
    auth,
    validTripStatuses,
    normalizeTripStatus,
    enforceTripUpdatePayload,
    enforceTripEventPayload,
    finalizeTripPayment,
  } = deps;

  async function runIdempotentTripCallable<
    T extends Record<string, unknown>,
  >(params: {
    data: Record<string, unknown> | null;
    tripId: string;
    action: string;
    requesterId: string;
    execute: (transaction: admin.firestore.Transaction) => Promise<T>;
  }): Promise<{ response: T; duplicated: boolean; idempotencyKey: string }> {
    const { data, tripId, action, requesterId, execute } = params;
    const idempotencyKey = resolveTripCallableIdempotencyKey({
      tripId,
      action,
      requesterId,
      eventId: parseOptionalEventId(data),
      providedKey: parseOptionalIdempotencyKey(data),
    });
    const { response, duplicated } = await runTripCallableIdempotent({
      firestore,
      tripId,
      idempotencyKey,
      action,
      requesterId,
      createdAtValue: FieldValue.serverTimestamp(),
      execute,
    });
    logger.debug("Trip callable idempotency evaluated.", {
      action,
      tripId,
      requesterId,
      idempotencyKey,
      duplicated,
    });
    return { response, duplicated, idempotencyKey };
  }

  const transitionTripState = onCall(
    CRITICAL_CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);
      const requesterEmail = await resolveAuditActorEmail({
        auth,
        authToken: request.auth?.token ?? null,
        actorId: requesterId,
        context: "transitionTripState",
      });
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });

      const data = request.data as Record<string, unknown> | null;
      const tripId = parseTripId(data);
      const targetStatus = normalizeTripStatus(data?.targetStatus);
      if (!validTripStatuses.has(targetStatus)) {
        throw new HttpsError("invalid-argument", "Estado de destino inválido.");
      }

      const tripRef = firestore.doc(`trips/${tripId}`);
      const isAdmin = callerRole === "admin";

      const response = await runIdempotentTripCallable({
        data,
        tripId,
        action: `trip_transition_${targetStatus.toLowerCase()}`,
        requesterId,
        execute: async (transaction) => {
          const eventRef = firestore
            .collection("tripEvents")
            .doc(tripId)
            .collection("events")
            .doc();
          const auditRef = firestore.collection("audit").doc();
          const tripSnapshot = await transaction.get(tripRef);
          const tripData = tripSnapshot.data();
          if (!tripData) {
            throw new HttpsError("not-found", "Viagem não encontrada.");
          }

          const currentStatus = normalizeTripStatus(tripData.status);
          assertTransitionAllowed(
            currentStatus,
            targetStatus,
            "transitionTripState",
          );

          const clientId = tripData.clientId?.toString();
          const assignedDriverId = tripData.assignedDriverId?.toString();
          const isOwner =
            requesterId === clientId || requesterId === assignedDriverId;
          if (!isOwner && !isAdmin) {
            throw new HttpsError(
              "permission-denied",
              "Permissões insuficientes.",
            );
          }

          const updatePayload: Record<string, unknown> = {
            status: targetStatus,
            statusEnteredAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
          };
          if (targetStatus === "DRIVER_ACCEPTED") {
            updatePayload.acceptedAt =
              FieldValue.serverTimestamp();
            updatePayload.acceptedDriverId = requesterId;
          }
          if (targetStatus === "DRIVER_DECLINED") {
            updatePayload.driverDeclinedAt =
              FieldValue.serverTimestamp();
            updatePayload.declinedByDriverId = requesterId;
          }
          if (targetStatus === "DRIVER_EN_ROUTE") {
            updatePayload.driverEnRouteAt =
              FieldValue.serverTimestamp();
          }
          if (targetStatus === "DRIVER_ARRIVED") {
            updatePayload.arrivedAt =
              FieldValue.serverTimestamp();
          }
          if (targetStatus === "IN_TRIP") {
            updatePayload.startedAt =
              FieldValue.serverTimestamp();
          }
          if (targetStatus === "ARRIVED_DESTINATION") {
            updatePayload.arrivedDestinationAt =
              FieldValue.serverTimestamp();
          }
          if (targetStatus === "EXTENSION_WINDOW") {
            updatePayload.extensionWindowAt =
              FieldValue.serverTimestamp();
          }
          if (targetStatus === "COMPLETED") {
            updatePayload.completedAt =
              FieldValue.serverTimestamp();
            updatePayload.paymentStatus = "PENDING";
            updatePayload.paymentPendingAt =
              FieldValue.serverTimestamp();
            updatePayload.paymentPaidAt = FieldValue.delete();
            updatePayload.paymentFailedAt = FieldValue.delete();
          }

          enforceTripUpdatePayload({
            payload: updatePayload,
            context: "transitionTripState",
          });
          transaction.update(tripRef, updatePayload);

          const eventPayload = buildTripEventPayload({
            fromStatus: currentStatus,
            toStatus: targetStatus,
            actorId: requesterId,
            eventType: "state_transition",
            metadata: {
              reason: typeof data?.reason === "string" ? data.reason : null,
              assignedDriverId:
                typeof data?.assignedDriverId === "string"
                  ? data.assignedDriverId
                  : null,
              assignmentAttempt:
                typeof data?.assignmentAttempt === "number"
                  ? data.assignmentAttempt
                  : null,
            },
          });
          enforceTripEventPayload({
            payload: eventPayload,
            context: "transitionTripState",
          });
          transaction.set(eventRef, eventPayload);

          const auditPayload = buildAuditPayload({
            actionType: "trip_state_transition",
            actorId: requesterId,
            actorEmail: requesterEmail,
            subject: tripId,
            reason: "Transição de estado da viagem",
            before: { status: currentStatus },
            after: { status: targetStatus },
          });
          transaction.set(auditRef, auditPayload);
          return { tripId, status: targetStatus };
        },
      });

      logger.info("Trip transition executed.", {
        tripId,
        targetStatus,
        requesterId,
      });
      return response.response;
    },
  );

  const cancelTrip = onCall(
    CRITICAL_CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);
      const requesterEmail = await resolveAuditActorEmail({
        auth,
        authToken: request.auth?.token ?? null,
        actorId: requesterId,
        context: "cancelTrip",
      });
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      const isAdmin = callerRole === "admin";
      const isManager = callerRole === "manager";

      const data = request.data as Record<string, unknown> | null;
      const tripId = parseTripId(data);
      const actor = data?.actor?.toString().trim().toLowerCase();
      const type = data?.type?.toString().trim().toLowerCase();
      if (!actor || !type) {
        throw new HttpsError(
          "invalid-argument",
          "Parâmetros de cancelamento inválidos.",
        );
      }
      const isSupportCancellation =
        actor === "support" || type === "support_cancel";
      const isNoShowCancellation = type === "no_show" || type === "noshow";
      const isDriverCancellation = actor === "driver" || type === "driver";

      const targetStatus = isNoShowCancellation
        ? "NO_SHOW"
        : isDriverCancellation
          ? "CANCELLED_BY_DRIVER"
          : "CANCELLED_BY_CLIENT";
      const resolvedActor = isSupportCancellation ? "support" : actor;
      const resolvedType = isSupportCancellation ? "support_cancel" : type;
      if (data?.feeMinor != null) {
        throw new HttpsError(
          "invalid-argument",
          "Parâmetro feeMinor não suportado. Use fee.",
        );
      }
      const resolvedFee = isSupportCancellation
        ? {
            amountMinor: 0,
            currency: OPERATION_CURRENCY_CODE,
          }
        : parseRequiredMoneyPayload(data?.fee, "fee");
      assertOperationCurrency(resolvedFee, "fee");
      if (resolvedFee.amountMinor < 0) {
        throw new HttpsError("invalid-argument", "fee.amountMinor inválido.");
      }

      const tripRef = firestore.doc(`trips/${tripId}`);
      const rawReason =
        typeof data?.reason === "string" ? data.reason.trim() : "";
      if (isManager && !isSupportCancellation) {
        throw new HttpsError("permission-denied", "Permissões insuficientes.");
      }
      if (isSupportCancellation && !isManager && !isAdmin) {
        throw new HttpsError("permission-denied", "Permissões insuficientes.");
      }
      if (isSupportCancellation) {
        assertManagerPermission({
          role: callerRole,
          authToken: request.auth?.token ?? null,
          permission: "cs",
          context: "cancelTrip",
        });
      }
      if (isSupportCancellation && rawReason.length === 0) {
        throw new HttpsError(
          "invalid-argument",
          "Motivo obrigatório para cancelamento por suporte.",
        );
      }

      const response = await runIdempotentTripCallable({
        data,
        tripId,
        action: `trip_cancel_${targetStatus.toLowerCase()}`,
        requesterId,
        execute: async (transaction) => {
          const eventRef = firestore
            .collection("tripEvents")
            .doc(tripId)
            .collection("events")
            .doc();
          const auditRef = firestore.collection("audit").doc();
          const tripSnapshot = await transaction.get(tripRef);
          const tripData = tripSnapshot.data();
          if (!tripData) {
            throw new HttpsError("not-found", "Viagem não encontrada.");
          }

          const currentStatus = normalizeTripStatus(tripData.status);
          if (isSupportCancellation) {
            assertSupportCancellationAllowed(currentStatus);
          }
          assertTransitionAllowed(currentStatus, targetStatus, "cancelTrip");

          const clientId = tripData.clientId?.toString();
          const assignedDriverId = tripData.assignedDriverId?.toString();
          const actorMatchesUser =
            (resolvedActor === "client" && requesterId === clientId) ||
            (resolvedActor === "driver" && requesterId === assignedDriverId);
          if (!isSupportCancellation && !actorMatchesUser && !isAdmin) {
            throw new HttpsError(
              "permission-denied",
              "Permissões insuficientes.",
            );
          }

          const cancellationReason =
            rawReason.length > 0 ? rawReason : "Cancelamento solicitado";

          const updatePayload = {
            status: targetStatus,
            statusEnteredAt: FieldValue.serverTimestamp(),
            cancelledAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
            cancellation: {
              actor: resolvedActor,
              type: resolvedType,
              fee: resolvedFee,
              reason: cancellationReason,
            },
          };
          enforceTripUpdatePayload({
            payload: updatePayload,
            context: "cancelTrip",
          });
          transaction.update(tripRef, updatePayload);

          const eventPayload = buildTripEventPayload({
            fromStatus: currentStatus,
            toStatus: targetStatus,
            actorId: requesterId,
            eventType: "state_transition",
          });
          enforceTripEventPayload({
            payload: eventPayload,
            context: "cancelTrip",
          });
          transaction.set(eventRef, eventPayload);

          const auditPayload = buildAuditPayload({
            actionType: "trip_cancel",
            actorId: requesterId,
            actorEmail: requesterEmail,
            subject: tripId,
            reason: cancellationReason,
            before: { status: currentStatus },
            after: {
              status: targetStatus,
              actor: resolvedActor,
              type: resolvedType,
              fee: resolvedFee,
            },
          });
          transaction.set(auditRef, auditPayload);
          return { tripId, status: targetStatus };
        },
      });

      logger.info("Trip cancelled.", {
        tripId,
        requesterId,
        actor: resolvedActor,
        type: resolvedType,
      });
      return response.response;
    },
  );

  const requestTripExtension = onCall(
    STANDARD_CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);
      const requesterEmail = await resolveAuditActorEmail({
        auth,
        authToken: request.auth?.token ?? null,
        actorId: requesterId,
        context: "requestTripExtension",
      });

      const data = request.data as Record<string, unknown> | null;
      const tripId = parseTripId(data);
      const tripRef = firestore.doc(`trips/${tripId}`);

      const response = await runIdempotentTripCallable({
        data,
        tripId,
        action: "trip_extension_request",
        requesterId,
        execute: async (transaction) => {
          const eventRef = firestore
            .collection("tripEvents")
            .doc(tripId)
            .collection("events")
            .doc();
          const auditRef = firestore.collection("audit").doc();
          const tripSnapshot = await transaction.get(tripRef);
          const tripData = tripSnapshot.data();
          if (!tripData) {
            throw new HttpsError("not-found", "Viagem não encontrada.");
          }

          const status = normalizeTripStatus(tripData.status);
          if (
            status !== "ARRIVED_DESTINATION" &&
            status !== "EXTENSION_WINDOW"
          ) {
            throw new HttpsError(
              "failed-precondition",
              "Estado atual não permite pedir extensão.",
            );
          }

          const clientId = tripData.clientId?.toString();
          if (requesterId !== clientId) {
            throw new HttpsError(
              "permission-denied",
              "Permissões insuficientes.",
            );
          }

          const updatePayload = {
            extensionRequestStatus: "requested",
            extensionRequestedAt: FieldValue.serverTimestamp(),
            extensionRespondedAt: FieldValue.delete(),
            updatedAt: FieldValue.serverTimestamp(),
          };
          enforceTripUpdatePayload({
            payload: updatePayload,
            context: "requestTripExtension",
          });
          transaction.update(tripRef, updatePayload);

          const eventPayload = buildTripEventPayload({
            fromStatus: status,
            toStatus: status,
            actorId: requesterId,
            eventType: "extension_requested",
          });
          enforceTripEventPayload({
            payload: eventPayload,
            context: "requestTripExtension",
          });
          transaction.set(eventRef, eventPayload);

          const auditPayload = buildAuditPayload({
            actionType: "trip_extension_request",
            actorId: requesterId,
            actorEmail: requesterEmail,
            subject: tripId,
            reason: "Pedido de extensão",
          });
          transaction.set(auditRef, auditPayload);
          return { tripId, extensionRequestStatus: "requested" };
        },
      });

      return response.response;
    },
  );

  const respondTripExtension = onCall(
    STANDARD_CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);
      const requesterEmail = await resolveAuditActorEmail({
        auth,
        authToken: request.auth?.token ?? null,
        actorId: requesterId,
        context: "respondTripExtension",
      });

      const data = request.data as Record<string, unknown> | null;
      const tripId = parseTripId(data);
      const isAccepted = data?.isAccepted === true;
      const tripRef = firestore.doc(`trips/${tripId}`);

      const response = await runIdempotentTripCallable({
        data,
        tripId,
        action: `trip_extension_respond_${isAccepted ? "accepted" : "declined"}`,
        requesterId,
        execute: async (transaction) => {
          const eventRef = firestore
            .collection("tripEvents")
            .doc(tripId)
            .collection("events")
            .doc();
          const auditRef = firestore.collection("audit").doc();
          const tripSnapshot = await transaction.get(tripRef);
          const tripData = tripSnapshot.data();
          if (!tripData) {
            throw new HttpsError("not-found", "Viagem não encontrada.");
          }

          const status = normalizeTripStatus(tripData.status);
          if (
            status !== "EXTENSION_WINDOW" &&
            status !== "ARRIVED_DESTINATION"
          ) {
            throw new HttpsError(
              "failed-precondition",
              "Estado atual não permite responder extensão.",
            );
          }

          const assignedDriverId = tripData.assignedDriverId?.toString();
          if (requesterId !== assignedDriverId) {
            throw new HttpsError(
              "permission-denied",
              "Permissões insuficientes.",
            );
          }

          const extensionRequestStatus = tripData.extensionRequestStatus
            ?.toString()
            ?.toLowerCase();
          if (extensionRequestStatus !== "requested") {
            throw new HttpsError(
              "failed-precondition",
              "Não existe pedido de extensão pendente.",
            );
          }

          const resolvedStatus = isAccepted ? "accepted" : "declined";
          const updatePayload = {
            extensionRequestStatus: resolvedStatus,
            extensionRespondedAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
          };
          enforceTripUpdatePayload({
            payload: updatePayload,
            context: "respondTripExtension",
          });
          transaction.update(tripRef, updatePayload);

          const eventPayload = buildTripEventPayload({
            fromStatus: status,
            toStatus: status,
            actorId: requesterId,
            eventType: isAccepted ? "extension_accepted" : "extension_declined",
          });
          enforceTripEventPayload({
            payload: eventPayload,
            context: "respondTripExtension",
          });
          transaction.set(eventRef, eventPayload);

          const auditPayload = buildAuditPayload({
            actionType: "trip_extension_response",
            actorId: requesterId,
            actorEmail: requesterEmail,
            subject: tripId,
            reason: isAccepted ? "Extensão aceite" : "Extensão rejeitada",
          });
          transaction.set(auditRef, auditPayload);
          return { tripId, isAccepted };
        },
      });

      return response.response;
    },
  );

  const handleTripFinancialAction = onCall(
    STANDARD_CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);
      const requesterEmail = await resolveAuditActorEmail({
        auth,
        authToken: request.auth?.token ?? null,
        actorId: requesterId,
        context: "handleTripFinancialAction",
      });
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });

      const data = request.data as Record<string, unknown> | null;
      const tripId = parseTripId(data);
      const action = data?.action?.toString();
      if (!action) {
        throw new HttpsError("invalid-argument", "Ação financeira inválida.");
      }

      if (action === "retry_payment") {
        const retryIdempotencyKey = resolveTripCallableIdempotencyKey({
          tripId,
          action: "trip_retry_payment",
          requesterId,
          eventId: parseOptionalEventId(data),
          providedKey: parseOptionalIdempotencyKey(data),
        });
        const retryIdempotencyRef = firestore.doc(
          buildTripCallableIdempotencyPath(tripId, retryIdempotencyKey),
        );
        const retrySnapshot = await retryIdempotencyRef.get();
        const retryData = retrySnapshot.data();
        if (retrySnapshot.exists && retryData?.response != null) {
          logger.debug("Trip callable idempotency hit.", {
            action: "trip_retry_payment",
            tripId,
            requesterId,
            idempotencyKey: retryIdempotencyKey,
          });
          return retryData.response as { tripId: string; status: string };
        }

        const tripSnapshot = await firestore.doc(`trips/${tripId}`).get();
        const tripData = tripSnapshot.data();
        if (!tripData) {
          throw new HttpsError("not-found", "Viagem não encontrada.");
        }
        const clientId = tripData.clientId?.toString();
        if (!clientId) {
          throw new HttpsError(
            "failed-precondition",
            "Viagem sem cliente associado.",
          );
        }
        if (requesterId !== clientId) {
          if (callerRole !== "admin") {
            throw new HttpsError(
              "permission-denied",
              "Permissões insuficientes.",
            );
          }
        }
        await finalizeTripPayment({ tripId, clientId, reason: "manual" });
        const auditPayload = buildAuditPayload({
          actionType: "trip_payment_retry",
          actorId: requesterId,
          actorEmail: requesterEmail,
          subject: tripId,
          reason: "Reprocessamento manual de pagamento",
        });
        await firestore
          .collection("audit")
          .doc(`trip_payment_retry_${tripId}_${retryIdempotencyKey}`)
          .set(auditPayload, { merge: true });
        const response = { tripId, status: "submitted" };
        await retryIdempotencyRef.set(
          {
            action: "trip_retry_payment",
            requesterId,
            idempotencyKey: retryIdempotencyKey,
            response,
            createdAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
        logger.debug("Trip callable idempotency miss.", {
          action: "trip_retry_payment",
          tripId,
          requesterId,
          idempotencyKey: retryIdempotencyKey,
        });
        return response;
      }

      const tripRef = firestore.doc(`trips/${tripId}`);
      const response = await runIdempotentTripCallable({
        data,
        tripId,
        action: `trip_financial_${action}`,
        requesterId,
        execute: async (transaction) => {
          const eventRef = firestore
            .collection("tripEvents")
            .doc(tripId)
            .collection("events")
            .doc();
          const auditRef = firestore.collection("audit").doc();
          const tripSnapshot = await transaction.get(tripRef);
          const tripData = tripSnapshot.data();
          if (!tripData) {
            throw new HttpsError("not-found", "Viagem não encontrada.");
          }

          const currentSurcharge =
            tripData.manualSurcharge &&
            typeof tripData.manualSurcharge === "object"
              ? (tripData.manualSurcharge as Record<string, unknown>)
              : {};
          const currentSurchargeAmount = parseStoredMoneyPayload(
            currentSurcharge.amount,
          ) ?? {
            amountMinor: 0,
            currency: OPERATION_CURRENCY_CODE,
          };
          const currentStatus =
            currentSurcharge.status?.toString()?.toLowerCase() ?? "none";

          if (action === "propose_surcharge") {
            if (data?.amountMinor != null) {
              throw new HttpsError(
                "invalid-argument",
                "Parâmetro amountMinor não suportado. Use amount.",
              );
            }
            const amount = parseRequiredMoneyPayload(data?.amount, "amount");
            assertOperationCurrency(amount, "amount");
            const reason =
              typeof data?.reason === "string" ? data.reason.trim() : "";
            if (amount.amountMinor <= 0 || !reason) {
              throw new HttpsError(
                "invalid-argument",
                "Dados de sobretaxa inválidos.",
              );
            }
            const assignedDriverId = tripData.assignedDriverId?.toString();
            if (requesterId !== assignedDriverId) {
              throw new HttpsError(
                "permission-denied",
                "Permissões insuficientes.",
              );
            }
            if (currentStatus === "requested") {
              throw new HttpsError(
                "failed-precondition",
                "Já existe uma sobretaxa pendente.",
              );
            }

            const updatePayload = {
              manualSurcharge: {
                status: "requested",
                amount,
                reason,
                requestedAt: FieldValue.serverTimestamp(),
                respondedAt: FieldValue.delete(),
                requestedBy: requesterId,
                respondedBy: FieldValue.delete(),
              },
              updatedAt: FieldValue.serverTimestamp(),
            };
            enforceTripUpdatePayload({
              payload: updatePayload,
              context: "handleTripFinancialAction.propose",
            });
            transaction.update(tripRef, updatePayload);

            const eventPayload = buildTripEventPayload({
              fromStatus: normalizeTripStatus(tripData.status),
              toStatus: normalizeTripStatus(tripData.status),
              actorId: requesterId,
              eventType: "surcharge_proposed",
              metadata: { amount, reason },
            });
            enforceTripEventPayload({
              payload: eventPayload,
              context: "handleTripFinancialAction.propose",
            });
            transaction.set(eventRef, eventPayload);

            const auditPayload = buildAuditPayload({
              actionType: "trip_surcharge",
              actorId: requesterId,
              actorEmail: requesterEmail,
              subject: tripId,
              reason,
              before: {
                status: currentStatus,
                amount: currentSurchargeAmount,
              },
              after: { status: "requested", amount },
            });
            transaction.set(auditRef, auditPayload);
            return { tripId, action, status: "applied" };
          }

          if (action === "respond_surcharge") {
            const isApproved = data?.isApproved === true;
            const clientId = tripData.clientId?.toString();
            if (requesterId !== clientId) {
              throw new HttpsError(
                "permission-denied",
                "Permissões insuficientes.",
              );
            }
            if (currentStatus !== "requested") {
              throw new HttpsError(
                "failed-precondition",
                "Não existe sobretaxa pendente.",
              );
            }
            const requestedAmount = parseStoredMoneyPayload(
              currentSurcharge.amount,
            );
            if (requestedAmount == null) {
              throw new HttpsError(
                "failed-precondition",
                "Sobretaxa pendente sem montante válido.",
              );
            }
            assertOperationCurrency(requestedAmount, "manualSurcharge.amount");

            const nextStatus = isApproved ? "approved" : "rejected";
            const updatePayload = {
              manualSurcharge: {
                ...currentSurcharge,
                status: nextStatus,
                respondedAt: FieldValue.serverTimestamp(),
                respondedBy: requesterId,
              },
              updatedAt: FieldValue.serverTimestamp(),
            };
            enforceTripUpdatePayload({
              payload: updatePayload,
              context: "handleTripFinancialAction.respond",
            });
            transaction.update(tripRef, updatePayload);

            const eventPayload = buildTripEventPayload({
              fromStatus: normalizeTripStatus(tripData.status),
              toStatus: normalizeTripStatus(tripData.status),
              actorId: requesterId,
              eventType: isApproved
                ? "surcharge_approved"
                : "surcharge_rejected",
              metadata: {
                amount: requestedAmount,
                reason: currentSurcharge.reason ?? null,
                approved: isApproved,
              },
            });
            enforceTripEventPayload({
              payload: eventPayload,
              context: "handleTripFinancialAction.respond",
            });
            transaction.set(eventRef, eventPayload);

            const auditPayload = buildAuditPayload({
              actionType: "trip_surcharge",
              actorId: requesterId,
              actorEmail: requesterEmail,
              subject: tripId,
              reason: isApproved
                ? "Aprovado pelo cliente"
                : "Rejeitado pelo cliente",
              before: {
                status: currentStatus,
                amount: requestedAmount,
              },
              after: {
                status: nextStatus,
                amount: requestedAmount,
              },
            });
            transaction.set(auditRef, auditPayload);
            return { tripId, action, status: "applied" };
          }

          throw new HttpsError("invalid-argument", "Ação financeira inválida.");
        },
      });

      return response.response;
    },
  );

  return {
    transitionTripState,
    cancelTrip,
    requestTripExtension,
    respondTripExtension,
    handleTripFinancialAction,
  };
}
