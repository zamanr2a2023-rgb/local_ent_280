import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:local_transport/features/trip_packages/application/providers/trip_package_domain_providers.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package.dart';
import 'package:local_transport/features/trip_packages/presentation/screens/client_trip_package_detail_screen.dart';
import 'package:local_transport/l10n/app_localizations.dart';

import '../../../../test_support/fakes/fake_trip_package_repository.dart';
import '../../../../test_support/fixtures/test_trip_package_factory.dart';
import '../../../../test_support/http/fake_image_http_client.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  testWidgets('shows the commercial purchase form and transport guidance', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final package = buildTestTripPackage();
    final repository = FakeTripPackageRepository(
      packagesById: <String, TripPackage?>{package.id: package},
    );

    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            tripPackageRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            locale: const Locale('pt', 'PT'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ClientTripPackageDetailScreen(packageId: package.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Comprar package', skipOffstage: false), findsOneWidget);
      expect(find.text('Recolha', skipOffstage: false), findsOneWidget);
      expect(find.text('Data', skipOffstage: false), findsOneWidget);
      expect(find.text('Hora', skipOffstage: false), findsOneWidget);
      expect(find.text('Transporte', skipOffstage: false), findsOneWidget);
      expect(
        find.textContaining(
          'A escolha do transporte é sua e deve ser adequada ao grupo',
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      expect(
        find.text('Sem lugares mínimos', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('Standard', skipOffstage: false), findsWidgets);
      expect(find.text('Van', skipOffstage: false), findsWidgets);
      expect(find.text('Reservar 1 lugar'), findsNothing);
      expect(find.textContaining('lugares restantes'), findsNothing);
    }, createHttpClient: (_) => FakeImageHttpClient());
  });

  testWidgets('requires pickup before confirming the purchase', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final package = buildTestTripPackage();
    final repository = FakeTripPackageRepository(
      packagesById: <String, TripPackage?>{package.id: package},
    );

    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            tripPackageRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            locale: const Locale('pt', 'PT'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ClientTripPackageDetailScreen(packageId: package.id),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Confirmar compra'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Confirmar compra'));
      await tester.pump();

      expect(find.text('Selecione a recolha.'), findsOneWidget);
      expect(repository.confirmRequests, isEmpty);
    }, createHttpClient: (_) => FakeImageHttpClient());
  });
}
