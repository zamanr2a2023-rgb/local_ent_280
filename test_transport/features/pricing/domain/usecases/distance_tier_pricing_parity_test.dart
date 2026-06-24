import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/pricing/domain/entities/tariff.dart';
import 'package:local_transport/features/pricing/domain/entities/tariff_distance_tier.dart';
import 'package:local_transport/features/pricing/domain/entities/tariff_penalty_fees.dart';
import 'package:local_transport/features/pricing/domain/usecases/calculate_distance_tier_charge.dart';
import 'package:local_transport/features/pricing/domain/usecases/estimate_trip_price.dart';
import 'package:local_transport/features/pricing/domain/usecases/resolve_tariff_multiplier.dart';

void main() {
  final cases = _loadCases();

  group('Distance tier pricing parity dataset', () {
    const calculateDistanceTierCharge = CalculateDistanceTierCharge();
    const estimateTripPrice = EstimateTripPrice();

    for (final scenario in cases) {
      test(scenario.name, () {
        final tariff = Tariff(
          id: 'test_tariff',
          baseByTransportType: {
            'standard': Money(
              amountMinor: scenario.baseMinor,
              currency: CurrencyCode.eur,
            ),
          },
          perKm: Money(
            amountMinor: scenario.fallbackPerKmMinor,
            currency: CurrencyCode.eur,
          ),
          perWaitMinute: Money(
            amountMinor: scenario.perWaitMinuteMinor,
            currency: CurrencyCode.eur,
          ),
          distanceTiers: scenario.tiers,
          penaltyFees: const TariffPenaltyFees.empty(),
          multiplierRules: const [],
        );

        final distanceChargeMinor = calculateDistanceTierCharge(
          totalMeters: scenario.totalMeters,
          tiers: tariff.resolvedDistanceTiers,
        );
        expect(distanceChargeMinor, scenario.expectedDistanceChargeMinor);

        final estimatedTotalMinor = estimateTripPrice(
          tariff: tariff,
          transportTypeId: 'standard',
          distanceMeters: scenario.totalMeters,
          durationMinutes: scenario.durationMinutes,
          multiplierSelection: TariffMultiplierSelection(
            id: 'transport:standard|time:none|holiday:none',
            multiplier: scenario.multiplier,
            transportTypeId: 'standard',
            timeRangeRuleId: null,
            timeRangeMultiplier: null,
            holidayRuleId: null,
            holidayMultiplier: null,
            evaluationTimestamp: DateTime.utc(2026, 3, 20, 8, 30),
            evaluationTimeZone: 'Europe/Lisbon',
          ),
        );
        expect(estimatedTotalMinor, scenario.expectedEstimateMinor);
      });
    }
  });
}

List<_DistanceTierScenario> _loadCases() {
  final content = File(
    'contracts/pricing/distance_tiers_cases.json',
  ).readAsStringSync();
  final json = jsonDecode(content) as Map<String, dynamic>;
  final cases = json['cases'] as List<dynamic>? ?? const [];
  return cases
      .whereType<Map>()
      .map(
        (entry) =>
            _DistanceTierScenario.fromJson(Map<String, dynamic>.from(entry)),
      )
      .toList(growable: false);
}

class _DistanceTierScenario {
  const _DistanceTierScenario({
    required this.name,
    required this.totalMeters,
    required this.durationMinutes,
    required this.baseMinor,
    required this.perWaitMinuteMinor,
    required this.fallbackPerKmMinor,
    required this.multiplier,
    required this.expectedDistanceChargeMinor,
    required this.expectedEstimateMinor,
    required this.tiers,
  });

  final String name;
  final int totalMeters;
  final int durationMinutes;
  final int baseMinor;
  final int perWaitMinuteMinor;
  final int fallbackPerKmMinor;
  final double multiplier;
  final int expectedDistanceChargeMinor;
  final int expectedEstimateMinor;
  final List<TariffDistanceTier> tiers;

  factory _DistanceTierScenario.fromJson(Map<String, dynamic> json) {
    final tiersJson = json['tiers'] as List<dynamic>? ?? const [];
    return _DistanceTierScenario(
      name: json['name'] as String,
      totalMeters: json['totalMeters'] as int,
      durationMinutes: json['durationMinutes'] as int,
      baseMinor: json['baseMinor'] as int,
      perWaitMinuteMinor: json['perWaitMinuteMinor'] as int,
      fallbackPerKmMinor: json['fallbackPerKmMinor'] as int,
      multiplier: (json['multiplier'] as num).toDouble(),
      expectedDistanceChargeMinor: json['expectedDistanceChargeMinor'] as int,
      expectedEstimateMinor: json['expectedEstimateMinor'] as int,
      tiers: tiersJson
          .whereType<Map>()
          .map((entry) {
            final map = Map<String, dynamic>.from(entry);
            return TariffDistanceTier(
              startMetersInclusive: map['startMetersInclusive'] as int,
              endMetersExclusive: map['endMetersExclusive'] as int?,
              perKm: Money(
                amountMinor: map['perKmMinor'] as int,
                currency: CurrencyCode.eur,
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
