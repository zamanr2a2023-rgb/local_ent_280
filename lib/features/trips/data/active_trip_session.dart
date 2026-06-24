import 'package:flutter/foundation.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';

/// Holds the active client trip id for the current booking flow.
class ActiveTripSession extends ChangeNotifier {
  ActiveTripSession._();

  static final ActiveTripSession instance = ActiveTripSession._();

  String? _tripId;
  TripRecord? _trip;

  String? get tripId => _tripId;
  TripRecord? get trip => _trip;

  void setTrip({required String tripId, TripRecord? trip}) {
    _tripId = tripId;
    _trip = trip;
    notifyListeners();
  }

  void updateTrip(TripRecord trip) {
    _tripId = trip.id;
    _trip = trip;
    notifyListeners();
  }

  void clear() {
    _tripId = null;
    _trip = null;
    notifyListeners();
  }
}
