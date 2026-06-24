import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/auth/domain/entities/user_profile.dart';
import 'package:local_transport/features/auth/domain/repositories/user_profile_repository.dart';

class FakeUserProfileRepository implements UserProfileRepository {
  FakeUserProfileRepository({
    Map<String, UserProfile> profiles = const <String, UserProfile>{},
  }) : _profiles = <String, UserProfile>{...profiles};

  final Map<String, UserProfile> _profiles;

  void seedProfile(UserProfile profile) {
    _profiles[profile.uid] = profile;
  }

  @override
  Future<void> createProfile(UserProfile profile) async {
    _profiles[profile.uid] = profile;
  }

  @override
  Future<UserProfile?> fetchProfile(String uid) async {
    return _profiles[uid];
  }

  @override
  Future<void> updateUiCurrency({
    required String uid,
    required CurrencyCode uiCurrency,
  }) async {
    final profile = _profiles[uid];
    if (profile == null) {
      return;
    }
    _profiles[uid] = UserProfile(
      uid: profile.uid,
      role: profile.role,
      name: profile.name,
      phone: profile.phone,
      isActive: profile.isActive,
      photoUrl: profile.photoUrl,
      discountPercentGlobal: profile.discountPercentGlobal,
      discountPercentByDistance: profile.discountPercentByDistance,
      discountFixed: profile.discountFixed,
      uiCurrency: uiCurrency,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }
}
