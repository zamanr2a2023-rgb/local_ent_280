import { createHash } from "node:crypto";

export const TRIP_PACKAGE_OPERATION_TIMEZONE = "Europe/Lisbon";
export const TRIP_PACKAGE_MIN_BOOKING_LEAD_MINUTES = 15;
export const TRIP_PACKAGE_CLIENT_CANCELLATION_WINDOW_MINUTES = 60;
export const TRIP_PACKAGE_ASSIGNMENT_WINDOW_LEAD_MINUTES = 60;
export const TRIP_PACKAGE_ASSIGNMENT_RETRY_MINUTES = 15;
export const TRIP_PACKAGE_ACTIVATION_LEAD_MINUTES = 15;

export const TRIP_PACKAGE_BOOKING_STATUSES = {
  pendingApproval: "pending_approval",
  approved: "approved",
  awaitingDriverAcceptance: "awaiting_driver_acceptance",
  driverAssigned: "driver_assigned",
  activationInProgress: "activation_in_progress",
  cancelled: "cancelled",
  rejected: "rejected",
  completed: "completed",
} as const;

export type TripPackageBookingStatus =
  (typeof TRIP_PACKAGE_BOOKING_STATUSES)[keyof typeof TRIP_PACKAGE_BOOKING_STATUSES];

export const LEGACY_TRIP_PACKAGE_BOOKING_STATUS_ALIASES = {
  confirmed: "confirmed",
} as const;

export const TRIP_PACKAGE_APPROVAL_DECISIONS = {
  pending: "pending",
  approved: "approved",
  rejected: "rejected",
} as const;

export type TripPackageApprovalDecision =
  (typeof TRIP_PACKAGE_APPROVAL_DECISIONS)[keyof typeof TRIP_PACKAGE_APPROVAL_DECISIONS];

export const TRIP_PACKAGE_OPS_QUEUE_BUCKETS = {
  pendingApproval: "pending_approval",
  approvedWaitingOpsWindow: "approved_waiting_ops_window",
  awaitingDriverAcceptance: "awaiting_driver_acceptance",
  activationIssues: "activation_issues",
  finalized: "finalized",
} as const;

export type TripPackageOpsQueueBucket =
  (typeof TRIP_PACKAGE_OPS_QUEUE_BUCKETS)[keyof typeof TRIP_PACKAGE_OPS_QUEUE_BUCKETS];

export const TRIP_PACKAGE_OPS_ISSUE_CODES = {
  noEligibleDriversFound: "no_eligible_drivers_found",
  driverAcceptanceTimedOut: "driver_acceptance_timed_out",
  driverAcceptanceDeclinedAll: "driver_acceptance_declined_all",
  activationWindowMissed: "activation_window_missed",
  activationCreationFailed: "activation_creation_failed",
  operationalPreExecutionFailed: "operational_pre_execution_failed",
} as const;

export type TripPackageOpsIssueCode =
  (typeof TRIP_PACKAGE_OPS_ISSUE_CODES)[keyof typeof TRIP_PACKAGE_OPS_ISSUE_CODES];

export const TRIP_PACKAGE_REFUND_STATUSES = {
  none: "none",
  full: "full",
} as const;

export type TripPackageRefundStatus =
  (typeof TRIP_PACKAGE_REFUND_STATUSES)[keyof typeof TRIP_PACKAGE_REFUND_STATUSES];

export const TRIP_PACKAGE_CANCELLATION_REASON_CODES = {
  clientCancelled: "client_cancelled",
  operationalPreExecutionFailed: "operational_pre_execution_failed",
  adminCancelled: "admin_cancelled",
  packageDeleted: "package_deleted",
} as const;

export type TripPackageCancellationReasonCode =
  (typeof TRIP_PACKAGE_CANCELLATION_REASON_CODES)[
    keyof typeof TRIP_PACKAGE_CANCELLATION_REASON_CODES
  ];

export function normalizeTripPackageBookingStatus(
  status: string,
): TripPackageBookingStatus {
  if (status === LEGACY_TRIP_PACKAGE_BOOKING_STATUS_ALIASES.confirmed) {
    return TRIP_PACKAGE_BOOKING_STATUSES.approved;
  }
  const values = Object.values(TRIP_PACKAGE_BOOKING_STATUSES);
  if (values.includes(status as TripPackageBookingStatus)) {
    return status as TripPackageBookingStatus;
  }
  throw new Error(`Estado de booking inválido: ${status}`);
}

export function isTripPackageBookingTerminal(
  status: TripPackageBookingStatus,
): boolean {
  return (
    status === TRIP_PACKAGE_BOOKING_STATUSES.cancelled ||
    status === TRIP_PACKAGE_BOOKING_STATUSES.rejected ||
    status === TRIP_PACKAGE_BOOKING_STATUSES.completed
  );
}

export function isTripPackageBookingActionable(
  status: TripPackageBookingStatus,
): boolean {
  return (
    status === TRIP_PACKAGE_BOOKING_STATUSES.awaitingDriverAcceptance ||
    status === TRIP_PACKAGE_BOOKING_STATUSES.driverAssigned ||
    status === TRIP_PACKAGE_BOOKING_STATUSES.activationInProgress
  );
}

export function deriveTripPackageOpsQueueBucket(params: {
  status: TripPackageBookingStatus;
  opsLastIssueCode: TripPackageOpsIssueCode | null;
}): TripPackageOpsQueueBucket {
  const { status, opsLastIssueCode } = params;
  if (isTripPackageBookingTerminal(status)) {
    return TRIP_PACKAGE_OPS_QUEUE_BUCKETS.finalized;
  }
  if (status === TRIP_PACKAGE_BOOKING_STATUSES.pendingApproval) {
    return TRIP_PACKAGE_OPS_QUEUE_BUCKETS.pendingApproval;
  }
  if (status === TRIP_PACKAGE_BOOKING_STATUSES.approved) {
    return TRIP_PACKAGE_OPS_QUEUE_BUCKETS.approvedWaitingOpsWindow;
  }
  if (opsLastIssueCode != null) {
    return TRIP_PACKAGE_OPS_QUEUE_BUCKETS.activationIssues;
  }
  return TRIP_PACKAGE_OPS_QUEUE_BUCKETS.awaitingDriverAcceptance;
}

export function buildTripPackageAssignmentWindowStartsAt(
  scheduledAt: Date,
): Date {
  return new Date(
    scheduledAt.getTime() -
      TRIP_PACKAGE_ASSIGNMENT_WINDOW_LEAD_MINUTES * 60 * 1000,
  );
}

export function buildTripPackageActivationAt(scheduledAt: Date): Date {
  return new Date(
    scheduledAt.getTime() - TRIP_PACKAGE_ACTIVATION_LEAD_MINUTES * 60 * 1000,
  );
}

export function buildNextTripPackageAssignmentAttemptAt(
  baseAt: Date,
): Date {
  return new Date(
    baseAt.getTime() + TRIP_PACKAGE_ASSIGNMENT_RETRY_MINUTES * 60 * 1000,
  );
}

export function buildTripPackageClientCancellationClosesAt(
  scheduledAt: Date,
): Date {
  return new Date(
    scheduledAt.getTime() -
      TRIP_PACKAGE_CLIENT_CANCELLATION_WINDOW_MINUTES * 60 * 1000,
  );
}

export function isTripPackagePurchaseAllowed(params: {
  scheduledAt: Date;
  now: Date;
}): boolean {
  const { scheduledAt, now } = params;
  return (
    scheduledAt.getTime() >=
    now.getTime() + TRIP_PACKAGE_MIN_BOOKING_LEAD_MINUTES * 60 * 1000
  );
}

export function canClientCancelTripPackageBooking(params: {
  clientCancellationClosesAt: Date;
  now: Date;
}): boolean {
  const { clientCancellationClosesAt, now } = params;
  return now.getTime() < clientCancellationClosesAt.getTime();
}

export function buildTripPackageBookingOperationId(params: {
  clientId: string;
  idempotencyKey: string;
}): string {
  const { clientId, idempotencyKey } = params;
  return (
    `trip_package_booking_operation_${sanitizeIdSegment(clientId)}_` +
    sanitizeIdSegment(idempotencyKey)
  );
}

export function buildTripPackageBookingRequestHash(value: unknown): string {
  return createHash("sha256").update(JSON.stringify(value)).digest("hex");
}

export function buildTripPackageChargeLedgerId(bookingId: string): string {
  return `trip_package_booking_${bookingId}_charge`;
}

export function buildTripPackageRefundLedgerId(bookingId: string): string {
  return `trip_package_booking_${bookingId}_refund_full`;
}

export function buildTripPackageTripId(bookingId: string): string {
  return `pkg_${sanitizeIdSegment(bookingId)}`;
}

function sanitizeIdSegment(value: string): string {
  return value.trim().replace(/[^a-zA-Z0-9:_-]/g, "_");
}
