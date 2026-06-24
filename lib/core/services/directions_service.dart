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
  final bool usedFallback;
}

/// Fetches driving route, distance, and duration from Google Directions API.
class DirectionsService {
  DirectionsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

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
    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': 'driving',
      'language': 'en',
      'key': GoogleMapsConfig.placesApiKey,
    });

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        return _fallbackResult(origin, destination);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'UNKNOWN';
      if (status != 'OK') {
        debugPrint('Directions API status: $status');
        return _fallbackResult(origin, destination);
      }

      final routes = data['routes'] as List<dynamic>? ?? [];
      if (routes.isEmpty) return _fallbackResult(origin, destination);

      final route = routes.first as Map<String, dynamic>;
      final legs = route['legs'] as List<dynamic>? ?? [];
      if (legs.isEmpty) return _fallbackResult(origin, destination);

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

      final directions = TripDirectionsResult(
        distanceKm: distanceMeters / 1000,
        durationMinutes: (durationSeconds / 60).ceil().clamp(1, 999),
        polylinePoints: polylinePoints,
      );
      if (directions.distanceKm <= 0) {
        return const DirectionsRouteResult(
          directions: null,
          usedFallback: true,
        );
      }
      return DirectionsRouteResult(directions: directions, usedFallback: false);
    } catch (e) {
      debugPrint('Directions request failed: $e');
      return _fallbackResult(origin, destination);
    }
  }

  DirectionsRouteResult _fallbackResult(LatLng origin, LatLng destination) {
    final directions = _fallback(origin, destination);
    if (directions.distanceKm <= 0) {
      return const DirectionsRouteResult(directions: null, usedFallback: true);
    }
    return DirectionsRouteResult(directions: directions, usedFallback: true);
  }

  TripDirectionsResult _fallback(LatLng origin, LatLng destination) {
    final distanceKm = PlacesDetailsService.estimateDistanceKm(
      origin,
      destination,
    );
    return TripDirectionsResult(
      distanceKm: distanceKm,
      durationMinutes: PlacesDetailsService.estimateDurationMinutes(distanceKm),
      polylinePoints: [origin, destination],
    );
  }
}
