import 'package:local_ent_280/features/trips/data/models/trip_location.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';

class CreateTripInput {
  const CreateTripInput({
    required this.clientId,
    required this.pickup,
    required this.destination,
    required this.transportType,
    required this.distanceKm,
    required this.durationMinutes,
    required this.estimatedTotalMinor,
  });

  final String clientId;
  final TripLocation pickup;
  final TripLocation destination;
  final TripTransportType transportType;
  final double distanceKm;
  final int durationMinutes;
  final int estimatedTotalMinor;
}
