import * as admin from "firebase-admin";
import {
  FieldPath,
  FieldValue,
  GeoPoint,
  Timestamp,
} from "firebase-admin/firestore";

let isInitialized = false;

type FirestoreNamespaceCompat = typeof admin.firestore & {
  FieldValue?: typeof FieldValue;
  FieldPath?: typeof FieldPath;
  GeoPoint?: typeof GeoPoint;
  Timestamp?: typeof Timestamp;
};

function ensureFirestoreNamespaceCompat(): void {
  const firestoreNamespace =
    admin.firestore as FirestoreNamespaceCompat;

  // firebase-admin v12 no longer exposes these helpers on admin.firestore.
  firestoreNamespace.FieldValue = FieldValue;
  firestoreNamespace.FieldPath = FieldPath;
  firestoreNamespace.GeoPoint = GeoPoint;
  firestoreNamespace.Timestamp = Timestamp;
}

export function ensureFirebaseAdminInitialized(): void {
  if (admin.apps.length === 0) {
    admin.initializeApp();
  }
  ensureFirestoreNamespaceCompat();
  isInitialized = true;
}

function ensureInitialized(): void {
  if (!isInitialized) {
    ensureFirebaseAdminInitialized();
  }
}

export function getFirestore(): admin.firestore.Firestore {
  ensureInitialized();
  return admin.firestore();
}

export function getRealtimeDb(): admin.database.Database {
  ensureInitialized();
  return admin.database();
}

export function getMessaging(): admin.messaging.Messaging {
  ensureInitialized();
  return admin.messaging();
}

export function getAuth(): admin.auth.Auth {
  ensureInitialized();
  return admin.auth();
}

export { admin };
