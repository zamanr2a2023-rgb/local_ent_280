import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:local_ent_280/core/config/google_maps_config.dart';

/// Resolves place IDs and addresses to map coordinates.
class PlacesDetailsService {
  PlacesDetailsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<LatLng?> resolveCoordinates({
    String? placeId,
    String? address,
  }) async {
    if (placeId != null && placeId.trim().isNotEmpty) {
      final fromPlace = await _coordinatesFromPlaceId(placeId.trim());
      if (fromPlace != null) return fromPlace;
    }

    final query = address?.trim();
    if (query != null && query.isNotEmpty) {
      return _coordinatesFromAddress(query);
    }
    return null;
  }

  Future<LatLng?> _coordinatesFromPlaceId(String placeId) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {
        'place_id': placeId,
        'fields': 'geometry',
        'key': GoogleMapsConfig.preferredWebServicesKey,
        'language': 'pt',
      },
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') {
        debugPrint('Place details status: ${data['status']}');
        return null;
      }

      final result = data['result'] as Map<String, dynamic>?;
      final geometry = result?['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;
      final lat = (location?['lat'] as num?)?.toDouble();
      final lng = (location?['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;
      return LatLng(lat, lng);
    } catch (e) {
      debugPrint('Place details failed: $e');
      return null;
    }
  }

  Future<LatLng?> _coordinatesFromAddress(String address) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      {
        'address': address,
        'key': GoogleMapsConfig.preferredWebServicesKey,
        'language': 'pt',
        'region': 'cv',
      },
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') {
        debugPrint('Geocode address status: ${data['status']}');
        return null;
      }

      final results = data['results'] as List<dynamic>? ?? [];
      if (results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>;
      final geometry = first['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;
      final lat = (location?['lat'] as num?)?.toDouble();
      final lng = (location?['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;
      return LatLng(lat, lng);
    } catch (e) {
      debugPrint('Geocode address failed: $e');
      return null;
    }
  }

  static double estimateDistanceKm(LatLng origin, LatLng destination) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(destination.latitude - origin.latitude);
    final dLng = _degToRad(destination.longitude - origin.longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(origin.latitude)) *
            math.cos(_degToRad(destination.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static int estimateDurationMinutes(double distanceKm) {
    const averageSpeedKmh = 38.0;
    return math.max(1, (distanceKm / averageSpeedKmh * 60).round());
  }

  static double _degToRad(double value) => value * math.pi / 180;
}
