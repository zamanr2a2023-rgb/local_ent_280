import 'package:flutter/material.dart';

class SupportedAppLocales {
  const SupportedAppLocales._();

  static const Locale english = Locale('en');
  static const Locale portuguesePortugal = Locale('pt', 'PT');
  static const Locale spanish = Locale('es');

  static const List<Locale> values = <Locale>[
    english,
    portuguesePortugal,
    spanish,
  ];
}
