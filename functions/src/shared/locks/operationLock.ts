import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import { FieldValue, Timestamp } from "firebase-admin/firestore";

export function buildTtlTimestamp(days: number): Timestamp {
  const ttlDate = new Date(Date.now() + days * 24 * 60 * 60 * 1000);
  return Timestamp.fromDate(ttlDate);
}

export function buildTripEventTtlField(days: number): Record<string, unknown> {
  return {
    tripEventExpiresAt: buildTtlTimestamp(days),
  };
}

export function buildOperationLockService(params: {
  firestore: admin.firestore.Firestore;
  lockTtlDays: number;
}): {
  acquireOperationLock: (params: {
    operationId: string;
    operationType: string;
    tripId?: string;
  }) => Promise<boolean>;
  completeOperationLock: (params: {
    operationId: string;
    status: "completed" | "failed";
    errorMessage?: string;
  }) => Promise<void>;
} {
  const {firestore, lockTtlDays} = params;

  function buildOperationLockRef(
    operationId: string,
  ): admin.firestore.DocumentReference {
    return firestore.collection("jobs").doc(`op_${operationId}`);
  }

  async function acquireOperationLock(lockParams: {
    operationId: string;
    operationType: string;
    tripId?: string;
  }): Promise<boolean> {
    const {operationId, operationType, tripId} = lockParams;
    const lockRef = buildOperationLockRef(operationId);
    const lockClaimed = await firestore.runTransaction(async (transaction) => {
      const lockSnapshot = await transaction.get(lockRef);
      if (lockSnapshot.exists) {
        return false;
      }
      transaction.set(lockRef, {
        operationId,
        operationType,
        tripId: tripId ?? null,
        status: "running",
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
        expiresAt: buildTtlTimestamp(lockTtlDays),
      });
      return true;
    });
    if (!lockClaimed) {
      logger.info("Operation lock already claimed, skipping duplicate execution.", {
        operationId,
        operationType,
        tripId,
        lockPath: lockRef.path,
      });
      return false;
    }
    logger.info("Operation lock claimed.", {
      operationId,
      operationType,
      tripId,
      lockPath: lockRef.path,
    });
    return true;
  }

  async function completeOperationLock(lockParams: {
    operationId: string;
    status: "completed" | "failed";
    errorMessage?: string;
  }): Promise<void> {
    const {operationId, status, errorMessage} = lockParams;
    const lockRef = buildOperationLockRef(operationId);
    await lockRef.set(
      {
        status,
        errorMessage: errorMessage ?? null,
        updatedAt: FieldValue.serverTimestamp(),
        releasedAt: FieldValue.serverTimestamp(),
        expiresAt: buildTtlTimestamp(lockTtlDays),
      },
      {merge: true},
    );
  }

  return {
    acquireOperationLock,
    completeOperationLock,
  };
}
