import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/localization/api_language_tag_mapper.dart';
import 'package:local_transport/core/localization/app_locale_resolution.dart';
import 'package:local_transport/core/localization/supported_app_locales.dart';

void main() {
  group('resolveSupportedAppLocale', () {
    test('maps pt-BR to pt-PT', () {
      final resolved = resolveSupportedAppLocale(const Locale('pt', 'BR'));
      expect(resolved, SupportedAppLocales.portuguesePortugal);
    });

    test('maps unsupported locale to pt-PT fallback', () {
      final resolved = resolveSupportedAppLocale(const Locale('fr', 'FR'));
      expect(resolved, SupportedAppLocales.portuguesePortugal);
    });
  });

  group('resolveAppLocaleFromDevice', () {
    test('uses pt-PT by default even when exact pt-PT is available', () {
      final resolved = resolveAppLocaleFromDevice(const <Locale>[
        Locale('en', 'US'),
        Locale('pt', 'PT'),
      ]);
      expect(resolved, SupportedAppLocales.portuguesePortugal);
    });

    test('uses pt-PT by default for english devices', () {
      final resolved = resolveAppLocaleFromDevice(const <Locale>[
        Locale('en', 'US'),
      ]);
      expect(resolved, SupportedAppLocales.portuguesePortugal);
    });

    test('falls back to pt-PT for unsupported locales', () {
      final resolved = resolveAppLocaleFromDevice(const <Locale>[
        Locale('fr', 'FR'),
      ]);
      expect(resolved, SupportedAppLocales.portuguesePortugal);
    });
  });

  group('persisted locale encoding', () {
    test('parses and normalizes pt-PT override', () {
      expect(
        parsePersistedLocaleOverride('pt-PT'),
        SupportedAppLocales.portuguesePortugal,
      );
    });

    test('encodes locale as underscore tag for storage', () {
      expect(
        encodeLocaleOverride(const Locale('pt', 'PT')),
        'pt_PT',
      );
    });
  });

  group('ApiLanguageTagMapper', () {
    test('maps locales to expected BCP-47 tags', () {
      expect(ApiLanguageTagMapper.toTag(const Locale('en')), 'en');
      expect(ApiLanguageTagMapper.toTag(const Locale('es', 'MX')), 'es');
      expect(ApiLanguageTagMapper.toTag(const Locale('pt', 'BR')), 'pt-PT');
    });
  });
}
