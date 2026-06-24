import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/core/domain/entities/sort_order.dart';
import 'package:local_transport/core/services/preferences/list_filters_preferences_service.dart';
import 'package:local_transport/features/auth/domain/entities/auth_status.dart';
import 'package:local_transport/features/auth/domain/entities/manager_permissions_snapshot.dart';
import 'package:local_transport/features/auth/domain/entities/password_help_request_result.dart';
import 'package:local_transport/features/auth/domain/entities/profile_role.dart';
import 'package:local_transport/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_transport/features/auth/domain/usecases/get_current_user_id.dart';
import 'package:local_transport/features/client/presentation/providers/client_trips_overview_provider.dart';
import 'package:local_transport/features/client/presentation/screens/client_trips_screen.dart';
import 'package:local_transport/features/trips/domain/entities/client_trip_filter.dart';
import 'package:local_transport/features/trips/domain/entities/client_trip_overview.dart';
import 'package:local_transport/features/trips/domain/entities/client_trip_status.dart';
import 'package:local_transport/features/trips/domain/entities/trip_extension_request.dart';
import 'package:local_transport/features/trips/domain/entities/trip_extension_status.dart';
import 'package:local_transport/features/trips/domain/entities/trip_location.dart';
import 'package:local_transport/features/trips/domain/entities/trip_participants.dart';
import 'package:local_transport/features/trips/domain/entities/trip_pricing_snapshot.dart';
import 'package:local_transport/features/trips/domain/entities/trip.dart';
import 'package:local_transport/features/trips/domain/entities/trip_date_range.dart';
import 'package:local_transport/features/trips/domain/entities/trip_list_page.dart';
import 'package:local_transport/features/trips/domain/entities/trip_state.dart';
import 'package:local_transport/features/trips/domain/entities/trip_timestamps.dart';
import 'package:local_transport/features/trips/domain/entities/trip_transport_type.dart';
import 'package:local_transport/features/trips/domain/repositories/trip_repository.dart';
import 'package:local_transport/features/trips/domain/usecases/build_client_trip_overview.dart';
import 'package:local_transport/features/trips/domain/usecases/build_client_trip_summary.dart';
import 'package:local_transport/features/trips/domain/usecases/get_client_trips_page.dart';
import 'package:local_transport/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  testWidgets('shows filter bar and opens more filters sheet', (tester) async {
    final initialState = const ClientTripsOverviewState(
      isLoading: false,
      isLoadingMore: false,
      hasMore: false,
      sections: <ClientTripSection>[],
      statusFilter: null,
      dateRange: null,
      sortOrder: SortOrder.descending,
      searchQuery: '',
      failure: null,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientTripsOverviewProvider.overrideWith(
            (ref) => _TestClientTripsOverviewController(initialState),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('pt', 'PT'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ClientTripsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Viagens'), findsOneWidget);
    expect(find.text('Mais filtros'), findsOneWidget);

    await tester.tap(find.text('Mais filtros').first);
    await tester.pumpAndSettle();

    expect(find.text('Intervalo de datas'), findsOneWidget);
    expect(find.text('Limpar'), findsOneWidget);
    expect(find.text('Aplicar'), findsOneWidget);
  });

  testWidgets('keeps search focus across rebuilds and syncs external reset', (
    tester,
  ) async {
    final controller = _TestClientTripsOverviewController(
      const ClientTripsOverviewState(
        isLoading: false,
        isLoadingMore: false,
        hasMore: false,
        sections: <ClientTripSection>[],
        statusFilter: null,
        dateRange: null,
        sortOrder: SortOrder.descending,
        searchQuery: '',
        failure: null,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clientTripsOverviewProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          locale: const Locale('pt', 'PT'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ClientTripsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final searchField = find.byType(TextFormField).first;

    await tester.tap(searchField);
    await tester.pump();

    tester.testTextInput.enterText('a');
    await tester.pump();

    expect(controller.searchUpdates, <String>['a']);
    expect(_editableText(tester).controller.text, 'a');
    expect(_editableText(tester).focusNode.hasFocus, isTrue);

    tester.testTextInput.enterText('ab');
    await tester.pump();

    expect(controller.searchUpdates, <String>['a', 'ab']);
    expect(_editableText(tester).controller.text, 'ab');
    expect(_editableText(tester).focusNode.hasFocus, isTrue);

    tester.testTextInput.enterText('abc');
    await tester.pump();

    expect(controller.searchUpdates, <String>['a', 'ab', 'abc']);
    expect(_editableText(tester).controller.text, 'abc');
    expect(_editableText(tester).focusNode.hasFocus, isTrue);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(controller.searchUpdates, <String>['a', 'ab', 'abc', '']);
    expect(_editableText(tester).controller.text, '');

    await controller.updateSearchQuery('rota');
    await tester.pump();

    expect(_editableText(tester).controller.text, 'rota');

    await controller.resetFilters();
    await tester.pump();

    expect(_editableText(tester).controller.text, '');
  });

  testWidgets(
    'updates filter copy and trip date formatting when locale changes',
    (tester) async {
      final locale = ValueNotifier<Locale>(const Locale('pt', 'PT'));
      final tripDate = DateTime(2026, 3, 6, 14, 30);
      final initialState = ClientTripsOverviewState(
        isLoading: false,
        isLoadingMore: false,
        hasMore: false,
        sections: <ClientTripSection>[
          ClientTripSection(
            status: ClientTripStatus.upcoming,
            trips: <ClientTripListItem>[
              ClientTripListItem(
                trip: _buildTrip(tripDate),
                status: ClientTripStatus.upcoming,
                date: tripDate,
                finalCostMinor: 1250,
              ),
            ],
          ),
        ],
        statusFilter: null,
        dateRange: null,
        sortOrder: SortOrder.descending,
        searchQuery: '',
        failure: null,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clientTripsOverviewProvider.overrideWith(
              (ref) => _TestClientTripsOverviewController(initialState),
            ),
          ],
          child: ValueListenableBuilder<Locale>(
            valueListenable: locale,
            builder: (context, currentLocale, child) {
              return MaterialApp(
                locale: currentLocale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const ClientTripsScreen(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Viagens'), findsOneWidget);
      expect(find.text('Mais filtros'), findsOneWidget);
      expect(find.textContaining('março'), findsOneWidget);

      locale.value = const Locale('en');
      await tester.pumpAndSettle();

      expect(find.text('Trips'), findsOneWidget);
      expect(find.text('More filters'), findsOneWidget);
      expect(find.textContaining('March'), findsOneWidget);

      locale.value = const Locale('es');
      await tester.pumpAndSettle();

      expect(find.text('Viajes'), findsOneWidget);
      expect(find.text('Más filtros'), findsOneWidget);
      expect(find.textContaining('marzo'), findsOneWidget);
    },
  );
}

class _TestClientTripsOverviewController extends ClientTripsOverviewController {
  _TestClientTripsOverviewController(ClientTripsOverviewState initialState)
    : super(
        _FakeGetClientTripsPage(),
        const BuildClientTripOverview(BuildClientTripSummary()),
        GetCurrentUserId(_FakeAuthRepository()),
        ListFiltersPreferencesService(),
      ) {
    state = initialState;
  }

  final List<String> searchUpdates = <String>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> load() async {}

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> updateStatus(ClientTripStatus? status) async {}

  @override
  Future<void> updateSearchQuery(String query) async {
    searchUpdates.add(query);
    state = state.copyWith(searchQuery: query, failure: null);
  }

  @override
  Future<void> updateSortOrder(SortOrder sortOrder) async {}

  @override
  Future<void> updateDateRange(TripDateRange? range) async {}

  @override
  Future<void> resetFilters() async {
    state = state.copyWith(
      statusFilter: null,
      dateRange: null,
      sortOrder: SortOrder.descending,
      searchQuery: '',
      failure: null,
      clearStatusFilter: true,
      clearDateRange: true,
    );
  }
}

EditableText _editableText(WidgetTester tester) {
  return tester.widget<EditableText>(find.byType(EditableText).first);
}

Trip _buildTrip(DateTime requestedAt) {
  const zeroMoney = Money(amountMinor: 0, currency: CurrencyCode.eur);
  return Trip(
    id: 'trip_1',
    state: TripState.requested,
    participants: const TripParticipants(clientId: 'client_1'),
    pickup: const TripLocation(
      latitude: 0,
      longitude: 0,
      address: 'Rua A',
    ),
    destination: const TripLocation(
      latitude: 1,
      longitude: 1,
      address: 'Rua B',
    ),
    transportType: const TripTransportType(id: 'standard', name: 'Standard'),
    pricingSnapshot: const TripPricingSnapshot(
      base: zeroMoney,
      perKm: zeroMoney,
      perWaitMinute: zeroMoney,
      lateCancellationFee: zeroMoney,
      noShowFee: zeroMoney,
    ),
    timestamps: TripTimestamps(requestedAt: requestedAt),
    extensionRequest: const TripExtensionRequest(
      status: TripExtensionStatus.none,
    ),
  );
}

class _FakeGetClientTripsPage extends GetClientTripsPage {
  _FakeGetClientTripsPage() : super(_FakeTripRepository());

  @override
  Future<TripListPage> call({
    required String clientId,
    ClientTripFilter? filter,
    String? cursorTripId,
    int pageSize = 20,
  }) async {
    return const TripListPage(
      trips: <Trip>[],
      hasMore: false,
      nextCursorTripId: null,
    );
  }
}

class _FakeTripRepository implements TripRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthStatus> fetchStatus() async =>
      const AuthStatus(isAvailable: false, role: ProfileRole.client);

  @override
  Stream<AuthStatus> watchStatus() => Stream<AuthStatus>.value(
    const AuthStatus(isAvailable: false, role: ProfileRole.client),
  );

  @override
  Future<ProfileRole> fetchProfileRole() async => ProfileRole.client;

  @override
  Future<ManagerPermissionsSnapshot> fetchManagerPermissions({
    bool forceRefresh = false,
  }) async {
    return ManagerPermissionsSnapshot.managerBlocked();
  }

  @override
  String? currentUserId() => 'client_1';

  @override
  String? currentUserEmail() => 'client_1@example.com';

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}

  @override
  Future<PasswordHelpRequestResult> requestPasswordHelp({
    required String emailOrLogin,
  }) async => const PasswordHelpRequestResult(ok: true);

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}
}
