import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/trip_packages/application/providers/trip_package_domain_providers.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_delete_result.dart';
import 'package:local_transport/features/trip_packages/presentation/screens/trip_package_management_screen.dart';
import 'package:local_transport/features/trip_packages/presentation/widgets/trip_package_management_card.dart';
import 'package:local_transport/l10n/app_localizations.dart';

import '../../../../test_support/fakes/fake_trip_package_repository.dart';
import '../../../../test_support/fixtures/test_trip_package_factory.dart';
import '../../../../test_support/http/fake_image_http_client.dart';

void main() {
  testWidgets('shows commercial management copy and package actions menu', (
    tester,
  ) async {
    final package = buildTestTripPackage();
    final repository = FakeTripPackageRepository(
      managementPackages: <TripPackage>[package],
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
            home: const TripPackageManagementScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.textContaining(
          'Gerir produtos comerciais com destino fixo, preço fixo',
        ),
        findsOneWidget,
      );
      expect(find.text('Editar pacote'), findsOneWidget);
      expect(
        find.byType(PopupMenuButton<TripPackageManagementAction>),
        findsOneWidget,
      );

      await tester.tap(
        find.byType(PopupMenuButton<TripPackageManagementAction>),
      );
      await tester.pumpAndSettle();

      expect(find.text('Desativar vendas'), findsOneWidget);
      expect(find.text('Arquivar'), findsOneWidget);
      expect(find.text('Eliminar'), findsOneWidget);
      expect(find.textContaining('tipos de transporte'), findsWidgets);
      expect(find.textContaining('saídas'), findsNothing);
    }, createHttpClient: (_) => FakeImageHttpClient());
  });

  testWidgets(
    'deletes a package while keeping the new block-sales-only copy',
    (tester) async {
      final package = buildTestTripPackage();
      final repository = FakeTripPackageRepository(
        managementPackages: <TripPackage>[package],
        deletePackageResult: const TripPackageDeleteResult.empty(),
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
              home: const TripPackageManagementScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(
          find.byType(PopupMenuButton<TripPackageManagementAction>),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('bloqueia novas vendas'),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            'Marcações futuras já aprovadas continuam válidas',
          ),
          findsOneWidget,
        );
        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('OK'), findsOneWidget);

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(repository.deletedPackageIds, <String>[package.id]);
        expect(find.text('Pacote eliminado com sucesso.'), findsOneWidget);
      }, createHttpClient: (_) => FakeImageHttpClient());
    },
  );
}
