import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_ent_280/core/services/client_functions_service.dart';
import 'package:local_ent_280/features/auth/data/models/app_user_profile.dart';
import 'package:local_ent_280/features/driver/data/models/driver_dashboard_stats.dart';
import 'package:local_ent_280/features/driver/data/models/driver_status.dart';
import 'package:local_ent_280/features/driver/data/models/driver_vehicle.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';

class DriverRepository {
  DriverRepository({
    FirebaseFirestore? firestore,
    ClientFunctionsService? functionsService,
    bool disabled = false,
  })  : _firestore = firestore,
        _functionsService = functionsService ?? ClientFunctionsService(),
        _disabled = disabled;

  final FirebaseFirestore? _firestore;
  final ClientFunctionsService _functionsService;
  final bool _disabled;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _trips =>
      _db.collection('trips');

  CollectionReference<Map<String, dynamic>> get _driverStatus =>
      _db.collection('driverStatus');

  CollectionReference<Map<String, dynamic>> get _vehicleAssignments =>
      _db.collection('driverVehicleAssignments');

  CollectionReference<Map<String, dynamic>> get _vehicles =>
      _db.collection('vehicles');

  bool get disabled => _disabled;

  static const driverTripFinishedStatuses = {
    'COMPLETED',
    'CHARGE_APPLIED',
    'TRIP_COMPLETED',
  };

  static bool isTripFinished(String status) =>
      driverTripFinishedStatuses.contains(status.toUpperCase());

  Stream<DriverStatus?> watchDriverStatus(String driverId) {
    if (_disabled) return Stream<DriverStatus?>.value(null);
    return _driverStatus.doc(driverId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return DriverStatus.fromFirestore(doc);
    });
  }

  Future<void> setAvailability(String driverId, bool isAvailable) async {
    if (_disabled) return;

    String? assignedVehicleId;
    if (isAvailable) {
      final assignment = await _vehicleAssignments.doc(driverId).get();
      final vehicleId = assignment.data()?['vehicleId'] as String?;
      if (vehicleId != null && vehicleId.trim().isNotEmpty) {
        assignedVehicleId = vehicleId.trim();
      } else {
        await _driverStatus.doc(driverId).set({
          'isAvailable': false,
          'availabilityEnabled': false,
          'isBusy': false,
          'currentTripId': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        throw StateError('no_vehicle_assigned');
      }
    }

    final updates = <String, dynamic>{
      'isActive': true,
      'isAvailable': isAvailable,
      'availabilityEnabled': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (isAvailable) {
      final hasAssignedActiveTrip = await _hasAssignedActiveTrip(driverId);
      if (!hasAssignedActiveTrip) {
        updates['isBusy'] = false;
        updates['currentTripId'] = FieldValue.delete();
      }
      updates['lastSeenAt'] = FieldValue.serverTimestamp();
      if (assignedVehicleId != null) {
        updates['vehicleId'] = assignedVehicleId;
      }
    } else {
      updates['isBusy'] = false;
      updates['currentTripId'] = FieldValue.delete();
    }

    await _driverStatus.doc(driverId).set(updates, SetOptions(merge: true));
  }

  Future<bool> _hasAssignedActiveTrip(String driverId) async {
    final snapshot = await _trips
        .where('assignedDriverId', isEqualTo: driverId)
        .where('isActive', isEqualTo: true)
        .limit(10)
        .get();
    const terminalStatuses = {
      'COMPLETED',
      'CHARGE_APPLIED',
      'TRIP_COMPLETED',
      'CANCELLED_BY_CLIENT',
      'CANCELLED_BY_DRIVER',
      'DRIVER_DECLINED',
      'NO_DRIVERS_AVAILABLE',
      'NO_SHOW',
    };
    for (final doc in snapshot.docs) {
      final status = (doc.data()['status'] as String? ?? '').toUpperCase();
      if (!terminalStatuses.contains(status)) {
        return true;
      }
    }
    return false;
  }

  /// Trip assigned to this driver awaiting accept/decline.
  Stream<TripRecord?> watchPendingAcceptanceTrip(String driverId) {
    if (_disabled) return Stream<TripRecord?>.value(null);
    return _trips
        .where('assignedDriverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'DRIVER_ASSIGNED_WAITING_ACCEPTANCE')
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return TripRecord.fromFirestore(snapshot.docs.first);
    });
  }

  /// Active trip for driver (accepted through in-progress).
  Stream<TripRecord?> watchActiveDriverTrip(String driverId) {
    if (_disabled) return Stream<TripRecord?>.value(null);
    return _trips
        .where('assignedDriverId', isEqualTo: driverId)
        .where('isActive', isEqualTo: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      const activeStatuses = {
        'DRIVER_ACCEPTED',
        'DRIVER_EN_ROUTE',
        'DRIVER_ARRIVED',
        'IN_TRIP',
        'ARRIVED_DESTINATION',
        'EXTENSION_WINDOW',
      };
      final active = snapshot.docs
          .map(TripRecord.fromFirestore)
          .where((trip) => activeStatuses.contains(trip.status))
          .toList();
      if (active.isEmpty) return null;
      active.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return active.first;
    });
  }

  Stream<List<TripRecord>> watchDriverTripHistory(String driverId) {
    if (_disabled) return Stream<List<TripRecord>>.value(const []);
    return _trips
        .where('assignedDriverId', isEqualTo: driverId)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      final trips = snapshot.docs.map(TripRecord.fromFirestore).toList();
      trips.sort((a, b) {
        final aDate = a.completedAt ??
            a.updatedAt ??
            a.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.completedAt ??
            b.updatedAt ??
            b.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return trips;
    });
  }

  Stream<DriverDashboardStats> watchDriverDashboardStats(String driverId) {
    return watchDriverTripHistory(driverId)
        .map(DriverDashboardStats.fromTrips);
  }

  Stream<DriverVehicle?> watchAssignedVehicle(String driverId) {
    if (_disabled) return Stream<DriverVehicle?>.value(null);
    return _vehicleAssignments.doc(driverId).snapshots().asyncMap((doc) async {
      if (!doc.exists) return null;
      final vehicleId = doc.data()?['vehicleId'] as String?;
      if (vehicleId == null || vehicleId.trim().isEmpty) return null;
      final vehicleDoc = await _vehicles.doc(vehicleId).get();
      if (!vehicleDoc.exists) return null;
      return DriverVehicle.fromFirestore(vehicleDoc);
    });
  }

  Future<void> acceptTrip({
    required String driverId,
    required String tripId,
    required AppUserProfile profile,
  }) async {
    if (_disabled) return;

    const navigableStatuses = {
      'DRIVER_ACCEPTED',
      'DRIVER_EN_ROUTE',
      'DRIVER_ARRIVED',
      'IN_TRIP',
      'ARRIVED_DESTINATION',
      'EXTENSION_WINDOW',
    };

    var status = await _readTripStatus(tripId, preferServer: true);

    if (status == 'DRIVER_ASSIGNED_WAITING_ACCEPTANCE') {
      await _functionsService.transitionTripState(
        tripId: tripId,
        targetStatus: 'DRIVER_ACCEPTED',
        actorId: driverId,
      );
      status = await _waitForTripStatus(
        tripId,
        expected: 'DRIVER_ACCEPTED',
        acceptAlso: navigableStatuses,
      );
    }

    if (status == 'DRIVER_ACCEPTED') {
      for (var attempt = 0; attempt < 3; attempt++) {
        try {
          await _functionsService.transitionTripState(
            tripId: tripId,
            targetStatus: 'DRIVER_EN_ROUTE',
            actorId: driverId,
          );
          status = await _waitForTripStatus(
            tripId,
            expected: 'DRIVER_EN_ROUTE',
            acceptAlso: navigableStatuses,
          );
          if (status != 'DRIVER_ACCEPTED') break;
        } on ClientFunctionsException {
          status = await _readTripStatus(tripId, preferServer: true);
          if (status != 'DRIVER_ACCEPTED') break;
          if (attempt == 2) rethrow;
          await Future<void>.delayed(
            Duration(milliseconds: 350 * (attempt + 1)),
          );
        }
      }
    }

    status = await _readTripStatus(tripId, preferServer: true);
    if (!navigableStatuses.contains(status)) {
      throw StateError('Trip could not be started (status: $status).');
    }

    await _driverStatus.doc(driverId).set({
      'isAvailable': false,
      'availabilityEnabled': true,
      'isBusy': true,
      'currentTripId': tripId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String> _readTripStatus(
    String tripId, {
    bool preferServer = false,
  }) async {
    final snap = await _trips.doc(tripId).get(
      GetOptions(
        source: preferServer ? Source.server : Source.serverAndCache,
      ),
    );
    return (snap.data()?['status'] as String? ?? '').toUpperCase();
  }

  Future<String> _waitForTripStatus(
    String tripId, {
    required String expected,
    Set<String>? acceptAlso,
    int maxAttempts = 30,
  }) async {
    final acceptable = {expected, ...?acceptAlso};
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final status = await _readTripStatus(tripId, preferServer: true);
      if (acceptable.contains(status)) return status;
      if (attempt < maxAttempts - 1) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
    }
    return _readTripStatus(tripId, preferServer: true);
  }

  Future<void> declineTrip(
    String driverId,
    String tripId, {
    String reason = 'driver_declined',
  }) async {
    if (_disabled) return;
    await _functionsService.transitionTripState(
      tripId: tripId,
      targetStatus: 'DRIVER_DECLINED',
      actorId: driverId,
      reason: reason,
    );
    await _driverStatus.doc(driverId).set({
      'isBusy': false,
      'currentTripId': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> releaseTrip(String driverId, String tripId) async {
    await declineTrip(
      driverId,
      tripId,
      reason: 'assignment_window_expired',
    );
  }

  Future<void> startEnRoute(String tripId) async {
    // Accept already transitions to DRIVER_EN_ROUTE.
  }

  Future<void> markArrived(String tripId, {required String driverId}) async {
    if (_disabled) return;
    var status = await _readTripStatus(tripId);
    if (isTripFinished(status)) return;
    if (status == 'DRIVER_ARRIVED' ||
        status == 'IN_TRIP' ||
        status == 'ARRIVED_DESTINATION' ||
        status == 'EXTENSION_WINDOW') {
      return;
    }
    if (status != 'DRIVER_EN_ROUTE') {
      throw StateError('Cannot mark arrived (status: $status).');
    }
    await _transitionTripTo(
      tripId: tripId,
      driverId: driverId,
      targetStatus: 'DRIVER_ARRIVED',
    );
  }

  Future<void> startTrip(String tripId, {required String driverId}) async {
    if (_disabled) return;
    var status = await _readTripStatus(tripId);
    if (isTripFinished(status)) return;
    if (status == 'IN_TRIP' ||
        status == 'ARRIVED_DESTINATION' ||
        status == 'EXTENSION_WINDOW') {
      return;
    }
    if (status == 'DRIVER_EN_ROUTE') {
      await _transitionTripTo(
        tripId: tripId,
        driverId: driverId,
        targetStatus: 'DRIVER_ARRIVED',
      );
      status = await _readTripStatus(tripId);
    }
    if (status == 'DRIVER_ARRIVED') {
      await _transitionTripTo(
        tripId: tripId,
        driverId: driverId,
        targetStatus: 'IN_TRIP',
      );
      return;
    }
    throw StateError('Cannot start trip (status: $status).');
  }

  Future<void> completeTrip({
    required String driverId,
    required String tripId,
  }) async {
    if (_disabled) return;

    var status = await _readTripStatus(tripId);
    if (status.isEmpty) {
      throw StateError('Trip not found');
    }

    const completable = {
      'DRIVER_EN_ROUTE',
      'DRIVER_ARRIVED',
      'IN_TRIP',
      'ARRIVED_DESTINATION',
      'EXTENSION_WINDOW',
    };
    const finished = driverTripFinishedStatuses;

    if (!finished.contains(status)) {
      if (!completable.contains(status)) {
        throw StateError('Trip cannot be finished (status: $status).');
      }

      if (status == 'DRIVER_EN_ROUTE') {
        await _transitionTripTo(
          tripId: tripId,
          driverId: driverId,
          targetStatus: 'DRIVER_ARRIVED',
        );
        status = await _readTripStatus(tripId);
      }
      if (status == 'DRIVER_ARRIVED') {
        await _transitionTripTo(
          tripId: tripId,
          driverId: driverId,
          targetStatus: 'IN_TRIP',
        );
        status = await _readTripStatus(tripId);
      }
      if (status == 'IN_TRIP') {
        await _transitionTripTo(
          tripId: tripId,
          driverId: driverId,
          targetStatus: 'ARRIVED_DESTINATION',
        );
        status = await _readTripStatus(tripId);
      }
      if (status == 'ARRIVED_DESTINATION' || status == 'EXTENSION_WINDOW') {
        await _transitionTripTo(
          tripId: tripId,
          driverId: driverId,
          targetStatus: 'COMPLETED',
        );
        status = await _readTripStatus(tripId);
      }

      if (!finished.contains(status)) {
        throw StateError('Trip could not be completed (status: $status).');
      }
    }

    await _driverStatus.doc(driverId).set({
      'isAvailable': true,
      'availabilityEnabled': true,
      'isBusy': false,
      'currentTripId': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _transitionTripTo({
    required String tripId,
    required String driverId,
    required String targetStatus,
  }) async {
    await _functionsService.transitionTripState(
      tripId: tripId,
      targetStatus: targetStatus,
      actorId: driverId,
    );
  }

  Future<void> recordPathPoint({
    required String tripId,
    required double latitude,
    required double longitude,
  }) async {
    if (_disabled) return;
    await _trips.doc(tripId).collection('pathPoints').add({
      'latitude': latitude,
      'longitude': longitude,
      'recordedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTripMetering({
    required String tripId,
    required double totalDistanceKm,
    required int totalMinutes,
    required int estimatedCostMinor,
  }) async {
    if (_disabled) return;
    final snapshot = TripMeteringSnapshot(
      totalDistanceKm: totalDistanceKm,
      totalMinutes: totalMinutes,
      totalWaitMinutes: 0,
      estimatedCostMinor: estimatedCostMinor,
    );
    await _trips.doc(tripId).collection('metering').doc('current').set({
      ...snapshot.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _trips.doc(tripId).update({
      'meteringSnapshot': snapshot.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
