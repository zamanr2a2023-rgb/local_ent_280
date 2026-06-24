import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_ent_280/features/trips/data/active_trip_session.dart';
import 'package:local_ent_280/features/trips/data/client_trip_flow.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';
import 'package:local_ent_280/features/trips/data/repositories/trip_repository_impl.dart';
import 'package:local_ent_280/features/trips/domain/repositories/trip_repository.dart';

/// Listens to a trip document and forwards the client through the booking flow.
class ClientTripWatcher {
  ClientTripWatcher({
    required this.screen,
    required this.onTripChanged,
    this.onCancelled,
    TripRepository? repository,
  }) : _repository = repository ?? TripRepositoryImpl();

  final ClientTripScreen screen;
  final void Function(TripRecord trip) onTripChanged;
  final VoidCallback? onCancelled;
  final TripRepository _repository;

  StreamSubscription<TripRecord?>? _subscription;
  bool _forwarded = false;

  void start({
    required String tripId,
    required BuildContext context,
  }) {
    _subscription?.cancel();
    _forwarded = false;
    _subscription = _repository.watchTrip(tripId).listen((trip) {
      if (trip == null) return;
      ActiveTripSession.instance.updateTrip(trip);
      onTripChanged(trip);
      if (_forwarded) return;
      ClientTripFlow.maybeForward(
        context: context,
        current: screen,
        trip: trip,
        onForwarded: () => _forwarded = true,
        onCancelled: onCancelled,
      );
    });
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
