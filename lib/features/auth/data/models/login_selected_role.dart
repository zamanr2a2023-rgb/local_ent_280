import 'package:local_ent_280/features/auth/data/models/app_user_role.dart';

/// Role chosen on the login screen before credentials are checked.
enum LoginSelectedRole {
  client,
  professional;

  AppUserRole get expectedAppRole => switch (this) {
        LoginSelectedRole.client => AppUserRole.client,
        LoginSelectedRole.professional => AppUserRole.driver,
      };

  /// Client tab accepts clients only; professional tab accepts staff roles.
  bool matchesProfileRole(AppUserRole profileRole) => switch (this) {
        LoginSelectedRole.client => profileRole == AppUserRole.client,
        LoginSelectedRole.professional =>
          profileRole == AppUserRole.driver || profileRole == AppUserRole.admin,
      };
}