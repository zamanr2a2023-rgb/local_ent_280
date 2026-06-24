import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/pricing/domain/entities/tariff_multiplier_rule.dart';
import 'package:local_transport/features/pricing/domain/usecases/resolve_tariff_multiplier.dart';

void main() {
  const useCase = ResolveTariffMultiplier();

  group('ResolveTariffMultiplier', () {
    test('combines time range and holiday multipliers', () {
      final result = useCase(
        rules: [
          TariffMultiplierRule(
            id: 'time_range_0800_1000',
            type: TariffMultiplierType.timeRange,
            multiplier: 1.2,
            timeRange: const TariffTimeRange(
              startMinutes: 8 * 60,
              endMinutes: 10 * 60,
            ),
          ),
          TariffMultiplierRule(
            id: 'holiday',
            type: TariffMultiplierType.holiday,
            multiplier: 1.5,
            holidayDates: [DateTime(2026, 12, 25)],
          ),
        ],
        tripStart: DateTime.utc(2026, 12, 25, 8, 30),
        transportTypeId: 'standard',
      );

      expect(
        result.id,
        'transport:standard|time:time_range_0800_1000|holiday:holiday',
      );
      expect(result.multiplier, closeTo(1.8, 0.000001));
      expect(result.timeRangeRuleId, 'time_range_0800_1000');
      expect(result.timeRangeMultiplier, 1.2);
      expect(result.holidayRuleId, 'holiday');
      expect(result.holidayMultiplier, 1.5);
      expect(result.evaluationTimeZone, 'Europe/Lisbon');
    });

    test('applies time range when no holiday matches', () {
      final result = useCase(
        rules: [
          TariffMultiplierRule(
            id: 'time_range_0800_1000',
            type: TariffMultiplierType.timeRange,
            multiplier: 1.2,
            timeRange: const TariffTimeRange(
              startMinutes: 8 * 60,
              endMinutes: 10 * 60,
            ),
          ),
        ],
        tripStart: DateTime.utc(2026, 3, 20, 8, 30),
        transportTypeId: 'standard',
      );

      expect(
        result.id,
        'transport:standard|time:time_range_0800_1000|holiday:none',
      );
      expect(result.multiplier, closeTo(1.2, 0.000001));
      expect(result.timeRangeRuleId, 'time_range_0800_1000');
      expect(result.holidayRuleId, isNull);
    });

    test('falls back to neutral multiplier when no rule matches', () {
      final result = useCase(
        rules: [
          TariffMultiplierRule(
            id: 'holiday',
            type: TariffMultiplierType.holiday,
            multiplier: 1.5,
            holidayDates: [DateTime(2026, 12, 25)],
          ),
        ],
        tripStart: DateTime.utc(2026, 3, 20, 8, 30),
        transportTypeId: 'standard',
      );

      expect(result.id, 'transport:standard|time:none|holiday:none');
      expect(result.multiplier, closeTo(1.0, 0.000001));
      expect(result.timeRangeRuleId, isNull);
      expect(result.holidayRuleId, isNull);
    });

    test(
      'supports overnight time ranges with inclusive start and exclusive end',
      () {
        final result = useCase(
          rules: [
            TariffMultiplierRule(
              id: 'time_range_2200_0200',
              type: TariffMultiplierType.timeRange,
              multiplier: 1.3,
              timeRange: const TariffTimeRange(
                startMinutes: 22 * 60,
                endMinutes: 2 * 60,
              ),
            ),
          ],
          tripStart: DateTime.utc(2026, 3, 20, 1, 30),
          transportTypeId: 'standard',
        );

        expect(
          result.id,
          'transport:standard|time:time_range_2200_0200|holiday:none',
        );
        expect(result.multiplier, closeTo(1.3, 0.000001));
      },
    );

    test('evaluates reservation instant in Europe/Lisbon across DST', () {
      final result = useCase(
        rules: [
          TariffMultiplierRule(
            id: 'time_range_0200_0300',
            type: TariffMultiplierType.timeRange,
            multiplier: 1.4,
            timeRange: const TariffTimeRange(
              startMinutes: 2 * 60,
              endMinutes: 3 * 60,
            ),
          ),
        ],
        tripStart: DateTime.utc(2026, 3, 29, 1, 30),
        transportTypeId: 'standard',
      );

      expect(
        result.id,
        'transport:standard|time:time_range_0200_0300|holiday:none',
      );
      expect(result.multiplier, closeTo(1.4, 0.000001));
    });

    test(
      'resolves legacy overlapping time ranges to the highest multiplier',
      () {
        final result = useCase(
          rules: [
            TariffMultiplierRule(
              id: 'time_range_low',
              type: TariffMultiplierType.timeRange,
              multiplier: 1.2,
              timeRange: const TariffTimeRange(
                startMinutes: 8 * 60,
                endMinutes: 10 * 60,
              ),
            ),
            TariffMultiplierRule(
              id: 'time_range_high',
              type: TariffMultiplierType.timeRange,
              multiplier: 1.5,
              timeRange: const TariffTimeRange(
                startMinutes: 9 * 60,
                endMinutes: 11 * 60,
              ),
            ),
          ],
          tripStart: DateTime.utc(2026, 3, 20, 9, 30),
          transportTypeId: 'standard',
        );

        expect(
          result.id,
          'transport:standard|time:time_range_high|holiday:none',
        );
        expect(result.multiplier, closeTo(1.5, 0.000001));
      },
    );
  });
}
