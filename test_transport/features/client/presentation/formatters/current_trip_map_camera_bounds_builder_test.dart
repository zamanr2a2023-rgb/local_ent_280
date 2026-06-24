import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/client/presentation/formatters/current_trip_map_camera_bounds_builder.dart';
import 'package:local_transport/features/driver/domain/entities/driver_location.dart';
import 'package:local_transport/features/trips/domain/entities/trip_route_estimate.dart';
import 'package:local_transport/features/trips/domain/entities/trip_route_point.dart';
import 'package:local_transport/features/trips/domain/entities/trip_route_segment.dart';
import 'package:local_transport/features/trips/domain/entities/trip_route_segment_type.dart';
import 'package:local_transport/features/trips/domain/entities/trip_state.dart';

import '../../../../test_support/fixtures/test_trip_factory.dart';

void main() {
  const builder = CurrentTripMapCameraBoundsBuilder();

  test(
    'fits driver and pickup before pickup without including destination',
    () {
      final trip = buildTestTrip(
        id: 'trip-1',
        pickupAddress: 'Recolha',
        destinationAddress: 'Destino',
        requestedAt: DateTime(2026),
        state: TripState.driverAccepted,
      );
      const driverLocation = DriverLocation(
        latitude: 38.7219,
        longitude: -9.1390,
      );

      final bounds = builder(
        trip: trip,
        driverLocation: driverLocation,
        routes: const [
          TripRouteEstimate(
            distanceKm: 0.2,
            durationMinutes: 1,
            polylinePoints: [
              TripRoutePoint(latitude: 38.7219, longitude: -9.1390),
              TripRoutePoint(latitude: 38.7223, longitude: -9.1393),
            ],
            isFallback: false,
          ),
          TripRouteEstimate(
            distanceKm: 200,
            durationMinutes: 120,
            polylinePoints: [
              TripRoutePoint(latitude: 40, longitude: -8),
            ],
            isFallback: false,
          ),
        ],
        segments: const [
          TripRouteSegment(
            origin: TripRoutePoint(latitude: 38.7219, longitude: -9.1390),
            destination: TripRoutePoint(latitude: 38.7223, longitude: -9.1393),
            type: TripRouteSegmentType.driverToPickup,
          ),
          TripRouteSegment(
            origin: TripRoutePoint(latitude: 38.7223, longitude: -9.1393),
            destination: TripRoutePoint(latitude: 40, longitude: -8),
            type: TripRouteSegmentType.pickupToDestination,
          ),
        ],
      );

      expect(bounds.southwest.latitude, closeTo(38.7219, 0.00001));
      expect(bounds.northeast.latitude, closeTo(38.7223, 0.00001));
      expect(bounds.northeast.latitude, lessThan(39));
      expect(bounds.northeast.longitude, lessThan(-9.13));
    },
  );

  test('fits driver and destination once trip is in progress', () {
    final trip = buildTestTrip(
      id: 'trip-2',
      pickupAddress: 'Recolha',
      destinationAddress: 'Destino',
      requestedAt: DateTime(2026),
      state: TripState.inTrip,
    );
    const driverLocation = DriverLocation(
      latitude: 38.7100,
      longitude: -9.1360,
    );

    final bounds = builder(
      trip: trip,
      driverLocation: driverLocation,
      routes: const [],
      segments: const [],
    );

    expect(bounds.southwest.latitude, closeTo(38.7071, 0.00001));
    expect(bounds.northeast.latitude, closeTo(38.7100, 0.00001));
    expect(bounds.southwest.longitude, closeTo(-9.1360, 0.00001));
    expect(bounds.northeast.longitude, closeTo(-9.1355, 0.00001));
  });
}
