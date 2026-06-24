import {
  appendReplaySample,
  decodePolyline,
  distanceToPolylineMeters,
  encodePolyline,
  haversineDistanceMeters,
  isInsideCircularGeofence,
} from "./operationalMonitoringMath";
import type { ReplaySample } from "./operationalMonitoringTypes";

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

async function testHaversineDistanceMeters(): Promise<void> {
  const samePointDistance = haversineDistanceMeters(
    { latitude: 38.7223, longitude: -9.1393 },
    { latitude: 38.7223, longitude: -9.1393 },
  );
  assertClose(samePointDistance, 0, 0.001, "Same point distance must be zero");

  const lisbonToPortoDistance = haversineDistanceMeters(
    { latitude: 38.7223, longitude: -9.1393 },
    { latitude: 41.1579, longitude: -8.6291 },
  );
  assert(
    lisbonToPortoDistance > 270000 && lisbonToPortoDistance < 280000,
    "Lisbon to Porto distance must stay within a realistic range.",
  );
}

async function testCircularGeofence(): Promise<void> {
  const geofence = {
    center: { latitude: 38.7223, longitude: -9.1393 },
    radiusMeters: 150,
  };

  assert(
    isInsideCircularGeofence({
      point: { latitude: 38.7227, longitude: -9.1390 },
      geofence,
    }),
    "Nearby point should be inside the geofence.",
  );
  assert(
    !isInsideCircularGeofence({
      point: { latitude: 38.7305, longitude: -9.1500 },
      geofence,
    }),
    "Distant point should be outside the geofence.",
  );
}

async function testDistanceToPolylineMeters(): Promise<void> {
  const polyline = [
    { latitude: 38.7223, longitude: -9.1393 },
    { latitude: 38.7223, longitude: -9.1293 },
  ];

  const onLine = distanceToPolylineMeters({
    point: { latitude: 38.7223, longitude: -9.1343 },
    polyline,
  });
  const offLine = distanceToPolylineMeters({
    point: { latitude: 38.7273, longitude: -9.1343 },
    polyline,
  });

  assertClose(onLine, 0, 1, "Point on line should be near zero distance");
  assert(
    offLine > 500,
    "Point away from line should have a meaningful positive distance.",
  );
}

async function testPolylineRoundTrip(): Promise<void> {
  const points = [
    { latitude: 38.7223, longitude: -9.1393 },
    { latitude: 38.7201, longitude: -9.1320 },
    { latitude: 38.7167, longitude: -9.1331 },
  ];
  const encoded = encodePolyline(points);
  const decoded = decodePolyline(encoded);

  assert(decoded.length === points.length, "Polyline roundtrip length mismatch.");
  for (let index = 0; index < points.length; index += 1) {
    assertClose(
      decoded[index].latitude,
      points[index].latitude,
      0.00002,
      `Latitude mismatch at index ${index}`,
    );
    assertClose(
      decoded[index].longitude,
      points[index].longitude,
      0.00002,
      `Longitude mismatch at index ${index}`,
    );
  }
}

async function testAppendReplaySampleRetainsNewestPoint(): Promise<void> {
  const baseDate = new Date("2026-03-22T10:00:00.000Z");
  const samples: ReplaySample[] = [];
  for (let index = 0; index < 6; index += 1) {
    samples.push({
      latitude: 38.72 + index * 0.001,
      longitude: -9.14 + index * 0.001,
      recordedAt: new Date(baseDate.getTime() + index * 60000),
    });
  }

  const reduced = appendReplaySample({
    samples: samples.slice(0, 5),
    nextSample: samples[5],
    maxSamples: 4,
  });

  assert(reduced.length <= 4, "Replay sample buffer must stay capped.");
  assert(
    reduced[reduced.length - 1].recordedAt.getTime() ===
      samples[5].recordedAt.getTime(),
    "Replay sample reduction must preserve the newest sample.",
  );
}

async function main(): Promise<void> {
  await testHaversineDistanceMeters();
  await testCircularGeofence();
  await testDistanceToPolylineMeters();
  await testPolylineRoundTrip();
  await testAppendReplaySampleRetainsNewestPoint();
  // eslint-disable-next-line no-console
  console.log("operationalMonitoringMath tests passed.");
}

main().catch((error) => {
  // eslint-disable-next-line no-console
  console.error(error);
  throw error;
});
