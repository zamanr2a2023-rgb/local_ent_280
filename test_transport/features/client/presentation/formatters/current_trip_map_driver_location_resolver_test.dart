import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/client/presentation/formatters/current_trip_map_driver_location_resolver.dart';
import 'package:local_transport/features/driver/domain/entities/driver_location.dart';
import 'package:local_transport/features/trips/domain/entities/trip_state.dart';

import '../../../../test_support/fixtures/test_trip_factory.dart';

void main() {
  const resolver = CurrentTripMapDriverLocationResolver();

  test('snaps stationary pre-pickup driver near pickup to pickup', () {
    final trip = buildTestTrip(
      id: 'trip-1',
      pickupAddress: 'Recolha',
      destinationAddress: 'Destino',
      requestedAt: DateTime(2026),
      state: TripState.driverEnRoute,
    );
    final location = DriverLocation(
      latitude: trip.pickup.latitude + 0.0002,
      longitude: trip.pickup.longitude + 0.0002,
      updatedAt: DateTime(2026),
      heading: 25,
      speed: 0,
    );

    final resolved = resolver(trip: trip, location: location);

    expect(resolved, isNotNull);
    expect(resolved!.latitude, trip.pickup.latitude);
    expect(resolved.longitude, trip.pickup.longitude);
    expect(resolved.heading, location.heading);
  });

  test('keeps moving pre-pickup driver location unchanged', () {
    final trip = buildTestTrip(
      id: 'trip-2',
      pickupAddress: 'Recolha',
      destinationAddress: 'Destino',
      requestedAt: DateTime(2026),
      state: TripState.driverEnRoute,
    );
    final location = DriverLocation(
      latitude: trip.pickup.latitude + 0.0002,
      longitude: trip.pickup.longitude + 0.0002,
      updatedAt: DateTime(2026),
      speed: 4,
    );

    final resolved = resolver(trip: trip, location: location);

    expect(resolved, same(location));
  });

  test('does not snap driver location after pickup', () {
    final trip = buildTestTrip(
      id: 'trip-3',
      pickupAddress: 'Recolha',
      destinationAddress: 'Destino',
      requestedAt: DateTime(2026),
      state: TripState.inTrip,
    );
    final location = DriverLocation(
      latitude: trip.pickup.latitude,
      longitude: trip.pickup.longitude,
      updatedAt: DateTime(2026),
      speed: 0,
    );

    final resolved = resolver(trip: trip, location: location);

    expect(resolved, same(location));
  });
}
