import { HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import type { RbacRole } from "./rbacRoleResolver";

export const MANAGER_PERMISSION_CODES = [
  "vt",
  "vr",
  "va",
  "vd",
  "vc",
  "vs",
  "ch",
  "cs",
  "ts",
  "rp",
  "me",
  "av",
  "ed",
  "mt",
  "tp",
] as const;

export type ManagerPermissionCode = (typeof MANAGER_PERMISSION_CODES)[number];
export type ManagerPermissionClaimsMap = Record<ManagerPermissionCode, boolean>;

const MANAGER_PERMISSION_DEPENDENCIES: Record<
  ManagerPermissionCode,
  readonly ManagerPermissionCode[]
> = {
  vt: [],
  vr: [],
  va: [],
  vd: [],
  vc: [],
  vs: [],
  ch: ["vc"],
  cs: ["vt"],
  ts: ["vt"],
  rp: ["vs"],
  me: ["vd"],
  av: ["vd"],
  ed: [],
  mt: [],
  tp: [],
};

export function normalizeManagerPermissionsInput(
  rawPermissions: unknown,
): ManagerPermissionClaimsMap {
  const normalized = emptyManagerPermissions();
  if (rawPermissions && typeof rawPermissions === "object") {
    const source = rawPermissions as Record<string, unknown>;
    for (const code of MANAGER_PERMISSION_CODES) {
      normalized[code] = source[code] === true;
    }
  }
  for (const [code, dependencies] of Object.entries(MANAGER_PERMISSION_DEPENDENCIES)) {
    const permissionCode = code as ManagerPermissionCode;
    if (!normalized[permissionCode]) {
      continue;
    }
    for (const dependency of dependencies) {
      normalized[dependency] = true;
    }
  }
  return normalized;
}

export function mergeClaimsWithManagerPermissions(params: {
  existingClaims: Record<string, unknown> | null | undefined;
  permissions: ManagerPermissionClaimsMap;
}): Record<string, unknown> {
  const { existingClaims, permissions } = params;
  return {
    ...(existingClaims ?? {}),
    role: "manager",
    mp: {
      ...permissions,
    },
  };
}

export function claimsByteSize(claims: Record<string, unknown>): number {
  return Buffer.byteLength(JSON.stringify(claims), "utf8");
}

export function hasManagerPermission(params: {
  authToken: Record<string, unknown> | null | undefined;
  permission: ManagerPermissionCode;
}): boolean {
  const { authToken, permission } = params;
  const claims = authToken?.mp;
  if (!claims || typeof claims !== "object") {
    return false;
  }
  const map = claims as Record<string, unknown>;
  return map[permission] === true;
}

export function assertManagerPermission(params: {
  role: RbacRole;
  authToken: Record<string, unknown> | null | undefined;
  permission: ManagerPermissionCode;
  context: string;
}): void {
  const { role, authToken, permission, context } = params;
  if (role !== "manager") {
    return;
  }
  if (hasManagerPermission({ authToken, permission })) {
    return;
  }
  logger.warn("Manager permission denied by callable guard.", {
    context,
    permission,
    hasClaims: authToken?.mp != null,
  });
  throw new HttpsError("permission-denied", "Permissões insuficientes.");
}

function emptyManagerPermissions(): ManagerPermissionClaimsMap {
  return {
    vt: false,
    vr: false,
    va: false,
    vd: false,
    vc: false,
    vs: false,
    ch: false,
    cs: false,
    ts: false,
    rp: false,
    me: false,
    av: false,
    ed: false,
    mt: false,
    tp: false,
  };
}
