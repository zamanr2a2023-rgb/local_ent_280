import {
  TRIP_PACKAGE_ACTIVATION_LEAD_MINUTES,
  TRIP_PACKAGE_APPROVAL_DECISIONS,
  TRIP_PACKAGE_ASSIGNMENT_RETRY_MINUTES,
  TRIP_PACKAGE_ASSIGNMENT_WINDOW_LEAD_MINUTES,
  TRIP_PACKAGE_BOOKING_STATUSES,
  TRIP_PACKAGE_CANCELLATION_REASON_CODES,
  TRIP_PACKAGE_CLIENT_CANCELLATION_WINDOW_MINUTES,
  TRIP_PACKAGE_MIN_BOOKING_LEAD_MINUTES,
  TRIP_PACKAGE_OPERATION_TIMEZONE,
  TRIP_PACKAGE_OPS_ISSUE_CODES,
  TRIP_PACKAGE_OPS_QUEUE_BUCKETS,
  buildTripPackageActivationAt,
  buildNextTripPackageAssignmentAttemptAt,
  buildTripPackageAssignmentWindowStartsAt,
  buildTripPackageBookingOperationId,
  buildTripPackageBookingRequestHash,
  buildTripPackageChargeLedgerId,
  buildTripPackageClientCancellationClosesAt,
  deriveTripPackageOpsQueueBucket,
  buildTripPackageRefundLedgerId,
  buildTripPackageTripId,
  canClientCancelTripPackageBooking,
  isTripPackageBookingActionable,
  isTripPackageBookingTerminal,
  isTripPackagePurchaseAllowed,
  normalizeTripPackageBookingStatus,
} from "./tripPackagePolicy";

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function testCanonicalConstants(): void {
  assert(
    TRIP_PACKAGE_OPERATION_TIMEZONE === "Europe/Lisbon",
    "Expected package timezone to be Europe/Lisbon.",
  );
  assert(
    TRIP_PACKAGE_MIN_BOOKING_LEAD_MINUTES === 15,
    "Expected 15 minutes booking lead time.",
  );
  assert(
    TRIP_PACKAGE_ASSIGNMENT_WINDOW_LEAD_MINUTES === 60,
    "Expected 60 minutes assignment window lead.",
  );
  assert(
    TRIP_PACKAGE_ASSIGNMENT_RETRY_MINUTES === 15,
    "Expected 15 minutes assignment retry interval.",
  );
  assert(
    TRIP_PACKAGE_CLIENT_CANCELLATION_WINDOW_MINUTES === 60,
    "Expected 60 minutes cancellation window.",
  );
  assert(
    TRIP_PACKAGE_ACTIVATION_LEAD_MINUTES === 15,
    "Expected 15 minutes trip activation lead.",
  );
  assert(
    TRIP_PACKAGE_CANCELLATION_REASON_CODES.operationalPreExecutionFailed ===
      "operational_pre_execution_failed",
    "Expected canonical operational failure code.",
  );
  assert(
    TRIP_PACKAGE_BOOKING_STATUSES.pendingApproval === "pending_approval",
    "Expected governed pending approval booking state.",
  );
  assert(
    TRIP_PACKAGE_APPROVAL_DECISIONS.approved === "approved",
    "Expected canonical approval decision.",
  );
  assert(
    TRIP_PACKAGE_OPS_QUEUE_BUCKETS.activationIssues === "activation_issues",
    "Expected canonical activation issues queue bucket.",
  );
  assert(
    TRIP_PACKAGE_OPS_ISSUE_CODES.activationCreationFailed ===
      "activation_creation_failed",
    "Expected canonical activation creation failure code.",
  );
}

function testThresholds(): void {
  const scheduledAt = new Date("2026-06-01T10:00:00.000Z");

  assert(
    buildTripPackageAssignmentWindowStartsAt(scheduledAt).toISOString() ===
      "2026-06-01T09:00:00.000Z",
    "Expected assignment window start at scheduledAt - 60 minutes.",
  );
  assert(
    buildTripPackageActivationAt(scheduledAt).toISOString() ===
      "2026-06-01T09:45:00.000Z",
    "Expected activation at scheduledAt - 15 minutes.",
  );
  assert(
    buildNextTripPackageAssignmentAttemptAt(
      new Date("2026-06-01T09:00:00.000Z"),
    ).toISOString() === "2026-06-01T09:15:00.000Z",
    "Expected next assignment attempt after 15 minutes.",
  );
  assert(
    buildTripPackageClientCancellationClosesAt(scheduledAt).toISOString() ===
      "2026-06-01T09:00:00.000Z",
    "Expected client cancellation cutoff at scheduledAt - 1 hour.",
  );
}

function testPolicies(): void {
  const now = new Date("2026-06-01T09:00:00.000Z");

  assert(
    isTripPackagePurchaseAllowed({
      scheduledAt: new Date("2026-06-01T09:15:00.000Z"),
      now,
    }),
    "Expected purchase to be allowed exactly at the lead threshold.",
  );
  assert(
    !isTripPackagePurchaseAllowed({
      scheduledAt: new Date("2026-06-01T09:14:59.000Z"),
      now,
    }),
    "Expected purchase to be rejected before the lead threshold.",
  );
  assert(
    canClientCancelTripPackageBooking({
      clientCancellationClosesAt: new Date("2026-06-01T10:00:00.000Z"),
      now,
    }),
    "Expected client cancellation before cutoff.",
  );
  assert(
    !canClientCancelTripPackageBooking({
      clientCancellationClosesAt: new Date("2026-06-01T09:00:00.000Z"),
      now,
    }),
    "Expected cancellation to close exactly at cutoff.",
  );
}

function testDeterministicIdentifiers(): void {
  assert(
    buildTripPackageChargeLedgerId("booking_1") ===
      "trip_package_booking_booking_1_charge",
    "Expected deterministic charge ledger id.",
  );
  assert(
    buildTripPackageRefundLedgerId("booking_1") ===
      "trip_package_booking_booking_1_refund_full",
    "Expected deterministic refund ledger id.",
  );
  assert(
    buildTripPackageTripId("booking 1") === "pkg_booking_1",
    "Expected deterministic trip id sanitization.",
  );
  assert(
    buildTripPackageBookingOperationId({
      clientId: "client 1",
      idempotencyKey: "idem key",
    }) ===
      "trip_package_booking_operation_client_1_idem_key",
    "Expected deterministic operation id sanitization.",
  );
  assert(
    buildTripPackageBookingRequestHash({
      packageId: "package_1",
      scheduledAt: "2026-06-01T10:00:00.000Z",
    }).length === 64,
    "Expected SHA-256 request hash.",
  );
}

function testGovernedLifecycleHelpers(): void {
  assert(
    normalizeTripPackageBookingStatus("confirmed") ===
      TRIP_PACKAGE_BOOKING_STATUSES.approved,
    "Expected legacy confirmed status to normalize to approved.",
  );
  assert(
    !isTripPackageBookingActionable(TRIP_PACKAGE_BOOKING_STATUSES.approved),
    "Approved should not be actionable before the ops window.",
  );
  assert(
    isTripPackageBookingActionable(
      TRIP_PACKAGE_BOOKING_STATUSES.awaitingDriverAcceptance,
    ),
    "Awaiting driver acceptance should be actionable.",
  );
  assert(
    isTripPackageBookingTerminal(TRIP_PACKAGE_BOOKING_STATUSES.rejected),
    "Rejected should be terminal.",
  );
  assert(
    deriveTripPackageOpsQueueBucket({
      status: TRIP_PACKAGE_BOOKING_STATUSES.pendingApproval,
      opsLastIssueCode: null,
    }) === TRIP_PACKAGE_OPS_QUEUE_BUCKETS.pendingApproval,
    "Expected pending approval bucket.",
  );
  assert(
    deriveTripPackageOpsQueueBucket({
      status: TRIP_PACKAGE_BOOKING_STATUSES.approved,
      opsLastIssueCode: null,
    }) === TRIP_PACKAGE_OPS_QUEUE_BUCKETS.approvedWaitingOpsWindow,
    "Expected approved waiting ops bucket.",
  );
  assert(
    deriveTripPackageOpsQueueBucket({
      status: TRIP_PACKAGE_BOOKING_STATUSES.driverAssigned,
      opsLastIssueCode: TRIP_PACKAGE_OPS_ISSUE_CODES.noEligibleDriversFound,
    }) === TRIP_PACKAGE_OPS_QUEUE_BUCKETS.activationIssues,
    "Expected activation issues bucket when an issue code is present.",
  );
}

async function main(): Promise<void> {
  testCanonicalConstants();
  testThresholds();
  testPolicies();
  testDeterministicIdentifiers();
  testGovernedLifecycleHelpers();
  // eslint-disable-next-line no-console
  console.log("tripPackagePolicy tests passed.");
}

main().catch((error) => {
  // eslint-disable-next-line no-console
  console.error(error);
  throw error;
});
