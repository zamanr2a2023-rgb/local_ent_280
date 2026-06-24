import 'package:flutter/material.dart';

import 'supported_app_locales.dart';

Locale resolveSupportedAppLocale(Locale locale) {
  final languageCode = locale.languageCode.toLowerCase();
  if (languageCode == 'pt') {
    return SupportedAppLocales.portuguesePortugal;
  }
  if (languageCode == 'en') {
    return SupportedAppLocales.english;
  }
  if (languageCode == 'es') {
    return SupportedAppLocales.spanish;
  }
  return SupportedAppLocales.portuguesePortugal;
}
