import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/client/application/providers/client_domain_providers.dart';
import 'package:local_transport/features/client/domain/entities/transport_type.dart';
import 'package:local_transport/features/client/domain/repositories/transport_type_repository.dart';
import 'package:local_transport/features/client/domain/usecases/get_transport_types.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_draft.dart';
import 'package:local_transport/features/trip_packages/presentation/widgets/trip_package_form_sheet.dart';
import 'package:local_transport/l10n/app_localizations.dart';

import '../../../../test_support/fixtures/test_trip_package_factory.dart';
import '../../../../test_support/http/fake_image_http_client.dart';

void main() {
  testWidgets('submits the simplified commercial draft', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    TripPackageDraft? submittedDraft;

    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            getTransportTypesProvider.overrideWithValue(
              GetTransportTypes(_FakeTransportTypeRepository()),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('pt', 'PT'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: TripPackageFormSheet(
                actorId: 'manager-1',
                package: buildTestTripPackage(),
                isSubmitting: false,
                onSubmit: (draft) async {
                  submittedDraft = draft;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Destino fixo', skipOffstage: false), findsOneWidget);
      expect(find.text('Preço fixo', skipOffstage: false), findsOneWidget);
      expect(
        find.text('Tipos de transporte permitidos', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('Experiencia'), findsNothing);
      expect(find.text('Atividades'), findsNothing);
      expect(find.text('Inclui'), findsNothing);
      expect(find.text('Não inclui'), findsNothing);

      await tester.enterText(find.byType(TextFormField).at(0), 'Novo package');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Descrição comercial atualizada para o package.',
      );
      await tester.enterText(find.byType(TextFormField).at(2), '32,50');
      await tester.ensureVisible(find.text('Guardar'));
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(submittedDraft, isNotNull);
      expect(submittedDraft!.name, 'Novo package');
      expect(
        submittedDraft!.description,
        'Descrição comercial atualizada para o package.',
      );
      expect(submittedDraft!.destination.address, 'Tarrafal');
      expect(submittedDraft!.price.amountMinor, 3250);
      expect(submittedDraft!.allowedTransportTypes, hasLength(2));
    }, createHttpClient: (_) => FakeImageHttpClient());
  });

  testWidgets('requires at least one allowed transport type', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            getTransportTypesProvider.overrideWithValue(
              GetTransportTypes(_FakeTransportTypeRepository()),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('pt', 'PT'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: TripPackageFormSheet(
                actorId: 'manager-1',
                package: buildTestTripPackage(),
                isSubmitting: false,
                onSubmit: (_) async {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Standard'));
      await tester.tap(find.text('Standard'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Van'));
      await tester.tap(find.text('Van'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Guardar'));
      await tester.tap(find.text('Guardar'));
      await tester.pump();

      expect(
        find.text('Selecione pelo menos um tipo de transporte.'),
        findsOneWidget,
      );
    }, createHttpClient: (_) => FakeImageHttpClient());
  });

  testWidgets('shows delete action while editing and delegates deletion', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var deleteWasRequested = false;

    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            getTransportTypesProvider.overrideWithValue(
              GetTransportTypes(_FakeTransportTypeRepository()),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('pt', 'PT'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: TripPackageFormSheet(
                actorId: 'manager-1',
                package: buildTestTripPackage(),
                isSubmitting: false,
                onSubmit: (_) async {},
                onDelete: () async {
                  deleteWasRequested = true;
                  return true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Eliminar'), findsOneWidget);
      await tester.ensureVisible(find.text('Eliminar'));
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      expect(deleteWasRequested, isTrue);
    }, createHttpClient: (_) => FakeImageHttpClient());
  });
}

class _FakeTransportTypeRepository implements TransportTypeRepository {
  @override
  Future<List<TransportType>> fetchTransportTypes() async {
    return const <TransportType>[
      TransportType(
        id: 'standard',
        name: 'Standard',
        description: 'Veículo standard',
        packagePriceMultiplierBasisPoints: 10000,
      ),
      TransportType(
        id: 'van',
        name: 'Van',
        description: 'Carrinha para grupo',
        packagePriceMultiplierBasisPoints: 12500,
      ),
    ];
  }

  @override
  Future<TransportType> getDefaultTransportType() async {
    return const TransportType(
      id: 'standard',
      name: 'Standard',
      description: 'Veículo standard',
      packagePriceMultiplierBasisPoints: 10000,
    );
  }
}
