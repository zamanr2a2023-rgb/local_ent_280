import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/trips/domain/entities/trip.dart';
import 'package:local_transport/features/trips/domain/entities/trip_extension_request.dart';
import 'package:local_transport/features/trips/domain/entities/trip_extension_status.dart';
import 'package:local_transport/features/trips/domain/entities/trip_location.dart';
import 'package:local_transport/features/trips/domain/entities/trip_metering_snapshot.dart';
import 'package:local_transport/features/trips/domain/entities/trip_participants.dart';
import 'package:local_transport/features/trips/domain/entities/trip_pricing_snapshot.dart';
import 'package:local_transport/features/trips/domain/entities/trip_state.dart';
import 'package:local_transport/features/trips/domain/entities/trip_timestamps.dart';
import 'package:local_transport/features/trips/domain/entities/trip_transport_type.dart';
import 'package:local_transport/features/trips/domain/usecases/build_trip_receipt.dart';

void main() {
  const useCase = BuildTripReceipt();

  group('BuildTripReceipt', () {
    test('uses locked combined multiplier from pricing snapshot', () {
      final trip = _trip(
        appliedMultiplier: 1.98,
        multipliers: const {
          'transport:standard|time:time_range_0800_1000|holiday:holiday_2026_12_25':
              1.98,
        },
      );

      final receipt = useCase(trip);

      expect(receipt.multiplier, closeTo(1.98, 0.000001));
      expect(receipt.subtotalMinor, 1980);
      expect(receipt.multiplierChargeMinor, 980);
      expect(receipt.totalMinor, 1980);
    });

    test(
      'keeps compatibility when metering still points to transport type id',
      () {
        final trip = _trip(
          appliedMultiplier: 1.98,
          activeMultiplierId: 'standard',
          multipliers: const {
            'transport:standard|time:time_range_0800_1000|holiday:holiday_2026_12_25':
                1.98,
            'standard': 1.98,
          },
        );

        final receipt = useCase(trip);

        expect(receipt.multiplier, closeTo(1.98, 0.000001));
        expect(receipt.subtotalMinor, 1980);
        expect(receipt.totalMinor, 1980);
      },
    );
  });
}

Trip _trip({
  required double appliedMultiplier,
  required Map<String, double> multipliers,
  String? activeMultiplierId,
}) {
  return Trip(
    id: 'trip_1',
    state: TripState.completed,
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
      perWaitMinute: const Money(amountMinor: 100, currency: CurrencyCode.eur),
      lateCancellationFee: const Money(
        amountMinor: 0,
        currency: CurrencyCode.eur,
      ),
      noShowFee: const Money(amountMinor: 0, currency: CurrencyCode.eur),
      appliedMultiplierId:
          'transport:standard|time:time_range_0800_1000|holiday:holiday_2026_12_25',
      appliedMultiplier: appliedMultiplier,
      multipliers: multipliers,
    ),
    timestamps: TripTimestamps(
      requestedAt: DateTime.utc(2026, 12, 25, 8, 30),
      acceptedAt: DateTime.utc(2026, 12, 25, 8, 32),
      arrivedAt: DateTime.utc(2026, 12, 25, 8, 35),
      startedAt: DateTime.utc(2026, 12, 25, 8, 36),
      completedAt: DateTime.utc(2026, 12, 25, 8, 50),
    ),
    meteringSnapshot: TripMeteringSnapshot(
      totalMinutes: 14,
      totalWaitMinutes: 1,
      totalDistanceKm: 2,
      estimatedCostMinor: 1980,
      activeMultiplierId: activeMultiplierId,
    ),
    extensionRequest: const TripExtensionRequest(
      status: TripExtensionStatus.none,
    ),
  );
}
