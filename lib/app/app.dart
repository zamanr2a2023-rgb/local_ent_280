import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/core/settings/user_preferences.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/l10n/app_localizations.dart';
import 'package:local_ent_280/presentation/splash/splash_gate.dart';

class LocalTransportApp extends StatefulWidget {
  const LocalTransportApp({super.key});

  @override
  State<LocalTransportApp> createState() => _LocalTransportAppState();
}

class _LocalTransportAppState extends State<LocalTransportApp> {
  final UserPreferences _preferences = UserPreferences.instance;
  final AppCurrencyFormatter _currencyFormatter = AppCurrencyFormatter.instance;

  @override
  void initState() {
    super.initState();
    _preferences.addListener(_onPreferencesChanged);
    _currencyFormatter.addListener(_onPreferencesChanged);
  }

  @override
  void dispose() {
    _preferences.removeListener(_onPreferencesChanged);
    _currencyFormatter.removeListener(_onPreferencesChanged);
    super.dispose();
  }

  void _onPreferencesChanged() {
    if (mounted) setState(() {});
  }

  Locale _resolveLocale(BuildContext context) {
    return _preferences.effectiveLocale(
      View.of(context).platformDispatcher.locale,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = _resolveLocale(context);
    return MaterialApp(
      title: 'Local Transport',
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.background,
        ),
      ),
      home: const SplashGate(),
    );
  }
}
