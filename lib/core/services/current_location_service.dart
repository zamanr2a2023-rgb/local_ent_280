import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:local_ent_280/core/config/google_maps_config.dart';

class DeviceLocation {
  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.isCoordinateFallback = false,
  });

  final double latitude;
  final double longitude;
  final String address;

  /// True when GPS worked but reverse geocoding could not resolve a street address.
  final bool isCoordinateFallback;
}

/// Reads the device GPS position and resolves it to a street address.
class CurrentLocationService {
  CurrentLocationService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Fast path using the last cached GPS fix (no fresh satellite lookup).
  Future<DeviceLocation?> getLastKnownLocation() async {
    try {
      if (!await _hasLocationAccess()) return null;

      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;

      return _buildLocation(position);
    } catch (e) {
      debugPrint('Last known location failed: $e');
      return null;
    }
  }

  Future<DeviceLocation?> getCurrentLocation() async {
    try {
      if (!await _hasLocationAccess()) return null;

      final position = await _resolvePosition();
      if (position == null) return null;

      return _buildLocation(position);
    } catch (e) {
      debugPrint('Current location failed: $e');
      return null;
    }
  }

  Future<DeviceLocation> locationFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    final address = await _reverseGeocode(latitude, longitude);
    return DeviceLocation(
      latitude: latitude,
      longitude: longitude,
      address: address ?? _formatCoordinates(latitude, longitude),
      isCoordinateFallback: address == null,
    );
  }

  Future<bool> _hasLocationAccess() async {
    final permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return false;
    }
    return Geolocator.isLocationServiceEnabled();
  }

  Future<DeviceLocation> _buildLocation(Position position) async {
    final address = await _reverseGeocode(position.latitude, position.longitude);
    final displayAddress =
        address ?? _formatCoordinates(position.latitude, position.longitude);

    return DeviceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      address: displayAddress,
      isCoordinateFallback: address == null,
    );
  }

  Future<Position?> _resolvePosition() async {
    Position? lastKnown;
    try {
      lastKnown = await Geolocator.getLastKnownPosition();
    } catch (e) {
      debugPrint('Last known position failed: $e');
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } on TimeoutException {
      debugPrint('GPS timeout, falling back to last known position');
      if (lastKnown != null) return lastKnown;

      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (e) {
        debugPrint('Low-accuracy position failed: $e');
        return lastKnown;
      }
    } catch (e) {
      debugPrint('Current position failed: $e');
      return lastKnown;
    }
  }

  Future<String?> _reverseGeocode(double lat, double lng) async {
    final platformAddress = await _reverseGeocodeFromDevice(lat, lng);
    if (platformAddress != null) return platformAddress;

    final withFilter = await _geocodeRequest(lat, lng, useResultTypeFilter: true);
    if (withFilter != null) return withFilter;

    return _geocodeRequest(lat, lng, useResultTypeFilter: false);
  }

  Future<String?> _reverseGeocodeFromDevice(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      final parts = <String>[
        if (place.street != null && place.street!.trim().isNotEmpty) place.street!.trim(),
        if (place.subLocality != null && place.subLocality!.trim().isNotEmpty)
          place.subLocality!.trim(),
        if (place.locality != null && place.locality!.trim().isNotEmpty) place.locality!.trim(),
        if (place.postalCode != null && place.postalCode!.trim().isNotEmpty)
          place.postalCode!.trim(),
        if (place.country != null && place.country!.trim().isNotEmpty) place.country!.trim(),
      ];

      if (parts.isEmpty) return null;
      return parts.join(', ');
    } catch (e) {
      debugPrint('Device geocode failed: $e');
      return null;
    }
  }

  Future<String?> _geocodeRequest(
    double lat,
    double lng, {
    required bool useResultTypeFilter,
  }) async {
    final params = <String, String>{
      'latlng': '$lat,$lng',
      'key': GoogleMapsConfig.placesApiKey,
      'language': 'en',
    };
    if (useResultTypeFilter) {
      params['result_type'] = 'street_address|route|premise';
    }

    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', params);

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'UNKNOWN';
      if (status != 'OK') {
        final message = data['error_message'] as String?;
        debugPrint(
          'Geocode API status: $status${message != null ? ' - $message' : ''}',
        );
        return null;
      }

      final results = data['results'] as List<dynamic>? ?? [];
      if (results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>;
      return first['formatted_address'] as String?;
    } catch (e) {
      debugPrint('Reverse geocode failed: $e');
      return null;
    }
  }

  String _formatCoordinates(double lat, double lng) {
    return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
  }
}
