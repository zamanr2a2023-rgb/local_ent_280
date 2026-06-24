import 'package:flutter/material.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';

class RecentTripPlace {
  const RecentTripPlace({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.filledIcon = false,
    this.latitude,
    this.longitude,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool filledIcon;
  final double? latitude;
  final double? longitude;
}

abstract final class RecentTripDestinations {
  static const _completedStatuses = {
    'COMPLETED',
    'TRIP_COMPLETED',
    'DONE',
    'ARRIVED_DESTINATION',
  };

  static List<RecentTripPlace> fromTrips(
    List<TripRecord> trips, {
    int limit = 5,
  }) {
    final seen = <String>{};
    final places = <RecentTripPlace>[];

    for (final trip in trips) {
      if (!_completedStatuses.contains(trip.status.toUpperCase())) continue;
      final address = trip.destination.address.trim();
      if (address.isEmpty || seen.contains(address)) continue;
      seen.add(address);
      final lat = trip.destination.latitude;
      final lng = trip.destination.longitude;
      places.add(
        RecentTripPlace(
          title: _titleFromAddress(address),
          subtitle: address,
          icon: Icons.history,
          latitude: lat != 0 ? lat : null,
          longitude: lng != 0 ? lng : null,
        ),
      );
      if (places.length >= limit) break;
    }

    return places;
  }

  static String _titleFromAddress(String address) {
    final firstSegment = address.split(',').first.trim();
    return firstSegment.isEmpty ? address : firstSegment;
  }
}
