import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/trip_packages/data/mappers/trip_package_booking_firestore_mapper.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_booking.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_booking_approval.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_cancellation.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_ops_issue_code.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_ops_queue_bucket.dart';

void main() {
  group('TripPackageBookingFirestoreMapper', () {
    const mapper = TripPackageBookingFirestoreMapper();

    test('maps a commercial booking document with authoritative snapshots', () {
      final scheduledAt = Timestamp.fromDate(DateTime.utc(2026, 4, 10, 9));
      final cancellationClosesAt = Timestamp.fromDate(
        DateTime.utc(2026, 4, 10, 8),
      );
      final createdAt = Timestamp.fromDate(DateTime.utc(2026, 4, 1, 10));

      final booking = mapper.fromBookingJson(<String, dynamic>{
        'clientId': 'client-1',
        'packageId': 'package-1',
        'reservationId': 'reservation-1',
        'tripId': 'trip-1',
        'assignedDriverId': 'driver-1',
        'assignedVehicleId': 'vehicle-1',
        'packageSnapshot': <String, dynamic>{
          'packageId': 'package-1',
          'snapshotVersion': 3,
          'name': 'Tarrafal',
          'photoUrl': 'https://example.com/tarrafal.jpg',
          'description': 'Praia e dia relaxado.',
          'destination': <String, dynamic>{
            'latitude': 15.2788,
            'longitude': -23.7519,
            'address': 'Tarrafal',
          },
          'price': <String, dynamic>{
            'amountMinor': 2500,
            'currency': 'EUR',
          },
          'allowedTransportTypes': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'standard',
              'name': 'Standard',
              'packagePriceMultiplierBasisPoints': 10000,
            },
            <String, dynamic>{
              'id': 'van',
              'name': 'Van',
              'packagePriceMultiplierBasisPoints': 12500,
            },
          ],
        },
        'pickup': <String, dynamic>{
          'latitude': 14.9177,
          'longitude': -23.5092,
          'address': 'Praia',
        },
        'destinationSnapshot': <String, dynamic>{
          'latitude': 15.2788,
          'longitude': -23.7519,
          'address': 'Tarrafal',
        },
        'scheduledAt': scheduledAt,
        'transportType': <String, dynamic>{
          'id': 'van',
          'name': 'Van',
          'packagePriceMultiplierBasisPoints': 12500,
        },
        'price': <String, dynamic>{
          'amountMinor': 2500,
          'currency': 'EUR',
        },
        'priceAdjustmentMinor': 625,
        'clientCancellationClosesAt': cancellationClosesAt,
        'status': 'cancelled',
        'refundStatus': 'full',
        'chargedAmount': <String, dynamic>{
          'amountMinor': 2500,
          'currency': 'EUR',
        },
        'refundedAmount': <String, dynamic>{
          'amountMinor': 2500,
          'currency': 'EUR',
        },
        'approval': <String, dynamic>{
          'requestedAt': Timestamp.fromDate(DateTime.utc(2026, 4, 1, 10)),
          'decidedAt': Timestamp.fromDate(DateTime.utc(2026, 4, 1, 11)),
          'decidedByUserId': 'manager-1',
          'decidedByRole': 'manager',
          'decision': 'rejected',
          'reason': 'Capacidade operacional indisponível.',
        },
        'assignmentStatus': 'assigned',
        'assignmentWindowStartsAt': Timestamp.fromDate(
          DateTime.utc(2026, 4, 10, 8),
        ),
        'nextAssignmentAttemptAt': null,
        'lastAssignmentAttemptAt': Timestamp.fromDate(
          DateTime.utc(2026, 4, 10, 8, 5),
        ),
        'opsQueueBucket': 'finalized',
        'opsNextActionAt': Timestamp.fromDate(DateTime.utc(2026, 4, 10, 8, 30)),
        'opsIsActionable': false,
        'opsLastIssueCode': 'activation_creation_failed',
        'assignmentAttemptsCount': 2,
        'cancellation': <String, dynamic>{
          'reasonCode': 'admin_cancelled',
          'reasonLabel': 'Cancelado pela equipa de suporte.',
          'cancelledBy': 'manager-1',
          'cancelledAt': Timestamp.fromDate(DateTime.utc(2026, 4, 9, 17)),
        },
        'createdAt': createdAt,
        'updatedAt': createdAt,
      }, id: 'booking-1');

      expect(booking.id, 'booking-1');
      expect(booking.status, TripPackageBookingStatus.cancelled);
      expect(booking.refundStatus, TripPackageRefundStatus.full);
      expect(booking.packageSnapshot.name, 'Tarrafal');
      expect(booking.pickup.address, 'Praia');
      expect(booking.destinationSnapshot.address, 'Tarrafal');
      expect(booking.transportType.id, 'van');
      expect(booking.transportType.packagePriceMultiplierBasisPoints, 12500);
      expect(booking.priceAdjustmentMinor, 625);
      expect(booking.assignedDriverId, 'driver-1');
      expect(booking.assignedVehicleId, 'vehicle-1');
      expect(
        booking.assignmentStatus,
        TripPackageBookingAssignmentStatus.assigned,
      );
      expect(
        booking.approval.decision,
        TripPackageBookingApprovalDecision.rejected,
      );
      expect(booking.opsQueueBucket, TripPackageOpsQueueBucket.finalized);
      expect(
        booking.opsLastIssueCode,
        TripPackageOpsIssueCode.activationCreationFailed,
      );
      expect(booking.assignmentAttemptsCount, 2);
      expect(
        booking.clientCancellationClosesAt.toUtc(),
        DateTime.utc(2026, 4, 10, 8),
      );
      expect(
        booking.cancellation?.reasonCode,
        TripPackageCancellationReasonCode.adminCancelled,
      );
      expect(
        booking.cancellation?.reasonLabel,
        'Cancelado pela equipa de suporte.',
      );
    });

    test('normalizes legacy confirmed bookings into approved', () {
      final booking = mapper.fromBookingJson(<String, dynamic>{
        'clientId': 'client-1',
        'packageId': 'package-1',
        'reservationId': 'reservation-1',
        'packageSnapshot': <String, dynamic>{
          'packageId': 'package-1',
          'snapshotVersion': 3,
          'name': 'Tarrafal',
          'photoUrl': 'https://example.com/tarrafal.jpg',
          'description': 'Praia e dia relaxado.',
          'destination': <String, dynamic>{
            'latitude': 15.2788,
            'longitude': -23.7519,
            'address': 'Tarrafal',
          },
          'price': <String, dynamic>{
            'amountMinor': 2500,
            'currency': 'EUR',
          },
          'allowedTransportTypes': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'standard',
              'name': 'Standard',
              'packagePriceMultiplierBasisPoints': 10000,
            },
          ],
        },
        'pickup': <String, dynamic>{
          'latitude': 14.9177,
          'longitude': -23.5092,
          'address': 'Praia',
        },
        'destinationSnapshot': <String, dynamic>{
          'latitude': 15.2788,
          'longitude': -23.7519,
          'address': 'Tarrafal',
        },
        'scheduledAt': Timestamp.fromDate(DateTime.utc(2026, 4, 10, 9)),
        'transportType': <String, dynamic>{
          'id': 'standard',
          'name': 'Standard',
          'packagePriceMultiplierBasisPoints': 10000,
        },
        'price': <String, dynamic>{
          'amountMinor': 2500,
          'currency': 'EUR',
        },
        'priceAdjustmentMinor': 0,
        'clientCancellationClosesAt': Timestamp.fromDate(
          DateTime.utc(2026, 4, 10, 8),
        ),
        'status': 'confirmed',
        'refundStatus': 'none',
        'chargedAmount': <String, dynamic>{
          'amountMinor': 2500,
          'currency': 'EUR',
        },
        'refundedAmount': <String, dynamic>{
          'amountMinor': 0,
          'currency': 'EUR',
        },
      }, id: 'booking-legacy');

      expect(booking.status, TripPackageBookingStatus.approved);
    });
  });
}
