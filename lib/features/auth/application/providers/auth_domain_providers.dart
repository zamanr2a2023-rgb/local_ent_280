import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_ent_280/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_ent_280/features/auth/domain/usecases/restore_session.dart';
import 'package:local_ent_280/features/auth/domain/usecases/sign_in_with_email_password.dart';
import 'package:local_ent_280/features/auth/domain/usecases/sign_out.dart';
import 'package:local_ent_280/features/auth/domain/usecases/sign_up.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('AuthRepository deve ser fornecido via override.');
});

final restoreSessionProvider = Provider<RestoreSession>((ref) {
  return RestoreSession(ref.watch(authRepositoryProvider));
});

final signInWithEmailPasswordProvider = Provider<SignInWithEmailPassword>((
  ref,
) {
  return SignInWithEmailPassword(ref.watch(authRepositoryProvider));
});

final signUpProvider = Provider<SignUp>((ref) {
  return SignUp(ref.watch(authRepositoryProvider));
});

final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(ref.watch(authRepositoryProvider));
});
