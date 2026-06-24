import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/services/connectivity_service.dart';
import 'package:local_transport/core/services/preferences/recent_destinations_preferences_service.dart';
import 'package:local_transport/features/auth/domain/entities/auth_status.dart';
import 'package:local_transport/features/auth/domain/entities/manager_permissions_snapshot.dart';
import 'package:local_transport/features/auth/domain/entities/password_help_request_result.dart';
import 'package:local_transport/features/auth/domain/entities/profile_role.dart';
import 'package:local_transport/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_transport/features/auth/domain/usecases/get_current_user_id.dart';
import 'package:local_transport/features/client/domain/entities/balance.dart';
import 'package:local_transport/features/client/domain/entities/trip_draft.dart';
import 'package:local_transport/features/client/domain/entities/transport_type.dart';
import 'package:local_transport/features/client/domain/repositories/balance_repository.dart';
import 'package:local_transport/features/client/domain/usecases/build_trip_request.dart';
import 'package:local_transport/features/client/domain/usecases/get_client_balance.dart';
import 'package:local_transport/features/client/domain/usecases/validate_trip_eligibility.dart';
import 'package:local_transport/features/client/presentation/providers/trip_request_provider.dart';
import 'package:local_transport/features/pricing/domain/usecases/resolve_tariff_multiplier.dart';
import 'package:local_transport/features/trips/domain/entities/trip.dart';
import 'package:local_transport/features/trips/domain/entities/trip_location.dart';
import 'package:local_transport/features/trips/domain/repositories/trip_assignment_repository.dart';
import 'package:local_transport/features/trips/domain/repositories/trip_repository.dart';
import 'package:local_transport/features/trips/domain/services/trip_id_generator.dart';
import 'package:local_transport/features/trips/domain/usecases/can_execute_critical_trip_action.dart';
import 'package:local_transport/features/trips/domain/usecases/check_driver_availability.dart';
import 'package:local_transport/features/trips/domain/usecases/request_trip.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('stores draft destination when submission is blocked offline', () async {
    final preferences = RecentDestinationsPreferencesService();
    final controller = TripRequestController(
      requestTrip: RequestTrip(
        _FakeTripRepository(),
        const _FakeTripIdGenerator(),
      ),
      getCurrentUserId: GetCurrentUserId(const _FakeAuthRepository('client-1')),
      buildTripRequest: BuildTripRequest(const ResolveTariffMultiplier()),
      precheckTripEligibility: PrecheckTripEligibility(
        GetClientBalance(_FakeBalanceRepository()),
      ),
      checkDriverAvailability: CheckDriverAvailability(
        _FakeTripAssignmentRepository(),
      ),
      canExecuteCriticalTripAction: CanExecuteCriticalTripAction(
        const _FakeConnectivityService(isOnline: false),
      ),
      recentDestinationsPreferencesService: preferences,
    );

    await controller.submit(
      draft: const TripDraft(
        destinationLatitude: 14.9177,
        destinationLongitude: -23.5092,
        destinationAddress: 'Palmarejo',
        pickupLatitude: 14.9,
        pickupLongitude: -23.5,
        pickupAddress: 'Origem',
        transportType: TransportType(
          id: 'standard',
          name: 'Standard',
          description: 'Standard',
          packagePriceMultiplierBasisPoints: 10000,
        ),
      ),
      tariff: null,
      estimatedTotalMinor: null,
    );

    final failedDestination = await preferences.readFailedDestination(
      'client-1',
    );

    expect(controller.state.failure, TripRequestFailure.offline);
    expect(failedDestination?.formattedAddress, 'Palmarejo');
  });
}

class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository(this.clientId);

  final String? clientId;

  @override
  String? currentUserId() => clientId;

  @override
  String? currentUserEmail() => null;

  @override
  Future<AuthStatus> fetchStatus() => throw UnimplementedError();

  @override
  Stream<AuthStatus> watchStatus() => const Stream<AuthStatus>.empty();

  @override
  Future<ProfileRole> fetchProfileRole() => throw UnimplementedError();

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => throw UnimplementedError();

  @override
  Future<ManagerPermissionsSnapshot> fetchManagerPermissions({
    bool forceRefresh = false,
  }) => throw UnimplementedError();

  @override
  Future<PasswordHelpRequestResult> requestPasswordHelp({
    required String emailOrLogin,
  }) => throw UnimplementedError();
}

class _FakeBalanceRepository implements BalanceRepository {
  @override
  Future<Balance?> fetchBalance(String clientId) async => null;

  @override
  Future<void> saveBalance(Balance balance) => throw UnimplementedError();

  @override
  Stream<Balance?> watchBalance(String clientId) {
    return const Stream<Balance?>.empty();
  }
}

class _FakeTripAssignmentRepository implements TripAssignmentRepository {
  @override
  Future<bool> hasAvailableDrivers() async => true;

  @override
  Future<bool> isReservationAssignmentAvailable({
    required String driverId,
    required DateTime scheduledAt,
    required TripLocation pickup,
    required TripLocation destination,
    String? excludeReservationId,
  }) => throw UnimplementedError();

  @override
  Future<String?> reassignTrip({
    required Trip trip,
    required String declinedDriverId,
    required int maxAttempts,
  }) => throw UnimplementedError();
}

class _FakeConnectivityService implements ConnectivityService {
  const _FakeConnectivityService({required this.isOnline});

  @override
  final bool isOnline;

  @override
  Stream<bool> get onConnectivityChanged => const Stream<bool>.empty();
}

class _FakeTripRepository implements TripRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTripIdGenerator implements TripIdGenerator {
  const _FakeTripIdGenerator();

  @override
  String generateTripEventId(String tripId) => '$tripId-event';

  @override
  String generateTripId() => 'trip-1';
}
