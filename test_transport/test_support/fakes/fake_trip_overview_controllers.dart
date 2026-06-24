import 'package:local_transport/core/services/preferences/list_filters_preferences_service.dart';
import 'package:local_transport/features/auth/domain/entities/auth_status.dart';
import 'package:local_transport/features/auth/domain/entities/manager_permissions_snapshot.dart';
import 'package:local_transport/features/auth/domain/entities/password_help_request_result.dart';
import 'package:local_transport/features/auth/domain/entities/profile_role.dart';
import 'package:local_transport/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_transport/features/auth/domain/usecases/get_current_user_id.dart';
import 'package:local_transport/features/client/presentation/providers/client_trips_overview_provider.dart';
import 'package:local_transport/features/driver/presentation/providers/driver_trips_overview_provider.dart';
import 'package:local_transport/features/trips/domain/entities/client_trip_filter.dart';
import 'package:local_transport/features/trips/domain/entities/driver_trip_filter.dart';
import 'package:local_transport/features/trips/domain/entities/trip_list_page.dart';
import 'package:local_transport/features/trips/domain/repositories/trip_repository.dart';
import 'package:local_transport/features/trips/domain/usecases/build_client_trip_overview.dart';
import 'package:local_transport/features/trips/domain/usecases/build_client_trip_summary.dart';
import 'package:local_transport/features/trips/domain/usecases/get_client_trips_page.dart';
import 'package:local_transport/features/trips/domain/usecases/get_driver_trips_page.dart';

class FakeClientTripsOverviewController extends ClientTripsOverviewController {
  FakeClientTripsOverviewController(ClientTripsOverviewState initialState)
    : super(
        _FakeGetClientTripsPage(),
        const BuildClientTripOverview(BuildClientTripSummary()),
        GetCurrentUserId(const _FakeAuthRepository()),
        ListFiltersPreferencesService(),
      ) {
    state = initialState;
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> load() async {}

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> updateDateRange(range) async {}

  @override
  Future<void> updateSearchQuery(String query) async {
    state = state.copyWith(searchQuery: query, failure: null);
  }

  @override
  Future<void> updateSortOrder(sortOrder) async {}

  @override
  Future<void> updateStatus(status) async {}

  @override
  Future<void> clearDateRange() async {}

  @override
  Future<void> resetFilters() async {}
}

class FakeDriverTripsOverviewController extends DriverTripsOverviewController {
  FakeDriverTripsOverviewController(DriverTripsOverviewState initialState)
    : super(
        _FakeGetDriverTripsPage(),
        GetCurrentUserId(const _FakeAuthRepository()),
        ListFiltersPreferencesService(),
      ) {
    state = initialState;
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> load() async {}

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> resetFilters() async {}

  @override
  Future<void> resetToToday() async {}

  @override
  Future<void> updateDateRange(range) async {}

  @override
  Future<void> updateSearchQuery(String query) async {
    state = state.copyWith(searchQuery: query, errorMessage: null);
  }

  @override
  Future<void> updateSortOrder(sortOrder) async {}

  @override
  Future<void> updateStatus(status) async {}
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
      trips: [],
      hasMore: false,
      nextCursorTripId: null,
    );
  }
}

class _FakeGetDriverTripsPage extends GetDriverTripsPage {
  _FakeGetDriverTripsPage() : super(_FakeTripRepository());

  @override
  Future<TripListPage> call({
    required String driverId,
    DriverTripFilter? filter,
    dateRange,
    String? cursorTripId,
    int pageSize = 20,
  }) async {
    return const TripListPage(
      trips: [],
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
  const _FakeAuthRepository();

  @override
  String? currentUserEmail() => null;

  @override
  String? currentUserId() => 'test-user';

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}

  @override
  Future<ManagerPermissionsSnapshot> fetchManagerPermissions({
    bool forceRefresh = false,
  }) async {
    return ManagerPermissionsSnapshot.managerBlocked();
  }

  @override
  Future<ProfileRole> fetchProfileRole() async => ProfileRole.client;

  @override
  Future<AuthStatus> fetchStatus() async {
    return const AuthStatus(isAvailable: true, role: ProfileRole.client);
  }

  @override
  Future<PasswordHelpRequestResult> requestPasswordHelp({
    required String emailOrLogin,
  }) async {
    return const PasswordHelpRequestResult(ok: true);
  }

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Stream<AuthStatus> watchStatus() {
    return Stream<AuthStatus>.value(
      const AuthStatus(isAvailable: true, role: ProfileRole.client),
    );
  }
}
