import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_ent_280/features/driver/data/driver_location_repository.dart';

/// Streams device GPS and writes throttled updates to RTDB while active.
class DriverLocationTracker {
  DriverLocationTracker({
    DriverLocationRepository? repository,
  }) : _repository = repository ?? DriverLocationRepository();

  static final DriverLocationTracker instance = DriverLocationTracker();

  final DriverLocationRepository _repository;

  StreamSubscription<Position>? _positionSubscription;
  String? _activeDriverId;
  DateTime? _lastWriteAt;
  double? _lastLatitude;
  double? _lastLongitude;

  static const _keepAliveInterval = Duration(seconds: 30);
  static const _movementThresholdMeters = 15.0;

  bool get isTracking =>
      _activeDriverId != null && _positionSubscription != null;

  Future<void> start(String driverId) async {
    if (_activeDriverId == driverId && _positionSubscription != null) {
      return;
    }

    final hasPermission = await _ensurePermission();
    if (!hasPermission) {
      debugPrint('Driver location tracker: permission denied.');
      return;
    }

    await stop(clearLocation: false);
    _activeDriverId = driverId;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
      ),
    ).listen(
      (position) => _handlePosition(driverId, position),
      onError: (Object error) {
        debugPrint('Driver location stream error: $error');
      },
    );
  }

  Future<void> stop({bool clearLocation = true}) async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    final driverId = _activeDriverId;
    _activeDriverId = null;
    _lastWriteAt = null;
    _lastLatitude = null;
    _lastLongitude = null;

    if (clearLocation && driverId != null) {
      await _repository.clearLocation(driverId);
    }
  }

  Future<void> _handlePosition(String driverId, Position position) async {
    final now = DateTime.now();
    final lastWriteAt = _lastWriteAt;
    final movedMeters = _lastLatitude == null || _lastLongitude == null
        ? double.infinity
        : Geolocator.distanceBetween(
            _lastLatitude!,
            _lastLongitude!,
            position.latitude,
            position.longitude,
          );

    final shouldWrite = lastWriteAt == null ||
        now.difference(lastWriteAt) >= _keepAliveInterval ||
        movedMeters >= _movementThresholdMeters;

    if (!shouldWrite) return;

    try {
      await _repository.updateLocation(
        driverId: driverId,
        latitude: position.latitude,
        longitude: position.longitude,
        heading: position.heading,
        speed: position.speed,
      );
      _lastWriteAt = now;
      _lastLatitude = position.latitude;
      _lastLongitude = position.longitude;
    } catch (_) {
      // Keep streaming; next tick may succeed.
    }
  }

  Future<bool> _ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return false;
    }
    return Geolocator.isLocationServiceEnabled();
  }
}
