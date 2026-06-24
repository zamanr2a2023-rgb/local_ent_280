import 'package:flutter/widgets.dart';

import 'package:local_transport/features/auth/domain/entities/auth_status.dart';
import 'package:local_transport/features/auth/domain/entities/manager_permissions_snapshot.dart';
import 'package:local_transport/features/auth/domain/entities/password_help_request_result.dart';
import 'package:local_transport/features/auth/domain/entities/profile_role.dart';
import 'package:local_transport/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_transport/features/auth/domain/usecases/get_current_user_id.dart';
import 'package:local_transport/features/driver/domain/entities/driver_status.dart';
import 'package:local_transport/features/driver/domain/entities/driver_tracking_permission_status.dart';
import 'package:local_transport/features/driver/domain/repositories/driver_device_location_repository.dart';
import 'package:local_transport/features/driver/domain/repositories/driver_heartbeat_store.dart';
import 'package:local_transport/features/driver/domain/repositories/driver_location_repository.dart';
import 'package:local_transport/features/driver/domain/repositories/driver_presence_store.dart';
import 'package:local_transport/features/driver/domain/repositories/driver_status_store.dart';
import 'package:local_transport/features/driver/domain/services/driver_location_sharing_coordinator.dart';
import 'package:local_transport/features/driver/domain/services/driver_tracking_permission_service.dart';
import 'package:local_transport/features/driver/domain/usecases/driver_location_streamer.dart';
import 'package:local_transport/features/driver/domain/usecases/get_driver_status_for_driver.dart';
import 'package:local_transport/features/driver/domain/usecases/is_background_tracking_trip_state.dart';
import 'package:local_transport/features/driver/domain/usecases/save_driver_status_for_driver.dart';
import 'package:local_transport/features/driver/domain/usecases/should_share_driver_location.dart';
import 'package:local_transport/features/driver/presentation/providers/driver_background_tracking_runtime_controller.dart';
import 'package:local_transport/features/trips/domain/repositories/trip_repository.dart';
import 'package:local_transport/features/trips/domain/usecases/watch_active_trip_for_driver.dart';

class FakeDriverBackgroundTrackingRuntimeController
    extends DriverBackgroundTrackingRuntimeController {
  FakeDriverBackgroundTrackingRuntimeController({
    DriverBackgroundTrackingRuntimeState? initialState,
  }) : this._internal(
         initialState: initialState,
         sharedPresenceStore: _FakeDriverPresenceStore(),
         sharedStatusStore: _FakeDriverStatusStore(),
       );

  FakeDriverBackgroundTrackingRuntimeController._internal({
    DriverBackgroundTrackingRuntimeState? initialState,
    required _FakeDriverPresenceStore sharedPresenceStore,
    required _FakeDriverStatusStore sharedStatusStore,
  }) : super(
         getCurrentUserId: GetCurrentUserId(const _FakeDriverAuthRepository()),
         getDriverStatusForDriver: GetDriverStatusForDriver(sharedStatusStore),
         watchActiveTripForDriver: WatchActiveTripForDriver(
           _FakeTripRepository(),
         ),
         locationSharingCoordinator: DriverLocationSharingCoordinator(
           streamer: DriverLocationStreamer(
             _FakeDriverDeviceLocationRepository(),
             _FakeDriverLocationRepository(),
             _FakeDriverHeartbeatStore(),
             sharedPresenceStore,
           ),
           shouldShareDriverLocation: const ShouldShareDriverLocation(
             IsBackgroundTrackingTripState(),
           ),
           presenceStore: sharedPresenceStore,
           isBackgroundTrackingTripState: const IsBackgroundTrackingTripState(),
           saveDriverStatusForDriver: SaveDriverStatusForDriver(
             sharedStatusStore,
             sharedPresenceStore,
           ),
         ),
         driverTrackingPermissionService:
             _FakeDriverTrackingPermissionService(),
         shouldShareDriverLocation: const ShouldShareDriverLocation(
           IsBackgroundTrackingTripState(),
         ),
         isBackgroundTrackingTripState: const IsBackgroundTrackingTripState(),
       ) {
    state = initialState ?? DriverBackgroundTrackingRuntimeState.initial();
  }

  @override
  Future<void> activate() async {}

  @override
  Future<void> deactivate() async {
    state = DriverBackgroundTrackingRuntimeState.initial();
  }

  @override
  Future<void> handleAppLifecycleState(
    AppLifecycleState lifecycleState,
  ) async {}

  @override
  Future<void> handlePermissionDisclosureAccepted() async {}

  @override
  void handlePermissionDisclosureDeferred() {}

  @override
  void logDisclosureShown() {}

  @override
  Future<void> openPermissionSettings() async {}
}

class _FakeDriverAuthRepository implements AuthRepository {
  const _FakeDriverAuthRepository();

  @override
  String? currentUserEmail() => null;

  @override
  String? currentUserId() => 'driver-test';

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
  Future<ProfileRole> fetchProfileRole() async => ProfileRole.driver;

  @override
  Future<AuthStatus> fetchStatus() async {
    return const AuthStatus(isAvailable: true, role: ProfileRole.driver);
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
  Future<void> signOut() async {}

  @override
  Stream<AuthStatus> watchStatus() {
    return Stream<AuthStatus>.value(
      const AuthStatus(isAvailable: true, role: ProfileRole.driver),
    );
  }
}

class _FakeDriverStatusStore implements DriverStatusStore {
  @override
  Future<DriverStatus?> fetchStatus(String driverId) async {
    return const DriverStatus(isAvailable: true);
  }

  @override
  Future<void> saveStatus(String driverId, DriverStatus status) async {}
}

class _FakeTripRepository implements TripRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDriverTrackingPermissionService
    implements DriverTrackingPermissionService {
  @override
  Future<DriverTrackingPermissionStatus> getStatus() async {
    return DriverTrackingPermissionStatus.foregroundOnly;
  }

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;

  @override
  Future<DriverTrackingPermissionStatus> requestAlwaysPermission() async {
    return DriverTrackingPermissionStatus.alwaysGranted;
  }

  @override
  Future<DriverTrackingPermissionStatus> requestForegroundPermission() async {
    return DriverTrackingPermissionStatus.foregroundOnly;
  }
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

class _FakeDriverDeviceLocationRepository
    implements DriverDeviceLocationRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDriverLocationRepository implements DriverLocationRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDriverHeartbeatStore implements DriverHeartbeatStore {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
