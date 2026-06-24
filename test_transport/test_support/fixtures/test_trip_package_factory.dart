import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_booking.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_booking_approval.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_cancellation.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_ops_issue_code.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_ops_queue_bucket.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_snapshot.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_transport_snapshot.dart';
import 'package:local_transport/features/trips/domain/entities/trip_location.dart';

TripPackage buildTestTripPackage({
  String id = 'package-1',
  String name = 'Cachoeira',
  String description =
      'Experiencia de dia inteiro com trilhos e paragens guiadas.',
  bool isActive = true,
  DateTime? archivedAt,
}) {
  return TripPackage(
    id: id,
    name: name,
    photoUrl: 'https://example.com/package.jpg',
    description: description,
    destination: _destination(),
    price: const Money(amountMinor: 2500, currency: CurrencyCode.eur),
    allowedTransportTypes: _allowedTransportTypes(),
    isActive: isActive,
    snapshotVersion: 3,
    archivedAt: archivedAt,
  );
}

TripPackageBooking buildTestTripPackageBooking({
  String id = 'booking-1',
  String clientId = 'client-1',
  String packageId = 'package-1',
  String reservationId = 'reservation-1',
  String? tripId,
  String? assignedDriverId,
  String? assignedVehicleId,
  TripPackageBookingStatus status = TripPackageBookingStatus.approved,
  TripPackageRefundStatus refundStatus = TripPackageRefundStatus.none,
  TripPackageBookingAssignmentStatus assignmentStatus =
      TripPackageBookingAssignmentStatus.pending,
  TripPackageBookingApproval? approval,
  TripPackageOpsQueueBucket? opsQueueBucket,
  bool? opsIsActionable,
  DateTime? opsNextActionAt,
  TripPackageOpsIssueCode opsLastIssueCode = TripPackageOpsIssueCode.none,
  TripPackageCancellation? cancellation,
  DateTime? scheduledAt,
  DateTime? clientCancellationClosesAt,
  DateTime? assignmentWindowStartsAt,
  DateTime? nextAssignmentAttemptAt,
  DateTime? lastAssignmentAttemptAt,
  int assignmentAttemptsCount = 0,
}) {
  final bookingScheduledAt = scheduledAt ?? DateTime.utc(2026, 4, 4, 9, 0);
  return TripPackageBooking(
    id: id,
    clientId: clientId,
    packageId: packageId,
    reservationId: reservationId,
    tripId: tripId,
    assignedDriverId: assignedDriverId,
    assignedVehicleId: assignedVehicleId,
    assignmentStatus: assignmentStatus,
    packageSnapshot: buildTestTripPackageSnapshot(packageId: packageId),
    pickup: _pickup(),
    destinationSnapshot: _destination(),
    scheduledAt: bookingScheduledAt,
    transportType: _allowedTransportTypes().first,
    price: const Money(amountMinor: 2500, currency: CurrencyCode.eur),
    priceAdjustmentMinor: 0,
    clientCancellationClosesAt:
        clientCancellationClosesAt ??
        bookingScheduledAt.subtract(const Duration(hours: 1)),
    status: status,
    refundStatus: refundStatus,
    chargedAmount: const Money(amountMinor: 2500, currency: CurrencyCode.eur),
    refundedAmount: refundStatus == TripPackageRefundStatus.full
        ? const Money(amountMinor: 2500, currency: CurrencyCode.eur)
        : const Money(amountMinor: 0, currency: CurrencyCode.eur),
    approval: approval ?? _defaultApprovalForStatus(status),
    opsQueueBucket: opsQueueBucket ?? _defaultOpsQueueBucketForStatus(status),
    opsIsActionable: opsIsActionable ?? _defaultActionableForStatus(status),
    assignmentWindowStartsAt:
        assignmentWindowStartsAt ??
        bookingScheduledAt.subtract(const Duration(hours: 1)),
    nextAssignmentAttemptAt: nextAssignmentAttemptAt,
    lastAssignmentAttemptAt: lastAssignmentAttemptAt,
    opsNextActionAt: opsNextActionAt,
    opsLastIssueCode: opsLastIssueCode,
    assignmentAttemptsCount: assignmentAttemptsCount,
    cancellation: cancellation,
  );
}

TripPackageSnapshot buildTestTripPackageSnapshot({
  String packageId = 'package-1',
}) {
  return TripPackageSnapshot(
    packageId: packageId,
    snapshotVersion: 3,
    name: 'Cachoeira',
    photoUrl: 'https://example.com/package.jpg',
    description: 'Experiencia de dia inteiro com trilhos e paragens guiadas.',
    destination: _destination(),
    price: const Money(amountMinor: 2500, currency: CurrencyCode.eur),
    allowedTransportTypes: _allowedTransportTypes(),
  );
}

List<TripPackageTransportSnapshot> _allowedTransportTypes() {
  return const <TripPackageTransportSnapshot>[
    TripPackageTransportSnapshot(
      id: 'standard',
      name: 'Standard',
      packagePriceMultiplierBasisPoints: 10000,
    ),
    TripPackageTransportSnapshot(
      id: 'van',
      name: 'Van',
      packagePriceMultiplierBasisPoints: 12500,
    ),
  ];
}

TripLocation _pickup() {
  return const TripLocation(
    latitude: 14.9177,
    longitude: -23.5092,
    address: 'Praia',
  );
}

TripLocation _destination() {
  return const TripLocation(
    latitude: 15.2788,
    longitude: -23.7519,
    address: 'Tarrafal',
  );
}

TripPackageBookingApproval _defaultApprovalForStatus(
  TripPackageBookingStatus status,
) {
  switch (status) {
    case TripPackageBookingStatus.pendingApproval:
      return TripPackageBookingApproval(
        requestedAt: DateTime.utc(2026, 4, 1, 9),
        decidedAt: null,
        decidedByUserId: null,
        decidedByRole: null,
        decision: TripPackageBookingApprovalDecision.pending,
        reason: null,
      );
    case TripPackageBookingStatus.rejected:
      return TripPackageBookingApproval(
        requestedAt: DateTime.utc(2026, 4, 1, 9),
        decidedAt: DateTime.utc(2026, 4, 1, 9, 30),
        decidedByUserId: 'manager-1',
        decidedByRole: 'manager',
        decision: TripPackageBookingApprovalDecision.rejected,
        reason: 'Capacidade operacional indisponível.',
      );
    case TripPackageBookingStatus.approved:
    case TripPackageBookingStatus.awaitingDriverAcceptance:
    case TripPackageBookingStatus.driverAssigned:
    case TripPackageBookingStatus.activationInProgress:
    case TripPackageBookingStatus.cancelled:
    case TripPackageBookingStatus.completed:
      return TripPackageBookingApproval(
        requestedAt: DateTime.utc(2026, 4, 1, 9),
        decidedAt: DateTime.utc(2026, 4, 1, 9, 30),
        decidedByUserId: 'manager-1',
        decidedByRole: 'manager',
        decision: TripPackageBookingApprovalDecision.approved,
        reason: null,
      );
  }
}

TripPackageOpsQueueBucket _defaultOpsQueueBucketForStatus(
  TripPackageBookingStatus status,
) {
  switch (status) {
    case TripPackageBookingStatus.pendingApproval:
      return TripPackageOpsQueueBucket.pendingApproval;
    case TripPackageBookingStatus.approved:
      return TripPackageOpsQueueBucket.approvedWaitingOpsWindow;
    case TripPackageBookingStatus.awaitingDriverAcceptance:
    case TripPackageBookingStatus.driverAssigned:
    case TripPackageBookingStatus.activationInProgress:
      return TripPackageOpsQueueBucket.awaitingDriverAcceptance;
    case TripPackageBookingStatus.cancelled:
    case TripPackageBookingStatus.rejected:
    case TripPackageBookingStatus.completed:
      return TripPackageOpsQueueBucket.finalized;
  }
}

bool _defaultActionableForStatus(TripPackageBookingStatus status) {
  switch (status) {
    case TripPackageBookingStatus.awaitingDriverAcceptance:
    case TripPackageBookingStatus.driverAssigned:
    case TripPackageBookingStatus.activationInProgress:
      return true;
    case TripPackageBookingStatus.pendingApproval:
    case TripPackageBookingStatus.approved:
    case TripPackageBookingStatus.cancelled:
    case TripPackageBookingStatus.rejected:
    case TripPackageBookingStatus.completed:
      return false;
  }
}
