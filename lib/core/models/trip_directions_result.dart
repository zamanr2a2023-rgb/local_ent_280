import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDirectionsResult {
  const TripDirectionsResult({
    required this.distanceKm,
    required this.durationMinutes,
    required this.polylinePoints,
  });

  final double distanceKm;
  final int durationMinutes;
  final List<LatLng> polylinePoints;

  String get formattedDistance {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  String get formattedDuration => '$durationMinutes min';
}
