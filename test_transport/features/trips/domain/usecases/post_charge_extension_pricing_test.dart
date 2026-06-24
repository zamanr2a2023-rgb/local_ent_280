import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/trips/domain/entities/post_charge_extension_action_result.dart';
import 'package:local_transport/features/trips/domain/entities/trip.dart';
import 'package:local_transport/features/trips/domain/entities/trip_extension_request.dart';
import 'package:local_transport/features/trips/domain/entities/trip_extension_status.dart';
import 'package:local_transport/features/trips/domain/entities/trip_location.dart';
import 'package:local_transport/features/trips/domain/entities/trip_participants.dart';
import 'package:local_transport/features/trips/domain/entities/trip_post_charge_extension_flow.dart';
import 'package:local_transport/features/trips/domain/entities/trip_post_charge_extension_status.dart';
import 'package:local_transport/features/trips/domain/entities/trip_pricing_snapshot.dart';
import 'package:local_transport/features/trips/domain/entities/trip_state.dart';
import 'package:local_transport/features/trips/domain/entities/trip_timestamps.dart';
import 'package:local_transport/features/trips/domain/entities/trip_transport_type.dart';
import 'package:local_transport/features/trips/domain/repositories/trip_repository.dart';
import 'package:local_transport/features/trips/domain/usecases/estimate_post_charge_extension_charge.dart';
import 'package:local_transport/features/trips/domain/usecases/request_post_charge_trip_extension.dart';

void main() {
  group('EstimatePostChargeExtensionCharge', () {
    test('returns perWaitMinute multiplied by requested minutes', () {
      const useCase = EstimatePostChargeExtensionCharge();
      const pricingSnapshot = TripPricingSnapshot(
        base: Money(amountMinor: 0, currency: CurrencyCode.eur),
        perKm: Money(amountMinor: 0, currency: CurrencyCode.eur),
        perWaitMinute: Money(amountMinor: 120, currency: CurrencyCode.eur),
        lateCancellationFee: Money(amountMinor: 0, currency: CurrencyCode.eur),
        noShowFee: Money(amountMinor: 0, currency: CurrencyCode.eur),
      );

      final result = useCase(
        pricingSnapshot: pricingSnapshot,
        requestedMinutes: 15,
      );

      expect(result.amountMinor, 1800);
      expect(result.currency, CurrencyCode.eur);
    });
  });

  group('RequestPostChargeTripExtension', () {
    test('accepts suggested durations from 15 to 60 minutes', () async {
      final repository = _FakeTripRepository();
      final useCase = RequestPostChargeTripExtension(repository);
      final trip = _buildTrip();

      for (final minutes in const <int>[15, 30, 45, 60]) {
        final result = await useCase(trip: trip, durationMinutes: minutes);

        expect(
          result.status,
          PostChargeExtensionActionResultStatus.driverPending,
        );
        expect(repository.requestedTripId, trip.id);
        expect(repository.requestedDurationMinutes, minutes);
      }
    });

    test('rejects durations below 15 minutes', () async {
      final repository = _FakeTripRepository();
      final useCase = RequestPostChargeTripExtension(repository);

      expect(
        () => useCase(trip: _buildTrip(), durationMinutes: 14),
        throwsArgumentError,
      );
    });

    test('rejects durations above 60 minutes', () async {
      final repository = _FakeTripRepository();
      final useCase = RequestPostChargeTripExtension(repository);

      expect(
        () => useCase(trip: _buildTrip(), durationMinutes: 61),
        throwsArgumentError,
      );
    });
  });
}

Trip _buildTrip() {
  const zeroMoney = Money(amountMinor: 0, currency: CurrencyCode.eur);
  return Trip(
    id: 'trip_1',
    state: TripState.chargeApplied,
    participants: const TripParticipants(clientId: 'client_1'),
    pickup: const TripLocation(latitude: 0, longitude: 0, address: 'Rua A'),
    destination: const TripLocation(
      latitude: 1,
      longitude: 1,
      address: 'Rua B',
    ),
    transportType: const TripTransportType(id: 'standard', name: 'Standard'),
    pricingSnapshot: const TripPricingSnapshot(
      base: zeroMoney,
      perKm: zeroMoney,
      perWaitMinute: Money(amountMinor: 100, currency: CurrencyCode.eur),
      lateCancellationFee: zeroMoney,
      noShowFee: zeroMoney,
    ),
    timestamps: TripTimestamps(requestedAt: DateTime(2026, 3, 17)),
    extensionRequest: const TripExtensionRequest(
      status: TripExtensionStatus.none,
    ),
    postChargeExtension: const TripPostChargeExtensionFlow(
      schemaVersion: 1,
      isActive: true,
      status: TripPostChargeExtensionStatus.clientPrompt,
    ),
  );
}

class _FakeTripRepository implements TripRepository {
  String? requestedTripId;
  int? requestedDurationMinutes;

  @override
  Future<PostChargeExtensionActionResult> requestTripExtension({
    required String tripId,
    int? durationMinutes,
  }) async {
    requestedTripId = tripId;
    requestedDurationMinutes = durationMinutes;
    return const PostChargeExtensionActionResult(
      tripId: 'trip_1',
      status: PostChargeExtensionActionResultStatus.driverPending,
      cycleIndex: 1,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
