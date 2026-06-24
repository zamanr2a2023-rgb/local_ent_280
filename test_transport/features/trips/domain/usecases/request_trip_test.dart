import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/trips/domain/entities/trip.dart';
import 'package:local_transport/features/trips/domain/entities/trip_location.dart';
import 'package:local_transport/features/trips/domain/entities/trip_pricing_snapshot.dart';
import 'package:local_transport/features/trips/domain/entities/trip_request.dart';
import 'package:local_transport/features/trips/domain/entities/trip_state.dart';
import 'package:local_transport/features/trips/domain/entities/trip_transport_type.dart';
import 'package:local_transport/features/trips/domain/repositories/trip_repository.dart';
import 'package:local_transport/features/trips/domain/services/trip_id_generator.dart';
import 'package:local_transport/features/trips/domain/usecases/request_trip.dart';

void main() {
  group('RequestTrip', () {
    test('creates the trip through the server repository only', () async {
      final repository = _RecordingTripRepository();
      final useCase = RequestTrip(repository, const _FixedTripIdGenerator());

      final trip = await useCase(_buildTripRequest());

      expect(trip.id, 'trip-1');
      expect(trip.state, TripState.requested);
      expect(repository.createdTrips, hasLength(1));
      expect(repository.createdTrips.single.id, 'trip-1');
    });
  });
}

TripRequest _buildTripRequest() {
  const money = Money(amountMinor: 100, currency: CurrencyCode.eur);
  return const TripRequest(
    clientId: 'client-1',
    pickup: TripLocation(
      latitude: 38.7223,
      longitude: -9.1393,
      address: 'Recolha',
    ),
    destination: TripLocation(
      latitude: 38.7071,
      longitude: -9.1355,
      address: 'Destino',
    ),
    transportType: TripTransportType(id: 'standard', name: 'Standard'),
    pricingSnapshot: TripPricingSnapshot(
      base: money,
      perKm: money,
      perWaitMinute: money,
      lateCancellationFee: money,
      noShowFee: money,
    ),
  );
}

class _FixedTripIdGenerator implements TripIdGenerator {
  const _FixedTripIdGenerator();

  @override
  String generateTripEventId(String tripId) => '$tripId-event';

  @override
  String generateTripId() => 'trip-1';
}

class _RecordingTripRepository implements TripRepository {
  final List<Trip> createdTrips = [];

  @override
  Future<void> createTrip(Trip trip) async {
    createdTrips.add(trip);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
