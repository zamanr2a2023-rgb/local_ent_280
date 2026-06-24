import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_ent_280/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:local_ent_280/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryImplementationProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});
