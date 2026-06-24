import 'package:local_ent_280/core/services/client_tariff_service.dart';
import 'package:local_ent_280/features/admin/data/admin_tariff_payload.dart';

class TripPriceEstimate {
  const TripPriceEstimate({
    required this.totalMinor,
    required this.baseMinor,
    required this.distanceMinor,
    required this.multiplier,
    required this.multiplierId,
  });

  final int totalMinor;
  final int baseMinor;
  final int distanceMinor;
  final double multiplier;
  final String multiplierId;
}

/// Estimates trip price from tariff + route distance (same rules as backend).
class TripPriceEstimator {
  const TripPriceEstimator();

  TripPriceEstimate estimate({
    required ClientTariff tariff,
    required String transportTypeId,
    required double distanceKm,
    int durationMinutes = 0,
    int transportBaseFallbackMinor = 250,
  }) {
    final normalizedDistanceKm = distanceKm < 0 ? 0.0 : distanceKm;
    final distanceMeters = (normalizedDistanceKm * 1000).round();
    final baseMinor = tariff.baseMinorForTransportType(
      transportTypeId,
      fallbackMinor: transportBaseFallbackMinor,
    );
    final distanceMinor = _distanceTierCharge(
      totalMeters: distanceMeters,
      tiers: tariff.resolvedDistanceTiers(),
    );
    const multiplier = 1.0;
    final subtotalMinor = baseMinor + distanceMinor;
    final totalMinor = (subtotalMinor * multiplier).ceil();

    return TripPriceEstimate(
      totalMinor: totalMinor,
      baseMinor: baseMinor,
      distanceMinor: distanceMinor,
      multiplier: multiplier,
      multiplierId: 'transport:$transportTypeId',
    );
  }

  int _distanceTierCharge({
    required int totalMeters,
    required List<Map<String, dynamic>> tiers,
  }) {
    if (totalMeters <= 0 || tiers.isEmpty) return 0;

    var chargeMinor = 0;
    var expectedStartMeters = 0;
    for (var index = 0; index < tiers.length; index++) {
      final tier = tiers[index];
      final tierStart = (tier['startMetersInclusive'] as num?)?.toInt() ?? 0;
      if (tierStart != expectedStartMeters) break;

      final isLast = index == tiers.length - 1;
      final tierEnd = isLast
          ? totalMeters
          : (tier['endMetersExclusive'] as num?)?.toInt() ?? totalMeters;
      final coveredMeters = _coveredMeters(
        totalMeters: totalMeters,
        tierStart: tierStart,
        tierEnd: tierEnd,
      );
      if (coveredMeters <= 0) continue;

      final perKmMinor = readEurMinor(tier['perKm']);
      final numerator = coveredMeters * perKmMinor;
      chargeMinor += _roundHalfUp(numerator: numerator, denominator: 1000);

      if (!isLast) {
        expectedStartMeters = tierEnd;
      }
    }
    return chargeMinor;
  }

  int _coveredMeters({
    required int totalMeters,
    required int tierStart,
    required int tierEnd,
  }) {
    if (totalMeters <= tierStart || tierEnd <= tierStart) return 0;
    final effectiveEnd = totalMeters < tierEnd ? totalMeters : tierEnd;
    return effectiveEnd - tierStart;
  }

  int _roundHalfUp({required int numerator, required int denominator}) {
    return (numerator + (denominator ~/ 2)) ~/ denominator;
  }
}
