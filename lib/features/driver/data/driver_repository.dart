import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_ent_280/features/auth/data/models/app_user_profile.dart';
import 'package:local_ent_280/features/driver/data/models/driver_dashboard_stats.dart';
import 'package:local_ent_280/features/driver/data/models/driver_status.dart';
import 'package:local_ent_280/features/driver/data/models/driver_vehicle.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';

class DriverRepository {
  DriverRepository({
    FirebaseFirestore? firestore,
    bool disabled = false,
  })  : _firestore = firestore,
        _disabled = disabled;

  final FirebaseFirestore? _firestore;
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

  Stream<DriverStatus?> watchDriverStatus(String driverId) {
    if (_disabled) return Stream<DriverStatus?>.value(null);
    return _driverStatus.doc(driverId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return DriverStatus.fromFirestore(doc);
    });
  }

  Future<void> setAvailability(String driverId, bool isAvailable) async {
    if (_disabled) return;
    await _driverStatus.doc(driverId).set({
      'isActive': true,
      'isAvailable': isAvailable,
      'availabilityEnabled': isAvailable,
      if (!isAvailable) 'currentTripId': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Open trips waiting for a driver (not yet assigned).
  Stream<TripRecord?> watchOpenTripOffer() {
    if (_disabled) return Stream<TripRecord?>.value(null);
    return _trips
        .where('status', isEqualTo: 'REQUESTED')
        .limit(20)
        .snapshots()
        .map((snapshot) {
      final open = snapshot.docs
          .map(TripRecord.fromFirestore)
          .where((trip) => !trip.hasAssignedDriver && trip.isActive)
          .toList();
      if (open.isEmpty) return null;
      open.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return open.first;
    });
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

  Future<bool> claimTrip(String driverId, String tripId) async {
    if (_disabled) return false;
    final ref = _trips.doc(tripId);
    return _db.runTransaction<bool>((transaction) async {
      final snap = await transaction.get(ref);
      if (!snap.exists) return false;
      final data = snap.data() ?? {};
      final status = data['status'] as String? ?? '';
      final assigned = data['assignedDriverId'] as String?;
      if (status != 'REQUESTED' || (assigned != null && assigned.isNotEmpty)) {
        return false;
      }
      transaction.update(ref, {
        'assignedDriverId': driverId,
        'status': 'DRIVER_ASSIGNED_WAITING_ACCEPTANCE',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    });
  }

  Future<void> acceptTrip({
    required String driverId,
    required String tripId,
    required AppUserProfile profile,
  }) async {
    if (_disabled) return;
    await _trips.doc(tripId).update({
      'status': 'DRIVER_ACCEPTED',
      'driverSummary': TripDriverSummary(
        displayName: profile.name.trim().isNotEmpty
            ? profile.name.trim()
            : profile.email,
        photoUrl: profile.photoUrl,
        phone: profile.phone,
      ).toFirestore(),
      'isActive': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _driverStatus.doc(driverId).set({
      'isAvailable': false,
      'availabilityEnabled': true,
      'currentTripId': tripId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> declineTrip(String driverId, String tripId) async {
    if (_disabled) return;
    await _trips.doc(tripId).update({
      'assignedDriverId': FieldValue.delete(),
      'status': 'REQUESTED',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _driverStatus.doc(driverId).set({
      'currentTripId': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> releaseTrip(String driverId, String tripId) async {
    await declineTrip(driverId, tripId);
  }

  Future<void> startEnRoute(String tripId) async {
    if (_disabled) return;
    await _trips.doc(tripId).update({
      'status': 'DRIVER_EN_ROUTE',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markArrived(String tripId) async {
    if (_disabled) return;
    await _trips.doc(tripId).update({
      'status': 'DRIVER_ARRIVED',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> startTrip(String tripId) async {
    if (_disabled) return;
    await _trips.doc(tripId).update({
      'status': 'IN_TRIP',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeTrip({
    required String driverId,
    required String tripId,
  }) async {
    if (_disabled) return;
    await _trips.doc(tripId).update({
      'status': 'COMPLETED',
      'isActive': false,
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _driverStatus.doc(driverId).set({
      'isAvailable': true,
      'currentTripId': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
