import {
  onDocumentCreated,
  onDocumentWritten,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { onTaskDispatched } from "firebase-functions/v2/tasks";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { getFunctions } from "firebase-admin/functions";
import { createHash } from "crypto";
import {
  EVENT_REMINDER_WINDOW_MINUTES,
  ScheduledEventSnapshot,
  evaluateEventReminder,
} from "../notifications/eventReminderEvaluator";
import {
  CRITICAL_CALLABLE_RUNTIME_OPTIONS,
  STANDARD_CALLABLE_RUNTIME_OPTIONS,
} from "../shared/constants";
import { buildTripStateMachineCallables } from "./tripStateMachineCallables";
import {
  resolveCallerRole,
  requireAuthenticatedUid,
} from "../shared/auth/rbacRoleResolver";
import {
  calculateDistanceTierChargeMinor,
  toMetersFromKm,
  type DistanceTierMinor,
} from "./distanceTierPricing";
import { parsePostChargeExtensionDurationMinutes } from "./postChargeExtensionDurationPolicy";
import {
  multiplyMinorAndCeil,
  multiplyMinorAndRoundHalfUp,
} from "./pricingMultiplierMath";

let firestore: admin.firestore.Firestore;
let realtimeDb: admin.database.Database;
let authService: admin.auth.Auth;
let messaging: admin.messaging.Messaging;

const ASSIGNMENT_TIMEOUT_MS = 5 * 60 * 1000;
const RESERVATION_ACTIVATION_HOUR = 5;
const RESERVATION_ACTIVATION_TIMEZONE = "Europe/Lisbon";
const PRICING_SCHEMA_VERSION = 3;
const AVERAGE_SPEED_KMH = 35;
const MIN_RESERVATION_WINDOW_MINUTES = 15;
const DRIVER_HEARTBEAT_STALE_MS = 3 * 60 * 1000;
const DRIVER_LOCATION_STALE_MS = 3 * 60 * 1000;
const OPERATION_CURRENCY_CODE = "EUR";
const INACTIVE_TRIP_STATUSES = new Set([
  "COMPLETED",
  "CHARGE_APPLIED",
  "CANCELLED_BY_CLIENT",
  "CANCELLED_BY_DRIVER",
  "NO_SHOW",
  "NO_DRIVERS_AVAILABLE",
]);
const VALID_TRIP_STATUSES = new Set([
  "REQUESTED",
  "DRIVER_ASSIGNED_WAITING_ACCEPTANCE",
  "DRIVER_ACCEPTED",
  "DRIVER_DECLINED",
  "NO_DRIVERS_AVAILABLE",
  "DRIVER_EN_ROUTE",
  "DRIVER_ARRIVED",
  "IN_TRIP",
  "ARRIVED_DESTINATION",
  "EXTENSION_WINDOW",
  "COMPLETED",
  "CHARGE_APPLIED",
  "CANCELLED_BY_CLIENT",
  "CANCELLED_BY_DRIVER",
  "NO_SHOW",
]);
const AVAILABILITY_RESTORE_TRIP_STATUSES = new Set([
  "CANCELLED_BY_CLIENT",
  "CANCELLED_BY_DRIVER",
  "NO_SHOW",
  "COMPLETED",
  "CHARGE_APPLIED",
]);
const ACTIVE_RESERVATION_STATUSES = ["scheduled", "pending", "confirmed"];
const JOB_LOCK_TTL_DAYS = 7;
const TRIP_EVENT_TTL_DAYS = 90;
const FCM_TOKEN_CLEANUP_BATCH_SIZE = 300;
const DRIVER_STATUS_COLLECTION = "driverStatus";
const POST_CHARGE_EXTENSION_SCHEMA_VERSION = 1;
const POST_CHARGE_EXTENSION_MAX_CYCLES = 6;
const POST_CHARGE_EXTENSION_DRIVER_PENDING_TIMEOUT_MS = 60 * 1000;
const POST_CHARGE_EXTENSION_SWEEP_BATCH_SIZE = 100;
const INTERNAL_STAFF_RESERVATION_SOURCE = "internal_staff";
const TASK_QUEUE_REGION = "europe-west1";
const DRIVER_ACCEPTANCE_TIMEOUT_TASK_FUNCTION_NAME = `locations/${TASK_QUEUE_REGION}/functions/processDriverAcceptanceTimeout`;
const POST_CHARGE_EXTENSION_TASK_FUNCTION_NAME = `locations/${TASK_QUEUE_REGION}/functions/processPostChargeExtensionNextAction`;

const POST_CHARGE_EXTENSION_STATUSES = {
  clientPrompt: "clientPrompt",
  driverPending: "driverPending",
  active: "active",
  chargeApplying: "chargeApplying",
  closed: "closed",
} as const;

type PostChargeExtensionStatus =
  (typeof POST_CHARGE_EXTENSION_STATUSES)[keyof typeof POST_CHARGE_EXTENSION_STATUSES];

const POST_CHARGE_EXTENSION_CLOSED_REASONS = {
  clientClosed: "client_closed",
  declinedByDriver: "declined_by_driver",
  driverUnavailable: "driver_unavailable",
  driverNoResponseTimeout: "driver_no_response_timeout",
  chargeFailed: "charge_failed",
  maxCycles: "max_cycles",
} as const;

type PostChargeExtensionClosedReason =
  (typeof POST_CHARGE_EXTENSION_CLOSED_REASONS)[keyof typeof POST_CHARGE_EXTENSION_CLOSED_REASONS];

const POST_CHARGE_EXTENSION_ERROR_CODES = {
  creditLimit: "credit_limit",
  invalidState: "invalid_state",
  notOwner: "not_owner",
  roleMismatch: "role_mismatch",
  alreadyProcessed: "already_processed",
  durationOutOfRange: "duration_out_of_range",
  driverUnavailable: "driver_unavailable",
  driverNoResponseTimeout: "driver_no_response_timeout",
  paymentInternal: "payment_internal",
  validationFailed: "validation_failed",
} as const;

type PostChargeExtensionErrorCode =
  (typeof POST_CHARGE_EXTENSION_ERROR_CODES)[keyof typeof POST_CHARGE_EXTENSION_ERROR_CODES];

type PostChargeExtensionCycleChargeStatus = "pending" | "succeeded" | "failed";

type PostChargeExtensionCycle = {
  cycleIndex: number;
  requestedMinutes: number;
  requestedAt?: Date;
  acceptedAt?: Date;
  startedAt?: Date;
  endsAt?: Date;
  endedAt?: Date;
  endedBy?: "client" | "system";
  actualSeconds?: number;
  billedMinutes?: number;
  waitRateApplied?: MoneyPayload;
  chargedAmount?: MoneyPayload;
  chargeStatus: PostChargeExtensionCycleChargeStatus;
  chargeFailedReason?: string;
};

type PostChargeExtensionFlow = {
  schemaVersion: number;
  isActive: boolean;
  status: PostChargeExtensionStatus;
  maxCycles: number;
  completedCyclesCount: number;
  nextActionAt?: Date;
  currentCycle?: PostChargeExtensionCycle;
  history: PostChargeExtensionCycle[];
  closedReason?: PostChargeExtensionClosedReason;
  lastErrorCode?: PostChargeExtensionErrorCode;
  createdAt?: Date;
  updatedAt?: Date;
};

type DriverAcceptanceTimeoutTaskPayload = {
  operation: "driver_acceptance_timeout";
  operationKey: string;
  tripId: string;
  assignedDriverId: string;
  assignmentAttempt: number;
  driverAssignedAtMillis: number;
};

type PostChargeExtensionTaskPayload = {
  operation: "post_charge_extension_next_action";
  operationKey: string;
  tripId: string;
  status:
    | typeof POST_CHARGE_EXTENSION_STATUSES.active
    | typeof POST_CHARGE_EXTENSION_STATUSES.driverPending;
  cycleIndex: number;
  nextActionAtMillis: number;
};

const DRIVER_LOCATION_PATH = "driverLocations";
const DRIVER_LOCATION_GEOHASH_FIELD = "g";
const DRIVER_LOCATION_COORDS_FIELD = "l";
const DRIVER_CANDIDATE_SEARCH_RADII_KM = [12, 24, 40, 60, 80, 100];
const MAX_DRIVER_CANDIDATES = 30;
const TRIP_EVENT_TYPE_STATE_TRANSITION = "state_transition";
const OPS_UNFULFILLED_NOTIFICATION_TYPE = "ops.trip_unfulfilled";
const TRIP_PACKAGE_TASK_FUNCTION_NAME =
  "locations/europe-southwest1/functions/activateTripPackageLeg";
const TRIP_PACKAGE_ACTIVATION_LEAD_TIME_MINUTES = 15;
const TRIP_PACKAGE_MIN_RETURN_GAP_MINUTES = 30;
const TRIP_PACKAGE_SOURCE = "package";
const TRIP_PACKAGE_FARE_COVERAGE_INCLUDED = "included";

export const TRIP_PACKAGE_BOOKING_STATUSES = {
  confirmed: "confirmed",
  partiallyUsed: "partiallyUsed",
  partiallyCancelled: "partiallyCancelled",
  completed: "completed",
  cancelled: "cancelled",
  opsException: "opsException",
} as const;

type TripPackageBookingStatus =
  (typeof TRIP_PACKAGE_BOOKING_STATUSES)[keyof typeof TRIP_PACKAGE_BOOKING_STATUSES];

export const TRIP_PACKAGE_REFUND_STATUSES = {
  none: "none",
  partial: "partial",
  full: "full",
} as const;

type TripPackageRefundStatus =
  (typeof TRIP_PACKAGE_REFUND_STATUSES)[keyof typeof TRIP_PACKAGE_REFUND_STATUSES];

export const TRIP_PACKAGE_LEG_STATUSES = {
  reserved: "reserved",
  activating: "activating",
  tripCreated: "tripCreated",
  cancelled: "cancelled",
  completed: "completed",
  opsException: "opsException",
} as const;

type TripPackageLegStatus =
  (typeof TRIP_PACKAGE_LEG_STATUSES)[keyof typeof TRIP_PACKAGE_LEG_STATUSES];

export const TRIP_PACKAGE_LEG_TYPES = {
  outbound: "outbound",
  return: "return",
} as const;

type TripPackageLegType =
  (typeof TRIP_PACKAGE_LEG_TYPES)[keyof typeof TRIP_PACKAGE_LEG_TYPES];

export const TRIP_PACKAGE_BOOKING_MODES = {
  oneWay: "oneWay",
  roundTrip: "roundTrip",
} as const;

type TripPackageBookingMode =
  (typeof TRIP_PACKAGE_BOOKING_MODES)[keyof typeof TRIP_PACKAGE_BOOKING_MODES];

type Coordinates = {
  latitude: number;
  longitude: number;
};

type DriverStatusSnapshot = {
  driverId: string;
  vehicleId: string | null;
  lastSeenAt: Date | null;
  availabilityEnabled: boolean;
  currentTripId: string | null;
  isBusy: boolean;
};

type DriverContactSnapshot = {
  driverId: string;
  name: string;
  phone: string;
  photoUrl?: string;
};

function isFirestoreDocumentMissingError(error: unknown): boolean {
  const firestoreError = error as { code?: unknown } | undefined;
  return firestoreError?.code === 5 || firestoreError?.code === "not-found";
}

type NearbyDriverCandidate = {
  id: string;
  location: Coordinates;
  distanceKm: number;
};

type DriverCandidate = NearbyDriverCandidate & {
  driverStatus: DriverStatusSnapshot;
};

type DriverVehicleCandidate = DriverCandidate & {
  vehicleId: string;
};

type DriverCandidateResolution = {
  candidates: DriverCandidate[];
  attemptedRadiiKm: number[];
  matchedRadiusKm: number | null;
  nearbyUniqueCount: number;
  filteredOutByStatusCount: number;
};

type DriverVehicleSelectionDiagnostics = {
  totalCandidates: number;
  missingVehicleCount: number;
  busyCount: number;
  reservedCount: number;
  reservationConflictCount: number;
};

type DriverVehicleSelectionResult = {
  assignment: DriverVehicleCandidate | null;
  diagnostics: DriverVehicleSelectionDiagnostics;
};

type GeoQueryBounds = {
  start: string;
  end: string;
  hash: string;
  precision: number;
};

type ReservationWindow = {
  start: Date;
  end: Date;
};

type ReservedAssignment = {
  driverId: string;
  vehicleId: string;
  window: ReservationWindow;
};

type TripLocationPayload = {
  latitude: number;
  longitude: number;
  address: string;
};

type TransportTypePayload = {
  id: string;
  name: string;
};

type TripPricingSnapshot = {
  baseMinor: number;
  perKmMinor: number;
  perWaitMinuteMinor: number;
  lateCancellationFeeMinor: number;
  noShowFeeMinor: number;
  distanceTiers: DistanceTierMinor[];
  pricingSchemaVersion?: number;
  tariffId?: string;
  tariffUpdatedAt?: Date;
  appliedMultiplierId?: string;
  appliedMultiplier?: number;
  pricingScheduleId?: string;
  specialDayId?: string;
  resolvedBaseTransportTypeId?: string;
  resolvedBaseSource?: string;
  transportMultiplier?: number;
  timeRangeMultiplier?: number;
  holidayMultiplier?: number;
  evaluationTimestamp?: Date;
  evaluationTimeZone?: string;
  multipliers: Record<string, number>;
  estimatedTotalMinor?: number;
};

type TariffMultiplierRulePayload = {
  id: string;
  type: "time_range" | "holiday";
  multiplier: number;
  startMinutes?: number;
  endMinutes?: number;
  holidayDates: string[];
};

type ReservationTariffSeed = {
  baseByTransportType: Record<string, number>;
  perKmMinor: number;
  perWaitMinuteMinor: number;
  lateCancellationFeeMinor: number;
  noShowFeeMinor: number;
  distanceTiers: DistanceTierMinor[];
  tariffId?: string;
  tariffUpdatedAt?: Date;
  multiplierRules: TariffMultiplierRulePayload[];
};

type TripMeteringSnapshot = {
  totalMinutes: number;
  totalWaitMinutes: number;
  totalDistanceKm: number;
  estimatedCostMinor: number;
  activeMultiplierId?: string;
};

function buildOperationLockRef(
  operationId: string,
): admin.firestore.DocumentReference {
  return firestore.collection("jobs").doc(`op_${operationId}`);
}

function buildTtlTimestamp(days: number): Timestamp {
  const ttlDate = new Date(Date.now() + days * 24 * 60 * 60 * 1000);
  return Timestamp.fromDate(ttlDate);
}

function buildTripEventTtlField(): Record<string, unknown> {
  return {
    tripEventExpiresAt: buildTtlTimestamp(TRIP_EVENT_TTL_DAYS),
  };
}

async function acquireOperationLock(params: {
  operationId: string;
  operationType: string;
  tripId?: string;
}): Promise<boolean> {
  const { operationId, operationType, tripId } = params;
  const lockRef = buildOperationLockRef(operationId);
  const lockClaimed = await firestore.runTransaction(async (transaction) => {
    const lockSnapshot = await transaction.get(lockRef);
    if (lockSnapshot.exists) {
      return false;
    }
    transaction.set(lockRef, {
      operationId,
      operationType,
      tripId: tripId ?? null,
      status: "running",
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      expiresAt: buildTtlTimestamp(JOB_LOCK_TTL_DAYS),
    });
    return true;
  });
  if (!lockClaimed) {
    logger.info(
      "Operation lock already claimed, skipping duplicate execution.",
      {
        operationId,
        operationType,
        tripId,
        lockPath: lockRef.path,
      },
    );
    return false;
  }
  logger.info("Operation lock claimed.", {
    operationId,
    operationType,
    tripId,
    lockPath: lockRef.path,
  });
  return true;
}

async function completeOperationLock(params: {
  operationId: string;
  status: "completed" | "failed";
  errorMessage?: string;
}): Promise<void> {
  const { operationId, status, errorMessage } = params;
  const lockRef = buildOperationLockRef(operationId);
  await lockRef.set(
    {
      status,
      errorMessage: errorMessage ?? null,
      updatedAt: FieldValue.serverTimestamp(),
      releasedAt: FieldValue.serverTimestamp(),
      expiresAt: buildTtlTimestamp(JOB_LOCK_TTL_DAYS),
    },
    { merge: true },
  );
}

type ClientDiscountConfig = {
  discountPercentGlobal?: number;
  discountPercentByDistance?: number;
  discountFixedMinor?: number;
};

type TripChargeDiscountBreakdown = {
  discountPercentGlobal?: number;
  discountPercentByDistance?: number;
  discountFixedMinor?: number;
  discountGlobalMinor: number;
  discountDistanceMinor: number;
  discountFixedMinorApplied: number;
  discountTotalMinor: number;
};

type TripChargeBreakdown = {
  baseMinor: number;
  distanceMinor: number;
  waitMinor: number;
  penaltiesMinor: number;
  surchargeMinor: number;
  subtotalMinor: number;
  multiplierId?: string;
  multiplierValue: number;
  multiplierChargeMinor: number;
  discountMinor: number;
  discountBreakdown: TripChargeDiscountBreakdown;
  totalMinor: number;
  totalDistanceKm: number;
  totalMinutes: number;
  totalWaitMinutes: number;
  hasMeteringData: boolean;
  calculatedFrom: "metering" | "fallback" | "estimate";
};

type RequestTripPayload = {
  tripId: string;
  tripData: Record<string, unknown>;
};

type MoneyPayload = {
  amountMinor: number;
  currency: string;
};

type TripPackageDocument = {
  id: string;
  name: string;
  description: string;
  photoUrl: string;
  destination: TripLocationPayload;
  transportType: TransportTypePayload;
  oneWayPrice: MoneyPayload;
  roundTripPrice: MoneyPayload;
  isActive: boolean;
  minimumLeadTimeMinutes: number;
  minimumReturnGapMinutes: number;
  activationLeadTimeMinutes: number;
  snapshotVersion: number;
  checkoutCopy: string;
};

type TripPackageSnapshot = {
  packageId: string;
  packageSnapshotVersion: number;
  name: string;
  description: string;
  photoUrl: string;
  destination: TripLocationPayload;
  transportType: TransportTypePayload;
  oneWayPrice: MoneyPayload;
  roundTripPrice: MoneyPayload;
  minimumLeadTimeMinutes: number;
  minimumReturnGapMinutes: number;
  activationLeadTimeMinutes: number;
  refundPolicy: {
    fullCancellationBeforeOutboundActivation: boolean;
    returnLegCancellationBeforeActivation: boolean;
  };
  checkoutCopy: string;
};

type TripPackageBookingLegPlan = {
  legType: TripPackageLegType;
  pickupAt: Date;
  pickup: TripLocationPayload;
  dropoff: TripLocationPayload;
  activationAt: Date;
};

type TripPackageBookingLegAssignment = TripPackageBookingLegPlan & {
  assignedDriverId: string;
  vehicleId: string;
  reservationId: string;
  taskId: string;
};

type TripPackageBookingDocument = {
  clientId: string;
  packageId: string;
  packageSnapshot: TripPackageSnapshot;
  mode: TripPackageBookingMode;
  status: TripPackageBookingStatus;
  refundStatus: TripPackageRefundStatus;
  chargedAmount: MoneyPayload;
  refundedAmount: MoneyPayload;
};

type TripEligibilitySnapshot = {
  balance: MoneyPayload;
  debtLimit: MoneyPayload;
};

type LimitExceededDetails = {
  reason: "LIMIT_EXCEEDED";
  operation: string;
  currency: string;
  balanceBeforeMinor: number;
  debitAmountMinor: number;
  balanceAfterMinor: number;
  creditLimitMinor: number;
};

function isMoneyPayload(value: unknown): value is MoneyPayload {
  if (!value || typeof value !== "object") {
    return false;
  }
  const payload = value as Record<string, unknown>;
  return (
    typeof payload.amountMinor === "number" &&
    typeof payload.currency === "string" &&
    payload.currency.trim().length > 0
  );
}

function parseTripPackageCoordinates(value: unknown): Coordinates | null {
  if (!value || typeof value !== "object") {
    return null;
  }
  const record = value as Record<string, unknown>;
  const latitude = typeof record.latitude === "number" ? record.latitude : null;
  const longitude =
    typeof record.longitude === "number" ? record.longitude : null;
  if (latitude == null || longitude == null) {
    return null;
  }
  return { latitude, longitude };
}

function parseTripPackageLocationPayload(
  value: unknown,
): TripLocationPayload | null {
  if (!value || typeof value !== "object") {
    return null;
  }
  const record = value as Record<string, unknown>;
  const coordinates = parseTripPackageCoordinates(record);
  if (!coordinates) {
    return null;
  }
  const address = typeof record.address === "string" ? record.address : "";
  return {
    ...coordinates,
    address,
  };
}

function parseTripPackageTransportTypePayload(
  value: unknown,
): TransportTypePayload | null {
  if (!value || typeof value !== "object") {
    return null;
  }
  const record = value as Record<string, unknown>;
  const id = typeof record.id === "string" ? record.id.trim() : "";
  const name = typeof record.name === "string" ? record.name.trim() : "";
  if (!id || !name) {
    return null;
  }
  return { id, name };
}

function parseTripPackageOptionalInteger(value: unknown): number | null {
  return typeof value === "number" &&
    !Number.isNaN(value) &&
    Number.isInteger(value)
    ? value
    : null;
}

function getTripPackageLocalDateParts(
  date: Date,
  timeZone: string,
): {
  year: number;
  month: number;
  day: number;
} {
  const formatter = new Intl.DateTimeFormat("en-CA", {
    timeZone,
    hour12: false,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  });
  const parts = formatter.formatToParts(date);
  const values = parts.reduce<Record<string, number>>((acc, part) => {
    if (part.type === "literal") {
      return acc;
    }
    acc[part.type] = Number.parseInt(part.value, 10);
    return acc;
  }, {});
  return {
    year: values.year ?? date.getUTCFullYear(),
    month: values.month ?? date.getUTCMonth() + 1,
    day: values.day ?? date.getUTCDate(),
  };
}

function buildTripPackageScheduledDayKey(date: Date, timeZone: string): string {
  const parts = getTripPackageLocalDateParts(date, timeZone);
  return [
    parts.year.toString().padStart(4, "0"),
    parts.month.toString().padStart(2, "0"),
    parts.day.toString().padStart(2, "0"),
  ].join("-");
}

function resolveMoneyPayload(value: unknown, fieldName: string): MoneyPayload {
  if (!isMoneyPayload(value)) {
    throw new HttpsError(
      "failed-precondition",
      `${fieldName} inválido ou ausente.`,
    );
  }
  return value;
}

function assertMoneyCurrencyOrThrow(params: {
  value: MoneyPayload;
  expectedCurrency: string;
  fieldName: string;
}): void {
  const { value, expectedCurrency, fieldName } = params;
  if (value.currency !== expectedCurrency) {
    throw new HttpsError(
      "failed-precondition",
      `${fieldName} com moeda incompatível.`,
      {
        reason: "CURRENCY_MISMATCH",
        field: fieldName,
        expectedCurrency,
        actualCurrency: value.currency,
      },
    );
  }
}

function parseTimestampToDate(value: unknown): Date | null {
  if (value instanceof Timestamp) {
    return value.toDate();
  }
  if (value instanceof Date) {
    return value;
  }
  return null;
}

type ClientSupportSnapshot = {
  displayName: string;
  phone: string;
};

async function fetchClientSupportSnapshot(
  clientId: string,
): Promise<ClientSupportSnapshot> {
  const userSnapshot = await firestore.doc(`users/${clientId}`).get();
  const userData = userSnapshot.data() ?? {};
  const displayName =
    typeof userData.name === "string" ? userData.name.trim() : "";
  const phone = typeof userData.phone === "string" ? userData.phone.trim() : "";
  return { displayName, phone };
}

function parseTripEligibilitySnapshot(
  data: FirebaseFirestore.DocumentData | undefined,
): TripEligibilitySnapshot {
  const balance = resolveMoneyPayload(data?.balance, "balance");
  const debtLimit = resolveMoneyPayload(data?.debtLimit, "debtLimit");
  if (balance.currency !== debtLimit.currency) {
    throw new HttpsError(
      "failed-precondition",
      "Saldo e limite têm moedas diferentes.",
      {
        reason: "CURRENCY_MISMATCH",
        operation: "parse_trip_eligibility_snapshot",
        balanceCurrency: balance.currency,
        debtLimitCurrency: debtLimit.currency,
      },
    );
  }
  return { balance, debtLimit };
}

function parseRequestTripPayload(data: unknown): RequestTripPayload {
  if (!data || typeof data !== "object") {
    throw new HttpsError("invalid-argument", "Pedido inválido.");
  }
  const payload = data as Record<string, unknown>;
  const tripId = payload.tripId;
  const tripData = payload.tripData;
  if (typeof tripId !== "string" || tripId.trim().length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "Identificador da viagem inválido.",
    );
  }
  if (!tripData || typeof tripData !== "object") {
    throw new HttpsError("invalid-argument", "Dados da viagem inválidos.");
  }
  return {
    tripId,
    tripData: tripData as Record<string, unknown>,
  };
}

function extractEstimatedTotal(
  tripData: Record<string, unknown>,
): MoneyPayload {
  const pricingSnapshot = tripData.pricingSnapshot;
  if (!pricingSnapshot || typeof pricingSnapshot !== "object") {
    throw new HttpsError("invalid-argument", "Preço estimado em falta.");
  }
  const estimatedTotal = (pricingSnapshot as Record<string, unknown>)
    .estimatedTotal;
  if (!isMoneyPayload(estimatedTotal)) {
    throw new HttpsError(
      "invalid-argument",
      "Preço estimado inválido (moeda em falta).",
    );
  }
  return estimatedTotal;
}

function resolveTripPackageLocationOrThrow(
  value: unknown,
  fieldName: string,
): TripLocationPayload {
  const location = parseTripPackageLocationPayload(value);
  if (!location || location.address.trim().length === 0) {
    throw new HttpsError(
      "failed-precondition",
      `${fieldName} inválido ou ausente.`,
    );
  }
  return location;
}

function resolveTripPackageTransportTypeOrThrow(
  value: unknown,
  fieldName: string,
): TransportTypePayload {
  const transportType = parseTripPackageTransportTypePayload(value);
  if (!transportType) {
    throw new HttpsError(
      "failed-precondition",
      `${fieldName} inválido ou ausente.`,
    );
  }
  return transportType;
}

function resolveTripPackageDocument(params: {
  packageId: string;
  data: FirebaseFirestore.DocumentData | undefined;
}): TripPackageDocument {
  const { packageId, data } = params;
  if (!data) {
    throw new HttpsError(
      "failed-precondition",
      "Pacote de viagem indisponível.",
    );
  }
  const oneWayPrice = resolveMoneyPayload(data.oneWayPrice, "oneWayPrice");
  const roundTripPrice = resolveMoneyPayload(
    data.roundTripPrice,
    "roundTripPrice",
  );
  assertMoneyCurrencyOrThrow({
    value: oneWayPrice,
    expectedCurrency: OPERATION_CURRENCY_CODE,
    fieldName: "oneWayPrice",
  });
  assertMoneyCurrencyOrThrow({
    value: roundTripPrice,
    expectedCurrency: OPERATION_CURRENCY_CODE,
    fieldName: "roundTripPrice",
  });
  const name = data.name?.toString()?.trim() ?? "";
  const description = data.description?.toString()?.trim() ?? "";
  const photoUrl = data.photoUrl?.toString()?.trim() ?? "";
  if (!name || !description || !photoUrl) {
    throw new HttpsError(
      "failed-precondition",
      "Pacote de viagem com dados incompletos.",
      { packageId },
    );
  }
  const minimumLeadTimeMinutes =
    parseTripPackageOptionalInteger(data.minimumLeadTimeMinutes) ??
    TRIP_PACKAGE_ACTIVATION_LEAD_TIME_MINUTES;
  const minimumReturnGapMinutes =
    parseTripPackageOptionalInteger(data.minimumReturnGapMinutes) ??
    TRIP_PACKAGE_MIN_RETURN_GAP_MINUTES;
  const activationLeadTimeMinutes =
    parseTripPackageOptionalInteger(data.activationLeadTimeMinutes) ??
    TRIP_PACKAGE_ACTIVATION_LEAD_TIME_MINUTES;
  const snapshotVersion =
    parseTripPackageOptionalInteger(data.snapshotVersion) ?? 1;
  const checkoutCopy =
    data.checkoutCopy?.toString()?.trim() ??
    "Pacote pré-pago com reserva operacional imediata.";
  return {
    id: packageId,
    name,
    description,
    photoUrl,
    destination: resolveTripPackageLocationOrThrow(
      data.destination,
      "destination",
    ),
    transportType: resolveTripPackageTransportTypeOrThrow(
      data.transportType,
      "transportType",
    ),
    oneWayPrice,
    roundTripPrice,
    isActive: data.isActive == true,
    minimumLeadTimeMinutes,
    minimumReturnGapMinutes,
    activationLeadTimeMinutes,
    snapshotVersion,
    checkoutCopy,
  };
}

function buildTripPackageSnapshot(
  packageDocument: TripPackageDocument,
): TripPackageSnapshot {
  return {
    packageId: packageDocument.id,
    packageSnapshotVersion: packageDocument.snapshotVersion,
    name: packageDocument.name,
    description: packageDocument.description,
    photoUrl: packageDocument.photoUrl,
    destination: packageDocument.destination,
    transportType: packageDocument.transportType,
    oneWayPrice: packageDocument.oneWayPrice,
    roundTripPrice: packageDocument.roundTripPrice,
    minimumLeadTimeMinutes: packageDocument.minimumLeadTimeMinutes,
    minimumReturnGapMinutes: packageDocument.minimumReturnGapMinutes,
    activationLeadTimeMinutes: packageDocument.activationLeadTimeMinutes,
    refundPolicy: {
      fullCancellationBeforeOutboundActivation: true,
      returnLegCancellationBeforeActivation: true,
    },
    checkoutCopy: packageDocument.checkoutCopy,
  };
}

function parseTripPackageBookingMode(
  value: unknown,
): TripPackageBookingMode | null {
  if (value === TRIP_PACKAGE_BOOKING_MODES.oneWay) {
    return TRIP_PACKAGE_BOOKING_MODES.oneWay;
  }
  if (value === TRIP_PACKAGE_BOOKING_MODES.roundTrip) {
    return TRIP_PACKAGE_BOOKING_MODES.roundTrip;
  }
  return null;
}

function parseDateInput(value: unknown, fieldName: string): Date {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} inválido ou ausente.`,
    );
  }
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    throw new HttpsError("invalid-argument", `${fieldName} inválido.`);
  }
  return parsed;
}

function isSameLocalDay(params: {
  left: Date;
  right: Date;
  timeZone: string;
}): boolean {
  const { left, right, timeZone } = params;
  return (
    buildTripPackageScheduledDayKey(left, timeZone) ===
    buildTripPackageScheduledDayKey(right, timeZone)
  );
}

export function buildTripPackageChargeLedgerId(bookingId: string): string {
  return `trip_package_booking_${bookingId}_charge`;
}

export function buildTripPackageRefundLedgerId(params: {
  bookingId: string;
  refundType: "full" | "return";
}): string {
  const { bookingId, refundType } = params;
  return `trip_package_booking_${bookingId}_refund_${refundType}`;
}

export function buildTripPackageReservationId(params: {
  bookingId: string;
  legType: TripPackageLegType;
}): string {
  const { bookingId, legType } = params;
  return `pkg_${bookingId}_${legType}`;
}

export function buildTripPackageTripId(params: {
  bookingId: string;
  legType: TripPackageLegType;
}): string {
  const { bookingId, legType } = params;
  return `pkg_${bookingId}_${legType}`;
}

export function buildTripPackageTaskId(params: {
  bookingId: string;
  legType: TripPackageLegType;
}): string {
  const { bookingId, legType } = params;
  return createHash("sha256")
    .update(`trip_package:${bookingId}:${legType}`)
    .digest("hex")
    .slice(0, 32);
}

function buildTripPackageLegPath(params: {
  bookingId: string;
  legType: TripPackageLegType;
}): string {
  const { bookingId, legType } = params;
  return `tripPackageBookings/${bookingId}/legs/${legType}`;
}

export function resolveTripPackageBookingAmount(params: {
  packageDocument: TripPackageDocument;
  mode: TripPackageBookingMode;
}): MoneyPayload {
  const { packageDocument, mode } = params;
  return mode == TRIP_PACKAGE_BOOKING_MODES.roundTrip
    ? packageDocument.roundTripPrice
    : packageDocument.oneWayPrice;
}

export function buildTripPackageLegPlans(params: {
  pickup: TripLocationPayload;
  packageDocument: Pick<
    TripPackageDocument,
    "destination" | "activationLeadTimeMinutes"
  >;
  outboundPickupAt: Date;
  returnPickupAt: Date | null;
  mode: TripPackageBookingMode;
}): TripPackageBookingLegPlan[] {
  const { pickup, packageDocument, outboundPickupAt, returnPickupAt, mode } =
    params;
  const outboundActivationAt = new Date(
    outboundPickupAt.getTime() -
      packageDocument.activationLeadTimeMinutes * 60 * 1000,
  );
  const plans: TripPackageBookingLegPlan[] = [
    {
      legType: TRIP_PACKAGE_LEG_TYPES.outbound,
      pickupAt: outboundPickupAt,
      pickup,
      dropoff: packageDocument.destination,
      activationAt: outboundActivationAt,
    },
  ];
  if (mode === TRIP_PACKAGE_BOOKING_MODES.roundTrip && returnPickupAt) {
    plans.push({
      legType: TRIP_PACKAGE_LEG_TYPES.return,
      pickupAt: returnPickupAt,
      pickup: packageDocument.destination,
      dropoff: pickup,
      activationAt: new Date(
        returnPickupAt.getTime() -
          packageDocument.activationLeadTimeMinutes * 60 * 1000,
      ),
    });
  }
  return plans;
}

export function validateTripPackageBookingRules(params: {
  packageDocument: Pick<
    TripPackageDocument,
    "isActive" | "minimumLeadTimeMinutes" | "minimumReturnGapMinutes"
  >;
  payload: {
    outboundPickupAt: Date;
    mode: TripPackageBookingMode;
    returnPickupAt: Date | null;
  };
  now: Date;
}): void {
  const { packageDocument, payload, now } = params;
  if (!packageDocument.isActive) {
    throw new HttpsError(
      "failed-precondition",
      "O pacote não está disponível.",
    );
  }
  const minimumOutboundTime = new Date(
    now.getTime() + packageDocument.minimumLeadTimeMinutes * 60 * 1000,
  );
  if (payload.outboundPickupAt < minimumOutboundTime) {
    throw new HttpsError(
      "failed-precondition",
      "A hora de recolha da ida está demasiado próxima.",
    );
  }
  if (payload.mode === TRIP_PACKAGE_BOOKING_MODES.oneWay) {
    if (payload.returnPickupAt != null) {
      throw new HttpsError(
        "invalid-argument",
        "A volta não é permitida neste modo.",
      );
    }
    return;
  }
  if (!payload.returnPickupAt) {
    throw new HttpsError(
      "failed-precondition",
      "A hora da volta é obrigatória.",
    );
  }
  if (
    !isSameLocalDay({
      left: payload.outboundPickupAt,
      right: payload.returnPickupAt,
      timeZone: RESERVATION_ACTIVATION_TIMEZONE,
    })
  ) {
    throw new HttpsError(
      "failed-precondition",
      "A volta tem de ocorrer no mesmo dia.",
    );
  }
  const minimumReturnAt = new Date(
    payload.outboundPickupAt.getTime() +
      packageDocument.minimumReturnGapMinutes * 60 * 1000,
  );
  if (payload.returnPickupAt < minimumReturnAt) {
    throw new HttpsError(
      "failed-precondition",
      "A volta tem de respeitar o intervalo mínimo.",
    );
  }
}

export function deriveTripPackageBookingStatus(params: {
  booking: Pick<TripPackageBookingDocument, "refundStatus" | "status">;
  legs: Array<{
    legType: TripPackageLegType;
    status: TripPackageLegStatus;
  }>;
}): TripPackageBookingStatus {
  const { booking, legs } = params;
  if (
    legs.some((leg) => leg.status === TRIP_PACKAGE_LEG_STATUSES.opsException)
  ) {
    return TRIP_PACKAGE_BOOKING_STATUSES.opsException;
  }
  if (booking.refundStatus === TRIP_PACKAGE_REFUND_STATUSES.full) {
    return TRIP_PACKAGE_BOOKING_STATUSES.cancelled;
  }
  if (booking.refundStatus === TRIP_PACKAGE_REFUND_STATUSES.partial) {
    return TRIP_PACKAGE_BOOKING_STATUSES.partiallyCancelled;
  }
  const activeLegs = legs.filter(
    (leg) => leg.status !== TRIP_PACKAGE_LEG_STATUSES.cancelled,
  );
  if (
    activeLegs.length > 0 &&
    activeLegs.every(
      (leg) => leg.status === TRIP_PACKAGE_LEG_STATUSES.completed,
    )
  ) {
    return TRIP_PACKAGE_BOOKING_STATUSES.completed;
  }
  const outboundLeg = legs.find(
    (leg) => leg.legType === TRIP_PACKAGE_LEG_TYPES.outbound,
  );
  if (outboundLeg?.status === TRIP_PACKAGE_LEG_STATUSES.completed) {
    return TRIP_PACKAGE_BOOKING_STATUSES.partiallyUsed;
  }
  return TRIP_PACKAGE_BOOKING_STATUSES.confirmed;
}

function resolveCreditLimitMinor(debtLimitMinor: number): number {
  return Math.abs(debtLimitMinor);
}

function isBalanceWithinCreditLimit({
  balanceAfterMinor,
  creditLimitMinor,
}: {
  balanceAfterMinor: number;
  creditLimitMinor: number;
}): boolean {
  return balanceAfterMinor >= -creditLimitMinor;
}

function buildLimitExceededDetails({
  operation,
  currency,
  balanceBeforeMinor,
  debitAmountMinor,
  creditLimitMinor,
}: {
  operation: string;
  currency: string;
  balanceBeforeMinor: number;
  debitAmountMinor: number;
  creditLimitMinor: number;
}): LimitExceededDetails {
  return {
    reason: "LIMIT_EXCEEDED",
    operation,
    currency,
    balanceBeforeMinor,
    debitAmountMinor,
    balanceAfterMinor: balanceBeforeMinor - debitAmountMinor,
    creditLimitMinor,
  };
}

function throwLimitExceededError(details: LimitExceededDetails): never {
  throw new HttpsError(
    "failed-precondition",
    "Limite de crédito excedido.",
    details,
  );
}

export type TripsFunctions = {
  requestTrip: ReturnType<typeof onCall>;
  confirmTripPackageBooking: ReturnType<typeof onCall>;
  cancelTripPackageBooking: ReturnType<typeof onCall>;
  cancelTripPackageReturnLeg: ReturnType<typeof onCall>;
  activateTripPackageLeg: ReturnType<typeof onTaskDispatched>;
  processDriverAcceptanceTimeout: ReturnType<typeof onTaskDispatched>;
  processPostChargeExtensionNextAction: ReturnType<typeof onTaskDispatched>;
  createPackageCoveredTripFromReservation: (params: {
    reservationId: string;
    clientId: string;
    pickup: TripLocationPayload;
    destination: TripLocationPayload;
    transportType: TransportTypePayload;
    scheduledAt: Date;
    assignedDriverId: string;
    vehicleId: string;
    bookingId: string;
    packageId: string;
    packageSnapshotVersion: number;
  }) => Promise<string | null>;
  assignDriverOnTripCreation: ReturnType<typeof onDocumentCreated>;
  syncDriverVehicleAssignment: ReturnType<typeof onDocumentWritten>;
  handleTripStatusUpdates: ReturnType<typeof onDocumentUpdated>;
  finalizeTripOnCompletion: ReturnType<typeof onDocumentUpdated>;
  retryTripPayment: ReturnType<typeof onCall>;
  transitionTripState: ReturnType<typeof onCall>;
  cancelTrip: ReturnType<typeof onCall>;
  requestTripExtension: ReturnType<typeof onCall>;
  respondTripExtension: ReturnType<typeof onCall>;
  closeTripExtensionFlow: ReturnType<typeof onCall>;
  endTripExtensionEarly: ReturnType<typeof onCall>;
  handleTripFinancialAction: ReturnType<typeof onCall>;
  autoCompleteTripExtensionWindow: ReturnType<typeof onDocumentUpdated>;
  notifyDriverOnAdminEventCreation: ReturnType<typeof onDocumentCreated>;
  syncDriversPublicProfile: ReturnType<typeof onDocumentWritten>;
  syncDriversPublicVehicle: ReturnType<typeof onDocumentWritten>;
  syncNotificationTargetToken: ReturnType<typeof onDocumentWritten>;
  activateReservationsForDayJob: () => Promise<void>;
  sendScheduledEventNotificationsJob: () => Promise<void>;
  monitorDriverHeartbeatJob: () => Promise<void>;
  pruneStaleFcmTokensJob: () => Promise<void>;
  sweepDriverAcceptanceTimeoutsJob: () => Promise<void>;
  sweepPostChargeTripExtensionsJob: () => Promise<void>;
};

export function buildTripsFunctions(params: {
  firestore: admin.firestore.Firestore;
  realtimeDb: admin.database.Database;
  auth: admin.auth.Auth;
  messaging: admin.messaging.Messaging;
}): TripsFunctions {
  firestore = params.firestore;
  realtimeDb = params.realtimeDb;
  authService = params.auth;
  messaging = params.messaging;

  const requestTrip = onCall(
    CRITICAL_CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      if (!request.auth?.uid) {
        logger.warn("Trip request rejected: unauthenticated.");
        throw new HttpsError("unauthenticated", "Autenticação necessária.");
      }

      const { tripId, tripData } = parseRequestTripPayload(request.data);
      const clientId = request.auth.uid;
      const estimatedTotal = extractEstimatedTotal(tripData);

      const balanceSnapshot = await firestore.doc(`balances/${clientId}`).get();
      if (!balanceSnapshot.exists) {
        logger.error("Trip request rejected: balance not found.", {
          tripId,
          clientId,
        });
        throw new HttpsError("failed-precondition", "Saldo indisponível.");
      }

      const eligibility = parseTripEligibilitySnapshot(balanceSnapshot.data());
      assertMoneyCurrencyOrThrow({
        value: estimatedTotal,
        expectedCurrency: eligibility.balance.currency,
        fieldName: "pricingSnapshot.estimatedTotal",
      });
      assertMoneyCurrencyOrThrow({
        value: eligibility.balance,
        expectedCurrency: OPERATION_CURRENCY_CODE,
        fieldName: "balance",
      });
      assertMoneyCurrencyOrThrow({
        value: eligibility.debtLimit,
        expectedCurrency: OPERATION_CURRENCY_CODE,
        fieldName: "debtLimit",
      });
      const creditLimitMinor = resolveCreditLimitMinor(
        eligibility.debtLimit.amountMinor,
      );
      const projectedDetails = buildLimitExceededDetails({
        operation: "request_trip",
        currency: eligibility.balance.currency,
        balanceBeforeMinor: eligibility.balance.amountMinor,
        debitAmountMinor: Math.max(estimatedTotal.amountMinor, 0),
        creditLimitMinor,
      });
      if (
        !isBalanceWithinCreditLimit({
          balanceAfterMinor: projectedDetails.balanceAfterMinor,
          creditLimitMinor,
        })
      ) {
        logger.warn(
          "Trip request rejected: projected balance exceeds credit limit.",
          {
            tripId,
            clientId,
            ...projectedDetails,
          },
        );
        throwLimitExceededError(projectedDetails);
      }

      const clientSupport = await fetchClientSupportSnapshot(clientId);
      const normalizedPricingSnapshot = serializePricingSnapshotForTrip(
        parsePricingSnapshot(tripData.pricingSnapshot),
      );
      const tripPayload = buildTripCreatePayload({
        clientId,
        pickup: tripData.pickup as TripLocationPayload,
        destination: (tripData.destination as TripLocationPayload) ?? null,
        transportType: tripData.transportType as TransportTypePayload,
        pricingSnapshot: normalizedPricingSnapshot,
        meteringSnapshot:
          (tripData.meteringSnapshot as TripMeteringSnapshot) ?? null,
        assignedDriverId: (tripData.assignedDriverId as string) ?? null,
        vehicleId: (tripData.vehicleId as string) ?? null,
        status: "REQUESTED",
        extra: { clientSupport },
      });
      enforceTripCreatePayload({
        payload: tripPayload,
        context: "requestTrip",
        errorCode: "invalid-argument",
      });

      await firestore.runTransaction(async (transaction) => {
        const tripRef = firestore.doc(`trips/${tripId}`);
        const eventRef = firestore
          .collection("tripEvents")
          .doc(tripId)
          .collection("events")
          .doc("requested");
        const existing = await transaction.get(tripRef);
        if (existing.exists) {
          logger.warn("Trip request rejected: trip already exists.", {
            tripId,
            clientId,
          });
          throw new HttpsError("already-exists", "Viagem já existe.");
        }
        const eventPayload = buildTripStateTransitionEventPayload({
          fromStatus: "REQUESTED",
          toStatus: "REQUESTED",
          actorId: clientId,
          metadata: { source: "requestTrip" },
        });
        enforceTripEventPayload({
          payload: eventPayload,
          context: "requestTrip.initialEvent",
        });
        transaction.set(tripRef, tripPayload);
        transaction.set(eventRef, eventPayload);
      });

      logger.info("Trip request created.", {
        tripId,
        clientId,
        estimatedTotalAmountMinor: estimatedTotal.amountMinor,
        currency: estimatedTotal.currency,
      });

      return { tripId };
    },
  );

  const confirmTripPackageBooking = onCall(
    CRITICAL_CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const clientId = requireAuthenticatedUid(request.auth);
      const role = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      if (role !== "client") {
        throw new HttpsError("permission-denied", "Permissões insuficientes.");
      }
      const payload = parseConfirmTripPackageBookingPayload(request.data);
      const operationId = buildTripPackageConfirmOperationId({
        clientId,
        payload,
      });
      const lockClaimed = await acquireOperationLock({
        operationId,
        operationType: "confirm_trip_package_booking",
      });
      if (!lockClaimed) {
        throw new HttpsError(
          "already-exists",
          "Já existe um pedido idêntico em processamento.",
        );
      }

      let operationError: Error | null = null;
      try {
        const bookingId = await confirmTripPackageBookingCore({
          clientId,
          payload,
        });
        return { bookingId };
      } catch (error) {
        operationError =
          error instanceof Error
            ? error
            : new Error("trip_package_confirm_failed");
        throw error;
      } finally {
        await completeOperationLock({
          operationId,
          status: operationError ? "failed" : "completed",
          ...(operationError ? { errorMessage: operationError.message } : {}),
        });
      }
    },
  );

  const cancelTripPackageBooking = onCall(
    CRITICAL_CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const clientId = requireAuthenticatedUid(request.auth);
      const role = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      if (role !== "client") {
        throw new HttpsError("permission-denied", "Permissões insuficientes.");
      }
      const bookingId = parseTripPackageBookingId(request.data);
      const operationId = `cancel_trip_package_booking_${bookingId}`;
      const lockClaimed = await acquireOperationLock({
        operationId,
        operationType: "cancel_trip_package_booking",
      });
      if (!lockClaimed) {
        throw new HttpsError(
          "already-exists",
          "O cancelamento já está em processamento.",
        );
      }

      let operationError: Error | null = null;
      try {
        await cancelTripPackageBookingCore({
          bookingId,
          clientId,
        });
        return { bookingId };
      } catch (error) {
        operationError =
          error instanceof Error
            ? error
            : new Error("trip_package_cancel_failed");
        throw error;
      } finally {
        await completeOperationLock({
          operationId,
          status: operationError ? "failed" : "completed",
          ...(operationError ? { errorMessage: operationError.message } : {}),
        });
      }
    },
  );

  const cancelTripPackageReturnLeg = onCall(
    CRITICAL_CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const clientId = requireAuthenticatedUid(request.auth);
      const role = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      if (role !== "client") {
        throw new HttpsError("permission-denied", "Permissões insuficientes.");
      }
      const bookingId = parseTripPackageBookingId(request.data);
      const operationId = `cancel_trip_package_return_${bookingId}`;
      const lockClaimed = await acquireOperationLock({
        operationId,
        operationType: "cancel_trip_package_return_leg",
      });
      if (!lockClaimed) {
        throw new HttpsError(
          "already-exists",
          "O cancelamento da volta já está em processamento.",
        );
      }

      let operationError: Error | null = null;
      try {
        await cancelTripPackageReturnLegCore({
          bookingId,
          clientId,
        });
        return { bookingId };
      } catch (error) {
        operationError =
          error instanceof Error
            ? error
            : new Error("trip_package_return_cancel_failed");
        throw error;
      } finally {
        await completeOperationLock({
          operationId,
          status: operationError ? "failed" : "completed",
          ...(operationError ? { errorMessage: operationError.message } : {}),
        });
      }
    },
  );

  const activateTripPackageLeg = onTaskDispatched<{
    bookingId: string;
    legType: TripPackageLegType;
  }>(
    {
      region: "europe-southwest1",
      retryConfig: {
        maxAttempts: 5,
        minBackoffSeconds: 30,
        maxBackoffSeconds: 300,
        maxRetrySeconds: 1800,
        maxDoublings: 5,
      },
      rateLimits: {
        maxConcurrentDispatches: 20,
        maxDispatchesPerSecond: 20,
      },
    },
    async (request) => {
      const data = request.data;
      const bookingId =
        typeof data.bookingId === "string" ? data.bookingId.trim() : "";
      const legType = data.legType;
      if (!bookingId || !parseTripPackageLegType(legType)) {
        logger.error("Trip package task payload inválido.", { data });
        return;
      }
      await activateTripPackageLegCore({
        bookingId,
        legType,
      });
    },
  );

  const processDriverAcceptanceTimeout =
    onTaskDispatched<DriverAcceptanceTimeoutTaskPayload>(
      {
        region: TASK_QUEUE_REGION,
        retryConfig: {
          maxAttempts: 5,
          minBackoffSeconds: 30,
          maxBackoffSeconds: 300,
          maxRetrySeconds: 1800,
          maxDoublings: 5,
        },
        rateLimits: {
          maxConcurrentDispatches: 20,
          maxDispatchesPerSecond: 20,
        },
      },
      async (request) => {
        await handleDriverAcceptanceTimeoutTask(request.data);
      },
    );

  const processPostChargeExtensionNextAction =
    onTaskDispatched<PostChargeExtensionTaskPayload>(
      {
        region: TASK_QUEUE_REGION,
        retryConfig: {
          maxAttempts: 5,
          minBackoffSeconds: 30,
          maxBackoffSeconds: 300,
          maxRetrySeconds: 1800,
          maxDoublings: 5,
        },
        rateLimits: {
          maxConcurrentDispatches: 20,
          maxDispatchesPerSecond: 20,
        },
      },
      async (request) => {
        await handlePostChargeExtensionTask(request.data);
      },
    );

  const assignDriverOnTripCreation = onDocumentCreated(
    {
      document: "trips/{tripId}",
      region: "europe-southwest1",
    },
    async (event) => {
      const snapshot = event.data;
      if (!snapshot) {
        logger.warn("Trip creation event missing snapshot.");
        return;
      }

      const tripId = event.params.tripId;
      const operationId = `assign_trip_creation_${event.id ?? tripId}`;
      const lockClaimed = await acquireOperationLock({
        operationId,
        operationType: "assign_driver_on_trip_creation",
        tripId,
      });
      if (!lockClaimed) {
        return;
      }

      let operationError: Error | null = null;
      try {
        const tripData = snapshot.data();
        const status = tripData?.status?.toString()?.toUpperCase();
        const clientId = tripData?.clientId?.toString();

        if (status !== "REQUESTED") {
          logger.info("Trip status is not REQUESTED, skipping.", {
            tripId,
            status,
          });
          return;
        }

        const pickupLocation = parseCoordinates(tripData?.pickup);
        if (!pickupLocation) {
          logger.error("Trip pickup location missing or invalid.", { tripId });
          await markTripUnfulfilled(tripId, clientId, "pickup_missing");
          return;
        }

        const destinationLocation = parseCoordinates(tripData?.destination);
        if (!destinationLocation) {
          logger.error("Trip destination location missing or invalid.", {
            tripId,
          });
          await markTripUnfulfilled(tripId, clientId, "destination_missing");
          return;
        }

        logger.info("Finding available drivers for trip.", { tripId });
        const availableDrivers = await fetchAvailableDrivers();
        if (availableDrivers.length === 0) {
          const reason = "no_available_drivers_status";
          logger.warn("No available drivers found.", {
            tripId,
            reason,
            availableDrivers: availableDrivers.length,
          });
          await markTripUnfulfilled(tripId, clientId, reason);
          return;
        }

        const candidateResolution = await resolveDriverCandidates(
          availableDrivers,
          pickupLocation,
        );
        const candidates = candidateResolution.candidates;
        if (candidates.length === 0) {
          const reason = buildNoLocationFailureReason(candidateResolution);
          logger.warn("No driver candidates found after radius expansion.", {
            tripId,
            reason,
            availableDrivers: availableDrivers.length,
            attemptedRadiiKm: candidateResolution.attemptedRadiiKm,
            nearbyUniqueCount: candidateResolution.nearbyUniqueCount,
            filteredOutByStatusCount:
              candidateResolution.filteredOutByStatusCount,
          });
          await markTripUnfulfilled(tripId, clientId, reason);
          return;
        }

        const tripWindow = buildReservationWindow({
          start: new Date(),
          pickup: pickupLocation,
          destination: destinationLocation,
        });
        const vehicleSelection = await selectDriverVehicleCandidate({
          candidates,
          window: tripWindow,
          reservedAssignments: [],
        });
        const assignedCandidate = vehicleSelection.assignment;
        if (!assignedCandidate) {
          const reason = buildNoAssignableDriverReason(
            vehicleSelection.diagnostics,
          );
          logger.warn("No assignable driver/vehicle for trip.", {
            tripId,
            reason,
            candidates: candidates.length,
            diagnostics: vehicleSelection.diagnostics,
          });
          await markTripUnfulfilled(tripId, clientId, reason);
          return;
        }

        logger.info("Assigning nearest driver with vehicle.", {
          tripId,
          driverId: assignedCandidate.id,
          vehicleId: assignedCandidate.vehicleId,
          distanceKm: assignedCandidate.distanceKm,
        });

        const [driverSummary, vehicleSummary, driverContactSnapshot] =
          await Promise.all([
            fetchDriverSummary(assignedCandidate.id),
            fetchVehicleSummary(assignedCandidate.vehicleId),
            fetchDriverContactSnapshot(assignedCandidate.id),
          ]);

        const tripRef = firestore.doc(`trips/${tripId}`);
        const driverContactRef = firestore.doc(
          `trips/${tripId}/driverContactSnapshots/${tripId}`,
        );
        await firestore.runTransaction(async (transaction) => {
          const freshSnapshot = await transaction.get(tripRef);
          const freshData = freshSnapshot.data();
          if (!freshData) {
            logger.warn("Trip missing during assignment transaction.", {
              tripId,
            });
            return;
          }
          const currentStatus = normalizeTripStatus(freshData.status);
          const currentAssignedDriverId =
            typeof freshData.assignedDriverId === "string" &&
            freshData.assignedDriverId.trim()
              ? freshData.assignedDriverId
              : null;
          if (currentStatus !== "REQUESTED" || currentAssignedDriverId) {
            logger.info("Trip assignment skipped by CAS guard.", {
              tripId,
              currentStatus,
              currentAssignedDriverId,
              operationId,
            });
            return;
          }
          const assignedAt = new Date();
          const tripUpdatePayload = {
            assignedDriverId: assignedCandidate.id,
            vehicleId: assignedCandidate.vehicleId,
            ...(driverSummary ? { driverSummary } : {}),
            ...(vehicleSummary ? { vehicleSummary } : {}),
            status: "DRIVER_ASSIGNED_WAITING_ACCEPTANCE",
            statusEnteredAt: Timestamp.fromDate(assignedAt),
            updatedAt: FieldValue.serverTimestamp(),
            driverAssignedAt: Timestamp.fromDate(assignedAt),
            assignmentAttempts: 1,
          };
          enforceTripUpdatePayload({
            payload: tripUpdatePayload,
            context: "assignDriverOnTripCreation",
          });
          transaction.update(tripRef, tripUpdatePayload);
          if (driverContactSnapshot) {
            transaction.set(driverContactRef, driverContactSnapshot, {
              merge: true,
            });
          } else {
            transaction.delete(driverContactRef);
          }
        });
      } catch (error) {
        operationError =
          error instanceof Error ? error : new Error("assignment_failed");
        throw error;
      } finally {
        await completeOperationLock({
          operationId,
          status: operationError ? "failed" : "completed",
          ...(operationError ? { errorMessage: operationError.message } : {}),
        });
      }
    },
  );

  async function fetchDriverSummary(
    driverId: string,
  ): Promise<Record<string, unknown> | null> {
    try {
      const snapshot = await firestore.doc(`driversPublic/${driverId}`).get();
      if (!snapshot.exists) {
        return null;
      }
      const data = snapshot.data() ?? {};
      const nameCandidates = [data.displayName, data.name, data.initials];
      const name = nameCandidates.find(
        (value) => typeof value === "string" && value.trim().length > 0,
      ) as string | undefined;
      const photoUrl =
        typeof data.photoUrl === "string" ? data.photoUrl.trim() : "";
      if (!name && !photoUrl) {
        return null;
      }
      return {
        ...(name ? { displayName: name.trim() } : {}),
        ...(photoUrl ? { photoUrl } : {}),
      };
    } catch (error) {
      logger.warn("Failed to fetch driver summary.", { driverId, error });
      return null;
    }
  }

  async function fetchDriverContactSnapshot(
    driverId: string,
  ): Promise<DriverContactSnapshot | null> {
    try {
      const [userSnapshot, publicSnapshot] = await Promise.all([
        firestore.doc(`users/${driverId}`).get(),
        firestore.doc(`driversPublic/${driverId}`).get(),
      ]);
      const userData = userSnapshot.data() ?? {};
      const publicData = publicSnapshot.data() ?? {};

      const phone =
        typeof userData.phone === "string" ? userData.phone.trim() : "";
      if (!phone) {
        logger.warn("Driver phone unavailable for contact snapshot.", {
          driverId,
        });
        return null;
      }

      const nameCandidates = [
        publicData.displayName,
        publicData.initials,
        userData.name,
      ];
      const nameCandidate = nameCandidates.find(
        (value) => typeof value === "string" && value.trim().length > 0,
      ) as string | undefined;
      const name = nameCandidate?.trim() ?? "Motorista";

      const photoCandidates = [publicData.photoUrl, userData.photoUrl];
      const photoCandidate = photoCandidates.find(
        (value) => typeof value === "string" && value.trim().length > 0,
      ) as string | undefined;
      const photoUrl = photoCandidate?.trim();

      return {
        driverId,
        name,
        phone,
        ...(photoUrl ? { photoUrl } : {}),
      };
    } catch (error) {
      logger.warn("Failed to build driver contact snapshot.", {
        driverId,
        error,
      });
      return null;
    }
  }

  async function syncTripDriverContactSnapshot(params: {
    tripId: string;
    driverId: string | null;
  }): Promise<void> {
    const { tripId, driverId } = params;
    const snapshotRef = firestore.doc(
      `trips/${tripId}/driverContactSnapshots/${tripId}`,
    );
    if (!driverId) {
      try {
        await snapshotRef.delete();
      } catch (error) {
        if (!isFirestoreDocumentMissingError(error)) {
          logger.warn("Failed to remove trip driver contact snapshot.", {
            tripId,
            error,
          });
        }
      }
      return;
    }
    const snapshot = await fetchDriverContactSnapshot(driverId);
    if (!snapshot) {
      try {
        await snapshotRef.delete();
      } catch (error) {
        if (!isFirestoreDocumentMissingError(error)) {
          logger.warn("Failed to cleanup stale trip driver contact snapshot.", {
            tripId,
            driverId,
            error,
          });
        }
      }
      logger.warn("Trip driver contact snapshot unavailable.", {
        tripId,
        driverId,
      });
      return;
    }
    await snapshotRef.set(snapshot, { merge: true });
  }

  async function fetchVehicleSummary(
    vehicleId?: string | null,
  ): Promise<Record<string, unknown> | null> {
    if (!vehicleId) {
      return null;
    }
    try {
      const snapshot = await firestore.doc(`vehicles/${vehicleId}`).get();
      if (!snapshot.exists) {
        return null;
      }
      const data = snapshot.data() ?? {};
      const plate = typeof data.plate === "string" ? data.plate.trim() : "";
      if (!plate) {
        return null;
      }
      return { plate };
    } catch (error) {
      logger.warn("Failed to fetch vehicle summary.", { vehicleId, error });
      return null;
    }
  }

  const syncDriverVehicleAssignment = onDocumentWritten(
    {
      document: "driverVehicleAssignments/{driverId}",
      region: "europe-southwest1",
    },
    async (event) => {
      const driverId = event.params.driverId;
      const afterData = event.data?.after?.data();
      const driverStatusRef = firestore.doc(
        `${DRIVER_STATUS_COLLECTION}/${driverId}`,
      );

      if (!afterData) {
        const statusPayload = {
          vehicleId: FieldValue.delete(),
          updatedAt: FieldValue.serverTimestamp(),
        };
        enforceDriverStatusPayload({
          payload: statusPayload,
          context: "syncDriverVehicleAssignment.remove",
        });
        await driverStatusRef.set(statusPayload, { merge: true });
        logger.info("Driver vehicle assignment removed; status cleared.", {
          driverId,
        });
        return;
      }

      const vehicleId = afterData.vehicleId?.toString() ?? "";
      if (!vehicleId) {
        const statusPayload = {
          vehicleId: FieldValue.delete(),
          updatedAt: FieldValue.serverTimestamp(),
        };
        enforceDriverStatusPayload({
          payload: statusPayload,
          context: "syncDriverVehicleAssignment.missingVehicleId",
        });
        await driverStatusRef.set(statusPayload, { merge: true });
        logger.warn("Driver assignment missing vehicleId; status cleared.", {
          driverId,
        });
        return;
      }

      const statusPayload = {
        vehicleId,
        updatedAt: FieldValue.serverTimestamp(),
      };
      enforceDriverStatusPayload({
        payload: statusPayload,
        context: "syncDriverVehicleAssignment",
      });
      await driverStatusRef.set(statusPayload, { merge: true });
      logger.info("Driver status vehicleId synced.", {
        driverId,
        vehicleId,
      });
    },
  );

  const handleTripStatusUpdates = onDocumentUpdated(
    {
      document: "trips/{tripId}",
      region: "europe-southwest1",
    },
    async (event) => {
      const beforeData = event.data?.before.data();
      const afterData = event.data?.after.data();
      if (!afterData) {
        logger.warn("Trip status update missing data.");
        return;
      }
      const beforeStatus = normalizeTripStatus(beforeData?.status);
      const afterStatus = normalizeTripStatus(afterData?.status);
      if (beforeStatus === afterStatus) {
        return;
      }
      const tripId = event.params.tripId;
      const tripRef = event.data?.after.ref;
      const shouldBeActive = isTripActiveStatus(afterStatus);
      const wasActive = isTripActiveStatus(beforeStatus);
      const currentIsActive =
        typeof afterData.isActive === "boolean" ? afterData.isActive : null;
      if (currentIsActive !== shouldBeActive && tripRef) {
        logger.info("Updating trip isActive based on status change.", {
          tripId,
          beforeStatus,
          afterStatus,
          isActive: shouldBeActive,
        });
        const tripUpdatePayload = {
          isActive: shouldBeActive,
          updatedAt: FieldValue.serverTimestamp(),
        };
        enforceTripUpdatePayload({
          payload: tripUpdatePayload,
          context: "handleTripStatusUpdates.isActive",
        });
        await tripRef.update(tripUpdatePayload);
      }
      const clientId = afterData.clientId?.toString();
      const unfulfilledReason = afterData.unfulfilledReason?.toString();
      const assignedDriverId = afterData.assignedDriverId?.toString();
      const previousDriverId = beforeData?.assignedDriverId?.toString();
      const vehicleId = afterData.vehicleId?.toString();
      await syncUserRuntimeForTripStatus({
        tripId,
        beforeStatus,
        afterStatus,
        clientId,
        assignedDriverId,
        previousDriverId,
      });

      if (shouldBeActive && assignedDriverId) {
        await syncTripDriverContactSnapshot({
          tripId,
          driverId: assignedDriverId,
        });
      }

      if (
        beforeStatus !== "NO_DRIVERS_AVAILABLE" &&
        afterStatus === "NO_DRIVERS_AVAILABLE"
      ) {
        await notifyManagersTripUnfulfilled({
          tripId,
          reason: unfulfilledReason ?? "unknown",
          clientId,
        });
      }

      if (shouldBeActive && assignedDriverId) {
        if (!wasActive || previousDriverId !== assignedDriverId) {
          await updateDriverTripState({
            tripId,
            driverId: assignedDriverId,
            vehicleId,
            isBusy: true,
          });
        }
      } else if (!shouldBeActive && wasActive && previousDriverId) {
        await updateDriverTripState({
          tripId,
          driverId: previousDriverId,
          vehicleId,
          isBusy: false,
        });
      } else if (!shouldBeActive) {
        const terminalDriverId = assignedDriverId ?? previousDriverId ?? "";
        if (terminalDriverId) {
          await updateDriverTripState({
            tripId,
            driverId: terminalDriverId,
            vehicleId,
            isBusy: false,
          });
        }
      }

      if (
        afterStatus === "ARRIVED_DESTINATION" ||
        afterStatus === "COMPLETED" ||
        afterStatus === "CHARGE_APPLIED"
      ) {
        try {
          await syncFinalMeteringSnapshotToTrip({ tripId });
        } catch (error) {
          logger.error("Final metering sync failed after status change.", {
            tripId,
            afterStatus,
            error,
          });
        }
      }

      if (
        tripRef &&
        (afterStatus === "CANCELLED_BY_CLIENT" ||
          afterStatus === "CANCELLED_BY_DRIVER") &&
        afterData.postChargeExtension?.isActive === true
      ) {
        const closePayload = buildClosedPostChargeExtensionUpdate({
          reason: POST_CHARGE_EXTENSION_CLOSED_REASONS.clientClosed,
        });
        enforceTripUpdatePayload({
          payload: closePayload,
          context: "handleTripStatusUpdates.closePostChargeOnCancellation",
        });
        await tripRef.update(closePayload);
        logger.info("Post-charge extension closed after cancellation.", {
          tripId,
          afterStatus,
        });
      }

      if (afterStatus === "DRIVER_ASSIGNED_WAITING_ACCEPTANCE") {
        logger.info("Trip assigned to driver, notifying.", { tripId });
        const driverAssignedAt = parseTimestampToDate(
          afterData.driverAssignedAt,
        );
        if (assignedDriverId && driverAssignedAt) {
          try {
            await enqueueDriverAcceptanceTimeoutTask({
              tripId,
              assignedDriverId,
              assignmentAttempt: normalizeAssignmentAttempt(
                afterData.assignmentAttempts,
              ),
              driverAssignedAt,
            });
          } catch (error) {
            logger.error("Failed to enqueue driver acceptance timeout task.", {
              tripId,
              assignedDriverId,
              error,
            });
          }
        } else {
          logger.warn("Driver acceptance timeout task skipped.", {
            tripId,
            assignedDriverId,
            hasDriverAssignedAt: driverAssignedAt != null,
          });
        }
        await notifyAssignedDriverForTrip({ tripId, tripData: afterData });
        return;
      }

      if (afterStatus === "DRIVER_ACCEPTED") {
        if (assignedDriverId) {
          await updateDriverAvailability(assignedDriverId, false);
        }
        return;
      }

      if (afterStatus === "DRIVER_DECLINED") {
        if (assignedDriverId) {
          await updateDriverAvailability(assignedDriverId, true);
        }
        const reassignment = await assignNextDriverForTrip({
          tripId,
          tripData: afterData,
          excludedDriverIds: assignedDriverId ? [assignedDriverId] : [],
        });
        if (reassignment.attempted && !reassignment.assignedDriverId) {
          await markTripNoDriversAvailable(
            tripId,
            clientId,
            reassignment.failureReason ?? "no_available_drivers_status",
          );
        }
      }

      if (AVAILABILITY_RESTORE_TRIP_STATUSES.has(afterStatus)) {
        const availabilityDriverId = assignedDriverId ?? previousDriverId ?? "";
        if (!availabilityDriverId) {
          logger.warn(
            "Cancelled trip missing driver for availability restore.",
            {
              tripId,
              afterStatus,
            },
          );
          return;
        }
        logger.info("Restoring driver availability after trip cancellation.", {
          tripId,
          driverId: availabilityDriverId,
          afterStatus,
        });
        await updateDriverAvailability(availabilityDriverId, true);
      }

      await syncTripPackageLegFromTripStatusChange({
        tripId,
        tripData: afterData,
        afterStatus,
      });
    },
  );

  const finalizeTripOnCompletion = onDocumentUpdated(
    {
      document: "trips/{tripId}",
      region: "europe-southwest1",
    },
    async (event) => {
      const beforeData = event.data?.before.data();
      const afterData = event.data?.after.data();
      if (!afterData) {
        logger.warn("Trip update event missing data.");
        return;
      }

      const beforeStatus = normalizeTripStatus(beforeData?.status);
      const afterStatus = normalizeTripStatus(afterData?.status);
      const beforePaymentStatus = normalizePaymentStatus(
        beforeData?.paymentStatus,
      );
      const afterPaymentStatus = normalizePaymentStatus(
        afterData?.paymentStatus,
      );
      const shouldFinalize =
        afterStatus === "COMPLETED" &&
        (beforeStatus !== "COMPLETED" ||
          (afterPaymentStatus === "PENDING" &&
            beforePaymentStatus !== "PENDING"));
      if (!shouldFinalize) {
        return;
      }

      const tripId = event.params.tripId;
      const operationId = `finalize_trip_completion_${event.id ?? tripId}`;
      const lockClaimed = await acquireOperationLock({
        operationId,
        operationType: "finalize_trip_on_completion",
        tripId,
      });
      if (!lockClaimed) {
        return;
      }

      const clientId = afterData?.clientId?.toString();
      if (!clientId) {
        logger.error("Completed trip missing clientId.", { tripId });
        await completeOperationLock({
          operationId,
          status: "failed",
          errorMessage: "missing_client_id",
        });
        return;
      }

      logger.info("Finalizing completed trip.", {
        tripId,
        clientId,
        paymentStatus: afterPaymentStatus,
      });
      let operationError: Error | null = null;
      try {
        await finalizeTripPayment({
          tripId,
          clientId,
          reason: "on_completion",
        });
      } catch (error) {
        operationError =
          error instanceof Error ? error : new Error("finalize_failed");
        throw error;
      } finally {
        await completeOperationLock({
          operationId,
          status: operationError ? "failed" : "completed",
          ...(operationError ? { errorMessage: operationError.message } : {}),
        });
      }
    },
  );

  const retryTripPayment = onCall(
    STANDARD_CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const requesterId = requireAuthenticatedUid(request.auth);

      const data = request.data as Record<string, unknown> | null;
      const tripId =
        typeof data?.tripId === "string" ? data?.tripId.trim() : "";
      if (!tripId) {
        throw new HttpsError("invalid-argument", "Viagem inválida.");
      }

      const tripSnapshot = await firestore.doc(`trips/${tripId}`).get();
      const tripData = tripSnapshot.data();
      if (!tripData) {
        throw new HttpsError("not-found", "Viagem não encontrada.");
      }

      const clientId = tripData.clientId?.toString();
      if (!clientId) {
        throw new HttpsError(
          "failed-precondition",
          "Viagem sem cliente associado.",
        );
      }

      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      const isAdmin = callerRole === "admin";
      if (!isAdmin && requesterId !== clientId) {
        logger.warn("Retry trip payment rejected: not authorized.", {
          tripId,
          requesterId,
        });
        throw new HttpsError("permission-denied", "Permissões insuficientes.");
      }

      logger.info("Manual trip payment retry requested.", {
        tripId,
        clientId,
        requesterId,
      });

      await finalizeTripPayment({ tripId, clientId, reason: "manual" });

      return { tripId, status: "submitted" };
    },
  );

  const tripCriticalCallables = buildTripStateMachineCallables({
    firestore,
    auth: authService,
    validTripStatuses: VALID_TRIP_STATUSES,
    normalizeTripStatus,
    enforceTripUpdatePayload,
    enforceTripEventPayload,
    finalizeTripPayment,
  });

  const transitionTripState = tripCriticalCallables.transitionTripState;
  const cancelTrip = tripCriticalCallables.cancelTrip;
  const legacyRequestTripExtension = tripCriticalCallables.requestTripExtension;
  const legacyRespondTripExtension = tripCriticalCallables.respondTripExtension;
  const handleTripFinancialAction =
    tripCriticalCallables.handleTripFinancialAction;

  function parseRequiredTripIdFromCallableData(
    data: Record<string, unknown> | null,
  ): string {
    const tripId = typeof data?.tripId === "string" ? data.tripId.trim() : "";
    if (!tripId) {
      throw new HttpsError("invalid-argument", "Viagem inválida.");
    }
    return tripId;
  }

  function buildUniformTaskId(operationKey: string): string {
    return createHash("sha256").update(operationKey).digest("hex").slice(0, 32);
  }

  function isAlreadyExistsTaskError(error: unknown): boolean {
    const record = error as { code?: unknown; message?: unknown };
    return (
      record.code === 6 ||
      record.code === "already-exists" ||
      record.code === "ALREADY_EXISTS" ||
      record.message?.toString().includes("ALREADY_EXISTS") === true
    );
  }

  function normalizeAssignmentAttempt(value: unknown): number {
    return typeof value === "number" && Number.isFinite(value) && value > 0
      ? Math.floor(value)
      : 1;
  }

  function buildDriverAcceptanceTimeoutOperationKey(params: {
    tripId: string;
    assignmentAttempt: number;
    driverAssignedAtMillis: number;
  }): string {
    return [
      "driver_acceptance_timeout",
      params.tripId,
      params.assignmentAttempt.toString(),
      params.driverAssignedAtMillis.toString(),
    ].join(":");
  }

  async function enqueueDriverAcceptanceTimeoutTask(params: {
    tripId: string;
    assignedDriverId: string;
    assignmentAttempt: number;
    driverAssignedAt: Date;
  }): Promise<void> {
    const driverAssignedAtMillis = params.driverAssignedAt.getTime();
    const operationKey = buildDriverAcceptanceTimeoutOperationKey({
      tripId: params.tripId,
      assignmentAttempt: params.assignmentAttempt,
      driverAssignedAtMillis,
    });
    const payload: DriverAcceptanceTimeoutTaskPayload = {
      operation: "driver_acceptance_timeout",
      operationKey,
      tripId: params.tripId,
      assignedDriverId: params.assignedDriverId,
      assignmentAttempt: params.assignmentAttempt,
      driverAssignedAtMillis,
    };
    const timeoutAt = new Date(driverAssignedAtMillis + ASSIGNMENT_TIMEOUT_MS);
    const tripRef = firestore.doc(`trips/${params.tripId}`);
    await tripRef.set(
      {
        pendingTasks: {
          driverAcceptanceTimeoutKey: operationKey,
          driverAcceptanceTimeoutAt:
            Timestamp.fromDate(timeoutAt),
        },
      },
      { merge: true },
    );
    const taskId = buildUniformTaskId(operationKey);
    const queue = getFunctions().taskQueue<DriverAcceptanceTimeoutTaskPayload>(
      DRIVER_ACCEPTANCE_TIMEOUT_TASK_FUNCTION_NAME,
    );
    try {
      await queue.enqueue(payload, { id: taskId, scheduleTime: timeoutAt });
      logger.info("cost_profile", {
        functionName: "enqueueDriverAcceptanceTimeoutTask",
        operation: "task_enqueued",
        taskId,
        operationKey,
        tripId: params.tripId,
        scheduleTime: timeoutAt.toISOString(),
      });
    } catch (error) {
      if (isAlreadyExistsTaskError(error)) {
        const snapshot = await tripRef.get();
        const currentKey =
          snapshot.data()?.pendingTasks &&
          typeof snapshot.data()?.pendingTasks === "object"
            ? (snapshot.data()?.pendingTasks as Record<string, unknown>)
                .driverAcceptanceTimeoutKey
            : null;
        if (currentKey === operationKey) {
          logger.info("Driver acceptance timeout task already exists.", {
            taskId,
            operationKey,
            tripId: params.tripId,
          });
          return;
        }
      }
      throw error;
    }
  }

  function buildPostChargeExtensionOperationKey(params: {
    tripId: string;
    status:
      | typeof POST_CHARGE_EXTENSION_STATUSES.active
      | typeof POST_CHARGE_EXTENSION_STATUSES.driverPending;
    cycleIndex: number;
    nextActionAtMillis: number;
  }): string {
    return [
      "post_charge_extension",
      params.tripId,
      params.cycleIndex.toString(),
      params.status,
      params.nextActionAtMillis.toString(),
    ].join(":");
  }

  async function enqueuePostChargeExtensionTask(params: {
    tripId: string;
    status:
      | typeof POST_CHARGE_EXTENSION_STATUSES.active
      | typeof POST_CHARGE_EXTENSION_STATUSES.driverPending;
    cycleIndex: number;
    nextActionAt: Date;
  }): Promise<void> {
    const nextActionAtMillis = params.nextActionAt.getTime();
    const operationKey = buildPostChargeExtensionOperationKey({
      tripId: params.tripId,
      status: params.status,
      cycleIndex: params.cycleIndex,
      nextActionAtMillis,
    });
    const payload: PostChargeExtensionTaskPayload = {
      operation: "post_charge_extension_next_action",
      operationKey,
      tripId: params.tripId,
      status: params.status,
      cycleIndex: params.cycleIndex,
      nextActionAtMillis,
    };
    const tripRef = firestore.doc(`trips/${params.tripId}`);
    await tripRef.set(
      {
        postChargeExtension: {
          pendingTaskKey: operationKey,
          pendingTaskAt: Timestamp.fromDate(
            params.nextActionAt,
          ),
        },
      },
      { merge: true },
    );
    const taskId = buildUniformTaskId(operationKey);
    const queue = getFunctions().taskQueue<PostChargeExtensionTaskPayload>(
      POST_CHARGE_EXTENSION_TASK_FUNCTION_NAME,
    );
    try {
      await queue.enqueue(payload, {
        id: taskId,
        scheduleTime: params.nextActionAt,
      });
      logger.info("cost_profile", {
        functionName: "enqueuePostChargeExtensionTask",
        operation: "task_enqueued",
        taskId,
        operationKey,
        tripId: params.tripId,
        status: params.status,
        cycleIndex: params.cycleIndex,
        scheduleTime: params.nextActionAt.toISOString(),
      });
    } catch (error) {
      if (isAlreadyExistsTaskError(error)) {
        const snapshot = await tripRef.get();
        const flow = snapshot.data()?.postChargeExtension;
        const currentKey =
          flow && typeof flow === "object"
            ? (flow as Record<string, unknown>).pendingTaskKey
            : null;
        if (currentKey === operationKey) {
          logger.info("Post-charge extension task already exists.", {
            taskId,
            operationKey,
            tripId: params.tripId,
          });
          return;
        }
      }
      throw error;
    }
  }

  function assertCallableRole(
    callerRole: string | null,
    requiredRole: "client" | "driver",
  ): void {
    if (callerRole !== requiredRole) {
      throw new HttpsError("permission-denied", "Permissões insuficientes.");
    }
  }

  function buildClosedPostChargeExtensionUpdate(params: {
    reason: PostChargeExtensionClosedReason;
    errorCode?: PostChargeExtensionErrorCode;
  }): Record<string, unknown> {
    const { reason, errorCode } = params;
    return {
      "postChargeExtension.isActive": false,
      "postChargeExtension.status": POST_CHARGE_EXTENSION_STATUSES.closed,
      "postChargeExtension.nextActionAt": null,
      "postChargeExtension.closedReason": reason,
      ...(errorCode == null
        ? {
            "postChargeExtension.lastErrorCode":
              FieldValue.delete(),
          }
        : { "postChargeExtension.lastErrorCode": errorCode }),
      "postChargeExtension.updatedAt":
        FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    };
  }

  function buildPostChargeExtensionCyclePayload(
    cycle: PostChargeExtensionCycle,
  ): Record<string, unknown> {
    return {
      cycleIndex: cycle.cycleIndex,
      requestedMinutes: cycle.requestedMinutes,
      ...(cycle.requestedAt ? { requestedAt: cycle.requestedAt } : {}),
      ...(cycle.acceptedAt ? { acceptedAt: cycle.acceptedAt } : {}),
      ...(cycle.startedAt ? { startedAt: cycle.startedAt } : {}),
      ...(cycle.endsAt ? { endsAt: cycle.endsAt } : {}),
      ...(cycle.endedAt ? { endedAt: cycle.endedAt } : {}),
      ...(cycle.endedBy ? { endedBy: cycle.endedBy } : {}),
      ...(cycle.actualSeconds != null
        ? { actualSeconds: cycle.actualSeconds }
        : {}),
      ...(cycle.billedMinutes != null
        ? { billedMinutes: cycle.billedMinutes }
        : {}),
      ...(cycle.waitRateApplied
        ? { waitRateApplied: cycle.waitRateApplied }
        : {}),
      ...(cycle.chargedAmount ? { chargedAmount: cycle.chargedAmount } : {}),
      chargeStatus: cycle.chargeStatus,
      ...(cycle.chargeFailedReason
        ? { chargeFailedReason: cycle.chargeFailedReason }
        : {}),
    };
  }

  function calculateBilledMinutes(actualSeconds: number): number {
    return Math.max(1, Math.ceil(actualSeconds / 60));
  }

  type PostChargeExtensionChargeLockResult =
    | { status: "locked"; cycleIndex: number }
    | { status: "noop"; reason: string };

  async function lockPostChargeExtensionCycleForCharge(params: {
    tripId: string;
    endedBy: "client" | "system";
  }): Promise<PostChargeExtensionChargeLockResult> {
    const { tripId, endedBy } = params;
    const tripRef = firestore.doc(`trips/${tripId}`);
    return firestore.runTransaction<PostChargeExtensionChargeLockResult>(
      async (transaction) => {
        const tripSnapshot = await transaction.get(tripRef);
        const tripData = tripSnapshot.data();
        if (!tripData) {
          throw new HttpsError("not-found", "Viagem não encontrada.");
        }
        if (normalizeTripStatus(tripData.status) !== "CHARGE_APPLIED") {
          return { status: "noop", reason: "invalid_trip_status" };
        }
        const flow = parsePostChargeExtensionFlow(tripData.postChargeExtension);
        if (!flow || !flow.isActive) {
          return { status: "noop", reason: "flow_inactive" };
        }
        if (flow.status === POST_CHARGE_EXTENSION_STATUSES.chargeApplying) {
          return { status: "noop", reason: "already_processing" };
        }
        if (
          flow.status !== POST_CHARGE_EXTENSION_STATUSES.active ||
          !flow.currentCycle
        ) {
          return { status: "noop", reason: "not_active_cycle" };
        }
        if (!flow.currentCycle.startedAt) {
          return { status: "noop", reason: "missing_started_at" };
        }
        const now = new Date();
        const actualSeconds = Math.max(
          0,
          Math.ceil(
            (now.getTime() - flow.currentCycle.startedAt.getTime()) / 1000,
          ),
        );
        const billedMinutes = calculateBilledMinutes(actualSeconds);
        const pricingSnapshot = parsePricingSnapshot(tripData.pricingSnapshot);
        const nextCycle: PostChargeExtensionCycle = {
          ...flow.currentCycle,
          endedAt: now,
          endedBy,
          actualSeconds,
          billedMinutes,
          waitRateApplied: buildMoneyPayload(
            pricingSnapshot.perWaitMinuteMinor,
          ),
          chargeStatus: "pending",
          chargeFailedReason: undefined,
        };
        const updatePayload = {
          "postChargeExtension.status":
            POST_CHARGE_EXTENSION_STATUSES.chargeApplying,
          "postChargeExtension.nextActionAt": null,
          "postChargeExtension.currentCycle":
            buildPostChargeExtensionCyclePayload(nextCycle),
          "postChargeExtension.updatedAt":
            FieldValue.serverTimestamp(),
          "postChargeExtension.lastErrorCode":
            FieldValue.delete(),
          updatedAt: FieldValue.serverTimestamp(),
        };
        enforceTripUpdatePayload({
          payload: updatePayload,
          context: "lockPostChargeExtensionCycleForCharge",
        });
        transaction.update(tripRef, updatePayload);
        return { status: "locked", cycleIndex: flow.currentCycle.cycleIndex };
      },
    );
  }

  async function clearDriverBusyForPostChargeExtension(params: {
    transaction: admin.firestore.Transaction;
    driverId: string | undefined;
    tripId: string;
    driverStatusData?: Record<string, unknown>;
  }): Promise<void> {
    const { transaction, driverId, tripId, driverStatusData } = params;
    if (!driverId) {
      return;
    }
    const driverRef = firestore.doc(`${DRIVER_STATUS_COLLECTION}/${driverId}`);
    const currentTripId =
      typeof driverStatusData?.currentTripId === "string"
        ? driverStatusData.currentTripId
        : null;
    if (currentTripId != null && currentTripId !== tripId) {
      logger.warn("Driver busy clear skipped due to another current trip.", {
        driverId,
        tripId,
        currentTripId,
      });
      return;
    }
    const clearPayload = {
      currentTripId: FieldValue.delete(),
      isBusy: false,
      updatedAt: FieldValue.serverTimestamp(),
    };
    enforceDriverStatusPayload({
      payload: clearPayload,
      context: "clearDriverBusyForPostChargeExtension",
    });
    transaction.set(driverRef, clearPayload, { merge: true });
  }

  async function finalizeLockedPostChargeExtensionCharge(params: {
    tripId: string;
  }): Promise<{ tripId: string; status: string; cycleIndex?: number }> {
    const { tripId } = params;
    const tripRef = firestore.doc(`trips/${tripId}`);
    try {
      return await firestore.runTransaction(async (transaction) => {
        const tripSnapshot = await transaction.get(tripRef);
        const tripData = tripSnapshot.data();
        if (!tripData) {
          throw new HttpsError("not-found", "Viagem não encontrada.");
        }
        const flow = parsePostChargeExtensionFlow(tripData.postChargeExtension);
        if (!flow || !flow.currentCycle) {
          return { tripId, status: "noop" };
        }
        if (normalizeTripStatus(tripData.status) !== "CHARGE_APPLIED") {
          return { tripId, status: "noop" };
        }
        if (flow.status !== POST_CHARGE_EXTENSION_STATUSES.chargeApplying) {
          return { tripId, status: "noop" };
        }
        const cycle = flow.currentCycle;
        if (
          cycle.chargeStatus === "succeeded" ||
          cycle.chargeStatus === "failed"
        ) {
          return { tripId, status: "noop", cycleIndex: cycle.cycleIndex };
        }
        const clientId = tripData.clientId?.toString();
        if (!clientId) {
          throw new HttpsError("failed-precondition", "Viagem sem cliente.");
        }
        const assignedDriverId = tripData.assignedDriverId?.toString();
        const pricingSnapshot = parsePricingSnapshot(tripData.pricingSnapshot);
        const billedMinutes = cycle.billedMinutes ?? 0;
        const chargeMinor =
          Math.max(0, billedMinutes) * pricingSnapshot.perWaitMinuteMinor;
        const ledgerRef = firestore.doc(
          `balance_adjustments/trip_${tripId}_extension_${cycle.cycleIndex}`,
        );
        const balanceRef = firestore.doc(`balances/${clientId}`);
        const driverRef = assignedDriverId
          ? firestore.doc(`${DRIVER_STATUS_COLLECTION}/${assignedDriverId}`)
          : null;
        const [ledgerSnapshot, balanceSnapshot, driverSnapshot] =
          await Promise.all([
            transaction.get(ledgerRef),
            transaction.get(balanceRef),
            driverRef == null
              ? Promise.resolve(null)
              : transaction.get(driverRef),
          ]);
        if (ledgerSnapshot.exists) {
          logger.warn("Post-charge extension ledger already exists.", {
            tripId,
            cycleIndex: cycle.cycleIndex,
          });
          return { tripId, status: "noop", cycleIndex: cycle.cycleIndex };
        }
        const eligibilitySnapshot = parseTripEligibilitySnapshot(
          balanceSnapshot.data(),
        );
        assertMoneyCurrencyOrThrow({
          value: eligibilitySnapshot.balance,
          expectedCurrency: OPERATION_CURRENCY_CODE,
          fieldName: "balance",
        });
        assertMoneyCurrencyOrThrow({
          value: eligibilitySnapshot.debtLimit,
          expectedCurrency: OPERATION_CURRENCY_CODE,
          fieldName: "debtLimit",
        });
        const balanceMinor = eligibilitySnapshot.balance.amountMinor;
        const debtLimitMinor = eligibilitySnapshot.debtLimit.amountMinor;
        const creditLimitMinor = resolveCreditLimitMinor(debtLimitMinor);
        const limitCheckDetails = buildLimitExceededDetails({
          operation: "post_charge_extension_cycle_charge",
          currency: eligibilitySnapshot.balance.currency,
          balanceBeforeMinor: balanceMinor,
          debitAmountMinor: Math.max(chargeMinor, 0),
          creditLimitMinor,
        });
        if (
          !isBalanceWithinCreditLimit({
            balanceAfterMinor: limitCheckDetails.balanceAfterMinor,
            creditLimitMinor,
          })
        ) {
          throwLimitExceededError(limitCheckDetails);
        }
        const updatedBalanceMinor = balanceMinor - chargeMinor;
        const balancePayload = {
          balance: {
            amountMinor: updatedBalanceMinor,
            currency: OPERATION_CURRENCY_CODE,
          },
          debtLimit: {
            amountMinor: debtLimitMinor,
            currency: OPERATION_CURRENCY_CODE,
          },
          updatedAt: FieldValue.serverTimestamp(),
          ...(balanceSnapshot.exists
            ? {}
            : { createdAt: FieldValue.serverTimestamp() }),
        };
        enforceBalancePayload({
          payload: balancePayload,
          context: "finalizeLockedPostChargeExtensionCharge.balance",
        });
        transaction.set(balanceRef, balancePayload, { merge: true });

        const ledgerPayload = {
          clientId,
          adminId: "system",
          delta: {
            amountMinor: -chargeMinor,
            currency: OPERATION_CURRENCY_CODE,
          },
          reason: "Cobrança de extensão pós-cobrança",
          tripId,
          createdAt: FieldValue.serverTimestamp(),
          cycleIndex: cycle.cycleIndex,
          ...buildTripEventTtlField(),
        };
        enforceBalanceAdjustmentPayload({
          payload: ledgerPayload,
          context: "finalizeLockedPostChargeExtensionCharge.ledger",
        });
        transaction.create(ledgerRef, ledgerPayload);

        const chargedCycle: PostChargeExtensionCycle = {
          ...cycle,
          waitRateApplied:
            cycle.waitRateApplied ??
            buildMoneyPayload(pricingSnapshot.perWaitMinuteMinor),
          chargedAmount: buildMoneyPayload(chargeMinor),
          chargeStatus: "succeeded",
          chargeFailedReason: undefined,
        };
        const nextCompletedCount = flow.completedCyclesCount + 1;
        const reachedMaxCycles = nextCompletedCount >= flow.maxCycles;
        const nextHistory = [...flow.history, chargedCycle]
          .slice(-POST_CHARGE_EXTENSION_MAX_CYCLES)
          .map((entry) => buildPostChargeExtensionCyclePayload(entry));
        const tripUpdatePayload = {
          "postChargeExtension.status": reachedMaxCycles
            ? POST_CHARGE_EXTENSION_STATUSES.closed
            : POST_CHARGE_EXTENSION_STATUSES.clientPrompt,
          "postChargeExtension.isActive": !reachedMaxCycles,
          "postChargeExtension.completedCyclesCount": nextCompletedCount,
          "postChargeExtension.nextActionAt": null,
          "postChargeExtension.currentCycle":
            FieldValue.delete(),
          "postChargeExtension.history": nextHistory,
          ...(reachedMaxCycles
            ? {
                "postChargeExtension.closedReason":
                  POST_CHARGE_EXTENSION_CLOSED_REASONS.maxCycles,
              }
            : {
                "postChargeExtension.closedReason":
                  FieldValue.delete(),
              }),
          "postChargeExtension.lastErrorCode":
            FieldValue.delete(),
          "postChargeExtension.updatedAt":
            FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        };
        enforceTripUpdatePayload({
          payload: tripUpdatePayload,
          context: "finalizeLockedPostChargeExtensionCharge.trip",
        });
        transaction.update(tripRef, tripUpdatePayload);
        await clearDriverBusyForPostChargeExtension({
          transaction,
          driverId: assignedDriverId,
          tripId,
          driverStatusData:
            driverSnapshot?.data() == null
              ? undefined
              : (driverSnapshot.data() as Record<string, unknown>),
        });
        return { tripId, status: "charged", cycleIndex: cycle.cycleIndex };
      });
    } catch (error) {
      const errorCode =
        error instanceof HttpsError && error.code === "failed-precondition"
          ? POST_CHARGE_EXTENSION_ERROR_CODES.creditLimit
          : POST_CHARGE_EXTENSION_ERROR_CODES.paymentInternal;
      await firestore.runTransaction(async (transaction) => {
        const tripSnapshot = await transaction.get(tripRef);
        const tripData = tripSnapshot.data();
        if (!tripData) {
          return;
        }
        const flow = parsePostChargeExtensionFlow(tripData.postChargeExtension);
        if (
          !flow ||
          flow.status !== POST_CHARGE_EXTENSION_STATUSES.chargeApplying
        ) {
          return;
        }
        const cycle = flow.currentCycle;
        const assignedDriverId = tripData.assignedDriverId?.toString();
        const driverRef = assignedDriverId
          ? firestore.doc(`${DRIVER_STATUS_COLLECTION}/${assignedDriverId}`)
          : null;
        const driverSnapshot =
          driverRef == null ? null : await transaction.get(driverRef);
        const failedCycle =
          cycle == null
            ? undefined
            : buildPostChargeExtensionCyclePayload({
                ...cycle,
                chargeStatus: "failed",
                chargeFailedReason:
                  errorCode === POST_CHARGE_EXTENSION_ERROR_CODES.creditLimit
                    ? "credit_limit"
                    : "payment_internal",
              });
        const failurePayload = {
          ...buildClosedPostChargeExtensionUpdate({
            reason: POST_CHARGE_EXTENSION_CLOSED_REASONS.chargeFailed,
            errorCode,
          }),
          ...(failedCycle == null
            ? {}
            : { "postChargeExtension.currentCycle": failedCycle }),
        };
        enforceTripUpdatePayload({
          payload: failurePayload,
          context: "finalizeLockedPostChargeExtensionCharge.failure",
        });
        transaction.update(tripRef, failurePayload);
        await clearDriverBusyForPostChargeExtension({
          transaction,
          driverId: assignedDriverId,
          tripId,
          driverStatusData:
            driverSnapshot?.data() == null
              ? undefined
              : (driverSnapshot.data() as Record<string, unknown>),
        });
      });
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("internal", "Falha na cobrança da extensão.");
    }
  }

  async function processPostChargeExtensionActiveTimeout(params: {
    tripId: string;
  }): Promise<void> {
    const lockResult = await lockPostChargeExtensionCycleForCharge({
      tripId: params.tripId,
      endedBy: "system",
    });
    if (lockResult.status !== "locked") {
      return;
    }
    await finalizeLockedPostChargeExtensionCharge({ tripId: params.tripId });
  }

  async function processPostChargeExtensionDriverPendingTimeout(params: {
    tripId: string;
  }): Promise<void> {
    const { tripId } = params;
    const tripRef = firestore.doc(`trips/${tripId}`);
    await firestore.runTransaction(async (transaction) => {
      const tripSnapshot = await transaction.get(tripRef);
      const tripData = tripSnapshot.data();
      if (!tripData) {
        return;
      }
      if (normalizeTripStatus(tripData.status) !== "CHARGE_APPLIED") {
        return;
      }
      const flow = parsePostChargeExtensionFlow(tripData.postChargeExtension);
      if (
        !flow ||
        flow.status !== POST_CHARGE_EXTENSION_STATUSES.driverPending
      ) {
        return;
      }
      const dueAt = flow.nextActionAt;
      if (!(dueAt instanceof Date) || dueAt.getTime() > Date.now()) {
        return;
      }
      const updatePayload = buildClosedPostChargeExtensionUpdate({
        reason: POST_CHARGE_EXTENSION_CLOSED_REASONS.driverNoResponseTimeout,
        errorCode: POST_CHARGE_EXTENSION_ERROR_CODES.driverNoResponseTimeout,
      });
      enforceTripUpdatePayload({
        payload: updatePayload,
        context: "processPostChargeExtensionDriverPendingTimeout",
      });
      transaction.update(tripRef, updatePayload);
    });
  }

  async function handleDriverAcceptanceTimeoutTask(
    payload: DriverAcceptanceTimeoutTaskPayload,
  ): Promise<void> {
    if (
      payload.operation !== "driver_acceptance_timeout" ||
      !payload.tripId ||
      !payload.assignedDriverId ||
      !Number.isFinite(payload.assignmentAttempt) ||
      !Number.isFinite(payload.driverAssignedAtMillis)
    ) {
      logger.error("Invalid driver acceptance timeout task payload.", {
        payload,
      });
      return;
    }
    logger.info("cost_profile", {
      functionName: "processDriverAcceptanceTimeout",
      operation: "task_executed",
      tripId: payload.tripId,
      operationKey: payload.operationKey,
    });
    const timeoutAt = new Date(
      payload.driverAssignedAtMillis + ASSIGNMENT_TIMEOUT_MS,
    );
    if (timeoutAt.getTime() > Date.now()) {
      logger.info("cost_profile", {
        functionName: "processDriverAcceptanceTimeout",
        operation: "task_noop_stale",
        reason: "not_due",
        tripId: payload.tripId,
        operationKey: payload.operationKey,
      });
      return;
    }
    const tripSnapshot = await firestore.doc(`trips/${payload.tripId}`).get();
    const tripData = tripSnapshot.data();
    const clientId = tripData?.clientId?.toString();
    const didUpdate = await markTripNoDriversAvailableWithEvent({
      tripId: payload.tripId,
      reason: "driver_timeout",
      expectedFromStatuses: ["DRIVER_ASSIGNED_WAITING_ACCEPTANCE"],
      driverAssignedAtMillis: payload.driverAssignedAtMillis,
      expectedAssignedDriverId: payload.assignedDriverId,
      expectedAssignmentAttempt: payload.assignmentAttempt,
    });
    if (!didUpdate) {
      logger.info("cost_profile", {
        functionName: "processDriverAcceptanceTimeout",
        operation: "task_noop_stale",
        reason: "state_mismatch",
        tripId: payload.tripId,
        operationKey: payload.operationKey,
      });
      return;
    }
    logger.warn("Trip marked as no drivers available by timeout task.", {
      tripId: payload.tripId,
      assignedDriverId: payload.assignedDriverId,
      assignmentAttempt: payload.assignmentAttempt,
    });
    if (clientId) {
      await notifyClientUnfulfilled(clientId, payload.tripId, "driver_timeout");
    }
  }

  async function handlePostChargeExtensionTask(
    payload: PostChargeExtensionTaskPayload,
  ): Promise<void> {
    if (
      payload.operation !== "post_charge_extension_next_action" ||
      !payload.tripId ||
      !Number.isFinite(payload.cycleIndex) ||
      !Number.isFinite(payload.nextActionAtMillis) ||
      (payload.status !== POST_CHARGE_EXTENSION_STATUSES.active &&
        payload.status !== POST_CHARGE_EXTENSION_STATUSES.driverPending)
    ) {
      logger.error("Invalid post-charge extension task payload.", { payload });
      return;
    }
    logger.info("cost_profile", {
      functionName: "processPostChargeExtensionNextAction",
      operation: "task_executed",
      tripId: payload.tripId,
      operationKey: payload.operationKey,
      status: payload.status,
      cycleIndex: payload.cycleIndex,
    });
    const tripSnapshot = await firestore.doc(`trips/${payload.tripId}`).get();
    const tripData = tripSnapshot.data();
    const flow = parsePostChargeExtensionFlow(tripData?.postChargeExtension);
    const currentNextActionAtMillis = flow?.nextActionAt?.getTime();
    if (
      normalizeTripStatus(tripData?.status) !== "CHARGE_APPLIED" ||
      !flow ||
      !flow.isActive ||
      flow.status !== payload.status ||
      flow.currentCycle?.cycleIndex !== payload.cycleIndex ||
      currentNextActionAtMillis !== payload.nextActionAtMillis ||
      payload.nextActionAtMillis > Date.now()
    ) {
      logger.info("cost_profile", {
        functionName: "processPostChargeExtensionNextAction",
        operation: "task_noop_stale",
        tripId: payload.tripId,
        operationKey: payload.operationKey,
        status: payload.status,
        cycleIndex: payload.cycleIndex,
      });
      return;
    }
    if (payload.status === POST_CHARGE_EXTENSION_STATUSES.active) {
      await processPostChargeExtensionActiveTimeout({
        tripId: payload.tripId,
      });
      return;
    }
    await processPostChargeExtensionDriverPendingTimeout({
      tripId: payload.tripId,
    });
  }

  void legacyRequestTripExtension;
  void legacyRespondTripExtension;

  const requestTripExtension = onCall(
    STANDARD_CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Auth required");
      }
      const requesterId = requireAuthenticatedUid(request.auth);
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      assertCallableRole(callerRole, "client");
      const data = request.data as Record<string, unknown> | null;
      const tripId = parseRequiredTripIdFromCallableData(data);
      const durationMinutes = parsePostChargeExtensionDurationMinutes(data);
      const tripRef = firestore.doc(`trips/${tripId}`);

      const result = await firestore.runTransaction(async (transaction) => {
        const tripSnapshot = await transaction.get(tripRef);
        const tripData = tripSnapshot.data();
        if (!tripData) {
          throw new HttpsError("not-found", "Viagem não encontrada.");
        }
        if (normalizeTripStatus(tripData.status) !== "CHARGE_APPLIED") {
          throw new HttpsError(
            "failed-precondition",
            "Estado atual não permite extensão.",
          );
        }
        const clientId = tripData.clientId?.toString();
        if (clientId !== requesterId) {
          throw new HttpsError(
            "permission-denied",
            "Permissões insuficientes.",
          );
        }
        const assignedDriverId = tripData.assignedDriverId?.toString();
        if (!assignedDriverId) {
          throw new HttpsError(
            "failed-precondition",
            "Viagem sem motorista atribuído.",
          );
        }
        const flow = parsePostChargeExtensionFlow(tripData.postChargeExtension);
        if (!flow) {
          throw new HttpsError(
            "failed-precondition",
            "Fluxo de extensão indisponível.",
          );
        }
        if (
          !flow.isActive ||
          flow.status === POST_CHARGE_EXTENSION_STATUSES.closed
        ) {
          return {
            tripId,
            status: "closed",
            reason:
              flow.closedReason ??
              POST_CHARGE_EXTENSION_CLOSED_REASONS.clientClosed,
          };
        }
        if (flow.status === POST_CHARGE_EXTENSION_STATUSES.driverPending) {
          return {
            tripId,
            status: "driverPending",
            cycleIndex:
              flow.currentCycle?.cycleIndex ?? flow.completedCyclesCount + 1,
          };
        }
        if (flow.status !== POST_CHARGE_EXTENSION_STATUSES.clientPrompt) {
          throw new HttpsError(
            "failed-precondition",
            "Extensão indisponível neste estado.",
          );
        }
        if (flow.completedCyclesCount >= flow.maxCycles) {
          const maxCyclesPayload = buildClosedPostChargeExtensionUpdate({
            reason: POST_CHARGE_EXTENSION_CLOSED_REASONS.maxCycles,
          });
          enforceTripUpdatePayload({
            payload: maxCyclesPayload,
            context: "requestTripExtension.maxCycles",
          });
          transaction.update(tripRef, maxCyclesPayload);
          return { tripId, status: "closed", reason: "max_cycles" };
        }

        const driverRef = firestore.doc(
          `${DRIVER_STATUS_COLLECTION}/${assignedDriverId}`,
        );
        const driverSnapshot = await transaction.get(driverRef);
        const driverData = driverSnapshot.data() ?? {};
        const currentTripId =
          typeof driverData.currentTripId === "string"
            ? driverData.currentTripId
            : null;
        const isBusy = driverData.isBusy === true || currentTripId !== null;
        if (isBusy && currentTripId !== tripId) {
          const unavailablePayload = buildClosedPostChargeExtensionUpdate({
            reason: POST_CHARGE_EXTENSION_CLOSED_REASONS.driverUnavailable,
            errorCode: POST_CHARGE_EXTENSION_ERROR_CODES.driverUnavailable,
          });
          enforceTripUpdatePayload({
            payload: unavailablePayload,
            context: "requestTripExtension.driverUnavailable",
          });
          transaction.update(tripRef, unavailablePayload);
          return { tripId, status: "closed", reason: "driver_unavailable" };
        }

        const cycleIndex = flow.completedCyclesCount + 1;
        const now = new Date();
        const timeoutAt = new Date(
          now.getTime() + POST_CHARGE_EXTENSION_DRIVER_PENDING_TIMEOUT_MS,
        );
        const updatePayload = {
          "postChargeExtension.isActive": true,
          "postChargeExtension.status":
            POST_CHARGE_EXTENSION_STATUSES.driverPending,
          "postChargeExtension.nextActionAt":
            Timestamp.fromDate(timeoutAt),
          "postChargeExtension.currentCycle": {
            cycleIndex,
            requestedMinutes: durationMinutes,
            requestedAt: Timestamp.fromDate(now),
            chargeStatus: "pending",
          },
          "postChargeExtension.closedReason":
            FieldValue.delete(),
          "postChargeExtension.lastErrorCode":
            FieldValue.delete(),
          "postChargeExtension.updatedAt":
            FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        };
        enforceTripUpdatePayload({
          payload: updatePayload,
          context: "requestTripExtension",
        });
        transaction.update(tripRef, updatePayload);
        logger.info("Post-charge extension requested.", {
          tripId,
          requesterId,
          cycleIndex,
          durationMinutes,
        });
        return {
          tripId,
          status: "driverPending",
          cycleIndex,
          durationMinutes,
          nextActionAtMillis: timeoutAt.getTime(),
        };
      });
      if (
        result.status === "driverPending" &&
        typeof result.nextActionAtMillis === "number"
      ) {
        await enqueuePostChargeExtensionTask({
          tripId,
          status: POST_CHARGE_EXTENSION_STATUSES.driverPending,
          cycleIndex: result.cycleIndex,
          nextActionAt: new Date(result.nextActionAtMillis),
        });
      }
      return result;
    },
  );

  const respondTripExtension = onCall(
    STANDARD_CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Auth required");
      }
      const requesterId = requireAuthenticatedUid(request.auth);
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      assertCallableRole(callerRole, "driver");
      const data = request.data as Record<string, unknown> | null;
      const tripId = parseRequiredTripIdFromCallableData(data);
      const isAccepted = data?.isAccepted === true;
      const tripRef = firestore.doc(`trips/${tripId}`);

      const result = await firestore.runTransaction(async (transaction) => {
        const tripSnapshot = await transaction.get(tripRef);
        const tripData = tripSnapshot.data();
        if (!tripData) {
          throw new HttpsError("not-found", "Viagem não encontrada.");
        }
        if (normalizeTripStatus(tripData.status) !== "CHARGE_APPLIED") {
          throw new HttpsError(
            "failed-precondition",
            "Estado atual não permite resposta.",
          );
        }
        const assignedDriverId = tripData.assignedDriverId?.toString();
        if (!assignedDriverId || assignedDriverId !== requesterId) {
          throw new HttpsError(
            "permission-denied",
            "Permissões insuficientes.",
          );
        }
        const flow = parsePostChargeExtensionFlow(tripData.postChargeExtension);
        if (!flow || !flow.currentCycle) {
          throw new HttpsError(
            "failed-precondition",
            "Pedido de extensão indisponível.",
          );
        }
        if (flow.status === POST_CHARGE_EXTENSION_STATUSES.active) {
          return {
            tripId,
            status: "active",
            cycleIndex: flow.currentCycle.cycleIndex,
          };
        }
        if (flow.status !== POST_CHARGE_EXTENSION_STATUSES.driverPending) {
          throw new HttpsError("failed-precondition", "Sem pedido pendente.");
        }
        const now = new Date();
        if (!isAccepted) {
          const updatePayload = buildClosedPostChargeExtensionUpdate({
            reason: POST_CHARGE_EXTENSION_CLOSED_REASONS.declinedByDriver,
          });
          enforceTripUpdatePayload({
            payload: updatePayload,
            context: "respondTripExtension.decline",
          });
          transaction.update(tripRef, updatePayload);
          logger.info("Post-charge extension declined by driver.", {
            tripId,
            cycleIndex: flow.currentCycle.cycleIndex,
            driverId: requesterId,
          });
          return {
            tripId,
            status: "closed",
            reason: "declined_by_driver",
            cycleIndex: flow.currentCycle.cycleIndex,
          };
        }
        const driverStatusRef = firestore.doc(
          `${DRIVER_STATUS_COLLECTION}/${requesterId}`,
        );
        const driverStatusSnapshot = await transaction.get(driverStatusRef);
        const driverStatusData = driverStatusSnapshot.data() ?? {};
        const driverCurrentTripId =
          typeof driverStatusData.currentTripId === "string"
            ? driverStatusData.currentTripId
            : null;
        const driverAlreadyBusy =
          driverStatusData.isBusy === true || driverCurrentTripId !== null;
        if (driverAlreadyBusy && driverCurrentTripId !== tripId) {
          const unavailablePayload = buildClosedPostChargeExtensionUpdate({
            reason: POST_CHARGE_EXTENSION_CLOSED_REASONS.driverUnavailable,
            errorCode: POST_CHARGE_EXTENSION_ERROR_CODES.driverUnavailable,
          });
          enforceTripUpdatePayload({
            payload: unavailablePayload,
            context: "respondTripExtension.accept.driverUnavailable",
          });
          transaction.update(tripRef, unavailablePayload);
          return {
            tripId,
            status: "closed",
            reason: "driver_unavailable",
            cycleIndex: flow.currentCycle.cycleIndex,
          };
        }
        const endsAt = new Date(
          now.getTime() + flow.currentCycle.requestedMinutes * 60 * 1000,
        );
        const activeCycle = {
          ...flow.currentCycle,
          acceptedAt: now,
          startedAt: now,
          endsAt,
          chargeStatus: "pending" as const,
        };
        const updatePayload = {
          "postChargeExtension.isActive": true,
          "postChargeExtension.status": POST_CHARGE_EXTENSION_STATUSES.active,
          "postChargeExtension.nextActionAt":
            Timestamp.fromDate(endsAt),
          "postChargeExtension.currentCycle":
            buildPostChargeExtensionCyclePayload(activeCycle),
          "postChargeExtension.closedReason":
            FieldValue.delete(),
          "postChargeExtension.lastErrorCode":
            FieldValue.delete(),
          "postChargeExtension.updatedAt":
            FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        };
        enforceTripUpdatePayload({
          payload: updatePayload,
          context: "respondTripExtension.accept",
        });
        transaction.update(tripRef, updatePayload);
        const driverBusyPayload = {
          currentTripId: tripId,
          isBusy: true,
          updatedAt: FieldValue.serverTimestamp(),
        };
        enforceDriverStatusPayload({
          payload: driverBusyPayload,
          context: "respondTripExtension.accept.driverStatus",
        });
        transaction.set(driverStatusRef, driverBusyPayload, { merge: true });
        logger.info("Post-charge extension accepted by driver.", {
          tripId,
          cycleIndex: flow.currentCycle.cycleIndex,
          driverId: requesterId,
          endsAt: endsAt.toISOString(),
        });
        return {
          tripId,
          status: "active",
          cycleIndex: flow.currentCycle.cycleIndex,
          nextActionAtMillis: endsAt.getTime(),
        };
      });
      if (
        result.status === "active" &&
        typeof result.nextActionAtMillis === "number"
      ) {
        await enqueuePostChargeExtensionTask({
          tripId,
          status: POST_CHARGE_EXTENSION_STATUSES.active,
          cycleIndex: result.cycleIndex,
          nextActionAt: new Date(result.nextActionAtMillis),
        });
      }
      return result;
    },
  );

  const closeTripExtensionFlow = onCall(
    STANDARD_CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Auth required");
      }
      const requesterId = requireAuthenticatedUid(request.auth);
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      assertCallableRole(callerRole, "client");
      const data = request.data as Record<string, unknown> | null;
      const tripId = parseRequiredTripIdFromCallableData(data);
      const tripRef = firestore.doc(`trips/${tripId}`);
      return firestore.runTransaction(async (transaction) => {
        const tripSnapshot = await transaction.get(tripRef);
        const tripData = tripSnapshot.data();
        if (!tripData) {
          throw new HttpsError("not-found", "Viagem não encontrada.");
        }
        if (tripData.clientId?.toString() !== requesterId) {
          throw new HttpsError(
            "permission-denied",
            "Permissões insuficientes.",
          );
        }
        if (normalizeTripStatus(tripData.status) !== "CHARGE_APPLIED") {
          throw new HttpsError(
            "failed-precondition",
            "Estado atual não permite fechar.",
          );
        }
        const flow = parsePostChargeExtensionFlow(tripData.postChargeExtension);
        if (!flow || !flow.isActive) {
          return { tripId, status: "noop" };
        }
        if (
          flow.status !== POST_CHARGE_EXTENSION_STATUSES.clientPrompt &&
          flow.status !== POST_CHARGE_EXTENSION_STATUSES.driverPending
        ) {
          throw new HttpsError(
            "failed-precondition",
            "Fluxo não pode ser fechado agora.",
          );
        }
        const updatePayload = buildClosedPostChargeExtensionUpdate({
          reason: POST_CHARGE_EXTENSION_CLOSED_REASONS.clientClosed,
        });
        enforceTripUpdatePayload({
          payload: updatePayload,
          context: "closeTripExtensionFlow",
        });
        transaction.update(tripRef, updatePayload);
        return { tripId, status: "closed", reason: "client_closed" };
      });
    },
  );

  const endTripExtensionEarly = onCall(
    STANDARD_CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Auth required");
      }
      const requesterId = requireAuthenticatedUid(request.auth);
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      assertCallableRole(callerRole, "client");
      const data = request.data as Record<string, unknown> | null;
      const tripId = parseRequiredTripIdFromCallableData(data);
      const tripSnapshot = await firestore.doc(`trips/${tripId}`).get();
      const tripData = tripSnapshot.data();
      if (!tripData) {
        throw new HttpsError("not-found", "Viagem não encontrada.");
      }
      if (tripData.clientId?.toString() !== requesterId) {
        throw new HttpsError("permission-denied", "Permissões insuficientes.");
      }
      const lockResult = await lockPostChargeExtensionCycleForCharge({
        tripId,
        endedBy: "client",
      });
      if (lockResult.status !== "locked") {
        return { tripId, status: "noop", reason: lockResult.reason };
      }
      return finalizeLockedPostChargeExtensionCharge({ tripId });
    },
  );

  const sweepPostChargeTripExtensionsJob = async (): Promise<void> => {
    const now = Timestamp.now();
    const dueQueries = [
      POST_CHARGE_EXTENSION_STATUSES.active,
      POST_CHARGE_EXTENSION_STATUSES.driverPending,
    ] as const;

    for (const status of dueQueries) {
      let recoveredCount = 0;
      const snapshot = await firestore
        .collection("trips")
        .where("postChargeExtension.status", "==", status)
        .where("postChargeExtension.nextActionAt", "<=", now)
        .orderBy("postChargeExtension.nextActionAt")
        .limit(POST_CHARGE_EXTENSION_SWEEP_BATCH_SIZE)
        .get();

      if (snapshot.empty) {
        continue;
      }

      logger.info("Sweeping post-charge trip extensions.", {
        status,
        count: snapshot.size,
      });

      for (const doc of snapshot.docs) {
        try {
          if (status === POST_CHARGE_EXTENSION_STATUSES.active) {
            await processPostChargeExtensionActiveTimeout({ tripId: doc.id });
          } else {
            await processPostChargeExtensionDriverPendingTimeout({
              tripId: doc.id,
            });
          }
          recoveredCount += 1;
        } catch (error) {
          logger.error("Failed processing post-charge extension sweep item.", {
            tripId: doc.id,
            status,
            error,
          });
        }
      }
      logger.info("cost_profile", {
        functionName: "sweepPostChargeTripExtensions",
        operation: "fallback_sweep_recovered",
        recoveredCount,
        scannedCount: snapshot.size,
        status,
      });
    }
  };

  const TRIP_EXTENSION_WINDOW_MS = 60 * 1000;

  const autoCompleteTripExtensionWindow = onDocumentUpdated(
    {
      document: "trips/{tripId}",
      region: "europe-southwest1",
    },
    async (event) => {
      const beforeData = event.data?.before.data();
      const afterData = event.data?.after.data();
      if (!afterData) {
        return;
      }

      const beforeStatus = normalizeTripStatus(beforeData?.status);
      const afterStatus = normalizeTripStatus(afterData.status);
      const beforeExtensionWindowAt =
        beforeData?.extensionWindowAt?.toMillis?.() ?? null;
      const afterExtensionWindowAt =
        afterData.extensionWindowAt?.toMillis?.() ?? null;
      if (
        beforeStatus === afterStatus &&
        beforeExtensionWindowAt === afterExtensionWindowAt
      ) {
        logger.info("cost_profile", {
          functionName: "autoCompleteTripExtensionWindow",
          operation: "trigger_skipped_diff_guard",
          tripId: event.params.tripId,
        });
        return;
      }
      if (afterStatus !== "EXTENSION_WINDOW") {
        return;
      }

      const extensionWindowAt = afterData.extensionWindowAt?.toDate?.();
      if (!(extensionWindowAt instanceof Date)) {
        return;
      }

      const now = new Date();
      if (
        now.getTime() - extensionWindowAt.getTime() <
        TRIP_EXTENSION_WINDOW_MS
      ) {
        return;
      }

      const tripId = event.params.tripId;
      const tripRef = firestore.doc(`trips/${tripId}`);
      const eventRef = firestore
        .collection("tripEvents")
        .doc(tripId)
        .collection("events")
        .doc("auto_completed");

      try {
        await firestore.runTransaction(async (transaction) => {
          const tripSnapshot = await transaction.get(tripRef);
          const tripData = tripSnapshot.data();
          if (!tripData) {
            return;
          }

          const currentStatus = normalizeTripStatus(tripData.status);
          if (currentStatus !== "EXTENSION_WINDOW") {
            return;
          }

          if (hasChargeApplied(tripData)) {
            return;
          }

          const eventSnapshot = await transaction.get(eventRef);

          const tripUpdatePayload = {
            status: "COMPLETED",
            statusEnteredAt: FieldValue.serverTimestamp(),
            completedAt: FieldValue.serverTimestamp(),
            paymentStatus: "PENDING",
            paymentPendingAt: FieldValue.serverTimestamp(),
            paymentPaidAt: FieldValue.delete(),
            paymentFailedAt: FieldValue.delete(),
            updatedAt: FieldValue.serverTimestamp(),
          };
          enforceTripUpdatePayload({
            payload: tripUpdatePayload,
            context: "autoCompleteExtensionWindow",
          });
          transaction.update(tripRef, tripUpdatePayload);

          if (!eventSnapshot.exists) {
            const eventPayload = {
              fromState: "extension_window",
              toState: "completed",
              actorId: "system",
              eventType: "state_transition",
              createdAt: FieldValue.serverTimestamp(),
              ...buildTripEventTtlField(),
            };
            enforceTripEventPayload({
              payload: eventPayload,
              context: "autoCompleteExtensionWindow",
            });
            transaction.set(eventRef, eventPayload);
          }
        });
      } catch (error) {
        logger.error("Failed to auto-complete extension window.", {
          tripId,
          error,
        });
      }
    },
  );

  const activateReservationsForDayJob = async (): Promise<void> => {
    const now = new Date();
    if (!isAfterReservationActivation(now, RESERVATION_ACTIVATION_TIMEZONE)) {
      logger.info("Reservation activation skipped before 05:00.", {
        now: now.toISOString(),
      });
      return;
    }

    const scheduledDayKey = buildScheduledDayKey(
      now,
      RESERVATION_ACTIVATION_TIMEZONE,
    );
    const lockRef = firestore
      .collection("jobs")
      .doc(`activateReservations_${scheduledDayKey}`);
    const lockClaimed = await firestore.runTransaction(async (transaction) => {
      const lockSnapshot = await transaction.get(lockRef);
      if (lockSnapshot.exists) {
        return false;
      }

      transaction.set(lockRef, {
        status: "running",
        scheduledDayKey,
        createdAt: FieldValue.serverTimestamp(),
        expiresAt: buildTtlTimestamp(JOB_LOCK_TTL_DAYS),
      });
      return true;
    });
    if (!lockClaimed) {
      logger.info("Reservation activation lock already claimed.", {
        scheduledDayKey,
        lockPath: lockRef.path,
      });
      return;
    }

    logger.info("Reservation activation lock claimed.", {
      scheduledDayKey,
      lockPath: lockRef.path,
    });

    const bounds = getLocalDayBounds(now, RESERVATION_ACTIVATION_TIMEZONE);
    logger.info("Activating reservations for day.", {
      scheduledDayKey,
      start: bounds.start.toISOString(),
      end: bounds.end.toISOString(),
    });

    try {
      const snapshot = await firestore
        .collection("reservations")
        .where("status", "==", "scheduled")
        .where("scheduledDayKey", "==", scheduledDayKey)
        .get();

      if (snapshot.empty) {
        logger.info("No reservations scheduled for activation window.");
        return;
      }

      const activatableReservationDocs = snapshot.docs.filter(
        (doc) => doc.data().source !== TRIP_PACKAGE_SOURCE,
      );
      if (activatableReservationDocs.length === 0) {
        logger.info(
          "No internal reservations scheduled for daily activation.",
          {
            scheduledReservations: snapshot.size,
          },
        );
        return;
      }

      const availableDrivers = await fetchAvailableDrivers();
      if (availableDrivers.length === 0) {
        const reason = "no_available_drivers_status";
        logger.warn("No available drivers found.", {
          reservations: activatableReservationDocs.length,
          reason,
        });
        await Promise.all(
          activatableReservationDocs.map((doc) =>
            markReservationFailed({
              reservationId: doc.id,
              clientId: doc.data().clientId?.toString(),
              reason,
            }),
          ),
        );
        return;
      }

      const reservedAssignments: ReservedAssignment[] = [];

      const tariffSeed = await fetchCurrentTariffSeed();
      for (const doc of activatableReservationDocs) {
        const reservationId = doc.id;
        const reservationData = doc.data();
        const clientId = reservationData.clientId?.toString();
        if (!clientId) {
          logger.error("Reservation missing clientId.", { reservationId });
          await markReservationFailed({
            reservationId,
            clientId: undefined,
            reason: "missing_client",
          });
          continue;
        }

        const pickup = parseTripLocation(reservationData.pickup);
        const destination = parseTripLocation(reservationData.destination);
        const transportType = parseTransportType(reservationData.transportType);
        if (!pickup || !destination || !transportType) {
          logger.error("Reservation missing route data.", {
            reservationId,
            hasPickup: Boolean(pickup),
            hasDestination: Boolean(destination),
            hasTransport: Boolean(transportType),
          });
          await markReservationFailed({
            reservationId,
            clientId,
            reason: "missing_route",
          });
          continue;
        }

        const scheduledAt = reservationData.scheduledAt?.toDate?.();
        if (!(scheduledAt instanceof Date)) {
          logger.error("Reservation missing scheduledAt.", { reservationId });
          await markReservationFailed({
            reservationId,
            clientId,
            reason: "missing_schedule",
          });
          continue;
        }

        try {
          const reservationWindow = buildReservationWindow({
            start: scheduledAt,
            pickup,
            destination,
          });
          const candidateResolution = await resolveDriverCandidates(
            availableDrivers,
            pickup,
          );
          const candidates = candidateResolution.candidates;
          if (candidates.length === 0) {
            const reason = buildNoLocationFailureReason(candidateResolution);
            logger.warn("No driver candidates available for reservation.", {
              reservationId,
              reason,
              attemptedRadiiKm: candidateResolution.attemptedRadiiKm,
              nearbyUniqueCount: candidateResolution.nearbyUniqueCount,
              filteredOutByStatusCount:
                candidateResolution.filteredOutByStatusCount,
            });
            await markReservationFailed({
              reservationId,
              clientId,
              reason,
            });
            continue;
          }
          const preferredDriverId =
            reservationData.source === INTERNAL_STAFF_RESERVATION_SOURCE &&
            typeof reservationData.assignedDriverId === "string"
              ? reservationData.assignedDriverId.trim()
              : "";
          let assignment: DriverVehicleCandidate | null = null;
          if (preferredDriverId) {
            assignment = await resolvePreferredReservationAssignment({
              availableDrivers,
              candidates,
              preferredDriverId,
              reservationId,
              window: reservationWindow,
              reservedAssignments,
            });
          }

          if (!assignment) {
            const vehicleSelection = await selectDriverVehicleCandidate({
              candidates,
              window: reservationWindow,
              reservedAssignments,
            });
            assignment = vehicleSelection.assignment;
            if (!assignment) {
              const reason = buildNoAssignableDriverReason(
                vehicleSelection.diagnostics,
              );
              logger.warn("No assignable driver/vehicle for reservation.", {
                reservationId,
                reason,
                diagnostics: vehicleSelection.diagnostics,
                preferredDriverId: preferredDriverId || null,
              });
              await markReservationFailed({
                reservationId,
                clientId,
                reason,
              });
              continue;
            }
            if (preferredDriverId && assignment.id !== preferredDriverId) {
              logger.warn(
                "Reservation activation fell back from preferred driver.",
                {
                  reservationId,
                  preferredDriverId,
                  fallbackDriverId: assignment.id,
                  fallbackVehicleId: assignment.vehicleId,
                },
              );
            }
          }
          const tripId = await createTripFromReservation({
            reservationId,
            clientId,
            pickup,
            destination,
            transportType,
            tariffSeed,
            scheduledAt,
            assignedDriverId: assignment.id,
            vehicleId: assignment.vehicleId,
          });
          if (!tripId) {
            logger.info("Reservation activation skipped.", {
              reservationId,
              clientId,
            });
            continue;
          }
          reservedAssignments.push({
            driverId: assignment.id,
            vehicleId: assignment.vehicleId,
            window: reservationWindow,
          });
          logger.info("Reservation activated into trip.", {
            reservationId,
            tripId,
            clientId,
          });
        } catch (error) {
          logger.error("Failed to activate reservation into trip.", {
            reservationId,
            clientId,
            error,
          });
          await markReservationFailed({
            reservationId,
            clientId,
            reason: "trip_creation_failed",
          });
        }
      }
    } finally {
      try {
        await lockRef.set(
          {
            status: "completed",
            releasedAt: FieldValue.serverTimestamp(),
            expiresAt: buildTtlTimestamp(JOB_LOCK_TTL_DAYS),
          },
          { merge: true },
        );
        logger.info("Reservation activation lock released.", {
          scheduledDayKey,
          lockPath: lockRef.path,
        });
      } catch (error) {
        logger.error("Failed to release reservation activation lock.", {
          scheduledDayKey,
          lockPath: lockRef.path,
          error,
        });
      }
    }
  };

  const notifyDriverOnAdminEventCreation = onDocumentCreated(
    {
      document: "events/{eventId}",
      region: "europe-southwest1",
    },
    async (event) => {
      const snapshot = event.data;
      if (!snapshot) {
        logger.warn("Event creation missing snapshot.");
        return;
      }

      const eventId = event.params.eventId;
      const data = snapshot.data() as ScheduledEventSnapshot;
      const targetType = data.targetType?.toString();
      const targetIds = normalizeEventTargetIds(data.targetIds);
      const createdByAdminId = data.createdByAdminId?.toString();

      if (targetType !== "driver") {
        logger.info("Event creation skipped (not driver target).", {
          eventId,
          targetType,
        });
        return;
      }

      if (targetIds.length === 0) {
        logger.warn("Driver event missing targetIds.", { eventId });
        return;
      }

      if (!createdByAdminId || createdByAdminId === "system") {
        logger.info("Driver event notification skipped (system origin).", {
          eventId,
          targetCount: targetIds.length,
          createdByAdminId,
        });
        return;
      }

      const now = new Date();
      const freshEventSnapshot = await firestore.doc(`events/${eventId}`).get();
      if (!freshEventSnapshot.exists) {
        logger.info("Driver event removed before notification dispatch.", {
          eventId,
          targetCount: targetIds.length,
          createdByAdminId,
        });
        return;
      }
      const freshData = freshEventSnapshot.data() as ScheduledEventSnapshot;
      const freshTargetIds = normalizeEventTargetIds(freshData.targetIds);
      if (freshTargetIds.length === 0) {
        logger.warn("Driver event missing targetIds in fresh snapshot.", {
          eventId,
        });
        return;
      }
      const reminderEvaluation = evaluateEventReminder({
        event: freshData,
        now,
        context: { eventId },
      });

      if (!reminderEvaluation.scheduledAt) {
        logger.warn("Driver event missing scheduled date.", { eventId });
        return;
      }

      if (reminderEvaluation.dueOffsetMinutes === null) {
        if (
          reminderEvaluation.diffMinutes !== null &&
          reminderEvaluation.diffMinutes > EVENT_REMINDER_WINDOW_MINUTES
        ) {
          logger.info(
            "Admin driver event created; reminder notification deferred.",
            {
              eventId,
              targetCount: freshTargetIds.length,
              createdByAdminId,
              diffMinutes: reminderEvaluation.diffMinutes,
              reminderOffsetsMinutes:
                reminderEvaluation.normalizedOffsetsMinutes,
            },
          );
        } else {
          logger.info("Driver event reminder not due on creation.", {
            eventId,
            targetCount: freshTargetIds.length,
            createdByAdminId,
            diffMinutes: reminderEvaluation.diffMinutes,
            reminderOffsetsMinutes: reminderEvaluation.normalizedOffsetsMinutes,
          });
        }
        return;
      }

      const payload = { eventId };
      logger.info("Sending driver reminder on admin event creation.", {
        eventId,
        targetCount: freshTargetIds.length,
        createdByAdminId,
        payload,
        diffMinutes: reminderEvaluation.diffMinutes,
        dueOffsetMinutes: reminderEvaluation.dueOffsetMinutes,
        reminderOffsetsMinutes: reminderEvaluation.normalizedOffsetsMinutes,
      });

      await notifyDrivers(freshTargetIds, {
        title: reminderEvaluation.title,
        body: reminderEvaluation.body,
        data: payload,
      });

      const updates: Record<string, FieldValue> = {
        [`reminderSentAtByOffsetMinutes.${reminderEvaluation.dueOffsetMinutes}`]:
          FieldValue.serverTimestamp(),
      };
      try {
        await firestore.doc(`events/${eventId}`).update(updates);
      } catch (error) {
        if (isFirestoreDocumentMissingError(error)) {
          logger.info("Driver event removed before reminder state update.", {
            eventId,
            targetCount: freshTargetIds.length,
          });
          return;
        }
        throw error;
      }
    },
  );

  const sendScheduledEventNotificationsJob = async (): Promise<void> => {
    const now = new Date();
    const windowEnd = new Date(
      now.getTime() + EVENT_REMINDER_WINDOW_MINUTES * 60 * 1000,
    );
    logger.info("Checking scheduled events for reminders.", {
      now: now.toISOString(),
      windowEnd: windowEnd.toISOString(),
    });

    const snapshot = await firestore
      .collection("events")
      .where("status", "==", "scheduled")
      .where("scheduledAt", ">=", Timestamp.fromDate(now))
      .where("scheduledAt", "<=", Timestamp.fromDate(windowEnd))
      .get();

    if (snapshot.empty) {
      logger.info("No scheduled events within reminder window.");
      return;
    }

    const driverIds = await fetchDriverIdsForAlerts();

    for (const doc of snapshot.docs) {
      const eventId = doc.id;
      const freshEventSnapshot = await firestore.doc(`events/${eventId}`).get();
      if (!freshEventSnapshot.exists) {
        logger.info("Scheduled event no longer exists during reminder job.", {
          eventId,
        });
        continue;
      }
      const data = freshEventSnapshot.data() as ScheduledEventSnapshot;
      const reminderEvaluation = evaluateEventReminder({
        event: data,
        now,
        context: { eventId },
      });

      if (!reminderEvaluation.scheduledAt) {
        logger.warn("Scheduled event missing date.", { eventId });
        continue;
      }

      if (reminderEvaluation.dueOffsetMinutes === null) {
        continue;
      }

      if (data.targetType === "broadcast") {
        await notifyDrivers(driverIds, {
          title: reminderEvaluation.title,
          body: reminderEvaluation.body,
          data: { eventId },
        });
      } else if (data.targetType === "driver") {
        const targetIds = normalizeEventTargetIds(data.targetIds);
        if (targetIds.length === 0) {
          logger.warn("Scheduled driver event missing targetIds.", {
            eventId,
          });
          continue;
        }
        await notifyDrivers(targetIds, {
          title: reminderEvaluation.title,
          body: reminderEvaluation.body,
          data: { eventId },
        });
      } else {
        logger.info("Scheduled event target not supported for reminders.", {
          eventId,
          targetType: data.targetType,
        });
        continue;
      }

      const updates: Record<string, FieldValue> = {
        [`reminderSentAtByOffsetMinutes.${reminderEvaluation.dueOffsetMinutes}`]:
          FieldValue.serverTimestamp(),
      };
      try {
        await firestore.doc(`events/${eventId}`).update(updates);
      } catch (error) {
        if (isFirestoreDocumentMissingError(error)) {
          logger.info("Scheduled event removed before reminder state update.", {
            eventId,
          });
          continue;
        }
        throw error;
      }
      logger.info("Event reminder sent.", {
        eventId,
        targetType: data.targetType,
        dueOffsetMinutes: reminderEvaluation.dueOffsetMinutes,
        diffMinutes: reminderEvaluation.diffMinutes,
        reminderOffsetsMinutes: reminderEvaluation.normalizedOffsetsMinutes,
      });
    }
  };

  const monitorDriverHeartbeatJob = async (): Promise<void> => {
    const cutoff = new Date(Date.now() - DRIVER_HEARTBEAT_STALE_MS);
    logger.info("Checking driver heartbeat status.", {
      cutoff: cutoff.toISOString(),
    });

    const snapshot = await firestore
      .collection(DRIVER_STATUS_COLLECTION)
      .where("isActive", "==", true)
      .where("availabilityEnabled", "==", true)
      .where("isAvailable", "==", true)
      .where("lastSeenAt", "<=", Timestamp.fromDate(cutoff))
      .limit(100)
      .get();
    const staleDrivers = snapshot.docs;
    if (staleDrivers.length === 0) {
      logger.info("No available drivers found for heartbeat monitoring.");
      return;
    }

    for (const doc of staleDrivers) {
      const driverId = doc.id;
      const statusData = doc.data() ?? {};
      const lastSeenValue = statusData.lastSeenAt;
      const alertedAtValue = statusData.lastHeartbeatAlertAt;

      const lastSeenAt = parseTimestampToDate(lastSeenValue);
      const lastAlertAt = parseTimestampToDate(alertedAtValue);

      if (lastAlertAt && lastAlertAt > cutoff) {
        continue;
      }

      logger.warn("Driver heartbeat is stale.", {
        driverId,
        lastSeenAt: lastSeenAt?.toISOString?.(),
      });

      await createDriverHeartbeatAlert(driverId);
      await notifyDriver(driverId, {
        title: "Problema de ligação",
        body: "Estamos a perder a tua localização. Confirma a ligação.",
        data: { driverId },
      });

      const statusPayload = {
        isAvailable: false,
        lastHeartbeatAlertAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      };
      enforceDriverStatusPayload({
        payload: statusPayload,
        context: "driverHeartbeatAlert",
      });
      await firestore
        .doc(`${DRIVER_STATUS_COLLECTION}/${driverId}`)
        .set(statusPayload, { merge: true });
      logger.warn("Driver availability disabled due to stale heartbeat.", {
        driverId,
        lastSeenAt: lastSeenAt?.toISOString?.() ?? null,
      });
    }
  };

  const pruneStaleFcmTokensJob = async (): Promise<void> => {
    const now = Timestamp.now();
    logger.info("Starting stale FCM token cleanup.", {
      now: now.toDate().toISOString(),
      batchSize: FCM_TOKEN_CLEANUP_BATCH_SIZE,
    });

    let deletedCount = 0;
    let pendingBatch = firestore.batch();
    let pendingDeletes = 0;

    const commitBatch = async (): Promise<void> => {
      if (pendingDeletes == 0) {
        return;
      }
      await pendingBatch.commit();
      deletedCount += pendingDeletes;
      logger.info("Deleted stale FCM token batch.", {
        deletedInBatch: pendingDeletes,
        deletedCount,
      });
      pendingBatch = firestore.batch();
      pendingDeletes = 0;
    };

    let lastTokenDoc: admin.firestore.QueryDocumentSnapshot | null = null;
    let hasMore = true;

    while (hasMore) {
      let expiredTokensQuery = firestore
        .collectionGroup("fcmTokens")
        .where("tokenExpiresAt", "<=", now)
        .orderBy("tokenExpiresAt")
        .orderBy(admin.firestore.FieldPath.documentId())
        .limit(FCM_TOKEN_CLEANUP_BATCH_SIZE);

      if (lastTokenDoc !== null) {
        expiredTokensQuery = expiredTokensQuery.startAfter(lastTokenDoc);
      }

      const expiredTokensSnapshot = await expiredTokensQuery.get();

      if (expiredTokensSnapshot.empty) {
        break;
      }

      for (const tokenDoc of expiredTokensSnapshot.docs) {
        pendingBatch.delete(tokenDoc.ref);
        pendingDeletes += 1;
        if (pendingDeletes >= FCM_TOKEN_CLEANUP_BATCH_SIZE) {
          await commitBatch();
        }
      }

      if (expiredTokensSnapshot.size < FCM_TOKEN_CLEANUP_BATCH_SIZE) {
        hasMore = false;
      } else {
        lastTokenDoc =
          expiredTokensSnapshot.docs[expiredTokensSnapshot.docs.length - 1];
      }
    }

    await commitBatch();
    logger.info("FCM token cleanup finished.", { deletedCount });
  };

  async function fetchAvailableDrivers(): Promise<DriverStatusSnapshot[]> {
    const staleCutoff = new Date(Date.now() - DRIVER_HEARTBEAT_STALE_MS);
    const snapshot = await firestore
      .collection(DRIVER_STATUS_COLLECTION)
      .where("isAvailable", "==", true)
      .get();

    if (snapshot.empty) {
      logger.info("No available drivers found for availability check.");
      return [];
    }

    let inactiveCount = 0;
    let availabilityDisabledCount = 0;
    let staleHeartbeatCount = 0;
    const drivers = snapshot.docs.flatMap((doc) => {
      const data = doc.data() ?? {};
      if (data.isActive === false) {
        inactiveCount += 1;
        return [];
      }
      if (data.availabilityEnabled === false) {
        availabilityDisabledCount += 1;
        return [];
      }
      const lastSeenAt = parseTimestampToDate(data.lastSeenAt);
      if (!lastSeenAt || lastSeenAt < staleCutoff) {
        staleHeartbeatCount += 1;
        return [];
      }
      const vehicleId =
        typeof data.vehicleId === "string" ? data.vehicleId : null;
      const currentTripId =
        typeof data.currentTripId === "string" ? data.currentTripId : null;
      const isBusy = data.isBusy === true || currentTripId !== null;
      return {
        driverId: doc.id,
        vehicleId,
        lastSeenAt,
        availabilityEnabled: data.availabilityEnabled === true,
        currentTripId,
        isBusy,
      };
    });
    logger.info("Available drivers fetched.", {
      availableCount: drivers.length,
      inactiveFiltered: inactiveCount,
      availabilityDisabledFiltered: availabilityDisabledCount,
      staleHeartbeatFiltered: staleHeartbeatCount,
      staleCutoff: staleCutoff.toISOString(),
    });
    return drivers;
  }

  function splitIntoChunks<T>(items: T[], size: number): T[][] {
    const chunks: T[][] = [];
    if (size <= 0) {
      return chunks;
    }
    for (let i = 0; i < items.length; i += size) {
      chunks.push(items.slice(i, i + size));
    }
    return chunks;
  }

  function normalizeEventTargetIds(rawTargetIds: unknown): string[] {
    if (!Array.isArray(rawTargetIds)) {
      return [];
    }
    const targetIds = [
      ...new Set(
        rawTargetIds
          .map((value) => (typeof value === "string" ? value.trim() : ""))
          .filter((value) => value.length > 0),
      ),
    ];
    targetIds.sort();
    return targetIds;
  }

  const GEOHASH_BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz";
  const GEOHASH_NEIGHBORS = {
    right: {
      even: "bc01fg45238967deuvhjyznpkmstqrwx",
      odd: "p0r21436x8zb9dcf5h7kjnmqesgutwvy",
    },
    left: {
      even: "238967debc01fg45kmstqrwxuvhjyznp",
      odd: "14365h7k9dcfesgujnmqp0r2twvyx8zb",
    },
    top: {
      even: "p0r21436x8zb9dcf5h7kjnmqesgutwvy",
      odd: "bc01fg45238967deuvhjyznpkmstqrwx",
    },
    bottom: {
      even: "14365h7k9dcfesgujnmqp0r2twvyx8zb",
      odd: "238967debc01fg45kmstqrwxuvhjyznp",
    },
  } as const;
  const GEOHASH_BORDERS = {
    right: { even: "bcfguvyz", odd: "prxz" },
    left: { even: "0145hjnp", odd: "028b" },
    top: { even: "prxz", odd: "bcfguvyz" },
    bottom: { even: "028b", odd: "0145hjnp" },
  } as const;

  function buildGeohashQueryBounds(
    pickup: Coordinates,
    radiusKm: number,
  ): GeoQueryBounds[] {
    const precision = precisionForRadiusKm(radiusKm);
    const hash = encodeGeohash({
      latitude: pickup.latitude,
      longitude: pickup.longitude,
      precision,
    });
    const hashes = new Set([hash, ...geohashNeighbors(hash)]);
    return Array.from(hashes).map((candidateHash) => ({
      start: candidateHash,
      end: `${candidateHash}\uf8ff`,
      hash: candidateHash,
      precision,
    }));
  }

  function geohashNeighbors(hash: string): string[] {
    const north = calculateAdjacent(hash, "top");
    const south = calculateAdjacent(hash, "bottom");
    const east = calculateAdjacent(hash, "right");
    const west = calculateAdjacent(hash, "left");
    return [
      north,
      south,
      east,
      west,
      calculateAdjacent(north, "right"),
      calculateAdjacent(north, "left"),
      calculateAdjacent(south, "right"),
      calculateAdjacent(south, "left"),
    ].filter((neighbor) => neighbor.length > 0);
  }

  function calculateAdjacent(
    hash: string,
    direction: "right" | "left" | "top" | "bottom",
  ): string {
    if (!hash) {
      return "";
    }
    const lowerHash = hash.toLowerCase();
    const type = lowerHash.length % 2 === 0 ? "even" : "odd";
    const lastChar = lowerHash[lowerHash.length - 1];
    let base = lowerHash.slice(0, -1);
    if (
      GEOHASH_BORDERS[direction][type].includes(lastChar) &&
      base.length > 0
    ) {
      base = calculateAdjacent(base, direction);
    }
    const neighborIndex = GEOHASH_NEIGHBORS[direction][type].indexOf(lastChar);
    if (neighborIndex < 0) {
      return base;
    }
    return base + GEOHASH_BASE32[neighborIndex];
  }

  function encodeGeohash(params: {
    latitude: number;
    longitude: number;
    precision: number;
  }): string {
    const { latitude, longitude, precision } = params;
    let latMin = -90.0;
    let latMax = 90.0;
    let lonMin = -180.0;
    let lonMax = 180.0;
    let isEven = true;
    let bit = 0;
    let ch = 0;
    let hash = "";
    while (hash.length < precision) {
      if (isEven) {
        const mid = (lonMin + lonMax) / 2;
        if (longitude >= mid) {
          ch |= 1 << (4 - bit);
          lonMin = mid;
        } else {
          lonMax = mid;
        }
      } else {
        const mid = (latMin + latMax) / 2;
        if (latitude >= mid) {
          ch |= 1 << (4 - bit);
          latMin = mid;
        } else {
          latMax = mid;
        }
      }
      isEven = !isEven;
      if (bit < 4) {
        bit += 1;
      } else {
        hash += GEOHASH_BASE32[ch];
        bit = 0;
        ch = 0;
      }
    }
    return hash;
  }

  function precisionForRadiusKm(radiusKm: number): number {
    const precisionToKm = new Map<number, number>([
      [1, 5000],
      [2, 1250],
      [3, 156],
      [4, 39.1],
      [5, 4.89],
      [6, 1.22],
      [7, 0.153],
      [8, 0.0382],
      [9, 0.00477],
    ]);
    const targetKm = radiusKm * 2;
    let selectedPrecision = 1;
    for (const [precision, km] of precisionToKm.entries()) {
      if (km >= targetKm) {
        selectedPrecision = precision;
      } else {
        break;
      }
    }
    return selectedPrecision;
  }

  async function resolveDriverCandidates(
    availableDrivers: DriverStatusSnapshot[],
    pickup: Coordinates,
  ): Promise<DriverCandidateResolution> {
    const availableDriverMap = new Map(
      availableDrivers.map((driver) => [driver.driverId, driver]),
    );
    const nearbyByDriverId = new Map<string, NearbyDriverCandidate>();
    const attemptedRadiiKm = [...DRIVER_CANDIDATE_SEARCH_RADII_KM];

    for (const radiusKm of DRIVER_CANDIDATE_SEARCH_RADII_KM) {
      const nearbyCandidates = await fetchNearbyDriverCandidates({
        pickup,
        radiusKm,
      });

      for (const candidate of nearbyCandidates) {
        const existing = nearbyByDriverId.get(candidate.id);
        if (!existing || candidate.distanceKm < existing.distanceKm) {
          nearbyByDriverId.set(candidate.id, candidate);
        }
      }

      const filteredCandidates = nearbyCandidates.flatMap((candidate) => {
        const driverStatus = availableDriverMap.get(candidate.id);
        if (!driverStatus) {
          return [];
        }
        return [{ ...candidate, driverStatus }];
      });

      logger.info("Driver candidate resolution at radius tier.", {
        radiusKm,
        nearbyCount: nearbyCandidates.length,
        eligibleCount: filteredCandidates.length,
      });

      if (filteredCandidates.length === 0) {
        continue;
      }

      filteredCandidates.sort((a, b) => a.distanceKm - b.distanceKm);
      if (filteredCandidates.length > MAX_DRIVER_CANDIDATES) {
        logger.info("Limiting candidates to closest drivers.", {
          radiusKm,
          total: filteredCandidates.length,
          limitedTo: MAX_DRIVER_CANDIDATES,
        });
      }
      return {
        candidates: filteredCandidates.slice(0, MAX_DRIVER_CANDIDATES),
        attemptedRadiiKm,
        matchedRadiusKm: radiusKm,
        nearbyUniqueCount: nearbyByDriverId.size,
        filteredOutByStatusCount:
          nearbyCandidates.length - filteredCandidates.length,
      };
    }

    const globalCandidates = await fetchGlobalDriverCandidates({
      pickup,
      availableDriverIds: new Set(availableDrivers.map((driver) => driver.driverId)),
    });
    const filteredGlobalCandidates = globalCandidates.flatMap((candidate) => {
      const driverStatus = availableDriverMap.get(candidate.id);
      if (!driverStatus) {
        return [];
      }
      return [{ ...candidate, driverStatus }];
    });
    if (filteredGlobalCandidates.length > 0) {
      filteredGlobalCandidates.sort((a, b) => a.distanceKm - b.distanceKm);
      logger.info("Driver candidate resolution via global fallback.", {
        eligibleCount: filteredGlobalCandidates.length,
        nearestDistanceKm: filteredGlobalCandidates[0]?.distanceKm ?? null,
      });
      return {
        candidates: filteredGlobalCandidates.slice(0, MAX_DRIVER_CANDIDATES),
        attemptedRadiiKm,
        matchedRadiusKm: null,
        nearbyUniqueCount: nearbyByDriverId.size + globalCandidates.length,
        filteredOutByStatusCount:
          globalCandidates.length - filteredGlobalCandidates.length,
      };
    }

    return {
      candidates: [],
      attemptedRadiiKm,
      matchedRadiusKm: null,
      nearbyUniqueCount: nearbyByDriverId.size,
      filteredOutByStatusCount:
        nearbyByDriverId.size -
        Array.from(nearbyByDriverId.values()).filter((candidate) =>
          availableDriverMap.has(candidate.id),
        ).length,
    };
  }

  async function selectDriverVehicleCandidate(params: {
    candidates: DriverCandidate[];
    window: ReservationWindow;
    reservedAssignments: ReservedAssignment[];
  }): Promise<DriverVehicleSelectionResult> {
    const { candidates, window, reservedAssignments } = params;
    let missingVehicleCount = 0;
    let busyCount = 0;
    let reservedCount = 0;
    let reservationConflictCount = 0;
    for (const candidate of candidates) {
      const { driverStatus } = candidate;
      const vehicleId = driverStatus.vehicleId;
      if (!vehicleId) {
        missingVehicleCount += 1;
        logger.info("Driver missing active vehicle assignment.", {
          driverId: candidate.id,
        });
        continue;
      }
      if (driverStatus.isBusy || driverStatus.currentTripId) {
        busyCount += 1;
        logger.info("Driver currently marked busy, skipping.", {
          driverId: candidate.id,
          currentTripId: driverStatus.currentTripId,
        });
        continue;
      }
      if (
        isReservedInMemory(reservedAssignments, candidate.id, vehicleId, window)
      ) {
        reservedCount += 1;
        logger.info("Driver or vehicle already reserved in activation batch.", {
          driverId: candidate.id,
          vehicleId,
        });
        continue;
      }
      const hasReservationConflict = await hasOverlappingReservations({
        driverId: candidate.id,
        vehicleId,
        window,
      });
      if (hasReservationConflict) {
        reservationConflictCount += 1;
        logger.info("Driver has overlapping reservation window.", {
          driverId: candidate.id,
        });
        continue;
      }
      return {
        assignment: { ...candidate, vehicleId },
        diagnostics: {
          totalCandidates: candidates.length,
          missingVehicleCount,
          busyCount,
          reservedCount,
          reservationConflictCount,
        },
      };
    }
    const diagnostics = {
      totalCandidates: candidates.length,
      missingVehicleCount,
      busyCount,
      reservedCount,
      reservationConflictCount,
    };
    logger.warn(
      "No driver vehicle candidate available after filtering.",
      diagnostics,
    );
    return {
      assignment: null,
      diagnostics,
    };
  }

  async function resolvePreferredReservationAssignment(params: {
    availableDrivers: DriverStatusSnapshot[];
    candidates: DriverCandidate[];
    preferredDriverId: string;
    reservationId: string;
    window: ReservationWindow;
    reservedAssignments: ReservedAssignment[];
  }): Promise<DriverVehicleCandidate | null> {
    const {
      availableDrivers,
      candidates,
      preferredDriverId,
      reservationId,
      window,
      reservedAssignments,
    } = params;
    const preferredStatus = availableDrivers.find(
      (driver) => driver.driverId === preferredDriverId,
    );
    if (!preferredStatus) {
      logger.warn("Preferred reservation driver unavailable in status pool.", {
        reservationId,
        preferredDriverId,
      });
      return null;
    }
    const vehicleId = preferredStatus.vehicleId;
    if (!vehicleId) {
      logger.warn("Preferred reservation driver missing vehicle assignment.", {
        reservationId,
        preferredDriverId,
      });
      return null;
    }
    if (preferredStatus.isBusy || preferredStatus.currentTripId) {
      logger.warn("Preferred reservation driver currently busy.", {
        reservationId,
        preferredDriverId,
        currentTripId: preferredStatus.currentTripId,
      });
      return null;
    }
    if (
      isReservedInMemory(
        reservedAssignments,
        preferredDriverId,
        vehicleId,
        window,
      )
    ) {
      logger.warn("Preferred reservation driver already reserved in batch.", {
        reservationId,
        preferredDriverId,
        vehicleId,
      });
      return null;
    }
    const hasReservationConflict = await hasOverlappingReservations({
      driverId: preferredDriverId,
      vehicleId,
      window,
      excludeReservationId: reservationId,
    });
    if (hasReservationConflict) {
      logger.warn("Preferred reservation driver has overlap conflict.", {
        reservationId,
        preferredDriverId,
        vehicleId,
      });
      return null;
    }
    const preferredCandidate =
      candidates.find((candidate) => candidate.id == preferredDriverId) ??
      ({
        id: preferredDriverId,
        location: { latitude: 0, longitude: 0 },
        distanceKm: 0,
        driverStatus: preferredStatus,
      } satisfies DriverCandidate);
    logger.info("Preferred reservation driver accepted for activation.", {
      reservationId,
      preferredDriverId,
      vehicleId,
    });
    return {
      ...preferredCandidate,
      vehicleId,
    };
  }

  function buildNoLocationFailureReason(
    resolution: DriverCandidateResolution,
  ): string {
    const maxRadiusKm = Math.max(...resolution.attemptedRadiiKm);
    if (resolution.nearbyUniqueCount === 0) {
      return `no_locations_within_${maxRadiusKm}km`;
    }
    return `no_available_drivers_near_pickup_within_${maxRadiusKm}km`;
  }

  function buildNoAssignableDriverReason(
    diagnostics: DriverVehicleSelectionDiagnostics,
  ): string {
    if (diagnostics.totalCandidates === 0) {
      return "no_eligible_driver_candidates";
    }
    if (diagnostics.missingVehicleCount === diagnostics.totalCandidates) {
      return "no_vehicle_assignment_for_nearby_drivers";
    }
    if (diagnostics.busyCount === diagnostics.totalCandidates) {
      return "nearby_drivers_busy";
    }
    if (diagnostics.reservationConflictCount === diagnostics.totalCandidates) {
      return "nearby_drivers_with_reservation_conflict";
    }
    if (diagnostics.reservedCount === diagnostics.totalCandidates) {
      return "nearby_drivers_reserved_in_batch";
    }
    return "no_assignable_driver_vehicle_candidate";
  }

  async function fetchNearbyDriverCandidates(params: {
    pickup: Coordinates;
    radiusKm: number;
  }): Promise<NearbyDriverCandidate[]> {
    const { pickup, radiusKm } = params;
    const bounds = buildGeohashQueryBounds(pickup, radiusKm);
    logger.info("Querying RTDB driver locations by geohash bounds.", {
      radiusKm,
      bounds: bounds.length,
    });
    const snapshots = await Promise.all(
      bounds.map((bound) =>
        realtimeDb
          .ref(DRIVER_LOCATION_PATH)
          .orderByChild(DRIVER_LOCATION_GEOHASH_FIELD)
          .startAt(bound.start)
          .endAt(bound.end)
          .get(),
      ),
    );

    const candidates = new Map<string, NearbyDriverCandidate>();
    for (const snapshot of snapshots) {
      snapshot.forEach((childSnapshot) => {
        const driverId = childSnapshot.key;
        if (!driverId) {
          return;
        }
        const payload = childSnapshot.val();
        const locationTimestamp = parseLocationTimestamp(payload);
        if (locationTimestamp !== null) {
          const ageMs = Date.now() - locationTimestamp;
          if (ageMs > DRIVER_LOCATION_STALE_MS) {
            logger.info("Discarding driver candidate due to stale location.", {
              driverId,
              ageMs,
              cutoffMs: DRIVER_LOCATION_STALE_MS,
              locationTimestamp,
            });
            return;
          }
        }
        const location = parseCoordinates(payload);
        if (!location) {
          logger.warn("Driver location missing coordinates in RTDB.", {
            driverId,
          });
          return;
        }
        const distanceKm = calculateDistanceKm(pickup, location);
        if (distanceKm > radiusKm) {
          return;
        }
        const existing = candidates.get(driverId);
        if (!existing || distanceKm < existing.distanceKm) {
          candidates.set(driverId, { id: driverId, location, distanceKm });
        }
      });
    }

    const results = Array.from(candidates.values());
    logger.info("Driver candidates collected from RTDB.", {
      count: results.length,
    });
    return results;
  }

  async function fetchGlobalDriverCandidates(params: {
    pickup: Coordinates;
    availableDriverIds: Set<string>;
  }): Promise<NearbyDriverCandidate[]> {
    const { pickup, availableDriverIds } = params;
    if (availableDriverIds.size === 0) {
      return [];
    }

    const snapshot = await realtimeDb.ref(DRIVER_LOCATION_PATH).get();
    if (!snapshot.exists()) {
      return [];
    }

    const candidates: NearbyDriverCandidate[] = [];
    snapshot.forEach((childSnapshot) => {
      const driverId = childSnapshot.key;
      if (!driverId || !availableDriverIds.has(driverId)) {
        return;
      }
      const payload = childSnapshot.val();
      const locationTimestamp = parseLocationTimestamp(payload);
      if (locationTimestamp !== null) {
        const ageMs = Date.now() - locationTimestamp;
        if (ageMs > DRIVER_LOCATION_STALE_MS) {
          return;
        }
      }
      const location = parseCoordinates(payload);
      if (!location) {
        return;
      }
      const distanceKm = calculateDistanceKm(pickup, location);
      candidates.push({ id: driverId, location, distanceKm });
    });

    candidates.sort((a, b) => a.distanceKm - b.distanceKm);
    logger.info("Global driver candidates collected from RTDB.", {
      count: candidates.length,
    });
    return candidates;
  }

  async function hasOverlappingReservations(params: {
    driverId: string;
    vehicleId?: string | null;
    window: ReservationWindow;
    excludeReservationId?: string;
  }): Promise<boolean> {
    const { driverId, vehicleId, window, excludeReservationId } = params;
    const scheduledDayKey = buildScheduledDayKey(
      window.start,
      RESERVATION_ACTIVATION_TIMEZONE,
    );
    const queries: Array<Promise<FirebaseFirestore.QuerySnapshot>> = [
      firestore
        .collection("reservations")
        .where("assignedDriverId", "==", driverId)
        .where("status", "in", ACTIVE_RESERVATION_STATUSES)
        .where("scheduledDayKey", "==", scheduledDayKey)
        .get(),
    ];
    if (vehicleId) {
      queries.push(
        firestore
          .collection("reservations")
          .where("vehicleId", "==", vehicleId)
          .where("status", "in", ACTIVE_RESERVATION_STATUSES)
          .where("scheduledDayKey", "==", scheduledDayKey)
          .get(),
      );
    }
    const snapshots = await Promise.all(queries);
    const seenReservationIds = new Set<string>();
    for (const snapshot of snapshots) {
      for (const doc of snapshot.docs) {
        if (doc.id === excludeReservationId || seenReservationIds.has(doc.id)) {
          continue;
        }
        seenReservationIds.add(doc.id);
        const reservationData = doc.data();
        const scheduledAt = reservationData.scheduledAt?.toDate?.();
        if (!(scheduledAt instanceof Date)) {
          logger.warn(
            "Reservation missing scheduledAt, blocking availability.",
            {
              reservationId: doc.id,
              driverId,
              vehicleId: vehicleId ?? null,
            },
          );
          return true;
        }
        const pickup = parseCoordinates(reservationData.pickup);
        const destination = parseCoordinates(reservationData.destination);
        if (!pickup || !destination) {
          logger.warn(
            "Reservation missing coordinates, blocking availability.",
            {
              reservationId: doc.id,
              driverId,
              vehicleId: vehicleId ?? null,
            },
          );
          return true;
        }
        const reservationWindow = buildReservationWindow({
          start: scheduledAt,
          pickup,
          destination,
        });
        if (windowsOverlap(window, reservationWindow)) {
          return true;
        }
      }
    }
    return false;
  }

  function buildReservationWindow(params: {
    start: Date;
    pickup: Coordinates;
    destination: Coordinates;
  }): ReservationWindow {
    const { start, pickup, destination } = params;
    const durationMinutes = estimateDurationMinutes(pickup, destination);
    const end = new Date(start.getTime() + durationMinutes * 60 * 1000);
    return { start, end };
  }

  function estimateDurationMinutes(
    pickup: Coordinates,
    destination: Coordinates,
  ): number {
    const distanceKm = calculateDistanceKm(pickup, destination);
    const durationMinutes =
      distanceKm === 0 ? 0 : Math.ceil((distanceKm / AVERAGE_SPEED_KMH) * 60);
    return Math.max(durationMinutes, MIN_RESERVATION_WINDOW_MINUTES);
  }

  function windowsOverlap(a: ReservationWindow, b: ReservationWindow): boolean {
    return a.start < b.end && b.start < a.end;
  }

  function isReservedInMemory(
    assignments: ReservedAssignment[],
    driverId: string,
    vehicleId: string,
    window: ReservationWindow,
  ): boolean {
    return assignments.some(
      (assignment) =>
        (assignment.driverId === driverId ||
          assignment.vehicleId === vehicleId) &&
        windowsOverlap(assignment.window, window),
    );
  }

  function parseLocationTimestamp(payload: unknown): number | null {
    if (!payload || typeof payload !== "object") {
      return null;
    }
    const record = payload as Record<string, unknown>;
    return typeof record.ts === "number" ? record.ts : null;
  }

  function parseCoordinates(payload: unknown): Coordinates | null {
    if (!payload || typeof payload !== "object") {
      return null;
    }
    const record = payload as Record<string, unknown>;
    const arrayLatitude = parseListCoordinate(
      record[DRIVER_LOCATION_COORDS_FIELD],
      0,
    );
    const arrayLongitude = parseListCoordinate(
      record[DRIVER_LOCATION_COORDS_FIELD],
      1,
    );
    const latitude =
      arrayLatitude ??
      (typeof record.latitude === "number"
        ? record.latitude
        : typeof record.lat === "number"
          ? record.lat
          : null);
    const longitude =
      arrayLongitude ??
      (typeof record.longitude === "number"
        ? record.longitude
        : typeof record.lng === "number"
          ? record.lng
          : null);
    if (latitude === null || longitude === null) {
      return null;
    }
    return { latitude, longitude };
  }

  function parseListCoordinate(value: unknown, index: number): number | null {
    if (Array.isArray(value) && value.length > index) {
      const entry = value[index];
      if (typeof entry === "number") {
        return entry;
      }
    }
    return null;
  }

  function parseTripLocation(payload: unknown): TripLocationPayload | null {
    if (!payload || typeof payload !== "object") {
      return null;
    }
    const record = payload as Record<string, unknown>;
    const coords = parseCoordinates(record);
    if (!coords) {
      return null;
    }
    const address = typeof record.address === "string" ? record.address : "";
    return { ...coords, address };
  }

  function parseTransportType(payload: unknown): TransportTypePayload | null {
    if (!payload || typeof payload !== "object") {
      return null;
    }
    const record = payload as Record<string, unknown>;
    const id = typeof record.id === "string" ? record.id : "";
    const name = typeof record.name === "string" ? record.name : "";
    if (!id || !name) {
      return null;
    }
    return { id, name };
  }

  function calculateDistanceKm(
    origin: Coordinates,
    target: Coordinates,
  ): number {
    const toRadians = (value: number) => (value * Math.PI) / 180;
    const earthRadiusKm = 6371;
    const dLat = toRadians(target.latitude - origin.latitude);
    const dLng = toRadians(target.longitude - origin.longitude);
    const originLat = toRadians(origin.latitude);
    const targetLat = toRadians(target.latitude);

    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.sin(dLng / 2) *
        Math.sin(dLng / 2) *
        Math.cos(originLat) *
        Math.cos(targetLat);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  function normalizeTripStatus(value: unknown): string {
    return value?.toString()?.toUpperCase() ?? "";
  }

  function normalizePaymentStatus(value: unknown): string {
    return value?.toString()?.toUpperCase() ?? "";
  }

  function toTripEventStateValue(status: string): string {
    return status.toLowerCase();
  }

  function buildTripStateTransitionEventPayload(params: {
    fromStatus: string;
    toStatus: string;
    actorId: string;
    metadata?: Record<string, unknown>;
  }): Record<string, unknown> {
    const { fromStatus, toStatus, actorId, metadata } = params;
    return {
      fromState: toTripEventStateValue(fromStatus),
      toState: toTripEventStateValue(toStatus),
      actorId,
      eventType: TRIP_EVENT_TYPE_STATE_TRANSITION,
      ...(metadata ? { metadata } : {}),
      createdAt: FieldValue.serverTimestamp(),
      ...buildTripEventTtlField(),
    };
  }

  function isTripActiveStatus(status: string): boolean {
    return status.length > 0 && !INACTIVE_TRIP_STATUSES.has(status);
  }

  async function syncFinalMeteringSnapshotToTrip(params: {
    tripId: string;
  }): Promise<void> {
    const meteringSnapshot = await firestore
      .doc(`trips/${params.tripId}/metering/current`)
      .get();
    if (!meteringSnapshot.exists) {
      return;
    }
    const metering = parseMeteringSnapshot(meteringSnapshot.data());
    if (!metering) {
      logger.warn("Final metering sync skipped due to invalid subdocument.", {
        tripId: params.tripId,
      });
      return;
    }
    const updatePayload = {
      meteringSnapshot: metering,
      updatedAt: FieldValue.serverTimestamp(),
    };
    enforceTripUpdatePayload({
      payload: updatePayload,
      context: "syncFinalMeteringSnapshotToTrip",
    });
    await firestore.doc(`trips/${params.tripId}`).set(updatePayload, {
      merge: true,
    });
    logger.info("Final metering snapshot synced to trip.", {
      tripId: params.tripId,
    });
  }

  async function syncUserRuntimeForTripStatus(params: {
    tripId: string;
    beforeStatus: string;
    afterStatus: string;
    clientId?: string;
    assignedDriverId?: string;
    previousDriverId?: string;
  }): Promise<void> {
    const batch = firestore.batch();
    const clientActive = isTripActiveStatus(params.afterStatus);
    const driverActive =
      clientActive &&
      params.afterStatus !== "REQUESTED" &&
      params.afterStatus !== "DRIVER_DECLINED" &&
      params.afterStatus !== "NO_DRIVERS_AVAILABLE";
    if (params.clientId) {
      batch.set(
        firestore.doc(`userRuntime/${params.clientId}`),
        clientActive
          ? {
              role: "client",
              activeClientTripId: params.tripId,
              activeClientTripStatus: params.afterStatus,
              activePostChargeExtensionTripId:
                params.afterStatus === "CHARGE_APPLIED"
                  ? params.tripId
                  : FieldValue.delete(),
              updatedAt: FieldValue.serverTimestamp(),
            }
          : {
              role: "client",
              activeClientTripId: FieldValue.delete(),
              activeClientTripStatus: FieldValue.delete(),
              activePostChargeExtensionTripId:
                FieldValue.delete(),
              updatedAt: FieldValue.serverTimestamp(),
            },
        { merge: true },
      );
    }
    const driverIds = new Set<string>();
    if (params.assignedDriverId) {
      driverIds.add(params.assignedDriverId);
    }
    if (
      params.previousDriverId &&
      params.previousDriverId !== params.assignedDriverId
    ) {
      driverIds.add(params.previousDriverId);
    }
    for (const driverId of driverIds) {
      const isCurrentDriver = driverId === params.assignedDriverId;
      batch.set(
        firestore.doc(`userRuntime/${driverId}`),
        driverActive && isCurrentDriver
          ? {
              role: "driver",
              activeDriverTripId: params.tripId,
              activeDriverTripStatus: params.afterStatus,
              activeDriverAssignmentTripId:
                params.afterStatus === "DRIVER_ASSIGNED_WAITING_ACCEPTANCE"
                  ? params.tripId
                  : FieldValue.delete(),
              updatedAt: FieldValue.serverTimestamp(),
            }
          : {
              role: "driver",
              activeDriverTripId: FieldValue.delete(),
              activeDriverTripStatus: FieldValue.delete(),
              activeDriverAssignmentTripId: FieldValue.delete(),
              updatedAt: FieldValue.serverTimestamp(),
            },
        { merge: true },
      );
    }
    if (params.beforeStatus !== params.afterStatus) {
      await batch.commit();
    }
  }

  type TripCreatePayloadParams = {
    clientId: string;
    pickup: TripLocationPayload;
    destination: TripLocationPayload | null;
    transportType: TransportTypePayload;
    pricingSnapshot: Record<string, unknown>;
    meteringSnapshot?: TripMeteringSnapshot | null;
    assignedDriverId?: string | null;
    vehicleId?: string | null;
    status: string;
    extra?: Record<string, unknown>;
  };

  function buildTripCreatePayload(
    params: TripCreatePayloadParams,
  ): Record<string, unknown> {
    const {
      clientId,
      pickup,
      destination,
      transportType,
      pricingSnapshot,
      meteringSnapshot,
      assignedDriverId,
      vehicleId,
      status,
      extra,
    } = params;

    return {
      clientId,
      pickup,
      destination,
      transportType,
      pricingSnapshot,
      meteringSnapshot: meteringSnapshot ?? null,
      assignedDriverId: assignedDriverId ?? null,
      vehicleId: vehicleId ?? null,
      status,
      statusEnteredAt: FieldValue.serverTimestamp(),
      isActive: isTripActiveStatus(status),
      createdAt: FieldValue.serverTimestamp(),
      requestedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      ...(extra ?? {}),
    };
  }

  function enforceTripCreatePayload(params: {
    payload: Record<string, unknown>;
    context: string;
    errorCode?: "invalid-argument" | "internal";
  }): void {
    const { payload, context, errorCode = "internal" } = params;
    const issues = validateTripCreatePayload(payload);
    if (issues.length === 0) {
      return;
    }
    logger.error("Trip payload inválido.", { context, issues, payload });
    throw new HttpsError(errorCode, "Payload de viagem inválido.");
  }

  function validateTripCreatePayload(
    payload: Record<string, unknown>,
  ): string[] {
    const issues: string[] = [];
    if (!isNonEmptyString(payload.clientId)) {
      issues.push("clientId inválido");
    }
    if (!isLocationPayload(payload.pickup)) {
      issues.push("pickup inválido");
    }
    if (!isLocationPayload(payload.destination)) {
      issues.push("destination inválido");
    }
    if (!isTransportTypePayload(payload.transportType)) {
      issues.push("transportType inválido");
    }
    if (!isPricingSnapshotPayload(payload.pricingSnapshot)) {
      issues.push("pricingSnapshot inválido");
    }
    if (!isNonEmptyString(payload.status)) {
      issues.push("status inválido");
    } else if (payload.status !== payload.status.toString().toUpperCase()) {
      issues.push("status não está em maiúsculas");
    }
    if (typeof payload.isActive !== "boolean") {
      issues.push("isActive inválido");
    }
    if (!payload.createdAt) {
      issues.push("createdAt em falta");
    }
    if (!payload.requestedAt) {
      issues.push("requestedAt em falta");
    }
    if (!payload.updatedAt) {
      issues.push("updatedAt em falta");
    }
    return issues;
  }

  function enforceTripEventPayload(params: {
    payload: Record<string, unknown>;
    context: string;
  }): void {
    const { payload, context } = params;
    const issues: string[] = [];
    if (!isNonEmptyString(payload.fromState)) {
      issues.push("fromState inválido");
    }
    if (!isNonEmptyString(payload.toState)) {
      issues.push("toState inválido");
    }
    if (!isNonEmptyString(payload.actorId)) {
      issues.push("actorId inválido");
    }
    if (!isNonEmptyString(payload.eventType)) {
      issues.push("eventType inválido");
    }
    if (!payload.createdAt) {
      issues.push("createdAt em falta");
    }
    if (!payload.tripEventExpiresAt) {
      issues.push("tripEventExpiresAt em falta");
    }
    if (issues.length === 0) {
      return;
    }
    logger.error("Trip event payload inválido.", { context, issues, payload });
    throw new HttpsError("internal", "Payload de evento de viagem inválido.");
  }

  function enforceReservationUpdatePayload(params: {
    payload: Record<string, unknown>;
    context: string;
  }): void {
    const { payload, context } = params;
    const issues: string[] = [];
    const status = payload.status;
    if (status != null) {
      if (!isNonEmptyString(status)) {
        issues.push("status inválido");
      } else if (status !== status.toString().toLowerCase()) {
        issues.push("status não está em minúsculas");
      }
    }
    if (
      payload.scheduledDayKey != null &&
      !isNonEmptyString(payload.scheduledDayKey)
    ) {
      issues.push("scheduledDayKey inválido");
    }
    if (
      payload.scheduledMinutesLocal != null &&
      typeof payload.scheduledMinutesLocal !== "number"
    ) {
      issues.push("scheduledMinutesLocal inválido");
    }
    if (!payload.updatedAt) {
      issues.push("updatedAt em falta");
    }
    if (issues.length === 0) {
      return;
    }
    logger.error("Reservation payload inválido.", { context, issues, payload });
    throw new HttpsError("internal", "Payload de reserva inválido.");
  }

  function isNonEmptyString(value: unknown): value is string {
    return typeof value === "string" && value.trim().length > 0;
  }

  function isLocationPayload(value: unknown): boolean {
    if (!value || typeof value !== "object") {
      return false;
    }
    const payload = value as Record<string, unknown>;
    return (
      typeof payload.latitude === "number" &&
      typeof payload.longitude === "number" &&
      isNonEmptyString(payload.address)
    );
  }

  function isTransportTypePayload(value: unknown): boolean {
    if (!value || typeof value !== "object") {
      return false;
    }
    const payload = value as Record<string, unknown>;
    return isNonEmptyString(payload.id) && isNonEmptyString(payload.name);
  }

  function isPricingSnapshotPayload(value: unknown): boolean {
    if (!value || typeof value !== "object") {
      return false;
    }
    const payload = value as Record<string, unknown>;
    if (
      payload.distanceTiers != null &&
      !isDistanceTierPayloadList(payload.distanceTiers)
    ) {
      return false;
    }
    return (
      isMoneyPayload(payload.base) &&
      isMoneyPayload(payload.perKm) &&
      isMoneyPayload(payload.perWaitMinute)
    );
  }

  function isDistanceTierPayloadList(value: unknown): boolean {
    if (!Array.isArray(value) || value.length === 0) {
      return false;
    }
    let expectedStartMeters = 0;
    for (let index = 0; index < value.length; index += 1) {
      const entry = value[index];
      if (!entry || typeof entry !== "object") {
        return false;
      }
      const tier = entry as Record<string, unknown>;
      const start = tier.startMetersInclusive;
      if (typeof start !== "number" || !Number.isInteger(start) || start < 0) {
        return false;
      }
      if (start !== expectedStartMeters) {
        return false;
      }
      if (!isMoneyPayload(tier.perKm)) {
        return false;
      }
      const isLast = index === value.length - 1;
      const end = tier.endMetersExclusive;
      if (isLast) {
        if (end != null) {
          return false;
        }
      } else {
        if (typeof end !== "number" || !Number.isInteger(end) || end <= start) {
          return false;
        }
        expectedStartMeters = end;
      }
    }
    return true;
  }

  function enforceTripUpdatePayload(params: {
    payload: Record<string, unknown>;
    context: string;
  }): void {
    const { payload, context } = params;
    const issues: string[] = [];
    if (payload.status != null) {
      if (!isNonEmptyString(payload.status)) {
        issues.push("status inválido");
      } else if (payload.status !== payload.status.toString().toUpperCase()) {
        issues.push("status não está em maiúsculas");
      } else if (!VALID_TRIP_STATUSES.has(payload.status.toString())) {
        issues.push(`status desconhecido: ${payload.status}`);
      }
    }
    if (payload.isActive != null && typeof payload.isActive !== "boolean") {
      issues.push("isActive inválido");
    }
    if (
      payload.assignedDriverId != null &&
      !isNonEmptyString(payload.assignedDriverId)
    ) {
      issues.push("assignedDriverId inválido");
    }
    if (payload.vehicleId != null && !isNonEmptyString(payload.vehicleId)) {
      issues.push("vehicleId inválido");
    }
    if (payload.finalCost != null && !isMoneyPayload(payload.finalCost)) {
      issues.push("finalCost inválido ou sem currency");
    }
    if (payload.finalCost != null && isMoneyPayload(payload.finalCost)) {
      if (payload.finalCost.currency !== OPERATION_CURRENCY_CODE) {
        issues.push("finalCost.currency inválida");
      }
    }
    if (payload.cancellation != null) {
      if (!payload.cancellation || typeof payload.cancellation !== "object") {
        issues.push("cancellation inválido");
      } else {
        const cancellation = payload.cancellation as Record<string, unknown>;
        if (cancellation.fee != null && !isMoneyPayload(cancellation.fee)) {
          issues.push("cancellation.fee inválido ou sem currency");
        }
        if (cancellation.fee != null && isMoneyPayload(cancellation.fee)) {
          if (cancellation.fee.currency !== OPERATION_CURRENCY_CODE) {
            issues.push("cancellation.fee.currency inválida");
          }
        }
      }
    }
    if (payload.manualSurcharge != null) {
      if (
        !payload.manualSurcharge ||
        typeof payload.manualSurcharge !== "object"
      ) {
        issues.push("manualSurcharge inválido");
      } else {
        const manualSurcharge = payload.manualSurcharge as Record<
          string,
          unknown
        >;
        if (
          manualSurcharge.amount != null &&
          !isMoneyPayload(manualSurcharge.amount)
        ) {
          issues.push("manualSurcharge.amount inválido ou sem currency");
        }
        if (
          manualSurcharge.amount != null &&
          isMoneyPayload(manualSurcharge.amount)
        ) {
          if (manualSurcharge.amount.currency !== OPERATION_CURRENCY_CODE) {
            issues.push("manualSurcharge.amount.currency inválida");
          }
        }
      }
    }
    if (!payload.updatedAt) {
      issues.push("updatedAt em falta");
    }
    if (issues.length === 0) {
      return;
    }
    logger.error("Trip update payload inválido.", { context, issues, payload });
    throw new HttpsError(
      "internal",
      "Payload de atualização de viagem inválido.",
    );
  }

  function enforceDriverStatusPayload(params: {
    payload: Record<string, unknown>;
    context: string;
  }): void {
    const { payload, context } = params;
    const issues: string[] = [];
    if (
      payload.isAvailable != null &&
      typeof payload.isAvailable !== "boolean"
    ) {
      issues.push("isAvailable inválido");
    }
    if (
      payload.availabilityEnabled != null &&
      typeof payload.availabilityEnabled !== "boolean"
    ) {
      issues.push("availabilityEnabled inválido");
    }
    if (payload.isBusy != null && typeof payload.isBusy !== "boolean") {
      issues.push("isBusy inválido");
    }
    if (
      payload.currentTripId != null &&
      !isNonEmptyString(payload.currentTripId)
    ) {
      if (!isFirestoreSentinel(payload.currentTripId)) {
        issues.push("currentTripId inválido");
      }
    }
    if (payload.vehicleId != null && !isNonEmptyString(payload.vehicleId)) {
      if (!isFirestoreSentinel(payload.vehicleId)) {
        issues.push("vehicleId inválido");
      }
    }
    if (!payload.updatedAt) {
      issues.push("updatedAt em falta");
    }
    if (issues.length === 0) {
      return;
    }
    logger.error("DriverStatus payload inválido.", {
      context,
      issues,
      payload,
    });
    throw new HttpsError(
      "internal",
      "Payload de estado do motorista inválido.",
    );
  }

  function enforceBalancePayload(params: {
    payload: Record<string, unknown>;
    context: string;
  }): void {
    const { payload, context } = params;
    const issues: string[] = [];
    if (payload.balance != null && !isMoneyPayload(payload.balance)) {
      issues.push("balance inválido ou sem currency");
    }
    if (payload.balance != null && isMoneyPayload(payload.balance)) {
      if (payload.balance.currency !== OPERATION_CURRENCY_CODE) {
        issues.push("balance.currency inválida");
      }
    }
    if (payload.debtLimit != null && !isMoneyPayload(payload.debtLimit)) {
      issues.push("debtLimit inválido ou sem currency");
    }
    if (payload.debtLimit != null && isMoneyPayload(payload.debtLimit)) {
      if (payload.debtLimit.currency !== OPERATION_CURRENCY_CODE) {
        issues.push("debtLimit.currency inválida");
      }
    }
    if (
      isMoneyPayload(payload.balance) &&
      isMoneyPayload(payload.debtLimit) &&
      payload.balance.currency !== payload.debtLimit.currency
    ) {
      issues.push("balance/debtLimit com moedas diferentes");
    }
    if (!payload.updatedAt) {
      issues.push("updatedAt em falta");
    }
    if (issues.length === 0) {
      return;
    }
    logger.error("Balance payload inválido.", { context, issues, payload });
    throw new HttpsError("internal", "Payload de saldo inválido.");
  }

  function enforceBalanceAdjustmentPayload(params: {
    payload: Record<string, unknown>;
    context: string;
  }): void {
    const { payload, context } = params;
    const issues: string[] = [];
    if (!isNonEmptyString(payload.clientId)) {
      issues.push("clientId inválido");
    }
    if (!isNonEmptyString(payload.adminId)) {
      issues.push("adminId inválido");
    }
    if (!isMoneyPayload(payload.delta)) {
      issues.push("delta inválido ou sem currency");
    }
    if (isMoneyPayload(payload.delta)) {
      if (payload.delta.currency !== OPERATION_CURRENCY_CODE) {
        issues.push("delta.currency inválida");
      }
    }
    if (!isNonEmptyString(payload.reason)) {
      issues.push("reason inválido");
    }
    if (!payload.createdAt) {
      issues.push("createdAt em falta");
    }
    if (issues.length === 0) {
      return;
    }
    logger.error("Balance adjustment payload inválido.", {
      context,
      issues,
      payload,
    });
    throw new HttpsError("internal", "Payload de ajuste de saldo inválido.");
  }

  function isFirestoreSentinel(value: unknown): boolean {
    return typeof value === "object" && value !== null;
  }

  async function finalizeTripPayment({
    tripId,
    clientId,
    reason,
  }: {
    tripId: string;
    clientId: string;
    reason: "on_completion" | "manual";
  }): Promise<void> {
    logger.info("Finalize trip payment requested.", {
      tripId,
      clientId,
      reason,
    });
    const tripRef = firestore.doc(`trips/${tripId}`);
    const balanceRef = firestore.doc(`balances/${clientId}`);
    const ledgerRef = firestore.doc(`balance_adjustments/trip_${tripId}`);
    const chargeEventRef = firestore
      .collection("tripEvents")
      .doc(tripId)
      .collection("events")
      .doc("charge_applied");

    try {
      await firestore.runTransaction(async (transaction) => {
        const tripSnapshot = await transaction.get(tripRef);
        const tripData = tripSnapshot.data();
        if (!tripData) {
          logger.warn("Trip missing during finalize transaction.", { tripId });
          return;
        }

        const currentStatus = normalizeTripStatus(tripData.status);
        if (currentStatus !== "COMPLETED") {
          logger.info("Trip no longer completed, skipping charge.", {
            tripId,
            currentStatus,
            reason,
          });
          return;
        }

        if (hasChargeApplied(tripData)) {
          logger.info("Trip already charged, skipping.", { tripId, reason });
          return;
        }
        const isPackageCovered =
          tripData.fareCoverage === TRIP_PACKAGE_FARE_COVERAGE_INCLUDED;

        const pricingSnapshot = parsePricingSnapshot(tripData.pricingSnapshot);
        const meteringSnapshot = parseMeteringSnapshot(
          tripData.meteringSnapshot,
        );
        const tripTimestamps = {
          arrivedAt: parseFirestoreDate(tripData.arrivedAt),
          startedAt: parseFirestoreDate(tripData.startedAt),
          arrivedDestinationAt: parseFirestoreDate(
            tripData.arrivedDestinationAt,
          ),
          completedAt: parseFirestoreDate(tripData.completedAt),
        };
        const discountConfig = await fetchClientDiscountConfig({
          transaction,
          clientId,
        });
        const surchargeMinor = resolveApprovedSurchargeMinor(tripData);
        if (surchargeMinor > 0) {
          logger.info("Manual surcharge approved for trip.", {
            tripId,
            surchargeMinor,
          });
        }
        const chargeBreakdown = buildChargeBreakdown(
          pricingSnapshot,
          meteringSnapshot,
          discountConfig,
          surchargeMinor,
          tripTimestamps,
        );
        logger.info("Charge breakdown computed.", {
          tripId,
          reason,
          totalMinor: chargeBreakdown.totalMinor,
          distanceKm: chargeBreakdown.totalDistanceKm,
          minutes: chargeBreakdown.totalMinutes,
          waitMinutes: chargeBreakdown.totalWaitMinutes,
          calculatedFrom: chargeBreakdown.calculatedFrom,
        });

        const balanceSnapshot = isPackageCovered
          ? null
          : await transaction.get(balanceRef);
        let updatedBalanceMinor: number | null = null;
        let debtLimitMinor: number | null = null;
        if (!isPackageCovered) {
          const eligibilitySnapshot = parseTripEligibilitySnapshot(
            balanceSnapshot?.data(),
          );
          assertMoneyCurrencyOrThrow({
            value: eligibilitySnapshot.balance,
            expectedCurrency: OPERATION_CURRENCY_CODE,
            fieldName: "balance",
          });
          assertMoneyCurrencyOrThrow({
            value: eligibilitySnapshot.debtLimit,
            expectedCurrency: OPERATION_CURRENCY_CODE,
            fieldName: "debtLimit",
          });
          const balanceMinor = eligibilitySnapshot.balance.amountMinor;
          debtLimitMinor = eligibilitySnapshot.debtLimit.amountMinor;
          const creditLimitMinor = resolveCreditLimitMinor(debtLimitMinor);
          const limitCheckDetails = buildLimitExceededDetails({
            operation: "finalize_trip_payment",
            currency: eligibilitySnapshot.balance.currency,
            balanceBeforeMinor: balanceMinor,
            debitAmountMinor: Math.max(chargeBreakdown.totalMinor, 0),
            creditLimitMinor,
          });
          if (
            !isBalanceWithinCreditLimit({
              balanceAfterMinor: limitCheckDetails.balanceAfterMinor,
              creditLimitMinor,
            })
          ) {
            logger.warn(
              "Trip payment rejected by credit limit during transaction.",
              {
                tripId,
                clientId,
                finalizeReason: reason,
                ...limitCheckDetails,
              },
            );
            throwLimitExceededError(limitCheckDetails);
          }
          updatedBalanceMinor = balanceMinor - chargeBreakdown.totalMinor;
          logger.info("Balance impact computed.", {
            tripId,
            balanceMinor,
            updatedBalanceMinor,
            debtLimitMinor,
          });
        } else {
          logger.info("Skipping balance debit for package-covered trip.", {
            tripId,
            clientId,
            fareCoverage: tripData.fareCoverage,
          });
        }
        const ledgerSnapshot = await transaction.get(ledgerRef);
        const chargeEventSnapshot = await transaction.get(chargeEventRef);
        const rawPostChargeExtension =
          tripData.postChargeExtension &&
          typeof tripData.postChargeExtension === "object"
            ? (tripData.postChargeExtension as Record<string, unknown>)
            : null;
        const hasPostChargeExtensionInitialized =
          rawPostChargeExtension?.schemaVersion ===
          POST_CHARGE_EXTENSION_SCHEMA_VERSION;

        if (
          !isPackageCovered &&
          balanceSnapshot != null &&
          updatedBalanceMinor != null &&
          debtLimitMinor != null
        ) {
          const balancePayload = {
            balance: {
              amountMinor: updatedBalanceMinor,
              currency: OPERATION_CURRENCY_CODE,
            },
            debtLimit: {
              amountMinor: debtLimitMinor,
              currency: OPERATION_CURRENCY_CODE,
            },
            updatedAt: FieldValue.serverTimestamp(),
            ...(balanceSnapshot.exists
              ? {}
              : { createdAt: FieldValue.serverTimestamp() }),
          };
          enforceBalancePayload({
            payload: balancePayload,
            context: "finalizeTripPayment",
          });
          transaction.set(balanceRef, balancePayload, { merge: true });
        }

        const sanitizedReceipt = sanitizeForFirestore(chargeBreakdown);
        const tripUpdatePayload = {
          status: "CHARGE_APPLIED",
          statusEnteredAt: FieldValue.serverTimestamp(),
          finalCost: {
            amountMinor: chargeBreakdown.totalMinor,
            currency: OPERATION_CURRENCY_CODE,
          },
          receipt: sanitizedReceipt,
          chargeAppliedAt: FieldValue.serverTimestamp(),
          paymentStatus: "PAID",
          paymentPaidAt: FieldValue.serverTimestamp(),
          paymentFailedAt: FieldValue.delete(),
          updatedAt: FieldValue.serverTimestamp(),
          ...(hasPostChargeExtensionInitialized
            ? {}
            : {
                postChargeExtension: buildInitialPostChargeExtensionPayload(),
              }),
        };
        enforceTripUpdatePayload({
          payload: tripUpdatePayload,
          context: "finalizeTripPayment",
        });
        transaction.update(tripRef, tripUpdatePayload);

        if (!isPackageCovered && !ledgerSnapshot.exists) {
          const ledgerPayload = {
            clientId,
            adminId: "system",
            delta: {
              amountMinor: -chargeBreakdown.totalMinor,
              currency: OPERATION_CURRENCY_CODE,
            },
            reason: "Cobrança da viagem",
            tripId,
            createdAt: FieldValue.serverTimestamp(),
            ...buildTripEventTtlField(),
          };
          enforceBalanceAdjustmentPayload({
            payload: ledgerPayload,
            context: "finalizeTripPayment",
          });
          transaction.set(ledgerRef, ledgerPayload);
        }

        if (!chargeEventSnapshot.exists) {
          const eventPayload = {
            fromState: "completed",
            toState: "charge_applied",
            actorId: "system",
            eventType: "state_transition",
            createdAt: FieldValue.serverTimestamp(),
            ...buildTripEventTtlField(),
          };
          enforceTripEventPayload({
            payload: eventPayload,
            context: "finalizeTripPayment",
          });
          transaction.set(chargeEventRef, eventPayload);
        }

        logger.info("Trip charged and balance updated.", {
          tripId,
          clientId,
          totalMinor: chargeBreakdown.totalMinor,
          updatedBalanceMinor,
          ledgerRecorded: !isPackageCovered && !ledgerSnapshot.exists,
          tripEventRecorded: !chargeEventSnapshot.exists,
          skippedLedgerForPackage: isPackageCovered,
          reason,
        });
      });
    } catch (error) {
      const httpError = error as Partial<HttpsError> | undefined;
      let paymentFailureReason: string | null = null;
      if (httpError?.details != null) {
        const details = httpError.details as Partial<LimitExceededDetails>;
        if (details.reason === "LIMIT_EXCEEDED") {
          paymentFailureReason = "LIMIT_EXCEEDED";
          logger.warn("Trip payment blocked by credit limit.", {
            tripId,
            reason,
            details,
          });
          if (reason === "manual") {
            throw error;
          }
        }
      }
      logger.error("Failed to finalize trip payment.", {
        tripId,
        error,
        reason,
      });
      const failurePayload = {
        paymentStatus: "FAILED",
        paymentFailureReason,
        paymentFailedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      };
      enforceTripUpdatePayload({
        payload: failurePayload,
        context: "finalizeTripPayment.failure",
      });
      await tripRef.set(failurePayload, { merge: true });
    }
  }

  function hasChargeApplied(tripData: Record<string, unknown>): boolean {
    const status = normalizeTripStatus(tripData.status);
    const paymentStatus = normalizePaymentStatus(tripData.paymentStatus);
    if (status === "CHARGE_APPLIED" || paymentStatus === "PAID") {
      return true;
    }
    return tripData.chargeAppliedAt != null || tripData.finalCost != null;
  }

  function parsePricingSnapshot(value: unknown): TripPricingSnapshot {
    if (!value || typeof value !== "object") {
      throw new HttpsError(
        "failed-precondition",
        "pricingSnapshot inválido ou ausente.",
      );
    }
    const record = value as Record<string, unknown>;
    const appliedMultiplierRaw = record.appliedMultiplier;
    const appliedMultiplier =
      typeof appliedMultiplierRaw === "number" &&
      !Number.isNaN(appliedMultiplierRaw)
        ? appliedMultiplierRaw
        : 1;
    const estimatedTotalRaw = record.estimatedTotal;
    const perKmMinor = parseRequiredMoneyAmountMinor(
      record.perKm,
      "pricingSnapshot.perKm",
    );
    const distanceTiers = parseDistanceTierMoneyPayload({
      value: record.distanceTiers,
      fieldName: "pricingSnapshot.distanceTiers",
      fallbackPerKmMinor: perKmMinor,
    });
    return {
      baseMinor: parseRequiredMoneyAmountMinor(
        record.base,
        "pricingSnapshot.base",
      ),
      perKmMinor,
      perWaitMinuteMinor: parseRequiredMoneyAmountMinor(
        record.perWaitMinute,
        "pricingSnapshot.perWaitMinute",
      ),
      lateCancellationFeeMinor:
        record.lateCancellationFee == null
          ? 0
          : parseRequiredMoneyAmountMinor(
              record.lateCancellationFee,
              "pricingSnapshot.lateCancellationFee",
            ),
      noShowFeeMinor:
        record.noShowFee == null
          ? 0
          : parseRequiredMoneyAmountMinor(
              record.noShowFee,
              "pricingSnapshot.noShowFee",
            ),
      distanceTiers,
      pricingSchemaVersion:
        record.pricingSchemaVersion == null
          ? undefined
          : parseInteger(
              record.pricingSchemaVersion,
              "pricingSnapshot.pricingSchemaVersion",
            ),
      tariffId:
        typeof record.tariffId === "string" ? record.tariffId : undefined,
      tariffUpdatedAt: parseFlexibleDate(record.tariffUpdatedAt),
      appliedMultiplierId:
        typeof record.appliedMultiplierId === "string"
          ? record.appliedMultiplierId
          : undefined,
      appliedMultiplier,
      pricingScheduleId:
        typeof record.pricingScheduleId === "string"
          ? record.pricingScheduleId
          : undefined,
      specialDayId:
        typeof record.specialDayId === "string"
          ? record.specialDayId
          : undefined,
      resolvedBaseTransportTypeId:
        typeof record.resolvedBaseTransportTypeId === "string"
          ? record.resolvedBaseTransportTypeId
          : undefined,
      resolvedBaseSource:
        typeof record.resolvedBaseSource === "string"
          ? record.resolvedBaseSource
          : undefined,
      transportMultiplier:
        typeof record.transportMultiplier === "number" &&
        !Number.isNaN(record.transportMultiplier)
          ? record.transportMultiplier
          : undefined,
      timeRangeMultiplier:
        typeof record.timeRangeMultiplier === "number" &&
        !Number.isNaN(record.timeRangeMultiplier)
          ? record.timeRangeMultiplier
          : undefined,
      holidayMultiplier:
        typeof record.holidayMultiplier === "number" &&
        !Number.isNaN(record.holidayMultiplier)
          ? record.holidayMultiplier
          : undefined,
      evaluationTimestamp: parseFlexibleDate(record.evaluationTimestamp),
      evaluationTimeZone:
        typeof record.evaluationTimeZone === "string"
          ? record.evaluationTimeZone
          : undefined,
      multipliers: parseMultiplierMap(record.multipliers),
      estimatedTotalMinor:
        estimatedTotalRaw == null
          ? undefined
          : parseRequiredMoneyAmountMinor(
              estimatedTotalRaw,
              "pricingSnapshot.estimatedTotal",
            ),
    };
  }

  function parseOptionalFirestoreDate(value: unknown): Date | undefined {
    return parseFirestoreDate(value);
  }

  function parseFlexibleDate(value: unknown): Date | undefined {
    const parsedDate = parseFirestoreDate(value);
    if (parsedDate != null) {
      return parsedDate;
    }
    if (typeof value !== "string") {
      return undefined;
    }
    const normalized = value.trim();
    if (normalized.length === 0) {
      return undefined;
    }
    const parsed = new Date(normalized);
    return Number.isNaN(parsed.getTime()) ? undefined : parsed;
  }

  function parsePostChargeExtensionFlow(
    value: unknown,
  ): PostChargeExtensionFlow | null {
    if (!value || typeof value !== "object") {
      return null;
    }
    const record = value as Record<string, unknown>;
    const schemaVersion = parseNumber(record.schemaVersion, 0);
    if (schemaVersion !== POST_CHARGE_EXTENSION_SCHEMA_VERSION) {
      return null;
    }
    const rawStatus = record.status?.toString();
    const status = (
      Object.values(POST_CHARGE_EXTENSION_STATUSES) as string[]
    ).includes(rawStatus ?? "")
      ? (rawStatus as PostChargeExtensionStatus)
      : POST_CHARGE_EXTENSION_STATUSES.closed;
    const historyRaw = Array.isArray(record.history) ? record.history : [];
    return {
      schemaVersion,
      isActive: record.isActive === true,
      status,
      maxCycles: Math.max(
        1,
        parseInteger(record.maxCycles, "postChargeExtension.maxCycles"),
      ),
      completedCyclesCount: Math.max(
        0,
        parseInteger(
          record.completedCyclesCount,
          "postChargeExtension.completedCyclesCount",
        ),
      ),
      nextActionAt: parseOptionalFirestoreDate(record.nextActionAt),
      currentCycle:
        parsePostChargeExtensionCycle(record.currentCycle) ?? undefined,
      history: historyRaw
        .map((entry) => parsePostChargeExtensionCycle(entry))
        .filter((entry): entry is PostChargeExtensionCycle => entry != null),
      closedReason: parsePostChargeExtensionClosedReason(record.closedReason),
      lastErrorCode: parsePostChargeExtensionErrorCode(record.lastErrorCode),
      createdAt: parseOptionalFirestoreDate(record.createdAt),
      updatedAt: parseOptionalFirestoreDate(record.updatedAt),
    };
  }

  function parsePostChargeExtensionCycle(
    value: unknown,
  ): PostChargeExtensionCycle | null {
    if (!value || typeof value !== "object") {
      return null;
    }
    const record = value as Record<string, unknown>;
    const chargeStatusRaw = record.chargeStatus?.toString() ?? "pending";
    const chargeStatus: PostChargeExtensionCycleChargeStatus =
      chargeStatusRaw === "succeeded" || chargeStatusRaw === "failed"
        ? chargeStatusRaw
        : "pending";
    return {
      cycleIndex: parseInteger(
        record.cycleIndex,
        "postChargeExtension.currentCycle.cycleIndex",
      ),
      requestedMinutes: parseInteger(
        record.requestedMinutes,
        "postChargeExtension.currentCycle.requestedMinutes",
      ),
      requestedAt: parseOptionalFirestoreDate(record.requestedAt),
      acceptedAt: parseOptionalFirestoreDate(record.acceptedAt),
      startedAt: parseOptionalFirestoreDate(record.startedAt),
      endsAt: parseOptionalFirestoreDate(record.endsAt),
      endedAt: parseOptionalFirestoreDate(record.endedAt),
      endedBy:
        record.endedBy === "client" || record.endedBy === "system"
          ? record.endedBy
          : undefined,
      actualSeconds:
        record.actualSeconds == null
          ? undefined
          : parseInteger(
              record.actualSeconds,
              "postChargeExtension.currentCycle.actualSeconds",
            ),
      billedMinutes:
        record.billedMinutes == null
          ? undefined
          : parseInteger(
              record.billedMinutes,
              "postChargeExtension.currentCycle.billedMinutes",
            ),
      waitRateApplied:
        record.waitRateApplied == null
          ? undefined
          : resolveMoneyPayload(
              record.waitRateApplied,
              "postChargeExtension.currentCycle.waitRateApplied",
            ),
      chargedAmount:
        record.chargedAmount == null
          ? undefined
          : resolveMoneyPayload(
              record.chargedAmount,
              "postChargeExtension.currentCycle.chargedAmount",
            ),
      chargeStatus,
      chargeFailedReason:
        typeof record.chargeFailedReason === "string"
          ? record.chargeFailedReason
          : undefined,
    };
  }

  function parsePostChargeExtensionClosedReason(
    value: unknown,
  ): PostChargeExtensionClosedReason | undefined {
    const raw = value?.toString();
    return (
      Object.values(POST_CHARGE_EXTENSION_CLOSED_REASONS) as string[]
    ).includes(raw ?? "")
      ? (raw as PostChargeExtensionClosedReason)
      : undefined;
  }

  function parsePostChargeExtensionErrorCode(
    value: unknown,
  ): PostChargeExtensionErrorCode | undefined {
    const raw = value?.toString();
    return (
      Object.values(POST_CHARGE_EXTENSION_ERROR_CODES) as string[]
    ).includes(raw ?? "")
      ? (raw as PostChargeExtensionErrorCode)
      : undefined;
  }

  function buildInitialPostChargeExtensionPayload(): Record<string, unknown> {
    return {
      schemaVersion: POST_CHARGE_EXTENSION_SCHEMA_VERSION,
      isActive: true,
      status: POST_CHARGE_EXTENSION_STATUSES.clientPrompt,
      maxCycles: POST_CHARGE_EXTENSION_MAX_CYCLES,
      completedCyclesCount: 0,
      nextActionAt: null,
      history: [],
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    };
  }

  function parseMeteringSnapshot(value: unknown): TripMeteringSnapshot | null {
    if (!value || typeof value !== "object") {
      return null;
    }
    const record = value as Record<string, unknown>;
    return {
      totalMinutes: parseNumber(record.totalMinutes),
      totalWaitMinutes: parseNumber(record.totalWaitMinutes),
      totalDistanceKm: parseNumber(record.totalDistanceKm),
      estimatedCostMinor: parseNumber(record.estimatedCostMinor),
      activeMultiplierId:
        typeof record.activeMultiplierId === "string"
          ? record.activeMultiplierId
          : undefined,
    };
  }

  function resolveApprovedSurchargeMinor(
    tripData: Record<string, unknown>,
  ): number {
    const raw = tripData.manualSurcharge;
    if (!raw || typeof raw !== "object") {
      return 0;
    }
    const record = raw as Record<string, unknown>;
    const status = record.status?.toString()?.toLowerCase();
    if (status !== "approved") {
      return 0;
    }
    return parseRequiredMoneyAmountMinor(
      record.amount,
      "manualSurcharge.amount",
    );
  }

  function parseMultiplierMap(value: unknown): Record<string, number> {
    if (!value || typeof value !== "object") {
      return {};
    }
    return Object.entries(value as Record<string, unknown>).reduce(
      (acc, [key, rawValue]) => {
        if (typeof rawValue === "number" && !Number.isNaN(rawValue)) {
          acc[key] = rawValue;
        }
        return acc;
      },
      {} as Record<string, number>,
    );
  }

  function parseNumber(value: unknown, fallback = 0): number {
    return typeof value === "number" && !Number.isNaN(value) ? value : fallback;
  }

  function parseInteger(value: unknown, fieldName: string): number {
    if (
      typeof value !== "number" ||
      Number.isNaN(value) ||
      !Number.isInteger(value)
    ) {
      throw new HttpsError("failed-precondition", `${fieldName} inválido.`);
    }
    return value;
  }

  function parseRequiredMoneyAmountMinor(
    value: unknown,
    fieldName: string,
  ): number {
    const money = resolveMoneyPayload(value, fieldName);
    assertMoneyCurrencyOrThrow({
      value: money,
      expectedCurrency: OPERATION_CURRENCY_CODE,
      fieldName,
    });
    return money.amountMinor;
  }

  function parseDistanceTierMoneyPayload(params: {
    value: unknown;
    fieldName: string;
    fallbackPerKmMinor: number;
  }): DistanceTierMinor[] {
    const { value, fieldName, fallbackPerKmMinor } = params;
    if (!Array.isArray(value) || value.length === 0) {
      return [
        {
          startMetersInclusive: 0,
          perKmMinor: fallbackPerKmMinor,
        },
      ];
    }

    const tiers: DistanceTierMinor[] = [];
    let expectedStartMeters = 0;
    for (let index = 0; index < value.length; index += 1) {
      const entry = value[index];
      if (!entry || typeof entry !== "object") {
        throw new HttpsError(
          "failed-precondition",
          `${fieldName}[${index}] inválido.`,
        );
      }
      const tier = entry as Record<string, unknown>;
      const startMetersInclusive = parseInteger(
        tier.startMetersInclusive,
        `${fieldName}[${index}].startMetersInclusive`,
      );
      if (
        startMetersInclusive < 0 ||
        startMetersInclusive !== expectedStartMeters
      ) {
        throw new HttpsError(
          "failed-precondition",
          `${fieldName}[${index}].startMetersInclusive inválido.`,
        );
      }

      const isLast = index === value.length - 1;
      const endRaw = tier.endMetersExclusive;
      let endMetersExclusive: number | undefined;
      if (isLast) {
        if (endRaw != null) {
          throw new HttpsError(
            "failed-precondition",
            `${fieldName}[${index}].endMetersExclusive deve ser omitido na última faixa.`,
          );
        }
      } else {
        endMetersExclusive = parseInteger(
          endRaw,
          `${fieldName}[${index}].endMetersExclusive`,
        );
        if (endMetersExclusive <= startMetersInclusive) {
          throw new HttpsError(
            "failed-precondition",
            `${fieldName}[${index}] limites inválidos.`,
          );
        }
        expectedStartMeters = endMetersExclusive;
      }

      const perKmMinor = parseRequiredMoneyAmountMinor(
        tier.perKm,
        `${fieldName}[${index}].perKm`,
      );
      tiers.push({
        startMetersInclusive,
        endMetersExclusive,
        perKmMinor,
      });
    }
    return tiers;
  }

  function parseTariffMultiplierRules(
    value: unknown,
  ): TariffMultiplierRulePayload[] {
    if (!Array.isArray(value)) {
      return [];
    }
    return value
      .map((entry, index) => parseTariffMultiplierRule(entry, index))
      .filter((entry): entry is TariffMultiplierRulePayload => entry != null);
  }

  function parseTariffMultiplierRule(
    value: unknown,
    index: number,
  ): TariffMultiplierRulePayload | null {
    if (!value || typeof value !== "object") {
      logger.warn("Skipping invalid tariff multiplier rule.", { index });
      return null;
    }
    const record = value as Record<string, unknown>;
    const rawType = record.type?.toString();
    if (rawType !== "time_range" && rawType !== "holiday") {
      logger.warn("Skipping unsupported tariff multiplier rule type.", {
        index,
        rawType,
      });
      return null;
    }
    const multiplier =
      typeof record.multiplier === "number" && !Number.isNaN(record.multiplier)
        ? record.multiplier
        : 1;
    const id = record.id?.toString()?.trim() || `${rawType}_${index}`;
    if (rawType === "time_range") {
      const timeRange =
        record.timeRange && typeof record.timeRange === "object"
          ? (record.timeRange as Record<string, unknown>)
          : null;
      const startMinutes =
        timeRange == null ? null : parseOptionalInteger(timeRange.startMinutes);
      const endMinutes =
        timeRange == null ? null : parseOptionalInteger(timeRange.endMinutes);
      if (startMinutes == null || endMinutes == null) {
        logger.warn("Skipping invalid time_range multiplier rule.", {
          id,
          index,
        });
        return null;
      }
      return {
        id,
        type: "time_range",
        multiplier,
        startMinutes,
        endMinutes,
        holidayDates: [],
      };
    }
    const holidayDates = Array.isArray(record.holidayDates)
      ? record.holidayDates
          .map((entry) => entry?.toString()?.trim() ?? "")
          .filter((entry) => /^\d{4}-\d{2}-\d{2}$/.test(entry))
      : [];
    if (holidayDates.length === 0) {
      logger.warn("Skipping invalid holiday multiplier rule.", { id, index });
      return null;
    }
    return {
      id,
      type: "holiday",
      multiplier,
      holidayDates,
    };
  }

  function parseOptionalInteger(value: unknown): number | null {
    return typeof value === "number" &&
      !Number.isNaN(value) &&
      Number.isInteger(value)
      ? value
      : null;
  }

  function parseFirestoreDate(value: unknown): Date | undefined {
    if (value instanceof Date) {
      return value;
    }
    if (!value || typeof value !== "object") {
      return undefined;
    }
    const maybeTimestamp = value as { toDate?: () => Date };
    const date = maybeTimestamp.toDate?.();
    return date instanceof Date ? date : undefined;
  }

  function buildMoneyPayload(amountMinor: number): MoneyPayload {
    return {
      amountMinor,
      currency: OPERATION_CURRENCY_CODE,
    };
  }

  async function fetchCurrentTariffSeed(): Promise<ReservationTariffSeed> {
    const tariffSnapshot = await firestore.doc("tariffs/public_default").get();
    const data = tariffSnapshot.data();
    if (!data) {
      logger.error("Public tariff snapshot missing.", {
        tariffId: "public_default",
      });
      throw new HttpsError(
        "failed-precondition",
        "Tarifário público inválido ou ausente.",
      );
    }
    const perKmMinor = parseRequiredMoneyAmountMinor(
      data.perKm,
      "tariff.perKm",
    );
    const distanceTiers = parseDistanceTierMoneyPayload({
      value: data.distanceTiers,
      fieldName: "tariff.distanceTiers",
      fallbackPerKmMinor: perKmMinor,
    });
    const perWaitMinuteMinor = parseRequiredMoneyAmountMinor(
      data.perWaitMinute,
      "tariff.perWaitMinute",
    );
    const penaltyFees =
      data.penaltyFees && typeof data.penaltyFees === "object"
        ? (data.penaltyFees as Record<string, unknown>)
        : {};
    const baseByTransportType = parseBaseByTransportTypePayload(
      data.baseByTransportType,
      "tariff.baseByTransportType",
    );
    return {
      baseByTransportType,
      perKmMinor,
      perWaitMinuteMinor,
      lateCancellationFeeMinor:
        penaltyFees.lateCancellation == null
          ? 0
          : parseRequiredMoneyAmountMinor(
              penaltyFees.lateCancellation,
              "tariff.penaltyFees.lateCancellation",
            ),
      noShowFeeMinor:
        penaltyFees.noShow == null
          ? 0
          : parseRequiredMoneyAmountMinor(
              penaltyFees.noShow,
              "tariff.penaltyFees.noShow",
            ),
      distanceTiers,
      tariffId: "public_default",
      tariffUpdatedAt: parseFlexibleDate(data.updatedAt),
      multiplierRules: parseTariffMultiplierRules(data.multiplierRules),
    };
  }

  function parseBaseByTransportTypePayload(
    value: unknown,
    fieldName: string,
  ): Record<string, number> {
    if (!value || typeof value !== "object") {
      throw new HttpsError(
        "failed-precondition",
        `${fieldName} inválido ou ausente.`,
      );
    }
    const entries = Object.entries(value as Record<string, unknown>);
    if (entries.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        `${fieldName} sem tipos de transporte configurados.`,
      );
    }
    return entries.reduce<Record<string, number>>(
      (acc, [transportTypeId, raw]) => {
        acc[transportTypeId] = parseRequiredMoneyAmountMinor(
          raw,
          `${fieldName}.${transportTypeId}`,
        );
        return acc;
      },
      {},
    );
  }

  function resolveBaseMinorForTransportType(params: {
    tariffSeed: ReservationTariffSeed;
    transportTypeId: string;
  }): number {
    const baseMinor =
      params.tariffSeed.baseByTransportType[params.transportTypeId];
    if (typeof baseMinor === "number" && baseMinor >= 0) {
      return baseMinor;
    }
    logger.error("Missing base fare for selected transport type.", {
      transportTypeId: params.transportTypeId,
      configuredTransportTypeIds: Object.keys(
        params.tariffSeed.baseByTransportType,
      ),
      tariffId: params.tariffSeed.tariffId ?? null,
    });
    throw new HttpsError(
      "failed-precondition",
      "Tarifário inválido para o tipo de transporte selecionado.",
    );
  }

  function estimateTripTotalMinor(params: {
    pricingSnapshot: TripPricingSnapshot;
    distanceKm: number;
    durationMinutes: number;
  }): number {
    const { pricingSnapshot, distanceKm } = params;
    const totalMeters = toMetersFromKm(distanceKm);
    const base = pricingSnapshot.baseMinor;
    const distanceMinor = calculateDistanceTierChargeMinor({
      totalMeters,
      tiers: pricingSnapshot.distanceTiers,
      fallbackPerKmMinor: pricingSnapshot.perKmMinor,
    });
    const subtotal = base + distanceMinor;
    return multiplyMinorAndCeil({
      amountMinor: subtotal,
      multiplier: pricingSnapshot.appliedMultiplier ?? 1,
    });
  }

  function buildTripPricingSnapshotForLock(params: {
    tariffSeed: ReservationTariffSeed;
    transportTypeId: string;
    evaluationAt: Date;
    estimatedTotalMinor?: number;
  }): TripPricingSnapshot {
    const { tariffSeed, transportTypeId, evaluationAt, estimatedTotalMinor } =
      params;
    const resolvedBaseMinor = resolveBaseMinorForTransportType({
      tariffSeed,
      transportTypeId,
    });
    const selection = resolveTariffMultiplierSelection({
      rules: tariffSeed.multiplierRules,
      evaluationAt,
      transportTypeId,
      timeZone: RESERVATION_ACTIVATION_TIMEZONE,
    });
    return {
      baseMinor: resolvedBaseMinor,
      perKmMinor: tariffSeed.perKmMinor,
      perWaitMinuteMinor: tariffSeed.perWaitMinuteMinor,
      lateCancellationFeeMinor: tariffSeed.lateCancellationFeeMinor,
      noShowFeeMinor: tariffSeed.noShowFeeMinor,
      distanceTiers: tariffSeed.distanceTiers,
      pricingSchemaVersion: PRICING_SCHEMA_VERSION,
      tariffId: tariffSeed.tariffId,
      tariffUpdatedAt: tariffSeed.tariffUpdatedAt,
      appliedMultiplierId: selection.appliedMultiplierId,
      appliedMultiplier: selection.appliedMultiplier,
      pricingScheduleId: selection.pricingScheduleId,
      specialDayId: selection.specialDayId,
      resolvedBaseTransportTypeId: transportTypeId,
      resolvedBaseSource: "tariff.baseByTransportType",
      timeRangeMultiplier: selection.timeRangeMultiplier,
      holidayMultiplier: selection.holidayMultiplier,
      evaluationTimestamp: evaluationAt,
      evaluationTimeZone: RESERVATION_ACTIVATION_TIMEZONE,
      multipliers: {
        [selection.appliedMultiplierId]: selection.appliedMultiplier,
      },
      estimatedTotalMinor,
    };
  }

  function resolveTariffMultiplierSelection(params: {
    rules: TariffMultiplierRulePayload[];
    evaluationAt: Date;
    transportTypeId: string;
    timeZone: string;
  }): {
    appliedMultiplierId: string;
    appliedMultiplier: number;
    pricingScheduleId?: string;
    specialDayId?: string;
    timeRangeMultiplier?: number;
    holidayMultiplier?: number;
  } {
    const { rules, evaluationAt, transportTypeId, timeZone } = params;
    const localParts = getLocalDateParts(evaluationAt, timeZone);
    const localDayKey = buildScheduledDayKey(evaluationAt, timeZone);
    const localMinutes = buildScheduledMinutesLocal(evaluationAt, timeZone);
    const holidayCandidates = rules.filter((rule) => {
      return rule.type === "holiday" && rule.holidayDates.includes(localDayKey);
    });
    const timeRangeCandidates = rules.filter((rule) => {
      return (
        rule.type === "time_range" &&
        rule.startMinutes != null &&
        rule.endMinutes != null &&
        containsMinuteInTimeRange({
          minutes: localMinutes,
          startMinutes: rule.startMinutes,
          endMinutes: rule.endMinutes,
        })
      );
    });
    const holidayRule = holidayCandidates[0];
    if (holidayCandidates.length > 1) {
      logger.error("Multiple holiday multipliers matched for one day.", {
        localDayKey,
        matchedRuleIds: holidayCandidates.map((rule) => rule.id),
      });
    }
    let timeRangeRule = timeRangeCandidates[0];
    if (timeRangeCandidates.length > 1) {
      const sorted = [...timeRangeCandidates].sort((left, right) => {
        return right.multiplier - left.multiplier;
      });
      timeRangeRule = sorted[0];
      logger.error("Multiple time_range multipliers matched for one instant.", {
        localDayKey,
        localMinutes,
        matchedRuleIds: sorted.map((rule) => rule.id),
        selectedRuleId: timeRangeRule.id,
      });
    }
    const appliedMultiplier =
      (timeRangeRule?.multiplier ?? 1) * (holidayRule?.multiplier ?? 1);
    const appliedMultiplierId =
      `transport:${transportTypeId}|` +
      `time:${timeRangeRule?.id ?? "none"}|` +
      `holiday:${holidayRule?.id ?? "none"}`;
    logger.info("Resolved tariff multiplier selection.", {
      transportTypeId,
      timeRangeRuleId: timeRangeRule?.id ?? null,
      holidayRuleId: holidayRule?.id ?? null,
      appliedMultiplierId,
      appliedMultiplier,
      evaluationAt: evaluationAt.toISOString(),
      evaluationTimeZone: timeZone,
      evaluationLocalDay: localDayKey,
      evaluationLocalMinutes: localMinutes,
      evaluationLocalHour: localParts.hour,
    });
    return {
      appliedMultiplierId,
      appliedMultiplier,
      pricingScheduleId: timeRangeRule?.id,
      specialDayId: holidayRule?.id,
      timeRangeMultiplier: timeRangeRule?.multiplier,
      holidayMultiplier: holidayRule?.multiplier,
    };
  }

  function containsMinuteInTimeRange(params: {
    minutes: number;
    startMinutes: number;
    endMinutes: number;
  }): boolean {
    const { minutes, startMinutes, endMinutes } = params;
    if (startMinutes <= endMinutes) {
      return minutes >= startMinutes && minutes < endMinutes;
    }
    return minutes >= startMinutes || minutes < endMinutes;
  }

  function serializeDistanceTiers(
    tiers: DistanceTierMinor[],
  ): Record<string, unknown>[] {
    return tiers.map((tier) => {
      return {
        startMetersInclusive: tier.startMetersInclusive,
        ...(tier.endMetersExclusive == null
          ? {}
          : { endMetersExclusive: tier.endMetersExclusive }),
        perKm: buildMoneyPayload(tier.perKmMinor),
      };
    });
  }

  function serializePricingSnapshotForTrip(
    snapshot: TripPricingSnapshot,
  ): Record<string, unknown> {
    return {
      base: buildMoneyPayload(snapshot.baseMinor),
      perKm: buildMoneyPayload(snapshot.perKmMinor),
      perWaitMinute: buildMoneyPayload(snapshot.perWaitMinuteMinor),
      distanceTiers: serializeDistanceTiers(snapshot.distanceTiers),
      lateCancellationFee: buildMoneyPayload(snapshot.lateCancellationFeeMinor),
      noShowFee: buildMoneyPayload(snapshot.noShowFeeMinor),
      ...(snapshot.pricingSchemaVersion == null
        ? {}
        : { pricingSchemaVersion: snapshot.pricingSchemaVersion }),
      ...(snapshot.appliedMultiplierId == null
        ? {}
        : { appliedMultiplierId: snapshot.appliedMultiplierId }),
      appliedMultiplier: snapshot.appliedMultiplier ?? 1,
      ...(snapshot.pricingScheduleId == null
        ? {}
        : { pricingScheduleId: snapshot.pricingScheduleId }),
      ...(snapshot.specialDayId == null
        ? {}
        : { specialDayId: snapshot.specialDayId }),
      ...(snapshot.resolvedBaseTransportTypeId == null
        ? {}
        : {
            resolvedBaseTransportTypeId: snapshot.resolvedBaseTransportTypeId,
          }),
      ...(snapshot.resolvedBaseSource == null
        ? {}
        : { resolvedBaseSource: snapshot.resolvedBaseSource }),
      ...(snapshot.timeRangeMultiplier == null
        ? {}
        : { timeRangeMultiplier: snapshot.timeRangeMultiplier }),
      ...(snapshot.holidayMultiplier == null
        ? {}
        : { holidayMultiplier: snapshot.holidayMultiplier }),
      ...(snapshot.evaluationTimestamp == null
        ? {}
        : { evaluationTimestamp: snapshot.evaluationTimestamp }),
      ...(snapshot.evaluationTimeZone == null
        ? {}
        : { evaluationTimeZone: snapshot.evaluationTimeZone }),
      ...(snapshot.tariffId == null ? {} : { tariffId: snapshot.tariffId }),
      ...(snapshot.tariffUpdatedAt == null
        ? {}
        : { tariffUpdatedAt: snapshot.tariffUpdatedAt }),
      multipliers: snapshot.multipliers,
      ...(snapshot.estimatedTotalMinor == null
        ? {}
        : { estimatedTotal: buildMoneyPayload(snapshot.estimatedTotalMinor) }),
    };
  }

  async function createTripFromReservation(params: {
    reservationId: string;
    clientId: string;
    pickup: TripLocationPayload;
    destination: TripLocationPayload;
    transportType: TransportTypePayload;
    tariffSeed: ReservationTariffSeed;
    scheduledAt: Date;
    assignedDriverId: string;
    vehicleId: string;
    tripId?: string;
    extraTripFields?: Record<string, unknown>;
  }): Promise<string | null> {
    const {
      reservationId,
      clientId,
      pickup,
      destination,
      transportType,
      tariffSeed,
      scheduledAt,
      assignedDriverId,
      vehicleId,
      tripId: providedTripId,
      extraTripFields,
    } = params;

    const tripId = providedTripId ?? firestore.collection("trips").doc().id;
    const reservationRef = firestore.doc(`reservations/${reservationId}`);
    const tripRef = firestore.doc(`trips/${tripId}`);
    const driverContactRef = firestore.doc(
      `trips/${tripId}/driverContactSnapshots/${tripId}`,
    );
    const eventRef = firestore
      .collection("tripEvents")
      .doc(tripId)
      .collection("events")
      .doc();

    const distanceKm = calculateDistanceKm(pickup, destination);
    const durationMinutes =
      distanceKm === 0 ? 0 : Math.ceil((distanceKm / AVERAGE_SPEED_KMH) * 60);
    const pricingSnapshotSeed = buildTripPricingSnapshotForLock({
      tariffSeed,
      transportTypeId: transportType.id,
      evaluationAt: scheduledAt,
    });
    const estimatedTotalMinor = estimateTripTotalMinor({
      pricingSnapshot: pricingSnapshotSeed,
      distanceKm,
      durationMinutes,
    });
    const pricingSnapshot: TripPricingSnapshot = {
      ...pricingSnapshotSeed,
      estimatedTotalMinor,
    };
    const pricingSnapshotPayload =
      serializePricingSnapshotForTrip(pricingSnapshot);
    const [
      clientSupport,
      driverSummary,
      vehicleSummary,
      driverContactSnapshot,
    ] = await Promise.all([
      fetchClientSupportSnapshot(clientId),
      fetchDriverSummary(assignedDriverId),
      fetchVehicleSummary(vehicleId),
      fetchDriverContactSnapshot(assignedDriverId),
    ]);

    const assignedAt = new Date();
    const tripPayload = buildTripCreatePayload({
      clientId,
      pickup,
      destination,
      transportType,
      pricingSnapshot: pricingSnapshotPayload,
      meteringSnapshot: {
        totalMinutes: 0,
        totalWaitMinutes: 0,
        totalDistanceKm: 0,
        estimatedCostMinor: 0,
      },
      assignedDriverId,
      vehicleId,
      status: "DRIVER_ASSIGNED_WAITING_ACCEPTANCE",
      extra: {
        clientSupport,
        reservationId,
        ...(driverSummary ? { driverSummary } : {}),
        ...(vehicleSummary ? { vehicleSummary } : {}),
        driverAssignedAt: Timestamp.fromDate(assignedAt),
        assignmentAttempts: 1,
        ...(extraTripFields ?? {}),
      },
    });
    enforceTripCreatePayload({
      payload: tripPayload,
      context: "createTripFromReservation",
    });

    const tripEventPayload = {
      fromState: "requested",
      toState: "driver_assigned_waiting_acceptance",
      actorId: assignedDriverId,
      eventType: "state_transition",
      createdAt: FieldValue.serverTimestamp(),
      ...buildTripEventTtlField(),
    };
    enforceTripEventPayload({
      payload: tripEventPayload,
      context: "createTripFromReservation",
    });

    let createdTripId: string | null = null;
    await firestore.runTransaction(async (transaction) => {
      const [reservationSnapshot, existingTripSnapshot] = await Promise.all([
        transaction.get(reservationRef),
        transaction.get(tripRef),
      ]);
      const reservationData = reservationSnapshot.data();
      const currentStatus = reservationData?.status?.toString();
      const currentTripId =
        typeof reservationData?.tripId === "string" &&
        reservationData.tripId.trim().length > 0
          ? reservationData.tripId
          : null;
      if (currentStatus !== "scheduled") {
        if (
          (currentStatus === "pending" || currentStatus === "confirmed") &&
          currentTripId
        ) {
          createdTripId = currentTripId;
          logger.info(
            "Reservation already activated, returning existing trip.",
            {
              reservationId,
              currentTripId,
            },
          );
          return;
        }
        logger.info("Reservation no longer scheduled.", {
          reservationId,
          currentStatus,
        });
        return;
      }

      const scheduledAt = reservationData?.scheduledAt?.toDate?.();
      const scheduleUpdates: Record<string, unknown> = {};
      if (scheduledAt instanceof Date) {
        scheduleUpdates.scheduledDayKey = buildScheduledDayKey(
          scheduledAt,
          RESERVATION_ACTIVATION_TIMEZONE,
        );
        scheduleUpdates.scheduledMinutesLocal = buildScheduledMinutesLocal(
          scheduledAt,
          RESERVATION_ACTIVATION_TIMEZONE,
        );
      } else {
        logger.warn("Reservation missing scheduledAt for schedule metadata.", {
          reservationId,
        });
      }

      if (!existingTripSnapshot.exists) {
        transaction.set(tripRef, tripPayload);
      }
      if (driverContactSnapshot) {
        transaction.set(driverContactRef, driverContactSnapshot, {
          merge: true,
        });
      }

      if (!existingTripSnapshot.exists) {
        transaction.set(eventRef, tripEventPayload);
      }

      const reservationPayload = {
        status: "pending",
        tripId,
        assignedDriverId,
        vehicleId,
        ...scheduleUpdates,
        activatedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      };
      enforceReservationUpdatePayload({
        payload: reservationPayload,
        context: "createTripFromReservation",
      });
      transaction.update(reservationRef, reservationPayload);

      createdTripId = tripId;
    });

    if (createdTripId) {
      await updateDriverTripState({
        tripId: createdTripId,
        driverId: assignedDriverId,
        vehicleId,
        isBusy: true,
      });
    }

    return createdTripId;
  }

  async function createPackageCoveredTripFromReservation(params: {
    reservationId: string;
    clientId: string;
    pickup: TripLocationPayload;
    destination: TripLocationPayload;
    transportType: TransportTypePayload;
    scheduledAt: Date;
    assignedDriverId: string;
    vehicleId: string;
    bookingId: string;
    packageId: string;
    packageSnapshotVersion: number;
  }): Promise<string | null> {
    const tariffSeed = await fetchCurrentTariffSeed();
    return createTripFromReservation({
      reservationId: params.reservationId,
      clientId: params.clientId,
      pickup: params.pickup,
      destination: params.destination,
      transportType: params.transportType,
      tariffSeed,
      scheduledAt: params.scheduledAt,
      assignedDriverId: params.assignedDriverId,
      vehicleId: params.vehicleId,
      tripId: `pkg_${params.bookingId}`,
      extraTripFields: {
        packageBookingId: params.bookingId,
        packageId: params.packageId,
        fareCoverage: TRIP_PACKAGE_FARE_COVERAGE_INCLUDED,
        packageSnapshotVersion: params.packageSnapshotVersion,
      },
    });
  }

  type ConfirmTripPackageBookingPayload = {
    packageId: string;
    pickup: TripLocationPayload;
    outboundPickupAt: Date;
    mode: TripPackageBookingMode;
    returnPickupAt: Date | null;
  };

  type ParsedTripPackageBookingLeg = {
    legType: TripPackageLegType;
    status: TripPackageLegStatus;
    pickupAt: Date;
    pickup: TripLocationPayload;
    dropoff: TripLocationPayload;
    assignedDriverId: string;
    vehicleId: string;
    activationAt: Date;
    tripId: string | null;
  };

  function parseConfirmTripPackageBookingPayload(
    data: unknown,
  ): ConfirmTripPackageBookingPayload {
    if (!data || typeof data !== "object") {
      throw new HttpsError("invalid-argument", "Pedido de pacote inválido.");
    }
    const payload = data as Record<string, unknown>;
    const packageId = payload.packageId?.toString()?.trim() ?? "";
    if (!packageId) {
      throw new HttpsError("invalid-argument", "Pacote inválido.");
    }
    const pickup = resolveTripPackageLocationOrThrow(payload.pickup, "pickup");
    const mode = parseTripPackageBookingMode(payload.mode);
    if (!mode) {
      throw new HttpsError("invalid-argument", "Modo do pacote inválido.");
    }
    const outboundPickupAt = parseDateInput(
      payload.outboundPickupAt,
      "outboundPickupAt",
    );
    const returnPickupAt =
      payload.returnPickupAt == null
        ? null
        : parseDateInput(payload.returnPickupAt, "returnPickupAt");
    return {
      packageId,
      pickup,
      outboundPickupAt,
      mode,
      returnPickupAt,
    };
  }

  function parseTripPackageBookingId(data: unknown): string {
    if (!data || typeof data !== "object") {
      throw new HttpsError("invalid-argument", "Pedido inválido.");
    }
    const bookingId =
      (data as Record<string, unknown>).bookingId?.toString()?.trim() ?? "";
    if (!bookingId) {
      throw new HttpsError("invalid-argument", "Booking inválido.");
    }
    return bookingId;
  }

  function parseTripPackageLegType(value: unknown): TripPackageLegType | null {
    if (value === TRIP_PACKAGE_LEG_TYPES.outbound) {
      return TRIP_PACKAGE_LEG_TYPES.outbound;
    }
    if (value === TRIP_PACKAGE_LEG_TYPES.return) {
      return TRIP_PACKAGE_LEG_TYPES.return;
    }
    return null;
  }

  function parseTripPackageBookingStatus(
    value: unknown,
  ): TripPackageBookingStatus {
    const status = value?.toString();
    if (
      status &&
      Object.values(TRIP_PACKAGE_BOOKING_STATUSES).includes(
        status as TripPackageBookingStatus,
      )
    ) {
      return status as TripPackageBookingStatus;
    }
    throw new HttpsError(
      "failed-precondition",
      "Estado do booking do pacote inválido.",
    );
  }

  function parseTripPackageRefundStatus(
    value: unknown,
  ): TripPackageRefundStatus {
    const status = value?.toString();
    if (
      status &&
      Object.values(TRIP_PACKAGE_REFUND_STATUSES).includes(
        status as TripPackageRefundStatus,
      )
    ) {
      return status as TripPackageRefundStatus;
    }
    throw new HttpsError(
      "failed-precondition",
      "Estado de reembolso do pacote inválido.",
    );
  }

  function parseTripPackageLegStatus(value: unknown): TripPackageLegStatus {
    const status = value?.toString();
    if (
      status &&
      Object.values(TRIP_PACKAGE_LEG_STATUSES).includes(
        status as TripPackageLegStatus,
      )
    ) {
      return status as TripPackageLegStatus;
    }
    throw new HttpsError(
      "failed-precondition",
      "Estado da perna do pacote inválido.",
    );
  }

  function parseTripPackageSnapshot(value: unknown): TripPackageSnapshot {
    if (!value || typeof value !== "object") {
      throw new HttpsError(
        "failed-precondition",
        "Snapshot do pacote inválido.",
      );
    }
    const record = value as Record<string, unknown>;
    const refundPolicy =
      record.refundPolicy && typeof record.refundPolicy === "object"
        ? (record.refundPolicy as Record<string, unknown>)
        : null;
    return {
      packageId: record.packageId?.toString() ?? "",
      packageSnapshotVersion:
        parseOptionalInteger(record.packageSnapshotVersion) ?? 1,
      name: record.name?.toString() ?? "",
      description: record.description?.toString() ?? "",
      photoUrl: record.photoUrl?.toString() ?? "",
      destination: resolveTripPackageLocationOrThrow(
        record.destination,
        "packageSnapshot.destination",
      ),
      transportType: resolveTripPackageTransportTypeOrThrow(
        record.transportType,
        "packageSnapshot.transportType",
      ),
      oneWayPrice: resolveMoneyPayload(
        record.oneWayPrice,
        "packageSnapshot.oneWayPrice",
      ),
      roundTripPrice: resolveMoneyPayload(
        record.roundTripPrice,
        "packageSnapshot.roundTripPrice",
      ),
      minimumLeadTimeMinutes:
        parseOptionalInteger(record.minimumLeadTimeMinutes) ??
        TRIP_PACKAGE_ACTIVATION_LEAD_TIME_MINUTES,
      minimumReturnGapMinutes:
        parseOptionalInteger(record.minimumReturnGapMinutes) ??
        TRIP_PACKAGE_MIN_RETURN_GAP_MINUTES,
      activationLeadTimeMinutes:
        parseOptionalInteger(record.activationLeadTimeMinutes) ??
        TRIP_PACKAGE_ACTIVATION_LEAD_TIME_MINUTES,
      refundPolicy: {
        fullCancellationBeforeOutboundActivation:
          refundPolicy?.fullCancellationBeforeOutboundActivation === true,
        returnLegCancellationBeforeActivation:
          refundPolicy?.returnLegCancellationBeforeActivation === true,
      },
      checkoutCopy: record.checkoutCopy?.toString() ?? "",
    };
  }

  function parseTripPackageBookingDocument(
    data: FirebaseFirestore.DocumentData | undefined,
  ): TripPackageBookingDocument {
    if (!data) {
      throw new HttpsError(
        "failed-precondition",
        "Booking do pacote indisponível.",
      );
    }
    const clientId = data.clientId?.toString()?.trim() ?? "";
    const packageId = data.packageId?.toString()?.trim() ?? "";
    const mode = parseTripPackageBookingMode(data.mode);
    if (!clientId || !packageId || !mode) {
      throw new HttpsError(
        "failed-precondition",
        "Booking do pacote com dados inválidos.",
      );
    }
    return {
      clientId,
      packageId,
      packageSnapshot: parseTripPackageSnapshot(data.packageSnapshot),
      mode,
      status: parseTripPackageBookingStatus(data.status),
      refundStatus: parseTripPackageRefundStatus(data.refundStatus),
      chargedAmount: resolveMoneyPayload(data.chargedAmount, "chargedAmount"),
      refundedAmount: resolveMoneyPayload(
        data.refundedAmount,
        "refundedAmount",
      ),
    };
  }

  function parseTripPackageLegDocument(params: {
    data: FirebaseFirestore.DocumentData | undefined;
    expectedLegType: TripPackageLegType;
  }): ParsedTripPackageBookingLeg {
    const { data, expectedLegType } = params;
    if (!data) {
      throw new HttpsError(
        "failed-precondition",
        "Perna do pacote indisponível.",
      );
    }
    const legType = parseTripPackageLegType(data.legType);
    if (legType !== expectedLegType) {
      throw new HttpsError("failed-precondition", "Perna do pacote inválida.");
    }
    const pickupAt = parseTimestampToDate(data.pickupAt);
    const activationAt = parseTimestampToDate(data.activationAt);
    if (!pickupAt || !activationAt) {
      throw new HttpsError(
        "failed-precondition",
        "Perna do pacote sem agendamento válido.",
      );
    }
    return {
      legType,
      status: parseTripPackageLegStatus(data.status),
      pickupAt,
      pickup: resolveTripPackageLocationOrThrow(data.pickup, "leg.pickup"),
      dropoff: resolveTripPackageLocationOrThrow(data.dropoff, "leg.dropoff"),
      assignedDriverId: data.assignedDriverId?.toString() ?? "",
      vehicleId: data.vehicleId?.toString() ?? "",
      activationAt,
      tripId: data.tripId?.toString() ?? null,
    };
  }

  function serializeTripPackageSnapshot(
    snapshot: TripPackageSnapshot,
  ): Record<string, unknown> {
    return {
      packageId: snapshot.packageId,
      packageSnapshotVersion: snapshot.packageSnapshotVersion,
      name: snapshot.name,
      description: snapshot.description,
      photoUrl: snapshot.photoUrl,
      destination: snapshot.destination,
      transportType: snapshot.transportType,
      oneWayPrice: snapshot.oneWayPrice,
      roundTripPrice: snapshot.roundTripPrice,
      minimumLeadTimeMinutes: snapshot.minimumLeadTimeMinutes,
      minimumReturnGapMinutes: snapshot.minimumReturnGapMinutes,
      activationLeadTimeMinutes: snapshot.activationLeadTimeMinutes,
      refundPolicy: snapshot.refundPolicy,
      checkoutCopy: snapshot.checkoutCopy,
    };
  }

  function buildTripPackageConfirmOperationId(params: {
    clientId: string;
    payload: ConfirmTripPackageBookingPayload;
  }): string {
    const { clientId, payload } = params;
    const digest = createHash("sha256")
      .update(
        JSON.stringify({
          clientId,
          packageId: payload.packageId,
          pickup: payload.pickup,
          outboundPickupAt: payload.outboundPickupAt.toISOString(),
          mode: payload.mode,
          returnPickupAt: payload.returnPickupAt?.toISOString() ?? null,
        }),
      )
      .digest("hex")
      .slice(0, 24);
    return `confirm_trip_package_${clientId}_${digest}`;
  }

  async function selectTripPackageAssignments(params: {
    bookingId: string;
    plans: TripPackageBookingLegPlan[];
  }): Promise<TripPackageBookingLegAssignment[]> {
    const { bookingId, plans } = params;
    const availableDrivers = await fetchAvailableDrivers();
    if (availableDrivers.length === 0) {
      throw new HttpsError(
        "failed-precondition",
        "Não há motoristas disponíveis para este pacote.",
      );
    }
    const reservedAssignments: ReservedAssignment[] = [];
    const assignments: TripPackageBookingLegAssignment[] = [];
    for (const plan of plans) {
      const candidateResolution = await resolveDriverCandidates(
        availableDrivers,
        plan.pickup,
      );
      if (candidateResolution.candidates.length === 0) {
        throw new HttpsError(
          "failed-precondition",
          "Sem motoristas elegíveis perto da recolha.",
          {
            reason: buildNoLocationFailureReason(candidateResolution),
            legType: plan.legType,
          },
        );
      }
      const window = buildReservationWindow({
        start: plan.pickupAt,
        pickup: plan.pickup,
        destination: plan.dropoff,
      });
      const selection = await selectDriverVehicleCandidate({
        candidates: candidateResolution.candidates,
        window,
        reservedAssignments,
      });
      if (!selection.assignment) {
        throw new HttpsError(
          "failed-precondition",
          "Sem viatura disponível para o horário pretendido.",
          {
            reason: buildNoAssignableDriverReason(selection.diagnostics),
            legType: plan.legType,
          },
        );
      }
      const assignment: TripPackageBookingLegAssignment = {
        ...plan,
        assignedDriverId: selection.assignment.id,
        vehicleId: selection.assignment.vehicleId,
        reservationId: buildTripPackageReservationId({
          bookingId,
          legType: plan.legType,
        }),
        taskId: buildTripPackageTaskId({
          bookingId,
          legType: plan.legType,
        }),
      };
      reservedAssignments.push({
        driverId: assignment.assignedDriverId,
        vehicleId: assignment.vehicleId,
        window,
      });
      assignments.push(assignment);
    }
    return assignments;
  }

  async function assertTripPackageAssignmentAvailableInTransaction(params: {
    transaction: FirebaseFirestore.Transaction;
    assignment: TripPackageBookingLegAssignment;
  }): Promise<void> {
    const { transaction, assignment } = params;
    const driverStatusSnapshot = await transaction.get(
      firestore.doc(
        `${DRIVER_STATUS_COLLECTION}/${assignment.assignedDriverId}`,
      ),
    );
    const driverStatusData = driverStatusSnapshot.data() ?? {};
    if (driverStatusData.isActive === false) {
      throw new HttpsError(
        "failed-precondition",
        "O motorista reservado deixou de estar ativo.",
      );
    }
    if (driverStatusData.availabilityEnabled === false) {
      throw new HttpsError(
        "failed-precondition",
        "O motorista reservado já não aceita serviço.",
      );
    }
    if (driverStatusData.isBusy === true || driverStatusData.currentTripId) {
      throw new HttpsError(
        "failed-precondition",
        "O motorista reservado deixou de estar disponível.",
      );
    }
    const currentVehicleId =
      typeof driverStatusData.vehicleId === "string"
        ? driverStatusData.vehicleId
        : null;
    if (currentVehicleId !== assignment.vehicleId) {
      throw new HttpsError(
        "failed-precondition",
        "A viatura reservada deixou de estar associada ao motorista.",
      );
    }
    const scheduledDayKey = buildScheduledDayKey(
      assignment.pickupAt,
      RESERVATION_ACTIVATION_TIMEZONE,
    );
    const queries: Array<Promise<FirebaseFirestore.QuerySnapshot>> = [
      transaction.get(
        firestore
          .collection("reservations")
          .where("assignedDriverId", "==", assignment.assignedDriverId)
          .where("status", "in", ACTIVE_RESERVATION_STATUSES)
          .where("scheduledDayKey", "==", scheduledDayKey),
      ),
      transaction.get(
        firestore
          .collection("reservations")
          .where("vehicleId", "==", assignment.vehicleId)
          .where("status", "in", ACTIVE_RESERVATION_STATUSES)
          .where("scheduledDayKey", "==", scheduledDayKey),
      ),
    ];
    const snapshots = await Promise.all(queries);
    const reservationWindow = buildReservationWindow({
      start: assignment.pickupAt,
      pickup: assignment.pickup,
      destination: assignment.dropoff,
    });
    const seenIds = new Set<string>();
    for (const snapshot of snapshots) {
      for (const doc of snapshot.docs) {
        if (doc.id === assignment.reservationId || seenIds.has(doc.id)) {
          continue;
        }
        seenIds.add(doc.id);
        const data = doc.data();
        const scheduledAt = parseTimestampToDate(data.scheduledAt);
        const pickup = parseCoordinates(data.pickup);
        const destination = parseCoordinates(data.destination);
        if (!scheduledAt || !pickup || !destination) {
          throw new HttpsError(
            "failed-precondition",
            "Foi detetado um conflito de reserva inválido.",
          );
        }
        const conflictWindow = buildReservationWindow({
          start: scheduledAt,
          pickup,
          destination,
        });
        if (windowsOverlap(reservationWindow, conflictWindow)) {
          throw new HttpsError(
            "failed-precondition",
            "A disponibilidade do pacote acabou de mudar. Tente novamente.",
          );
        }
      }
    }
  }

  function buildTripPackageBookingCreatePayload(params: {
    clientId: string;
    packageDocument: TripPackageDocument;
    pickup: TripLocationPayload;
    outboundPickupAt: Date;
    returnPickupAt: Date | null;
    mode: TripPackageBookingMode;
    chargedAmount: MoneyPayload;
  }): Record<string, unknown> {
    const {
      clientId,
      packageDocument,
      pickup,
      outboundPickupAt,
      returnPickupAt,
      mode,
      chargedAmount,
    } = params;
    return {
      clientId,
      packageId: packageDocument.id,
      packageSnapshot: serializeTripPackageSnapshot(
        buildTripPackageSnapshot(packageDocument),
      ),
      pickup,
      outboundPickupAt,
      returnPickupAt,
      mode,
      status: TRIP_PACKAGE_BOOKING_STATUSES.confirmed,
      refundStatus: TRIP_PACKAGE_REFUND_STATUSES.none,
      chargedAmount,
      refundedAmount: buildMoneyPayload(0),
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    };
  }

  function buildTripPackageLegCreatePayload(params: {
    bookingId: string;
    packageId: string;
    clientId: string;
    assignment: TripPackageBookingLegAssignment;
    transportType: TransportTypePayload;
  }): Record<string, unknown> {
    const { bookingId, packageId, clientId, assignment, transportType } =
      params;
    return {
      bookingId,
      packageId,
      clientId,
      legType: assignment.legType,
      status: TRIP_PACKAGE_LEG_STATUSES.reserved,
      pickupAt: assignment.pickupAt,
      pickup: assignment.pickup,
      dropoff: assignment.dropoff,
      transportType,
      reservationId: assignment.reservationId,
      assignedDriverId: assignment.assignedDriverId,
      vehicleId: assignment.vehicleId,
      activationAt: assignment.activationAt,
      tripId: null,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    };
  }

  function buildTripPackageReservationCreatePayload(params: {
    clientId: string;
    packageId: string;
    bookingId: string;
    packageDocument: TripPackageDocument;
    assignment: TripPackageBookingLegAssignment;
  }): Record<string, unknown> {
    const { clientId, packageId, bookingId, packageDocument, assignment } =
      params;
    return {
      clientId,
      scheduledAt: assignment.pickupAt,
      status: "scheduled",
      pickup: assignment.pickup,
      destination: assignment.dropoff,
      transportType: packageDocument.transportType,
      assignedDriverId: assignment.assignedDriverId,
      vehicleId: assignment.vehicleId,
      scheduledDayKey: buildScheduledDayKey(
        assignment.pickupAt,
        RESERVATION_ACTIVATION_TIMEZONE,
      ),
      scheduledMinutesLocal: buildScheduledMinutesLocal(
        assignment.pickupAt,
        RESERVATION_ACTIVATION_TIMEZONE,
      ),
      source: TRIP_PACKAGE_SOURCE,
      packageId,
      packageBookingId: bookingId,
      packageLegType: assignment.legType,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    };
  }

  async function enqueueTripPackageActivationTask(
    assignment: TripPackageBookingLegAssignment,
    bookingId: string,
  ): Promise<void> {
    const queue = getFunctions().taskQueue<{
      bookingId: string;
      legType: TripPackageLegType;
    }>(TRIP_PACKAGE_TASK_FUNCTION_NAME);
    await queue.enqueue(
      {
        bookingId,
        legType: assignment.legType,
      },
      {
        id: assignment.taskId,
        scheduleTime: assignment.activationAt,
      },
    );
    logger.info("Trip package activation task enqueued.", {
      bookingId,
      legType: assignment.legType,
      taskId: assignment.taskId,
      activationAt: assignment.activationAt.toISOString(),
    });
  }

  async function deleteTripPackageActivationTask(params: {
    bookingId: string;
    legType: TripPackageLegType;
  }): Promise<void> {
    const taskId = buildTripPackageTaskId(params);
    try {
      const queue = getFunctions().taskQueue(TRIP_PACKAGE_TASK_FUNCTION_NAME);
      await queue.delete(taskId);
      logger.info("Trip package activation task deleted.", {
        bookingId: params.bookingId,
        legType: params.legType,
        taskId,
      });
    } catch (error) {
      logger.warn("Trip package activation task delete skipped.", {
        bookingId: params.bookingId,
        legType: params.legType,
        taskId,
        error,
      });
    }
  }

  async function confirmTripPackageBookingCore(params: {
    clientId: string;
    payload: ConfirmTripPackageBookingPayload;
  }): Promise<string> {
    const { clientId, payload } = params;
    const packageRef = firestore.doc(`tripPackages/${payload.packageId}`);
    const packageSnapshot = await packageRef.get();
    const packageDocument = resolveTripPackageDocument({
      packageId: payload.packageId,
      data: packageSnapshot.data(),
    });
    validateTripPackageBookingRules({
      packageDocument,
      payload,
      now: new Date(),
    });

    const bookingRef = firestore.collection("tripPackageBookings").doc();
    const bookingId = bookingRef.id;
    const plans = buildTripPackageLegPlans({
      pickup: payload.pickup,
      packageDocument,
      outboundPickupAt: payload.outboundPickupAt,
      returnPickupAt: payload.returnPickupAt,
      mode: payload.mode,
    });
    const assignments = await selectTripPackageAssignments({
      bookingId,
      plans,
    });
    const chargedAmount = resolveTripPackageBookingAmount({
      packageDocument,
      mode: payload.mode,
    });
    const balanceRef = firestore.doc(`balances/${clientId}`);
    const chargeLedgerRef = firestore.doc(
      `balance_adjustments/${buildTripPackageChargeLedgerId(bookingId)}`,
    );

    await firestore.runTransaction(async (transaction) => {
      const [freshPackageSnapshot, balanceSnapshot] = await Promise.all([
        transaction.get(packageRef),
        transaction.get(balanceRef),
      ]);
      const freshPackage = resolveTripPackageDocument({
        packageId: payload.packageId,
        data: freshPackageSnapshot.data(),
      });
      validateTripPackageBookingRules({
        packageDocument: freshPackage,
        payload,
        now: new Date(),
      });
      if (!balanceSnapshot.exists) {
        throw new HttpsError("failed-precondition", "Saldo indisponível.");
      }
      const eligibility = parseTripEligibilitySnapshot(balanceSnapshot.data());
      assertMoneyCurrencyOrThrow({
        value: chargedAmount,
        expectedCurrency: eligibility.balance.currency,
        fieldName: "chargedAmount",
      });
      const creditLimitMinor = resolveCreditLimitMinor(
        eligibility.debtLimit.amountMinor,
      );
      const projectedDetails = buildLimitExceededDetails({
        operation: "confirm_trip_package_booking",
        currency: eligibility.balance.currency,
        balanceBeforeMinor: eligibility.balance.amountMinor,
        debitAmountMinor: Math.max(chargedAmount.amountMinor, 0),
        creditLimitMinor,
      });
      if (
        !isBalanceWithinCreditLimit({
          balanceAfterMinor: projectedDetails.balanceAfterMinor,
          creditLimitMinor,
        })
      ) {
        throwLimitExceededError(projectedDetails);
      }
      for (const assignment of assignments) {
        await assertTripPackageAssignmentAvailableInTransaction({
          transaction,
          assignment,
        });
        const reservationRef = firestore.doc(
          `reservations/${assignment.reservationId}`,
        );
        transaction.set(
          reservationRef,
          buildTripPackageReservationCreatePayload({
            clientId,
            packageId: freshPackage.id,
            bookingId,
            packageDocument: freshPackage,
            assignment,
          }),
        );
        transaction.set(
          firestore.doc(
            buildTripPackageLegPath({
              bookingId,
              legType: assignment.legType,
            }),
          ),
          buildTripPackageLegCreatePayload({
            bookingId,
            packageId: freshPackage.id,
            clientId,
            assignment,
            transportType: freshPackage.transportType,
          }),
        );
      }

      const updatedBalanceMinor =
        eligibility.balance.amountMinor - chargedAmount.amountMinor;
      const balancePayload = {
        balance: buildMoneyPayload(updatedBalanceMinor),
        debtLimit: eligibility.debtLimit,
        updatedAt: FieldValue.serverTimestamp(),
      };
      enforceBalancePayload({
        payload: balancePayload,
        context: "confirmTripPackageBooking.balance",
      });
      transaction.set(balanceRef, balancePayload, { merge: true });

      const bookingPayload = buildTripPackageBookingCreatePayload({
        clientId,
        packageDocument: freshPackage,
        pickup: payload.pickup,
        outboundPickupAt: payload.outboundPickupAt,
        returnPickupAt: payload.returnPickupAt ?? null,
        mode: payload.mode,
        chargedAmount,
      });
      transaction.set(bookingRef, bookingPayload);

      const chargeLedgerPayload = {
        clientId,
        adminId: "system",
        delta: {
          amountMinor: -chargedAmount.amountMinor,
          currency: OPERATION_CURRENCY_CODE,
        },
        reason: "Cobrança do pacote pré-pago",
        tripPackageBookingId: bookingId,
        createdAt: FieldValue.serverTimestamp(),
        ...buildTripEventTtlField(),
      };
      enforceBalanceAdjustmentPayload({
        payload: chargeLedgerPayload,
        context: "confirmTripPackageBooking.ledger",
      });
      transaction.set(chargeLedgerRef, chargeLedgerPayload);
    });

    await Promise.all(
      assignments.map(async (assignment) => {
        try {
          await enqueueTripPackageActivationTask(assignment, bookingId);
        } catch (error) {
          logger.error("Failed to enqueue trip package activation task.", {
            bookingId,
            legType: assignment.legType,
            error,
          });
          await markTripPackageLegOpsException({
            bookingId,
            legType: assignment.legType,
            reason: "task_enqueue_failed",
          });
        }
      }),
    );

    logger.info("Trip package booking confirmed.", {
      bookingId,
      clientId,
      packageId: payload.packageId,
      mode: payload.mode,
      chargedAmountMinor: chargedAmount.amountMinor,
    });
    return bookingId;
  }

  async function cancelTripPackageBookingCore(params: {
    bookingId: string;
    clientId: string;
  }): Promise<void> {
    const { bookingId, clientId } = params;
    const bookingRef = firestore.doc(`tripPackageBookings/${bookingId}`);
    const outboundLegRef = firestore.doc(
      buildTripPackageLegPath({
        bookingId,
        legType: TRIP_PACKAGE_LEG_TYPES.outbound,
      }),
    );
    const returnLegRef = firestore.doc(
      buildTripPackageLegPath({
        bookingId,
        legType: TRIP_PACKAGE_LEG_TYPES.return,
      }),
    );
    const balanceRef = firestore.doc(`balances/${clientId}`);
    const refundLedgerRef = firestore.doc(
      `balance_adjustments/${buildTripPackageRefundLedgerId({
        bookingId,
        refundType: "full",
      })}`,
    );

    await firestore.runTransaction(async (transaction) => {
      const [
        bookingSnapshot,
        outboundLegSnapshot,
        returnLegSnapshot,
        balanceSnapshot,
      ] = await Promise.all([
        transaction.get(bookingRef),
        transaction.get(outboundLegRef),
        transaction.get(returnLegRef),
        transaction.get(balanceRef),
      ]);
      const booking = parseTripPackageBookingDocument(bookingSnapshot.data());
      if (booking.clientId !== clientId) {
        throw new HttpsError("permission-denied", "Permissões insuficientes.");
      }
      if (booking.status === TRIP_PACKAGE_BOOKING_STATUSES.cancelled) {
        return;
      }
      const outboundLeg = parseTripPackageLegDocument({
        data: outboundLegSnapshot.data(),
        expectedLegType: TRIP_PACKAGE_LEG_TYPES.outbound,
      });
      if (outboundLeg.status !== TRIP_PACKAGE_LEG_STATUSES.reserved) {
        throw new HttpsError(
          "failed-precondition",
          "O pacote já entrou em ativação e não pode ser cancelado.",
        );
      }
      const balanceEligibility = parseTripEligibilitySnapshot(
        balanceSnapshot.data(),
      );
      const refundedAmountMinor = booking.chargedAmount.amountMinor;
      const updatedBalanceMinor =
        balanceEligibility.balance.amountMinor + refundedAmountMinor;
      transaction.set(
        balanceRef,
        {
          balance: buildMoneyPayload(updatedBalanceMinor),
          debtLimit: balanceEligibility.debtLimit,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      transaction.set(refundLedgerRef, {
        clientId,
        adminId: "system",
        delta: buildMoneyPayload(refundedAmountMinor),
        reason: "Reembolso total do pacote pré-pago",
        tripPackageBookingId: bookingId,
        createdAt: FieldValue.serverTimestamp(),
        ...buildTripEventTtlField(),
      });
      transaction.update(bookingRef, {
        status: TRIP_PACKAGE_BOOKING_STATUSES.cancelled,
        refundStatus: TRIP_PACKAGE_REFUND_STATUSES.full,
        refundedAmount: buildMoneyPayload(refundedAmountMinor),
        cancelledAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
      const reservationRefs = [
        firestore.doc(
          `reservations/${buildTripPackageReservationId({
            bookingId,
            legType: TRIP_PACKAGE_LEG_TYPES.outbound,
          })}`,
        ),
      ];
      const legUpdates = [outboundLegRef];
      if (returnLegSnapshot.exists) {
        reservationRefs.push(
          firestore.doc(
            `reservations/${buildTripPackageReservationId({
              bookingId,
              legType: TRIP_PACKAGE_LEG_TYPES.return,
            })}`,
          ),
        );
        legUpdates.push(returnLegRef);
      }
      for (const reservationRef of reservationRefs) {
        transaction.set(
          reservationRef,
          {
            status: "cancelled",
            cancelledAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
      }
      for (const legRef of legUpdates) {
        transaction.set(
          legRef,
          {
            status: TRIP_PACKAGE_LEG_STATUSES.cancelled,
            cancelledAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
      }
    });

    await deleteTripPackageActivationTask({
      bookingId,
      legType: TRIP_PACKAGE_LEG_TYPES.outbound,
    });
    await deleteTripPackageActivationTask({
      bookingId,
      legType: TRIP_PACKAGE_LEG_TYPES.return,
    });
  }

  async function cancelTripPackageReturnLegCore(params: {
    bookingId: string;
    clientId: string;
  }): Promise<void> {
    const { bookingId, clientId } = params;
    const bookingRef = firestore.doc(`tripPackageBookings/${bookingId}`);
    const outboundLegRef = firestore.doc(
      buildTripPackageLegPath({
        bookingId,
        legType: TRIP_PACKAGE_LEG_TYPES.outbound,
      }),
    );
    const returnLegRef = firestore.doc(
      buildTripPackageLegPath({
        bookingId,
        legType: TRIP_PACKAGE_LEG_TYPES.return,
      }),
    );
    const returnReservationRef = firestore.doc(
      `reservations/${buildTripPackageReservationId({
        bookingId,
        legType: TRIP_PACKAGE_LEG_TYPES.return,
      })}`,
    );
    const balanceRef = firestore.doc(`balances/${clientId}`);
    const refundLedgerRef = firestore.doc(
      `balance_adjustments/${buildTripPackageRefundLedgerId({
        bookingId,
        refundType: "return",
      })}`,
    );

    await firestore.runTransaction(async (transaction) => {
      const [
        bookingSnapshot,
        outboundLegSnapshot,
        returnLegSnapshot,
        balanceSnapshot,
      ] = await Promise.all([
        transaction.get(bookingRef),
        transaction.get(outboundLegRef),
        transaction.get(returnLegRef),
        transaction.get(balanceRef),
      ]);
      const booking = parseTripPackageBookingDocument(bookingSnapshot.data());
      if (booking.clientId !== clientId) {
        throw new HttpsError("permission-denied", "Permissões insuficientes.");
      }
      if (booking.mode !== TRIP_PACKAGE_BOOKING_MODES.roundTrip) {
        throw new HttpsError(
          "failed-precondition",
          "O pacote não inclui volta.",
        );
      }
      const outboundLeg = parseTripPackageLegDocument({
        data: outboundLegSnapshot.data(),
        expectedLegType: TRIP_PACKAGE_LEG_TYPES.outbound,
      });
      const returnLeg = parseTripPackageLegDocument({
        data: returnLegSnapshot.data(),
        expectedLegType: TRIP_PACKAGE_LEG_TYPES.return,
      });
      if (
        booking.status !== TRIP_PACKAGE_BOOKING_STATUSES.partiallyUsed ||
        outboundLeg.status !== TRIP_PACKAGE_LEG_STATUSES.completed ||
        returnLeg.status !== TRIP_PACKAGE_LEG_STATUSES.reserved
      ) {
        throw new HttpsError(
          "failed-precondition",
          "A volta já não pode ser cancelada.",
        );
      }
      const refundMinor = Math.max(
        booking.packageSnapshot.roundTripPrice.amountMinor -
          booking.packageSnapshot.oneWayPrice.amountMinor,
        0,
      );
      const balanceEligibility = parseTripEligibilitySnapshot(
        balanceSnapshot.data(),
      );
      transaction.set(
        balanceRef,
        {
          balance: buildMoneyPayload(
            balanceEligibility.balance.amountMinor + refundMinor,
          ),
          debtLimit: balanceEligibility.debtLimit,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      transaction.set(refundLedgerRef, {
        clientId,
        adminId: "system",
        delta: buildMoneyPayload(refundMinor),
        reason: "Reembolso da volta do pacote pré-pago",
        tripPackageBookingId: bookingId,
        createdAt: FieldValue.serverTimestamp(),
        ...buildTripEventTtlField(),
      });
      transaction.update(bookingRef, {
        status: TRIP_PACKAGE_BOOKING_STATUSES.partiallyCancelled,
        refundStatus: TRIP_PACKAGE_REFUND_STATUSES.partial,
        refundedAmount: buildMoneyPayload(refundMinor),
        updatedAt: FieldValue.serverTimestamp(),
      });
      transaction.set(
        returnLegRef,
        {
          status: TRIP_PACKAGE_LEG_STATUSES.cancelled,
          cancelledAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      transaction.set(
        returnReservationRef,
        {
          status: "cancelled",
          cancelledAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    });

    await deleteTripPackageActivationTask({
      bookingId,
      legType: TRIP_PACKAGE_LEG_TYPES.return,
    });
  }

  async function isTripPackageReservedAssignmentUsable(params: {
    reservationId: string;
    driverId: string;
    vehicleId: string;
    pickupAt: Date;
    pickup: TripLocationPayload;
    dropoff: TripLocationPayload;
  }): Promise<boolean> {
    const { reservationId, driverId, vehicleId, pickupAt, pickup, dropoff } =
      params;
    const driverStatusSnapshot = await firestore
      .doc(`${DRIVER_STATUS_COLLECTION}/${driverId}`)
      .get();
    const driverStatusData = driverStatusSnapshot.data() ?? {};
    if (
      driverStatusData.isActive === false ||
      driverStatusData.availabilityEnabled === false ||
      driverStatusData.isAvailable !== true ||
      driverStatusData.isBusy === true ||
      driverStatusData.currentTripId != null
    ) {
      return false;
    }
    if (driverStatusData.vehicleId?.toString() !== vehicleId) {
      return false;
    }
    return !(await hasOverlappingReservations({
      driverId,
      vehicleId,
      window: buildReservationWindow({
        start: pickupAt,
        pickup,
        destination: dropoff,
      }),
      excludeReservationId: reservationId,
    }));
  }

  async function tryReassignTripPackageLeg(params: {
    bookingId: string;
    booking: TripPackageBookingDocument;
    leg: ParsedTripPackageBookingLeg;
  }): Promise<{
    assignedDriverId: string;
    vehicleId: string;
  } | null> {
    const { bookingId, booking, leg } = params;
    const availableDrivers = await fetchAvailableDrivers();
    const filteredDrivers = availableDrivers.filter(
      (driver) => driver.driverId !== leg.assignedDriverId,
    );
    if (filteredDrivers.length === 0) {
      return null;
    }
    const candidateResolution = await resolveDriverCandidates(
      filteredDrivers,
      leg.pickup,
    );
    if (candidateResolution.candidates.length === 0) {
      return null;
    }
    const selection = await selectDriverVehicleCandidate({
      candidates: candidateResolution.candidates,
      window: buildReservationWindow({
        start: leg.pickupAt,
        pickup: leg.pickup,
        destination: leg.dropoff,
      }),
      reservedAssignments: [],
    });
    if (!selection.assignment) {
      return null;
    }
    const reservationRef = firestore.doc(
      `reservations/${buildTripPackageReservationId({
        bookingId,
        legType: leg.legType,
      })}`,
    );
    await reservationRef.set(
      {
        assignedDriverId: selection.assignment.id,
        vehicleId: selection.assignment.vehicleId,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    await firestore
      .doc(
        buildTripPackageLegPath({
          bookingId,
          legType: leg.legType,
        }),
      )
      .set(
        {
          assignedDriverId: selection.assignment.id,
          vehicleId: selection.assignment.vehicleId,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    logger.warn("Trip package leg reassigned during activation.", {
      bookingId,
      packageId: booking.packageId,
      legType: leg.legType,
      assignedDriverId: selection.assignment.id,
      vehicleId: selection.assignment.vehicleId,
    });
    return {
      assignedDriverId: selection.assignment.id,
      vehicleId: selection.assignment.vehicleId,
    };
  }

  async function markTripPackageLegOpsException(params: {
    bookingId: string;
    legType: TripPackageLegType;
    reason: string;
  }): Promise<void> {
    const { bookingId, legType, reason } = params;
    const legRef = firestore.doc(
      buildTripPackageLegPath({
        bookingId,
        legType,
      }),
    );
    const reservationRef = firestore.doc(
      `reservations/${buildTripPackageReservationId({
        bookingId,
        legType,
      })}`,
    );
    const bookingRef = firestore.doc(`tripPackageBookings/${bookingId}`);
    await Promise.all([
      legRef.set(
        {
          status: TRIP_PACKAGE_LEG_STATUSES.opsException,
          opsExceptionReason: reason,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      ),
      reservationRef.set(
        {
          status: "failed",
          failureReason: reason,
          failedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      ),
      bookingRef.set(
        {
          status: TRIP_PACKAGE_BOOKING_STATUSES.opsException,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      ),
    ]);
    await notifyManagersTripPackageOpsException({
      bookingId,
      legType,
      reason,
    });
  }

  async function activateTripPackageLegCore(params: {
    bookingId: string;
    legType: TripPackageLegType;
  }): Promise<void> {
    const { bookingId, legType } = params;
    const bookingRef = firestore.doc(`tripPackageBookings/${bookingId}`);
    const legRef = firestore.doc(
      buildTripPackageLegPath({
        bookingId,
        legType,
      }),
    );
    const reservationId = buildTripPackageReservationId({
      bookingId,
      legType,
    });
    const reservationRef = firestore.doc(`reservations/${reservationId}`);
    const [bookingSnapshot, legSnapshot, reservationSnapshot] =
      await Promise.all([bookingRef.get(), legRef.get(), reservationRef.get()]);
    if (
      !bookingSnapshot.exists ||
      !legSnapshot.exists ||
      !reservationSnapshot.exists
    ) {
      logger.warn("Trip package activation skipped due to missing records.", {
        bookingId,
        legType,
      });
      return;
    }
    const booking = parseTripPackageBookingDocument(bookingSnapshot.data());
    const leg = parseTripPackageLegDocument({
      data: legSnapshot.data(),
      expectedLegType: legType,
    });
    const reservationData = reservationSnapshot.data() ?? {};
    if (
      booking.status === TRIP_PACKAGE_BOOKING_STATUSES.cancelled ||
      leg.status === TRIP_PACKAGE_LEG_STATUSES.cancelled ||
      leg.status === TRIP_PACKAGE_LEG_STATUSES.completed ||
      leg.status === TRIP_PACKAGE_LEG_STATUSES.opsException
    ) {
      logger.info("Trip package activation no-op due to terminal state.", {
        bookingId,
        legType,
        bookingStatus: booking.status,
        legStatus: leg.status,
      });
      return;
    }
    const existingTripId =
      typeof reservationData.tripId === "string" &&
      reservationData.tripId.trim()
        ? reservationData.tripId
        : leg.tripId;
    if (existingTripId) {
      await legRef.set(
        {
          status: TRIP_PACKAGE_LEG_STATUSES.tripCreated,
          tripId: existingTripId,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      return;
    }
    if (reservationData.status?.toString() !== "scheduled") {
      logger.info(
        "Trip package activation skipped: reservation not scheduled.",
        {
          bookingId,
          legType,
          reservationStatus: reservationData.status ?? null,
        },
      );
      return;
    }
    await legRef.set(
      {
        status: TRIP_PACKAGE_LEG_STATUSES.activating,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    let assignedDriverId = leg.assignedDriverId;
    let vehicleId = leg.vehicleId;
    const usable = await isTripPackageReservedAssignmentUsable({
      reservationId,
      driverId: assignedDriverId,
      vehicleId,
      pickupAt: leg.pickupAt,
      pickup: leg.pickup,
      dropoff: leg.dropoff,
    });
    if (!usable) {
      const reassigned = await tryReassignTripPackageLeg({
        bookingId,
        booking,
        leg,
      });
      if (!reassigned) {
        await markTripPackageLegOpsException({
          bookingId,
          legType,
          reason: "reassignment_failed",
        });
        return;
      }
      assignedDriverId = reassigned.assignedDriverId;
      vehicleId = reassigned.vehicleId;
    }

    const tariffSeed = await fetchCurrentTariffSeed();
    const tripId = await createTripFromReservation({
      reservationId,
      clientId: booking.clientId,
      pickup: leg.pickup,
      destination: leg.dropoff,
      transportType: booking.packageSnapshot.transportType,
      tariffSeed,
      scheduledAt: leg.pickupAt,
      assignedDriverId,
      vehicleId,
      tripId: buildTripPackageTripId({ bookingId, legType }),
      extraTripFields: {
        packageBookingId: bookingId,
        packageId: booking.packageId,
        packageLegType: legType,
        fareCoverage: TRIP_PACKAGE_FARE_COVERAGE_INCLUDED,
        packageSnapshotVersion: booking.packageSnapshot.packageSnapshotVersion,
      },
    });
    if (!tripId) {
      await markTripPackageLegOpsException({
        bookingId,
        legType,
        reason: "trip_creation_failed",
      });
      return;
    }
    await legRef.set(
      {
        status: TRIP_PACKAGE_LEG_STATUSES.tripCreated,
        tripId,
        assignedDriverId,
        vehicleId,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }

  async function syncTripPackageLegFromTripStatusChange(params: {
    tripId: string;
    tripData: Record<string, unknown>;
    afterStatus: string;
  }): Promise<void> {
    const { tripId, tripData, afterStatus } = params;
    const bookingId = tripData.packageBookingId?.toString()?.trim() ?? "";
    const legType = parseTripPackageLegType(tripData.packageLegType);
    if (!bookingId || !legType) {
      return;
    }
    const legRef = firestore.doc(
      buildTripPackageLegPath({
        bookingId,
        legType,
      }),
    );
    const reservationRef = firestore.doc(
      `reservations/${buildTripPackageReservationId({
        bookingId,
        legType,
      })}`,
    );
    if (afterStatus === "COMPLETED" || afterStatus === "CHARGE_APPLIED") {
      await Promise.all([
        legRef.set(
          {
            status: TRIP_PACKAGE_LEG_STATUSES.completed,
            tripId,
            completedAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        ),
        reservationRef.set(
          {
            status: "completed",
            completedAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        ),
      ]);
      await syncTripPackageBookingStatusFromLegs(bookingId);
      return;
    }
    if (
      afterStatus === "NO_DRIVERS_AVAILABLE" ||
      afterStatus === "CANCELLED_BY_CLIENT" ||
      afterStatus === "CANCELLED_BY_DRIVER" ||
      afterStatus === "NO_SHOW"
    ) {
      await markTripPackageLegOpsException({
        bookingId,
        legType,
        reason: `trip_${afterStatus.toLowerCase()}`,
      });
      await syncTripPackageBookingStatusFromLegs(bookingId);
    }
  }

  async function syncTripPackageBookingStatusFromLegs(
    bookingId: string,
  ): Promise<void> {
    const bookingRef = firestore.doc(`tripPackageBookings/${bookingId}`);
    const [bookingSnapshot, legsSnapshot] = await Promise.all([
      bookingRef.get(),
      firestore.collection(`tripPackageBookings/${bookingId}/legs`).get(),
    ]);
    if (!bookingSnapshot.exists) {
      return;
    }
    const booking = parseTripPackageBookingDocument(bookingSnapshot.data());
    const legEntries = legsSnapshot.docs.map((doc) =>
      parseTripPackageLegDocument({
        data: doc.data(),
        expectedLegType:
          doc.id === TRIP_PACKAGE_LEG_TYPES.return
            ? TRIP_PACKAGE_LEG_TYPES.return
            : TRIP_PACKAGE_LEG_TYPES.outbound,
      }),
    );
    const nextStatus = deriveTripPackageBookingStatus({
      booking,
      legs: legEntries,
    });
    if (nextStatus === booking.status) {
      return;
    }
    await bookingRef.set(
      {
        status: nextStatus,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }

  async function notifyManagersTripPackageOpsException(params: {
    bookingId: string;
    legType: TripPackageLegType;
    reason: string;
  }): Promise<void> {
    const managerIds = await fetchManagerIdsForAlerts();
    if (managerIds.length === 0) {
      return;
    }
    await Promise.all(
      managerIds.map((managerId) =>
        notifyUser({
          userId: managerId,
          context: "ops.trip_package_exception",
          message: {
            title: "Pacote com exceção operacional",
            body: `O pacote ${params.bookingId} entrou em exceção na perna ${params.legType}.`,
            data: {
              type: "ops.trip_package_exception",
              bookingId: params.bookingId,
              legType: params.legType,
              reason: params.reason,
            },
          },
        }),
      ),
    );
  }

  async function markReservationFailed(params: {
    reservationId: string;
    clientId?: string;
    reason: string;
  }): Promise<void> {
    const { reservationId, clientId, reason } = params;
    const reservationRef = firestore.doc(`reservations/${reservationId}`);
    const reservationSnapshot = await reservationRef.get();
    const scheduledAt = reservationSnapshot.data()?.scheduledAt?.toDate?.();
    const scheduleUpdates: Record<string, unknown> = {};
    if (scheduledAt instanceof Date) {
      scheduleUpdates.scheduledDayKey = buildScheduledDayKey(
        scheduledAt,
        RESERVATION_ACTIVATION_TIMEZONE,
      );
      scheduleUpdates.scheduledMinutesLocal = buildScheduledMinutesLocal(
        scheduledAt,
        RESERVATION_ACTIVATION_TIMEZONE,
      );
    } else {
      logger.warn("Reservation missing scheduledAt for failure metadata.", {
        reservationId,
      });
    }

    const reservationPayload = {
      status: "failed",
      failureReason: reason,
      failedAt: FieldValue.serverTimestamp(),
      ...scheduleUpdates,
      updatedAt: FieldValue.serverTimestamp(),
    };
    enforceReservationUpdatePayload({
      payload: reservationPayload,
      context: "markReservationFailed",
    });
    await reservationRef.update(reservationPayload);
    logger.warn("Reservation marked as failed.", { reservationId, reason });
    if (clientId) {
      await notifyClientReservationFailed(clientId, reservationId);
    }
  }

  function isAfterReservationActivation(date: Date, timeZone: string): boolean {
    const parts = getLocalDateParts(date, timeZone);
    return parts.hour >= RESERVATION_ACTIVATION_HOUR;
  }

  function getLocalDayBounds(
    date: Date,
    timeZone: string,
  ): {
    start: Date;
    end: Date;
  } {
    const parts = getLocalDateParts(date, timeZone);
    const startBase = new Date(
      Date.UTC(parts.year, parts.month - 1, parts.day),
    );
    const startOffset = getTimeZoneOffsetMinutes(startBase, timeZone);
    const start = new Date(startBase.getTime() - startOffset * 60 * 1000);

    const nextDay = new Date(date.getTime() + 24 * 60 * 60 * 1000);
    const nextParts = getLocalDateParts(nextDay, timeZone);
    const endBase = new Date(
      Date.UTC(nextParts.year, nextParts.month - 1, nextParts.day),
    );
    const endOffset = getTimeZoneOffsetMinutes(endBase, timeZone);
    const end = new Date(endBase.getTime() - endOffset * 60 * 1000);

    return { start, end };
  }

  function getLocalDateParts(
    date: Date,
    timeZone: string,
  ): {
    year: number;
    month: number;
    day: number;
    hour: number;
    minute: number;
    second: number;
  } {
    const formatter = new Intl.DateTimeFormat("en-CA", {
      timeZone,
      hour12: false,
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
    });
    const parts = formatter.formatToParts(date);
    const values = parts.reduce<Record<string, number>>((acc, part) => {
      if (part.type === "literal") {
        return acc;
      }
      acc[part.type] = Number.parseInt(part.value, 10);
      return acc;
    }, {});

    return {
      year: values.year ?? date.getUTCFullYear(),
      month: values.month ?? date.getUTCMonth() + 1,
      day: values.day ?? date.getUTCDate(),
      hour: values.hour ?? date.getUTCHours(),
      minute: values.minute ?? date.getUTCMinutes(),
      second: values.second ?? date.getUTCSeconds(),
    };
  }

  function buildScheduledDayKey(date: Date, timeZone: string): string {
    const parts = getLocalDateParts(date, timeZone);
    const year = parts.year.toString().padStart(4, "0");
    const month = parts.month.toString().padStart(2, "0");
    const day = parts.day.toString().padStart(2, "0");
    return `${year}-${month}-${day}`;
  }

  function buildScheduledMinutesLocal(date: Date, timeZone: string): number {
    const parts = getLocalDateParts(date, timeZone);
    return parts.hour * 60 + parts.minute;
  }

  function getTimeZoneOffsetMinutes(date: Date, timeZone: string): number {
    const formatter = new Intl.DateTimeFormat("en-US", {
      timeZone,
      hour12: false,
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
    });
    const parts = formatter.formatToParts(date);
    const values = parts.reduce<Record<string, string>>((acc, part) => {
      if (part.type !== "literal") {
        acc[part.type] = part.value;
      }
      return acc;
    }, {});
    const utcTime = Date.UTC(
      Number.parseInt(values.year ?? "0", 10),
      Number.parseInt(values.month ?? "1", 10) - 1,
      Number.parseInt(values.day ?? "1", 10),
      Number.parseInt(values.hour ?? "0", 10),
      Number.parseInt(values.minute ?? "0", 10),
      Number.parseInt(values.second ?? "0", 10),
    );
    return (utcTime - date.getTime()) / 60000;
  }

  async function fetchClientDiscountConfig(params: {
    transaction: admin.firestore.Transaction;
    clientId: string;
  }): Promise<ClientDiscountConfig> {
    const { transaction, clientId } = params;
    const userSnapshot = await transaction.get(
      firestore.doc(`users/${clientId}`),
    );
    const userData = userSnapshot.data();
    if (userData) {
      return parseDiscountConfig(userData);
    }
    logger.warn("Client profile missing for discount lookup.", { clientId });
    return {};
  }

  function parseDiscountConfig(
    data: FirebaseFirestore.DocumentData,
  ): ClientDiscountConfig {
    return {
      discountPercentGlobal: parseOptionalPercent(data.discountPercentGlobal),
      discountPercentByDistance: parseOptionalPercent(
        data.discountPercentByDistance,
      ),
      discountFixedMinor: parseOptionalMinor(data.discountFixedMinor),
    };
  }

  function parseOptionalPercent(value: unknown): number | undefined {
    const parsed =
      typeof value === "number" ? value : Number.parseFloat(`${value}`);
    if (Number.isNaN(parsed) || parsed <= 0) {
      return undefined;
    }
    return Math.min(parsed, 100);
  }

  function parseOptionalMinor(value: unknown): number | undefined {
    const parsed = parseNumber(value);
    if (parsed <= 0) {
      return undefined;
    }
    return parsed;
  }

  function applyDiscounts(params: {
    discountConfig: ClientDiscountConfig;
    subtotalMinor: number;
    distanceEligibleMinor: number;
  }): {
    discountMinor: number;
    breakdown: TripChargeDiscountBreakdown;
  } {
    const { discountConfig, subtotalMinor, distanceEligibleMinor } = params;
    const percentGlobal = discountConfig.discountPercentGlobal;
    const percentByDistance = discountConfig.discountPercentByDistance;
    const fixedMinor = discountConfig.discountFixedMinor;
    let remaining = subtotalMinor;

    const globalDiscountMinor =
      percentGlobal != null
        ? Math.min(remaining, Math.round(subtotalMinor * (percentGlobal / 100)))
        : 0;
    remaining -= globalDiscountMinor;

    const distanceDiscountMinor =
      percentByDistance != null
        ? Math.min(
            remaining,
            Math.round(distanceEligibleMinor * (percentByDistance / 100)),
          )
        : 0;
    remaining -= distanceDiscountMinor;

    const fixedDiscountMinor =
      fixedMinor != null ? Math.min(remaining, fixedMinor) : 0;
    remaining -= fixedDiscountMinor;

    const discountTotalMinor = subtotalMinor - remaining;
    return {
      discountMinor: discountTotalMinor,
      breakdown: {
        discountPercentGlobal: percentGlobal,
        discountPercentByDistance: percentByDistance,
        discountFixedMinor: fixedMinor,
        discountGlobalMinor: globalDiscountMinor,
        discountDistanceMinor: distanceDiscountMinor,
        discountFixedMinorApplied: fixedDiscountMinor,
        discountTotalMinor,
      },
    };
  }

  function buildChargeBreakdown(
    pricing: TripPricingSnapshot,
    metering: TripMeteringSnapshot | null,
    discountConfig: ClientDiscountConfig,
    surchargeMinor: number,
    timestamps?: {
      arrivedAt?: Date;
      startedAt?: Date;
      arrivedDestinationAt?: Date;
      completedAt?: Date;
    },
  ): TripChargeBreakdown {
    const hasMetering =
      metering != null &&
      (metering.totalMinutes > 0 ||
        metering.totalWaitMinutes > 0 ||
        metering.totalDistanceKm > 0);
    let resolvedMetering = metering;
    let resolvedFrom: "metering" | "fallback" | "estimate" = hasMetering
      ? "metering"
      : "estimate";
    if (!hasMetering && timestamps) {
      const arrivedAt = timestamps.arrivedAt;
      const startedAt = timestamps.startedAt;
      const finishedAt =
        timestamps.arrivedDestinationAt ?? timestamps.completedAt;
      const waitMinutes =
        arrivedAt && startedAt
          ? Math.max(
              0,
              Math.floor((startedAt.getTime() - arrivedAt.getTime()) / 60000),
            )
          : 0;
      const tripMinutes =
        startedAt && finishedAt
          ? Math.max(
              0,
              Math.floor((finishedAt.getTime() - startedAt.getTime()) / 60000),
            )
          : 0;
      if (waitMinutes > 0 || tripMinutes > 0) {
        resolvedMetering = {
          totalMinutes: tripMinutes,
          totalWaitMinutes: waitMinutes,
          totalDistanceKm: 0,
          estimatedCostMinor: 0,
          activeMultiplierId: undefined,
        };
        resolvedFrom = "fallback";
      }
    }

    const totalDistanceKm = resolvedMetering?.totalDistanceKm ?? 0;
    const totalDistanceMeters = toMetersFromKm(totalDistanceKm);
    const totalMinutes = resolvedMetering?.totalMinutes ?? 0;
    const totalWaitMinutes = resolvedMetering?.totalWaitMinutes ?? 0;
    const distanceMinor = calculateDistanceTierChargeMinor({
      totalMeters: totalDistanceMeters,
      tiers: pricing.distanceTiers,
      fallbackPerKmMinor: pricing.perKmMinor,
    });
    const waitMinor = pricing.perWaitMinuteMinor * totalWaitMinutes;
    const preMultiplierSubtotalMinor =
      pricing.baseMinor + distanceMinor + waitMinor;

    const meteringMultiplier =
      resolvedMetering?.activeMultiplierId != null
        ? (pricing.multipliers[resolvedMetering.activeMultiplierId] ?? null)
        : null;
    let multiplierValue = 1;
    let multiplierId: string | undefined =
      resolvedMetering?.activeMultiplierId ?? pricing.appliedMultiplierId;
    if (meteringMultiplier != null) {
      multiplierValue = meteringMultiplier;
      multiplierId = resolvedMetering?.activeMultiplierId ?? multiplierId;
    } else if (pricing.appliedMultiplier && pricing.appliedMultiplier > 0) {
      multiplierValue = pricing.appliedMultiplier;
      multiplierId = pricing.appliedMultiplierId ?? multiplierId;
      logger.info("Multiplier fallback to appliedMultiplier.", {
        multiplierValue,
        multiplierId,
      });
    }

    let subtotalMinor = multiplyMinorAndRoundHalfUp({
      amountMinor: preMultiplierSubtotalMinor,
      multiplier: multiplierValue,
    });
    if (
      resolvedFrom === "estimate" &&
      typeof pricing.estimatedTotalMinor === "number"
    ) {
      if (subtotalMinor < pricing.estimatedTotalMinor) {
        logger.info("Applying estimate floor.", {
          subtotalMinor,
          estimatedTotalMinor: pricing.estimatedTotalMinor,
        });
        subtotalMinor = pricing.estimatedTotalMinor;
      }
    }

    const multiplierChargeMinor = subtotalMinor - preMultiplierSubtotalMinor;
    const { discountMinor, breakdown } = applyDiscounts({
      discountConfig,
      subtotalMinor,
      distanceEligibleMinor: multiplyMinorAndRoundHalfUp({
        amountMinor: distanceMinor,
        multiplier: multiplierValue,
      }),
    });
    const totalMinor =
      Math.max(subtotalMinor - discountMinor, 0) + surchargeMinor;

    if (discountMinor > 0) {
      logger.info("Trip discount applied.", {
        discountMinor,
        subtotalMinor,
        totalMinor,
        discountConfig,
      });
    }

    return {
      baseMinor: pricing.baseMinor,
      distanceMinor,
      waitMinor,
      penaltiesMinor: 0,
      surchargeMinor,
      subtotalMinor,
      multiplierId,
      multiplierValue,
      multiplierChargeMinor,
      discountMinor,
      discountBreakdown: breakdown,
      totalMinor,
      totalDistanceKm: totalDistanceKm,
      totalMinutes: totalMinutes,
      totalWaitMinutes: totalWaitMinutes,
      hasMeteringData: resolvedFrom !== "estimate",
      calculatedFrom: resolvedFrom,
    };
  }

  function sanitizeForFirestore<T>(value: T): T {
    if (Array.isArray(value)) {
      return value
        .map((entry) => sanitizeForFirestore(entry))
        .filter((entry) => entry !== undefined) as T;
    }
    if (value !== null && typeof value === "object") {
      const record = value as Record<string, unknown>;
      const sanitized: Record<string, unknown> = {};
      for (const [key, entry] of Object.entries(record)) {
        if (entry === undefined) {
          continue;
        }
        sanitized[key] = sanitizeForFirestore(entry);
      }
      return sanitized as T;
    }
    return value;
  }

  async function createDriverHeartbeatAlert(driverId: string): Promise<void> {
    const eventRef = firestore.collection("events").doc();
    await eventRef.set({
      targetType: "driver",
      targetIds: [driverId],
      title: "Ligação instável",
      message: "O condutor deixou de atualizar a localização.",
      scheduledAt: Timestamp.fromDate(new Date()),
      createdByAdminId: "system",
      status: "scheduled",
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    logger.info("Driver heartbeat alert event created.", {
      driverId,
      eventId: eventRef.id,
    });
  }

  async function notifyDriver(
    driverId: string,
    message: {
      title: string;
      body: string;
      data?: Record<string, string>;
    },
  ): Promise<void> {
    const tokens = await fetchUserTokens(driverId);
    if (tokens.length === 0) {
      logger.warn("No notification tokens for driver.", { driverId });
      return;
    }

    await sendMulticastNotification({
      userId: driverId,
      tokens,
      message,
      context: "driver",
    });
  }

  async function notifyUser(params: {
    userId: string;
    message: {
      title: string;
      body: string;
      data?: Record<string, string>;
    };
    context: string;
  }): Promise<void> {
    const { userId, message, context } = params;
    const tokens = await fetchUserTokens(userId);
    if (tokens.length === 0) {
      logger.warn("No notification tokens for user.", { userId, context });
      return;
    }
    await sendMulticastNotification({
      userId,
      tokens,
      message,
      context,
    });
  }

  async function fetchManagerIdsForAlerts(): Promise<string[]> {
    const snapshot = await firestore
      .collection("users")
      .where("role", "==", "manager")
      .get();
    if (snapshot.empty) {
      logger.warn("No managers found for alerts.");
      return [];
    }
    return snapshot.docs
      .map((doc) => doc.id)
      .filter((managerId) => managerId.trim().length > 0);
  }

  async function notifyManagersTripUnfulfilled(params: {
    tripId: string;
    reason: string;
    clientId?: string;
  }): Promise<void> {
    const { tripId, reason, clientId } = params;
    const managerIds = await fetchManagerIdsForAlerts();
    if (managerIds.length === 0) {
      logger.warn("Trip unfulfilled alert skipped: no managers available.", {
        tripId,
        reason,
        clientId: clientId ?? null,
      });
      return;
    }
    logger.info("Dispatching trip unfulfilled alert to managers.", {
      tripId,
      reason,
      managerCount: managerIds.length,
      clientId: clientId ?? null,
    });
    await Promise.all(
      managerIds.map((managerId) =>
        notifyUser({
          userId: managerId,
          context: OPS_UNFULFILLED_NOTIFICATION_TYPE,
          message: {
            title: "Viagem sem motorista disponível",
            body: `A viagem ${tripId} ficou sem motorista disponível.`,
            data: {
              type: OPS_UNFULFILLED_NOTIFICATION_TYPE,
              tripId,
              unfulfilledReason: reason,
              status: "NO_DRIVERS_AVAILABLE",
            },
          },
        }),
      ),
    );
    logger.info("Trip unfulfilled alert dispatched to managers.", {
      tripId,
      reason,
      managerCount: managerIds.length,
    });
  }

  function buildDriverPublicProfile(
    data: Record<string, unknown>,
  ): Record<string, unknown> | null {
    const role = data.role?.toString();
    if (role != "driver") {
      return null;
    }
    const name = typeof data.name === "string" ? data.name.trim() : "";
    const photoUrl =
      typeof data.photoUrl === "string" ? data.photoUrl.trim() : "";
    const rating = typeof data.rating === "number" ? data.rating : null;
    const initials = name
      .split(" ")
      .map((chunk) => chunk.trim())
      .filter((chunk) => chunk.length > 0)
      .map((chunk) => chunk[0].toUpperCase())
      .slice(0, 2)
      .join("");

    return {
      initials: initials,
      displayName: initials,
      photoUrl: photoUrl,
      rating: rating,
      updatedAt: FieldValue.serverTimestamp(),
    };
  }

  async function fetchDriverPublicVehicleSummary(
    driverId: string,
  ): Promise<Record<string, unknown> | null> {
    const assignmentSnapshot = await firestore
      .doc(`driverVehicleAssignments/${driverId}`)
      .get();
    const vehicleId = assignmentSnapshot.data()?.vehicleId?.toString();
    if (!vehicleId) {
      return null;
    }
    const vehicleSnapshot = await firestore.doc(`vehicles/${vehicleId}`).get();
    const vehicleData = vehicleSnapshot.data();
    if (!vehicleData) {
      return null;
    }
    const plate = vehicleData.plate?.toString().trim() ?? "";
    const model = vehicleData.model?.toString().trim() ?? "";
    if (!plate && !model) {
      return null;
    }
    return {
      plate: plate,
      model: model,
    };
  }

  const syncDriversPublicProfile = onDocumentWritten(
    {
      document: "users/{uid}",
      region: "europe-southwest1",
    },
    async (event) => {
      const userId = event.params.uid;
      const afterData = event.data?.after.data() as
        | Record<string, unknown>
        | undefined;
      const driversPublicRef = firestore.doc(`driversPublic/${userId}`);

      if (!afterData) {
        logger.info("User deleted, removing driversPublic profile.", {
          userId,
        });
        await driversPublicRef.delete();
        return;
      }

      const publicProfile = buildDriverPublicProfile(afterData);
      if (!publicProfile) {
        logger.info(
          "User is not driver, ensuring driversPublic profile removal.",
          {
            userId,
          },
        );
        await driversPublicRef.delete();
        return;
      }

      const vehicleSummary = await fetchDriverPublicVehicleSummary(userId);
      const payload: Record<string, unknown> = {
        ...publicProfile,
        vehicleSummary: vehicleSummary,
      };

      logger.info("Syncing driversPublic profile.", {
        userId,
        hasPhoto: Boolean(publicProfile["photoUrl"]),
        hasRating: publicProfile["rating"] != null,
        hasVehicleSummary: vehicleSummary != null,
      });

      await driversPublicRef.set(payload, { merge: true });
    },
  );

  const syncDriversPublicVehicle = onDocumentWritten(
    {
      document: "driverVehicleAssignments/{driverId}",
      region: "europe-southwest1",
    },
    async (event) => {
      const driverId = event.params.driverId;
      const driversPublicRef = firestore.doc(`driversPublic/${driverId}`);
      const driversPublicSnapshot = await driversPublicRef.get();
      if (!driversPublicSnapshot.exists) {
        logger.info("driversPublic profile missing, skipping vehicle sync.", {
          driverId,
        });
        return;
      }

      const vehicleSummary = await fetchDriverPublicVehicleSummary(driverId);
      await driversPublicRef.set(
        {
          vehicleSummary: vehicleSummary,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      logger.info("driversPublic vehicle summary synced.", {
        driverId,
        hasVehicleSummary: vehicleSummary != null,
      });
    },
  );

  const syncNotificationTargetToken = onDocumentWritten(
    {
      document: "users/{uid}/fcmTokens/{tokenId}",
      region: "europe-southwest1",
    },
    async (event) => {
      const userId = event.params.uid;
      const afterData = event.data?.after.data() as
        | Record<string, unknown>
        | undefined;
      const tokenValue = afterData?.token?.toString().trim() ?? "";
      const tokenHash = tokenValue
        ? createHash("sha256").update(tokenValue).digest("hex")
        : createHash("sha256").update(event.params.tokenId).digest("hex");
      const targetRef = firestore.doc(`notificationTargets/${userId}`);
      const targetTokenRef = targetRef.collection("tokens").doc(tokenHash);

      if (!afterData || afterData.enabled !== true || !tokenValue) {
        await targetTokenRef.delete();
        await refreshNotificationTargetSummary(userId);
        return;
      }

      const userSnapshot = await firestore.doc(`users/${userId}`).get();
      const userData = userSnapshot.data() ?? {};
      const role = userData.role?.toString().trim().toLowerCase() ?? "";
      const managerPermissions = userData.managerPermissions ?? null;
      await targetRef.set(
        {
          role,
          ...(managerPermissions == null ? {} : { managerPermissions }),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      await targetTokenRef.set(
        {
          token: tokenValue,
          platform: afterData.platform ?? null,
          enabled: true,
          tokenExpiresAt: afterData.tokenExpiresAt ?? null,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      await refreshNotificationTargetSummary(userId);
      logger.info("Notification target token synced.", { userId, tokenHash });
    },
  );

  async function refreshNotificationTargetSummary(
    userId: string,
  ): Promise<void> {
    const targetRef = firestore.doc(`notificationTargets/${userId}`);
    const snapshot = await targetRef
      .collection("tokens")
      .where("enabled", "==", true)
      .get();
    if (snapshot.empty) {
      await targetRef.set(
        {
          enabledTokenCount: 0,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      return;
    }
    await targetRef.set(
      {
        enabledTokenCount: snapshot.size,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }

  async function fetchUserName(userId: string): Promise<string | null> {
    const snapshot = await firestore.doc(`users/${userId}`).get();
    const data = snapshot.data();
    if (!data) {
      return null;
    }
    const name = data.name ?? data.fullName ?? data.displayName;
    return typeof name === "string" && name.trim().length > 0 ? name : null;
  }

  async function notifyAssignedDriverForTrip(params: {
    tripId: string;
    tripData: Record<string, unknown>;
  }): Promise<void> {
    const { tripId, tripData } = params;
    const driverId = tripData.assignedDriverId?.toString();
    if (!driverId) {
      logger.warn("Assigned driver missing for notification.", { tripId });
      return;
    }
    const pickup = parseTripLocation(tripData.pickup);
    const destination = parseTripLocation(tripData.destination);
    const clientId = tripData.clientId?.toString();
    const clientName = clientId ? await fetchUserName(clientId) : null;
    const distanceKm =
      pickup && destination ? calculateDistanceKm(pickup, destination) : null;
    const etaMinutes =
      distanceKm != null
        ? Math.max(1, Math.ceil((distanceKm / AVERAGE_SPEED_KMH) * 60))
        : null;
    const pickupLabel = pickup?.address || "Local de recolha";
    const destinationLabel = destination?.address || "Destino";
    const details = [
      distanceKm != null ? `${distanceKm.toFixed(1)} km` : null,
      etaMinutes != null ? `${etaMinutes} min` : null,
    ].filter((value): value is string => Boolean(value));
    const body =
      details.length > 0
        ? `${pickupLabel} → ${destinationLabel} · ${details.join(" · ")}`
        : `${pickupLabel} → ${destinationLabel}`;

    await notifyDriver(driverId, {
      title: "Novo pedido de viagem",
      body: clientName != null ? `${body} · ${clientName}` : body,
      data: {
        tripId,
        type: "driver.new_trip_assigned",
        pickupAddress: pickup?.address ?? "",
        destinationAddress: destination?.address ?? "",
        ...(distanceKm != null ? { distanceKm: distanceKm.toFixed(2) } : {}),
        ...(etaMinutes != null ? { etaMinutes: etaMinutes.toString() } : {}),
        ...(clientName != null ? { clientName } : {}),
      },
    });
  }

  async function notifyDrivers(
    driverIds: string[],
    message: {
      title: string;
      body: string;
      data?: Record<string, string>;
    },
  ): Promise<void> {
    if (driverIds.length === 0) {
      logger.warn("No drivers found for broadcast notification.");
      return;
    }
    await Promise.all(
      driverIds.map((driverId) => notifyDriver(driverId, message)),
    );
  }

  async function notifyClientUnfulfilled(
    clientId: string,
    tripId: string,
    reason?: string,
  ): Promise<void> {
    const tokens = await fetchUserTokens(clientId);
    if (tokens.length === 0) {
      logger.warn("No notification tokens for client.", { clientId, tripId });
      return;
    }

    const reasonCode = reason ?? "";
    const isNoDrivers =
      reasonCode === "no_drivers" ||
      reasonCode === "no_available_drivers_status";
    const isNoLocations = reasonCode.startsWith("no_locations_within_");
    const isNoNearbyAvailableDrivers = reasonCode.startsWith(
      "no_available_drivers_near_pickup_within_",
    );
    const isNoAssignableDriver =
      reasonCode === "no_vehicle_assignment_for_nearby_drivers" ||
      reasonCode === "nearby_drivers_busy" ||
      reasonCode === "nearby_drivers_with_reservation_conflict" ||
      reasonCode === "nearby_drivers_reserved_in_batch" ||
      reasonCode === "no_assignable_driver_vehicle_candidate";

    const title = isNoDrivers
      ? "Pedido recusado"
      : "Pedido de viagem não atribuído";
    const body = isNoDrivers
      ? "Sem motoristas disponíveis neste momento."
      : isNoLocations
        ? "Não foi possível encontrar motoristas dentro do raio de pesquisa."
        : isNoNearbyAvailableDrivers
          ? "Existem motoristas na zona, mas nenhum está disponível para aceitar."
          : isNoAssignableDriver
            ? "Existem motoristas próximos, mas sem viatura/agenda compatível."
            : "Não foi possível encontrar um motorista disponível.";

    await sendMulticastNotification({
      userId: clientId,
      tokens,
      message: {
        title,
        body,
        data: {
          tripId,
          type: "client.trip_unfulfilled",
          ...(reason ? { unfulfilledReason: reason } : {}),
        },
      },
      context: "client.trip_unfulfilled",
    });
  }

  async function notifyClientReservationFailed(
    clientId: string,
    reservationId: string,
  ): Promise<void> {
    const tokens = await fetchUserTokens(clientId);
    if (tokens.length === 0) {
      logger.warn("No notification tokens for client reservation.", {
        clientId,
        reservationId,
      });
      return;
    }

    await sendMulticastNotification({
      userId: clientId,
      tokens,
      message: {
        title: "Viagem agendada indisponível",
        body: "Não foi possível ativar uma viagem agendada para hoje.",
        data: {
          reservationId,
          type: "client.reservation_failed",
        },
      },
      context: "client.reservation_failed",
    });
  }

  async function fetchDriverIdsForAlerts(): Promise<string[]> {
    const snapshot = await firestore
      .collection("users")
      .where("role", "==", "driver")
      .get();
    if (snapshot.empty) {
      logger.warn("No drivers found for alerts.");
      return [];
    }
    return snapshot.docs.map((doc) => doc.id);
  }

  async function fetchUserTokens(userId: string): Promise<string[]> {
    const snapshot = await firestore
      .collection(`users/${userId}/fcmTokens`)
      .where("enabled", "==", true)
      .get();
    if (snapshot.empty) {
      return [];
    }
    return snapshot.docs
      .map((doc) => {
        const data = doc.data();
        if (typeof doc.id === "string" && doc.id.length > 0) {
          return doc.id;
        }
        const token = data.token;
        return typeof token === "string" ? token : "";
      })
      .filter((token) => token.length > 0);
  }

  const INVALID_TOKEN_ERROR_CODES = new Set([
    "messaging/registration-token-not-registered",
    "messaging/invalid-argument",
    "messaging/invalid-registration-token",
  ]);
  const MAX_FCM_TOKENS_PER_BATCH = 500;

  type MulticastMessagePayload = {
    title: string;
    body: string;
    data?: Record<string, string>;
  };

  async function sendMulticastNotification(params: {
    userId: string;
    tokens: string[];
    message: MulticastMessagePayload;
    context: string;
  }): Promise<void> {
    const { userId, tokens, message, context } = params;
    const tokenChunks = splitIntoChunks(tokens, MAX_FCM_TOKENS_PER_BATCH);
    let successCount = 0;
    let failureCount = 0;

    for (let index = 0; index < tokenChunks.length; index++) {
      const tokenChunk = tokenChunks[index];
      const response = await messaging.sendEachForMulticast({
        tokens: tokenChunk,
        notification: {
          title: message.title,
          body: message.body,
        },
        data: message.data,
      });

      successCount += response.successCount;
      failureCount += response.failureCount;

      logger.info("Multicast notification batch dispatched.", {
        context,
        userId,
        batchIndex: index + 1,
        batchCount: tokenChunks.length,
        tokenCount: tokenChunk.length,
        successCount: response.successCount,
        failureCount: response.failureCount,
      });

      await cleanupInvalidTokens({
        userId,
        tokens: tokenChunk,
        responses: response.responses,
        context,
      });
    }

    logger.info("Multicast notification dispatched.", {
      context,
      userId,
      tokenCount: tokens.length,
      successCount,
      failureCount,
    });
  }

  async function cleanupInvalidTokens(params: {
    userId: string;
    tokens: string[];
    responses: admin.messaging.SendResponse[];
    context: string;
  }): Promise<void> {
    const { userId, tokens, responses, context } = params;
    const cleanupTargets = responses
      .map((response, index) => ({
        response,
        token: tokens[index],
      }))
      .filter(({ response }) => !response.success && response.error);

    await Promise.all(
      cleanupTargets.map(async ({ response, token }) => {
        const errorCode = response.error?.code;
        if (!errorCode || !INVALID_TOKEN_ERROR_CODES.has(errorCode)) {
          logger.warn("Notification send failure.", {
            context,
            userId,
            token,
            errorCode,
          });
          return;
        }
        try {
          await firestore.doc(`users/${userId}/fcmTokens/${token}`).delete();
          logger.info("Removed invalid notification token.", {
            context,
            userId,
            token,
            errorCode,
          });
        } catch (error) {
          logger.error("Failed to remove invalid notification token.", {
            context,
            userId,
            token,
            errorCode,
            error,
          });
        }
      }),
    );
  }

  async function updateDriverAvailability(
    driverId: string,
    isAvailable: boolean,
  ): Promise<void> {
    const statusPayload = {
      isAvailable,
      updatedAt: FieldValue.serverTimestamp(),
    };
    enforceDriverStatusPayload({
      payload: statusPayload,
      context: "updateDriverAvailability",
    });
    await firestore
      .doc(`${DRIVER_STATUS_COLLECTION}/${driverId}`)
      .set(statusPayload, { merge: true });
    logger.info("Driver availability updated.", { driverId, isAvailable });
  }

  type DriverTripAction =
    | "set"
    | "cleared"
    | "skipped_other_trip"
    | "unchanged";

  async function updateDriverTripState(params: {
    tripId: string;
    driverId: string;
    vehicleId?: string;
    isBusy: boolean;
  }): Promise<void> {
    const { tripId, driverId, vehicleId, isBusy } = params;
    const driverRef = firestore.doc(`${DRIVER_STATUS_COLLECTION}/${driverId}`);
    const action = await firestore.runTransaction<DriverTripAction>(
      async (transaction) => {
        const snapshot = await transaction.get(driverRef);
        const data = snapshot.data() ?? {};
        const currentTripId =
          typeof data.currentTripId === "string" ? data.currentTripId : null;

        let transactionAction: DriverTripAction = "unchanged";

        if (isBusy) {
          if (currentTripId && currentTripId !== tripId) {
            transactionAction = "skipped_other_trip";
            return transactionAction;
          }
          transactionAction = "set";
          const updatePayload: Record<string, unknown> = {
            currentTripId: tripId,
            isBusy: true,
            updatedAt: FieldValue.serverTimestamp(),
          };
          if (vehicleId && data.vehicleId !== vehicleId) {
            updatePayload.vehicleId = vehicleId;
          }
          enforceDriverStatusPayload({
            payload: updatePayload,
            context: "updateDriverTripState.set",
          });
          transaction.set(driverRef, updatePayload, { merge: true });
          return transactionAction;
        }

        if (currentTripId && currentTripId !== tripId) {
          transactionAction = "skipped_other_trip";
          return transactionAction;
        }
        if (currentTripId !== null || data.isBusy === true) {
          transactionAction = "cleared";
        }
        const clearPayload = {
          currentTripId: FieldValue.delete(),
          isBusy: false,
          updatedAt: FieldValue.serverTimestamp(),
        };
        enforceDriverStatusPayload({
          payload: clearPayload,
          context: "updateDriverTripState.clear",
        });
        transaction.set(driverRef, clearPayload, { merge: true });
        return transactionAction;
      },
    );

    if (action === "skipped_other_trip") {
      logger.warn("Driver trip state not updated due to another active trip.", {
        driverId,
        tripId,
        isBusy,
      });
      return;
    }

    if (action === "set" || action === "cleared") {
      logger.info("Driver trip state updated.", {
        driverId,
        tripId,
        isBusy,
        action,
      });
    }
  }

  type ReassignmentResult = {
    attempted: boolean;
    assignedDriverId?: string;
    failureReason?: string;
  };

  async function assignNextDriverForTrip(params: {
    tripId: string;
    tripData: Record<string, unknown>;
    excludedDriverIds: string[];
  }): Promise<ReassignmentResult> {
    const { tripId, tripData, excludedDriverIds } = params;
    const pickupLocation = parseCoordinates(tripData.pickup);
    const destinationLocation = parseCoordinates(tripData.destination);
    if (!pickupLocation || !destinationLocation) {
      logger.error("Trip location missing for reassignment.", { tripId });
      return { attempted: false };
    }
    const availableDrivers = await fetchAvailableDrivers();
    const excluded = new Set(excludedDriverIds);
    const remainingDrivers = availableDrivers.filter(
      (driver) => !excluded.has(driver.driverId),
    );
    if (remainingDrivers.length === 0) {
      const reason = "no_remaining_available_drivers";
      logger.warn("No remaining drivers for reassignment.", {
        tripId,
        reason,
      });
      return { attempted: true, failureReason: reason };
    }
    const candidateResolution = await resolveDriverCandidates(
      remainingDrivers,
      pickupLocation,
    );
    const candidates = candidateResolution.candidates;
    if (candidates.length === 0) {
      const reason = buildNoLocationFailureReason(candidateResolution);
      logger.warn("No candidate locations for reassignment.", {
        tripId,
        reason,
        attemptedRadiiKm: candidateResolution.attemptedRadiiKm,
        nearbyUniqueCount: candidateResolution.nearbyUniqueCount,
        filteredOutByStatusCount: candidateResolution.filteredOutByStatusCount,
      });
      return { attempted: true, failureReason: reason };
    }
    const tripWindow = buildReservationWindow({
      start: new Date(),
      pickup: pickupLocation,
      destination: destinationLocation,
    });
    const vehicleSelection = await selectDriverVehicleCandidate({
      candidates,
      window: tripWindow,
      reservedAssignments: [],
    });
    const assignment = vehicleSelection.assignment;
    if (!assignment) {
      const reason = buildNoAssignableDriverReason(
        vehicleSelection.diagnostics,
      );
      logger.warn("No available driver/vehicle for reassignment.", {
        tripId,
        reason,
        diagnostics: vehicleSelection.diagnostics,
      });
      return { attempted: true, failureReason: reason };
    }

    const [driverSummary, vehicleSummary, driverContactSnapshot] =
      await Promise.all([
        fetchDriverSummary(assignment.id),
        fetchVehicleSummary(assignment.vehicleId),
        fetchDriverContactSnapshot(assignment.id),
      ]);
    const tripRef = firestore.doc(`trips/${tripId}`);
    const driverContactRef = firestore.doc(
      `trips/${tripId}/driverContactSnapshots/${tripId}`,
    );
    const updated = await firestore.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(tripRef);
      const currentStatus = normalizeTripStatus(snapshot.data()?.status);
      if (currentStatus !== "DRIVER_DECLINED") {
        logger.info("Trip no longer declined; reassignment skipped.", {
          tripId,
          currentStatus,
        });
        return false;
      }
      const previousAttempts =
        typeof snapshot.data()?.assignmentAttempts === "number"
          ? Number(snapshot.data()?.assignmentAttempts)
          : 0;
      const assignedAt = new Date();
      const tripUpdatePayload = {
        assignedDriverId: assignment.id,
        vehicleId: assignment.vehicleId,
        ...(driverSummary ? { driverSummary } : {}),
        ...(vehicleSummary ? { vehicleSummary } : {}),
        status: "DRIVER_ASSIGNED_WAITING_ACCEPTANCE",
        statusEnteredAt: Timestamp.fromDate(assignedAt),
        updatedAt: FieldValue.serverTimestamp(),
        driverAssignedAt: Timestamp.fromDate(assignedAt),
        assignmentAttempts: previousAttempts + 1,
      };
      enforceTripUpdatePayload({
        payload: tripUpdatePayload,
        context: "assignNextDriverForTrip",
      });
      transaction.update(tripRef, tripUpdatePayload);
      if (driverContactSnapshot) {
        transaction.set(driverContactRef, driverContactSnapshot, {
          merge: true,
        });
      } else {
        transaction.delete(driverContactRef);
      }
      return true;
    });
    if (!updated) {
      return { attempted: false };
    }
    logger.info("Trip reassigned to new driver.", {
      tripId,
      driverId: assignment.id,
    });
    return { attempted: true, assignedDriverId: assignment.id };
  }

  const sweepDriverAcceptanceTimeoutsJob = async (): Promise<void> => {
    const now = new Date();
    const cutoffMinuteKey = Math.floor(now.getTime() / 60000).toString();
    const operationId = `sweep_driver_acceptance_timeouts_${cutoffMinuteKey}`;
    const lockClaimed = await acquireOperationLock({
      operationId,
      operationType: "sweep_driver_acceptance_timeouts",
    });
    if (!lockClaimed) {
      return;
    }
    logger.info("Sweeping driver acceptance timeouts.", {
      now: now.toISOString(),
      operationId,
    });

    const snapshot = await firestore
      .collection("trips")
      .where("status", "==", "DRIVER_ASSIGNED_WAITING_ACCEPTANCE")
      .where(
        "pendingTasks.driverAcceptanceTimeoutAt",
        "<=",
        Timestamp.fromDate(now),
      )
      .limit(50)
      .get();

    if (snapshot.empty) {
      logger.info("No trips overdue for driver acceptance.");
      await completeOperationLock({ operationId, status: "completed" });
      return;
    }

    let operationError: Error | null = null;
    let recoveredCount = 0;
    try {
      for (const doc of snapshot.docs) {
        const tripId = doc.id;
        const tripData = doc.data() ?? {};
        const clientId = tripData.clientId?.toString();
        const assignedAt = parseTimestampToDate(tripData.driverAssignedAt);

        const didUpdate = await markTripNoDriversAvailableWithEvent({
          tripId,
          reason: "driver_timeout",
          expectedFromStatuses: ["DRIVER_ASSIGNED_WAITING_ACCEPTANCE"],
          driverAssignedAtNotAfter: now,
          expectedAssignedDriverId: tripData.assignedDriverId?.toString(),
          expectedAssignmentAttempt: normalizeAssignmentAttempt(
            tripData.assignmentAttempts,
          ),
          ...(assignedAt == null
            ? {}
            : { driverAssignedAtMillis: assignedAt.getTime() }),
        });

        if (!didUpdate) {
          continue;
        }
        recoveredCount += 1;

        logger.warn("Trip marked as no drivers available due to timeout.", {
          tripId,
        });
        if (clientId) {
          await notifyClientUnfulfilled(clientId, tripId, "driver_timeout");
        }
      }
      logger.info("cost_profile", {
        functionName: "sweepDriverAcceptanceTimeouts",
        operation: "fallback_sweep_recovered",
        recoveredCount,
        scannedCount: snapshot.size,
        operationId,
      });
    } catch (error) {
      operationError =
        error instanceof Error ? error : new Error("sweep_failed");
      throw error;
    } finally {
      await completeOperationLock({
        operationId,
        status: operationError ? "failed" : "completed",
        ...(operationError ? { errorMessage: operationError.message } : {}),
      });
    }
  };

  async function markTripUnfulfilled(
    tripId: string,
    clientId: string | undefined,
    reason: string,
  ): Promise<void> {
    await markTripNoDriversAvailable(tripId, clientId, reason);
  }

  async function markTripNoDriversAvailableWithEvent(params: {
    tripId: string;
    reason: string;
    expectedFromStatuses?: string[];
    driverAssignedAtNotAfter?: Date;
    driverAssignedAtMillis?: number;
    expectedAssignedDriverId?: string;
    expectedAssignmentAttempt?: number;
  }): Promise<boolean> {
    const {
      tripId,
      reason,
      expectedFromStatuses,
      driverAssignedAtNotAfter,
      driverAssignedAtMillis,
      expectedAssignedDriverId,
      expectedAssignmentAttempt,
    } = params;
    const tripRef = firestore.doc(`trips/${tripId}`);
    const eventRef = firestore
      .collection("tripEvents")
      .doc(tripId)
      .collection("events")
      .doc();
    return firestore.runTransaction(async (transaction) => {
      const tripSnapshot = await transaction.get(tripRef);
      const tripData = tripSnapshot.data();
      if (!tripData) {
        logger.warn("Trip missing while marking as no drivers available.", {
          tripId,
          reason,
        });
        return false;
      }
      const currentStatus = normalizeTripStatus(tripData.status);
      if (currentStatus === "NO_DRIVERS_AVAILABLE") {
        logger.info(
          "Trip already in NO_DRIVERS_AVAILABLE; skipping duplicate.",
          {
            tripId,
            reason,
          },
        );
        return false;
      }
      if (
        expectedFromStatuses &&
        expectedFromStatuses.length > 0 &&
        !expectedFromStatuses.includes(currentStatus)
      ) {
        logger.info("Trip status guard blocked no-drivers transition.", {
          tripId,
          reason,
          currentStatus,
          expectedFromStatuses,
        });
        return false;
      }
      if (driverAssignedAtNotAfter) {
        const assignedAt = parseTimestampToDate(tripData.driverAssignedAt);
        if (!assignedAt || assignedAt > driverAssignedAtNotAfter) {
          logger.info("Trip assignment timestamp guard blocked transition.", {
            tripId,
            reason,
            assignedAt: assignedAt?.toISOString() ?? null,
            cutoff: driverAssignedAtNotAfter.toISOString(),
          });
          return false;
        }
      }
      if (driverAssignedAtMillis != null) {
        const assignedAt = parseTimestampToDate(tripData.driverAssignedAt);
        if (!assignedAt || assignedAt.getTime() !== driverAssignedAtMillis) {
          logger.info(
            "Trip exact assignment timestamp guard blocked transition.",
            {
              tripId,
              reason,
              assignedAt: assignedAt?.toISOString() ?? null,
              expectedMillis: driverAssignedAtMillis,
            },
          );
          return false;
        }
      }
      if (
        expectedAssignedDriverId &&
        tripData.assignedDriverId?.toString() !== expectedAssignedDriverId
      ) {
        logger.info("Trip assigned driver guard blocked transition.", {
          tripId,
          reason,
          assignedDriverId: tripData.assignedDriverId?.toString() ?? null,
          expectedAssignedDriverId,
        });
        return false;
      }
      if (
        expectedAssignmentAttempt != null &&
        normalizeAssignmentAttempt(tripData.assignmentAttempts) !==
          expectedAssignmentAttempt
      ) {
        logger.info("Trip assignment attempt guard blocked transition.", {
          tripId,
          reason,
          assignmentAttempt: normalizeAssignmentAttempt(
            tripData.assignmentAttempts,
          ),
          expectedAssignmentAttempt,
        });
        return false;
      }
      const tripUpdatePayload = {
        status: "NO_DRIVERS_AVAILABLE",
        statusEnteredAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
        unfulfilledAt: FieldValue.serverTimestamp(),
        unfulfilledReason: reason,
        "pendingTasks.driverAcceptanceTimeoutKey":
          FieldValue.delete(),
        "pendingTasks.driverAcceptanceTimeoutAt":
          FieldValue.delete(),
      };
      enforceTripUpdatePayload({
        payload: tripUpdatePayload,
        context: "markTripNoDriversAvailableWithEvent.update",
      });
      transaction.update(tripRef, tripUpdatePayload);

      const eventPayload = buildTripStateTransitionEventPayload({
        fromStatus: currentStatus,
        toStatus: "NO_DRIVERS_AVAILABLE",
        actorId: "system",
        metadata: { reason },
      });
      enforceTripEventPayload({
        payload: eventPayload,
        context: "markTripNoDriversAvailableWithEvent.event",
      });
      transaction.set(eventRef, eventPayload);
      return true;
    });
  }

  async function markTripNoDriversAvailable(
    tripId: string,
    clientId: string | undefined,
    reason: string,
  ): Promise<void> {
    const didUpdate = await markTripNoDriversAvailableWithEvent({
      tripId,
      reason,
    });
    if (!didUpdate) {
      return;
    }
    logger.warn("Trip marked as no drivers available.", { tripId, reason });
    if (clientId) {
      await notifyClientUnfulfilled(clientId, tripId, reason);
    }
  }

  return {
    requestTrip,
    confirmTripPackageBooking,
    cancelTripPackageBooking,
    cancelTripPackageReturnLeg,
    activateTripPackageLeg,
    processDriverAcceptanceTimeout,
    processPostChargeExtensionNextAction,
    createPackageCoveredTripFromReservation,
    assignDriverOnTripCreation,
    syncDriverVehicleAssignment,
    handleTripStatusUpdates,
    finalizeTripOnCompletion,
    retryTripPayment,
    transitionTripState,
    cancelTrip,
    requestTripExtension,
    respondTripExtension,
    closeTripExtensionFlow,
    endTripExtensionEarly,
    handleTripFinancialAction,
    autoCompleteTripExtensionWindow,
    notifyDriverOnAdminEventCreation,
    syncDriversPublicProfile,
    syncDriversPublicVehicle,
    syncNotificationTargetToken,
    activateReservationsForDayJob,
    sendScheduledEventNotificationsJob,
    monitorDriverHeartbeatJob,
    pruneStaleFcmTokensJob,
    sweepDriverAcceptanceTimeoutsJob,
    sweepPostChargeTripExtensionsJob,
  };
}
