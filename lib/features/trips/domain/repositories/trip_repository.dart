import 'package:local_ent_280/features/trips/data/models/trip_record.dart';
import 'package:local_ent_280/features/trips/domain/entities/create_trip_input.dart';

/// Domain contract for client trip persistence and realtime updates.
abstract class TripRepository {
  Future<String> createTrip(CreateTripInput input);

  Stream<TripRecord?> watchTrip(String tripId);

  Future<TripRecord?> getTrip(String tripId);

  Stream<List<TripRecord>> watchClientTrips(String clientId);

  Future<void> cancelTripByClient(String tripId);

  Future<void> submitTripRating({
    required String tripId,
    required String clientId,
    required int stars,
    String? feedback,
  });
}
