import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_ent_280/core/data/notifications/providers/flutter_local_notification_service_provider.dart';
import 'package:local_ent_280/core/services/providers/local_notification_service_provider.dart';
import 'package:local_ent_280/features/auth/application/providers/auth_domain_providers.dart';
import 'package:local_ent_280/features/auth/data/providers/auth_repository_provider.dart';
import 'package:local_ent_280/features/notifications/application/providers/notification_domain_providers.dart';
import 'package:local_ent_280/features/notifications/data/providers/notification_event_repository_provider.dart';
import 'package:local_ent_280/features/notifications/data/providers/notification_token_repository_provider.dart';
import 'package:local_ent_280/features/trips/application/providers/trip_domain_providers.dart';
import 'package:local_ent_280/features/trips/data/providers/trip_repository_provider.dart';

List<Override> buildProviderOverrides() {
  return <Override>[
    localNotificationServiceProvider.overrideWith((ref) {
      return ref.watch(localNotificationServiceImplementationProvider);
    }),
    notificationTokenRepositoryProvider.overrideWith((ref) {
      return ref.watch(notificationTokenRepositoryImplementationProvider);
    }),
    notificationEventRepositoryProvider.overrideWith((ref) {
      return ref.watch(notificationEventRepositoryImplementationProvider);
    }),
    authRepositoryProvider.overrideWith((ref) {
      return ref.watch(authRepositoryImplementationProvider);
    }),
    tripRepositoryProvider.overrideWith((ref) {
      return ref.watch(tripRepositoryImplementationProvider);
    }),
  ];
}
