import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/client/application/policies/place_autocomplete_policy.dart';
import 'package:local_transport/features/client/domain/entities/geo_coordinates.dart';
import 'package:local_transport/features/client/domain/entities/place_details.dart';
import 'package:local_transport/features/client/domain/entities/place_suggestion.dart';
import 'package:local_transport/features/client/domain/entities/place_suggestions_request.dart';
import 'package:local_transport/features/client/domain/repositories/location_repository.dart';
import 'package:local_transport/features/client/domain/repositories/places_repository.dart';
import 'package:local_transport/features/client/domain/usecases/get_current_location_if_authorized.dart';
import 'package:local_transport/features/client/domain/usecases/get_current_location_place.dart';
import 'package:local_transport/features/client/domain/usecases/get_place_details.dart';
import 'package:local_transport/features/client/domain/usecases/get_place_details_from_coordinates.dart';
import 'package:local_transport/features/client/domain/usecases/get_place_suggestions.dart';
import 'package:local_transport/features/client/presentation/providers/pickup_step_provider.dart';

void main() {
  test('keeps the real client position after loading the pickup map', () async {
    const deviceLocation = GeoCoordinates(
      latitude: 14.9251,
      longitude: -23.5134,
    );
    const snappedPickupPlace = PlaceDetails(
      latitude: 14.9258,
      longitude: -23.514,
      formattedAddress: 'Achada Grande Trás',
    );
    final controller = _buildController(
      locationRepository: _FakeLocationRepository(
        currentLocation: deviceLocation,
        authorizedLocation: deviceLocation,
      ),
      placesRepository: _FakePlacesRepository(
        coordinateDetails: snappedPickupPlace,
      ),
    );

    await controller.loadCurrentLocation();

    expect(controller.state.selectedPlace, snappedPickupPlace);
    expect(controller.state.currentClientLocation?.latitude, 14.9251);
    expect(controller.state.currentClientLocation?.longitude, -23.5134);
  });
}

PickupStepController _buildController({
  required LocationRepository locationRepository,
  required PlacesRepository placesRepository,
}) {
  return PickupStepController(
    GetPlaceSuggestions(placesRepository),
    GetPlaceDetails(placesRepository),
    GetPlaceDetailsFromCoordinates(placesRepository),
    GetCurrentLocationPlace(locationRepository, placesRepository),
    GetCurrentLocationIfAuthorized(locationRepository),
    const PlaceAutocompletePolicy(
      countryCodes: <String>['cv'],
      usesLocationBias: true,
    ),
  );
}

class _FakeLocationRepository implements LocationRepository {
  const _FakeLocationRepository({
    required this.currentLocation,
    required this.authorizedLocation,
  });

  final GeoCoordinates currentLocation;
  final GeoCoordinates? authorizedLocation;

  @override
  Future<GeoCoordinates> fetchCurrentLocation() async => currentLocation;

  @override
  Future<GeoCoordinates?> fetchCurrentLocationIfAuthorized() async {
    return authorizedLocation;
  }
}

class _FakePlacesRepository implements PlacesRepository {
  const _FakePlacesRepository({
    required this.coordinateDetails,
  });

  final PlaceDetails coordinateDetails;

  @override
  Future<PlaceDetails> getPlaceDetails(
    String placeId, {
    String? sessionToken,
  }) async {
    return coordinateDetails;
  }

  @override
  Future<PlaceDetails> getPlaceDetailsFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    return coordinateDetails;
  }

  @override
  Future<List<PlaceSuggestion>> getSuggestions(
    PlaceSuggestionsRequest request,
  ) async {
    return const <PlaceSuggestion>[];
  }
}
