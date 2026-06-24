import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_ent_280/features/trips/data/repositories/trip_repository_impl.dart';
import 'package:local_ent_280/features/trips/domain/repositories/trip_repository.dart';

final tripRepositoryImplementationProvider = Provider<TripRepository>((ref) {
  return TripRepositoryImpl();
});
