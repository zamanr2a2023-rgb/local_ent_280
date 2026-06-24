import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/core/services/currency_formatter.dart';
import 'package:local_transport/features/client/presentation/widgets/post_charge_extension_custom_duration_dialog.dart';
import 'package:local_transport/features/client/presentation/widgets/post_charge_extension_duration_selector.dart';
import 'package:local_transport/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'duration selector shows 15, 30, 45 and 1 h with estimates',
    (tester) async {
      await _pumpLocalizedWidget(
        tester,
        Scaffold(
          body: PostChargeExtensionDurationSelector(
            isSubmitting: false,
            locale: 'pt_PT',
            moneyFormatter: euroCurrencyFormatter,
            estimateForMinutes: _estimateForMinutes,
            onSelectMinutes: (_) {},
            onCustomDuration: () {},
          ),
        ),
      );

      expect(find.text('15 min'), findsOneWidget);
      expect(find.text('30 min'), findsOneWidget);
      expect(find.text('45 min'), findsOneWidget);
      expect(find.text('1 h'), findsOneWidget);
      expect(find.text('5 min'), findsNothing);
      expect(find.text('10 min'), findsNothing);
      expect(
        find.text('A cobrança final depende do tempo efetivamente utilizado.'),
        findsOneWidget,
      );
      expect(
        find.text(
          euroCurrencyFormatter.formatMoney(
            _estimateForMinutes(15),
            locale: 'pt_PT',
            currency: CurrencyCode.eur,
          ),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'custom duration dialog validates 15..60 and updates estimate',
    (tester) async {
      await _pumpLocalizedWidget(
        tester,
        Scaffold(
          body: PostChargeExtensionCustomDurationDialog(
            locale: 'pt_PT',
            moneyFormatter: euroCurrencyFormatter,
            estimateForMinutes: _estimateForMinutes,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '10');
      await tester.pump();

      expect(
        find.text('Indica um valor entre 15 e 60 minutos.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextFormField), '30');
      await tester.pump();

      expect(
        find.textContaining('Estimativa para 30 min:'),
        findsOneWidget,
      );
      expect(
        find.text('A cobrança final depende do tempo efetivamente utilizado.'),
        findsOneWidget,
      );
    },
  );
}

Money _estimateForMinutes(int minutes) {
  return Money(
    amountMinor: minutes * 120,
    currency: CurrencyCode.eur,
  );
}

Future<void> _pumpLocalizedWidget(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      locale: const Locale('pt', 'PT'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}
