import {
  buildTripCallableIdempotencyPath,
  resolveTripCallableIdempotencyKey,
  runTripCallableIdempotent,
} from "./callableIdempotency";
import type * as admin from "firebase-admin";

type StoredDoc = Record<string, unknown>;

type Ref = {
  path: string;
};

class FakeTransaction {
  constructor(private readonly docs: Map<string, StoredDoc>) {}

  async get(ref: Ref): Promise<{ exists: boolean; data(): StoredDoc | undefined }> {
    const value = this.docs.get(ref.path);
    return {
      exists: value != null,
      data: () => value,
    };
  }

  set(ref: Ref, data: StoredDoc, options?: { merge?: boolean }): void {
    if (options?.merge) {
      const current = this.docs.get(ref.path) ?? {};
      this.docs.set(ref.path, { ...current, ...data });
      return;
    }
    this.docs.set(ref.path, data);
  }
}

class FakeFirestore {
  private readonly docs = new Map<string, StoredDoc>();

  doc(path: string): Ref {
    return { path };
  }

  async runTransaction<T>(
    updateFunction: (transaction: FakeTransaction) => Promise<T>,
  ): Promise<T> {
    const transaction = new FakeTransaction(this.docs);
    return updateFunction(transaction);
  }
}

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

async function testResolveKeyUsesEventId(): Promise<void> {
  const key = resolveTripCallableIdempotencyKey({
    tripId: "trip_1",
    action: "transition",
    requesterId: "user_1",
    eventId: "event_42",
  });
  assert(key === "trip_1:transition:event_42", "Expected event-based idempotency key.");
}

async function testResolveKeyUsesProvidedKey(): Promise<void> {
  const key = resolveTripCallableIdempotencyKey({
    tripId: "trip_1",
    action: "transition",
    requesterId: "user_1",
    eventId: "event_42",
    providedKey: "manual-key",
  });
  assert(key === "manual-key", "Expected provided idempotency key to have priority.");
}

async function testRunTripCallableIdempotentDeduplicates(): Promise<void> {
  const firestore = new FakeFirestore();
  let executionCount = 0;
  const idempotencyKey = resolveTripCallableIdempotencyKey({
    tripId: "trip_2",
    action: "cancel",
    requesterId: "driver_1",
    eventId: "evt_1",
  });

  const firstResult = await runTripCallableIdempotent({
    firestore: firestore as unknown as admin.firestore.Firestore,
    tripId: "trip_2",
    idempotencyKey,
    action: "cancel",
    requesterId: "driver_1",
    createdAtValue: "now",
    execute: async () => {
      executionCount += 1;
      return { tripId: "trip_2", status: "CANCELLED_BY_DRIVER" };
    },
  });

  const secondResult = await runTripCallableIdempotent({
    firestore: firestore as unknown as admin.firestore.Firestore,
    tripId: "trip_2",
    idempotencyKey,
    action: "cancel",
    requesterId: "driver_1",
    createdAtValue: "later",
    execute: async () => {
      executionCount += 1;
      return { tripId: "trip_2", status: "CANCELLED_BY_DRIVER" };
    },
  });

  assert(executionCount === 1, "Expected execute callback to run once.");
  assert(firstResult.duplicated === false, "First invocation must not be duplicated.");
  assert(secondResult.duplicated === true, "Second invocation must be duplicated.");
  assert(
    secondResult.response.status === "CANCELLED_BY_DRIVER",
    "Duplicate call must return stored response.",
  );

  const expectedPath = buildTripCallableIdempotencyPath("trip_2", idempotencyKey);
  assert(
    expectedPath === "trips/trip_2/callableIdempotency/trip_2:cancel:evt_1",
    "Idempotency path mismatch.",
  );
}

async function main(): Promise<void> {
  await testResolveKeyUsesEventId();
  await testResolveKeyUsesProvidedKey();
  await testRunTripCallableIdempotentDeduplicates();
  // eslint-disable-next-line no-console
  console.log("callableIdempotency tests passed.");
}

main().catch((error) => {
  // eslint-disable-next-line no-console
  console.error(error);
  throw error;
});
