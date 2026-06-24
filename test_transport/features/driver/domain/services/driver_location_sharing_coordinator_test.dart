import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
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
import 'package:local_transport/features/driver/domain/usecases/is_background_tracking_trip_state.dart';
import 'package:local_transport/features/driver/domain/usecases/save_driver_status_for_driver.dart';
import 'package:local_transport/features/driver/domain/usecases/should_share_driver_location.dart';

void main() {
  test(
    'ignora falha ao iniciar tracking e mantém stream desligado',
    () async {
      final streamer = _ThrowingDriverLocationStreamer();
      final presenceStore = _FakeDriverPresenceStore();
      final coordinator = DriverLocationSharingCoordinator(
        streamer: streamer,
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

      await coordinator.setDriverContext(
        driverId: 'driver-1',
        isAvailable: true,
      );

      expect(streamer.startCalls, 1);
      expect(streamer.stopCalls, 1);
      expect(coordinator.isStreaming, false);
      expect(presenceStore.startSessionCalls, 1);
    },
  );

  test(
    'não propaga erro quando a limpeza do stream também falha',
    () async {
      final streamer = _ThrowingDriverLocationStreamer(throwOnStop: true);
      final coordinator = DriverLocationSharingCoordinator(
        streamer: streamer,
        shouldShareDriverLocation: const ShouldShareDriverLocation(
          IsBackgroundTrackingTripState(),
        ),
        presenceStore: _FakeDriverPresenceStore(),
        isBackgroundTrackingTripState: const IsBackgroundTrackingTripState(),
        saveDriverStatusForDriver: SaveDriverStatusForDriver(
          _FakeDriverStatusStore(),
          _FakeDriverPresenceStore(),
        ),
      );

      await coordinator.setDriverContext(
        driverId: 'driver-1',
        isAvailable: true,
      );

      expect(streamer.startCalls, 1);
      expect(streamer.stopCalls, 1);
      expect(coordinator.isStreaming, false);
    },
  );

  test(
    'desativa disponibilidade quando o streamer reporta falha crítica RTDB',
    () async {
      final streamer = _ControllableDriverLocationStreamer();
      final statusStore = _FakeDriverStatusStore();
      final presenceStore = _FakeDriverPresenceStore();
      final coordinator = DriverLocationSharingCoordinator(
        streamer: streamer,
        shouldShareDriverLocation: const ShouldShareDriverLocation(
          IsBackgroundTrackingTripState(),
        ),
        presenceStore: presenceStore,
        isBackgroundTrackingTripState: const IsBackgroundTrackingTripState(),
        saveDriverStatusForDriver: SaveDriverStatusForDriver(
          statusStore,
          presenceStore,
        ),
      );

      await coordinator.setDriverContext(
        driverId: 'driver-1',
        isAvailable: true,
      );
      streamer.emitPermissionDenied('driver-1');

      await _waitForCondition(
        () => statusStore.savedStatuses.isNotEmpty && !coordinator.isStreaming,
        debugLabel: 'persistir indisponibilidade após falha crítica RTDB',
      );

      expect(statusStore.savedStatuses.single.isAvailable, false);
      expect(streamer.stopCalls, greaterThanOrEqualTo(1));
    },
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

class _ThrowingDriverLocationStreamer extends DriverLocationStreamer {
  _ThrowingDriverLocationStreamer({this.throwOnStop = false})
    : super(
        _FakeDriverDeviceLocationRepository(),
        _FakeDriverLocationRepository(),
        _FakeDriverHeartbeatStore(),
        _FakeDriverPresenceStore(),
      );

  final bool throwOnStop;
  int startCalls = 0;
  int stopCalls = 0;

  @override
  bool get isRunning => false;

  @override
  Future<void> start({
    required String driverId,
    required int deviceDistanceThresholdMeters,
    required Duration presenceHeartbeatInterval,
    required Duration locationKeepAliveInterval,
    required int movementThresholdMeters,
    DriverLocation? initialLocation,
  }) async {
    startCalls += 1;
    throw StateError('permission-denied');
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
    if (throwOnStop) {
      throw StateError('stop failed');
    }
  }
}

class _ControllableDriverLocationStreamer extends DriverLocationStreamer {
  _ControllableDriverLocationStreamer()
    : _failureController = StreamController<DriverTrackingFailure>.broadcast(),
      super(
        _FakeDriverDeviceLocationRepository(),
        _FakeDriverLocationRepository(),
        _FakeDriverHeartbeatStore(),
        _FakeDriverPresenceStore(),
      );

  final StreamController<DriverTrackingFailure> _failureController;
  bool _isRunning = false;
  int stopCalls = 0;

  @override
  Stream<DriverTrackingFailure> get failures => _failureController.stream;

  @override
  bool get isRunning => _isRunning;

  @override
  Future<void> start({
    required String driverId,
    required int deviceDistanceThresholdMeters,
    required Duration presenceHeartbeatInterval,
    required Duration locationKeepAliveInterval,
    required int movementThresholdMeters,
    DriverLocation? initialLocation,
  }) async {
    _isRunning = true;
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
    _isRunning = false;
  }

  void emitPermissionDenied(String driverId) {
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

class _FakeDriverPresenceStore implements DriverPresenceStore {
  int startSessionCalls = 0;

  @override
  Future<void> startSession({
    required String driverId,
    required bool isAvailable,
  }) async {
    startSessionCalls += 1;
  }

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
  Future<DriverLocation> fetchCurrentLocation() async {
    return const DriverLocation(
      latitude: 0,
      longitude: 0,
    );
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

class _FakeDriverStatusStore implements DriverStatusStore {
  final List<DriverStatus> savedStatuses = <DriverStatus>[];

  @override
  Future<DriverStatus?> fetchStatus(String driverId) async => null;

  @override
  Future<void> saveStatus(String driverId, DriverStatus status) async {
    savedStatuses.add(status);
  }
}
