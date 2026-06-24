import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/auth/domain/entities/auth_status.dart';
import 'package:local_transport/features/auth/domain/entities/manager_permissions_snapshot.dart';
import 'package:local_transport/features/auth/domain/entities/password_help_request_result.dart';
import 'package:local_transport/features/auth/domain/entities/profile_role.dart';
import 'package:local_transport/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_transport/features/auth/domain/usecases/get_current_user_id.dart';
import 'package:local_transport/features/driver/domain/entities/driver_location.dart';
import 'package:local_transport/features/driver/domain/entities/driver_status.dart';
import 'package:local_transport/features/driver/domain/entities/driver_tracking_failure.dart';
import 'package:local_transport/features/driver/domain/repositories/driver_device_location_repository.dart';
import 'package:local_transport/features/driver/domain/repositories/driver_heartbeat_store.dart';
import 'package:local_transport/features/driver/domain/repositories/driver_location_repository.dart';
import 'package:local_transport/features/driver/domain/repositories/driver_presence_store.dart';
import 'package:local_transport/features/driver/domain/repositories/driver_status_store.dart';
import 'package:local_transport/features/driver/domain/services/driver_location_sharing_coordinator.dart';
import 'package:local_transport/features/driver/domain/usecases/driver_location_streamer.dart';
import 'package:local_transport/features/driver/domain/usecases/get_driver_status_for_driver.dart';
import 'package:local_transport/features/driver/domain/usecases/is_background_tracking_trip_state.dart';
import 'package:local_transport/features/driver/domain/usecases/save_driver_status_for_driver.dart';
import 'package:local_transport/features/driver/domain/usecases/should_share_driver_location.dart';
import 'package:local_transport/features/driver/presentation/providers/driver_home_controller.dart';

void main() {
  test(
    'backfills missing driver status fields only once per session',
    () async {
      final statusStore = _FakeDriverStatusStore(
        fetchedStatus: const DriverStatus(isAvailable: false),
      );
      final controller = DriverHomeController(
        getCurrentUserId: GetCurrentUserId(_FakeAuthRepository(userId: 'd1')),
        getDriverStatusForDriver: GetDriverStatusForDriver(statusStore),
        saveDriverStatusForDriver: SaveDriverStatusForDriver(
          statusStore,
          _FakeDriverPresenceStore(),
        ),
        driverDeviceLocationRepository: _FakeDriverDeviceLocationRepository(),
        locationSharingCoordinator: _FakeDriverLocationSharingCoordinator(
          streamingAfterAvailabilitySync: true,
        ),
      );

      await _waitForDriverHomeIdle(controller);
      expect(statusStore.saveCalls, 1);

      await controller.refresh();
      await _waitForDriverHomeIdle(controller);

      expect(statusStore.saveCalls, 1);

      controller.dispose();
    },
  );

  test(
    'toggle availability releases UI after status save even if presence sync is pending',
    () async {
      final statusStore = _FakeDriverStatusStore(
        fetchedStatus: const DriverStatus(
          isAvailable: false,
          isActive: true,
          availabilityEnabled: true,
        ),
      );
      final presenceStore = _CompleterDriverPresenceStore();
      final controller = DriverHomeController(
        getCurrentUserId: GetCurrentUserId(_FakeAuthRepository(userId: 'd1')),
        getDriverStatusForDriver: GetDriverStatusForDriver(statusStore),
        saveDriverStatusForDriver: SaveDriverStatusForDriver(
          statusStore,
          presenceStore,
        ),
        driverDeviceLocationRepository: _FakeDriverDeviceLocationRepository(),
        locationSharingCoordinator: _FakeDriverLocationSharingCoordinator(
          streamingAfterAvailabilitySync: true,
        ),
      );

      await _waitForDriverHomeIdle(controller);

      unawaited(controller.toggleAvailability(true));
      await _waitForCondition(
        () => statusStore.saveCalls == 1 && !controller.state.isLoading,
        debugLabel: 'toggle true concluir save inicial e libertar loading',
      );

      expect(statusStore.saveCalls, 1);
      expect(presenceStore.syncCalls, 1);
      expect(controller.state.isAvailable, true);
      expect(controller.state.isLoading, false);

      presenceStore.completeSync();
      controller.dispose();
    },
  );

  test(
    'reverts availability when tracking cannot arm a live session',
    () async {
      final statusStore = _FakeDriverStatusStore(
        fetchedStatus: const DriverStatus(
          isAvailable: false,
          isActive: true,
          availabilityEnabled: true,
        ),
      );
      final controller = DriverHomeController(
        getCurrentUserId: GetCurrentUserId(_FakeAuthRepository(userId: 'd1')),
        getDriverStatusForDriver: GetDriverStatusForDriver(statusStore),
        saveDriverStatusForDriver: SaveDriverStatusForDriver(
          statusStore,
          _FakeDriverPresenceStore(),
        ),
        driverDeviceLocationRepository: _FakeDriverDeviceLocationRepository(),
        locationSharingCoordinator: _FakeDriverLocationSharingCoordinator(
          streamingAfterAvailabilitySync: false,
        ),
      );

      await _waitForDriverHomeIdle(controller);
      await controller.toggleAvailability(true);
      await _waitForCondition(
        () =>
            statusStore.saveCalls == 2 &&
            controller.state.errorType == DriverHomeErrorType.locationFailed,
        debugLabel: 'reversão para indisponível após falha de tracking',
      );

      expect(statusStore.saveCalls, 2);
      expect(controller.state.isAvailable, false);
      expect(controller.state.isStreaming, false);
      expect(controller.state.errorType, DriverHomeErrorType.locationFailed);
      expect(
        (controller.locationSharingCoordinator
                as _FakeDriverLocationSharingCoordinator)
            .updateAvailabilityCalls,
        [false, true, false],
      );

      controller.dispose();
    },
  );

  test(
    'ignores stale availability sync when user toggles again',
    () async {
      final statusStore = _FakeDriverStatusStore(
        fetchedStatus: const DriverStatus(
          isAvailable: false,
          isActive: true,
          availabilityEnabled: true,
        ),
      );
      final locationCoordinator = _FakeDriverLocationSharingCoordinator(
        streamingAfterAvailabilitySync: false,
        trueAvailabilitySyncCompleter: Completer<void>(),
      );
      final controller = DriverHomeController(
        getCurrentUserId: GetCurrentUserId(_FakeAuthRepository(userId: 'd1')),
        getDriverStatusForDriver: GetDriverStatusForDriver(statusStore),
        saveDriverStatusForDriver: SaveDriverStatusForDriver(
          statusStore,
          _FakeDriverPresenceStore(),
        ),
        driverDeviceLocationRepository: _FakeDriverDeviceLocationRepository(),
        locationSharingCoordinator: locationCoordinator,
      );

      await _waitForDriverHomeIdle(controller);

      unawaited(controller.toggleAvailability(true));
      await _waitForCondition(
        () => locationCoordinator.updateAvailabilityCalls.contains(true),
        debugLabel: 'sync de disponibilidade=true iniciar no coordenador',
      );

      await controller.toggleAvailability(false);
      await _waitForCondition(
        () => locationCoordinator.updateAvailabilityCalls.contains(false),
        debugLabel: 'sync de disponibilidade=false iniciar no coordenador',
      );

      locationCoordinator.completeTrueAvailabilitySync();
      await _waitForCondition(
        () => !controller.state.isLoading,
        debugLabel:
            'controller finalizar atualização após completar sync stale',
      );

      expect(statusStore.saveCalls, 2);
      expect(controller.state.isAvailable, false);
      expect(controller.state.errorType, isNull);
      expect(
        locationCoordinator.updateAvailabilityCalls,
        [false, true, false],
      );

      controller.dispose();
    },
  );

  test(
    'updates UI to unavailable when coordinator reports critical tracking failure',
    () async {
      final locationCoordinator = _FakeDriverLocationSharingCoordinator(
        streamingAfterAvailabilitySync: true,
      );
      final controller = DriverHomeController(
        getCurrentUserId: GetCurrentUserId(_FakeAuthRepository(userId: 'd1')),
        getDriverStatusForDriver: GetDriverStatusForDriver(
          _FakeDriverStatusStore(
            fetchedStatus: const DriverStatus(
              isAvailable: true,
              isActive: true,
              availabilityEnabled: true,
            ),
          ),
        ),
        saveDriverStatusForDriver: SaveDriverStatusForDriver(
          _FakeDriverStatusStore(
            fetchedStatus: const DriverStatus(
              isAvailable: true,
              isActive: true,
              availabilityEnabled: true,
            ),
          ),
          _FakeDriverPresenceStore(),
        ),
        driverDeviceLocationRepository: _FakeDriverDeviceLocationRepository(),
        locationSharingCoordinator: locationCoordinator,
      );

      await _waitForDriverHomeIdle(controller);
      locationCoordinator.emitTrackingFailure('d1');

      await _waitForCondition(
        () => controller.state.errorType == DriverHomeErrorType.locationFailed,
        debugLabel: 'home refletir falha crítica de tracking',
      );

      expect(controller.state.isAvailable, false);
      expect(controller.state.isStreaming, false);

      controller.dispose();
    },
  );
}

Future<void> _waitForDriverHomeIdle(DriverHomeController controller) async {
  await _waitForCondition(
    () => !controller.state.isLoading,
    debugLabel: 'driver home sair de loading',
  );
}

Future<void> _waitForCondition(
  bool Function() predicate, {
  required String debugLabel,
}) async {
  for (var attempt = 0; attempt < 30; attempt += 1) {
    if (predicate()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Condição não atingida no tempo esperado: $debugLabel');
}

class _FakeDriverStatusStore implements DriverStatusStore {
  _FakeDriverStatusStore({required this.fetchedStatus});

  final DriverStatus fetchedStatus;
  int saveCalls = 0;

  @override
  Future<DriverStatus?> fetchStatus(String driverId) async => fetchedStatus;

  @override
  Future<void> saveStatus(String driverId, DriverStatus status) async {
    saveCalls += 1;
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

class _CompleterDriverPresenceStore implements DriverPresenceStore {
  int syncCalls = 0;
  final Completer<void> _syncCompleter = Completer<void>();

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
  }) {
    syncCalls += 1;
    return _syncCompleter.future;
  }

  @override
  Future<void> updateHeartbeat(String driverId) async {}

  void completeSync() {
    if (!_syncCompleter.isCompleted) {
      _syncCompleter.complete();
    }
  }
}

class _FakeDriverLocationSharingCoordinator
    extends DriverLocationSharingCoordinator {
  _FakeDriverLocationSharingCoordinator({
    this.streamingAfterAvailabilitySync = false,
    this.trueAvailabilitySyncCompleter,
  }) : super(
         saveDriverStatusForDriver: SaveDriverStatusForDriver(
           _FakeDriverStatusStore(
             fetchedStatus: const DriverStatus(
               isAvailable: false,
               isActive: true,
               availabilityEnabled: true,
             ),
           ),
           _FakeDriverPresenceStore(),
         ),
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
         isBackgroundTrackingTripState: const IsBackgroundTrackingTripState(),
       );

  final bool streamingAfterAvailabilitySync;
  final Completer<void>? trueAvailabilitySyncCompleter;
  final StreamController<DriverTrackingFailure> _failureController =
      StreamController<DriverTrackingFailure>.broadcast();
  bool _isStreaming = false;
  final List<bool> updateAvailabilityCalls = <bool>[];

  @override
  bool get isStreaming => _isStreaming;

  @override
  Stream<DriverTrackingFailure> get failures => _failureController.stream;

  @override
  Future<void> updateAvailability(
    bool isAvailable, {
    DriverLocation? initialLocation,
  }) async {
    updateAvailabilityCalls.add(isAvailable);
    if (isAvailable && trueAvailabilitySyncCompleter != null) {
      await trueAvailabilitySyncCompleter!.future;
    }
    _isStreaming = isAvailable && streamingAfterAvailabilitySync;
  }

  void completeTrueAvailabilitySync() {
    if (trueAvailabilitySyncCompleter != null &&
        !trueAvailabilitySyncCompleter!.isCompleted) {
      trueAvailabilitySyncCompleter!.complete();
    }
  }

  void emitTrackingFailure(String driverId) {
    _failureController.add(
      DriverTrackingFailure.realtimeDbPermissionDenied(
        driverId: driverId,
        action: 'update',
        path: '/driverLocations/$driverId',
        currentAuthenticatedUid: null,
        targetUserId: driverId,
      ),
    );
  }
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
  }) {
    return const Stream<DriverLocation>.empty();
  }
}

class _FakeDriverLocationRepository implements DriverLocationRepository {
  @override
  Future<void> clearLocation(String driverId) async {}

  @override
  Future<void> updateLocation(String driverId, DriverLocation location) async {}

  @override
  Stream<DriverLocation?> watchLocation(String driverId) {
    return const Stream<DriverLocation?>.empty();
  }
}

class _FakeDriverHeartbeatStore implements DriverHeartbeatStore {
  @override
  Future<void> updateLastSeenAt(String driverId) async {}
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.userId});

  final String? userId;

  @override
  String? currentUserId() => userId;

  @override
  String? currentUserEmail() => null;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ManagerPermissionsSnapshot> fetchManagerPermissions({
    bool forceRefresh = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ProfileRole> fetchProfileRole() {
    throw UnimplementedError();
  }

  @override
  Future<AuthStatus> fetchStatus() {
    throw UnimplementedError();
  }

  @override
  Future<PasswordHelpRequestResult> requestPasswordHelp({
    required String emailOrLogin,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  Stream<AuthStatus> watchStatus() {
    throw UnimplementedError();
  }
}
