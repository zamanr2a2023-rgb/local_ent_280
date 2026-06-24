import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {
  type CircularGeofence,
  type GeoPointLiteral,
  type OperationalMonitoringConfig,
} from "./operationalMonitoringTypes";

const DEFAULT_CONFIG: OperationalMonitoringConfig = {
  enabled: false,
  baseGeofence: null,
  serviceGeofences: [],
  dropoffWaitingRadiusMeters: 250,
  postDropoffGracePeriodMinutes: 8,
  routeDeviationCorridorMeters: 300,
  sustainedDeviationThresholdSeconds: 180,
  activeTripVarianceToleranceKm: 1.5,
  activeTripVarianceTolerancePct: 12,
  postDropoffLocalMovementAllowanceKm: 0.5,
  postDropoffVarianceToleranceKm: 0.8,
  postDropoffVarianceTolerancePct: 18,
  noTripLocalMovementAllowanceKm: 1,
  noTripMovementGracePeriodMinutes: 10,
  nextAssignmentSuppressionLookaheadMinutes: 30,
  staleTelemetryThresholdSeconds: 180,
  incidentClearanceThresholdSeconds: 180,
  replaySampleMinDistanceMeters: 75,
  replaySampleMinIntervalSeconds: 30,
  approvalDestinationArrivalRadiusMeters: 300,
};

export async function loadOperationalMonitoringConfig(params: {
  firestore: admin.firestore.Firestore;
}): Promise<OperationalMonitoringConfig> {
  const { firestore } = params;
  const snapshot = await firestore.doc("config/operations_monitoring").get();
  if (!snapshot.exists) {
    logger.warn("Operational monitoring config missing; using defaults.");
    return DEFAULT_CONFIG;
  }
  const data = snapshot.data() ?? {};
  return {
    enabled: data.enabled === true,
    baseGeofence: parseCircularGeofence(data.baseGeofence),
    serviceGeofences: parseGeofenceList(data.serviceGeofences),
    dropoffWaitingRadiusMeters:
      parsePositiveNumber(data.dropoffWaitingRadiusMeters) ??
      DEFAULT_CONFIG.dropoffWaitingRadiusMeters,
    postDropoffGracePeriodMinutes:
      parsePositiveNumber(data.postDropoffGracePeriodMinutes) ??
      DEFAULT_CONFIG.postDropoffGracePeriodMinutes,
    routeDeviationCorridorMeters:
      parsePositiveNumber(data.routeDeviationCorridorMeters) ??
      DEFAULT_CONFIG.routeDeviationCorridorMeters,
    sustainedDeviationThresholdSeconds:
      parsePositiveNumber(data.sustainedDeviationThresholdSeconds) ??
      DEFAULT_CONFIG.sustainedDeviationThresholdSeconds,
    activeTripVarianceToleranceKm:
      parsePositiveNumber(data.activeTripVarianceToleranceKm) ??
      DEFAULT_CONFIG.activeTripVarianceToleranceKm,
    activeTripVarianceTolerancePct:
      parsePositiveNumber(data.activeTripVarianceTolerancePct) ??
      DEFAULT_CONFIG.activeTripVarianceTolerancePct,
    postDropoffLocalMovementAllowanceKm:
      parsePositiveNumber(data.postDropoffLocalMovementAllowanceKm) ??
      DEFAULT_CONFIG.postDropoffLocalMovementAllowanceKm,
    postDropoffVarianceToleranceKm:
      parsePositiveNumber(data.postDropoffVarianceToleranceKm) ??
      DEFAULT_CONFIG.postDropoffVarianceToleranceKm,
    postDropoffVarianceTolerancePct:
      parsePositiveNumber(data.postDropoffVarianceTolerancePct) ??
      DEFAULT_CONFIG.postDropoffVarianceTolerancePct,
    noTripLocalMovementAllowanceKm:
      parsePositiveNumber(data.noTripLocalMovementAllowanceKm) ??
      DEFAULT_CONFIG.noTripLocalMovementAllowanceKm,
    noTripMovementGracePeriodMinutes:
      parsePositiveNumber(data.noTripMovementGracePeriodMinutes) ??
      DEFAULT_CONFIG.noTripMovementGracePeriodMinutes,
    nextAssignmentSuppressionLookaheadMinutes:
      parsePositiveNumber(data.nextAssignmentSuppressionLookaheadMinutes) ??
      DEFAULT_CONFIG.nextAssignmentSuppressionLookaheadMinutes,
    staleTelemetryThresholdSeconds:
      parsePositiveNumber(data.staleTelemetryThresholdSeconds) ??
      DEFAULT_CONFIG.staleTelemetryThresholdSeconds,
    incidentClearanceThresholdSeconds:
      parsePositiveNumber(data.incidentClearanceThresholdSeconds) ??
      DEFAULT_CONFIG.incidentClearanceThresholdSeconds,
    replaySampleMinDistanceMeters:
      parsePositiveNumber(data.replaySampleMinDistanceMeters) ??
      DEFAULT_CONFIG.replaySampleMinDistanceMeters,
    replaySampleMinIntervalSeconds:
      parsePositiveNumber(data.replaySampleMinIntervalSeconds) ??
      DEFAULT_CONFIG.replaySampleMinIntervalSeconds,
    approvalDestinationArrivalRadiusMeters:
      parsePositiveNumber(data.approvalDestinationArrivalRadiusMeters) ??
      DEFAULT_CONFIG.approvalDestinationArrivalRadiusMeters,
  };
}

export function hasOperationalBaseConfig(
  config: OperationalMonitoringConfig,
): boolean {
  return config.baseGeofence != null;
}

function parseGeofenceList(value: unknown): CircularGeofence[] {
  if (!Array.isArray(value)) {
    return [];
  }
  return value
    .map((entry) => parseCircularGeofence(entry))
    .filter((entry): entry is CircularGeofence => entry != null);
}

function parseCircularGeofence(value: unknown): CircularGeofence | null {
  if (!value || typeof value !== "object") {
    return null;
  }
  const source = value as Record<string, unknown>;
  const center = parseGeoPoint(source.center);
  const radiusMeters = parsePositiveNumber(source.radiusMeters);
  if (!center || radiusMeters == null) {
    return null;
  }
  return {
    label: normalizeOptionalString(source.label),
    center,
    radiusMeters,
  };
}

function parseGeoPoint(value: unknown): GeoPointLiteral | null {
  if (!value || typeof value !== "object") {
    return null;
  }
  const source = value as Record<string, unknown>;
  const latitude = parseNumber(source.latitude);
  const longitude = parseNumber(source.longitude);
  if (latitude == null || longitude == null) {
    return null;
  }
  return {
    latitude,
    longitude,
  };
}

function normalizeOptionalString(value: unknown): string | undefined {
  if (typeof value !== "string") {
    return undefined;
  }
  const normalized = value.trim();
  return normalized.length > 0 ? normalized : undefined;
}

function parseNumber(value: unknown): number | null {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }
  return null;
}

function parsePositiveNumber(value: unknown): number | null {
  const parsed = parseNumber(value);
  if (parsed == null || parsed < 0) {
    return null;
  }
  return parsed;
}
