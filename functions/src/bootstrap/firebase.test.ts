import * as admin from "firebase-admin";
import {
  FieldPath,
  FieldValue,
  GeoPoint,
  Timestamp,
} from "firebase-admin/firestore";
import { ensureFirebaseAdminInitialized } from "./firebase";

type FirestoreNamespaceCompat = typeof admin.firestore & {
  FieldValue?: typeof FieldValue;
  FieldPath?: typeof FieldPath;
  GeoPoint?: typeof GeoPoint;
  Timestamp?: typeof Timestamp;
};

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function testEnsureFirebaseAdminInitializedAddsFieldValueCompat(): void {
  ensureFirebaseAdminInitialized();

  const firestoreNamespace =
    admin.firestore as FirestoreNamespaceCompat;

  assert(
    firestoreNamespace.FieldPath === FieldPath,
    "Expected bootstrap to expose Firestore FieldPath compatibility.",
  );
  assert(
    typeof firestoreNamespace.FieldPath?.documentId === "function",
    "Expected FieldPath.documentId to be available after bootstrap.",
  );
  assert(
    firestoreNamespace.FieldValue === FieldValue,
    "Expected bootstrap to expose Firestore FieldValue compatibility.",
  );
  assert(
    typeof firestoreNamespace.FieldValue?.serverTimestamp === "function",
    "Expected FieldValue.serverTimestamp to be available after bootstrap.",
  );
  assert(
    firestoreNamespace.Timestamp === Timestamp,
    "Expected bootstrap to expose Firestore Timestamp compatibility.",
  );
  assert(
    firestoreNamespace.GeoPoint === GeoPoint,
    "Expected bootstrap to expose Firestore GeoPoint compatibility.",
  );
}

function main(): void {
  testEnsureFirebaseAdminInitializedAddsFieldValueCompat();
  // eslint-disable-next-line no-console
  console.log("bootstrap firebase tests passed.");
}

main();
