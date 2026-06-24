import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import { createHash } from "crypto";

const MAX_FCM_TOKENS_PER_BATCH = 500;
const INVALID_TOKEN_ERROR_CODES = new Set<string>([
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
]);

export type NotificationDispatchStats = {
  targetUsers: number;
  tokenCount: number;
  successCount: number;
  failureCount: number;
  invalidTokenRemovals: number;
};

type NotificationTarget = {
  userId: string;
  tokens: string[];
};

export async function fetchNotificationTargetsByRoles(params: {
  firestore: admin.firestore.Firestore;
  roles: string[];
}): Promise<NotificationTarget[]> {
  const { firestore, roles } = params;
  if (roles.length === 0) {
    return [];
  }
  const normalizedRoles = Array.from(
    new Set(
      roles
        .map((role) => role.trim().toLowerCase())
        .filter((role) => role.length > 0),
    ),
  );
  if (normalizedRoles.length === 0) {
    return [];
  }

  const targetQuery = normalizedRoles.length == 1 ?
    firestore.collection("notificationTargets").where("role", "==", normalizedRoles[0]) :
    firestore.collection("notificationTargets").where("role", "in", normalizedRoles);
  const targetSnapshot = await targetQuery.get();
  const denormalizedTargets = await fetchNotificationTargetsFromTargetSnapshot({
    firestore,
    targetsSnapshot: targetSnapshot,
  });
  if (denormalizedTargets.length > 0) {
    return denormalizedTargets;
  }

  const usersQuery = normalizedRoles.length == 1 ?
    firestore.collection("users").where("role", "==", normalizedRoles[0]) :
    firestore.collection("users").where("role", "in", normalizedRoles);

  const usersSnapshot = await usersQuery.get();
  if (usersSnapshot.empty) {
    logger.warn("Notification fanout skipped because no users were found.", {
      roles: normalizedRoles,
    });
    return [];
  }

  return fetchNotificationTargetsFromUsersSnapshot({
    firestore,
    usersSnapshot,
  });
}

export async function fetchNotificationTargetsByUserIds(params: {
  firestore: admin.firestore.Firestore;
  userIds: string[];
}): Promise<NotificationTarget[]> {
  const normalizedUserIds = Array.from(
    new Set(
      params.userIds
        .map((userId) => userId.trim())
        .filter((userId) => userId.length > 0),
    ),
  );
  if (normalizedUserIds.length === 0) {
    return [];
  }

  const denormalizedSnapshots = await Promise.all(
    normalizedUserIds.map((userId) =>
      params.firestore.doc(`notificationTargets/${userId}`).get()),
  );
  const denormalizedTargets = await fetchNotificationTargetsFromTargetSnapshot({
    firestore: params.firestore,
    targetsSnapshot: denormalizedSnapshots,
  });
  if (denormalizedTargets.length > 0) {
    return denormalizedTargets;
  }

  const usersSnapshot = await Promise.all(
    normalizedUserIds.map((userId) => params.firestore.doc(`users/${userId}`).get()),
  );
  return fetchNotificationTargetsFromUsersSnapshot({
    firestore: params.firestore,
    usersSnapshot,
  });
}

export async function dispatchNotificationToTargets(params: {
  firestore: admin.firestore.Firestore;
  messaging: admin.messaging.Messaging;
  targets: NotificationTarget[];
  message: Omit<admin.messaging.MulticastMessage, "tokens">;
  context: string;
}): Promise<NotificationDispatchStats> {
  const { firestore, messaging, targets, message, context } = params;
  let tokenCount = 0;
  let successCount = 0;
  let failureCount = 0;
  let invalidTokenRemovals = 0;

  for (const target of targets) {
    tokenCount += target.tokens.length;
    const tokenChunks = splitIntoChunks(target.tokens, MAX_FCM_TOKENS_PER_BATCH);
    for (let index = 0; index < tokenChunks.length; index++) {
      const tokenChunk = tokenChunks[index];
      try {
        const response = await messaging.sendEachForMulticast({
          ...message,
          tokens: tokenChunk,
        });
        successCount += response.successCount;
        failureCount += response.failureCount;
        invalidTokenRemovals += await cleanupInvalidTokens({
          firestore,
          userId: target.userId,
          tokens: tokenChunk,
          responses: response.responses,
          context,
        });
      } catch (error) {
        failureCount += tokenChunk.length;
        logger.error("Failed to send notification chunk.", {
          context,
          userId: target.userId,
          chunkIndex: index + 1,
          chunkSize: tokenChunk.length,
          error,
        });
      }
    }
  }

  const stats: NotificationDispatchStats = {
    targetUsers: targets.length,
    tokenCount,
    successCount,
    failureCount,
    invalidTokenRemovals,
  };
  logger.info("Notification fanout summary.", {
    context,
    ...stats,
  });
  return stats;
}

async function fetchUserTokens(params: {
  firestore: admin.firestore.Firestore;
  userId: string;
}): Promise<string[]> {
  const { firestore, userId } = params;
  const snapshot = await firestore
    .collection(`users/${userId}/fcmTokens`)
    .where("enabled", "==", true)
    .get();
  if (snapshot.empty) {
    return [];
  }
  const uniqueTokens = new Set<string>();
  for (const doc of snapshot.docs) {
    const token = doc.data().token;
    if (typeof token !== "string") {
      continue;
    }
    const normalized = token.trim();
    if (normalized.length > 0) {
      uniqueTokens.add(normalized);
    }
  }
  return Array.from(uniqueTokens);
}

async function fetchNotificationTargetTokens(params: {
  firestore: admin.firestore.Firestore;
  userId: string;
}): Promise<string[]> {
  const snapshot = await params.firestore
    .collection(`notificationTargets/${params.userId}/tokens`)
    .where("enabled", "==", true)
    .get();
  if (snapshot.empty) {
    return [];
  }
  const uniqueTokens = new Set<string>();
  for (const doc of snapshot.docs) {
    const token = doc.data().token;
    if (typeof token !== "string") {
      continue;
    }
    const normalized = token.trim();
    if (normalized.length > 0) {
      uniqueTokens.add(normalized);
    }
  }
  return Array.from(uniqueTokens);
}

async function fetchNotificationTargetsFromTargetSnapshot(params: {
  firestore: admin.firestore.Firestore;
  targetsSnapshot:
    | admin.firestore.DocumentSnapshot[]
    | admin.firestore.QuerySnapshot;
}): Promise<NotificationTarget[]> {
  const targetDocs = Array.isArray(params.targetsSnapshot) ?
    params.targetsSnapshot :
    params.targetsSnapshot.docs;
  const targets: NotificationTarget[] = [];
  for (const targetDoc of targetDocs) {
    const userId = targetDoc.id.trim();
    if (!userId || !targetDoc.exists) {
      continue;
    }
    const tokens = await fetchNotificationTargetTokens({
      firestore: params.firestore,
      userId,
    });
    if (tokens.length === 0) {
      continue;
    }
    targets.push({ userId, tokens });
  }
  return targets;
}

async function fetchNotificationTargetsFromUsersSnapshot(params: {
  firestore: admin.firestore.Firestore;
  usersSnapshot:
    | admin.firestore.DocumentSnapshot[]
    | admin.firestore.QuerySnapshot;
}): Promise<NotificationTarget[]> {
  const { firestore } = params;
  const usersSnapshot = Array.isArray(params.usersSnapshot) ?
    params.usersSnapshot :
    params.usersSnapshot.docs;
  const targets: NotificationTarget[] = [];
  for (const userDoc of usersSnapshot) {
    const userId = userDoc.id.trim();
    if (!userId || !userDoc.exists) {
      continue;
    }
    const tokens = await fetchUserTokens({
      firestore,
      userId,
    });
    if (tokens.length === 0) {
      continue;
    }
    targets.push({
      userId,
      tokens,
    });
  }
  return targets;
}

async function cleanupInvalidTokens(params: {
  firestore: admin.firestore.Firestore;
  userId: string;
  tokens: string[];
  responses: admin.messaging.SendResponse[];
  context: string;
}): Promise<number> {
  const { firestore, userId, tokens, responses, context } = params;
  const cleanupTargets = responses
    .map((response, index) => ({
      response,
      token: tokens[index],
    }))
    .filter(
      ({ response }) =>
        !response.success &&
        INVALID_TOKEN_ERROR_CODES.has(response.error?.code ?? ""),
    );
  if (cleanupTargets.length === 0) {
    return 0;
  }

  await Promise.all(
    cleanupTargets.map(async ({ token, response }) => {
      try {
        await firestore.doc(`users/${userId}/fcmTokens/${token}`).delete();
        await firestore
          .doc(`notificationTargets/${userId}/tokens/${buildTokenHash(token)}`)
          .delete();
        logger.info("Removed invalid FCM token after send failure.", {
          context,
          userId,
          token,
          errorCode: response.error?.code ?? null,
        });
      } catch (error) {
        logger.error("Failed to remove invalid FCM token.", {
          context,
          userId,
          token,
          error,
        });
      }
    }),
  );
  return cleanupTargets.length;
}

function buildTokenHash(token: string): string {
  return createHash("sha256").update(token).digest("hex");
}

function splitIntoChunks<T>(items: T[], size: number): T[][] {
  const chunks: T[][] = [];
  if (size <= 0 || items.length === 0) {
    return chunks;
  }
  for (let index = 0; index < items.length; index += size) {
    chunks.push(items.slice(index, index + size));
  }
  return chunks;
}
