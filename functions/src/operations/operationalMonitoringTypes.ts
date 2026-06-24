export const OPERATIONAL_WINDOW_TYPES = {
  activeTrip: "active_trip",
  postDropoff: "post_dropoff",
  noTripOperational: "no_trip_operational",
} as const;

export type OperationalWindowType =
  (typeof OPERATIONAL_WINDOW_TYPES)[keyof typeof OPERATIONAL_WINDOW_TYPES];

export const OPERATIONAL_STATES = {
  onActiveTrip: "on_active_trip",
  postDropoffWaiting: "post_dropoff_waiting",
  returningToBase: "returning_to_base",
  atBase: "at_base",
  approvedReposition: "approved_reposition",
  operationalIdle: "operational_idle",
  offDuty: "off_duty",
} as const;

export type OperationalState =
  (typeof OPERATIONAL_STATES)[keyof typeof OPERATIONAL_STATES];

export const OPERATIONAL_INCIDENT_TYPES = {
  activeTripRouteDeviation: "active_trip_route_deviation",
  postDropoffUnauthorizedMovement: "post_dropoff_unauthorized_movement",
} as const;

export type OperationalIncidentType =
  (typeof OPERATIONAL_INCIDENT_TYPES)[keyof typeof OPERATIONAL_INCIDENT_TYPES];

export const OPERATIONAL_INCIDENT_STATUSES = {
  open: "open",
  acknowledged: "acknowledged",
  approved: "approved",
  dismissed: "dismissed",
  confirmed: "confirmed",
} as const;

export type OperationalIncidentStatus =
  (typeof OPERATIONAL_INCIDENT_STATUSES)[keyof typeof OPERATIONAL_INCIDENT_STATUSES];

export const OPERATIONAL_APPROVAL_STATUSES = {
  active: "active",
  expired: "expired",
  completed: "completed",
  revoked: "revoked",
} as const;

export type OperationalApprovalStatus =
  (typeof OPERATIONAL_APPROVAL_STATUSES)[keyof typeof OPERATIONAL_APPROVAL_STATUSES];

export type GeoPointLiteral = {
  latitude: number;
  longitude: number;
};

export type CircularGeofence = {
  label?: string;
  center: GeoPointLiteral;
  radiusMeters: number;
};

export type LocationSnapshot = GeoPointLiteral & {
  heading?: number;
  speed?: number;
  recordedAt: Date;
};

export type ReplaySample = GeoPointLiteral & {
  recordedAt: Date;
};

export type ExpectedRoute = {
  routeKey: string;
  origin: GeoPointLiteral;
  destination: GeoPointLiteral;
  encodedPolyline: string;
  distanceKm: number;
  durationMinutes: number;
  isFallback: boolean;
  fetchedAt: Date;
};

export type OperationalMonitoringConfig = {
  enabled: boolean;
  baseGeofence: CircularGeofence | null;
  serviceGeofences: CircularGeofence[];
  dropoffWaitingRadiusMeters: number;
  postDropoffGracePeriodMinutes: number;
  routeDeviationCorridorMeters: number;
  sustainedDeviationThresholdSeconds: number;
  activeTripVarianceToleranceKm: number;
  activeTripVarianceTolerancePct: number;
  postDropoffLocalMovementAllowanceKm: number;
  postDropoffVarianceToleranceKm: number;
  postDropoffVarianceTolerancePct: number;
  noTripLocalMovementAllowanceKm: number;
  noTripMovementGracePeriodMinutes: number;
  nextAssignmentSuppressionLookaheadMinutes: number;
  staleTelemetryThresholdSeconds: number;
  incidentClearanceThresholdSeconds: number;
  replaySampleMinDistanceMeters: number;
  replaySampleMinIntervalSeconds: number;
  approvalDestinationArrivalRadiusMeters: number;
};

export type DriverOperationalStateDocument = {
  driverId: string;
  driverName?: string;
  vehicleId?: string | null;
  vehiclePlate?: string | null;
  tripId?: string | null;
  linkedTripId?: string | null;
  operationalWindowId?: string | null;
  operationalWindowType?: OperationalWindowType | null;
  currentState: OperationalState;
  monitoringSuppressed?: boolean;
  suppressionReason?: string | null;
  latestLocation?: LocationSnapshot | null;
  lastProcessedRtdbTimestamp?: Date | null;
  currentOpenIncidentId?: string | null;
  activeApprovalSummary?: {
    approvalId: string;
    reason: string;
    expiresAt: Date;
    destinationLabel?: string | null;
  } | null;
  cachedExpectedRoute?: ExpectedRoute | null;
  replaySamples?: ReplaySample[];
  actualWindowDistanceKm?: number;
  windowStartedAt?: Date | null;
  windowAnchorLocation?: GeoPointLiteral | null;
  dropoffLocation?: GeoPointLiteral | null;
  dropoffAt?: Date | null;
  graceEndsAt?: Date | null;
  lastDistanceToTripDestinationMeters?: number | null;
  lastDistanceToBaseMeters?: number | null;
  nonCompliantSinceAt?: Date | null;
  compliantSinceAt?: Date | null;
  updatedAt?: Date | null;
};

export type TripOperationalMetricsDocument = {
  tripId: string;
  driverId?: string | null;
  vehicleId?: string | null;
  activeTripOperationalWindowId?: string | null;
  postDropoffOperationalWindowId?: string | null;
  latestNoTripOperationalWindowId?: string | null;
  expectedTripDistanceKm?: number | null;
  actualTripDistanceKm?: number | null;
  tripDistanceVarianceKm?: number | null;
  tripDistanceVariancePct?: number | null;
  expectedPostDropoffDistanceKm?: number | null;
  actualPostDropoffDistanceKm?: number | null;
  postDropoffVarianceKm?: number | null;
  postDropoffVariancePct?: number | null;
  expectedNoTripDistanceKm?: number | null;
  actualNoTripDistanceKm?: number | null;
  noTripVarianceKm?: number | null;
  noTripVariancePct?: number | null;
  totalExpectedDistanceKm?: number | null;
  totalActualDistanceKm?: number | null;
  totalVarianceKm?: number | null;
  totalVariancePct?: number | null;
  expectedTripPolyline?: string | null;
  expectedPostDropoffPolyline?: string | null;
  startedAt?: Date | null;
  arrivedDestinationAt?: Date | null;
  postDropoffWindowStartedAt?: Date | null;
  postDropoffWindowEndedAt?: Date | null;
  baseArrivedAt?: Date | null;
  nextAssignmentAt?: Date | null;
  offDutyAt?: Date | null;
  noTripWindowStartedAt?: Date | null;
  noTripWindowEndedAt?: Date | null;
  retentionExpiresAt?: Date | null;
  updatedAt?: Date | null;
};

export type OperationalIncidentDocument = {
  operationalWindowId: string;
  operationalWindowType: OperationalWindowType;
  driverId: string;
  driverName?: string;
  vehicleId?: string | null;
  vehiclePlate?: string | null;
  tripId?: string | null;
  incidentType: OperationalIncidentType;
  subreason?: string | null;
  status: OperationalIncidentStatus;
  startedAt: Date;
  resolvedAt?: Date | null;
  resolutionSource?: "system" | "reviewer" | null;
  resolutionReason?: string | null;
  currentState: OperationalState;
  originCoordinates: LocationSnapshot;
  latestCoordinates: LocationSnapshot;
  expectedPolyline?: string | null;
  actualPathSamples: ReplaySample[];
  expectedTripDistanceKm?: number | null;
  actualTripDistanceKm?: number | null;
  tripDistanceVarianceKm?: number | null;
  tripDistanceVariancePct?: number | null;
  expectedPostDropoffDistanceKm?: number | null;
  actualPostDropoffDistanceKm?: number | null;
  postDropoffVarianceKm?: number | null;
  postDropoffVariancePct?: number | null;
  expectedNoTripDistanceKm?: number | null;
  actualNoTripDistanceKm?: number | null;
  noTripVarianceKm?: number | null;
  noTripVariancePct?: number | null;
  totalExpectedDistanceKm?: number | null;
  totalActualDistanceKm?: number | null;
  totalVarianceKm?: number | null;
  totalVariancePct?: number | null;
  tripStartedAt?: Date | null;
  dropoffAt?: Date | null;
  postDropoffWindowStartedAt?: Date | null;
  baseArrivedAt?: Date | null;
  nextAssignmentAt?: Date | null;
  offDutyAt?: Date | null;
  reviewNote?: string | null;
  clearanceCandidateStartedAt?: Date | null;
  retentionExpiresAt?: Date | null;
  createdAt?: Date | null;
  updatedAt?: Date | null;
};

export type OperationalMovementApprovalDocument = {
  operationalWindowId: string;
  operationalWindowType: OperationalWindowType;
  driverId: string;
  driverName?: string;
  vehicleId?: string | null;
  vehiclePlate?: string | null;
  tripId?: string | null;
  reason: string;
  expiresAt: Date;
  destination?: (GeoPointLiteral & { address?: string }) | null;
  allowedArea?: CircularGeofence | null;
  approvedBy: string;
  approvedByRole: "admin" | "manager";
  status: OperationalApprovalStatus;
  incidentId?: string | null;
  createdAt?: Date | null;
  updatedAt?: Date | null;
  retentionExpiresAt?: Date | null;
};

export const OPERATIONAL_MONITORING_COLLECTIONS = {
  driverOperationalStates: "driverOperationalStates",
  tripOperationalMetrics: "tripOperationalMetrics",
  operationalIncidents: "operationalIncidents",
  operationalMovementApprovals: "operationalMovementApprovals",
  config: "config",
} as const;

export const OPERATIONAL_MONITORING_EVENT_ACTIONS = {
  created: "created",
  acknowledged: "acknowledged",
  dismissed: "dismissed",
  confirmed: "confirmed",
  approvedException: "approved_exception",
  autoResolved: "auto_resolved",
  approvalCreated: "approval_created",
} as const;
