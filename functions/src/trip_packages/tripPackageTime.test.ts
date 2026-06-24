import {
  addDaysToLocalDayKey,
  buildLocalDayKey,
  getLocalDateParts,
  resolveLocalDateTime,
} from "./tripPackageTime";

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function testBuildLocalDayKey(): void {
  const reference = new Date("2026-03-29T10:15:00.000Z");
  const dayKey = buildLocalDayKey(reference, "Europe/Lisbon");
  assert(dayKey === "2026-03-29", "Expected Europe/Lisbon local day key.");
  assert(
    addDaysToLocalDayKey("2026-12-31", 1) === "2027-01-01",
    "Expected addDaysToLocalDayKey to cross year boundaries.",
  );
}

function testResolveInvalidDstMinuteToNextValidMinute(): void {
  const resolved = resolveLocalDateTime({
    localDayKey: "2026-03-29",
    minutesLocal: 150,
    timeZone: "Europe/Berlin",
  });
  const local = getLocalDateParts(resolved, "Europe/Berlin");
  assert(
    local.year === 2026 && local.month === 3 && local.day === 29,
    "Expected same local day.",
  );
  assert(
    local.hour === 3 && local.minute === 0,
    "Expected invalid 02:30 local time to advance to 03:00.",
  );
}

function testResolveAmbiguousDstMinuteToFirstOccurrence(): void {
  const resolved = resolveLocalDateTime({
    localDayKey: "2026-10-25",
    minutesLocal: 150,
    timeZone: "Europe/Berlin",
  });
  assert(
    resolved.toISOString() === "2026-10-25T00:30:00.000Z",
    "Expected ambiguous 02:30 local time to resolve to the first occurrence.",
  );
  const firstOccurrence = getLocalDateParts(resolved, "Europe/Berlin");
  const secondOccurrence = getLocalDateParts(
    new Date(resolved.getTime() + 60 * 60 * 1000),
    "Europe/Berlin",
  );
  assert(
    firstOccurrence.hour === 2 &&
        firstOccurrence.minute === 30 &&
        secondOccurrence.hour === 2 &&
        secondOccurrence.minute === 30,
    "Expected DST fallback hour to produce two local 02:30 occurrences.",
  );
}

async function main(): Promise<void> {
  testBuildLocalDayKey();
  testResolveInvalidDstMinuteToNextValidMinute();
  testResolveAmbiguousDstMinuteToFirstOccurrence();
  // eslint-disable-next-line no-console
  console.log("tripPackageTime tests passed.");
}

main().catch((error) => {
  // eslint-disable-next-line no-console
  console.error(error);
  throw error;
});
