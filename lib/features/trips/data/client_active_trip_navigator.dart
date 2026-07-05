import 'package:flutter/material.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/features/trips/data/active_trip_session.dart';
import 'package:local_ent_280/features/trips/data/client_trip_flow.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';

/// Detects in-progress client trips and resumes the correct booking screen.
abstract final class ClientActiveTripNavigator {
  static const _activeStatuses = {
    'REQUESTED',
    'DRIVER_ASSIGNED_WAITING_ACCEPTANCE',
    'DRIVER_ACCEPTED',
    'DRIVER_EN_ROUTE',
    'DRIVER_ARRIVED',
    'IN_TRIP',
    'ARRIVED_DESTINATION',
    'EXTENSION_WINDOW',
  };

  static TripRecord? findActiveTrip(List<TripRecord> trips) {
    for (final trip in trips) {
      final status = trip.status.toUpperCase();
      if (ClientTripFlow.isCancelled(status)) continue;
      if (!trip.isActive) continue;
      if (_activeStatuses.contains(status)) {
        return trip;
      }
    }
    return null;
  }

  static TripRecord? findResumableTrip(List<TripRecord> trips) {
    for (final trip in trips) {
      final status = trip.status.toUpperCase();
      if (ClientTripFlow.isCancelled(status)) continue;
      if (!trip.isActive) continue;
      if (!_activeStatuses.contains(status)) continue;
      // Keep searching on home until the user explicitly opens the flow.
      if (status == 'REQUESTED') continue;
      return trip;
    }
    return null;
  }

  static void resume(BuildContext context, TripRecord trip) {
    if (!context.mounted) return;

    ActiveTripSession.instance.setTrip(tripId: trip.id, trip: trip);
    final status = trip.status.toUpperCase();

    if (status == 'REQUESTED') {
      AppNavigation.toDriverSearch(
        context,
        tripId: trip.id,
        showNoDriversMessage: false,
      );
      return;
    }

    final target = ClientTripFlow.targetScreenForStatus(status);
    switch (target) {
      case ClientTripScreen.driverFound:
        AppNavigation.toDriverFound(context, tripId: trip.id, trip: trip);
      case ClientTripScreen.driverEnRoute:
        AppNavigation.toDriverEnRoute(context, tripId: trip.id, trip: trip);
      case ClientTripScreen.tripInProgress:
        AppNavigation.toTripInProgress(context, tripId: trip.id, trip: trip);
      case ClientTripScreen.tripCompleted:
        ActiveTripSession.instance.clear();
        AppNavigation.toTripCompleted(context, tripId: trip.id, trip: trip);
      case ClientTripScreen.driverSearch:
      case null:
        AppNavigation.toDriverSearch(
          context,
          tripId: trip.id,
          showNoDriversMessage: false,
        );
    }
  }
}
