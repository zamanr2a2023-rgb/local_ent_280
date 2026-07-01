import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:local_ent_280/core/config/google_maps_config.dart';
import 'package:local_ent_280/core/policies/place_autocomplete_policy.dart';

class PlacePrediction {
  const PlacePrediction({required this.description, required this.placeId});

  final String description;
  final String placeId;
}

/// Google Places Autocomplete (REST).
class PlacesAutocompleteService {
  PlacesAutocompleteService({
    http.Client? client,
    PlaceAutocompletePolicy? policy,
  }) : _client = client ?? http.Client(),
       _policy = policy ?? PlaceAutocompletePolicy.resolve();

  final http.Client _client;
  final PlaceAutocompletePolicy _policy;

  Future<List<PlacePrediction>> search(
    String input, {
    double? biasLatitude,
    double? biasLongitude,
  }) async {
    final query = input.trim();
    if (query.isEmpty) return [];

    final params = <String, String>{
      'input': query,
      'key': GoogleMapsConfig.placesApiKey,
      'language': 'pt',
      'types': 'geocode',
    };

    if (_policy.countryCodes.isNotEmpty) {
      params['components'] = _policy.countryCodes
          .map((code) => 'country:${code.trim().toLowerCase()}')
          .join('|');
    }

    if (_policy.usesLocationBias &&
        biasLatitude != null &&
        biasLongitude != null) {
      params['location'] = '$biasLatitude,$biasLongitude';
      params['radius'] = '50000';
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      params,
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
        debugPrint('Places API status: ${data['status']}');
        return [];
      }

      final predictions = data['predictions'] as List<dynamic>? ?? [];
      return predictions
          .map((item) {
            final map = item as Map<String, dynamic>;
            return PlacePrediction(
              description: map['description'] as String? ?? '',
              placeId: map['place_id'] as String? ?? '',
            );
          })
          .where((p) => p.description.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Places autocomplete failed: $e');
      return [];
    }
  }
}
