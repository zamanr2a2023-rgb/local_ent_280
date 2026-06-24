import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/trip_packages/application/providers/trip_package_domain_providers.dart';
import 'package:local_transport/features/trip_packages/domain/entities/trip_package_booking.dart';
import 'package:local_transport/features/trip_packages/presentation/screens/trip_package_ops_queue_screen.dart';
import 'package:local_transport/l10n/app_localizations.dart';

import '../../../../test_support/fakes/fake_trip_package_repository.dart';
import '../../../../test_support/fixtures/test_trip_package_factory.dart';
import '../../../../test_support/http/fake_image_http_client.dart';

void main() {
  testWidgets('shows pending approvals and approves a booking from the queue', (
    tester,
  ) async {
    final booking = buildTestTripPackageBooking(
      status: TripPackageBookingStatus.pendingApproval,
    );
    final repository = FakeTripPackageRepository(
      opsQueueBookings: <TripPackageBooking>[booking],
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
            home: const TripPackageOpsQueueScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Fila operacional'), findsOneWidget);
      expect(find.text('Pendentes de aprovação'), findsOneWidget);
      expect(find.text('Aprovar'), findsOneWidget);
      expect(find.text('Rejeitar'), findsOneWidget);

      await tester.tap(find.text('Aprovar'));
      await tester.pumpAndSettle();

      expect(repository.approvedBookingIds, <String>[booking.id]);
      expect(find.text('Booking aprovado com sucesso.'), findsOneWidget);
    }, createHttpClient: (_) => FakeImageHttpClient());
  });
}
