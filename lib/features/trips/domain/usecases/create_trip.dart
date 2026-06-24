import 'package:local_ent_280/features/trips/domain/entities/create_trip_input.dart';
import 'package:local_ent_280/features/trips/domain/repositories/trip_repository.dart';

class CreateTrip {
  const CreateTrip(this._repository);

  final TripRepository _repository;

  Future<String> call(CreateTripInput input) => _repository.createTrip(input);
}
