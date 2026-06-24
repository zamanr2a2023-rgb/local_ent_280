import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/data/firebase/realtime_db_service.dart';
import 'package:local_transport/features/driver/data/mappers/driver_location_realtime_db_mapper.dart';
import 'package:local_transport/features/driver/data/repositories/driver_location_repository_impl.dart';
import 'package:local_transport/features/driver/domain/entities/driver_location.dart';

void main() {
  group('DriverLocationRepositoryImpl', () {
    test('mantém localização stale como último ponto conhecido', () async {
      final realtimeDbService = _FakeRealtimeDbService();
      final repository = DriverLocationRepositoryImpl(
        realtimeDbService,
        const DriverLocationRealtimeDbMapper(),
      );
      final staleLocation = DriverLocation(
        latitude: 38.7169,
        longitude: -9.1399,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        heading: 45,
      );

      final emissions = <DriverLocation?>[];
      final subscription = repository
          .watchLocation('driver-1')
          .listen(
            emissions.add,
          );

      realtimeDbService.emitDriverLocation(
        const DriverLocationRealtimeDbMapper().toJson(staleLocation),
      );
      await pumpEventQueue();

      expect(emissions, hasLength(1));
      expect(emissions.single, isNotNull);
      expect(emissions.single!.latitude, staleLocation.latitude);
      expect(emissions.single!.longitude, staleLocation.longitude);
      expect(emissions.single!.heading, staleLocation.heading);

      await subscription.cancel();
      await realtimeDbService.dispose();
    });
  });
}

class _FakeRealtimeDbService implements RealtimeDbService {
  final _locationController =
      StreamController<Map<String, dynamic>?>.broadcast();

  void emitDriverLocation(Map<String, dynamic>? payload) {
    _locationController.add(payload);
  }

  Future<void> dispose() => _locationController.close();

  @override
  Future<void> cancelOnDisconnect({required String path}) async {}

  @override
  Future<void> clearValue({required String path}) async {}

  @override
  Future<Map<String, dynamic>?> fetchValue(String path) async => null;

  @override
  Future<void> setOnDisconnect({
    required String path,
    required Map<String, Object?> value,
  }) async {}

  @override
  Future<void> setValue({
    required String path,
    required Map<String, dynamic> value,
  }) async {}

  @override
  Stream<Map<String, dynamic>?> streamDriverLocation(String driverId) {
    return _locationController.stream;
  }

  @override
  Future<void> updateValue({
    required String path,
    required Map<String, Object?> value,
  }) async {}

  @override
  Stream<bool> watchConnectionState() => const Stream<bool>.empty();
}
