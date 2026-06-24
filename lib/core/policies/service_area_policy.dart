import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:local_ent_280/core/config/google_maps_config.dart';

/// Matches backend driver search radius and supported operating regions.
abstract final class ServiceAreaPolicy {
  static const maxDispatchRadiusKm = 100.0;

  static const _praia = _ServiceHub(
    latitude: GoogleMapsConfig.defaultMapLat,
    longitude: GoogleMapsConfig.defaultMapLng,
    label: 'Cabo Verde',
  );

  static const _lisbon = _ServiceHub(
    latitude: 38.7223,
    longitude: -9.1393,
    label: 'Portugal',
  );

  static bool isPickupEligibleForDispatch({
    required double latitude,
    required double longitude,
  }) {
    final hubs = kDebugMode ? [_praia, _lisbon] : [_praia];
    for (final hub in hubs) {
      if (_distanceKm(latitude, longitude, hub.latitude, hub.longitude) <=
          maxDispatchRadiusKm) {
        return true;
      }
    }
    return false;
  }

  static String nearestHubLabel({
    required double latitude,
    required double longitude,
  }) {
    final hubs = kDebugMode ? [_praia, _lisbon] : [_praia];
    _ServiceHub? nearest;
    var nearestDistance = double.infinity;
    for (final hub in hubs) {
      final distance =
          _distanceKm(latitude, longitude, hub.latitude, hub.longitude);
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = hub;
      }
    }
    return nearest?.label ?? _praia.label;
  }

  static double _distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}

class _ServiceHub {
  const _ServiceHub({
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  final double latitude;
  final double longitude;
  final String label;
}
