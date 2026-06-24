import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/app/theme/app_theme.dart';
import 'package:local_transport/features/auth/application/providers/auth_domain_providers.dart';
import 'package:local_transport/features/auth/domain/entities/auth_status.dart';
import 'package:local_transport/features/auth/domain/entities/manager_permissions_snapshot.dart';
import 'package:local_transport/features/auth/domain/entities/password_help_request_result.dart';
import 'package:local_transport/features/auth/domain/entities/profile_role.dart';
import 'package:local_transport/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_transport/features/operational_incidents/data/providers/operational_monitoring_config_repository_provider.dart';
import 'package:local_transport/features/operational_incidents/domain/entities/operational_monitoring_config.dart';
import 'package:local_transport/features/operational_incidents/domain/repositories/operational_monitoring_config_repository.dart';
import 'package:local_transport/features/operational_incidents/presentation/screens/operational_monitoring_settings_screen.dart';
import 'package:local_transport/l10n/app_localizations.dart';

void main() {
  testWidgets('saves edited operational monitoring parameters', (
    tester,
  ) async {
    final repository = _FakeOperationalMonitoringConfigRepository(
      initialConfig: OperationalMonitoringConfig(
        enabled: false,
        dropoffWaitingRadiusMeters: 250,
        postDropoffGracePeriodMinutes: 8,
        routeDeviationCorridorMeters: 300,
        sustainedDeviationThresholdSeconds: 180,
        activeTripVarianceToleranceKm: 1.5,
        activeTripVarianceTolerancePct: 12,
        postDropoffLocalMovementAllowanceKm: 0.5,
        postDropoffVarianceToleranceKm: 0.8,
        postDropoffVarianceTolerancePct: 18,
        noTripLocalMovementAllowanceKm: 1,
        noTripMovementGracePeriodMinutes: 10,
        nextAssignmentSuppressionLookaheadMinutes: 30,
        staleTelemetryThresholdSeconds: 180,
        incidentClearanceThresholdSeconds: 180,
        replaySampleMinDistanceMeters: 75,
        replaySampleMinIntervalSeconds: 30,
        approvalDestinationArrivalRadiusMeters: 300,
        hasBaseGeofence: true,
        serviceGeofenceCount: 2,
        updatedBy: 'admin-0',
      ),
    );
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          _FakeAuthRepository(userId: 'admin-1'),
        ),
        operationalMonitoringConfigRepositoryProvider.overrideWithValue(
          repository,
        ),
      ],
    );
    addTearDown(() async {
      await repository.dispose();
      container.dispose();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('pt', 'PT'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const OperationalMonitoringSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Configuração de monitorização operacional'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField).first, '320');
    await tester.scrollUntilVisible(
      find.text('Guardar parâmetros'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Guardar parâmetros'));
    await tester.pump();

    expect(repository.lastSavedDraft, isNotNull);
    expect(
      repository.lastSavedDraft!.routeDeviationCorridorMeters,
      320,
    );
    expect(repository.lastSavedDraft!.updatedBy, 'admin-1');
  });

  testWidgets('does not render removed overview section', (tester) async {
    final repository = _FakeOperationalMonitoringConfigRepository(
      initialConfig: OperationalMonitoringConfig(
        enabled: false,
        dropoffWaitingRadiusMeters: 250,
        postDropoffGracePeriodMinutes: 8,
        routeDeviationCorridorMeters: 300,
        sustainedDeviationThresholdSeconds: 180,
        activeTripVarianceToleranceKm: 1.5,
        activeTripVarianceTolerancePct: 12,
        postDropoffLocalMovementAllowanceKm: 0.5,
        postDropoffVarianceToleranceKm: 0.8,
        postDropoffVarianceTolerancePct: 18,
        noTripLocalMovementAllowanceKm: 1,
        noTripMovementGracePeriodMinutes: 10,
        nextAssignmentSuppressionLookaheadMinutes: 30,
        staleTelemetryThresholdSeconds: 180,
        incidentClearanceThresholdSeconds: 180,
        replaySampleMinDistanceMeters: 75,
        replaySampleMinIntervalSeconds: 30,
        approvalDestinationArrivalRadiusMeters: 300,
        hasBaseGeofence: true,
        serviceGeofenceCount: 2,
        updatedAt: DateTime(2026, 3, 29, 14, 45),
        updatedBy: 'admin-0',
      ),
    );
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          _FakeAuthRepository(userId: 'admin-1'),
        ),
        operationalMonitoringConfigRepositoryProvider.overrideWithValue(
          repository,
        ),
      ],
    );
    addTearDown(() async {
      await repository.dispose();
      container.dispose();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('pt', 'PT'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const OperationalMonitoringSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Geofences de contexto'), findsNothing);
    expect(
      find.text('Última atualização: 29/03/2026 14:45 por admin-0'),
      findsNothing,
    );
  });

  testWidgets('opens field explanation in bottom sheet', (tester) async {
    final repository = _FakeOperationalMonitoringConfigRepository(
      initialConfig: OperationalMonitoringConfig(
        enabled: false,
        dropoffWaitingRadiusMeters: 250,
        postDropoffGracePeriodMinutes: 8,
        routeDeviationCorridorMeters: 300,
        sustainedDeviationThresholdSeconds: 180,
        activeTripVarianceToleranceKm: 1.5,
        activeTripVarianceTolerancePct: 12,
        postDropoffLocalMovementAllowanceKm: 0.5,
        postDropoffVarianceToleranceKm: 0.8,
        postDropoffVarianceTolerancePct: 18,
        noTripLocalMovementAllowanceKm: 1,
        noTripMovementGracePeriodMinutes: 10,
        nextAssignmentSuppressionLookaheadMinutes: 30,
        staleTelemetryThresholdSeconds: 180,
        incidentClearanceThresholdSeconds: 180,
        replaySampleMinDistanceMeters: 75,
        replaySampleMinIntervalSeconds: 30,
        approvalDestinationArrivalRadiusMeters: 300,
        hasBaseGeofence: true,
        serviceGeofenceCount: 2,
        updatedBy: 'admin-0',
      ),
    );
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          _FakeAuthRepository(userId: 'admin-1'),
        ),
        operationalMonitoringConfigRepositoryProvider.overrideWithValue(
          repository,
        ),
      ],
    );
    addTearDown(() async {
      await repository.dispose();
      container.dispose();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('pt', 'PT'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const OperationalMonitoringSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final infoButton = find.byTooltip('Corredor de desvio da rota (m)');
    await tester.scrollUntilVisible(
      infoButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(infoButton);
    await tester.pumpAndSettle();
    await tester.tap(infoButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Distância máxima ao percurso esperado antes de iniciar contagem de desvio.',
      ),
      findsOneWidget,
    );
    expect(find.text('Intervalo permitido: 1 a 5000'), findsOneWidget);
  });
}

class _FakeOperationalMonitoringConfigRepository
    implements OperationalMonitoringConfigRepository {
  _FakeOperationalMonitoringConfigRepository({this.initialConfig})
    : _config = initialConfig;

  final OperationalMonitoringConfig? initialConfig;
  OperationalMonitoringConfig? _config;
  OperationalMonitoringConfigDraft? lastSavedDraft;
  final StreamController<OperationalMonitoringConfig?> _controller =
      StreamController<OperationalMonitoringConfig?>.broadcast();

  @override
  Future<OperationalMonitoringConfig?> fetchConfig() async => _config;

  @override
  Future<void> saveConfig(OperationalMonitoringConfigDraft draft) async {
    lastSavedDraft = draft;
    _config = OperationalMonitoringConfig(
      enabled: draft.enabled,
      dropoffWaitingRadiusMeters: draft.dropoffWaitingRadiusMeters,
      postDropoffGracePeriodMinutes: draft.postDropoffGracePeriodMinutes,
      routeDeviationCorridorMeters: draft.routeDeviationCorridorMeters,
      sustainedDeviationThresholdSeconds:
          draft.sustainedDeviationThresholdSeconds,
      activeTripVarianceToleranceKm: draft.activeTripVarianceToleranceKm,
      activeTripVarianceTolerancePct: draft.activeTripVarianceTolerancePct,
      postDropoffLocalMovementAllowanceKm:
          draft.postDropoffLocalMovementAllowanceKm,
      postDropoffVarianceToleranceKm: draft.postDropoffVarianceToleranceKm,
      postDropoffVarianceTolerancePct: draft.postDropoffVarianceTolerancePct,
      noTripLocalMovementAllowanceKm: draft.noTripLocalMovementAllowanceKm,
      noTripMovementGracePeriodMinutes: draft.noTripMovementGracePeriodMinutes,
      nextAssignmentSuppressionLookaheadMinutes:
          draft.nextAssignmentSuppressionLookaheadMinutes,
      staleTelemetryThresholdSeconds: draft.staleTelemetryThresholdSeconds,
      incidentClearanceThresholdSeconds:
          draft.incidentClearanceThresholdSeconds,
      replaySampleMinDistanceMeters: draft.replaySampleMinDistanceMeters,
      replaySampleMinIntervalSeconds: draft.replaySampleMinIntervalSeconds,
      approvalDestinationArrivalRadiusMeters:
          draft.approvalDestinationArrivalRadiusMeters,
      hasBaseGeofence: _config?.hasBaseGeofence ?? false,
      serviceGeofenceCount: _config?.serviceGeofenceCount ?? 0,
      updatedAt: DateTime(2026),
      updatedBy: draft.updatedBy,
    );
    _controller.add(_config);
  }

  @override
  Stream<OperationalMonitoringConfig?> watchConfig() async* {
    yield _config;
    yield* _controller.stream;
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.userId});

  final String? userId;

  @override
  String? currentUserId() => userId;

  @override
  String? currentUserEmail() => null;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ManagerPermissionsSnapshot> fetchManagerPermissions({
    bool forceRefresh = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ProfileRole> fetchProfileRole() async => ProfileRole.admin;

  @override
  Future<AuthStatus> fetchStatus() async =>
      const AuthStatus(isAvailable: true, role: ProfileRole.admin);

  @override
  Future<PasswordHelpRequestResult> requestPasswordHelp({
    required String emailOrLogin,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  Stream<AuthStatus> watchStatus() {
    return Stream<AuthStatus>.value(
      const AuthStatus(isAvailable: true, role: ProfileRole.admin),
    );
  }
}
