import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_ent_280/features/admin/data/models/admin_stats.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';

class AdminRepository {
  AdminRepository({FirebaseFirestore? firestore, bool disabled = false})
    : _firestore = firestore,
      _disabled = disabled;

  final FirebaseFirestore? _firestore;
  final bool _disabled;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _trips =>
      _db.collection('trips');

  CollectionReference<Map<String, dynamic>> get _driverStatus =>
      _db.collection('driverStatus');

  CollectionReference<Map<String, dynamic>> get _balances =>
      _db.collection('balances');

  CollectionReference<Map<String, dynamic>> get _vehicles =>
      _db.collection('vehicles');

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _assignments =>
      _db.collection('driverVehicleAssignments');

  DocumentReference<Map<String, dynamic>> get _publicTariff =>
      _db.collection('tariffs').doc('public_default');

  DocumentReference<Map<String, dynamic>> get _marketConfig =>
      _db.collection('config').doc('market');

  CollectionReference<Map<String, dynamic>> get _driverOperationalStates =>
      _db.collection('driverOperationalStates');

  Stream<List<TripRecord>> watchTrips() {
    if (_disabled) return Stream<List<TripRecord>>.value(const []);
    return _trips.limit(200).snapshots().map((snapshot) {
      final trips = snapshot.docs.map(TripRecord.fromFirestore).toList();
      trips.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return trips;
    });
  }

  Stream<AdminDashboardStats> watchDashboardStats() {
    if (_disabled) {
      return Stream<AdminDashboardStats>.value(AdminDashboardStats.empty);
    }

    return watchTrips().asyncMap((trips) async {
      final driversSnap = await _driverStatus
          .where('isAvailable', isEqualTo: true)
          .get();
      final availableDrivers = driversSnap.docs.where((doc) {
        return doc.data()['isActive'] as bool? ?? true;
      }).length;

      final balancesSnap = await _balances.get();
      var debtorCount = 0;
      var debtMinor = 0;
      for (final doc in balancesSnap.docs) {
        final amount = _readAmountMinor(doc.data());
        if (amount < 0) {
          debtorCount++;
          debtMinor += amount.abs();
        }
      }

      return AdminDashboardStats.fromTripsAndDrivers(
        trips: trips,
        availableDrivers: availableDrivers,
        pendingDebtorCount: debtorCount,
        pendingDebtEur: debtMinor / 100,
      );
    });
  }

  Stream<AdminReportsStats> watchReportsStats() {
    if (_disabled)
      return Stream<AdminReportsStats>.value(AdminReportsStats.empty);

    return watchTrips().asyncMap((trips) async {
      final balancesSnap = await _balances.get();
      var debtMinor = 0;
      for (final doc in balancesSnap.docs) {
        final amount = _readAmountMinor(doc.data());
        if (amount < 0) debtMinor += amount.abs();
      }
      return AdminReportsStats.fromTrips(
        trips: trips,
        pendingDebtEur: debtMinor / 100,
      );
    });
  }

  Stream<AdminTariffSummary?> watchTariffSummary() {
    if (_disabled) return Stream<AdminTariffSummary?>.value(null);
    return _publicTariff.snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() ?? {};
      final perKm = _readMoneyMinor(data['perKm']);
      final rules = data['multiplierRules'] as List<dynamic>? ?? [];
      double? multiplier;
      if (rules.isNotEmpty) {
        final first = rules.first;
        if (first is Map<String, dynamic>) {
          multiplier = (first['multiplier'] as num?)?.toDouble();
        }
      }
      if (perKm == 0) return null;
      return AdminTariffSummary(
        perKmEur: perKm / 100,
        dynamicMultiplier: multiplier,
      );
    });
  }

  Stream<AdminMarketSummary?> watchMarketSummary() {
    if (_disabled) return Stream<AdminMarketSummary?>.value(null);
    return _marketConfig.snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() ?? {};
      final fuelMinor = _readMoneyMinor(data['fuelCostPerLiter']);
      final center = _readLatLng(data['mapCenter']);
      return AdminMarketSummary(
        fuelCostPerLiterEur: fuelMinor / 100,
        activityMapLabel: data['activityMapLabel'] as String?,
        centerLatitude: center?.$1,
        centerLongitude: center?.$2,
      );
    });
  }

  Stream<AdminActivityMapData> watchActivityMap() {
    if (_disabled) {
      return Stream<AdminActivityMapData>.value(AdminActivityMapData.empty);
    }

    final controller = StreamController<AdminActivityMapData>.broadcast();
    List<TripRecord> trips = const [];
    QuerySnapshot<Map<String, dynamic>>? opsSnap;
    DocumentSnapshot<Map<String, dynamic>>? marketSnap;

    void emit() {
      if (controller.isClosed) return;
      controller.add(
        _buildActivityMapData(
          trips: trips,
          opsSnap: opsSnap,
          marketSnap: marketSnap,
        ),
      );
    }

    final subs = <StreamSubscription<dynamic>>[
      watchTrips().listen((value) {
        trips = value;
        emit();
      }, onError: controller.addError),
      _driverOperationalStates.limit(50).snapshots().listen((value) {
        opsSnap = value;
        emit();
      }, onError: controller.addError),
      _marketConfig.snapshots().listen((value) {
        marketSnap = value;
        emit();
      }, onError: controller.addError),
    ];

    controller.onCancel = () async {
      for (final sub in subs) {
        await sub.cancel();
      }
    };

    return controller.stream;
  }

  AdminActivityMapData _buildActivityMapData({
    required List<TripRecord> trips,
    required QuerySnapshot<Map<String, dynamic>>? opsSnap,
    required DocumentSnapshot<Map<String, dynamic>>? marketSnap,
  }) {
    const activeStatuses = {
      'DRIVER_ASSIGNED_WAITING_ACCEPTANCE',
      'DRIVER_ACCEPTED',
      'DRIVER_EN_ROUTE',
      'DRIVER_ARRIVED',
      'IN_TRIP',
      'ARRIVED_DESTINATION',
      'EXTENSION_WINDOW',
      'REQUESTED',
    };
    const inTripStatuses = {
      'IN_TRIP',
      'ARRIVED_DESTINATION',
      'EXTENSION_WINDOW',
      'DRIVER_EN_ROUTE',
      'DRIVER_ARRIVED',
    };

    final markers = <AdminMapMarker>[];
    String? firstAddress;
    var activeTripCount = 0;

    for (final trip in trips) {
      if (!trip.isActive && !activeStatuses.contains(trip.status)) continue;
      activeTripCount++;

      final pickup = trip.pickup;
      if (pickup.latitude != 0 || pickup.longitude != 0) {
        firstAddress ??= pickup.address;
        markers.add(
          AdminMapMarker(
            latitude: pickup.latitude,
            longitude: pickup.longitude,
            kind: AdminMapMarkerKind.tripPickup,
            label: pickup.address,
          ),
        );
      }

      if (inTripStatuses.contains(trip.status)) {
        final destination = trip.destination;
        if (destination.latitude != 0 || destination.longitude != 0) {
          markers.add(
            AdminMapMarker(
              latitude: destination.latitude,
              longitude: destination.longitude,
              kind: AdminMapMarkerKind.tripDestination,
              label: destination.address,
            ),
          );
        }
      }
    }

    if (opsSnap != null) {
      for (final doc in opsSnap.docs) {
        final location = doc.data()['latestLocation'];
        if (location is! Map<String, dynamic>) continue;
        final lat = (location['latitude'] as num?)?.toDouble();
        final lng = (location['longitude'] as num?)?.toDouble();
        if (lat == null || lng == null || (lat == 0 && lng == 0)) continue;
        markers.add(
          AdminMapMarker(
            latitude: lat,
            longitude: lng,
            kind: AdminMapMarkerKind.driver,
            label: doc.data()['driverName'] as String?,
          ),
        );
      }
    }

    final marketData = marketSnap?.data();
    final configLabel = marketData?['activityMapLabel'] as String?;
    final center = _readLatLng(marketData?['mapCenter']);
    final driverCount = markers
        .where((m) => m.kind == AdminMapMarkerKind.driver)
        .length;

    return AdminActivityMapData(
      markers: markers,
      locationLabel: configLabel?.trim().isNotEmpty == true
          ? configLabel!.trim()
          : _shortAddress(firstAddress),
      centerLatitude: center?.$1,
      centerLongitude: center?.$2,
      activeTripCount: activeTripCount,
      activeDriverCount: driverCount,
    );
  }

  (double, double)? _readLatLng(dynamic value) {
    if (value is! Map<String, dynamic>) return null;
    final lat = (value['latitude'] as num?)?.toDouble();
    final lng = (value['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return (lat, lng);
  }

  String? _shortAddress(String? address) {
    if (address == null || address.trim().isEmpty) return null;
    final parts = address.split(',');
    if (parts.length >= 2) {
      return '${parts[parts.length - 2].trim()}, ${parts.last.trim()}';
    }
    return address.trim();
  }

  Stream<List<AdminFleetRow>> watchRecentFleet() {
    if (_disabled) return Stream<List<AdminFleetRow>>.value(const []);
    return _combineQuerySnapshots(
      _vehicles.limit(10).snapshots(),
      _assignments.snapshots(),
      _mapRecentFleetRows,
    );
  }

  Future<List<AdminFleetRow>> _mapRecentFleetRows(
    QuerySnapshot<Map<String, dynamic>> vehiclesSnap,
    QuerySnapshot<Map<String, dynamic>> assignmentsSnap,
  ) async {
    if (vehiclesSnap.docs.isEmpty) return const <AdminFleetRow>[];

    final assignmentByVehicle = <String, String>{};
    for (final doc in assignmentsSnap.docs) {
      final vehicleId = doc.data()['vehicleId'] as String?;
      if (vehicleId != null) {
        assignmentByVehicle[vehicleId] = doc.id;
      }
    }

    final rows = <AdminFleetRow>[];
    for (final vehicleDoc in vehiclesSnap.docs.take(5)) {
      final vehicleData = vehicleDoc.data();
      final make = vehicleData['make'] as String? ?? '';
      final model = vehicleData['model'] as String? ?? '';
      final plate = vehicleData['plate'] as String? ?? '';
      final vehicleName = make.trim().isNotEmpty ? make.trim() : model.trim();
      final driverId = assignmentByVehicle[vehicleDoc.id];

      var driverLabel = '—';
      var isOnTrip = false;
      if (driverId != null) {
        final userDoc = await _users.doc(driverId).get();
        final statusDoc = await _driverStatus.doc(driverId).get();
        final name = userDoc.data()?['name'] as String? ?? '';
        driverLabel = name.trim().isNotEmpty ? name.trim() : driverId;
        final currentTripId = statusDoc.data()?['currentTripId'] as String?;
        isOnTrip = currentTripId != null && currentTripId.trim().isNotEmpty;
      }

      rows.add(
        AdminFleetRow(
          vehicleLabel: [
            if (vehicleName.isNotEmpty) vehicleName,
            if (plate.trim().isNotEmpty) plate.trim(),
          ].join(' • '),
          driverLabel: driverLabel == '—' ? '—' : 'Driver: $driverLabel',
          isOnTrip: isOnTrip,
        ),
      );
    }
    return rows;
  }

  Stream<T> _combineQuerySnapshots<T>(
    Stream<QuerySnapshot<Map<String, dynamic>>> primary,
    Stream<QuerySnapshot<Map<String, dynamic>>> secondary,
    Future<T> Function(
      QuerySnapshot<Map<String, dynamic>> primary,
      QuerySnapshot<Map<String, dynamic>> secondary,
    )
    mapper,
  ) {
    final controller = StreamController<T>();
    QuerySnapshot<Map<String, dynamic>>? primarySnap;
    QuerySnapshot<Map<String, dynamic>>? secondarySnap;

    Future<void> publish() async {
      final currentPrimary = primarySnap;
      final currentSecondary = secondarySnap;
      if (currentPrimary == null || currentSecondary == null) return;
      if (controller.isClosed) return;
      try {
        controller.add(await mapper(currentPrimary, currentSecondary));
      } catch (error, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      }
    }

    late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
    primarySub;
    late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
    secondarySub;

    primarySub = primary.listen((snap) {
      primarySnap = snap;
      publish();
    }, onError: controller.addError);
    secondarySub = secondary.listen((snap) {
      secondarySnap = snap;
      publish();
    }, onError: controller.addError);

    controller.onCancel = () async {
      await primarySub.cancel();
      await secondarySub.cancel();
    };

    return controller.stream;
  }

  int _readAmountMinor(Map<String, dynamic> data) {
    final money = data['amount'];
    if (money is Map<String, dynamic>) {
      return (money['amountMinor'] as num?)?.toInt() ?? 0;
    }
    return (data['amountMinor'] as num?)?.toInt() ?? 0;
  }

  int _readMoneyMinor(dynamic value) {
    if (value is Map<String, dynamic>) {
      return (value['amountMinor'] as num?)?.toInt() ?? 0;
    }
    if (value is num) return value.round();
    return 0;
  }
}
