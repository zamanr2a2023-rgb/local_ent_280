import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import { FieldPath, FieldValue, GeoPoint, Timestamp } from "firebase-admin/firestore";
import { createHash } from "node:crypto";
import {
  assertCallerIsAdmin,
  assertCallerIsOps,
  resolveCallerRole,
  requireAuthenticatedUid,
} from "../shared/auth/rbacRoleResolver";
import {
  assertManagerPermission,
  claimsByteSize,
  mergeClaimsWithManagerPermissions,
  normalizeManagerPermissionsInput,
} from "../shared/auth/managerPermissionClaims";
import {
  dispatchNotificationToTargets,
  fetchNotificationTargetsByRoles,
} from "../shared/notifications/fcmFanout";

export type AdminFunctions = {
  adminDeleteUser: ReturnType<typeof onCall>;
  adminUpdateUserPassword: ReturnType<typeof onCall>;
  setManagerPermissions: ReturnType<typeof onCall>;
  createTransportType: ReturnType<typeof onCall>;
  updateTransportType: ReturnType<typeof onCall>;
  saveAdminTariff: ReturnType<typeof onCall>;
  resolveAuditAdminEmails: ReturnType<typeof onCall>;
  resolveAuditSubjectIdentities: ReturnType<typeof onCall>;
  requestSupportTicket: ReturnType<typeof onCall>;
  requestPasswordHelp: ReturnType<typeof onCall>;
  resolvePasswordHelpRequest: ReturnType<typeof onCall>;
  syncPublicTariffFromAdmin: ReturnType<typeof onDocumentWritten>;
};

export function buildAdminFunctions(params: {
  firestore: admin.firestore.Firestore;
  realtimeDb: admin.database.Database;
  auth: admin.auth.Auth;
  messaging: admin.messaging.Messaging;
}): AdminFunctions {
  const { firestore, realtimeDb, auth, messaging } = params;

  const adminDeleteUser = onCall(
    {
      region: "europe-southwest1",
    },
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);

      const data = request.data as Record<string, unknown> | null;
      const targetUserId = data?.userId;
      if (
        typeof targetUserId !== "string" ||
        targetUserId.trim().length === 0
      ) {
        throw new HttpsError("invalid-argument", "Utilizador inválido.");
      }

      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      assertCallerIsAdmin(callerRole);

      const trimmedUserId = targetUserId.trim();
      try {
        await auth.deleteUser(trimmedUserId);
      } catch (error) {
        const code = (error as { code?: string })?.code;
        if (code !== "auth/user-not-found") {
          logger.error("Failed to delete auth user.", {
            trimmedUserId,
            error,
          });
          throw new HttpsError("internal", "Falha ao apagar utilizador.");
        }
      }

      const batch = firestore.batch();
      batch.delete(firestore.doc(`users/${trimmedUserId}`));
      batch.delete(firestore.doc(`balances/${trimmedUserId}`));
      batch.delete(firestore.doc(`driverStatus/${trimmedUserId}`));
      batch.delete(firestore.doc(`driverVehicleAssignments/${trimmedUserId}`));
      batch.delete(firestore.doc(`driversPublic/${trimmedUserId}`));
      await batch.commit();

      try {
        await realtimeDb.ref(`driverLocations/${trimmedUserId}`).remove();
      } catch (error) {
        logger.warn("Failed to remove driver location.", {
          trimmedUserId,
          error,
        });
      }

      logger.info("Admin deleted user.", {
        trimmedUserId,
        requesterId,
      });

      return { userId: trimmedUserId };
    },
  );

  const adminUpdateUserPassword = onCall(
    {
      region: "europe-southwest1",
    },
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      assertCallerIsAdmin(callerRole);

      const payload = request.data as Record<string, unknown> | null;
      const userId =
        typeof payload?.userId === "string" ? payload.userId.trim() : "";
      const newPassword =
        typeof payload?.newPassword === "string"
          ? payload.newPassword.trim()
          : "";

      if (!userId) {
        throw new HttpsError("invalid-argument", "Utilizador inválido.");
      }
      if (newPassword.length < 6) {
        throw new HttpsError(
          "invalid-argument",
          "A palavra-passe deve ter pelo menos 6 caracteres.",
        );
      }

      await auth.updateUser(userId, { password: newPassword });
      logger.info("Admin updated user password.", {
        userId,
        requesterId,
      });
      return { ok: true };
    },
  );

  const setManagerPermissions = onCall(
    {
      region: "europe-southwest1",
    },
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      assertCallerIsAdmin(callerRole);

      const payload = request.data as Record<string, unknown> | null;
      const userId =
        typeof payload?.userId === "string" ? payload.userId.trim() : "";
      if (!userId) {
        throw new HttpsError("invalid-argument", "Utilizador inválido.");
      }

      const userRef = firestore.doc(`users/${userId}`);
      const userSnapshot = await userRef.get();
      if (!userSnapshot.exists) {
        throw new HttpsError("not-found", "Utilizador não encontrado.");
      }
      const userData = userSnapshot.data() ?? {};
      const userRoleRaw = userData.role;
      const userRole =
        typeof userRoleRaw === "string" ? userRoleRaw.trim().toLowerCase() : "";
      if (userRole !== "manager") {
        throw new HttpsError(
          "failed-precondition",
          "Permissões de manager só podem ser aplicadas a utilizadores manager.",
        );
      }

      const permissions = normalizeManagerPermissionsInput(
        payload?.permissions,
      );
      const authUser = await auth.getUser(userId);
      const mergedClaims = mergeClaimsWithManagerPermissions({
        existingClaims: authUser.customClaims ?? {},
        permissions,
      });
      const payloadSize = claimsByteSize(mergedClaims);
      if (payloadSize > 1000) {
        throw new HttpsError(
          "failed-precondition",
          "Payload de permissões excede o limite permitido.",
        );
      }

      await auth.setCustomUserClaims(userId, mergedClaims);
      await userRef.set(
        {
          managerPermissions: {
            ...permissions,
            updatedAt: FieldValue.serverTimestamp(),
            updatedBy: requesterId,
          },
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      logger.info("Manager permissions updated.", {
        userId,
        requesterId,
        payloadSize,
        permissions,
      });
      return { ok: true };
    },
  );

  const createTransportType = onCall(
    {
      region: "europe-southwest1",
    },
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      assertCallerIsAdmin(callerRole);

      const payload = request.data as Record<string, unknown> | null;
      const requestedId =
        typeof payload?.id === "string" ? payload.id.trim() : "";
      const name = typeof payload?.name === "string" ? payload.name.trim() : "";
      const description =
        typeof payload?.description === "string"
          ? payload.description.trim()
          : "";
      const initialBaseFare = parseEuroMoneyPayload(
        payload?.initialBaseFare,
        "initialBaseFare",
      );
      const packagePriceMultiplierBasisPoints =
        parsePackagePriceMultiplierBasisPoints(
          payload?.packagePriceMultiplierBasisPoints,
          "packagePriceMultiplierBasisPoints",
        );

      if (
        requestedId &&
        (!/^[a-z0-9_]+$/.test(requestedId) || requestedId.length > 40)
      ) {
        throw new HttpsError(
          "invalid-argument",
          "Identificador do tipo de transporte inválido.",
        );
      }
      if (name.length < 2 || name.length > 120) {
        throw new HttpsError(
          "invalid-argument",
          "Nome do tipo de transporte inválido.",
        );
      }
      if (description.length > 500) {
        throw new HttpsError(
          "invalid-argument",
          "Descrição do tipo de transporte inválida.",
        );
      }
      if (initialBaseFare.amountMinor < 0) {
        throw new HttpsError(
          "invalid-argument",
          "Tarifa base inicial inválida.",
        );
      }

      let transportTypeId = "";
      const adminTariffRef = firestore.doc("tariffs/admin_default");
      await firestore.runTransaction(async (transaction) => {
        transportTypeId =
          requestedId ||
          (await allocateTransportTypeId({
            firestore,
            transaction,
            name,
          }));
        const transportTypeRef = firestore.doc(
          `transport_types/${transportTypeId}`,
        );
        const [transportTypeSnapshot, adminTariffSnapshot] = await Promise.all([
          transaction.get(transportTypeRef),
          transaction.get(adminTariffRef),
        ]);

        if (transportTypeSnapshot.exists) {
          throw new HttpsError(
            "already-exists",
            "Tipo de transporte já existe.",
          );
        }
        if (!adminTariffSnapshot.exists) {
          throw new HttpsError(
            "failed-precondition",
            "Tarifário administrativo em falta.",
          );
        }
        const existingTariff = normalizePersistedTariffForAudit(
          adminTariffSnapshot.data(),
        );
        const existingBaseByTransportType =
          existingTariff != null && isRecord(existingTariff.baseByTransportType)
            ? (existingTariff.baseByTransportType as Record<
                string,
                MoneyPayload
              >)
            : {};
        const nextBaseByTransportType = {
          ...existingBaseByTransportType,
          [transportTypeId]: initialBaseFare,
        };
        transaction.set(transportTypeRef, {
          name,
          description,
          packagePriceMultiplierBasisPoints,
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });
        transaction.set(
          adminTariffRef,
          {
            baseByTransportType: sortRecordByKey(nextBaseByTransportType),
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
      });

      logger.info("Transport type created and seeded into tariff.", {
        transportTypeId,
        requesterId,
        initialBaseFareMinor: initialBaseFare.amountMinor,
        packagePriceMultiplierBasisPoints,
      });
      return { ok: true, transportTypeId };
    },
  );

  const updateTransportType = onCall(
    {
      region: "europe-southwest1",
    },
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      assertCallerIsAdmin(callerRole);

      const payload = request.data as Record<string, unknown> | null;
      const id = typeof payload?.id === "string" ? payload.id.trim() : "";
      const name = typeof payload?.name === "string" ? payload.name.trim() : "";
      const description =
        typeof payload?.description === "string"
          ? payload.description.trim()
          : "";
      const baseFare = parseEuroMoneyPayload(payload?.baseFare, "baseFare");
      const packagePriceMultiplierBasisPoints =
        parsePackagePriceMultiplierBasisPoints(
          payload?.packagePriceMultiplierBasisPoints,
          "packagePriceMultiplierBasisPoints",
        );

      if (!id || name.length < 2 || name.length > 120) {
        throw new HttpsError(
          "invalid-argument",
          "Nome do tipo de transporte inválido.",
        );
      }
      if (description.length > 500) {
        throw new HttpsError(
          "invalid-argument",
          "Descrição do tipo de transporte inválida.",
        );
      }

      const transportTypeRef = firestore.doc(`transport_types/${id}`);
      const adminTariffRef = firestore.doc("tariffs/admin_default");
      await firestore.runTransaction(async (transaction) => {
        const [transportTypeSnapshot, adminTariffSnapshot] = await Promise.all([
          transaction.get(transportTypeRef),
          transaction.get(adminTariffRef),
        ]);
        if (!transportTypeSnapshot.exists) {
          throw new HttpsError(
            "not-found",
            "Tipo de transporte não encontrado.",
          );
        }
        if (!adminTariffSnapshot.exists) {
          throw new HttpsError(
            "failed-precondition",
            "Tarifário administrativo em falta.",
          );
        }
        const existingTariff = normalizePersistedTariffForAudit(
          adminTariffSnapshot.data(),
        );
        const existingBaseByTransportType =
          existingTariff != null && isRecord(existingTariff.baseByTransportType)
            ? (existingTariff.baseByTransportType as Record<
                string,
                MoneyPayload
              >)
            : {};
        const nextBaseByTransportType = {
          ...existingBaseByTransportType,
          [id]: baseFare,
        };
        transaction.update(transportTypeRef, {
          name,
          description,
          packagePriceMultiplierBasisPoints,
          updatedAt: FieldValue.serverTimestamp(),
        });
        transaction.set(
          adminTariffRef,
          {
            baseByTransportType: sortRecordByKey(nextBaseByTransportType),
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
      });

      logger.info("Transport type updated; starting vehicle backfill.", {
        transportTypeId: id,
        requesterId,
        baseFareMinor: baseFare.amountMinor,
        packagePriceMultiplierBasisPoints,
      });

      const backfillResult = await backfillVehicleTransportTypeName({
        firestore,
        transportTypeId: id,
        transportTypeName: name,
      });

      if (backfillResult.backfillCompleted) {
        logger.info(
          "Transport type update completed with full vehicle backfill.",
          {
            transportTypeId: id,
            requesterId,
            matchedVehicles: backfillResult.matchedVehicles,
            updatedVehicles: backfillResult.updatedVehicles,
            failedVehicles: backfillResult.failedVehicles,
          },
        );
      } else {
        logger.warn(
          "Transport type update completed with partial vehicle backfill.",
          {
            transportTypeId: id,
            requesterId,
            matchedVehicles: backfillResult.matchedVehicles,
            updatedVehicles: backfillResult.updatedVehicles,
            failedVehicles: backfillResult.failedVehicles,
          },
        );
      }

      return backfillResult;
    },
  );

  const saveAdminTariff = onCall(
    {
      region: "europe-southwest1",
    },
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      if (callerRole === "manager") {
        assertManagerPermission({
          role: callerRole,
          authToken: request.auth?.token ?? null,
          permission: "mt",
          context: "saveAdminTariff",
        });
      } else {
        assertCallerIsAdmin(callerRole);
      }

      const payload = request.data as Record<string, unknown> | null;
      const tariffPayload = payload?.tariff;
      const reason =
        typeof payload?.reason === "string" ? payload.reason.trim() : "";
      const transportTypesSnapshot = await firestore
        .collection("transport_types")
        .orderBy(FieldPath.documentId())
        .get();
      const transportTypeIds = transportTypesSnapshot.docs.map((doc) => doc.id);
      const normalizedTariff = normalizeCallableTariffPayload({
        value: tariffPayload,
        transportTypeIds,
      });

      const tariffRef = firestore.doc("tariffs/admin_default");
      const currentSnapshot = await tariffRef.get();
      const currentData = currentSnapshot.data() ?? null;
      const beforeValues = normalizePersistedTariffForAudit(currentData) ?? {};
      const afterValues = normalizeTariffForAudit(normalizedTariff);
      const currentCreatedAt = currentData?.createdAt;
      const adminEmail = normalizeOptionalString(request.auth?.token.email);
      const batch = firestore.batch();
      batch.set(
        tariffRef,
        buildTariffWritePayload({
          tariff: normalizedTariff,
          createdAt: currentCreatedAt,
        }),
      );
      batch.set(firestore.collection("audit").doc(), {
        actionType: "tariff_edit",
        adminId: requesterId,
        ...(adminEmail ? { adminEmail } : {}),
        reason: reason || "Atualização de tarifário",
        before: beforeValues,
        after: afterValues,
        subject: "admin_default",
        createdAt: FieldValue.serverTimestamp(),
      });
      await batch.commit();

      logger.info("Admin tariff saved via callable.", {
        requesterId,
        actorRole: callerRole,
        transportTypeCount: transportTypeIds.length,
        changed: stableSerialize(beforeValues) !== stableSerialize(afterValues),
      });
      return { ok: true };
    },
  );

  const resolveAuditAdminEmails = onCall(
    {
      region: "europe-southwest1",
    },
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      if (callerRole === "manager") {
        assertManagerPermission({
          role: callerRole,
          authToken: request.auth?.token ?? null,
          permission: "va",
          context: "resolveAuditAdminEmails",
        });
      } else {
        assertCallerIsAdmin(callerRole);
      }

      const rawIds = (request.data as Record<string, unknown> | null)?.adminIds;
      if (!Array.isArray(rawIds)) {
        throw new HttpsError(
          "invalid-argument",
          "Lista de utilizadores inválida.",
        );
      }
      const adminIds = Array.from(
        new Set(
          rawIds
            .map((value) => (typeof value === "string" ? value.trim() : ""))
            .filter((value) => value.length > 0),
        ),
      );
      if (adminIds.length > 100) {
        throw new HttpsError(
          "invalid-argument",
          "Lista de utilizadores demasiado longa.",
        );
      }
      if (adminIds.length === 0) {
        return { emails: {} };
      }

      let users: admin.auth.GetUsersResult;
      try {
        users = await auth.getUsers(adminIds.map((uid) => ({ uid })));
      } catch (error) {
        logger.error("Failed to resolve audit admin emails.", {
          requesterId,
          requestedCount: adminIds.length,
          error,
        });
        throw new HttpsError(
          "internal",
          "Não foi possível resolver identidades da auditoria.",
        );
      }
      const emails: Record<string, string> = {};
      for (const user of users.users) {
        const email = user.email?.trim();
        if (!email) {
          continue;
        }
        emails[user.uid] = email;
      }

      logger.info("Resolved audit admin emails.", {
        requesterId,
        requestedCount: adminIds.length,
        resolvedCount: Object.keys(emails).length,
      });
      return { emails };
    },
  );

  const resolveAuditSubjectIdentities = onCall(
    {
      region: "europe-southwest1",
    },
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      if (callerRole === "manager") {
        assertManagerPermission({
          role: callerRole,
          authToken: request.auth?.token ?? null,
          permission: "va",
          context: "resolveAuditSubjectIdentities",
        });
      } else {
        assertCallerIsAdmin(callerRole);
      }

      const rawIds = (request.data as Record<string, unknown> | null)?.userIds;
      if (!Array.isArray(rawIds)) {
        throw new HttpsError("invalid-argument", "Lista de alvos inválida.");
      }
      const userIds = Array.from(
        new Set(
          rawIds
            .map((value) => (typeof value === "string" ? value.trim() : ""))
            .filter((value) => value.length > 0),
        ),
      );
      if (userIds.length > 100) {
        throw new HttpsError(
          "invalid-argument",
          "Lista de alvos demasiado longa.",
        );
      }
      if (userIds.length === 0) {
        return { identities: {} };
      }

      try {
        const snapshots = await firestore.getAll(
          ...userIds.map((userId) => firestore.doc(`users/${userId}`)),
        );
        const identities: Record<
          string,
          { displayName?: string; email?: string }
        > = {};
        for (const snapshot of snapshots) {
          if (!snapshot.exists) {
            continue;
          }
          const userData = snapshot.data() ?? {};
          const displayName = resolveAuditSubjectDisplayName(userData);
          const email = resolveAuditSubjectEmail(userData);
          if (!displayName && !email) {
            continue;
          }
          identities[snapshot.id] = {
            ...(displayName ? { displayName } : {}),
            ...(email ? { email } : {}),
          };
        }

        logger.info("Resolved audit subject identities.", {
          requesterId,
          requestedCount: userIds.length,
          resolvedCount: Object.keys(identities).length,
        });
        return { identities };
      } catch (error) {
        logger.error("Failed to resolve audit subject identities.", {
          requesterId,
          requestedCount: userIds.length,
          error,
        });
        throw new HttpsError(
          "internal",
          "Não foi possível resolver alvos da auditoria.",
        );
      }
    },
  );

  const requestPasswordHelp = onCall(
    {
      region: "europe-southwest1",
      enforceAppCheck: true,
    },
    async (request) => {
      const supportPhone = await fetchSupportPhone({
        firestore,
      });
      const normalizedIdentifier = normalizeEmailOrLogin(
        (request.data as Record<string, unknown> | null)?.emailOrLogin,
      );
      const identifierHash = hashIdentifier(normalizedIdentifier);
      logger.info("Processing password help request.", {
        appCheckValidated: request.app != null,
        identifierHash,
        supportPhoneConfigured: supportPhone != null,
      });
      if (!normalizedIdentifier) {
        logger.warn(
          "Password help request ignored because identifier is empty.",
          {
            appCheckValidated: request.app != null,
            identifierHash,
          },
        );
        return {
          ok: true,
          supportPhone,
        };
      }

      let requestCreated = false;
      let requestId: string | null = null;
      try {
        const authUser = await resolveAuthUserByEmail({
          auth,
          email: normalizedIdentifier,
        });
        if (authUser != null) {
          const supportRequest = await upsertPasswordHelpRequest({
            firestore,
            userId: authUser.uid,
            fallbackDisplayName: authUser.displayName ?? null,
            fallbackEmail: authUser.email ?? null,
          });
          requestCreated = supportRequest.created;
          requestId = supportRequest.requestId;
          await notifyOpsPasswordHelpRequest({
            firestore,
            messaging,
            requestId: supportRequest.requestId,
            userId: authUser.uid,
            displayName: supportRequest.displayName,
            email: supportRequest.email,
            role: supportRequest.role,
          });
        }
      } catch (error) {
        logger.error("Password help request processing failed.", {
          identifierHash,
          appCheckValidated: request.app != null,
          error,
        });
      }

      logger.info("Password help request processed.", {
        appCheckValidated: request.app != null,
        identifierHash,
        requestCreated,
        requestId,
      });
      return {
        ok: true,
        supportPhone,
      };
    },
  );

  const requestSupportTicket = onCall(
    {
      region: "europe-southwest1",
    },
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      if (callerRole !== "client") {
        throw new HttpsError(
          "permission-denied",
          "Só clientes podem abrir pedidos de suporte.",
        );
      }

      const payload = request.data as Record<string, unknown> | null;
      const subject = normalizeSupportTicketText(payload?.subject, 120);
      const message = normalizeSupportTicketText(payload?.message, 1000);
      if (!message) {
        throw new HttpsError(
          "invalid-argument",
          "Descreva o pedido de suporte.",
        );
      }

      const userSnapshot = await firestore.doc(`users/${requesterId}`).get();
      const userData = userSnapshot.data() ?? {};
      const displayName = resolveDisplayName({
        fromUserDoc: userData.name,
        fallbackDisplayName: null,
      });
      const email = resolveEmail({
        fromUserDoc: userData.email,
        fallbackEmail: null,
      });
      const role =
        typeof userData.role === "string" ? userData.role.trim() : "client";
      const supportRequestRef = firestore.collection("supportRequests").doc();
      const sanitizedRequestId = supportRequestRef.id.replace(
        /[^a-zA-Z0-9:_-]/g,
        "_",
      );
      const chatThreadId = `support_request_${sanitizedRequestId}`;
      await supportRequestRef.set({
        type: "general",
        sourceType: "general",
        subject: subject || null,
        message,
        userId: requesterId,
        role,
        displayName,
        email,
        chatThreadId,
        status: "open",
        requestedAt: FieldValue.serverTimestamp(),
        requestedBy: "client_support_ticket",
        updatedAt: FieldValue.serverTimestamp(),
      });

      logger.info("Support ticket created.", {
        requestId: supportRequestRef.id,
        requesterId,
        appCheckValidated: request.app != null,
      });
      await notifyOpsSupportTicket({
        firestore,
        messaging,
        requestId: supportRequestRef.id,
        threadId: chatThreadId,
        displayName,
        email,
      });

      return {
        ok: true,
        requestId: supportRequestRef.id,
      };
    },
  );

  const resolvePasswordHelpRequest = onCall(
    {
      region: "europe-southwest1",
    },
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      assertCallerIsOps(callerRole);
      assertManagerPermission({
        role: callerRole,
        authToken: request.auth?.token ?? null,
        permission: "rp",
        context: "resolvePasswordHelpRequest",
      });

      const payload = request.data as Record<string, unknown> | null;
      const requestId =
        typeof payload?.requestId === "string" ? payload.requestId.trim() : "";
      if (!requestId) {
        throw new HttpsError("invalid-argument", "Pedido de suporte inválido.");
      }

      const supportRequestRef = firestore.doc(`supportRequests/${requestId}`);
      const snapshot = await supportRequestRef.get();
      if (!snapshot.exists) {
        throw new HttpsError("not-found", "Pedido de suporte não encontrado.");
      }
      const requestData = snapshot.data() ?? {};
      const userIdRaw = requestData.userId;
      const userId = typeof userIdRaw === "string" ? userIdRaw.trim() : "";
      const requestedBy =
        typeof requestData.requestedBy === "string"
          ? requestData.requestedBy.trim()
          : "";

      await supportRequestRef.set(
        {
          status: "resolved",
          resolvedAt: FieldValue.serverTimestamp(),
          resolvedBy: requesterId,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      if (userId && requestedBy === "forgot_password") {
        const userRef = firestore.doc(`users/${userId}`);
        const userSnapshot = await userRef.get();
        if (userSnapshot.exists) {
          await userRef.set(
            {
              support: {
                passwordHelp: {
                  status: "resolved",
                  resolvedAt: FieldValue.serverTimestamp(),
                  resolvedBy: requesterId,
                  updatedAt: FieldValue.serverTimestamp(),
                },
              },
            },
            { merge: true },
          );
        }
      }

      logger.info("Support request resolved.", {
        requestId,
        requesterId,
        resolveActor: callerRole,
        userId: userId || null,
        requestedBy: requestedBy || null,
      });
      return {
        ok: true,
      };
    },
  );

  const syncPublicTariffFromAdmin = onDocumentWritten(
    {
      document: "tariffs/admin_default",
      region: "europe-southwest1",
    },
    async (event) => {
      if (!event.data?.after?.exists) {
        logger.error(
          "Admin tariff ausente; sync de public_default cancelado.",
          {
            sourcePath: "tariffs/admin_default",
          },
        );
        return;
      }
      const adminTariffSnapshot = await firestore
        .doc("tariffs/admin_default")
        .get();
      if (!adminTariffSnapshot.exists) {
        logger.error(
          "Admin tariff ausente após trigger; sync de public_default cancelado.",
          {
            sourcePath: "tariffs/admin_default",
          },
        );
        return;
      }
      const data = adminTariffSnapshot.data();
      if (!data || typeof data !== "object") {
        logger.error("Admin tariff payload inválido para sync.", {
          path: adminTariffSnapshot.ref.path,
        });
        return;
      }
      const normalizedPayload = normalizeValue(data);
      if (!isRecord(normalizedPayload)) {
        logger.error("Admin tariff payload não pôde ser normalizado.", {
          path: adminTariffSnapshot.ref.path,
        });
        return;
      }
      const publicTariffRef = firestore.doc("tariffs/public_default");
      const currentPublicSnapshot = await publicTariffRef.get();
      const currentPublicData = currentPublicSnapshot.data() ?? {};
      if (
        stableSerialize(currentPublicData) ===
        stableSerialize(normalizedPayload)
      ) {
        logger.info("Public tariff já está sincronizado com admin_default.", {
          sourcePath: adminTariffSnapshot.ref.path,
          targetPath: publicTariffRef.path,
        });
        return;
      }
      await publicTariffRef.set(normalizedPayload);
      logger.info("Public tariff synced from admin_default.", {
        sourcePath: adminTariffSnapshot.ref.path,
        targetPath: publicTariffRef.path,
      });
    },
  );

  return {
    adminDeleteUser,
    adminUpdateUserPassword,
    setManagerPermissions,
    createTransportType,
    updateTransportType,
    saveAdminTariff,
    resolveAuditAdminEmails,
    resolveAuditSubjectIdentities,
    requestSupportTicket,
    requestPasswordHelp,
    resolvePasswordHelpRequest,
    syncPublicTariffFromAdmin,
  };
}

async function backfillVehicleTransportTypeName(params: {
  firestore: admin.firestore.Firestore;
  transportTypeId: string;
  transportTypeName: string;
}): Promise<{
  matchedVehicles: number;
  updatedVehicles: number;
  failedVehicles: number;
  backfillCompleted: boolean;
}> {
  const { firestore, transportTypeId, transportTypeName } = params;
  const bulkWriter = buildBulkWriter(firestore);
  const writePromises: Array<Promise<void>> = [];
  let matchedVehicles = 0;
  let updatedVehicles = 0;
  let failedVehicles = 0;
  let closeFailed = false;
  let lastVehicleId: string | null = null;
  let hasMoreVehicles = true;

  while (hasMoreVehicles) {
    let query: admin.firestore.Query = firestore
      .collection("vehicles")
      .where("defaultTransportType.id", "==", transportTypeId)
      .orderBy(FieldPath.documentId())
      .limit(200);
    if (lastVehicleId != null) {
      query = query.startAfter(lastVehicleId);
    }
    const snapshot = await query.get();
    if (snapshot.empty) {
      hasMoreVehicles = false;
      continue;
    }
    matchedVehicles += snapshot.docs.length;
    for (const vehicleDoc of snapshot.docs) {
      writePromises.push(
        bulkWriter
          .update(vehicleDoc.ref, {
            "defaultTransportType.name": transportTypeName,
            updatedAt: FieldValue.serverTimestamp(),
          })
          .then(() => {
            updatedVehicles += 1;
          })
          .catch((error: unknown) => {
            failedVehicles += 1;
            logger.error("Vehicle transport type backfill failed.", {
              transportTypeId,
              vehicleId: vehicleDoc.id,
              error,
            });
          }),
      );
    }
    lastVehicleId = snapshot.docs[snapshot.docs.length - 1].id;
  }

  try {
    await bulkWriter.close();
  } catch (error) {
    closeFailed = true;
    logger.error("Vehicle transport type backfill close failed.", {
      transportTypeId,
      error,
    });
  }

  await Promise.all(writePromises);

  return {
    matchedVehicles,
    updatedVehicles,
    failedVehicles,
    backfillCompleted: !closeFailed && failedVehicles === 0,
  };
}

function normalizeEmailOrLogin(value: unknown): string {
  if (typeof value !== "string") {
    return "";
  }
  return value.trim().toLowerCase();
}

function normalizeSupportTicketText(value: unknown, maxLength: number): string {
  if (typeof value !== "string") {
    return "";
  }
  return value.trim().replace(/\s+/g, " ").slice(0, maxLength);
}

function hashIdentifier(value: string): string {
  if (!value) {
    return "empty";
  }
  return createHash("sha256").update(value).digest("hex").slice(0, 16);
}

function resolveAuditSubjectDisplayName(
  data: admin.firestore.DocumentData,
): string | null {
  return normalizeOptionalString(data.name);
}

function resolveAuditSubjectEmail(
  data: admin.firestore.DocumentData,
): string | null {
  return normalizeOptionalString(data.email);
}

function normalizeOptionalString(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }
  const normalized = value.trim();
  return normalized.length > 0 ? normalized : null;
}

async function fetchSupportPhone(params: {
  firestore: admin.firestore.Firestore;
}): Promise<string | null> {
  const { firestore } = params;
  try {
    const snapshot = await firestore.doc("config/support").get();
    const supportPhone = snapshot.data()?.supportPhone;
    if (typeof supportPhone !== "string") {
      return null;
    }
    const normalized = supportPhone.trim();
    return normalized.length > 0 ? normalized : null;
  } catch (error) {
    logger.error(
      "Failed to read support config while handling password help.",
      {
        error,
      },
    );
    return null;
  }
}

async function resolveAuthUserByEmail(params: {
  auth: admin.auth.Auth;
  email: string;
}): Promise<admin.auth.UserRecord | null> {
  const { auth, email } = params;
  try {
    return await auth.getUserByEmail(email);
  } catch (error) {
    const code = (error as { code?: string } | null)?.code ?? "";
    if (code === "auth/user-not-found") {
      return null;
    }
    throw error;
  }
}

async function upsertPasswordHelpRequest(params: {
  firestore: admin.firestore.Firestore;
  userId: string;
  fallbackDisplayName: string | null;
  fallbackEmail: string | null;
}): Promise<{
  requestId: string;
  created: boolean;
  displayName: string | null;
  email: string | null;
  role: string | null;
}> {
  const { firestore, userId, fallbackDisplayName, fallbackEmail } = params;
  const userSnapshot = await firestore.doc(`users/${userId}`).get();
  const userData = userSnapshot.data() ?? {};
  const role = typeof userData.role === "string" ? userData.role.trim() : null;
  const displayName = resolveDisplayName({
    fromUserDoc: userData.name,
    fallbackDisplayName,
  });
  const email = resolveEmail({
    fromUserDoc: userData.email,
    fallbackEmail,
  });

  const existingOpenRequestQuery = await firestore
    .collection("supportRequests")
    .where("userId", "==", userId)
    .where("status", "==", "open")
    .limit(1)
    .get();
  const existingOpenRequest = existingOpenRequestQuery.docs[0] ?? null;

  const supportRequestRef =
    existingOpenRequest?.ref ?? firestore.collection("supportRequests").doc();
  const created = existingOpenRequest == null;
  await supportRequestRef.set(
    {
      userId,
      role,
      displayName,
      email,
      status: "open",
      requestedAt: FieldValue.serverTimestamp(),
      requestedBy: "forgot_password",
      resolvedAt: FieldValue.delete(),
      resolvedBy: FieldValue.delete(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  if (userSnapshot.exists) {
    await firestore.doc(`users/${userId}`).set(
      {
        support: {
          passwordHelp: {
            status: "open",
            requestedAt: FieldValue.serverTimestamp(),
            requestedBy: "forgot_password",
            resolvedAt: FieldValue.delete(),
            resolvedBy: FieldValue.delete(),
            updatedAt: FieldValue.serverTimestamp(),
          },
        },
      },
      { merge: true },
    );
  } else {
    logger.warn(
      "Skipping users password help note because users doc is missing.",
      {
        userId,
      },
    );
  }

  return {
    requestId: supportRequestRef.id,
    created,
    displayName,
    email,
    role,
  };
}

async function notifyOpsPasswordHelpRequest(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
  requestId: string;
  userId: string;
  displayName: string | null;
  email: string | null;
  role: string | null;
}): Promise<void> {
  const { firestore, messaging, requestId, userId, displayName, email, role } =
    params;
  const targets = await fetchNotificationTargetsByRoles({
    firestore,
    roles: ["admin", "manager"],
  });
  if (targets.length === 0) {
    logger.warn("Password help request notification skipped: no ops targets.", {
      requestId,
      userId,
    });
    return;
  }

  const label = displayName ?? email ?? userId;
  const dispatchStats = await dispatchNotificationToTargets({
    firestore,
    messaging,
    targets,
    message: {
      notification: {
        title: "Pedido de ajuda para palavra-passe",
        body: `Utilizador ${label} pediu ajuda para recuperar acesso.`,
      },
      data: {
        type: "ops.password_help_request",
        requestId,
        userId,
        userRole: role ?? "unknown",
      },
    },
    context: "password_help_request",
  });
  logger.info("Password help request notification dispatched.", {
    requestId,
    userId,
    notificationTargets: dispatchStats.targetUsers,
    tokenCount: dispatchStats.tokenCount,
    successCount: dispatchStats.successCount,
    failureCount: dispatchStats.failureCount,
    invalidTokenRemovals: dispatchStats.invalidTokenRemovals,
  });
}

async function notifyOpsSupportTicket(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
  requestId: string;
  threadId: string;
  tripId?: string;
  displayName: string | null;
  email: string | null;
}): Promise<void> {
  const { firestore, messaging, requestId, threadId, tripId, displayName, email } =
    params;
  const baseTargets = await fetchNotificationTargetsByRoles({
    firestore,
    roles: ["admin", "manager"],
  });
  const snapshots = await Promise.all(
    baseTargets.map((target) => firestore.doc(`users/${target.userId}`).get()),
  );
  const targets = baseTargets.filter((target, index) => {
    const data = snapshots[index].data() ?? {};
    const role = typeof data.role === "string" ?
      data.role.trim().toLowerCase() :
      "";
    if (role === "admin") {
      return true;
    }
    const managerPermissions = data.managerPermissions;
    if (!managerPermissions || typeof managerPermissions !== "object") {
      return false;
    }
    return (managerPermissions as Record<string, unknown>).vs === true;
  });
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

function resolveDisplayName(params: {
  fromUserDoc: unknown;
  fallbackDisplayName: string | null;
}): string | null {
  const { fromUserDoc, fallbackDisplayName } = params;
  if (typeof fromUserDoc === "string" && fromUserDoc.trim().length > 0) {
    return fromUserDoc.trim();
  }
  if (
    typeof fallbackDisplayName === "string" &&
    fallbackDisplayName.trim().length > 0
  ) {
    return fallbackDisplayName.trim();
  }
  return null;
}

function resolveEmail(params: {
  fromUserDoc: unknown;
  fallbackEmail: string | null;
}): string | null {
  const { fromUserDoc, fallbackEmail } = params;
  if (typeof fromUserDoc === "string" && fromUserDoc.trim().length > 0) {
    return fromUserDoc.trim().toLowerCase();
  }
  if (typeof fallbackEmail === "string" && fallbackEmail.trim().length > 0) {
    return fallbackEmail.trim().toLowerCase();
  }
  return null;
}

type MoneyPayload = {
  amountMinor: number;
  currency: string;
};

type NormalizedTariffDistanceTier = {
  startMetersInclusive: number;
  endMetersExclusive?: number;
  perKm: MoneyPayload;
};

type NormalizedTariffMultiplierRule = {
  id: string;
  type: "time_range" | "holiday";
  multiplier: number;
  timeRange?: {
    startMinutes: number;
    endMinutes: number;
  };
  holidayDates?: string[];
};

type NormalizedTariffPayload = {
  id: "admin_default";
  baseByTransportType: Record<string, MoneyPayload>;
  perKm: MoneyPayload;
  perWaitMinute: MoneyPayload;
  distanceTiers: NormalizedTariffDistanceTier[];
  penaltyFees: {
    lateCancellation: MoneyPayload;
    noShow: MoneyPayload;
  };
  multiplierRules: NormalizedTariffMultiplierRule[];
};

function parseEuroMoneyPayload(
  value: unknown,
  fieldPath: string,
): MoneyPayload {
  if (!isRecord(value)) {
    throw new HttpsError("invalid-argument", `${fieldPath} inválido.`);
  }
  const amountMinor = value.amountMinor;
  const currency = value.currency;
  if (!Number.isSafeInteger(amountMinor)) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldPath}.amountMinor inválido.`,
    );
  }
  if (currency !== "EUR") {
    throw new HttpsError(
      "invalid-argument",
      `${fieldPath}.currency deve ser EUR.`,
    );
  }
  return {
    amountMinor: amountMinor as number,
    currency: "EUR",
  };
}

function parseRequiredInteger(
  value: unknown,
  fieldPath: string,
  minimum = 0,
): number {
  if (!Number.isSafeInteger(value) || (value as number) < minimum) {
    throw new HttpsError("invalid-argument", `${fieldPath} inválido.`);
  }
  return value as number;
}

function parseOptionalInteger(
  value: unknown,
  fieldPath: string,
  minimum = 0,
): number | undefined {
  if (value == null) {
    return undefined;
  }
  return parseRequiredInteger(value, fieldPath, minimum);
}

function parsePackagePriceMultiplierBasisPoints(
  value: unknown,
  fieldPath: string,
): number {
  const basisPoints = parseRequiredInteger(value, fieldPath, 1);
  if (basisPoints < 5000 || basisPoints > 30000) {
    throw new HttpsError("invalid-argument", `${fieldPath} inválido.`);
  }
  return basisPoints;
}

function parseMultiplierValue(value: unknown, fieldPath: string): number {
  if (typeof value !== "number" || !Number.isFinite(value)) {
    throw new HttpsError("invalid-argument", `${fieldPath} inválido.`);
  }
  const normalized = Number(value.toFixed(2));
  if (normalized < 0.5 || normalized > 3.0) {
    throw new HttpsError("invalid-argument", `${fieldPath} inválido.`);
  }
  return normalized;
}

function normalizeHolidayDate(value: unknown, fieldPath: string): string {
  if (typeof value !== "string") {
    throw new HttpsError("invalid-argument", `${fieldPath} inválido.`);
  }
  const normalized = value.trim();
  if (!/^\d{4}-\d{2}-\d{2}$/.test(normalized)) {
    throw new HttpsError("invalid-argument", `${fieldPath} inválido.`);
  }
  return normalized;
}

function normalizeCallableTariffPayload(params: {
  value: unknown;
  transportTypeIds: string[];
}): NormalizedTariffPayload {
  const { value, transportTypeIds } = params;
  if (!isRecord(value)) {
    throw new HttpsError("invalid-argument", "Tarifário inválido.");
  }
  if (transportTypeIds.length === 0) {
    throw new HttpsError(
      "failed-precondition",
      "É necessário ter tipos de transporte configurados.",
    );
  }
  const id = typeof value.id === "string" ? value.id.trim() : "";
  if (id !== "admin_default") {
    throw new HttpsError("invalid-argument", "Tarifário inválido.");
  }
  const rawBaseByTransportType = value.baseByTransportType;
  if (!isRecord(rawBaseByTransportType)) {
    throw new HttpsError(
      "invalid-argument",
      "Tarifa base por tipo de transporte inválida.",
    );
  }
  const providedTransportTypeIds = Object.keys(rawBaseByTransportType)
    .map((entry) => entry.trim())
    .filter((entry) => entry.length > 0)
    .sort();
  const expectedTransportTypeIds = [...transportTypeIds].sort();
  const hasSameTransportTypes =
    stableSerialize(providedTransportTypeIds) ===
    stableSerialize(expectedTransportTypeIds);
  if (!hasSameTransportTypes) {
    throw new HttpsError(
      "invalid-argument",
      "Tarifa base deve cobrir exatamente os tipos de transporte ativos.",
    );
  }
  const baseByTransportType = sortRecordByKey(
    expectedTransportTypeIds.reduce(
      (acc, transportTypeId) => {
        acc[transportTypeId] = parseEuroMoneyPayload(
          rawBaseByTransportType[transportTypeId],
          `tariff.baseByTransportType.${transportTypeId}`,
        );
        return acc;
      },
      {} as Record<string, MoneyPayload>,
    ),
  );
  const distanceTiers = parseDistanceTiers(value.distanceTiers);
  const perKm = distanceTiers[0].perKm;
  return {
    id: "admin_default",
    baseByTransportType,
    perKm,
    perWaitMinute: parseEuroMoneyPayload(
      value.perWaitMinute,
      "tariff.perWaitMinute",
    ),
    distanceTiers,
    penaltyFees: parsePenaltyFees(value.penaltyFees),
    multiplierRules: parseMultiplierRules(value.multiplierRules),
  };
}

function parseDistanceTiers(value: unknown): NormalizedTariffDistanceTier[] {
  if (!Array.isArray(value) || value.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "distanceTiers deve conter pelo menos uma faixa.",
    );
  }
  const parsed = value.map((entry, index) => {
    if (!isRecord(entry)) {
      throw new HttpsError(
        "invalid-argument",
        `distanceTiers[${index}] inválido.`,
      );
    }
    return {
      startMetersInclusive: parseRequiredInteger(
        entry.startMetersInclusive,
        `distanceTiers[${index}].startMetersInclusive`,
      ),
      endMetersExclusive: parseOptionalInteger(
        entry.endMetersExclusive,
        `distanceTiers[${index}].endMetersExclusive`,
        1,
      ),
      perKm: parseEuroMoneyPayload(
        entry.perKm,
        `distanceTiers[${index}].perKm`,
      ),
    };
  });

  let expectedStart = 0;
  for (let index = 0; index < parsed.length; index += 1) {
    const tier = parsed[index];
    if (tier.startMetersInclusive !== expectedStart) {
      throw new HttpsError(
        "invalid-argument",
        `distanceTiers[${index}].startMetersInclusive inválido.`,
      );
    }
    const isLast = index === parsed.length - 1;
    if (isLast) {
      if (tier.endMetersExclusive != null) {
        throw new HttpsError(
          "invalid-argument",
          `distanceTiers[${index}].endMetersExclusive inválido.`,
        );
      }
      continue;
    }
    if (
      tier.endMetersExclusive == null ||
      tier.endMetersExclusive <= tier.startMetersInclusive
    ) {
      throw new HttpsError(
        "invalid-argument",
        `distanceTiers[${index}].endMetersExclusive inválido.`,
      );
    }
    expectedStart = tier.endMetersExclusive;
  }
  return parsed;
}

function parsePenaltyFees(value: unknown): {
  lateCancellation: MoneyPayload;
  noShow: MoneyPayload;
} {
  if (!isRecord(value)) {
    throw new HttpsError("invalid-argument", "penaltyFees inválido.");
  }
  return {
    lateCancellation: parseEuroMoneyPayload(
      value.lateCancellation,
      "penaltyFees.lateCancellation",
    ),
    noShow: parseEuroMoneyPayload(value.noShow, "penaltyFees.noShow"),
  };
}

function parseMultiplierRules(
  value: unknown,
): NormalizedTariffMultiplierRule[] {
  if (value == null) {
    return [];
  }
  if (!Array.isArray(value)) {
    throw new HttpsError("invalid-argument", "multiplierRules inválido.");
  }
  const parsed: NormalizedTariffMultiplierRule[] = value.map(
    (entry, index): NormalizedTariffMultiplierRule => {
      if (!isRecord(entry)) {
        throw new HttpsError(
          "invalid-argument",
          `multiplierRules[${index}] inválido.`,
        );
      }
      const type = typeof entry.type === "string" ? entry.type : "";
      const id =
        typeof entry.id === "string" && entry.id.trim().length > 0
          ? entry.id.trim()
          : `rule_${index + 1}`;
      const multiplier = parseMultiplierValue(
        entry.multiplier,
        `multiplierRules[${index}].multiplier`,
      );
      if (type === "time_range") {
        if (!isRecord(entry.timeRange)) {
          throw new HttpsError(
            "invalid-argument",
            `multiplierRules[${index}].timeRange inválido.`,
          );
        }
        const startMinutes = parseRequiredInteger(
          entry.timeRange.startMinutes,
          `multiplierRules[${index}].timeRange.startMinutes`,
        );
        const endMinutes = parseRequiredInteger(
          entry.timeRange.endMinutes,
          `multiplierRules[${index}].timeRange.endMinutes`,
        );
        if (
          startMinutes >= 1440 ||
          endMinutes >= 1440 ||
          startMinutes === endMinutes
        ) {
          throw new HttpsError(
            "invalid-argument",
            `multiplierRules[${index}].timeRange inválido.`,
          );
        }
        return {
          id,
          type: "time_range",
          multiplier,
          timeRange: {
            startMinutes,
            endMinutes,
          },
        };
      }
      if (type === "holiday") {
        if (
          !Array.isArray(entry.holidayDates) ||
          entry.holidayDates.length === 0
        ) {
          throw new HttpsError(
            "invalid-argument",
            `multiplierRules[${index}].holidayDates inválido.`,
          );
        }
        const holidayDates = Array.from(
          new Set(
            entry.holidayDates.map((holidayDate, holidayIndex) =>
              normalizeHolidayDate(
                holidayDate,
                `multiplierRules[${index}].holidayDates[${holidayIndex}]`,
              ),
            ),
          ),
        ).sort();
        return {
          id,
          type: "holiday",
          multiplier,
          holidayDates,
        };
      }
      throw new HttpsError(
        "invalid-argument",
        `multiplierRules[${index}].type inválido.`,
      );
    },
  );
  const timeRangeRules = parsed.filter((entry) => entry.type === "time_range");
  if (timeRangeRules.length > 5) {
    throw new HttpsError(
      "invalid-argument",
      "multiplierRules excede o limite de períodos horários.",
    );
  }
  return [...parsed].sort((left, right) => {
    const typeComparison = left.type.localeCompare(right.type);
    if (typeComparison !== 0) {
      return typeComparison;
    }
    if (left.type === "time_range" && right.type === "time_range") {
      const startComparison =
        (left.timeRange?.startMinutes ?? 0) -
        (right.timeRange?.startMinutes ?? 0);
      if (startComparison !== 0) {
        return startComparison;
      }
      const endComparison =
        (left.timeRange?.endMinutes ?? 0) - (right.timeRange?.endMinutes ?? 0);
      if (endComparison !== 0) {
        return endComparison;
      }
    }
    return left.id.localeCompare(right.id);
  });
}

function normalizePersistedTariffForAudit(
  value: unknown,
): Record<string, unknown> | null {
  if (!isRecord(value) || !isRecord(value.baseByTransportType)) {
    return null;
  }
  try {
    const transportTypeIds = Object.keys(value.baseByTransportType)
      .map((entry) => entry.trim())
      .filter((entry) => entry.length > 0);
    if (transportTypeIds.length === 0) {
      return null;
    }
    return normalizeTariffForAudit(
      normalizeCallableTariffPayload({
        value: {
          id: "admin_default",
          baseByTransportType: value.baseByTransportType,
          perKm: value.perKm,
          perWaitMinute: value.perWaitMinute,
          distanceTiers: value.distanceTiers,
          penaltyFees: value.penaltyFees,
          multiplierRules: value.multiplierRules,
        },
        transportTypeIds,
      }),
    );
  } catch (error) {
    logger.warn("Failed to normalize persisted tariff for audit.", { error });
    return null;
  }
}

function normalizeTariffForAudit(
  tariff: NormalizedTariffPayload,
): Record<string, unknown> {
  return {
    baseByTransportType: sortRecordByKey(tariff.baseByTransportType),
    perKm: tariff.perKm,
    perWaitMinute: tariff.perWaitMinute,
    distanceTiers: tariff.distanceTiers.map((tier) => ({
      startMetersInclusive: tier.startMetersInclusive,
      ...(tier.endMetersExclusive == null
        ? {}
        : { endMetersExclusive: tier.endMetersExclusive }),
      perKm: tier.perKm,
    })),
    penaltyFees: {
      lateCancellation: tariff.penaltyFees.lateCancellation,
      noShow: tariff.penaltyFees.noShow,
    },
    multiplierRules: tariff.multiplierRules,
  };
}

function buildTariffWritePayload(params: {
  tariff: NormalizedTariffPayload;
  createdAt: unknown;
}): Record<string, unknown> {
  const { tariff, createdAt } = params;
  return {
    ...normalizeTariffForAudit(tariff),
    createdAt: isFirestoreTimestamp(createdAt)
      ? createdAt
      : FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };
}

async function allocateTransportTypeId(params: {
  firestore: admin.firestore.Firestore;
  transaction: admin.firestore.Transaction;
  name: string;
}): Promise<string> {
  const { firestore, transaction, name } = params;
  const baseId = slugifyTransportTypeId(name);
  for (let suffix = 0; suffix < 1000; suffix += 1) {
    const candidate =
      suffix == 0
        ? baseId
        : `${truncateTransportTypeId(baseId, suffix)}_${suffix}`;
    const snapshot = await transaction.get(
      firestore.doc(`transport_types/${candidate}`),
    );
    if (!snapshot.exists) {
      return candidate;
    }
  }
  throw new HttpsError(
    "already-exists",
    "Não foi possível gerar um identificador único para o tipo de transporte.",
  );
}

function slugifyTransportTypeId(value: string): string {
  const normalized = value
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "")
    .replace(/_+/g, "_");
  const fallback = normalized || "transport";
  return truncateTransportTypeId(fallback, 0);
}

function truncateTransportTypeId(baseId: string, suffix: number): string {
  const suffixLength = suffix == 0 ? 0 : `_${suffix}`.length;
  const maxBaseLength = Math.max(1, 40 - suffixLength);
  return baseId.slice(0, maxBaseLength).replace(/_+$/g, "") || "transport";
}

function sortRecordByKey<T>(value: Record<string, T>): Record<string, T> {
  return Object.entries(value)
    .sort(([left], [right]) => left.localeCompare(right))
    .reduce(
      (acc, [key, entry]) => {
        acc[key] = entry;
        return acc;
      },
      {} as Record<string, T>,
    );
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return value != null && typeof value === "object" && !Array.isArray(value);
}

function isFirestoreTimestamp(
  value: unknown,
): value is Timestamp {
  return value instanceof Timestamp;
}

function isFirestoreGeoPoint(
  value: unknown,
): value is GeoPoint {
  return value instanceof GeoPoint;
}

function isPassthroughValue(value: unknown): boolean {
  return (
    value instanceof Date ||
    isFirestoreTimestamp(value) ||
    isFirestoreGeoPoint(value)
  );
}

function normalizeValue(value: unknown): unknown {
  if (isPassthroughValue(value)) {
    return value;
  }
  if (Array.isArray(value)) {
    return value.map((entry) => normalizeValue(entry));
  }
  if (!isRecord(value)) {
    return value;
  }
  return Object.entries(value).reduce(
    (acc, [key, entry]) => {
      if (entry === undefined) {
        return acc;
      }
      acc[key] = normalizeValue(entry);
      return acc;
    },
    {} as Record<string, unknown>,
  );
}

function buildBulkWriter(
  firestore: admin.firestore.Firestore,
): admin.firestore.BulkWriter {
  const bulkWriter = firestore.bulkWriter();
  bulkWriter.onWriteError((error) => {
    logger.warn("BulkWriter write failed.", {
      documentPath: error.documentRef.path,
      failedAttempts: error.failedAttempts,
      code: error.code,
      message: error.message,
    });
    return error.failedAttempts < 3;
  });
  return bulkWriter;
}

function stableSerialize(value: unknown): string {
  return JSON.stringify(sortValue(value));
}

function sortValue(value: unknown): unknown {
  if (value instanceof Date) {
    return {
      __type: "date",
      iso: value.toISOString(),
    };
  }
  if (isFirestoreTimestamp(value)) {
    return {
      __type: "timestamp",
      seconds: value.seconds,
      nanoseconds: value.nanoseconds,
    };
  }
  if (isFirestoreGeoPoint(value)) {
    return {
      __type: "geopoint",
      latitude: value.latitude,
      longitude: value.longitude,
    };
  }
  if (Array.isArray(value)) {
    return value.map((entry) => sortValue(entry));
  }
  if (!isRecord(value)) {
    return value;
  }
  const sortedEntries = Object.entries(value).sort(([left], [right]) =>
    left.localeCompare(right),
  );
  return sortedEntries.reduce(
    (acc, [key, entry]) => {
      acc[key] = sortValue(entry);
      return acc;
    },
    {} as Record<string, unknown>,
  );
}
