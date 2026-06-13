import 'package:flutter/material.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/features/trips/data/active_trip_session.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';

/// Client booking flow screens in lifecycle order.
enum ClientTripScreen {
  driverSearch,
  driverFound,
  driverEnRoute,
  tripInProgress,
  tripCompleted,
}

abstract final class ClientTripFlow {
  static const _cancelledStatuses = {
    'CANCELLED_BY_CLIENT',
    'CANCELLED_BY_DRIVER',
    'NO_SHOW',
    'NO_DRIVERS_AVAILABLE',
  };

  static const _completedStatuses = {
    'COMPLETED',
    'CHARGE_APPLIED',
    'TRIP_COMPLETED',
  };

  static const _inProgressStatuses = {
    'IN_TRIP',
    'ARRIVED_DESTINATION',
    'EXTENSION_WINDOW',
  };

  static const _enRouteStatuses = {
    'DRIVER_ACCEPTED',
    'DRIVER_EN_ROUTE',
    'DRIVER_ARRIVED',
  };

  static ClientTripScreen? targetScreenForStatus(String status) {
    final normalized = status.toUpperCase();
    if (_completedStatuses.contains(normalized)) {
      return ClientTripScreen.tripCompleted;
    }
    if (_inProgressStatuses.contains(normalized)) {
      return ClientTripScreen.tripInProgress;
    }
    if (_enRouteStatuses.contains(normalized)) {
      return ClientTripScreen.driverEnRoute;
    }
    if (normalized == 'DRIVER_ASSIGNED_WAITING_ACCEPTANCE') {
      return ClientTripScreen.driverFound;
    }
    return null;
  }

  static bool isCancelled(String status) =>
      _cancelledStatuses.contains(status.toUpperCase());

  static void maybeForward({
    required BuildContext context,
    required ClientTripScreen current,
    required TripRecord trip,
    required VoidCallback onForwarded,
    VoidCallback? onCancelled,
  }) {
    if (!context.mounted) return;
    final status = trip.status.toUpperCase();
    if (isCancelled(status)) {
      ActiveTripSession.instance.clear();
      onCancelled?.call();
      if (status == 'NO_DRIVERS_AVAILABLE') {
        AppNavigation.cancelToTripDestination(context);
      } else {
        AppNavigation.toHomeAfterLogin(context);
      }
      onForwarded();
      return;
    }

    final target = targetScreenForStatus(status);
    if (target == null || target.index <= current.index) return;

    switch (target) {
      case ClientTripScreen.driverFound:
        AppNavigation.toDriverFound(
          context,
          tripId: trip.id,
          trip: trip,
        );
      case ClientTripScreen.driverEnRoute:
        AppNavigation.toDriverEnRoute(
          context,
          tripId: trip.id,
          trip: trip,
        );
      case ClientTripScreen.tripInProgress:
        AppNavigation.toTripInProgress(
          context,
          tripId: trip.id,
          trip: trip,
        );
      case ClientTripScreen.tripCompleted:
        ActiveTripSession.instance.clear();
        AppNavigation.toTripCompleted(
          context,
          tripId: trip.id,
          trip: trip,
        );
      case ClientTripScreen.driverSearch:
        break;
    }
    onForwarded();
  }
}
