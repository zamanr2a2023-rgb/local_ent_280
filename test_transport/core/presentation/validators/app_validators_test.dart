import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/core/presentation/validators/app_validators.dart';

void main() {
  group('AppValidators', () {
    test('requiredTrimmed rejeita vazio e espaços', () {
      final validator = AppValidators.requiredTrimmed(message: 'required');
      expect(validator(null), 'required');
      expect(validator('   '), 'required');
      expect(validator('ok'), isNull);
    });

    test('email valida formato básico', () {
      final validator = AppValidators.email(
        requiredMessage: 'required',
        invalidMessage: 'invalid',
      );
      expect(validator(''), 'required');
      expect(validator('foo'), 'invalid');
      expect(validator('foo@bar.com'), isNull);
    });

    test('parseDecimal aceita vírgula e ponto', () {
      final dot = AppValidators.parseDecimal('10.5', requirePositive: true);
      final comma = AppValidators.parseDecimal('10,5', requirePositive: true);

      expect(dot, isNotNull);
      expect(comma, isNotNull);
      expect(
        dot!.numerator * comma!.denominator,
        comma.numerator * dot.denominator,
      );
    });

    test('parseDouble aceita vírgula e ponto', () {
      expect(AppValidators.parseDouble('10.5', requirePositive: true), 10.5);
      expect(AppValidators.parseDouble('10,5', requirePositive: true), 10.5);
      expect(AppValidators.parseDouble('0', requirePositive: true), isNull);
    });

    test('parseMoneyToMinor usa arredondamento half-up sem double', () {
      expect(
        AppValidators.parseMoneyToMinor(
          raw: '10,50',
          currency: CurrencyCode.eur,
        ),
        1050,
      );
      expect(
        AppValidators.parseMoneyToMinor(
          raw: '10.505',
          currency: CurrencyCode.eur,
        ),
        1051,
      );
    });

    test('parseMoneyToMinor aceita texto formatado com simbolo euro', () {
      expect(
        AppValidators.parseMoneyToMinor(
          raw: '€1.00',
          currency: CurrencyCode.eur,
        ),
        100,
      );
      expect(
        AppValidators.parseMoneyToMinor(
          raw: '1,00 €',
          currency: CurrencyCode.eur,
        ),
        100,
      );
      expect(
        AppValidators.parseMoneyToMinor(
          raw: 'EUR 12,50',
          currency: CurrencyCode.eur,
        ),
        1250,
      );
    });

    test('intRange valida limites e formato', () {
      final validator = AppValidators.intRange(
        min: 1,
        max: 3,
        requiredMessage: 'required',
        invalidMessage: 'invalid',
        outOfRangeMessage: 'range',
      );
      expect(validator(''), 'required');
      expect(validator('1.2'), 'invalid');
      expect(validator('0'), 'range');
      expect(validator('2'), isNull);
    });

    test('phoneBasic valida comprimento de dígitos', () {
      final validator = AppValidators.phoneBasic(
        requiredMessage: 'required',
        invalidMessage: 'invalid',
      );
      expect(validator(''), 'required');
      expect(validator('abc'), 'invalid');
      expect(validator('+351 912 345 678'), isNull);
    });

    test('plateBasic valida padrão simples', () {
      final validator = AppValidators.plateBasic(
        requiredMessage: 'required',
        invalidMessage: 'invalid',
      );
      expect(validator(''), 'required');
      expect(validator('@@@'), 'invalid');
      expect(validator('AA-12-BB'), isNull);
    });
  });
}
