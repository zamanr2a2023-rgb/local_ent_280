import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/pricing/domain/entities/tariff.dart';
import 'package:local_transport/features/pricing/domain/entities/tariff_penalty_fees.dart';
import 'package:local_transport/features/pricing/domain/usecases/estimate_trip_price_breakdown.dart';
import 'package:local_transport/features/pricing/domain/usecases/resolve_tariff_multiplier.dart';

void main() {
  const useCase = EstimateTripPriceBreakdown();

  group('EstimateTripPriceBreakdown', () {
    test('calculates total with multiplier 1.0', () {
      final breakdown = useCase(
        tariff: _tariff(baseMinor: 100, perKmMinor: 200),
        transportTypeId: 'standard',
        distanceMeters: 2500,
        durationMinutes: 6,
        distanceKm: 2.5,
        multiplierSelection: TariffMultiplierSelection(
          id: 'transport:standard|time:none|holiday:none',
          multiplier: 1,
          transportTypeId: 'standard',
          timeRangeRuleId: null,
          timeRangeMultiplier: null,
          holidayRuleId: null,
          holidayMultiplier: null,
          evaluationTimestamp: DateTime.utc(2026, 3, 20, 8, 30),
          evaluationTimeZone: 'Europe/Lisbon',
        ),
      );

      expect(breakdown.baseMinor, 100);
      expect(breakdown.distanceMinor, 500);
      expect(breakdown.subtotalMinor, 600);
      expect(breakdown.multiplierChargeMinor, 0);
      expect(breakdown.totalMinor, 600);
      expect(
        breakdown.multiplierId,
        'transport:standard|time:none|holiday:none',
      );
      expect(breakdown.transportTypeId, 'standard');
      expect(breakdown.timeRangeMultiplier, isNull);
      expect(breakdown.holidayMultiplier, isNull);
    });

    test('applies ceil rounding only at total level', () {
      final breakdown = useCase(
        tariff: _tariff(baseMinor: 123, perKmMinor: 107),
        transportTypeId: 'standard',
        distanceMeters: 1500,
        durationMinutes: 5,
        distanceKm: 1.5,
        multiplierSelection: TariffMultiplierSelection(
          id: 'transport:standard|time:time_1|holiday:none',
          multiplier: 1.2,
          transportTypeId: 'standard',
          timeRangeRuleId: 'time_1',
          timeRangeMultiplier: 1.2,
          holidayRuleId: null,
          holidayMultiplier: null,
          evaluationTimestamp: DateTime.utc(2026, 3, 20, 8, 30),
          evaluationTimeZone: 'Europe/Lisbon',
        ),
      );

      expect(breakdown.subtotalMinor, 284);
      expect(breakdown.totalMinor, 341);
      expect(breakdown.multiplierChargeMinor, 57);
      expect(breakdown.subtotalMinor + breakdown.multiplierChargeMinor, 341);
      expect(
        breakdown.multiplierId,
        'transport:standard|time:time_1|holiday:none',
      );
      expect(breakdown.timeRangeRuleId, 'time_1');
      expect(breakdown.holidayRuleId, isNull);
    });

    test('normalizes negative distance and duration to zero', () {
      final breakdown = useCase(
        tariff: _tariff(baseMinor: 100, perKmMinor: 300),
        transportTypeId: 'standard',
        distanceMeters: -10,
        durationMinutes: -5,
        distanceKm: -2,
        multiplierSelection: TariffMultiplierSelection(
          id: 'transport:standard|time:none|holiday:none',
          multiplier: 1.5,
          transportTypeId: 'standard',
          timeRangeRuleId: null,
          timeRangeMultiplier: null,
          holidayRuleId: null,
          holidayMultiplier: null,
          evaluationTimestamp: DateTime.utc(2026, 3, 20, 8, 30),
          evaluationTimeZone: 'Europe/Lisbon',
        ),
      );

      expect(breakdown.distanceMinor, 0);
      expect(breakdown.distanceKm, 0);
      expect(breakdown.durationMinutes, 0);
      expect(breakdown.subtotalMinor, 100);
      expect(breakdown.totalMinor, 150);
      expect(breakdown.multiplierChargeMinor, 50);
    });
  });
}

Tariff _tariff({
  required int baseMinor,
  required int perKmMinor,
}) {
  return Tariff(
    id: 'tariff_test',
    baseByTransportType: {
      'standard': Money(amountMinor: baseMinor, currency: CurrencyCode.eur),
    },
    perKm: Money(amountMinor: perKmMinor, currency: CurrencyCode.eur),
    perWaitMinute: const Money(amountMinor: 0, currency: CurrencyCode.eur),
    penaltyFees: const TariffPenaltyFees.empty(),
  );
}
