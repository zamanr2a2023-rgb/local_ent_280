import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_ent_280/features/auth/application/providers/auth_domain_providers.dart';
import 'package:local_ent_280/features/auth/data/providers/auth_repository_provider.dart';
import 'package:local_ent_280/features/trips/application/providers/trip_domain_providers.dart';
import 'package:local_ent_280/features/trips/data/providers/trip_repository_provider.dart';

List<Override> buildProviderOverrides() {
  return <Override>[
    authRepositoryProvider.overrideWith((ref) {
      return ref.watch(authRepositoryImplementationProvider);
    }),
    tripRepositoryProvider.overrideWith((ref) {
      return ref.watch(tripRepositoryImplementationProvider);
    }),
  ];
}
