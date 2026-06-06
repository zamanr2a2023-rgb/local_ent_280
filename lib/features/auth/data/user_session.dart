import 'package:flutter/foundation.dart';
import 'package:local_ent_280/features/auth/data/models/app_user_profile.dart';

/// In-memory session for the authenticated Firestore user profile.
class UserSession extends ChangeNotifier {
  UserSession._();

  static final UserSession instance = UserSession._();

  AppUserProfile? _profile;

  AppUserProfile? get profile => _profile;

  bool get isAuthenticated => _profile != null;

  void setProfile(AppUserProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  void clear() {
    _profile = null;
    notifyListeners();
  }
}
