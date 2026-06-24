import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/client/presentation/widgets/trip_request_failure_dialog.dart';
import 'package:local_transport/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'shows failure reason and support call action when phone exists',
    (
      tester,
    ) async {
      var callSupportCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('pt', 'PT'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (_) => TripRequestFailureDialog(
                        reason: 'Não foi possível criar o pedido.',
                        supportPhone: '+351 210 000 000',
                        onCallSupport: () => callSupportCount++,
                      ),
                    );
                  },
                  child: const Text('open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível pedir a viagem'), findsOneWidget);
      expect(
        find.textContaining('Não foi possível criar o pedido.'),
        findsOneWidget,
      );
      expect(find.textContaining('+351 210 000 000'), findsOneWidget);
      expect(find.text('Ligar para suporte'), findsOneWidget);

      await tester.tap(find.text('Ligar para suporte'));

      expect(callSupportCount, 1);
    },
  );

  testWidgets('hides support call action when phone is missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt', 'PT'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: TripRequestFailureDialog(
            reason: 'Sem ligação à internet.',
            supportPhone: '',
            onCallSupport: _noop,
          ),
        ),
      ),
    );

    expect(find.textContaining('Sem ligação à internet.'), findsOneWidget);
    expect(find.text('Ligar para suporte'), findsNothing);
    expect(find.text('Fechar'), findsOneWidget);
  });
}

void _noop() {}
