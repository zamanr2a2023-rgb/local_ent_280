import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:local_ent_280/core/config/google_maps_config.dart';

class PlacePrediction {
  const PlacePrediction({
    required this.description,
    required this.placeId,
  });

  final String description;
  final String placeId;
}

/// Google Places Autocomplete (REST).
class PlacesAutocompleteService {
  PlacesAutocompleteService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<PlacePrediction>> search(String input) async {
    final query = input.trim();
    if (query.isEmpty) return [];

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {
        'input': query,
        'key': GoogleMapsConfig.placesApiKey,
        'language': 'en',
        'components': 'country:pt',
        'types': 'geocode',
        'location': '${GoogleMapsConfig.lisbonLat},${GoogleMapsConfig.lisbonLng}',
        'radius': '50000',
      },
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
