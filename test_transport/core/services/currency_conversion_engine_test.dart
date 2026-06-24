import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/core/domain/value_objects/decimal_ratio.dart';
import 'package:local_transport/core/services/currency_conversion_engine.dart';

void main() {
  group('DecimalRatio.parse', () {
    test('parses dot and comma decimals and reduces ratio', () {
      final dot = DecimalRatio.parse('0.00907');
      final comma = DecimalRatio.parse('0,00907');

      expect(dot, isNotNull);
      expect(dot!.numerator, BigInt.from(907));
      expect(dot.denominator, BigInt.from(100000));

      expect(comma, isNotNull);
      expect(comma!.numerator, BigInt.from(907));
      expect(comma.denominator, BigInt.from(100000));
    });

    test('rejects invalid or non-positive values when required', () {
      expect(DecimalRatio.parse(''), isNull);
      expect(DecimalRatio.parse('abc'), isNull);
      expect(DecimalRatio.parse('-0.5'), isNull);
      expect(DecimalRatio.parse('0'), isNull);
    });
  });

  group('CurrencyConversionEngine.convertMinor', () {
    final engine = CurrencyConversionEngine();
    final rates = CurrencyFxRates(
      cveToEur: DecimalRatio.parse('0.00907')!,
      cveToUsd: DecimalRatio.parse('0.0101')!,
    );

    test('converts EUR to CVE and USD using fixed-point math', () {
      final eurToCve = engine.convertMinor(
        amountMinor: 100,
        fromCurrency: CurrencyCode.eur,
        toCurrency: CurrencyCode.cve,
        rates: rates,
      );
      final eurToUsd = engine.convertMinor(
        amountMinor: 100,
        fromCurrency: CurrencyCode.eur,
        toCurrency: CurrencyCode.usd,
        rates: rates,
      );

      expect(eurToCve, 11025);
      expect(eurToUsd, 111);
    });

    test('converts USD to EUR using inverse ratio', () {
      final usdToEur = engine.convertMinor(
        amountMinor: 10000,
        fromCurrency: CurrencyCode.usd,
        toCurrency: CurrencyCode.eur,
        rates: rates,
      );

      expect(usdToEur, 8980);
    });

    test('keeps amount unchanged when currency is the same', () {
      final unchanged = engine.convertMinor(
        amountMinor: 12345,
        fromCurrency: CurrencyCode.cve,
        toCurrency: CurrencyCode.cve,
        rates: rates,
      );

      expect(unchanged, 12345);
    });

    test('applies half-up rounding for positive and negative values', () {
      final customRates = CurrencyFxRates(
        cveToEur: DecimalRatio.parse('0.5')!,
        cveToUsd: DecimalRatio.parse('1')!,
      );

      final positiveHalf = engine.convertMinor(
        amountMinor: 1,
        fromCurrency: CurrencyCode.usd,
        toCurrency: CurrencyCode.eur,
        rates: customRates,
      );
      final negativeHalf = engine.convertMinor(
        amountMinor: -1,
        fromCurrency: CurrencyCode.usd,
        toCurrency: CurrencyCode.eur,
        rates: customRates,
      );

      expect(positiveHalf, 1);
      expect(negativeHalf, -1);
    });
  });
}
