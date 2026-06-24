import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/trips/data/mappers/trip_firestore_mapper.dart';
import 'package:local_transport/features/trips/domain/entities/trip.dart';
import 'package:local_transport/features/trips/domain/entities/trip_extension_request.dart';
import 'package:local_transport/features/trips/domain/entities/trip_extension_status.dart';
import 'package:local_transport/features/trips/domain/entities/trip_location.dart';
import 'package:local_transport/features/trips/domain/entities/trip_participants.dart';
import 'package:local_transport/features/trips/domain/entities/trip_pricing_snapshot.dart';
import 'package:local_transport/features/trips/domain/entities/trip_state.dart';
import 'package:local_transport/features/trips/domain/entities/trip_timestamps.dart';
import 'package:local_transport/features/trips/domain/entities/trip_transport_type.dart';

void main() {
  const mapper = TripFirestoreMapper();

  group('TripFirestoreMapper', () {
    test('serializes v3 pricing snapshot provenance to callable payload', () {
      final payload = mapper.toCallablePayload(_tripWithV3Snapshot());
      final snapshot = payload['pricingSnapshot'] as Map<String, dynamic>;

      expect(snapshot['pricingSchemaVersion'], 3);
      expect(
        snapshot['appliedMultiplierId'],
        'transport:standard|time:time_range_0800_1000|holiday:holiday_2026_12_25',
      );
      expect(snapshot['resolvedBaseTransportTypeId'], 'standard');
      expect(snapshot['resolvedBaseSource'], 'tariff.baseByTransportType');
      expect(snapshot.containsKey('transportMultiplier'), isFalse);
      expect(snapshot['timeRangeMultiplier'], 1.2);
      expect(snapshot['holidayMultiplier'], 1.5);
      expect(snapshot['pricingScheduleId'], 'time_range_0800_1000');
      expect(snapshot['specialDayId'], 'holiday_2026_12_25');
      expect(snapshot['evaluationTimeZone'], 'Europe/Lisbon');
      expect(
        snapshot['evaluationTimestamp'],
        '2026-12-25T08:30:00.000Z',
      );
    });

    test('reads v3 pricing snapshot from firestore json', () {
      final trip = _tripWithV3Snapshot();
      final json = mapper.toCreateJson(trip)
        ..['createdAt'] = DateTime.utc(2026, 12, 25, 8, 30)
        ..['requestedAt'] = DateTime.utc(2026, 12, 25, 8, 30)
        ..['statusEnteredAt'] = DateTime.utc(2026, 12, 25, 8, 30)
        ..['updatedAt'] = DateTime.utc(2026, 12, 25, 8, 30);

      final mapped = mapper.fromJson(json, id: 'trip_1');
      final snapshot = mapped.pricingSnapshot;

      expect(snapshot.pricingSchemaVersion, 3);
      expect(
        snapshot.appliedMultiplierId,
        'transport:standard|time:time_range_0800_1000|holiday:holiday_2026_12_25',
      );
      expect(snapshot.appliedMultiplier, closeTo(1.98, 0.000001));
      expect(snapshot.resolvedBaseTransportTypeId, 'standard');
      expect(snapshot.resolvedBaseSource, 'tariff.baseByTransportType');
      expect(snapshot.transportMultiplier, isNull);
      expect(snapshot.timeRangeMultiplier, 1.2);
      expect(snapshot.holidayMultiplier, 1.5);
      expect(snapshot.pricingScheduleId, 'time_range_0800_1000');
      expect(snapshot.specialDayId, 'holiday_2026_12_25');
      expect(
        snapshot.evaluationTimestamp,
        DateTime.utc(2026, 12, 25, 8, 30),
      );
      expect(snapshot.evaluationTimeZone, 'Europe/Lisbon');
    });

    test('keeps v1 pricing snapshot readable when v2 fields are absent', () {
      final mapped = mapper.fromJson({
        'clientId': 'client_1',
        'pickup': {
          'latitude': 14.91,
          'longitude': -23.52,
          'address': 'Origem',
        },
        'destination': {
          'latitude': 14.92,
          'longitude': -23.51,
          'address': 'Destino',
        },
        'transportType': {'id': 'standard', 'name': 'Standard'},
        'status': 'REQUESTED',
        'pricingSnapshot': {
          'base': {'amountMinor': 500, 'currency': 'EUR'},
          'perKm': {'amountMinor': 200, 'currency': 'EUR'},
          'perWaitMinute': {'amountMinor': 50, 'currency': 'EUR'},
          'lateCancellationFee': {'amountMinor': 0, 'currency': 'EUR'},
          'noShowFee': {'amountMinor': 0, 'currency': 'EUR'},
          'appliedMultiplier': 1.2,
          'multipliers': {'time_range_0800_1000': 1.2},
          'estimatedTotal': {'amountMinor': 1200, 'currency': 'EUR'},
        },
        'requestedAt': DateTime.utc(2026, 3, 20, 8, 30),
        'statusEnteredAt': DateTime.utc(2026, 3, 20, 8, 30),
        'createdAt': DateTime.utc(2026, 3, 20, 8, 30),
        'updatedAt': DateTime.utc(2026, 3, 20, 8, 30),
        'extensionRequestStatus': 'NONE',
      }, id: 'trip_legacy');

      final snapshot = mapped.pricingSnapshot;

      expect(snapshot.pricingSchemaVersion, isNull);
      expect(snapshot.appliedMultiplier, 1.2);
      expect(snapshot.appliedMultiplierId, isNull);
      expect(snapshot.pricingScheduleId, isNull);
      expect(snapshot.specialDayId, isNull);
      expect(snapshot.transportMultiplier, isNull);
      expect(snapshot.timeRangeMultiplier, isNull);
      expect(snapshot.holidayMultiplier, isNull);
      expect(snapshot.evaluationTimestamp, isNull);
      expect(snapshot.evaluationTimeZone, isNull);
      expect(snapshot.multipliers['time_range_0800_1000'], 1.2);
    });

    test('reads v2 pricing snapshot for backward compatibility', () {
      final trip = _tripWithV2Snapshot();
      final json = mapper.toCreateJson(trip)
        ..['createdAt'] = DateTime.utc(2026, 12, 25, 8, 30)
        ..['requestedAt'] = DateTime.utc(2026, 12, 25, 8, 30)
        ..['statusEnteredAt'] = DateTime.utc(2026, 12, 25, 8, 30)
        ..['updatedAt'] = DateTime.utc(2026, 12, 25, 8, 30);

      final mapped = mapper.fromJson(json, id: 'trip_v2');
      final snapshot = mapped.pricingSnapshot;

      expect(snapshot.pricingSchemaVersion, 2);
      expect(snapshot.transportMultiplier, 1.1);
      expect(snapshot.resolvedBaseTransportTypeId, isNull);
      expect(snapshot.resolvedBaseSource, isNull);
    });

    test('maps package coverage metadata when trip fare is included', () {
      final mapped = mapper.fromJson({
        'clientId': 'client_1',
        'pickup': {
          'latitude': 14.91,
          'longitude': -23.52,
          'address': 'Origem',
        },
        'destination': {
          'latitude': 14.92,
          'longitude': -23.51,
          'address': 'Destino',
        },
        'transportType': {'id': 'standard', 'name': 'Standard'},
        'status': 'CHARGE_APPLIED',
        'pricingSnapshot': {
          'base': {'amountMinor': 500, 'currency': 'EUR'},
          'perKm': {'amountMinor': 200, 'currency': 'EUR'},
          'perWaitMinute': {'amountMinor': 50, 'currency': 'EUR'},
          'lateCancellationFee': {'amountMinor': 0, 'currency': 'EUR'},
          'noShowFee': {'amountMinor': 0, 'currency': 'EUR'},
          'estimatedTotal': {'amountMinor': 1200, 'currency': 'EUR'},
        },
        'requestedAt': DateTime.utc(2026, 3, 20, 8, 30),
        'statusEnteredAt': DateTime.utc(2026, 3, 20, 8, 30),
        'createdAt': DateTime.utc(2026, 3, 20, 8, 30),
        'updatedAt': DateTime.utc(2026, 3, 20, 8, 30),
        'extensionRequestStatus': 'NONE',
        'packageBookingId': 'booking_1',
        'packageId': 'package_1',
        'packageSnapshotVersion': 4,
        'fareCoverage': 'included',
      }, id: 'pkg_booking_1_return');

      expect(mapped.packageCoverage, isNotNull);
      expect(mapped.packageCoverage!.bookingId, 'booking_1');
      expect(mapped.packageCoverage!.packageId, 'package_1');
      expect(mapped.packageCoverage!.snapshotVersion, 4);
      expect(mapped.packageCoverage!.isIncludedFare, isTrue);
    });
  });
}

Trip _tripWithV3Snapshot() {
  return Trip(
    id: 'trip_1',
    state: TripState.requested,
    participants: const TripParticipants(clientId: 'client_1'),
    pickup: const TripLocation(
      latitude: 14.91,
      longitude: -23.52,
      address: 'Origem',
    ),
    destination: const TripLocation(
      latitude: 14.92,
      longitude: -23.51,
      address: 'Destino',
    ),
    transportType: const TripTransportType(id: 'standard', name: 'Standard'),
    pricingSnapshot: TripPricingSnapshot(
      base: const Money(amountMinor: 500, currency: CurrencyCode.eur),
      perKm: const Money(amountMinor: 200, currency: CurrencyCode.eur),
      perWaitMinute: const Money(amountMinor: 50, currency: CurrencyCode.eur),
      lateCancellationFee: const Money(
        amountMinor: 0,
        currency: CurrencyCode.eur,
      ),
      noShowFee: const Money(amountMinor: 0, currency: CurrencyCode.eur),
      appliedMultiplierId:
          'transport:standard|time:time_range_0800_1000|holiday:holiday_2026_12_25',
      appliedMultiplier: 1.98,
      pricingSchemaVersion: 3,
      tariffId: 'tariff_1',
      tariffUpdatedAt: DateTime.utc(2026, 12, 1, 0, 0),
      resolvedBaseTransportTypeId: 'standard',
      resolvedBaseSource: 'tariff.baseByTransportType',
      pricingScheduleId: 'time_range_0800_1000',
      specialDayId: 'holiday_2026_12_25',
      timeRangeMultiplier: 1.2,
      holidayMultiplier: 1.5,
      evaluationTimestamp: DateTime.utc(2026, 12, 25, 8, 30),
      evaluationTimeZone: 'Europe/Lisbon',
      multipliers: const {
        'transport:standard|time:time_range_0800_1000|holiday:holiday_2026_12_25':
            1.98,
      },
      estimatedTotal: const Money(
        amountMinor: 1980,
        currency: CurrencyCode.eur,
      ),
    ),
    timestamps: TripTimestamps(
      createdAt: DateTime.utc(2026, 12, 25, 8, 30),
      requestedAt: DateTime.utc(2026, 12, 25, 8, 30),
      updatedAt: DateTime.utc(2026, 12, 25, 8, 30),
    ),
    extensionRequest: const TripExtensionRequest(
      status: TripExtensionStatus.none,
    ),
  );
}

Trip _tripWithV2Snapshot() {
  return Trip(
    id: 'trip_v2',
    state: TripState.requested,
    participants: const TripParticipants(clientId: 'client_1'),
    pickup: const TripLocation(
      latitude: 14.91,
      longitude: -23.52,
      address: 'Origem',
    ),
    destination: const TripLocation(
      latitude: 14.92,
      longitude: -23.51,
      address: 'Destino',
    ),
    transportType: const TripTransportType(id: 'standard', name: 'Standard'),
    pricingSnapshot: TripPricingSnapshot(
      base: const Money(amountMinor: 500, currency: CurrencyCode.eur),
      perKm: const Money(amountMinor: 200, currency: CurrencyCode.eur),
      perWaitMinute: const Money(amountMinor: 50, currency: CurrencyCode.eur),
      lateCancellationFee: const Money(
        amountMinor: 0,
        currency: CurrencyCode.eur,
      ),
      noShowFee: const Money(amountMinor: 0, currency: CurrencyCode.eur),
      appliedMultiplierId:
          'transport:standard|time:time_range_0800_1000|holiday:holiday_2026_12_25',
      appliedMultiplier: 1.98,
      pricingSchemaVersion: 2,
      tariffId: 'tariff_1',
      tariffUpdatedAt: DateTime.utc(2026, 12, 1, 0, 0),
      pricingScheduleId: 'time_range_0800_1000',
      specialDayId: 'holiday_2026_12_25',
      transportMultiplier: 1.1,
      timeRangeMultiplier: 1.2,
      holidayMultiplier: 1.5,
      evaluationTimestamp: DateTime.utc(2026, 12, 25, 8, 30),
      evaluationTimeZone: 'Europe/Lisbon',
      multipliers: const {
        'transport:standard|time:time_range_0800_1000|holiday:holiday_2026_12_25':
            1.98,
        'standard': 1.98,
      },
      estimatedTotal: const Money(
        amountMinor: 1980,
        currency: CurrencyCode.eur,
      ),
    ),
    timestamps: TripTimestamps(
      createdAt: DateTime.utc(2026, 12, 25, 8, 30),
      requestedAt: DateTime.utc(2026, 12, 25, 8, 30),
      updatedAt: DateTime.utc(2026, 12, 25, 8, 30),
    ),
    extensionRequest: const TripExtensionRequest(
      status: TripExtensionStatus.none,
    ),
  );
}
