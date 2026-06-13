import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';

/// Fleet overview metrics for the admin home dashboard.
class AdminDashboardStats {
  const AdminDashboardStats({
    required this.activeTripsCount,
    required this.availableDriversCount,
    required this.activeTripsTrendPercent,
    required this.pendingDebtorCount,
    required this.pendingDebtEur,
  });

  final int activeTripsCount;
  final int availableDriversCount;
  final int activeTripsTrendPercent;
  final int pendingDebtorCount;
  final double pendingDebtEur;

  static const empty = AdminDashboardStats(
    activeTripsCount: 0,
    availableDriversCount: 0,
    activeTripsTrendPercent: 0,
    pendingDebtorCount: 0,
    pendingDebtEur: 0,
  );

  String get activeTripsFormatted => '$activeTripsCount';

  String get availableDriversFormatted => '$availableDriversCount';

  String get activeTripsTrendLabel {
    if (activeTripsTrendPercent > 0) return '+$activeTripsTrendPercent%';
    if (activeTripsTrendPercent < 0) return '$activeTripsTrendPercent%';
    return '0%';
  }

  bool get activeTripsTrendingUp => activeTripsTrendPercent >= 0;

  String get pendingDebtFormatted =>
      AppCurrencyFormatter.instance.formatEurMajor(pendingDebtEur);

  String pendingDebtorsSubtitle(int invoiceLabel) =>
      pendingDebtorCount == 0
          ? '0'
          : '$pendingDebtorCount';

  static AdminDashboardStats fromTripsAndDrivers({
    required List<TripRecord> trips,
    required int availableDrivers,
    required int pendingDebtorCount,
    required double pendingDebtEur,
  }) {
    const activeStatuses = {
      'DRIVER_ASSIGNED_WAITING_ACCEPTANCE',
      'DRIVER_ACCEPTED',
      'DRIVER_EN_ROUTE',
      'DRIVER_ARRIVED',
      'IN_TRIP',
      'ARRIVED_DESTINATION',
      'EXTENSION_WINDOW',
      'REQUESTED',
    };

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    int activeOnDay(DateTime day) {
      return trips.where((trip) {
        if (!trip.isActive && !activeStatuses.contains(trip.status)) {
          return false;
        }
        if (!activeStatuses.contains(trip.status) && !trip.isActive) {
          return false;
        }
        final date = trip.createdAt;
        if (date == null) return day == today;
        final tripDay = DateTime(date.year, date.month, date.day);
        return tripDay == day &&
            (trip.isActive || activeStatuses.contains(trip.status));
      }).length;
    }

    final todayActive = trips
        .where((t) => t.isActive || activeStatuses.contains(t.status))
        .length;
    final yesterdayActive = activeOnDay(yesterday);

    int trend = 0;
    if (yesterdayActive == 0 && todayActive > 0) {
      trend = 100;
    } else if (yesterdayActive > 0) {
      trend =
          (((todayActive - yesterdayActive) / yesterdayActive) * 100).round();
    }

    return AdminDashboardStats(
      activeTripsCount: todayActive,
      availableDriversCount: availableDrivers,
      activeTripsTrendPercent: trend,
      pendingDebtorCount: pendingDebtorCount,
      pendingDebtEur: pendingDebtEur,
    );
  }
}

/// Aggregated reporting metrics for the admin reports screen.
class AdminReportsStats {
  const AdminReportsStats({
    required this.totalTrips,
    required this.tripsTrendPercent,
    required this.totalDistanceKm,
    required this.totalMinutes,
    required this.totalRevenueEur,
    required this.pendingDebtEur,
    required this.recentActivities,
    required this.fleetEfficiencyPercent,
  });

  final int totalTrips;
  final int tripsTrendPercent;
  final double totalDistanceKm;
  final int totalMinutes;
  final double totalRevenueEur;
  final double pendingDebtEur;
  final List<AdminReportActivityRow> recentActivities;
  final int fleetEfficiencyPercent;

  static const empty = AdminReportsStats(
    totalTrips: 0,
    tripsTrendPercent: 0,
    totalDistanceKm: 0,
    totalMinutes: 0,
    totalRevenueEur: 0,
    pendingDebtEur: 0,
    recentActivities: [],
    fleetEfficiencyPercent: 0,
  );

  String get totalTripsFormatted {
    if (totalTrips >= 1000) {
      return '${(totalTrips / 1000).toStringAsFixed(1)}k';
    }
    return _formatNumber(totalTrips);
  }

  String get tripsTrendLabel {
    if (tripsTrendPercent > 0) return '+$tripsTrendPercent%';
    if (tripsTrendPercent < 0) return '$tripsTrendPercent%';
    return '0%';
  }

  String get totalDistanceFormatted {
    if (totalDistanceKm >= 1000) {
      return '${(totalDistanceKm / 1000).toStringAsFixed(1)}k';
    }
    return totalDistanceKm.round().toString();
  }

  String get timeOnRouteFormatted {
    final hours = (totalMinutes / 60).round();
    if (hours >= 1000) return '${(hours / 1000).toStringAsFixed(1)}k';
    return '$hours';
  }

  String get totalCostFormatted {
    final revenue = AppCurrencyFormatter.instance.convertEurMajor(totalRevenueEur);
    if (revenue >= 1000) {
      return '${(revenue / 1000).toStringAsFixed(1)}k';
    }
    return revenue.round().toString();
  }

  String get pendingDebtFormatted {
    final debt = AppCurrencyFormatter.instance.convertEurMajor(pendingDebtEur);
    if (debt >= 1000) {
      return '${(debt / 1000).toStringAsFixed(1)}k';
    }
    return debt.toStringAsFixed(0);
  }

  static String _formatNumber(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final fromEnd = text.length - i;
      if (i > 0 && fromEnd % 3 == 0) buffer.write(',');
      buffer.write(text[i]);
    }
    return buffer.toString();
  }

  factory AdminReportsStats.fromTrips({
    required List<TripRecord> trips,
    required double pendingDebtEur,
  }) {
    final completed = trips.where((t) => t.status == 'COMPLETED').toList();
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);

    int countForMonth(DateTime month) {
      return completed.where((trip) {
        final date = trip.completedAt ?? trip.updatedAt ?? trip.createdAt;
        if (date == null) return false;
        return date.year == month.year && date.month == month.month;
      }).length;
    }

    final monthCompleted = completed.where((trip) {
      final date = trip.completedAt ?? trip.updatedAt ?? trip.createdAt;
      if (date == null) return true;
      return date.year == now.year && date.month == now.month;
    }).toList();

    final thisMonthCount = countForMonth(thisMonth);
    final lastMonthCount = countForMonth(lastMonth);
    var trend = 0;
    if (lastMonthCount == 0 && thisMonthCount > 0) {
      trend = 100;
    } else if (lastMonthCount > 0) {
      trend =
          (((thisMonthCount - lastMonthCount) / lastMonthCount) * 100).round();
    }

    final distance = monthCompleted.fold<double>(
      0,
      (sum, t) => sum + t.meteringSnapshot.totalDistanceKm,
    );
    final minutes = monthCompleted.fold<int>(
      0,
      (sum, t) => sum + t.meteringSnapshot.totalMinutes,
    );
    final revenue = monthCompleted.fold<double>(
      0,
      (sum, t) => sum + t.meteringSnapshot.estimatedCostMinor / 100,
    );

    final activities = completed.take(5).map((trip) {
      final date = trip.completedAt ?? trip.updatedAt ?? trip.createdAt;
      final time = date == null
          ? '—'
          : '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}h';
      return AdminReportActivityRow(
        title: trip.destination.address,
        reference: trip.id.length > 8 ? trip.id.substring(0, 8).toUpperCase() : trip.id,
        time: time,
        amount: trip.fareFormatted,
      );
    }).toList();

    final assignedTrips =
        trips.where((t) => t.hasAssignedDriver && t.status == 'COMPLETED').length;
    final efficiency = completed.isEmpty
        ? 0
        : ((assignedTrips / completed.length) * 100).round().clamp(0, 100);

    return AdminReportsStats(
      totalTrips: monthCompleted.length,
      tripsTrendPercent: trend,
      totalDistanceKm: distance,
      totalMinutes: minutes,
      totalRevenueEur: revenue,
      pendingDebtEur: pendingDebtEur,
      recentActivities: activities,
      fleetEfficiencyPercent: efficiency,
    );
  }
}

class AdminReportActivityRow {
  const AdminReportActivityRow({
    required this.title,
    required this.reference,
    required this.time,
    required this.amount,
  });

  final String title;
  final String reference;
  final String time;
  final String amount;
}

class AdminTariffSummary {
  const AdminTariffSummary({
    required this.perKmEur,
    this.dynamicMultiplier,
  });

  final double perKmEur;
  final double? dynamicMultiplier;

  String get perKmFormatted =>
      AppCurrencyFormatter.instance.formatEurMajorWithSuffix(perKmEur, '/km');

  String? get dynamicLabel {
    if (dynamicMultiplier == null || dynamicMultiplier! <= 1) return null;
    return '${dynamicMultiplier!.toStringAsFixed(1)}x';
  }
}

class AdminFleetRow {
  const AdminFleetRow({
    required this.vehicleLabel,
    required this.driverLabel,
    required this.isOnTrip,
  });

  final String vehicleLabel;
  final String driverLabel;
  final bool isOnTrip;
}

/// Market data for admin dashboard (fuel cost, map label, default center).
class AdminMarketSummary {
  const AdminMarketSummary({
    required this.fuelCostPerLiterEur,
    this.activityMapLabel,
    this.centerLatitude,
    this.centerLongitude,
  });

  final double fuelCostPerLiterEur;
  final String? activityMapLabel;
  final double? centerLatitude;
  final double? centerLongitude;

  String get fuelCostFormatted =>
      AppCurrencyFormatter.instance.formatEurMajorWithSuffix(
        fuelCostPerLiterEur,
        '/L',
      );

  bool get hasFuelCost => fuelCostPerLiterEur > 0;

  bool get hasMapCenter =>
      centerLatitude != null &&
      centerLongitude != null &&
      (centerLatitude != 0 || centerLongitude != 0);
}

/// A point shown on the admin activity map.
class AdminMapMarker {
  const AdminMapMarker({
    required this.latitude,
    required this.longitude,
    required this.kind,
    this.label,
  });

  final double latitude;
  final double longitude;
  final AdminMapMarkerKind kind;
  final String? label;

  bool get isDriver => kind == AdminMapMarkerKind.driver;
}

enum AdminMapMarkerKind { tripPickup, tripDestination, driver }

/// Live activity map data from active trips and driver locations.
class AdminActivityMapData {
  const AdminActivityMapData({
    required this.markers,
    this.locationLabel,
    this.centerLatitude,
    this.centerLongitude,
    this.activeTripCount = 0,
    this.activeDriverCount = 0,
  });

  final List<AdminMapMarker> markers;
  final String? locationLabel;
  final double? centerLatitude;
  final double? centerLongitude;
  final int activeTripCount;
  final int activeDriverCount;

  static const empty = AdminActivityMapData(markers: []);

  bool get hasMapCenter =>
      centerLatitude != null &&
      centerLongitude != null &&
      (centerLatitude != 0 || centerLongitude != 0);

  bool get hasLiveMarkers => markers.isNotEmpty;
}
