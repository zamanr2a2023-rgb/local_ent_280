import {
  parsePostChargeExtensionDurationMinutes,
  POST_CHARGE_EXTENSION_MAX_DURATION_MINUTES,
  POST_CHARGE_EXTENSION_MIN_DURATION_MINUTES,
} from "./postChargeExtensionDurationPolicy";

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function assertThrows(callback: () => void, expectedMessage: string): void {
  try {
    callback();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    assert(
      message.includes(expectedMessage),
      `Expected error containing "${expectedMessage}", got "${message}".`,
    );
    return;
  }

  throw new Error("Expected callback to throw.");
}

function testAcceptsBoundaryDurations(): void {
  assert(
    parsePostChargeExtensionDurationMinutes({
      durationMinutes: POST_CHARGE_EXTENSION_MIN_DURATION_MINUTES,
    }) === POST_CHARGE_EXTENSION_MIN_DURATION_MINUTES,
    "Minimum duration should be accepted.",
  );
  assert(
    parsePostChargeExtensionDurationMinutes({
      durationMinutes: POST_CHARGE_EXTENSION_MAX_DURATION_MINUTES,
    }) === POST_CHARGE_EXTENSION_MAX_DURATION_MINUTES,
    "Maximum duration should be accepted.",
  );
}

function testRejectsOutOfRangeDurations(): void {
  assertThrows(
    () =>
      parsePostChargeExtensionDurationMinutes({
        durationMinutes: POST_CHARGE_EXTENSION_MIN_DURATION_MINUTES - 1,
      }),
    "Duração fora do intervalo.",
  );
  assertThrows(
    () =>
      parsePostChargeExtensionDurationMinutes({
        durationMinutes: POST_CHARGE_EXTENSION_MAX_DURATION_MINUTES + 1,
      }),
    "Duração fora do intervalo.",
  );
}

function main(): void {
  testAcceptsBoundaryDurations();
  testRejectsOutOfRangeDurations();
  // eslint-disable-next-line no-console
  console.log("postChargeExtensionDurationPolicy tests passed.");
}

main();
