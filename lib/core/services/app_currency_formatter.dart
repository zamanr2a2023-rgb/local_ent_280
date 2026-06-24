import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_ent_280/core/settings/user_preferences.dart';

/// Converts and formats stored EUR minor-unit amounts using the user's
/// display currency from Settings and admin FX rates from `config/currency`.
class AppCurrencyFormatter extends ChangeNotifier {
  AppCurrencyFormatter._();

  static final AppCurrencyFormatter instance = AppCurrencyFormatter._();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _fxSub;
  VoidCallback? _preferencesListener;
  bool _initialized = false;

  double? _cveToEur;
  double? _cveToUsd;

  bool get hasFxRates => _cveToEur != null && _cveToUsd != null;

  void initialize({FirebaseFirestore? firestore}) {
    if (_initialized) return;
    _initialized = true;

    final db = firestore ?? FirebaseFirestore.instance;
    _fxSub = db.collection('config').doc('currency').snapshots().listen(
      (snapshot) {
        final data = snapshot.data() ?? {};
        _cveToEur = _parseRate(data['cveToEur']);
        _cveToUsd = _parseRate(data['cveToUsd']);
        notifyListeners();
      },
      onError: (_) {},
    );

    _preferencesListener = notifyListeners;
    UserPreferences.instance.addListener(_preferencesListener!);
  }

  void disposeRuntime() {
    _fxSub?.cancel();
    if (_preferencesListener != null) {
      UserPreferences.instance.removeListener(_preferencesListener!);
    }
  }

  String get displaySymbol => _symbolFor(_effectiveDisplayCurrency());

  double convertEurMajor(double eurMajor) {
    final convertedMinor = _convertMinor(
      amountMinor: (eurMajor * 100).round(),
      fromCurrency: DisplayCurrency.eur,
      toCurrency: _effectiveDisplayCurrency(),
    );
    return convertedMinor / 100.0;
  }

  /// Amounts in Firestore trip/balance fields are stored as EUR minor units.
  String formatEurMinor(int minor, {Locale? locale}) {
    return _formatMinor(
      minor,
      sourceCurrency: DisplayCurrency.eur,
      locale: locale,
    );
  }

  String formatEurMajor(double major, {Locale? locale}) {
    return formatEurMinor((major * 100).round(), locale: locale);
  }

  String formatStoredMinor(
    int minor, {
    String storedCurrency = 'EUR',
    Locale? locale,
  }) {
    final source = DisplayCurrency.fromCode(storedCurrency) ?? DisplayCurrency.eur;
    return _formatMinor(minor, sourceCurrency: source, locale: locale);
  }

  String formatEurMajorWithSuffix(
    double major,
    String suffix, {
    Locale? locale,
  }) {
    return '${formatEurMajor(major, locale: locale)}$suffix';
  }

  DisplayCurrency _effectiveDisplayCurrency() {
    final selected = UserPreferences.instance.displayCurrency;
    if (selected == DisplayCurrency.eur) return DisplayCurrency.eur;
    if (hasFxRates) return selected;
    return DisplayCurrency.eur;
  }

  int _convertMinor({
    required int amountMinor,
    required DisplayCurrency fromCurrency,
    required DisplayCurrency toCurrency,
  }) {
    if (fromCurrency == toCurrency) return amountMinor;

    final cveToEur = _cveToEur;
    final cveToUsd = _cveToUsd;
    if (cveToEur == null || cveToUsd == null || cveToEur <= 0 || cveToUsd <= 0) {
      return amountMinor;
    }

    final fromMajor = amountMinor / 100.0;
    double toMajor;

    if (fromCurrency == DisplayCurrency.eur && toCurrency == DisplayCurrency.cve) {
      toMajor = fromMajor / cveToEur;
    } else if (fromCurrency == DisplayCurrency.cve &&
        toCurrency == DisplayCurrency.eur) {
      toMajor = fromMajor * cveToEur;
    } else if (fromCurrency == DisplayCurrency.eur &&
        toCurrency == DisplayCurrency.usd) {
      toMajor = fromMajor * (cveToUsd / cveToEur);
    } else if (fromCurrency == DisplayCurrency.usd &&
        toCurrency == DisplayCurrency.eur) {
      toMajor = fromMajor * (cveToEur / cveToUsd);
    } else if (fromCurrency == DisplayCurrency.cve &&
        toCurrency == DisplayCurrency.usd) {
      toMajor = fromMajor * cveToUsd;
    } else if (fromCurrency == DisplayCurrency.usd &&
        toCurrency == DisplayCurrency.cve) {
      toMajor = fromMajor / cveToUsd;
    } else {
      return amountMinor;
    }

    return (toMajor * 100).round();
  }

  String _formatMinor(
    int minor, {
    required DisplayCurrency sourceCurrency,
    Locale? locale,
  }) {
    final target = _effectiveDisplayCurrency();
    final convertedMinor = _convertMinor(
      amountMinor: minor,
      fromCurrency: sourceCurrency,
      toCurrency: target,
    );
    final major = convertedMinor / 100.0;
    final formatter = NumberFormat.currency(
      locale: _localeTag(locale),
      symbol: _symbolFor(target),
      decimalDigits: 2,
    );
    return formatter.format(major);
  }

  String _localeTag(Locale? locale) {
    final effective = locale ?? UserPreferences.instance.localeOverride;
    if (effective == null) return 'en';
    if (effective.countryCode == null || effective.countryCode!.isEmpty) {
      return effective.languageCode;
    }
    return '${effective.languageCode}_${effective.countryCode}';
  }

  String _symbolFor(DisplayCurrency currency) {
    return switch (currency) {
      DisplayCurrency.eur => '€',
      DisplayCurrency.usd => r'$',
      DisplayCurrency.cve => 'Esc',
    };
  }

  double? _parseRate(dynamic value) {
    if (value is num) {
      final parsed = value.toDouble();
      return parsed > 0 ? parsed : null;
    }
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed == null || parsed <= 0) return null;
      return parsed;
    }
    return null;
  }
}
