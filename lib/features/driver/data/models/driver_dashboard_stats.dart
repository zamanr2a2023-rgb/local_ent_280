import 'package:local_ent_280/core/data/driver_home_data.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';

/// Aggregated driver home metrics computed from Firestore `trips`.
class DriverDashboardStats {
  const DriverDashboardStats({
    required this.todayEarningsEur,
    required this.todayTripCount,
    required this.todayDistanceKm,
    required this.yesterdayEarningsEur,
    required this.recentTrips,
  });

  final double todayEarningsEur;
  final int todayTripCount;
  final double todayDistanceKm;
  final double yesterdayEarningsEur;
  final List<DriverRecentTrip> recentTrips;

  static const empty = DriverDashboardStats(
    todayEarningsEur: 0,
    todayTripCount: 0,
    todayDistanceKm: 0,
    yesterdayEarningsEur: 0,
    recentTrips: [],
  );

  String get todayEarningsFormatted =>
      AppCurrencyFormatter.instance.formatEurMajor(todayEarningsEur);

  String get todayTripCountFormatted => '$todayTripCount';

  String get todayDistanceFormatted {
    if (todayDistanceKm <= 0) return '0 km';
    final rounded = todayDistanceKm.round();
    return '$rounded km';
  }

  /// e.g. "+12%", "-5%", "0%", "+100%"
  String get earningsChangePercent {
    if (todayEarningsEur == 0 && yesterdayEarningsEur == 0) return '0%';
    if (yesterdayEarningsEur == 0) return '+100%';
    final delta =
        ((todayEarningsEur - yesterdayEarningsEur) / yesterdayEarningsEur) * 100;
    final rounded = delta.round();
    if (rounded > 0) return '+$rounded%';
    if (rounded < 0) return '$rounded%';
    return '0%';
  }

  bool get earningsTrendingUp =>
      todayEarningsEur >= yesterdayEarningsEur;

  factory DriverDashboardStats.fromTrips(List<TripRecord> trips) {
    final completed = trips.where((trip) => trip.status == 'COMPLETED').toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    double earningsForDay(DateTime day) {
      return completed
          .where((trip) => _tripDay(trip) == day)
          .fold<double>(
            0,
            (sum, trip) =>
                sum + trip.meteringSnapshot.estimatedCostMinor / 100,
          );
    }

    int tripsForDay(DateTime day) {
      return completed.where((trip) => _tripDay(trip) == day).length;
    }

    double distanceForDay(DateTime day) {
      return completed
          .where((trip) => _tripDay(trip) == day)
          .fold<double>(
            0,
            (sum, trip) => sum + trip.meteringSnapshot.totalDistanceKm,
          );
    }

    final recent = completed.take(3).map((trip) {
      final tripDate = _tripCompletionDate(trip);
      final hoursAgo = tripDate == null
          ? 0
          : DateTime.now().difference(tripDate).inHours;
      return DriverRecentTrip(
        passengerName: trip.passengerName,
        destination: trip.destination.address,
        price: trip.fareFormatted,
        hoursAgo: hoursAgo.clamp(0, 999),
      );
    }).toList();

    return DriverDashboardStats(
      todayEarningsEur: earningsForDay(today),
      todayTripCount: tripsForDay(today),
      todayDistanceKm: distanceForDay(today),
      yesterdayEarningsEur: earningsForDay(yesterday),
      recentTrips: recent,
    );
  }

  static DateTime? _tripDay(TripRecord trip) {
    final date = _tripCompletionDate(trip);
    if (date == null) return null;
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime? _tripCompletionDate(TripRecord trip) {
    return trip.completedAt ?? trip.updatedAt ?? trip.createdAt;
  }
}
