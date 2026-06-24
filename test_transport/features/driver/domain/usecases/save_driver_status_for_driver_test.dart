import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/driver/domain/entities/driver_status.dart';
import 'package:local_transport/features/driver/domain/repositories/driver_presence_store.dart';
import 'package:local_transport/features/driver/domain/repositories/driver_status_store.dart';
import 'package:local_transport/features/driver/domain/usecases/save_driver_status_for_driver.dart';

void main() {
  group('SaveDriverStatusForDriver', () {
    test(
      'does not rewrite stale trip ownership fields when only availability changes',
      () async {
        final store = _FakeDriverStatusStore(
          initialStatus: const DriverStatus(
            isAvailable: false,
            isActive: true,
            availabilityEnabled: true,
            vehicleId: 'vehicle-1',
            currentTripId: 'trip-1',
            isBusy: true,
          ),
        );
        final presenceStore = _FakeDriverPresenceStore();
        final useCase = SaveDriverStatusForDriver(store, presenceStore);

        await useCase(
          'driver-1',
          const DriverStatus(isAvailable: true),
        );

        expect(store.savedDriverId, 'driver-1');
        expect(store.savedStatus?.isAvailable, isTrue);
        expect(store.savedStatus?.isActive, isTrue);
        expect(store.savedStatus?.availabilityEnabled, isTrue);
        expect(store.savedStatus?.vehicleId, 'vehicle-1');
        expect(store.savedStatus?.currentTripId, isNull);
        expect(store.savedStatus?.isBusy, isNull);
        expect(presenceStore.syncedDriverId, 'driver-1');
        expect(presenceStore.syncedAvailability, isTrue);
      },
    );
  });
}

class _FakeDriverStatusStore implements DriverStatusStore {
  _FakeDriverStatusStore({this.initialStatus});

  final DriverStatus? initialStatus;
  String? savedDriverId;
  DriverStatus? savedStatus;

  @override
  Future<DriverStatus?> fetchStatus(String driverId) async => initialStatus;

  @override
  Future<void> saveStatus(String driverId, DriverStatus status) async {
    savedDriverId = driverId;
    savedStatus = status;
  }
}

class _FakeDriverPresenceStore implements DriverPresenceStore {
  String? syncedDriverId;
  bool? syncedAvailability;

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
  }) async {
    syncedDriverId = driverId;
    syncedAvailability = isAvailable;
  }

  @override
  Future<void> updateHeartbeat(String driverId) async {}
}
