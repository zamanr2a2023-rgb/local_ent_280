import {
  type CircularGeofence,
  type GeoPointLiteral,
  type ReplaySample,
} from "./operationalMonitoringTypes";

const EARTH_RADIUS_METERS = 6371000;

export function haversineDistanceMeters(
  from: GeoPointLiteral,
  to: GeoPointLiteral,
): number {
  const latDelta = toRadians(to.latitude - from.latitude);
  const lngDelta = toRadians(to.longitude - from.longitude);
  const fromLat = toRadians(from.latitude);
  const toLat = toRadians(to.latitude);
  const a =
    Math.sin(latDelta / 2) ** 2 +
    Math.cos(fromLat) * Math.cos(toLat) * Math.sin(lngDelta / 2) ** 2;
  return EARTH_RADIUS_METERS * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

export function isInsideCircularGeofence(params: {
  point: GeoPointLiteral;
  geofence: CircularGeofence | null | undefined;
}): boolean {
  const { point, geofence } = params;
  if (!geofence) {
    return false;
  }
  return (
    haversineDistanceMeters(point, geofence.center) <= geofence.radiusMeters
  );
}

export function distanceToPolylineMeters(params: {
  point: GeoPointLiteral;
  polyline: GeoPointLiteral[];
}): number {
  const { point, polyline } = params;
  if (polyline.length === 0) {
    return Number.POSITIVE_INFINITY;
  }
  if (polyline.length === 1) {
    return haversineDistanceMeters(point, polyline[0]);
  }
  const pointXY = projectPoint(point, point.latitude);
  let minDistance = Number.POSITIVE_INFINITY;
  for (let i = 0; i < polyline.length - 1; i += 1) {
    const startXY = projectPoint(polyline[i], point.latitude);
    const endXY = projectPoint(polyline[i + 1], point.latitude);
    const distance = distancePointToSegmentMeters(pointXY, startXY, endXY);
    if (distance < minDistance) {
      minDistance = distance;
    }
  }
  return minDistance;
}

export function decodePolyline(encoded: string): GeoPointLiteral[] {
  const points: GeoPointLiteral[] = [];
  let index = 0;
  let latitude = 0;
  let longitude = 0;
  while (index < encoded.length) {
    let result = 0;
    let shift = 0;
    let byte = 0;
    do {
      byte = encoded.charCodeAt(index) - 63;
      index += 1;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20 && index < encoded.length);
    const deltaLat = (result & 1) !== 0 ? ~(result >> 1) : result >> 1;
    latitude += deltaLat;

    result = 0;
    shift = 0;
    do {
      byte = encoded.charCodeAt(index) - 63;
      index += 1;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20 && index < encoded.length);
    const deltaLng = (result & 1) !== 0 ? ~(result >> 1) : result >> 1;
    longitude += deltaLng;

    points.push({
      latitude: latitude / 1e5,
      longitude: longitude / 1e5,
    });
  }
  return points;
}

export function encodePolyline(points: GeoPointLiteral[]): string {
  let previousLatitude = 0;
  let previousLongitude = 0;
  let encoded = "";
  for (const point of points) {
    const latitude = Math.round(point.latitude * 1e5);
    const longitude = Math.round(point.longitude * 1e5);
    encoded += encodeSignedNumber(latitude - previousLatitude);
    encoded += encodeSignedNumber(longitude - previousLongitude);
    previousLatitude = latitude;
    previousLongitude = longitude;
  }
  return encoded;
}

export function appendReplaySample(params: {
  samples: ReplaySample[];
  nextSample: ReplaySample;
  maxSamples: number;
}): ReplaySample[] {
  const merged = [...params.samples, params.nextSample];
  if (merged.length <= params.maxSamples) {
    return merged;
  }
  const stride = Math.ceil(merged.length / params.maxSamples);
  const reduced = merged.filter((_, index) => index % stride === 0);
  const last = merged[merged.length - 1];
  if (reduced[reduced.length - 1] !== last) {
    reduced[reduced.length - 1] = last;
  }
  return reduced.slice(-params.maxSamples);
}

function projectPoint(point: GeoPointLiteral, referenceLatitude: number): {
  x: number;
  y: number;
} {
  const latitudeRadians = toRadians(point.latitude);
  const longitudeRadians = toRadians(point.longitude);
  const referenceRadians = toRadians(referenceLatitude);
  return {
    x: EARTH_RADIUS_METERS * longitudeRadians * Math.cos(referenceRadians),
    y: EARTH_RADIUS_METERS * latitudeRadians,
  };
}

function distancePointToSegmentMeters(
  point: { x: number; y: number },
  start: { x: number; y: number },
  end: { x: number; y: number },
): number {
  const deltaX = end.x - start.x;
  const deltaY = end.y - start.y;
  if (deltaX === 0 && deltaY === 0) {
    return Math.hypot(point.x - start.x, point.y - start.y);
  }
  const projection =
    ((point.x - start.x) * deltaX + (point.y - start.y) * deltaY) /
    (deltaX * deltaX + deltaY * deltaY);
  const clamped = Math.max(0, Math.min(1, projection));
  const projectedX = start.x + deltaX * clamped;
  const projectedY = start.y + deltaY * clamped;
  return Math.hypot(point.x - projectedX, point.y - projectedY);
}

function encodeSignedNumber(value: number): string {
  let current = value < 0 ? ~(value << 1) : value << 1;
  let encoded = "";
  while (current >= 0x20) {
    encoded += String.fromCharCode((0x20 | (current & 0x1f)) + 63);
    current >>= 5;
  }
  encoded += String.fromCharCode(current + 63);
  return encoded;
}

function toRadians(value: number): number {
  return (value * Math.PI) / 180;
}
