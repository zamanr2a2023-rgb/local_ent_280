import { decodePolyline } from "./operationalMonitoringMath";
import {
  buildRouteKey,
  fetchExpectedRoute,
} from "./operationalMonitoringRoutes";

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function assertClose(
  actual: number,
  expected: number,
  tolerance: number,
  message: string,
): void {
  if (Math.abs(actual - expected) > tolerance) {
    throw new Error(
      `${message}. actual=${actual} expected=${expected} tolerance=${tolerance}`,
    );
  }
}

async function testBuildRouteKeyRoundsCoordinates(): Promise<void> {
  const routeKey = buildRouteKey({
    operationalWindowId: "trip:trip_1:postdropoff:1711111111111",
    origin: { latitude: 38.7223456, longitude: -9.1393456 },
    destination: { latitude: 38.7369456, longitude: -9.1427456 },
  });

  assert(
    routeKey ===
      "trip:trip_1:postdropoff:1711111111111|38.72235|-9.13935|38.73695|-9.14275",
    "Route key must be stable and rounded to five decimal places.",
  );
}

async function testFetchExpectedRouteFallsBackWithoutApiKey(): Promise<void> {
  const previousDirectionsKey = process.env.GOOGLE_DIRECTIONS_API_KEY;
  const previousMapsKey = process.env.GOOGLE_MAPS_API_KEY;
  delete process.env.GOOGLE_DIRECTIONS_API_KEY;
  delete process.env.GOOGLE_MAPS_API_KEY;

  try {
    const route = await fetchExpectedRoute({
      routeKey: "driver:driver_1:idle:1711111111111",
      origin: { latitude: 38.7223, longitude: -9.1393 },
      destination: { latitude: 38.7369, longitude: -9.1427 },
    });

    assert(route.isFallback, "Fallback route must be used when API key is missing.");
    assert(route.distanceKm > 0, "Fallback route must compute a positive distance.");
    assert(route.durationMinutes > 0, "Fallback route must compute a positive duration.");
    const decoded = decodePolyline(route.encodedPolyline);
    assert(decoded.length === 2, "Fallback polyline must contain origin and destination.");
    assertClose(decoded[0].latitude, 38.7223, 0.00002, "Origin latitude mismatch");
    assertClose(decoded[0].longitude, -9.1393, 0.00002, "Origin longitude mismatch");
    assertClose(
      decoded[1].latitude,
      38.7369,
      0.00002,
      "Destination latitude mismatch",
    );
    assertClose(
      decoded[1].longitude,
      -9.1427,
      0.00002,
      "Destination longitude mismatch",
    );
  } finally {
    if (previousDirectionsKey != null) {
      process.env.GOOGLE_DIRECTIONS_API_KEY = previousDirectionsKey;
    }
    if (previousMapsKey != null) {
      process.env.GOOGLE_MAPS_API_KEY = previousMapsKey;
    }
  }
}

async function main(): Promise<void> {
  await testBuildRouteKeyRoundsCoordinates();
  await testFetchExpectedRouteFallsBackWithoutApiKey();
  // eslint-disable-next-line no-console
  console.log("operationalMonitoringRoutes tests passed.");
}

main().catch((error) => {
  // eslint-disable-next-line no-console
  console.error(error);
  throw error;
});
