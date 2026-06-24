import 'package:flutter/foundation.dart';

/// Country and bias rules for Google Places Autocomplete.
///
/// Matches `local_transport` / `docs/source_of_truth/trips.md`:
/// - dev/debug: Cabo Verde + Portugal
/// - prod: Cabo Verde only
class PlaceAutocompletePolicy {
  const PlaceAutocompletePolicy({
    required this.countryCodes,
    required this.usesLocationBias,
  });

  final List<String> countryCodes;
  final bool usesLocationBias;

  static PlaceAutocompletePolicy resolve() {
    if (kDebugMode) {
      return const PlaceAutocompletePolicy(
        countryCodes: ['cv', 'pt'],
        usesLocationBias: true,
      );
    }
    return const PlaceAutocompletePolicy(
      countryCodes: ['cv'],
      usesLocationBias: true,
    );
  }
}
