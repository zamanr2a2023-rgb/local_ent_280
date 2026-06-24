import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:local_transport/core/services/analytics_service.dart';
import 'package:local_transport/core/services/connectivity_service.dart';
import 'package:local_transport/core/services/crash_reporting_service.dart';
import 'package:local_transport/core/services/screen_awake_service.dart';

class FakeAnalyticsService implements AnalyticsService {
  final List<String> screenViews = <String>[];

  String? currentUserId;
  String? currentUserRole;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> clearUser() async {
    currentUserId = null;
    currentUserRole = null;
  }

  @override
  Future<void> logLogin({required String method}) async {}

  @override
  Future<void> logLogout() async {}

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    screenViews.add(screenName);
  }

  @override
  Future<void> setUser({
    required String userId,
    required String userRole,
  }) async {
    currentUserId = userId;
    currentUserRole = userRole;
  }
}

class FakeCrashReportingService implements CrashReportingService {
  final List<String> logs = <String>[];
  final List<Object> recordedErrors = <Object>[];

  String? currentUserId;
  String? currentUserRole;

  @override
  Future<void> clearUser() async {
    currentUserId = null;
    currentUserRole = null;
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> log(String message) async {
    logs.add(message);
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    recordedErrors.add(error);
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    recordedErrors.add(details.exception);
  }

  @override
  Future<void> recordFlutterFatalError(FlutterErrorDetails details) async {
    recordedErrors.add(details.exception);
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {}

  @override
  Future<void> setUser({
    required String userId,
    required String userRole,
  }) async {
    currentUserId = userId;
    currentUserRole = userRole;
  }
}

class FakeConnectivityService implements ConnectivityService {
  FakeConnectivityService({bool isOnline = true}) : _isOnline = isOnline;

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _isOnline;

  @override
  bool get isOnline => _isOnline;

  @override
  Stream<bool> get onConnectivityChanged async* {
    yield _isOnline;
    yield* _controller.stream;
  }

  void setOnline(bool value) {
    if (_isOnline == value) {
      return;
    }
    _isOnline = value;
    _controller.add(value);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

class FakeScreenAwakeService implements ScreenAwakeService {
  bool isEnabled = false;

  @override
  Future<void> setEnabled(bool enabled) async {
    isEnabled = enabled;
  }
}
