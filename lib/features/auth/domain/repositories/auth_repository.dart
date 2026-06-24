import 'package:firebase_auth/firebase_auth.dart';

import 'package:local_ent_280/features/auth/data/auth_signing.dart';
import 'package:local_ent_280/features/auth/data/models/app_user_profile.dart';

/// Domain contract for authentication and session restore.
abstract class AuthRepository implements AuthSigning {
  User? get currentUser;

  Future<AppUserProfile?> fetchUserProfile(String uid);

  Future<AppUserProfile?> restoreSession();

  Future<void> signOut();
}
