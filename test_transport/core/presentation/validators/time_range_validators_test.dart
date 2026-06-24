import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/services/day_minute_overlap_detector.dart';
import 'package:local_transport/core/presentation/validators/time_range_validators.dart';

void main() {
  group('TimeRangeValidators.normalizeRange', () {
    test('normaliza range no mesmo dia', () {
      final result = TimeRangeValidators.normalizeRange(
        startMinutes: 600,
        endMinutes: 660,
      );

      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result.first.startInclusive, 600);
      expect(result.first.endExclusive, 660);
    });

    test('normaliza overnight em dois segmentos', () {
      final result = TimeRangeValidators.normalizeRange(
        startMinutes: 1320,
        endMinutes: 120,
      );

      expect(result, isNotNull);
      expect(result!.length, 2);
      expect(result[0].startInclusive, 1320);
      expect(result[0].endExclusive, 1440);
      expect(result[1].startInclusive, 0);
      expect(result[1].endExclusive, 120);
    });

    test('rejeita intervalo de duração zero', () {
      final result = TimeRangeValidators.normalizeRange(
        startMinutes: 120,
        endMinutes: 120,
      );

      expect(result, isNull);
    });
  });

  group('TimeRangeValidators.validateNonOverlapping', () {
    test('aceita adjacentes [10:00,11:00) e [11:00,12:00)', () {
      final validation = TimeRangeValidators.validateNonOverlapping(
        const <DayMinuteRange>[
          DayMinuteRange(startMinutes: 600, endMinutes: 660),
          DayMinuteRange(startMinutes: 660, endMinutes: 720),
        ],
      );

      expect(validation.hasOverlap, isFalse);
      expect(validation.isValid, isTrue);
    });

    test('deteta overlap simples', () {
      final validation = TimeRangeValidators.validateNonOverlapping(
        const <DayMinuteRange>[
          DayMinuteRange(startMinutes: 600, endMinutes: 700),
          DayMinuteRange(startMinutes: 650, endMinutes: 720),
        ],
      );

      expect(validation.hasOverlap, isTrue);
      expect(validation.isValid, isFalse);
    });

    test('deteta overlap com overnight normalizado internamente', () {
      final validation = TimeRangeValidators.validateNonOverlapping(
        const <DayMinuteRange>[
          DayMinuteRange(startMinutes: 1320, endMinutes: 120),
          DayMinuteRange(startMinutes: 100, endMinutes: 200),
        ],
      );

      expect(validation.hasOverlap, isTrue);
      expect(validation.isValid, isFalse);
    });

    test('marca out-of-bounds e zero-length', () {
      final validation = TimeRangeValidators.validateNonOverlapping(
        const <DayMinuteRange>[
          DayMinuteRange(startMinutes: -1, endMinutes: 60),
          DayMinuteRange(startMinutes: 60, endMinutes: 60),
        ],
      );

      expect(validation.hasOutOfBounds, isTrue);
      expect(validation.hasZeroLengthRange, isTrue);
      expect(validation.isValid, isFalse);
    });
  });
}
