import * as logger from "firebase-functions/logger";
import {
  encodePolyline,
  haversineDistanceMeters,
} from "./operationalMonitoringMath";
import {
  type ExpectedRoute,
  type GeoPointLiteral,
} from "./operationalMonitoringTypes";

const GOOGLE_DIRECTIONS_LANGUAGE = "pt-PT";
const FALLBACK_SPEED_KMH = 35;

export async function fetchExpectedRoute(params: {
  origin: GeoPointLiteral;
  destination: GeoPointLiteral;
  routeKey: string;
}): Promise<ExpectedRoute> {
  const { origin, destination, routeKey } = params;
  const apiKey =
    process.env.GOOGLE_DIRECTIONS_API_KEY ||
    process.env.GOOGLE_MAPS_API_KEY ||
    "";
  if (!apiKey) {
    logger.warn("Directions API key missing for operational monitoring.", {
      routeKey,
    });
    return buildFallbackRoute({ origin, destination, routeKey });
  }

  const uri = new URL("https://maps.googleapis.com/maps/api/directions/json");
  uri.searchParams.set("origin", `${origin.latitude},${origin.longitude}`);
  uri.searchParams.set(
    "destination",
    `${destination.latitude},${destination.longitude}`,
  );
  uri.searchParams.set("mode", "driving");
  uri.searchParams.set("language", GOOGLE_DIRECTIONS_LANGUAGE);
  uri.searchParams.set("key", apiKey);

  try {
    const response = await fetch(uri.toString());
    if (!response.ok) {
      logger.warn("Directions HTTP request failed.", {
        routeKey,
        status: response.status,
      });
      return buildFallbackRoute({ origin, destination, routeKey });
    }
    const payload = (await response.json()) as Record<string, unknown>;
    if (payload.status !== "OK") {
      logger.warn("Directions response status invalid.", {
        routeKey,
        status: payload.status ?? null,
      });
      return buildFallbackRoute({ origin, destination, routeKey });
    }
    const routes = Array.isArray(payload.routes) ? payload.routes : [];
    const route = routes[0] as Record<string, unknown> | undefined;
    const legs = Array.isArray(route?.legs) ? route.legs : [];
    const leg = legs[0] as Record<string, unknown> | undefined;
    const distanceMeters = readNestedNumber(leg, "distance", "value");
    const durationSeconds = readNestedNumber(leg, "duration", "value");
    const polyline =
      readNestedString(route, "overview_polyline", "points") ?? "";
    if (distanceMeters == null || durationSeconds == null || polyline.length === 0) {
      logger.warn("Directions payload incomplete.", {
        routeKey,
        hasDistance: distanceMeters != null,
        hasDuration: durationSeconds != null,
        hasPolyline: polyline.length > 0,
      });
      return buildFallbackRoute({ origin, destination, routeKey });
    }
    return {
      routeKey,
      origin,
      destination,
      encodedPolyline: polyline,
      distanceKm: distanceMeters / 1000,
      durationMinutes: Math.max(1, Math.ceil(durationSeconds / 60)),
      isFallback: false,
      fetchedAt: new Date(),
    };
  } catch (error) {
    logger.error("Directions request failed unexpectedly.", {
      routeKey,
      error,
    });
    return buildFallbackRoute({ origin, destination, routeKey });
  }
}

export function buildRouteKey(params: {
  operationalWindowId: string;
  origin: GeoPointLiteral;
  destination: GeoPointLiteral;
}): string {
  const { operationalWindowId, origin, destination } = params;
  return [
    operationalWindowId,
    origin.latitude.toFixed(5),
    origin.longitude.toFixed(5),
    destination.latitude.toFixed(5),
    destination.longitude.toFixed(5),
  ].join("|");
}

function buildFallbackRoute(params: {
  origin: GeoPointLiteral;
  destination: GeoPointLiteral;
  routeKey: string;
}): ExpectedRoute {
  const { origin, destination, routeKey } = params;
  const distanceMeters = haversineDistanceMeters(origin, destination);
  const durationMinutes =
    distanceMeters === 0 ? 0 : Math.ceil((distanceMeters / 1000 / FALLBACK_SPEED_KMH) * 60);
  return {
    routeKey,
    origin,
    destination,
    encodedPolyline: encodePolyline([origin, destination]),
    distanceKm: distanceMeters / 1000,
    durationMinutes,
    isFallback: true,
    fetchedAt: new Date(),
  };
}

function readNestedNumber(
  source: Record<string, unknown> | undefined,
  field: string,
  nestedField: string,
): number | null {
  const nested = source?.[field];
  if (!nested || typeof nested !== "object") {
    return null;
  }
  const value = (nested as Record<string, unknown>)[nestedField];
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

function readNestedString(
  source: Record<string, unknown> | undefined,
  field: string,
  nestedField: string,
): string | null {
  const nested = source?.[field];
  if (!nested || typeof nested !== "object") {
    return null;
  }
  const value = (nested as Record<string, unknown>)[nestedField];
  return typeof value === "string" && value.trim().length > 0 ? value : null;
}
