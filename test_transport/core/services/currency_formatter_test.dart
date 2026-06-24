import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/decimal_ratio.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/core/services/currency_conversion_engine.dart';
import 'package:local_transport/core/services/currency_formatter.dart';

void main() {
  setUp(() {
    CurrencyFormatter.setDisplayCurrency(CurrencyCode.eur);
    CurrencyFormatter.setFxRuntime(
      rates: null,
      fallbackReason: null,
      updatedAt: null,
      version: null,
    );
  });

  test('falls back to EUR formatting when CVE is selected without FX', () {
    CurrencyFormatter.setDisplayCurrency(CurrencyCode.cve);
    CurrencyFormatter.setFxRuntime(
      rates: null,
      fallbackReason: 'missing_config',
      updatedAt: null,
      version: null,
    );

    final formatted = euroCurrencyFormatter.formatMinor(
      1234,
      locale: 'pt_PT',
      sourceCurrency: CurrencyCode.eur,
    );

    expect(formatted.contains('€'), isTrue);
    expect(formatted.contains('CVE'), isFalse);
  });

  test('formats using selected CVE when FX config is available', () {
    CurrencyFormatter.setDisplayCurrency(CurrencyCode.cve);
    CurrencyFormatter.setFxRuntime(
      rates: CurrencyFxRates(
        cveToEur: DecimalRatio.parse('0.00907')!,
        cveToUsd: DecimalRatio.parse('0.0101')!,
      ),
      fallbackReason: null,
      updatedAt: DateTime(2026, 1, 1),
      version: 1,
    );

    final formatted = euroCurrencyFormatter.formatMinor(
      100,
      locale: 'pt_PT',
      sourceCurrency: CurrencyCode.eur,
    );

    expect(formatted.contains('CVE'), isTrue);
  });
}
