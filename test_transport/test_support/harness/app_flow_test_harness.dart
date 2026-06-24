import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'package:local_transport/app/application/bootstrap/local_transport_app_bootstrap.dart';
import 'package:local_transport/app/config/app_config.dart';
import 'package:local_transport/app/presentation/navigation/initial_route_override_provider.dart';
import 'package:local_transport/core/data/device/providers/screen_awake_service_provider.dart';
import 'package:local_transport/core/data/firebase/providers/firebase_analytics_service_provider.dart';
import 'package:local_transport/core/data/firebase/providers/firebase_crash_reporting_service_provider.dart';
import 'package:local_transport/core/data/network/providers/connectivity_service_provider.dart';
import 'package:local_transport/features/auth/application/providers/auth_domain_providers.dart';
import 'package:local_transport/features/auth/application/providers/user_profile_domain_providers.dart';
import 'package:local_transport/features/currency/data/providers/currency_fx_repository_provider.dart';
import 'package:local_transport/features/driver/presentation/providers/driver_background_tracking_runtime_controller.dart';
import 'package:local_transport/features/notifications/data/providers/notification_event_repository_provider.dart';
import 'package:local_transport/features/notifications/data/providers/notification_token_repository_provider.dart';
import 'package:local_transport/features/onboarding/data/providers/onboarding_repository_provider.dart';
import 'package:local_transport/features/auth/presentation/providers/manager_permissions_controller.dart';
import 'package:local_transport/core/services/preferences/language_preferences_service.dart';

import '../fakes/fake_app_services.dart';
import '../fakes/fake_auth_repository.dart';
import '../fakes/fake_currency_fx_repository.dart';
import '../fakes/fake_driver_background_tracking_runtime_controller.dart';
import '../fakes/fake_manager_permissions_controller.dart';
import '../fakes/fake_notification_repositories.dart';
import '../fakes/fake_onboarding_repository.dart';
import '../fakes/fake_user_profile_repository.dart';

class AppFlowTestHarness {
  AppFlowTestHarness({
    FakeAnalyticsService? analyticsService,
    FakeCrashReportingService? crashReportingService,
    FakeConnectivityService? connectivityService,
    FakeScreenAwakeService? screenAwakeService,
    FakeNotificationEventRepository? notificationEventRepository,
    FakeNotificationTokenRepository? notificationTokenRepository,
    FakeCurrencyFxRepository? currencyFxRepository,
    FakeOnboardingRepository? onboardingRepository,
    FakeManagerPermissionsController? managerPermissionsController,
    FakeDriverBackgroundTrackingRuntimeController?
    driverBackgroundTrackingRuntimeController,
    FakeAuthRepository? authRepository,
    FakeUserProfileRepository? userProfileRepository,
  }) : analyticsService = analyticsService ?? FakeAnalyticsService(),
       crashReportingService =
           crashReportingService ?? FakeCrashReportingService(),
       connectivityService = connectivityService ?? FakeConnectivityService(),
       screenAwakeService = screenAwakeService ?? FakeScreenAwakeService(),
       notificationEventRepository =
           notificationEventRepository ?? FakeNotificationEventRepository(),
       notificationTokenRepository =
           notificationTokenRepository ?? FakeNotificationTokenRepository(),
       currencyFxRepository =
           currencyFxRepository ?? FakeCurrencyFxRepository(),
       onboardingRepository =
           onboardingRepository ?? FakeOnboardingRepository(),
       managerPermissionsController =
           managerPermissionsController ?? FakeManagerPermissionsController(),
       driverBackgroundTrackingRuntimeController =
           driverBackgroundTrackingRuntimeController ??
           FakeDriverBackgroundTrackingRuntimeController(),
       authRepository = authRepository ?? FakeAuthRepository.unauthenticated(),
       userProfileRepository =
           userProfileRepository ?? FakeUserProfileRepository();

  static bool _didInitializeDateFormatting = false;

  final LocalTransportAppBootstrap _bootstrap =
      const LocalTransportAppBootstrap();
  final FakeAnalyticsService analyticsService;
  final FakeCrashReportingService crashReportingService;
  final FakeConnectivityService connectivityService;
  final FakeScreenAwakeService screenAwakeService;
  final FakeNotificationEventRepository notificationEventRepository;
  final FakeNotificationTokenRepository notificationTokenRepository;
  final FakeCurrencyFxRepository currencyFxRepository;
  final FakeOnboardingRepository onboardingRepository;
  final FakeManagerPermissionsController managerPermissionsController;
  final FakeDriverBackgroundTrackingRuntimeController
  driverBackgroundTrackingRuntimeController;
  final FakeAuthRepository authRepository;
  final FakeUserProfileRepository userProfileRepository;

  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    required String initialRoute,
    AppConfig? appConfig,
    List<Override> overrides = const <Override>[],
  }) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await LanguagePreferencesService().writeOverride(const Locale('pt', 'PT'));
    if (!_didInitializeDateFormatting) {
      await initializeDateFormatting('pt_PT');
      _didInitializeDateFormatting = true;
    }
    final resolvedAppConfig = appConfig ?? AppConfig.mockedTest();
    final useFakeAuth = !resolvedAppConfig.enableFirebase;

    final container = await _bootstrap.initialize(
      appConfig: resolvedAppConfig,
      overrides: <Override>[
        initialRouteOverrideProvider.overrideWithValue(initialRoute),
        analyticsServiceImplementationProvider.overrideWithValue(
          analyticsService,
        ),
        crashReportingServiceImplementationProvider.overrideWithValue(
          crashReportingService,
        ),
        connectivityServiceImplementationProvider.overrideWithValue(
          connectivityService,
        ),
        screenAwakeServiceImplementationProvider.overrideWithValue(
          screenAwakeService,
        ),
        notificationEventRepositoryImplementationProvider.overrideWithValue(
          notificationEventRepository,
        ),
        notificationTokenRepositoryImplementationProvider.overrideWithValue(
          notificationTokenRepository,
        ),
        currencyFxRepositoryImplementationProvider.overrideWithValue(
          currencyFxRepository,
        ),
        onboardingRepositoryImplementationProvider.overrideWithValue(
          onboardingRepository,
        ),
        managerPermissionsControllerProvider.overrideWith(
          (ref) => managerPermissionsController,
        ),
        driverBackgroundTrackingRuntimeControllerProvider.overrideWith(
          (ref) => driverBackgroundTrackingRuntimeController,
        ),
        if (useFakeAuth)
          authRepositoryProvider.overrideWithValue(authRepository),
        if (useFakeAuth)
          userProfileRepositoryProvider.overrideWithValue(
            userProfileRepository,
          ),
        ...overrides,
      ],
    );

    await tester.pumpWidget(_bootstrap.buildApp(container: container));
    await tester.pump();
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> dispose() async {
    await connectivityService.dispose();
    await notificationEventRepository.dispose();
    await currencyFxRepository.dispose();
    await authRepository.dispose();
    if (managerPermissionsController.mounted) {
      managerPermissionsController.dispose();
    }
    if (driverBackgroundTrackingRuntimeController.mounted) {
      driverBackgroundTrackingRuntimeController.dispose();
    }
  }
}
