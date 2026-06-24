import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/auth/domain/entities/auth_status.dart';
import 'package:local_transport/features/auth/domain/entities/manager_permissions_snapshot.dart';
import 'package:local_transport/features/auth/domain/entities/password_help_request_result.dart';
import 'package:local_transport/features/auth/domain/entities/profile_role.dart';
import 'package:local_transport/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_transport/features/auth/domain/usecases/get_current_user_id.dart';
import 'package:local_transport/features/auth/domain/usecases/get_profile_role.dart';
import 'package:local_transport/features/auth/domain/usecases/logout_user.dart';
import 'package:local_transport/features/auth/domain/usecases/sign_out.dart';
import 'package:local_transport/features/driver/domain/entities/driver_location.dart';
import 'package:local_transport/features/driver/domain/entities/driver_status.dart';
import 'package:local_transport/features/driver/domain/repositories/driver_device_location_repository.dart';
import 'package:local_transport/features/driver/domain/repositories/driver_heartbeat_store.dart';
import 'package:local_transport/features/driver/domain/repositories/driver_location_repository.dart';
import 'package:local_transport/features/driver/domain/repositories/driver_presence_store.dart';
import 'package:local_transport/features/driver/domain/repositories/driver_status_store.dart';
import 'package:local_transport/features/driver/domain/services/driver_location_sharing_coordinator.dart';
import 'package:local_transport/features/driver/domain/usecases/cleanup_driver_session.dart';
import 'package:local_transport/features/driver/domain/usecases/driver_location_streamer.dart';
import 'package:local_transport/features/driver/domain/usecases/is_background_tracking_trip_state.dart';
import 'package:local_transport/features/driver/domain/usecases/save_driver_status_for_driver.dart';
import 'package:local_transport/features/driver/domain/usecases/should_share_driver_location.dart';
import 'package:local_transport/features/notifications/domain/repositories/notification_token_repository.dart';
import 'package:local_transport/features/notifications/domain/usecases/remove_notification_token.dart';

void main() {
  group('LogoutUser', () {
    test(
      'continues to sign out when driver cleanup stalls',
      () async {
        final authRepository = _FakeAuthRepository(role: ProfileRole.driver);
        final notificationRepository = _FakeNotificationTokenRepository();
        final presenceStore = _NeverCompletingStopPresenceStore();
        final locationSharingCoordinator = DriverLocationSharingCoordinator(
          streamer: DriverLocationStreamer(
            _FakeDriverDeviceLocationRepository(),
            _FakeDriverLocationRepository(),
            _FakeDriverHeartbeatStore(),
            presenceStore,
          ),
          shouldShareDriverLocation: const ShouldShareDriverLocation(
            IsBackgroundTrackingTripState(),
          ),
          presenceStore: presenceStore,
          isBackgroundTrackingTripState: const IsBackgroundTrackingTripState(),
          saveDriverStatusForDriver: SaveDriverStatusForDriver(
            _FakeDriverStatusStore(),
            presenceStore,
          ),
        );
        await locationSharingCoordinator.setDriverContext(
          driverId: 'driver_1',
          isAvailable: false,
        );
        final useCase = LogoutUser(
          signOut: SignOut(authRepository),
          getProfileRole: GetProfileRole(authRepository),
          getCurrentUserId: GetCurrentUserId(authRepository),
          cleanupDriverSession: CleanupDriverSession(
            statusStore: _FakeDriverStatusStore(),
            locationRepository: _FakeDriverLocationRepository(),
            locationSharingCoordinator: locationSharingCoordinator,
          ),
          removeNotificationToken: RemoveNotificationToken(
            notificationRepository,
          ),
        );

        await useCase();

        expect(authRepository.signOutCalls, 1);
        expect(notificationRepository.removeCalls, 1);
        expect(presenceStore.stopCalls, 1);
      },
      timeout: const Timeout(Duration(seconds: 7)),
    );

    test(
      'continues to sign out when notification token removal stalls',
      () async {
        final authRepository = _FakeAuthRepository(role: ProfileRole.driver);
        final notificationRepository =
            _NeverCompletingNotificationTokenRepository();
        final useCase = LogoutUser(
          signOut: SignOut(authRepository),
          getProfileRole: GetProfileRole(authRepository),
          getCurrentUserId: GetCurrentUserId(authRepository),
          cleanupDriverSession: CleanupDriverSession(
            statusStore: _FakeDriverStatusStore(),
            locationRepository: _FakeDriverLocationRepository(),
            locationSharingCoordinator: DriverLocationSharingCoordinator(
              streamer: DriverLocationStreamer(
                _FakeDriverDeviceLocationRepository(),
                _FakeDriverLocationRepository(),
                _FakeDriverHeartbeatStore(),
                _FakeDriverPresenceStore(),
              ),
              shouldShareDriverLocation: const ShouldShareDriverLocation(
                IsBackgroundTrackingTripState(),
              ),
              presenceStore: _FakeDriverPresenceStore(),
              isBackgroundTrackingTripState:
                  const IsBackgroundTrackingTripState(),
              saveDriverStatusForDriver: SaveDriverStatusForDriver(
                _FakeDriverStatusStore(),
                _FakeDriverPresenceStore(),
              ),
            ),
          ),
          removeNotificationToken: RemoveNotificationToken(
            notificationRepository,
          ),
        );

        await useCase();

        expect(authRepository.signOutCalls, 1);
        expect(notificationRepository.removeCalls, 1);
      },
      timeout: const Timeout(Duration(seconds: 7)),
    );
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.role});

  final ProfileRole role;
  int signOutCalls = 0;

  @override
  String? currentUserEmail() => null;

  @override
  String? currentUserId() => 'driver_1';

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}

  @override
  Future<ManagerPermissionsSnapshot> fetchManagerPermissions({
    bool forceRefresh = false,
  }) async {
    return ManagerPermissionsSnapshot.managerBlocked();
  }

  @override
  Future<ProfileRole> fetchProfileRole() async => role;

  @override
  Future<AuthStatus> fetchStatus() async {
    return AuthStatus(isAvailable: true, role: role);
  }

  @override
  Future<PasswordHelpRequestResult> requestPasswordHelp({
    required String emailOrLogin,
  }) async {
    return const PasswordHelpRequestResult(ok: true);
  }

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
  }

  @override
  Stream<AuthStatus> watchStatus() => const Stream<AuthStatus>.empty();
}

class _FakeNotificationTokenRepository implements NotificationTokenRepository {
  int removeCalls = 0;

  @override
  Future<void> registerToken({
    required String token,
    required String userId,
  }) async {}

  @override
  Future<void> removeCurrentToken({required String userId}) async {
    removeCalls += 1;
  }
}

class _NeverCompletingNotificationTokenRepository
    implements NotificationTokenRepository {
  int removeCalls = 0;

  @override
  Future<void> registerToken({
    required String token,
    required String userId,
  }) async {}

  @override
  Future<void> removeCurrentToken({required String userId}) {
    removeCalls += 1;
    return Completer<void>().future;
  }
}

class _FakeDriverStatusStore implements DriverStatusStore {
  DriverStatus? lastStatus;

  @override
  Future<DriverStatus?> fetchStatus(String driverId) async => lastStatus;

  @override
  Future<void> saveStatus(String driverId, DriverStatus status) async {
    lastStatus = status;
  }
}

class _FakeDriverLocationRepository implements DriverLocationRepository {
  int clearCalls = 0;

  @override
  Future<void> clearLocation(String driverId) async {
    clearCalls += 1;
  }

  @override
  Future<void> updateLocation(String driverId, DriverLocation location) async {}

  @override
  Stream<DriverLocation?> watchLocation(String driverId) =>
      const Stream<DriverLocation?>.empty();
}

class _FakeDriverDeviceLocationRepository
    implements DriverDeviceLocationRepository {
  @override
  Future<DriverLocation> fetchCurrentLocation() async {
    return const DriverLocation(latitude: 0, longitude: 0);
  }

  @override
  Stream<DriverLocation> watchLocationUpdates({
    required int distanceThresholdMeters,
  }) => const Stream<DriverLocation>.empty();
}

class _FakeDriverHeartbeatStore implements DriverHeartbeatStore {
  @override
  Future<void> updateLastSeenAt(String driverId) async {}
}

class _FakeDriverPresenceStore implements DriverPresenceStore {
  @override
  Future<void> startSession({
    required String driverId,
    required bool isAvailable,
  }) async {}

  @override
  Future<void> stopSession(String driverId) async {}

  @override
  Future<void> syncAvailability({
    required String driverId,
    required bool isAvailable,
  }) async {}

  @override
  Future<void> updateHeartbeat(String driverId) async {}
}

class _NeverCompletingStopPresenceStore implements DriverPresenceStore {
  int stopCalls = 0;

  @override
  Future<void> startSession({
    required String driverId,
    required bool isAvailable,
  }) async {}

  @override
  Future<void> stopSession(String driverId) {
    stopCalls += 1;
    return Completer<void>().future;
  }

  @override
  Future<void> syncAvailability({
    required String driverId,
    required bool isAvailable,
  }) async {}

  @override
  Future<void> updateHeartbeat(String driverId) async {}
}
