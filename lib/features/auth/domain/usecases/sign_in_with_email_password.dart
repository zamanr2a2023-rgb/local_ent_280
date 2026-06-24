import 'package:local_ent_280/features/auth/data/models/app_user_profile.dart';
import 'package:local_ent_280/features/auth/data/models/login_selected_role.dart';
import 'package:local_ent_280/features/auth/domain/repositories/auth_repository.dart';

class SignInWithEmailPassword {
  const SignInWithEmailPassword(this._repository);

  final AuthRepository _repository;

  Future<AppUserProfile> call({
    required String email,
    required String password,
    required LoginSelectedRole selectedRole,
  }) {
    return _repository.signIn(
      email: email,
      password: password,
      selectedRole: selectedRole,
    );
  }
}
