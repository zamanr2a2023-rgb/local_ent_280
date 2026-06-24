import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_ent_280/app/app.dart';
import 'package:local_ent_280/app/di/provider_overrides.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/core/settings/user_preferences.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_fonts.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

class LocalTransportAppBootstrap {
  const LocalTransportAppBootstrap();

  Future<ProviderContainer> initialize({
    List<Override> overrides = const <Override>[],
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await UserPreferences.instance.load();
    AppCurrencyFormatter.instance.initialize();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    await AppFonts.ensureLoaded();

    return ProviderContainer(
      overrides: <Override>[
        ...buildProviderOverrides(),
        ...overrides,
      ],
    );
  }

  Widget buildApp({required ProviderContainer container}) {
    return UncontrolledProviderScope(
      container: container,
      child: AppScreenUtil.init(child: const LocalTransportApp()),
    );
  }

  Future<void> run({List<Override> overrides = const <Override>[]}) async {
    final container = await initialize(overrides: overrides);
    runApp(buildApp(container: container));
  }
}
