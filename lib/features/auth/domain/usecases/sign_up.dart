import 'package:local_ent_280/features/auth/data/models/app_user_profile.dart';
import 'package:local_ent_280/features/auth/data/models/login_selected_role.dart';
import 'package:local_ent_280/features/auth/domain/repositories/auth_repository.dart';

class SignUp {
  const SignUp(this._repository);

  final AuthRepository _repository;

  Future<AppUserProfile> call({
    required String name,
    required String email,
    required String password,
    required String phone,
    required LoginSelectedRole selectedRole,
  }) {
    return _repository.signUp(
      name: name,
      email: email,
      password: password,
      phone: phone,
      selectedRole: selectedRole,
    );
  }
}
