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

  /// Optional separate key for Directions / Places / Geocoding HTTP calls.
  /// Use when [apiKey] is restricted to Android/iOS apps (Maps SDK only).
  /// `flutter run --dart-define=GOOGLE_MAPS_WEB_SERVICES_API_KEY=your_key`
  static const String webServicesApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_WEB_SERVICES_API_KEY',
    defaultValue: '',
  );

  @Deprecated('Use GoogleMapsConfig.apiKey')
  static const String placesApiKey = apiKey;

  /// Keys tried in order for Directions API HTTP requests.
  static List<String> get directionsApiKeys {
    final keys = <String>[];
    final webKey = webServicesApiKey.trim();
    final primaryKey = apiKey.trim();
    if (webKey.isNotEmpty) keys.add(webKey);
    if (primaryKey.isNotEmpty && primaryKey != webKey) keys.add(primaryKey);
    return keys;
  }

  static String get preferredWebServicesKey =>
      directionsApiKeys.isNotEmpty ? directionsApiKeys.first : apiKey;

  /// Fallback map centre (Praia, Cabo Verde) when no device location is available.
  static const double defaultMapLat = 14.9177;
  static const double defaultMapLng = -23.5092;

  static bool get isConfigured => apiKey.trim().isNotEmpty;
}
