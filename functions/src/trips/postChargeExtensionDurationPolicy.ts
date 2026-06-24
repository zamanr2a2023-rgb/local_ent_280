import { HttpsError } from "firebase-functions/v2/https";

export const POST_CHARGE_EXTENSION_MIN_DURATION_MINUTES = 15;
export const POST_CHARGE_EXTENSION_MAX_DURATION_MINUTES = 60;

export function isValidPostChargeExtensionDurationMinutes(value: unknown): value is number {
  return (
    typeof value === "number" &&
    Number.isInteger(value) &&
    value >= POST_CHARGE_EXTENSION_MIN_DURATION_MINUTES &&
    value <= POST_CHARGE_EXTENSION_MAX_DURATION_MINUTES
  );
}

export function parsePostChargeExtensionDurationMinutes(
  data: Record<string, unknown> | null,
): number {
  const raw = data?.durationMinutes;
  if (typeof raw !== "number" || !Number.isInteger(raw)) {
    throw new HttpsError("invalid-argument", "Duração inválida.");
  }
  if (!isValidPostChargeExtensionDurationMinutes(raw)) {
    throw new HttpsError("invalid-argument", "Duração fora do intervalo.");
  }
  return raw;
}
