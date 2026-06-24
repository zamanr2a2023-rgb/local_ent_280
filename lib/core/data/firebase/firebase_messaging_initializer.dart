import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:local_ent_280/features/auth/data/user_session.dart';
import 'package:local_ent_280/features/notifications/domain/usecases/register_notification_token.dart';
import 'messaging_service.dart';

class FirebaseMessagingInitializer {
  FirebaseMessagingInitializer(
    this._messagingService,
    this._registerNotificationToken,
    this._auth,
  );

  final MessagingService _messagingService;
  final RegisterNotificationToken _registerNotificationToken;
  final FirebaseAuth _auth;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<User?>? _authSubscription;
  String? _currentToken;
  String? _lastRegisteredUserId;
  String? _lastRegisteredToken;
  bool _sessionListenerAttached = false;

  Future<void> initialize() async {
    developer.log(
      'A iniciar configuração de notificações.',
      name: 'FirebaseMessagingInitializer',
    );
    final needsRuntimePermission =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
    if (needsRuntimePermission) {
      await _messagingService.requestPermission();
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _messagingService.setForegroundPresentationOptions();
    }

    _currentToken = await _messagingService.getToken();
    if (_currentToken != null) {
      await _registerTokenForCurrentUser(_currentToken!);
    }

    _tokenSubscription ??= _messagingService.onTokenRefresh.listen((token) {
      unawaited(_handleTokenRefresh(token));
    });

    _authSubscription ??= _auth.authStateChanges().listen((_) {
      unawaited(_handleAuthStatusChanged());
    });

    if (!_sessionListenerAttached) {
      UserSession.instance.addListener(_onSessionChanged);
      _sessionListenerAttached = true;
    }
  }

  void _onSessionChanged() {
    unawaited(_handleAuthStatusChanged());
  }

  String? _currentUserId() {
    return UserSession.instance.profile?.uid ?? _auth.currentUser?.uid;
  }

  Future<void> _registerTokenForCurrentUser(String token) async {
    final userId = _currentUserId();
    if (userId == null || userId.isEmpty) {
      return;
    }
    if (_lastRegisteredUserId == userId && _lastRegisteredToken == token) {
      return;
    }
    await _registerNotificationToken(token: token, userId: userId);
    _lastRegisteredUserId = userId;
    _lastRegisteredToken = token;
  }

  Future<void> _handleTokenRefresh(String token) async {
    _currentToken = token;
    try {
      await _registerTokenForCurrentUser(token);
    } catch (error, stackTrace) {
      developer.log(
        'Falha ao registar token renovado.',
        name: 'FirebaseMessagingInitializer',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _handleAuthStatusChanged() async {
    final userId = _currentUserId();
    if (userId == null || userId.isEmpty) {
      _currentToken = null;
      _lastRegisteredUserId = null;
      _lastRegisteredToken = null;
      return;
    }
    _currentToken ??= await _messagingService.getToken();
    if (_currentToken == null) {
      return;
    }
    try {
      await _registerTokenForCurrentUser(_currentToken!);
    } catch (error, stackTrace) {
      developer.log(
        'Falha ao registar token após autenticação.',
        name: 'FirebaseMessagingInitializer',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void dispose() {
    _tokenSubscription?.cancel();
    _tokenSubscription = null;
    _authSubscription?.cancel();
    _authSubscription = null;
    if (_sessionListenerAttached) {
      UserSession.instance.removeListener(_onSessionChanged);
      _sessionListenerAttached = false;
    }
  }
}
