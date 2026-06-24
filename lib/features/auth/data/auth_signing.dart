import 'package:local_ent_280/features/auth/data/models/app_user_profile.dart';
import 'package:local_ent_280/features/auth/data/models/login_selected_role.dart';

abstract class AuthSigning {
  Future<AppUserProfile> signIn({
    required String email,
    required String password,
    required LoginSelectedRole selectedRole,
  });

  Future<AppUserProfile> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required LoginSelectedRole selectedRole,
  });
}
