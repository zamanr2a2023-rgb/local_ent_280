import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/trip_packages/application/providers/trip_package_domain_providers.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_booking.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_cancellation.dart';
import 'package:local_transport/features/trip_packages/presentation/screens/client_trip_package_booking_detail_screen.dart';
import 'package:local_transport/l10n/app_localizations.dart';

import '../../../../test_support/fakes/fake_trip_package_repository.dart';
import '../../../../test_support/fixtures/test_trip_package_factory.dart';
import '../../../../test_support/http/fake_image_http_client.dart';

void main() {
  group('ClientTripPackageBookingDetailScreen', () {
    testWidgets(
      'shows separated commercial and operational states with cancel action',
      (tester) async {
        tester.view.physicalSize = const Size(1170, 2532);
        tester.view.devicePixelRatio = 3;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final now = DateTime.now().toUtc();
        final booking = buildTestTripPackageBooking(
          status: TripPackageBookingStatus.pendingApproval,
          scheduledAt: now.add(const Duration(hours: 4)),
          clientCancellationClosesAt: now.add(const Duration(hours: 3)),
        );
        final repository = FakeTripPackageRepository(
          bookingsById: <String, TripPackageBooking?>{booking.id: booking},
        );

        await HttpOverrides.runZoned(() async {
          await tester.pumpWidget(
            ProviderScope(
              overrides: <Override>[
                tripPackageRepositoryProvider.overrideWithValue(repository),
              ],
              child: MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: ClientTripPackageBookingDetailScreen(
                  bookingId: booking.id,
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(
            find.text('Estado comercial', skipOffstage: false),
            findsOneWidget,
          );
          expect(
            find.text('Estado operacional', skipOffstage: false),
            findsWidgets,
          );
          expect(
            find.text('Estado do booking', skipOffstage: false),
            findsOneWidget,
          );
          await tester.scrollUntilVisible(
            find.text('Reserva'),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          expect(find.text('Reserva', skipOffstage: false), findsOneWidget);
          expect(find.text('Viagem', skipOffstage: false), findsOneWidget);
          expect(
            find.text('Decisão da equipa', skipOffstage: false),
            findsOneWidget,
          );
          expect(find.text('Pendente', skipOffstage: false), findsOneWidget);
          await tester.scrollUntilVisible(
            find.text('Cancelar compra'),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          expect(find.text('Cancelar compra'), findsOneWidget);
          expect(
            find.text('Ainda não criado', skipOffstage: false),
            findsOneWidget,
          );
          expect(
            find.text(
              'Sem ação operacional até existir decisão da equipa.',
              skipOffstage: false,
            ),
            findsOneWidget,
          );
          expect(find.text('Praia', skipOffstage: false), findsOneWidget);
          expect(find.text('Tarrafal', skipOffstage: false), findsWidgets);
          expect(find.text('Standard', skipOffstage: false), findsOneWidget);
        }, createHttpClient: (_) => FakeImageHttpClient());
      },
    );

    testWidgets('hides self-cancel when the booking is already cancelled', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final booking = buildTestTripPackageBooking(
        status: TripPackageBookingStatus.cancelled,
        refundStatus: TripPackageRefundStatus.full,
        cancellation: TripPackageCancellation(
          reasonCode: TripPackageCancellationReasonCode.adminCancelled,
          reasonLabel: 'Cancelado pela operação.',
          cancelledAt: DateTime.now().toUtc(),
          cancelledBy: 'admin-1',
        ),
        clientCancellationClosesAt: DateTime.now().toUtc().subtract(
          const Duration(hours: 1),
        ),
      );
      final repository = FakeTripPackageRepository(
        bookingsById: <String, TripPackageBooking?>{booking.id: booking},
      );

      await HttpOverrides.runZoned(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: <Override>[
              tripPackageRepositoryProvider.overrideWithValue(repository),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: ClientTripPackageBookingDetailScreen(bookingId: booking.id),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.textContaining('já não pode ser cancelado'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Cancelar compra', skipOffstage: false), findsNothing);
        expect(
          find.textContaining('já não pode ser cancelado'),
          findsOneWidget,
        );
        expect(
          find.text('Motivo do cancelamento', skipOffstage: false),
          findsOneWidget,
        );
        expect(
          find.text('Cancelado pela operação.', skipOffstage: false),
          findsOneWidget,
        );
        expect(
          find.text('Operação cancelada', skipOffstage: false),
          findsNothing,
        );
        expect(
          find.text('Operação cancelada.', skipOffstage: false),
          findsOneWidget,
        );
      }, createHttpClient: (_) => FakeImageHttpClient());
    });
  });
}
