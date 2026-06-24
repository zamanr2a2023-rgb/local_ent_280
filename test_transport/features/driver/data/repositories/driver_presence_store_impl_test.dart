import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/data/firebase/realtime_db_service.dart';
import 'package:local_transport/features/driver/data/repositories/driver_presence_store_impl.dart';

void main() {
  group('DriverPresenceStoreImpl', () {
    test(
      'waits for pending connection update and skips stale online write on stop',
      () async {
        final realtimeDbService = _FakeRealtimeDbService();
        final store = DriverPresenceStoreImpl(realtimeDbService);

        await store.startSession(driverId: 'driver_1', isAvailable: true);

        realtimeDbService.emitConnectionState(true);
        await realtimeDbService.waitForOnDisconnectCall();

        var stopCompleted = false;
        final stopFuture = store.stopSession('driver_1').then((_) {
          stopCompleted = true;
        });

        await Future<void>.delayed(Duration.zero);
        expect(stopCompleted, isFalse);

        realtimeDbService.completePendingOnDisconnect();
        await stopFuture;

        expect(
          realtimeDbService.operations,
          <String>[
            'setOnDisconnect:/driverPresence/driver_1',
            'updateValue:/driverPresence/driver_1',
            'cancelOnDisconnect:/driverPresence/driver_1',
          ],
        );
        expect(
          realtimeDbService.updatePayloads,
          hasLength(1),
        );
        expect(
          realtimeDbService.updatePayloads.single['state'],
          'offline',
        );
      },
    );

    test('ignores heartbeat writes after session stop', () async {
      final realtimeDbService = _FakeRealtimeDbService();
      final store = DriverPresenceStoreImpl(realtimeDbService);

      await store.startSession(driverId: 'driver_1', isAvailable: false);
      await store.stopSession('driver_1');
      await store.updateHeartbeat('driver_1');

      expect(
        realtimeDbService.updatePayloads.where(
          (payload) => payload.containsKey('lastHeartbeatAt'),
        ),
        isEmpty,
      );
    });
  });
}

class _FakeRealtimeDbService implements RealtimeDbService {
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final List<String> operations = <String>[];
  final List<Map<String, Object?>> updatePayloads = <Map<String, Object?>>[];
  Completer<void>? _pendingOnDisconnectCompleter;
  Completer<void>? _onDisconnectCalledCompleter;

  void emitConnectionState(bool isConnected) {
    _connectionController.add(isConnected);
  }

  Future<void> waitForOnDisconnectCall() {
    final completer = _onDisconnectCalledCompleter ??= Completer<void>();
    return completer.future;
  }

  void completePendingOnDisconnect() {
    _pendingOnDisconnectCompleter?.complete();
    _pendingOnDisconnectCompleter = null;
  }

  @override
  Future<void> cancelOnDisconnect({required String path}) async {
    operations.add('cancelOnDisconnect:$path');
  }

  @override
  Future<void> clearValue({required String path}) async {}

  @override
  Future<Map<String, dynamic>?> fetchValue(String path) async => null;

  @override
  Future<void> setOnDisconnect({
    required String path,
    required Map<String, Object?> value,
  }) async {
    operations.add('setOnDisconnect:$path');
    (_onDisconnectCalledCompleter ??= Completer<void>()).complete();
    final completer = Completer<void>();
    _pendingOnDisconnectCompleter = completer;
    await completer.future;
  }

  @override
  Future<void> setValue({
    required String path,
    required Map<String, dynamic> value,
  }) async {}

  @override
  Stream<Map<String, dynamic>?> streamDriverLocation(String driverId) =>
      const Stream<Map<String, dynamic>?>.empty();

  @override
  Future<void> updateValue({
    required String path,
    required Map<String, Object?> value,
  }) async {
    operations.add('updateValue:$path');
    updatePayloads.add(value);
  }

  @override
  Stream<bool> watchConnectionState() => _connectionController.stream;
}
