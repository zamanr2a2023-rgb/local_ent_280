import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/client/presentation/formatters/client_trip_eta_presenter.dart';
import 'package:local_transport/features/client/presentation/providers/current_trip_route_provider.dart';
import 'package:local_transport/features/trips/domain/entities/trip_route_estimate.dart';
import 'package:local_transport/features/trips/domain/entities/trip_route_point.dart';
import 'package:local_transport/features/trips/domain/entities/trip_route_segment.dart';
import 'package:local_transport/features/trips/domain/entities/trip_route_segment_type.dart';
import 'package:local_transport/features/trips/domain/entities/trip_state.dart';

void main() {
  const presenter = ClientTripEtaPresenter();
  const copy = ClientTripEtaCopy(
    pickupReady: _pickupReady,
    pickupLoading: 'A calcular chegada…',
    pickupUnavailable: 'Chegada indisponível',
    destinationReady: _destinationReady,
    destinationLoading: 'A calcular chegada ao destino…',
    destinationUnavailable: 'Chegada ao destino indisponível',
  );

  group('ClientTripEtaPresenter', () {
    test('returns pickup ETA before collection when driver route is ready', () {
      final result = presenter.present(
        state: TripState.driverEnRoute,
        hasAssignedDriver: true,
        routeState: _routeState(
          type: TripRouteSegmentType.driverToPickup,
          durationMinutes: 7,
        ),
        locale: 'pt_PT',
        copy: copy,
      );

      expect(result, 'Chega em 7 min');
    });

    test('returns pickup loading copy while route is loading', () {
      final result = presenter.present(
        state: TripState.driverAccepted,
        hasAssignedDriver: true,
        routeState: const CurrentTripRouteState(isLoading: true),
        locale: 'pt_PT',
        copy: copy,
      );

      expect(result, 'A calcular chegada…');
    });

    test('returns pickup unavailable copy when route is missing', () {
      final result = presenter.present(
        state: TripState.driverAssignedWaitingAcceptance,
        hasAssignedDriver: true,
        routeState: const CurrentTripRouteState(),
        locale: 'pt_PT',
        copy: copy,
      );

      expect(result, 'Chegada indisponível');
    });

    test('returns destination ETA after collection when route is ready', () {
      final result = presenter.present(
        state: TripState.inTrip,
        hasAssignedDriver: true,
        routeState: _routeState(
          type: TripRouteSegmentType.driverToDestination,
          durationMinutes: 14,
        ),
        locale: 'pt_PT',
        copy: copy,
      );

      expect(result, 'Destino em 14 min');
    });

    test('returns destination loading copy while route is loading', () {
      final result = presenter.present(
        state: TripState.inTrip,
        hasAssignedDriver: true,
        routeState: const CurrentTripRouteState(isLoading: true),
        locale: 'pt_PT',
        copy: copy,
      );

      expect(result, 'A calcular chegada ao destino…');
    });

    test('returns destination unavailable copy when route is missing', () {
      final result = presenter.present(
        state: TripState.inTrip,
        hasAssignedDriver: true,
        routeState: const CurrentTripRouteState(),
        locale: 'pt_PT',
        copy: copy,
      );

      expect(result, 'Chegada ao destino indisponível');
    });

    test('returns null for states without client ETA', () {
      final result = presenter.present(
        state: TripState.driverArrived,
        hasAssignedDriver: true,
        routeState: _routeState(
          type: TripRouteSegmentType.driverToPickup,
          durationMinutes: 1,
        ),
        locale: 'pt_PT',
        copy: copy,
      );

      expect(result, isNull);
    });

    test('returns null without assigned driver', () {
      final result = presenter.present(
        state: TripState.driverEnRoute,
        hasAssignedDriver: false,
        routeState: _routeState(
          type: TripRouteSegmentType.driverToPickup,
          durationMinutes: 7,
        ),
        locale: 'pt_PT',
        copy: copy,
      );

      expect(result, isNull);
    });
  });
}

String _pickupReady(String minutes) => 'Chega em $minutes min';

String _destinationReady(String minutes) => 'Destino em $minutes min';

CurrentTripRouteState _routeState({
  required TripRouteSegmentType type,
  required int durationMinutes,
}) {
  const origin = TripRoutePoint(latitude: 38.7, longitude: -9.1);
  const destination = TripRoutePoint(latitude: 38.8, longitude: -9.2);
  return CurrentTripRouteState(
    routes: [
      TripRouteEstimate(
        distanceKm: 3,
        durationMinutes: durationMinutes,
        polylinePoints: const [origin, destination],
        isFallback: false,
      ),
    ],
    segments: [
      TripRouteSegment(origin: origin, destination: destination, type: type),
    ],
  );
}
