import 'package:flutter/material.dart';
import 'package:local_ent_280/core/localization/app_locale_resolution.dart';
import 'package:local_ent_280/core/localization/supported_app_locales.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DisplayCurrency {
  cve('CVE'),
  eur('EUR'),
  usd('USD');

  const DisplayCurrency(this.code);

  final String code;

  static DisplayCurrency? fromCode(String? code) {
    if (code == null) return null;
    for (final currency in values) {
      if (currency.code == code) return currency;
    }
    return null;
  }
}

/// Persists language and display currency preferences app-wide.
class UserPreferences extends ChangeNotifier {
  UserPreferences._();

  static final UserPreferences instance = UserPreferences._();

  static const _languageCodeKey = 'settings_language_code';
  static const _countryCodeKey = 'settings_country_code';
  static const _currencyKey = 'settings_display_currency';
  static const _driverSimulationKey = 'settings_driver_location_simulation';
  static const _onboardingCompletedKey = 'onboarding_completed';

  Locale? _localeOverride;
  DisplayCurrency _displayCurrency = DisplayCurrency.cve;
  bool _driverLocationSimulationEnabled = false;
  bool _onboardingCompleted = true;
  bool _loaded = false;

  Locale? get localeOverride => _localeOverride;
  DisplayCurrency get displayCurrency => _displayCurrency;
  bool get driverLocationSimulationEnabled => _driverLocationSimulationEnabled;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get isLoaded => _loaded;

  static const selectableLocales = SupportedAppLocales.values;

  static const selectableCurrencies = <DisplayCurrency>[
    DisplayCurrency.cve,
    DisplayCurrency.eur,
    DisplayCurrency.usd,
  ];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageCodeKey);
    final countryCode = prefs.getString(_countryCodeKey);
    if (languageCode != null && languageCode.isNotEmpty) {
      _localeOverride = countryCode == null || countryCode.isEmpty
          ? Locale(languageCode)
          : Locale(languageCode, countryCode);
    } else {
      _localeOverride = null;
    }
    _displayCurrency =
        DisplayCurrency.fromCode(prefs.getString(_currencyKey)) ??
            DisplayCurrency.cve;
    _driverLocationSimulationEnabled =
        prefs.getBool(_driverSimulationKey) ?? false;
    _onboardingCompleted = prefs.getBool(_onboardingCompletedKey) ?? true;
    _loaded = true;
    notifyListeners();
  }

  Locale effectiveLocale(Locale deviceLocale) {
    if (_localeOverride != null) {
      return resolveSupportedAppLocale(_localeOverride!);
    }
    return SupportedAppLocales.portuguesePortugal;
  }

  Locale _matchSupportedLocale(Locale deviceLocale) {
    return resolveSupportedAppLocale(deviceLocale);
  }

  Future<void> setLanguage(Locale locale) async {
    _localeOverride = resolveSupportedAppLocale(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, locale.languageCode);
    if (locale.countryCode == null || locale.countryCode!.isEmpty) {
      await prefs.remove(_countryCodeKey);
    } else {
      await prefs.setString(_countryCodeKey, locale.countryCode!);
    }
    notifyListeners();
  }

  Future<void> resetToDeviceLanguage(Locale deviceLocale) async {
    await setLanguage(_matchSupportedLocale(deviceLocale));
  }

  Future<void> setDisplayCurrency(DisplayCurrency currency) async {
    _displayCurrency = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency.code);
    notifyListeners();
  }

  Future<void> setDriverLocationSimulationEnabled(bool enabled) async {
    _driverLocationSimulationEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_driverSimulationKey, enabled);
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    _onboardingCompleted = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, false);
    notifyListeners();
  }
}
