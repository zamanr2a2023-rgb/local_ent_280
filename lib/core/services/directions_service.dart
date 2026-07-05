import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:local_ent_280/core/config/google_maps_config.dart';
import 'package:local_ent_280/core/models/trip_directions_result.dart';
import 'package:local_ent_280/core/services/places_details_service.dart';
import 'package:local_ent_280/core/utils/polyline_decoder.dart';

class DirectionsRouteResult {
  const DirectionsRouteResult({
    required this.directions,
    required this.usedFallback,
  });

  final TripDirectionsResult? directions;

  /// True only when distance uses a straight-line approximation (no road geometry).
  final bool usedFallback;
}

/// Fetches driving route, distance, and duration from Google Directions API.
class DirectionsService {
  DirectionsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _requestTimeout = Duration(seconds: 12);

  Future<TripDirectionsResult> getDrivingRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final result = await getDrivingRouteDetailed(
      origin: origin,
      destination: destination,
    );
    return result.directions ??
        TripDirectionsResult(
          distanceKm: 0,
          durationMinutes: 0,
          polylinePoints: [origin, destination],
        );
  }

  Future<DirectionsRouteResult> getDrivingRouteDetailed({
    required LatLng origin,
    required LatLng destination,
  }) async {
    for (final apiKey in GoogleMapsConfig.directionsApiKeys) {
      final googleResult = await _fetchGoogleDirections(
        origin: origin,
        destination: destination,
        apiKey: apiKey,
      );
      if (googleResult != null) {
        return DirectionsRouteResult(
          directions: googleResult,
          usedFallback: false,
        );
      }
    }

    final osrmResult = await _fetchOsrmDirections(
      origin: origin,
      destination: destination,
    );
    if (osrmResult != null) {
      debugPrint('Directions: using OSRM road route fallback.');
      return DirectionsRouteResult(
        directions: osrmResult,
        usedFallback: false,
      );
    }

    return _straightLineFallback(origin, destination);
  }

  Future<TripDirectionsResult?> _fetchGoogleDirections({
    required LatLng origin,
    required LatLng destination,
    required String apiKey,
  }) async {
    if (apiKey.trim().isEmpty) return null;

    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': 'driving',
      'language': 'en',
      'key': apiKey,
    });

    try {
      final response = await _client.get(uri).timeout(_requestTimeout);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'UNKNOWN';
      if (status != 'OK') {
        final message = data['error_message'] as String? ?? status;
        debugPrint('Directions API status: $status ($message)');
        return null;
      }

      final routes = data['routes'] as List<dynamic>? ?? [];
      if (routes.isEmpty) return null;

      final route = routes.first as Map<String, dynamic>;
      final legs = route['legs'] as List<dynamic>? ?? [];
      if (legs.isEmpty) return null;

      final leg = legs.first as Map<String, dynamic>;
      final distanceMeters =
          (leg['distance'] as Map<String, dynamic>?)?['value'] as num? ?? 0;
      final durationSeconds =
          (leg['duration'] as Map<String, dynamic>?)?['value'] as num? ?? 0;
      final encodedPolyline =
          (route['overview_polyline'] as Map<String, dynamic>?)?['points']
              as String?;

      final polylinePoints = encodedPolyline == null
          ? [origin, destination]
          : decodePolyline(encodedPolyline);
      if (polylinePoints.length < 2) return null;

      final directions = TripDirectionsResult(
        distanceKm: distanceMeters / 1000,
        durationMinutes: (durationSeconds / 60).ceil().clamp(1, 999),
        polylinePoints: polylinePoints,
      );
      if (directions.distanceKm <= 0) return null;
      return directions;
    } catch (e) {
      debugPrint('Directions request failed: $e');
      return null;
    }
  }

  Future<TripDirectionsResult?> _fetchOsrmDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final path =
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}';
    final uri = Uri.https(
      'router.project-osrm.org',
      '/route/v1/driving/$path',
      {
        'overview': 'full',
        'geometries': 'polyline',
        'steps': 'false',
      },
    );

    try {
      final response = await _client.get(uri).timeout(_requestTimeout);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['code'] != 'Ok') return null;

      final routes = data['routes'] as List<dynamic>? ?? [];
      if (routes.isEmpty) return null;

      final route = routes.first as Map<String, dynamic>;
      final encodedPolyline = route['geometry'] as String?;
      if (encodedPolyline == null || encodedPolyline.isEmpty) return null;

      final polylinePoints = decodePolyline(encodedPolyline);
      if (polylinePoints.length < 2) return null;

      final distanceMeters = (route['distance'] as num?)?.toDouble() ?? 0;
      final durationSeconds = (route['duration'] as num?)?.toDouble() ?? 0;
      if (distanceMeters <= 0) return null;

      return TripDirectionsResult(
        distanceKm: distanceMeters / 1000,
        durationMinutes: (durationSeconds / 60).ceil().clamp(1, 999),
        polylinePoints: polylinePoints,
      );
    } catch (e) {
      debugPrint('OSRM directions failed: $e');
      return null;
    }
  }

  DirectionsRouteResult _straightLineFallback(
    LatLng origin,
    LatLng destination,
  ) {
    final distanceKm = PlacesDetailsService.estimateDistanceKm(
      origin,
      destination,
    );
    if (distanceKm <= 0) {
      return const DirectionsRouteResult(directions: null, usedFallback: true);
    }
    return DirectionsRouteResult(
      directions: TripDirectionsResult(
        distanceKm: distanceKm,
        durationMinutes: PlacesDetailsService.estimateDurationMinutes(distanceKm),
        polylinePoints: [origin, destination],
      ),
      usedFallback: true,
    );
  }
}
