/// Country and bias rules for Google Places Autocomplete.
///
/// Empty [countryCodes] means no country filter — suggestions may come from any
/// country supported by Google Places. When [usesLocationBias] is true and GPS
/// coordinates are available, nearby results are ranked higher.
class PlaceAutocompletePolicy {
  const PlaceAutocompletePolicy({
    required this.countryCodes,
    required this.usesLocationBias,
  });

  final List<String> countryCodes;
  final bool usesLocationBias;

  static PlaceAutocompletePolicy resolve() {
    return const PlaceAutocompletePolicy(
      countryCodes: [],
      usesLocationBias: true,
    );
  }
}
