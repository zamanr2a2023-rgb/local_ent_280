import {
  resolveIncidentReplaySamples,
} from "./buildOperationalMonitoringFunctions";
import { OPERATIONAL_WINDOW_TYPES, type ReplaySample } from "./operationalMonitoringTypes";

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function buildSample(index: number): ReplaySample {
  return {
    latitude: 14.9 + index,
    longitude: -23.5 - index,
    recordedAt: new Date(2026, 0, 1, 10, index),
  };
}

function testActiveTripFallsBackToReplaySamples(): void {
  const replaySamples = [buildSample(1), buildSample(2)];
  const result = resolveIncidentReplaySamples({
    operationalWindowType: OPERATIONAL_WINDOW_TYPES.activeTrip,
    driverId: "driver-1",
    tripId: "trip-1",
    tripPathSamples: [],
    replaySamples,
  });

  assert(result.length == replaySamples.length, "Fallback must keep replay samples.");
  assert(
    result[0].recordedAt.getTime() == replaySamples[0].recordedAt.getTime(),
    "Fallback must preserve replay sample ordering.",
  );
}

function testActiveTripPrefersTripPathSamples(): void {
  const tripPathSamples = [buildSample(3), buildSample(4)];
  const replaySamples = [buildSample(1), buildSample(2)];
  const result = resolveIncidentReplaySamples({
    operationalWindowType: OPERATIONAL_WINDOW_TYPES.activeTrip,
    driverId: "driver-1",
    tripId: "trip-1",
    tripPathSamples,
    replaySamples,
  });

  assert(result.length == tripPathSamples.length, "Trip path samples must win when present.");
  assert(
    result[0].recordedAt.getTime() == tripPathSamples[0].recordedAt.getTime(),
    "Trip path samples must be returned unchanged.",
  );
}

function testNonActiveTripUsesReplaySamples(): void {
  const replaySamples = [buildSample(1), buildSample(2)];
  const result = resolveIncidentReplaySamples({
    operationalWindowType: OPERATIONAL_WINDOW_TYPES.postDropoff,
    driverId: "driver-1",
    tripId: null,
    tripPathSamples: [buildSample(3)],
    replaySamples,
  });

  assert(result.length == replaySamples.length, "Post drop-off incidents must use replay samples.");
  assert(
    result[0].recordedAt.getTime() == replaySamples[0].recordedAt.getTime(),
    "Replay samples must be preserved for non-active trips.",
  );
}

function main(): void {
  testActiveTripFallsBackToReplaySamples();
  testActiveTripPrefersTripPathSamples();
  testNonActiveTripUsesReplaySamples();
  // eslint-disable-next-line no-console
  console.log("operationalMonitoringIncidentSamples tests passed.");
}

main();
