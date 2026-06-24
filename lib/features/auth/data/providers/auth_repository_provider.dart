import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_ent_280/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:local_ent_280/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_ent_280/features/notifications/data/providers/notification_token_repository_provider.dart';

final authRepositoryImplementationProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    notificationTokenRepository:
        ref.watch(notificationTokenRepositoryImplementationProvider),
  );
});
