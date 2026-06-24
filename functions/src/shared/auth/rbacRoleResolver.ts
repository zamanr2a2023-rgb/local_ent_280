import { HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

export type RbacRole = "client" | "driver" | "manager" | "admin";

type CallableAuth = {
  uid: string;
  token: Record<string, unknown>;
} | null | undefined;

const SUPPORTED_ROLES: ReadonlySet<string> = new Set([
  "client",
  "driver",
  "manager",
  "admin",
]);

function parseRole(value: unknown): RbacRole | null {
  if (typeof value !== "string") {
    return null;
  }
  const normalized = value.trim().toLowerCase();
  return SUPPORTED_ROLES.has(normalized) ? (normalized as RbacRole) : null;
}

export function requireAuthenticatedUid(auth: CallableAuth): string {
  const uid = auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Autenticação necessária.");
  }
  return uid;
}

export async function resolveCallerRole(params: {
  firestore: admin.firestore.Firestore;
  auth: CallableAuth;
}): Promise<RbacRole> {
  const { firestore, auth } = params;
  const uid = requireAuthenticatedUid(auth);

  const tokenRole = parseRole(auth?.token?.role);
  if (tokenRole) {
    logger.debug("RBAC role resolved from custom claims.", {
      uid,
      role: tokenRole,
      source: "token",
    });
    return tokenRole;
  }

  const userSnapshot = await firestore.doc(`users/${uid}`).get();
  const documentRole = parseRole(userSnapshot.data()?.role);
  if (documentRole) {
    logger.debug("RBAC role resolved from users document fallback.", {
      uid,
      role: documentRole,
      source: "users_doc",
    });
    return documentRole;
  }

  logger.warn("RBAC role not found for caller.", {
    uid,
    tokenRole: auth?.token?.role ?? null,
  });
  throw new HttpsError("permission-denied", "Permissões insuficientes.");
}

export function assertCallerIsAdmin(role: RbacRole): void {
  if (role !== "admin") {
    throw new HttpsError("permission-denied", "Permissões insuficientes.");
  }
}

export function assertCallerIsOps(role: RbacRole): void {
  if (role !== "admin" && role !== "manager") {
    throw new HttpsError("permission-denied", "Permissões insuficientes.");
  }
}
