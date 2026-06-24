import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/trips/domain/entities/trip.dart';
import 'package:local_transport/features/trips/domain/entities/trip_extension_request.dart';
import 'package:local_transport/features/trips/domain/entities/trip_extension_status.dart';
import 'package:local_transport/features/trips/domain/entities/trip_location.dart';
import 'package:local_transport/features/trips/domain/entities/trip_participants.dart';
import 'package:local_transport/features/trips/domain/entities/trip_post_charge_extension_cycle.dart';
import 'package:local_transport/features/trips/domain/entities/trip_post_charge_extension_flow.dart';
import 'package:local_transport/features/trips/domain/entities/trip_post_charge_extension_status.dart';
import 'package:local_transport/features/trips/domain/entities/trip_pricing_snapshot.dart';
import 'package:local_transport/features/trips/domain/entities/trip_rating.dart';
import 'package:local_transport/features/trips/domain/entities/trip_state.dart';
import 'package:local_transport/features/trips/domain/entities/trip_timestamps.dart';
import 'package:local_transport/features/trips/domain/entities/trip_transport_type.dart';
import 'package:local_transport/features/trips/presentation/models/trip_completion_ui_state.dart';

void main() {
  const resolver = TripCompletionUiStateResolver();

  group('TripCompletionUiStateResolver', () {
    test('cliente em completed fica em chargingPending', () {
      final trip = _trip(state: TripState.completed);

      expect(
        resolver.forClient(trip, isLoading: false),
        TripCompletionUiState.chargingPending,
      );
    });

    test(
      'cliente em chargeApplied com prompt mostra prolongamento antes de rating',
      () {
        final trip = _trip(
          state: TripState.chargeApplied,
          postChargeExtension: _flow(
            TripPostChargeExtensionStatus.clientPrompt,
          ),
        );

        expect(
          resolver.forClient(trip, isLoading: false),
          TripCompletionUiState.clientPrompt,
        );
      },
    );

    test('cliente em chargeApplied sem prolongamento pode avaliar', () {
      final trip = _trip(state: TripState.chargeApplied);

      expect(
        resolver.forClient(trip, isLoading: false),
        TripCompletionUiState.ratingAvailable,
      );
    });

    test('cliente com avaliação submetida vê ratingSubmitted', () {
      final trip = _trip(
        state: TripState.chargeApplied,
        rating: const TripRating(stars: 5),
      );

      expect(
        resolver.forClient(trip, isLoading: false),
        TripCompletionUiState.ratingSubmitted,
      );
    });

    test('cliente com avaliação e extensão ativa continua a ver extensão', () {
      final trip = _trip(
        state: TripState.chargeApplied,
        postChargeExtension: _flow(TripPostChargeExtensionStatus.active),
        rating: const TripRating(stars: 5),
      );

      expect(
        resolver.forClient(trip, isLoading: false),
        TripCompletionUiState.extensionActive,
      );
    });

    test('motorista com pedido pendente vê driverPending', () {
      final trip = _trip(
        state: TripState.chargeApplied,
        postChargeExtension: _flow(TripPostChargeExtensionStatus.driverPending),
      );

      expect(
        resolver.forDriver(trip, isLoading: false),
        TripCompletionUiState.driverPending,
      );
    });

    test('cliente em cancelado vê estado cancelado sem prolongamento', () {
      final trip = _trip(
        state: TripState.cancelledByClient,
        postChargeExtension: _flow(TripPostChargeExtensionStatus.clientPrompt),
      );

      expect(
        resolver.forClient(trip, isLoading: false),
        TripCompletionUiState.cancelled,
      );
    });

    test('motorista em cancelado vê estado cancelado sem prolongamento', () {
      final trip = _trip(
        state: TripState.cancelledByDriver,
        postChargeExtension: _flow(TripPostChargeExtensionStatus.clientPrompt),
      );

      expect(
        resolver.forDriver(trip, isLoading: false),
        TripCompletionUiState.cancelled,
      );
    });
  });
}

Trip _trip({
  required TripState state,
  TripPostChargeExtensionFlow postChargeExtension =
      const TripPostChargeExtensionFlow.none(),
  TripRating? rating,
}) {
  const zeroMoney = Money(amountMinor: 0, currency: CurrencyCode.eur);
  return Trip(
    id: 'trip-1',
    state: state,
    participants: const TripParticipants(clientId: 'client-1'),
    pickup: const TripLocation(
      latitude: 38.7223,
      longitude: -9.1393,
      address: 'Origem',
    ),
    destination: const TripLocation(
      latitude: 38.7071,
      longitude: -9.1355,
      address: 'Destino',
    ),
    transportType: const TripTransportType(id: 'standard', name: 'Standard'),
    pricingSnapshot: const TripPricingSnapshot(
      base: zeroMoney,
      perKm: zeroMoney,
      perWaitMinute: zeroMoney,
      lateCancellationFee: zeroMoney,
      noShowFee: zeroMoney,
    ),
    timestamps: TripTimestamps(
      requestedAt: DateTime(2026),
      completedAt: DateTime(2026, 1, 1, 12),
    ),
    extensionRequest: const TripExtensionRequest(
      status: TripExtensionStatus.none,
    ),
    postChargeExtension: postChargeExtension,
    rating: rating,
  );
}

TripPostChargeExtensionFlow _flow(TripPostChargeExtensionStatus status) {
  return TripPostChargeExtensionFlow(
    schemaVersion: 1,
    isActive: true,
    status: status,
    currentCycle: const TripPostChargeExtensionCycle(
      cycleIndex: 1,
      requestedMinutes: 30,
    ),
  );
}
