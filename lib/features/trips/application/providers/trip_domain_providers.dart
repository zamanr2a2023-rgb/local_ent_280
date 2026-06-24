import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_ent_280/features/trips/domain/repositories/trip_repository.dart';
import 'package:local_ent_280/features/trips/domain/usecases/create_trip.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  throw UnimplementedError('TripRepository deve ser fornecido via override.');
});

final createTripProvider = Provider<CreateTrip>((ref) {
  return CreateTrip(ref.watch(tripRepositoryProvider));
});
