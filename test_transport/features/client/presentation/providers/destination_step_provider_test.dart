import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/services/preferences/destination_preference_entry.dart';
import 'package:local_transport/core/services/preferences/recent_destinations_preferences_service.dart';
import 'package:local_transport/features/auth/domain/entities/auth_status.dart';
import 'package:local_transport/features/auth/domain/entities/manager_permissions_snapshot.dart';
import 'package:local_transport/features/auth/domain/entities/password_help_request_result.dart';
import 'package:local_transport/features/auth/domain/entities/profile_role.dart';
import 'package:local_transport/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_transport/features/auth/domain/usecases/get_current_user_id.dart';
import 'package:local_transport/features/client/application/policies/place_autocomplete_policy.dart';
import 'package:local_transport/features/client/domain/entities/geo_coordinates.dart';
import 'package:local_transport/features/client/domain/entities/place_details.dart';
import 'package:local_transport/features/client/domain/entities/place_suggestion.dart';
import 'package:local_transport/features/client/domain/entities/place_suggestions_request.dart';
import 'package:local_transport/features/client/domain/repositories/location_repository.dart';
import 'package:local_transport/features/client/domain/repositories/places_repository.dart';
import 'package:local_transport/features/client/domain/usecases/get_current_location_if_authorized.dart';
import 'package:local_transport/features/client/domain/usecases/get_place_details.dart';
import 'package:local_transport/features/client/domain/usecases/get_place_details_from_coordinates.dart';
import 'package:local_transport/features/client/domain/usecases/get_place_suggestions.dart';
import 'package:local_transport/features/client/presentation/providers/destination_step_provider.dart';
import 'package:local_transport/features/trips/domain/entities/client_trip_filter.dart';
import 'package:local_transport/features/trips/domain/entities/trip.dart';
import 'package:local_transport/features/trips/domain/entities/trip_list_page.dart';
import 'package:local_transport/features/trips/domain/entities/trip_state.dart';
import 'package:local_transport/features/trips/domain/repositories/trip_repository.dart';
import 'package:local_transport/features/trips/domain/usecases/get_client_trips_page.dart';
import 'package:local_transport/features/trips/domain/usecases/get_recent_client_completed_destinations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../test_support/fixtures/test_trip_factory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'loads favorites, failed destination, and recent destinations once',
    () async {
      final preferences = RecentDestinationsPreferencesService();
      const favorite = DestinationPreferenceEntry(
        latitude: 38.7071,
        longitude: -9.1355,
        formattedAddress: 'Palmarejo',
      );
      const failed = DestinationPreferenceEntry(
        latitude: 14.921,
        longitude: -23.508,
        formattedAddress: 'Achada Santo António',
      );
      await preferences.saveFavoriteDestination(
        clientId: 'client-1',
        destination: favorite,
      );
      await preferences.writeFailedDestination(
        clientId: 'client-1',
        destination: failed,
      );
      final controller = _buildController(
        clientId: 'client-1',
        preferences: preferences,
        trips: <Trip>[
          buildTestTrip(
            id: 'trip-1',
            pickupAddress: 'Origem',
            destinationAddress: 'Palmarejo',
            requestedAt: DateTime(2026),
            state: TripState.completed,
          ),
          buildTestTrip(
            id: 'trip-2',
            pickupAddress: 'Origem',
            destinationAddress: 'Plateau',
            requestedAt: DateTime(2026, 1, 2),
            state: TripState.chargeApplied,
          ),
        ],
      );

      await controller.loadRecentDestinations();

      expect(
        controller.state.recentDestinations.map(
          (item) => item.formattedAddress,
        ),
        <String>['Palmarejo', 'Achada Santo António', 'Plateau'],
      );
      expect(controller.state.favoriteDestinations, hasLength(1));
      expect(controller.state.favoriteDestinationKeys, hasLength(1));
      expect(controller.state.removableRecentDestinationKeys, hasLength(2));
    },
  );

  test(
    'keeps destination suggestions empty without authenticated client',
    () async {
      final controller = _buildController(
        clientId: null,
        preferences: RecentDestinationsPreferencesService(),
        trips: <Trip>[
          buildTestTrip(
            id: 'trip-1',
            pickupAddress: 'Origem',
            destinationAddress: 'Plateau',
            requestedAt: DateTime(2026),
            state: TripState.completed,
          ),
        ],
      );

      await controller.loadRecentDestinations();

      expect(controller.state.recentDestinations, isEmpty);
      expect(controller.state.favoriteDestinations, isEmpty);
      expect(controller.state.isLoadingRecentDestinations, isFalse);
    },
  );

  test(
    'persists confirmed destination into local recent suggestions',
    () async {
      final preferences = RecentDestinationsPreferencesService();
      final controller = _buildController(
        clientId: 'client-1',
        preferences: preferences,
        trips: <Trip>[
          buildTestTrip(
            id: 'trip-1',
            pickupAddress: 'Origem',
            destinationAddress: 'Plateau',
            requestedAt: DateTime(2026),
            state: TripState.completed,
          ),
        ],
      );

      await controller.saveConfirmedDestination(
        const PlaceDetails(
          latitude: 14.9177,
          longitude: -23.5092,
          formattedAddress: 'Palmarejo',
        ),
      );
      await controller.loadRecentDestinations();

      expect(
        controller.state.recentDestinations.map(
          (item) => item.formattedAddress,
        ),
        <String>['Palmarejo', 'Plateau'],
      );
      expect(controller.state.removableRecentDestinationKeys, hasLength(2));
    },
  );
}

DestinationStepController _buildController({
  required String? clientId,
  required RecentDestinationsPreferencesService preferences,
  required List<Trip> trips,
}) {
  final placesRepository = _FakePlacesRepository();
  return DestinationStepController(
    GetPlaceSuggestions(placesRepository),
    GetPlaceDetails(placesRepository),
    GetPlaceDetailsFromCoordinates(placesRepository),
    GetCurrentLocationIfAuthorized(_FakeLocationRepository()),
    GetCurrentUserId(_FakeAuthRepository(clientId)),
    GetRecentClientCompletedDestinations(
      GetClientTripsPage(_FakeTripRepository(trips)),
    ),
    preferences,
    const PlaceAutocompletePolicy(
      countryCodes: <String>['cv'],
      usesLocationBias: false,
    ),
  );
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

class _FakeLocationRepository implements LocationRepository {
  @override
  Future<GeoCoordinates> fetchCurrentLocation() => throw UnimplementedError();

  @override
  Future<GeoCoordinates?> fetchCurrentLocationIfAuthorized() async => null;
}

class _FakePlacesRepository implements PlacesRepository {
  @override
  Future<PlaceDetails> getPlaceDetails(
    String placeId, {
    String? sessionToken,
  }) => throw UnimplementedError();

  @override
  Future<PlaceDetails> getPlaceDetailsFromCoordinates({
    required double latitude,
    required double longitude,
  }) => throw UnimplementedError();

  @override
  Future<List<PlaceSuggestion>> getSuggestions(
    PlaceSuggestionsRequest request,
  ) async {
    return const <PlaceSuggestion>[];
  }
}

class _FakeTripRepository implements TripRepository {
  const _FakeTripRepository(this.trips);

  final List<Trip> trips;

  @override
  Future<TripListPage> fetchTripsForClientPage({
    required String clientId,
    ClientTripFilter? filter,
    String? cursorTripId,
    int pageSize = 20,
  }) async {
    return TripListPage(
      trips: trips,
      hasMore: false,
      nextCursorTripId: null,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
