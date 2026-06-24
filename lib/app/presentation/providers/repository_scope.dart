import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_ent_280/features/auth/application/providers/auth_domain_providers.dart';
import 'package:local_ent_280/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_ent_280/features/trips/application/providers/trip_domain_providers.dart';
import 'package:local_ent_280/features/trips/domain/repositories/trip_repository.dart';

AuthRepository authRepositoryOf(BuildContext context) {
  return ProviderScope.containerOf(context).read(authRepositoryProvider);
}

TripRepository tripRepositoryOf(BuildContext context) {
  return ProviderScope.containerOf(context).read(tripRepositoryProvider);
}
