import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:local_transport/app/presentation/navigation/app_routes.dart';
import 'package:local_transport/app/presentation/screens/no_permission_screen.dart';
import 'package:local_transport/core/domain/entities/sort_order.dart';
import 'package:local_transport/features/admin/domain/entities/admin_status.dart';
import 'package:local_transport/features/admin/presentation/providers/admin_status_provider.dart';
import 'package:local_transport/features/admin/presentation/screens/admin_home_shell.dart';
import 'package:local_transport/features/admin/presentation/screens/admin_reports_screen.dart';
import 'package:local_transport/features/auth/domain/entities/auth_status.dart';
import 'package:local_transport/features/auth/domain/entities/manager_permission.dart';
import 'package:local_transport/features/auth/domain/entities/manager_permissions_snapshot.dart';
import 'package:local_transport/features/auth/domain/entities/profile_role.dart';
import 'package:local_transport/features/auth/presentation/providers/manager_permissions_controller.dart';
import 'package:local_transport/features/auth/presentation/screens/welcome_screen.dart';
import 'package:local_transport/features/client/presentation/providers/client_trips_overview_provider.dart';
import 'package:local_transport/features/client/presentation/screens/client_trips_screen.dart';
import 'package:local_transport/features/driver/presentation/providers/driver_trips_overview_provider.dart';
import 'package:local_transport/features/driver/presentation/screens/driver_trips_screen.dart';
import 'package:local_transport/features/manager/presentation/screens/manager_home_shell.dart';
import 'package:local_transport/features/notifications/domain/entities/notification_event.dart';
import 'package:local_transport/features/notifications/domain/entities/notification_event_type.dart';
import 'package:local_transport/features/reports/data/providers/client_statement_repository_provider.dart';
import 'package:local_transport/features/reports/data/providers/trip_explorer_repository_provider.dart';
import 'package:local_transport/features/trips/domain/entities/client_trip_overview.dart';
import 'package:local_transport/features/trips/domain/entities/client_trip_status.dart';
import 'package:local_transport/features/trips/domain/entities/driver_trip_filter.dart';
import 'package:local_transport/features/trips/domain/entities/trip.dart';
import 'package:local_transport/features/trips/domain/entities/trip_date_range.dart';

import '../../test/test_support/fakes/fake_auth_repository.dart';
import '../../test/test_support/fakes/fake_manager_permissions_controller.dart';
import '../../test/test_support/fakes/fake_reports_repositories.dart';
import '../../test/test_support/fakes/fake_trip_overview_controllers.dart';
import '../../test/test_support/fixtures/test_report_factory.dart';
import '../../test/test_support/fixtures/test_trip_factory.dart';
import '../../test/test_support/harness/app_flow_test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('mocked auth and shell flows', () {
    testWidgets('role router sends unauthenticated users to welcome', (
      tester,
    ) async {
      final harness = AppFlowTestHarness(
        authRepository: FakeAuthRepository.unauthenticated(),
      );
      addTearDown(harness.dispose);

      final container = await harness.pumpApp(
        tester,
        initialRoute: AppRoutes.roleRouter,
      );
      addTearDown(container.dispose);

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('auth redirector sends signed-out users back to welcome', (
      tester,
    ) async {
      final authRepository = FakeAuthRepository.authenticated(
        userId: 'client-redirect',
        role: ProfileRole.client,
        email: 'client.redirect@example.com',
      );
      final harness = AppFlowTestHarness(authRepository: authRepository);
      addTearDown(harness.dispose);

      final tripDate = DateTime(2026, 3, 10, 9, 30);
      final trip = buildTestTrip(
        id: 'trip-client-1',
        pickupAddress: 'Rua do Ouro',
        destinationAddress: 'Rossio',
        requestedAt: tripDate,
      );

      final container = await harness.pumpApp(
        tester,
        initialRoute: AppRoutes.clientTrips,
        overrides: <Override>[
          clientTripsOverviewProvider.overrideWith(
            (ref) => FakeClientTripsOverviewController(
              ClientTripsOverviewState(
                isLoading: false,
                isLoadingMore: false,
                hasMore: false,
                sections: <ClientTripSection>[
                  ClientTripSection(
                    status: ClientTripStatus.upcoming,
                    trips: <ClientTripListItem>[
                      ClientTripListItem(
                        trip: trip,
                        status: ClientTripStatus.upcoming,
                        date: tripDate,
                        finalCostMinor: 1200,
                      ),
                    ],
                  ),
                ],
                statusFilter: null,
                dateRange: null,
                sortOrder: SortOrder.descending,
                searchQuery: '',
                failure: null,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(find.byType(ClientTripsScreen), findsOneWidget);
      expect(find.textContaining('Rua do Ouro'), findsOneWidget);

      authRepository.setSession(
        status: const AuthStatus(
          isAvailable: false,
          role: ProfileRole.client,
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text('Bem-vindo.'), findsOneWidget);
    });

    testWidgets('offline banner is visible when connectivity is lost', (
      tester,
    ) async {
      final harness = AppFlowTestHarness(
        authRepository: FakeAuthRepository.unauthenticated(),
      );
      harness.connectivityService.setOnline(false);
      addTearDown(harness.dispose);

      final container = await harness.pumpApp(
        tester,
        initialRoute: AppRoutes.welcome,
      );
      addTearDown(container.dispose);

      expect(find.text('Sem ligação à internet.'), findsOneWidget);
    });

    testWidgets(
      'notification listener shows in-app banner from repository event',
      (tester) async {
        final harness = AppFlowTestHarness(
          authRepository: FakeAuthRepository.unauthenticated(),
        );
        addTearDown(harness.dispose);

        final container = await harness.pumpApp(
          tester,
          initialRoute: AppRoutes.welcome,
        );
        addTearDown(container.dispose);

        harness.notificationEventRepository.emit(
          const NotificationEvent(
            type: NotificationEventType.clientDriverAssigned,
            data: <String, String>{'tripId': 'trip-banner-1'},
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Motorista atribuído'), findsOneWidget);
      },
    );
  });

  group('mocked role navigation flows', () {
    testWidgets('client sees trip history from the app shell', (tester) async {
      final harness = AppFlowTestHarness(
        authRepository: FakeAuthRepository.authenticated(
          userId: 'client-shell',
          role: ProfileRole.client,
          email: 'client.shell@example.com',
        ),
      );
      addTearDown(harness.dispose);
      final tripDate = DateTime(2026, 3, 11, 14, 00);
      final trip = buildTestTrip(
        id: 'trip-client-2',
        pickupAddress: 'Avenida da Liberdade',
        destinationAddress: 'Santa Apolónia',
        requestedAt: tripDate,
      );

      final container = await harness.pumpApp(
        tester,
        initialRoute: AppRoutes.clientTrips,
        overrides: <Override>[
          clientTripsOverviewProvider.overrideWith(
            (ref) => FakeClientTripsOverviewController(
              ClientTripsOverviewState(
                isLoading: false,
                isLoadingMore: false,
                hasMore: false,
                sections: <ClientTripSection>[
                  ClientTripSection(
                    status: ClientTripStatus.upcoming,
                    trips: <ClientTripListItem>[
                      ClientTripListItem(
                        trip: trip,
                        status: ClientTripStatus.upcoming,
                        date: tripDate,
                        finalCostMinor: 1450,
                      ),
                    ],
                  ),
                ],
                statusFilter: null,
                dateRange: null,
                sortOrder: SortOrder.descending,
                searchQuery: '',
                failure: null,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(find.byType(ClientTripsScreen), findsOneWidget);
      expect(find.textContaining('Avenida da Liberdade'), findsOneWidget);
      expect(find.textContaining('Santa Apolónia'), findsOneWidget);
    });

    testWidgets('driver sees assigned trips from the app shell', (
      tester,
    ) async {
      final harness = AppFlowTestHarness(
        authRepository: FakeAuthRepository.authenticated(
          userId: 'driver-shell',
          role: ProfileRole.driver,
          email: 'driver.shell@example.com',
        ),
      );
      addTearDown(harness.dispose);
      final tripDate = DateTime(2026, 3, 12, 8, 15);
      final trip = buildTestTrip(
        id: 'trip-driver-1',
        pickupAddress: 'Campo Grande',
        destinationAddress: 'Entrecampos',
        requestedAt: tripDate,
      );

      final container = await harness.pumpApp(
        tester,
        initialRoute: AppRoutes.driverTrips,
        overrides: <Override>[
          driverTripsOverviewProvider.overrideWith(
            (ref) => FakeDriverTripsOverviewController(
              DriverTripsOverviewState(
                isLoading: false,
                isLoadingMore: false,
                hasMore: false,
                trips: <Trip>[trip],
                dateRange: TripDateRange(
                  start: DateTime(2026, 3, 12),
                  end: DateTime(2026, 3, 12, 23, 59, 59),
                ),
                status: DriverTripStatusFilter.all,
                sortOrder: SortOrder.descending,
                searchQuery: '',
                errorMessage: null,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(find.byType(DriverTripsScreen), findsOneWidget);
      expect(find.textContaining('Campo Grande'), findsOneWidget);
      expect(find.textContaining('Entrecampos'), findsOneWidget);
    });

    testWidgets('manager without reports permission sees denied state', (
      tester,
    ) async {
      final harness = AppFlowTestHarness(
        authRepository: FakeAuthRepository.authenticated(
          userId: 'manager-denied',
          role: ProfileRole.manager,
          email: 'manager.denied@example.com',
        ),
        managerPermissionsController: FakeManagerPermissionsController(
          initialState: ManagerPermissionsState(
            snapshot: ManagerPermissionsSnapshot(
              isConfigured: true,
              grants: <ManagerPermission, bool>{
                for (final permission in ManagerPermission.values)
                  permission: false,
              },
            ),
            isLoading: false,
            revision: 1,
            lastRefreshAt: DateTime(2026, 3, 12, 9),
            failure: null,
          ),
        ),
      );
      addTearDown(harness.dispose);

      final container = await harness.pumpApp(
        tester,
        initialRoute: AppRoutes.managerReports,
      );
      addTearDown(container.dispose);

      expect(find.byType(NoPermissionScreen), findsOneWidget);
      expect(find.text('Sem acesso ao módulo'), findsOneWidget);
    });

    testWidgets('manager home navigates to reports when permission exists', (
      tester,
    ) async {
      final harness = AppFlowTestHarness(
        authRepository: FakeAuthRepository.authenticated(
          userId: 'manager-allowed',
          role: ProfileRole.manager,
          email: 'manager.allowed@example.com',
        ),
        managerPermissionsController: FakeManagerPermissionsController(
          initialState: ManagerPermissionsState(
            snapshot: ManagerPermissionsSnapshot.allowAll(),
            isLoading: false,
            revision: 1,
            lastRefreshAt: DateTime(2026, 3, 12, 9),
            failure: null,
          ),
        ),
      );
      addTearDown(harness.dispose);

      final container = await harness.pumpApp(
        tester,
        initialRoute: AppRoutes.managerHome,
        overrides: <Override>[
          tripExplorerRepositoryImplementationProvider.overrideWithValue(
            FakeTripExplorerRepository(buildTestTripExplorerRecords()),
          ),
          clientStatementRepositoryImplementationProvider.overrideWithValue(
            const FakeClientStatementRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(find.byType(ManagerHomeShell), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Relatórios').last,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Relatórios').last, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(AdminReportsScreen), findsOneWidget);
    });

    testWidgets('admin home navigates to reports workspace', (tester) async {
      final harness = AppFlowTestHarness(
        authRepository: FakeAuthRepository.authenticated(
          userId: 'admin-shell',
          role: ProfileRole.admin,
          email: 'admin.shell@example.com',
        ),
      );
      addTearDown(harness.dispose);

      final container = await harness.pumpApp(
        tester,
        initialRoute: AppRoutes.adminHome,
        overrides: <Override>[
          adminStatusProvider.overrideWith(
            (ref) async => const AdminStatus(
              isAvailable: true,
              missingConfigs: <String>[],
            ),
          ),
          tripExplorerRepositoryImplementationProvider.overrideWithValue(
            FakeTripExplorerRepository(buildTestTripExplorerRecords()),
          ),
          clientStatementRepositoryImplementationProvider.overrideWithValue(
            const FakeClientStatementRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(find.byType(AdminHomeShell), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Relatórios').last,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Relatórios').last, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(AdminReportsScreen), findsOneWidget);
    });
  });
}
