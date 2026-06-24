import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:local_transport/app/config/app_config.dart';
import 'package:local_transport/app/presentation/navigation/app_routes.dart';
import 'package:local_transport/core/data/firebase/providers/realtime_db_service_provider.dart';
import 'package:local_transport/features/auth/application/providers/auth_domain_providers.dart';
import 'package:local_transport/features/auth/presentation/screens/login_screen.dart';
import 'package:local_transport/features/auth/presentation/screens/welcome_screen.dart';
import 'package:local_transport/features/client/presentation/screens/client_trips_screen.dart';

import '../../test/test_support/harness/app_flow_test_harness.dart';

const _seededClientEmail = 'cliente.e2e@localtransport.test';
const _seededClientPassword = 'ClienteE2E123!';
const _seededDriverId = 'driver-e2e-1';
const _seededTripRouteLabel = 'Aeroporto Humberto Delgado → Marquês de Pombal';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'routes through real emulator auth and renders seeded client trip data',
    (tester) async {
      final harness = AppFlowTestHarness();
      addTearDown(harness.dispose);

      final container = await harness.pumpApp(
        tester,
        initialRoute: AppRoutes.roleRouter,
        appConfig: AppConfig.emulatorTest(),
      );
      addTearDown(container.dispose);

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();
      await _pumpUntilFound(tester, find.byType(LoginScreen));

      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(2));

      await tester.enterText(fields.at(0), _seededClientEmail);
      await tester.enterText(fields.at(1), _seededClientPassword);
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      await _pumpUntil(
        tester,
        condition: () {
          final userId = container.read(getCurrentUserIdProvider)();
          return userId != null && userId.isNotEmpty;
        },
        description: 'utilizador autenticado',
      );
      await _pumpUntilFound(tester, find.text('Minhas viagens'));

      final userId = container.read(getCurrentUserIdProvider)();
      expect(userId, isNotNull);
      expect(userId, isNotEmpty);

      final realtimeDbService = container.read(realtimeDbServiceProvider);
      final driverPresence = await realtimeDbService.fetchValue(
        '/driverPresence/$_seededDriverId',
      );
      expect(driverPresence, isNotNull);
      expect(driverPresence?['state'], 'online');
      expect(driverPresence?['operationalAvailability'], isTrue);

      await tester.ensureVisible(find.text('Minhas viagens'));
      await tester.tap(find.text('Minhas viagens'));
      await tester.pump();

      await _pumpUntilFound(tester, find.byType(ClientTripsScreen));

      expect(find.text('Viagens'), findsOneWidget);
      expect(find.text('Próximas'), findsWidgets);
      expect(find.text(_seededTripRouteLabel), findsOneWidget);
    },
  );
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 400),
  int maxAttempts = 25,
}) async {
  await _pumpUntil(
    tester,
    condition: () => finder.evaluate().isNotEmpty,
    description: finder.toString(),
    step: step,
    maxAttempts: maxAttempts,
  );
}

Future<void> _pumpUntil(
  WidgetTester tester, {
  required bool Function() condition,
  required String description,
  Duration step = const Duration(milliseconds: 400),
  int maxAttempts = 25,
}) async {
  for (var attempt = 0; attempt < maxAttempts; attempt += 1) {
    await tester.pump(step);
    if (condition()) {
      return;
    }
  }
  _dumpVisibleTexts();
  debugDumpApp();
  fail('Elemento não encontrado após $maxAttempts tentativas: $description');
}

void _dumpVisibleTexts() {
  final visibleTexts =
      find
          .byType(Text)
          .evaluate()
          .map((element) {
            final widget = element.widget as Text;
            final data = widget.data?.trim();
            if (data != null && data.isNotEmpty) {
              return data;
            }
            final span = widget.textSpan;
            if (span is TextSpan) {
              final plainText = span.toPlainText().trim();
              if (plainText.isNotEmpty) {
                return plainText;
              }
            }
            return null;
          })
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();

  debugPrint(
    'EmulatorClientFlowTest: textos visíveis -> ${visibleTexts.join(' | ')}',
  );
}
