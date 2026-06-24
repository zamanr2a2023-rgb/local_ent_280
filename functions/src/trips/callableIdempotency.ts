import type * as admin from "firebase-admin";

function toRecord(value: unknown): Record<string, unknown> | null {
  if (!value || typeof value !== "object") {
    return null;
  }
  return value as Record<string, unknown>;
}

function toSafeSegment(value: string): string {
  const normalized = value.trim().replace(/\s+/g, "_");
  const sanitized = normalized.replace(/[^a-zA-Z0-9:_-]/g, "_");
  if (sanitized.length <= 240) {
    return sanitized;
  }
  return sanitized.slice(0, 240);
}

export function parseOptionalIdempotencyKey(
  data: Record<string, unknown> | null,
): string | null {
  const value = data?.idempotencyKey;
  if (typeof value !== "string") {
    return null;
  }
  const trimmed = value.trim();
  if (!trimmed) {
    return null;
  }
  return trimmed;
}

export function resolveTripCallableIdempotencyKey(params: {
  tripId: string;
  action: string;
  requesterId: string;
  eventId?: string | null;
  providedKey?: string | null;
}): string {
  const {
    tripId,
    action,
    requesterId,
    eventId,
    providedKey,
  } = params;
  const resolvedEventId = eventId?.trim();
  const baseKey =
    providedKey?.trim() ||
    `${tripId}:${action}:${resolvedEventId || requesterId}`;
  return toSafeSegment(baseKey);
}

export function buildTripCallableIdempotencyPath(
  tripId: string,
  idempotencyKey: string,
): string {
  return `trips/${tripId}/callableIdempotency/${toSafeSegment(idempotencyKey)}`;
}

export async function runTripCallableIdempotent<T extends Record<string, unknown>>(params: {
  firestore: admin.firestore.Firestore;
  tripId: string;
  idempotencyKey: string;
  action: string;
  requesterId: string;
  createdAtValue: unknown;
  execute: (transaction: admin.firestore.Transaction) => Promise<T>;
}): Promise<{ response: T; duplicated: boolean }> {
  const {
    firestore,
    tripId,
    idempotencyKey,
    action,
    requesterId,
    createdAtValue,
    execute,
  } = params;
  const idempotencyRef = firestore.doc(
    buildTripCallableIdempotencyPath(tripId, idempotencyKey),
  );
  return firestore.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(idempotencyRef);
    if (snapshot.exists) {
      const existingData = toRecord(snapshot.data());
      const existingResponse = toRecord(existingData?.response);
      if (existingResponse != null) {
        return {
          response: existingResponse as T,
          duplicated: true,
        };
      }
    }

    const response = await execute(transaction);
    transaction.set(
      idempotencyRef,
      {
        action,
        requesterId,
        idempotencyKey,
        response,
        createdAt: createdAtValue,
      },
      { merge: true },
    );
    return {
      response,
      duplicated: false,
    };
  });
}
