import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import {
  CRITICAL_CALLABLE_RUNTIME_OPTIONS,
  INACTIVE_TRIP_STATUSES,
} from "../shared/constants";
import {
  requireAuthenticatedUid,
  resolveCallerRole,
} from "../shared/auth/rbacRoleResolver";
import {
  assertManagerPermission,
} from "../shared/auth/managerPermissionClaims";
import {
  dispatchNotificationToTargets,
  fetchNotificationTargetsByRoles,
  fetchNotificationTargetsByUserIds,
} from "../shared/notifications/fcmFanout";

const MAX_CHAT_MESSAGE_LENGTH = 1000;
const TRIP_CHAT_OPEN_STATUSES = new Set<string>([
  "DRIVER_ACCEPTED",
  "DRIVER_EN_ROUTE",
  "DRIVER_ARRIVED",
  "IN_TRIP",
  "ARRIVED_DESTINATION",
  "EXTENSION_WINDOW",
]);

type ChatFunctions = {
  sendSupportChatMessage: ReturnType<typeof onCall>;
  sendSupportTicketMessage: ReturnType<typeof onCall>;
  sendTripChatMessage: ReturnType<typeof onCall>;
  closeTripChatOnTripUpdate: ReturnType<typeof onDocumentUpdated>;
};

type ChatThreadStatus = "open" | "closed";
type SenderRole = "client" | "driver" | "admin" | "manager" | "ops";

type SendMessageResult = {
  ok: true;
  threadId: string;
  messageId: string;
  duplicated: boolean;
  requestId?: string;
};

export function buildChatFunctions(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
}): ChatFunctions {
  const { firestore, messaging } = params;

  const sendSupportChatMessage = onCall(
    {
      ...CRITICAL_CALLABLE_RUNTIME_OPTIONS,
    },
    async (request) => {
      const requestData = toRecord(request.data);
      const requestBody = requestData?.body;
      logger.info("Support chat send requested.", {
        authUid: request.auth?.uid ?? null,
        authRole: request.auth?.token?.role ?? null,
        appId: request.app?.appId ?? null,
        hasAppCheck: request.app != null,
        clientMessageId: requestData?.clientMessageId ?? null,
        targetClientId: requestData?.clientId ?? null,
        bodyLength: typeof requestBody === "string"
          ? requestBody.trim().length
          : null,
      });
      try {
        const requesterId = requireAuthenticatedUid(request.auth);
        const callerRole = await resolveCallerRole({
          firestore,
          auth: request.auth,
        });
        if (callerRole !== "client" && callerRole !== "admin" && callerRole !== "manager") {
          throw new HttpsError("permission-denied", "Permissões insuficientes.");
        }
        if (callerRole === "manager") {
          assertManagerPermission({
            role: callerRole,
            authToken: request.auth?.token ?? null,
            permission: "ch",
            context: "sendSupportChatMessage",
          });
        }

        const payload = parseMessagePayload(request.data);
        const clientId = callerRole === "client" ? requesterId : resolveTargetClientId(payload);
        const threadId = buildSupportThreadId(clientId);
        const senderProfile = await resolveSenderProfile({
          firestore,
          userId: requesterId,
          callerRole,
        });
        const result = await runChatMessageIdempotent({
          firestore,
          threadId,
          clientMessageId: payload.clientMessageId,
          execute: async (transaction) => {
            const threadRef = firestore.doc(`chatThreads/${threadId}`);
            const messageRef = threadRef.collection("chatMessages").doc();
            const threadSnapshot = await transaction.get(threadRef);
            const createdAtValue = FieldValue.serverTimestamp();
            const summaryText = summarizeMessage(payload.body);
            const createdAt = threadSnapshot.data()?.createdAt ?? createdAtValue;
            transaction.set(
              messageRef,
              {
                threadId,
                senderUserId: requesterId,
                senderRole: senderProfile.senderRole,
                senderDisplayName: senderProfile.displayName,
                body: payload.body,
                createdAt: createdAtValue,
                clientMessageId: payload.clientMessageId,
              },
            );
            transaction.set(
              threadRef,
              {
                type: "support_client_ops",
                status: "open",
                clientId,
                createdAt,
                updatedAt: createdAtValue,
                lastMessageAt: createdAtValue,
                lastMessageText: summaryText,
                lastSenderUserId: requesterId,
                lastSenderRole: senderProfile.senderRole,
                needsOpsAttention: senderProfile.senderRole === "client",
              },
              { merge: true },
            );
            return {
              ok: true,
              threadId,
              messageId: messageRef.id,
            };
          },
        });

        if (!result.duplicated) {
          await notifySupportThreadParticipants({
            firestore,
            messaging,
            actorId: requesterId,
            body: payload.body,
            threadId,
            clientId,
          });
        }
        logger.info("Support chat message stored.", {
          requesterId,
          callerRole,
          threadId,
          clientId,
          duplicated: result.duplicated,
          messageId: result.response.messageId,
        });
        return result.response;
      } catch (error) {
        logger.error("Support chat send failed.", {
          authUid: request.auth?.uid ?? null,
          authRole: request.auth?.token?.role ?? null,
          appId: request.app?.appId ?? null,
          hasAppCheck: request.app != null,
          errorMessage: error instanceof Error ? error.message : String(error),
          errorCode: error instanceof HttpsError ? error.code : null,
        });
        throw error;
      }
    },
  );

  const sendTripChatMessage = onCall(
    {
      ...CRITICAL_CALLABLE_RUNTIME_OPTIONS,
    },
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      if (callerRole !== "client" && callerRole !== "driver") {
        throw new HttpsError("permission-denied", "Permissões insuficientes.");
      }
      const payload = parseTripMessagePayload(request.data);
      const tripRef = firestore.doc(`trips/${payload.tripId}`);
      const tripSnapshot = await tripRef.get();
      if (!tripSnapshot.exists) {
        throw new HttpsError("not-found", "Viagem não encontrada.");
      }
      const trip = tripSnapshot.data() ?? {};
      const tripStatus = normalizeTripStatus(trip.status);
      if (!TRIP_CHAT_OPEN_STATUSES.has(tripStatus)) {
        throw new HttpsError("failed-precondition", "Chat da viagem indisponível.");
      }
      const clientId = readNonEmptyString(trip.clientId, "clientId");
      const driverId = readNonEmptyString(trip.assignedDriverId, "assignedDriverId");
      if (callerRole === "client" && clientId !== requesterId) {
        throw new HttpsError("permission-denied", "Permissões insuficientes.");
      }
      if (callerRole === "driver" && driverId !== requesterId) {
        throw new HttpsError("permission-denied", "Permissões insuficientes.");
      }

      const threadId = buildTripThreadId(payload.tripId);
      const senderProfile = await resolveSenderProfile({
        firestore,
        userId: requesterId,
        callerRole,
      });
      const result = await runChatMessageIdempotent({
        firestore,
        threadId,
        clientMessageId: payload.clientMessageId,
        execute: async (transaction) => {
          const threadRef = firestore.doc(`chatThreads/${threadId}`);
          const threadSnapshot = await transaction.get(threadRef);
          const existingStatus = normalizeThreadStatus(threadSnapshot.data()?.status);
          if (existingStatus === "closed") {
            throw new HttpsError("failed-precondition", "Chat da viagem fechado.");
          }
          const messageRef = threadRef.collection("chatMessages").doc();
          const createdAtValue = FieldValue.serverTimestamp();
          const summaryText = summarizeMessage(payload.body);
          const createdAt = threadSnapshot.data()?.createdAt ?? createdAtValue;
          transaction.set(
            messageRef,
            {
              threadId,
              senderUserId: requesterId,
              senderRole: senderProfile.senderRole,
              senderDisplayName: senderProfile.displayName,
              body: payload.body,
              createdAt: createdAtValue,
              clientMessageId: payload.clientMessageId,
            },
          );
          transaction.set(
            threadRef,
            {
              type: "trip_client_driver",
              status: "open",
              clientId,
              tripId: payload.tripId,
              driverId,
              createdAt,
              updatedAt: createdAtValue,
              lastMessageAt: createdAtValue,
              lastMessageText: summaryText,
              lastSenderUserId: requesterId,
              lastSenderRole: senderProfile.senderRole,
              needsOpsAttention: true,
            },
            { merge: true },
          );
          return {
            ok: true,
            threadId,
            messageId: messageRef.id,
          };
        },
      });

      if (!result.duplicated) {
        await notifyTripThreadParticipants({
          firestore,
          messaging,
          actorId: requesterId,
          body: payload.body,
          threadId,
          tripId: payload.tripId,
          clientId,
          driverId,
        });
      }
      return result.response;
    },
  );

  const sendSupportTicketMessage = onCall(
    {
      ...CRITICAL_CALLABLE_RUNTIME_OPTIONS,
    },
    async (request) => {
      const requestData = toRecord(request.data);
      logger.info("Support ticket chat send requested.", {
        authUid: request.auth?.uid ?? null,
        authRole: request.auth?.token?.role ?? null,
        appId: request.app?.appId ?? null,
        hasAppCheck: request.app != null,
        requestId: requestData.requestId ?? null,
        tripId: requestData.tripId ?? null,
        clientMessageId: requestData.clientMessageId ?? null,
      });
      try {
        const requesterId = requireAuthenticatedUid(request.auth);
        const callerRole = await resolveCallerRole({
          firestore,
          auth: request.auth,
        });
        if (callerRole !== "client" && callerRole !== "admin" && callerRole !== "manager") {
          throw new HttpsError("permission-denied", "Permissões insuficientes.");
        }
        if (callerRole === "manager") {
          assertManagerPermission({
            role: callerRole,
            authToken: request.auth?.token ?? null,
            permission: "vs",
            context: "sendSupportTicketMessage",
          });
        }

        const payload = parseSupportTicketMessagePayload(request.data);
        const ticketContext = callerRole === "client" ?
          await resolveClientSupportTicketContext({
            firestore,
            clientId: requesterId,
            requestId: payload.requestId,
            tripId: payload.tripId,
          }) :
          await resolveOpsSupportTicketContext({
            firestore,
            requestId: payload.requestId,
          });
        const senderProfile = await resolveSenderProfile({
          firestore,
          userId: requesterId,
          callerRole,
        });
        const result = await runChatMessageIdempotent({
          firestore,
          threadId: ticketContext.threadId,
          clientMessageId: payload.clientMessageId,
          execute: async (transaction) => {
            const supportRequestRef = firestore.doc(`supportRequests/${ticketContext.requestId}`);
            const threadRef = firestore.doc(`chatThreads/${ticketContext.threadId}`);
            const threadSnapshot = await transaction.get(threadRef);
            const messageRef = threadRef.collection("chatMessages").doc();
            const createdAtValue = FieldValue.serverTimestamp();
            const summaryText = summarizeMessage(payload.body);
            const createdAt = threadSnapshot.data()?.createdAt ?? createdAtValue;
            transaction.set(
              supportRequestRef,
              {
                ...ticketContext.requestWrite,
                chatThreadId: ticketContext.threadId,
                status: "open",
                updatedAt: createdAtValue,
              },
              { merge: true },
            );
            transaction.set(
              messageRef,
              {
                threadId: ticketContext.threadId,
                senderUserId: requesterId,
                senderRole: senderProfile.senderRole,
                senderDisplayName: senderProfile.displayName,
                body: payload.body,
                createdAt: createdAtValue,
                clientMessageId: payload.clientMessageId,
              },
            );
            transaction.set(
              threadRef,
              {
                type: "support_client_ops",
                status: "open",
                clientId: ticketContext.clientId,
                tripId: ticketContext.tripId ?? FieldValue.delete(),
                supportRequestId: ticketContext.requestId,
                createdAt,
                updatedAt: createdAtValue,
                lastMessageAt: createdAtValue,
                lastMessageText: summaryText,
                lastSenderUserId: requesterId,
                lastSenderRole: senderProfile.senderRole,
                needsOpsAttention: senderProfile.senderRole === "client",
              },
              { merge: true },
            );
            return {
              ok: true,
              threadId: ticketContext.threadId,
              messageId: messageRef.id,
              requestId: ticketContext.requestId,
            };
          },
        });

        if (!result.duplicated) {
          if (ticketContext.isNewTicket) {
            await notifyOpsSupportTicketCreated({
              firestore,
              messaging,
              requestId: ticketContext.requestId,
              threadId: ticketContext.threadId,
              tripId: ticketContext.tripId,
              displayName: ticketContext.displayName,
              email: ticketContext.email,
            });
          }
          await notifySupportThreadParticipants({
            firestore,
            messaging,
            actorId: requesterId,
            body: payload.body,
            threadId: ticketContext.threadId,
            clientId: ticketContext.clientId,
            requestId: ticketContext.requestId,
            tripId: ticketContext.tripId,
            suppressOpsNotification: ticketContext.isNewTicket,
          });
        }
        logger.info("Support ticket chat message stored.", {
          requesterId,
          callerRole,
          requestId: ticketContext.requestId,
          threadId: ticketContext.threadId,
          duplicated: result.duplicated,
        });
        return {
          ...result.response,
          requestId: ticketContext.requestId,
        };
      } catch (error) {
        logger.error("Support ticket chat send failed.", {
          authUid: request.auth?.uid ?? null,
          authRole: request.auth?.token?.role ?? null,
          appId: request.app?.appId ?? null,
          hasAppCheck: request.app != null,
          errorMessage: error instanceof Error ? error.message : String(error),
          errorCode: error instanceof HttpsError ? error.code : null,
        });
        throw error;
      }
    },
  );

  const closeTripChatOnTripUpdate = onDocumentUpdated(
    {
      region: "europe-southwest1",
      document: "trips/{tripId}",
    },
    async (event) => {
      const before = event.data?.before.data();
      const after = event.data?.after.data();
      if (!after) {
        return;
      }
      const beforeStatus = normalizeTripStatus(before?.status);
      const tripStatus = normalizeTripStatus(after.status);
      if (beforeStatus === tripStatus) {
        logger.info("cost_profile", {
          functionName: "closeTripChatOnTripUpdate",
          operation: "trigger_skipped_diff_guard",
          tripId: event.params.tripId,
        });
        return;
      }
      if (!INACTIVE_TRIP_STATUSES.has(tripStatus)) {
        return;
      }
      const tripId = event.params.tripId;
      const threadRef = firestore.doc(`chatThreads/${buildTripThreadId(tripId)}`);
      const snapshot = await threadRef.get();
      if (!snapshot.exists) {
        return;
      }
      const currentStatus = normalizeThreadStatus(snapshot.data()?.status);
      if (currentStatus === "closed") {
        return;
      }
      logger.info("Closing trip chat thread after trip finalization.", {
        tripId,
        tripStatus,
      });
      await threadRef.set(
        {
          status: "closed",
          updatedAt: FieldValue.serverTimestamp(),
          needsOpsAttention: false,
        },
        { merge: true },
      );
    },
  );

  return {
    sendSupportChatMessage,
    sendSupportTicketMessage,
    sendTripChatMessage,
    closeTripChatOnTripUpdate,
  };
}

function parseMessagePayload(data: unknown): {
  body: string;
  clientMessageId: string;
  clientId?: string;
} {
  const record = toRecord(data);
  const body = requireMessageBody(record?.body);
  const clientMessageId = requireClientMessageId(record?.clientMessageId);
  const clientId = typeof record?.clientId === "string" && record.clientId.trim() ?
    record.clientId.trim() :
    undefined;
  return {
    body,
    clientMessageId,
    clientId,
  };
}

function parseTripMessagePayload(data: unknown): {
  tripId: string;
  body: string;
  clientMessageId: string;
} {
  const record = toRecord(data);
  const tripId = readNonEmptyString(record?.tripId, "tripId");
  const body = requireMessageBody(record?.body);
  const clientMessageId = requireClientMessageId(record?.clientMessageId);
  return {
    tripId,
    body,
    clientMessageId,
  };
}

function parseSupportTicketMessagePayload(data: unknown): {
  requestId?: string;
  tripId?: string;
  body: string;
  clientMessageId: string;
} {
  const record = toRecord(data);
  const requestId = typeof record.requestId === "string" && record.requestId.trim() ?
    record.requestId.trim() :
    undefined;
  const tripId = typeof record.tripId === "string" && record.tripId.trim() ?
    record.tripId.trim() :
    undefined;
  const body = requireMessageBody(record.body);
  const clientMessageId = requireClientMessageId(record.clientMessageId);
  if (!requestId && !tripId) {
    throw new HttpsError("invalid-argument", "Ticket ou viagem obrigatória.");
  }
  return {
    requestId,
    tripId,
    body,
    clientMessageId,
  };
}

async function resolveClientSupportTicketContext(params: {
  firestore: admin.firestore.Firestore;
  clientId: string;
  requestId?: string;
  tripId?: string;
}): Promise<SupportTicketMessageContext> {
  const { firestore, clientId, requestId, tripId } = params;
  if (requestId) {
    const snapshot = await firestore.doc(`supportRequests/${requestId}`).get();
    if (!snapshot.exists) {
      throw new HttpsError("not-found", "Ticket de suporte não encontrado.");
    }
    const data = snapshot.data() ?? {};
    if (readOptionalString(data.userId) !== clientId) {
      throw new HttpsError("permission-denied", "Permissões insuficientes.");
    }
    return supportTicketContextFromSnapshot({
      requestId,
      data,
      fallbackClientId: clientId,
    });
  }
  if (!tripId) {
    throw new HttpsError("invalid-argument", "Viagem obrigatória.");
  }
  const tripSnapshot = await firestore.doc(`trips/${tripId}`).get();
  if (!tripSnapshot.exists) {
    throw new HttpsError("not-found", "Viagem não encontrada.");
  }
  const trip = tripSnapshot.data() ?? {};
  const tripStatus = normalizeTripStatus(trip.status);
  if (!TRIP_CHAT_OPEN_STATUSES.has(tripStatus)) {
    throw new HttpsError("failed-precondition", "Suporte da viagem indisponível.");
  }
  if (readNonEmptyString(trip.clientId, "clientId") !== clientId) {
    throw new HttpsError("permission-denied", "Permissões insuficientes.");
  }
  const existing = await firestore
    .collection("supportRequests")
    .where("userId", "==", clientId)
    .where("tripId", "==", tripId)
    .where("status", "==", "open")
    .limit(1)
    .get();
  const existingDoc = existing.docs[0] ?? null;
  const supportRequestRef = existingDoc?.ref ?? firestore.collection("supportRequests").doc();
  const userSnapshot = await firestore.doc(`users/${clientId}`).get();
  const user = userSnapshot.data() ?? {};
  const displayName = readOptionalString(user.name) ?? null;
  const email = readOptionalString(user.email) ?? null;
  const isNewTicket = existingDoc == null;
  const requestIdValue = supportRequestRef.id;
  const threadId = buildSupportRequestThreadId(requestIdValue);
  return {
    requestId: requestIdValue,
    threadId,
    clientId,
    tripId,
    isNewTicket,
    displayName,
    email,
    requestWrite: {
      type: "active_trip",
      sourceType: "active_trip",
      subject: "Suporte durante a viagem",
      message: "Conversa de suporte aberta durante uma viagem ativa.",
      userId: clientId,
      role: readOptionalString(user.role) ?? "client",
      displayName,
      email,
      requestedAt: isNewTicket ?
        FieldValue.serverTimestamp() :
        existingDoc.data().requestedAt ?? FieldValue.serverTimestamp(),
      requestedBy: "active_trip_support",
      tripId,
      tripSnapshot: buildSupportTripSnapshot(trip, tripStatus),
      resolvedAt: FieldValue.delete(),
      resolvedBy: FieldValue.delete(),
    },
  };
}

async function resolveOpsSupportTicketContext(params: {
  firestore: admin.firestore.Firestore;
  requestId?: string;
}): Promise<SupportTicketMessageContext> {
  if (!params.requestId) {
    throw new HttpsError("invalid-argument", "Ticket de suporte obrigatório.");
  }
  const snapshot = await params.firestore.doc(`supportRequests/${params.requestId}`).get();
  if (!snapshot.exists) {
    throw new HttpsError("not-found", "Ticket de suporte não encontrado.");
  }
  return supportTicketContextFromSnapshot({
    requestId: params.requestId,
    data: snapshot.data() ?? {},
  });
}

type SupportTicketMessageContext = {
  requestId: string;
  threadId: string;
  clientId: string;
  tripId?: string;
  isNewTicket: boolean;
  displayName: string | null;
  email: string | null;
  requestWrite: Record<string, unknown>;
};

function supportTicketContextFromSnapshot(params: {
  requestId: string;
  data: admin.firestore.DocumentData;
  fallbackClientId?: string;
}): SupportTicketMessageContext {
  const clientId = readOptionalString(params.data.userId) ?? params.fallbackClientId;
  if (!clientId) {
    throw new HttpsError("failed-precondition", "Ticket sem cliente associado.");
  }
  const threadId = readOptionalString(params.data.chatThreadId) ??
    buildSupportRequestThreadId(params.requestId);
  return {
    requestId: params.requestId,
    threadId,
    clientId,
    tripId: readOptionalString(params.data.tripId),
    isNewTicket: false,
    displayName: readOptionalString(params.data.displayName) ?? null,
    email: readOptionalString(params.data.email) ?? null,
    requestWrite: {},
  };
}

async function notifySupportThreadParticipants(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
  actorId: string;
  body: string;
  threadId: string;
  clientId: string;
  requestId?: string;
  tripId?: string;
  suppressOpsNotification?: boolean;
}): Promise<void> {
  const {
    firestore,
    messaging,
    actorId,
    body,
    threadId,
    clientId,
    requestId,
    tripId,
    suppressOpsNotification,
  } = params;
  const targetUserIds = clientId === actorId ? [] : [clientId];
  const directTargets = await fetchNotificationTargetsByUserIds({
    firestore,
    userIds: targetUserIds,
  });
  if (directTargets.length > 0) {
    await dispatchNotificationToTargets({
      firestore,
      messaging,
      targets: directTargets,
      context: "client.support_chat_message",
      message: {
        notification: {
          title: "Nova mensagem de suporte",
          body: summarizeMessage(body),
        },
        data: {
          type: "client.support_chat_message",
          threadId,
          ...(requestId ? { requestId } : {}),
          ...(tripId ? { tripId } : {}),
        },
      },
    });
  }

  const opsTargets = suppressOpsNotification ? [] :
    (await fetchOpsSupportTargets({ firestore }))
    .filter((target) => target.userId !== actorId);
  if (opsTargets.length > 0) {
    await dispatchNotificationToTargets({
      firestore,
      messaging,
      targets: opsTargets,
      context: "ops.chat_message",
      message: {
        notification: {
          title: "Nova mensagem no suporte",
          body: summarizeMessage(body),
        },
        data: {
          type: "ops.chat_message",
          threadId,
          ...(requestId ? { requestId } : {}),
          ...(tripId ? { tripId } : {}),
        },
      },
    });
  }
}

async function notifyOpsSupportTicketCreated(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
  requestId: string;
  threadId: string;
  tripId?: string;
  displayName: string | null;
  email: string | null;
}): Promise<void> {
  const {
    firestore,
    messaging,
    requestId,
    threadId,
    tripId,
    displayName,
    email,
  } = params;
  const targets = await fetchOpsSupportTargets({ firestore });
  if (targets.length === 0) {
    logger.warn("Support ticket notification skipped: no ops targets.", {
      requestId,
      threadId,
      tripId: tripId ?? null,
    });
    return;
  }

  const label = displayName ?? email ?? "Cliente";
  const dispatchStats = await dispatchNotificationToTargets({
    firestore,
    messaging,
    targets,
    message: {
      notification: {
        title: "Novo ticket de suporte",
        body: `${label} abriu um pedido de suporte.`,
      },
      data: {
        type: "ops.support_ticket",
        requestId,
        threadId,
        ...(tripId ? { tripId } : {}),
      },
    },
    context: "support_ticket",
  });
  logger.info("Support ticket notification dispatched.", {
    requestId,
    threadId,
    tripId: tripId ?? null,
    notificationTargets: dispatchStats.targetUsers,
    tokenCount: dispatchStats.tokenCount,
    successCount: dispatchStats.successCount,
    failureCount: dispatchStats.failureCount,
    invalidTokenRemovals: dispatchStats.invalidTokenRemovals,
  });
}

async function notifyTripThreadParticipants(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
  actorId: string;
  body: string;
  threadId: string;
  tripId: string;
  clientId: string;
  driverId: string;
}): Promise<void> {
  const { firestore, messaging, actorId, body, threadId, tripId, clientId, driverId } = params;
  const participantTargets = await fetchNotificationTargetsByUserIds({
    firestore,
    userIds: [clientId, driverId].filter((userId) => userId !== actorId),
  });
  if (participantTargets.length > 0) {
    const eventType = actorId === clientId ?
      "driver.trip_chat_message" :
      "client.trip_chat_message";
    await dispatchNotificationToTargets({
      firestore,
      messaging,
      targets: participantTargets,
      context: eventType,
      message: {
        notification: {
          title: "Nova mensagem da viagem",
          body: summarizeMessage(body),
        },
        data: {
          type: eventType,
          threadId,
          tripId,
        },
      },
    });
  }

  const opsTargets = await fetchOpsChatTargets({ firestore });
  if (opsTargets.length > 0) {
    await dispatchNotificationToTargets({
      firestore,
      messaging,
      targets: opsTargets,
      context: "ops.chat_message",
      message: {
        notification: {
          title: "Nova mensagem numa viagem",
          body: summarizeMessage(body),
        },
        data: {
          type: "ops.chat_message",
          threadId,
          tripId,
        },
      },
    });
  }
}

async function fetchOpsChatTargets(params: {
  firestore: admin.firestore.Firestore;
}) {
  const baseTargets = await fetchNotificationTargetsByRoles({
    firestore: params.firestore,
    roles: ["admin", "manager"],
  });
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
    return (managerPermissions as Record<string, unknown>).ch === true;
  });
}

async function resolveSenderProfile(params: {
  firestore: admin.firestore.Firestore;
  userId: string;
  callerRole: string;
}): Promise<{ displayName: string; senderRole: SenderRole }> {
  const snapshot = await params.firestore.doc(`users/${params.userId}`).get();
  const data = snapshot.data() ?? {};
  const displayName = typeof data.name === "string" && data.name.trim() ?
    data.name.trim() :
    "Operação";
  const senderRole = normalizeSenderRole(params.callerRole);
  return {
    displayName,
    senderRole,
  };
}

function normalizeSenderRole(role: string): SenderRole {
  switch (role) {
    case "client":
      return "client";
    case "driver":
      return "driver";
    case "admin":
      return "admin";
    case "manager":
      return "manager";
    default:
      return "ops";
  }
}

async function runChatMessageIdempotent(params: {
  firestore: admin.firestore.Firestore;
  threadId: string;
  clientMessageId: string;
  execute: (
    transaction: admin.firestore.Transaction,
  ) => Promise<Omit<SendMessageResult, "duplicated">>;
}): Promise<{ response: SendMessageResult; duplicated: boolean }> {
  const idempotencyRef = params.firestore.doc(
    `chatThreads/${params.threadId}/messageIdempotency/${sanitizeSegment(params.clientMessageId)}`,
  );
  return params.firestore.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(idempotencyRef);
    if (snapshot.exists) {
      const existing = snapshot.data() ?? {};
      return {
        response: {
          ok: true,
          threadId: typeof existing.threadId === "string" ?
            existing.threadId :
            params.threadId,
          messageId: typeof existing.messageId === "string" ?
            existing.messageId :
            "",
          duplicated: true,
        },
        duplicated: true,
      };
    }

    const response = await params.execute(transaction);
    transaction.set(idempotencyRef, {
      threadId: response.threadId,
      messageId: response.messageId,
      createdAt: FieldValue.serverTimestamp(),
    });
    return {
      response: {
        ...response,
        duplicated: false,
      },
      duplicated: false,
    };
  });
}

function buildSupportThreadId(clientId: string): string {
  return `support_client_${sanitizeSegment(clientId)}`;
}

function buildSupportRequestThreadId(requestId: string): string {
  return `support_request_${sanitizeSegment(requestId)}`;
}

function buildTripThreadId(tripId: string): string {
  return `trip_${sanitizeSegment(tripId)}`;
}

function sanitizeSegment(value: string): string {
  return value.trim().replace(/[^a-zA-Z0-9:_-]/g, "_");
}

function summarizeMessage(body: string): string {
  const sanitized = body.replace(/\s+/g, " ").trim();
  if (sanitized.length <= 120) {
    return sanitized;
  }
  return `${sanitized.slice(0, 117)}...`;
}

function requireMessageBody(value: unknown): string {
  if (typeof value !== "string") {
    throw new HttpsError("invalid-argument", "Mensagem inválida.");
  }
  const normalized = value.trim();
  if (!normalized) {
    throw new HttpsError("invalid-argument", "Mensagem obrigatória.");
  }
  if (normalized.length > MAX_CHAT_MESSAGE_LENGTH) {
    throw new HttpsError("invalid-argument", "Mensagem demasiado longa.");
  }
  return normalized;
}

function requireClientMessageId(value: unknown): string {
  if (typeof value !== "string") {
    throw new HttpsError("invalid-argument", "clientMessageId inválido.");
  }
  const normalized = value.trim();
  if (!normalized) {
    throw new HttpsError("invalid-argument", "clientMessageId obrigatório.");
  }
  return normalized;
}

function resolveTargetClientId(data: Record<string, unknown>): string {
  return readNonEmptyString(data.clientId, "clientId");
}

function readNonEmptyString(value: unknown, key: string): string {
  if (typeof value !== "string" || !value.trim()) {
    throw new HttpsError("invalid-argument", `${key} inválido.`);
  }
  return value.trim();
}

function readOptionalString(value: unknown): string | undefined {
  if (typeof value !== "string" || !value.trim()) {
    return undefined;
  }
  return value.trim();
}

function buildSupportTripSnapshot(
  trip: admin.firestore.DocumentData,
  tripStatus: string,
): Record<string, unknown> {
  const pickup = toRecord(trip.pickup);
  const destination = toRecord(trip.destination);
  const transportType = toRecord(trip.transportType);
  const clientSummary = toRecord(trip.clientSummary);
  const driverSummary = toRecord(trip.driverSummary);
  const vehicleSummary = toRecord(trip.vehicleSummary);
  return {
    status: tripStatus,
    pickupAddress: readOptionalString(pickup.address) ?? null,
    destinationAddress: readOptionalString(destination.address) ?? null,
    transportTypeName: readOptionalString(transportType.name) ?? null,
    clientName: readOptionalString(clientSummary.displayName) ?? null,
    driverName: readOptionalString(driverSummary.displayName) ?? null,
    vehiclePlate: readOptionalString(vehicleSummary.plate) ?? null,
    requestedAt: trip.requestedAt ?? null,
    startedAt: trip.startedAt ?? null,
  };
}

async function fetchOpsSupportTargets(params: {
  firestore: admin.firestore.Firestore;
}) {
  const baseTargets = await fetchNotificationTargetsByRoles({
    firestore: params.firestore,
    roles: ["admin", "manager"],
  });
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
    return (managerPermissions as Record<string, unknown>).vs === true;
  });
}

function normalizeTripStatus(value: unknown): string {
  if (typeof value !== "string") {
    return "";
  }
  return value.trim().toUpperCase();
}

function normalizeThreadStatus(value: unknown): ChatThreadStatus {
  return value === "closed" ? "closed" : "open";
}

function toRecord(value: unknown): Record<string, unknown> {
  if (!value || typeof value !== "object") {
    return {};
  }
  return value as Record<string, unknown>;
}
