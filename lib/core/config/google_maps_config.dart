/// Google Maps / Places / Directions API configuration.
///
/// Firebase uses a separate API key from [firebase_options.dart] / google-services.json.
/// This key must have these APIs enabled in Google Cloud Console:
/// - Maps SDK for Android
/// - Places API
/// - Directions API
/// - Geocoding API (optional fallback; device geocoder is preferred)
abstract final class GoogleMapsConfig {
  static const String _defaultApiKey =
      'AIzaSyCfYetXZeDG082fWzLTgT8Mzldo6e7i6HE';

  /// Override at build time:
  /// `flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_key`
  static const String apiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: _defaultApiKey,
  );

  @Deprecated('Use GoogleMapsConfig.apiKey')
  static const String placesApiKey = apiKey;

  /// Bias autocomplete suggestions toward Lisbon.
  static const double lisbonLat = 38.7223;
  static const double lisbonLng = -9.1393;

  static bool get isConfigured => apiKey.trim().isNotEmpty;
}
