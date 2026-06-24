import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:local_ent_280/core/data/geo/geohash_encoder.dart';
import 'package:local_ent_280/firebase_options.dart';

class DriverLocationSnapshot {
  const DriverLocationSnapshot({
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
    this.heading,
    this.speed,
  });

  final double latitude;
  final double longitude;
  final DateTime updatedAt;
  final double? heading;
  final double? speed;
}

/// Publishes and reads live driver GPS in RTDB `driverLocations/{driverId}`.
class DriverLocationRepository {
  DriverLocationRepository({
    FirebaseDatabase? database,
    FirebaseFirestore? firestore,
  })  : _database = database ?? _defaultDatabase(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseDatabase _database;
  final FirebaseFirestore _firestore;
  static const _collection = 'driverLocations';
  static const _geohashPrecision = 9;

  static FirebaseDatabase _defaultDatabase() {
    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: DefaultFirebaseOptions.android.databaseURL!,
    );
  }

  DatabaseReference _ref(String driverId) =>
      _database.ref('$_collection/$driverId');

  Stream<DriverLocationSnapshot?> watchLocation(String driverId) {
    return _ref(driverId).onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return null;
      final data = value.map(
        (key, entry) => MapEntry(key.toString(), entry),
      );
      return _fromJson(data);
    });
  }

  Future<void> updateLocation({
    required String driverId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
  }) async {
    final payload = _toJson(
      latitude: latitude,
      longitude: longitude,
      heading: heading,
      speed: speed,
    );
    try {
      await _ref(driverId).update(payload);
      await _firestore.collection('driverStatus').doc(driverId).set({
        'lastSeenAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Driver location RTDB update failed: $e');
      rethrow;
    }
  }

  Future<void> clearLocation(String driverId) async {
    try {
      await _ref(driverId).remove();
    } catch (e) {
      debugPrint('Driver location RTDB clear failed: $e');
    }
  }

  Map<String, Object?> _toJson({
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
  }) {
    final geohash = const GeoHashEncoder()
        .encode(
          latitude: latitude,
          longitude: longitude,
          precision: _geohashPrecision,
        )
        .toLowerCase();
    final data = <String, Object?>{
      'l': <double>[latitude, longitude],
      'g': geohash,
      'ts': DateTime.now().millisecondsSinceEpoch,
    };
    if (heading != null) data['heading'] = heading;
    if (speed != null) data['speed'] = speed;
    return data;
  }

  DriverLocationSnapshot? _fromJson(Map<String, dynamic> data) {
    final coordinates = data['l'];
    if (coordinates is! List || coordinates.length < 2) return null;
    final latitude = _asDouble(coordinates[0]);
    final longitude = _asDouble(coordinates[1]);
    final updatedAtMs = data['ts'];
    if (latitude == null || longitude == null || updatedAtMs is! num) {
      return null;
    }
    return DriverLocationSnapshot(
      latitude: latitude,
      longitude: longitude,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs.toInt()),
      heading: _asDouble(data['heading']),
      speed: _asDouble(data['speed']),
    );
  }

  double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
