import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class MessagingService {
  MessagingService(this._messaging);

  final FirebaseMessaging _messaging;

  Future<String?> getToken() async {
    debugPrint('MessagingService: a obter token de push.');
    try {
      final token = await _messaging.getToken();
      if (token == null) {
        debugPrint('MessagingService: token indisponível.');
        return null;
      }
      debugPrint('MessagingService: token recebido.');
      return token;
    } catch (error, stackTrace) {
      developer.log(
        'Falha ao obter token FCM. A app continuará sem push neste dispositivo.',
        name: 'MessagingService',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Stream<String> get onTokenRefresh {
    return _messaging.onTokenRefresh.map((token) {
      debugPrint('MessagingService: token atualizado.');
      return token;
    });
  }

  Stream<RemoteMessage> get onMessage {
    return FirebaseMessaging.onMessage.map((message) {
      debugPrint(
        'MessagingService: mensagem recebida (${message.messageId ?? "sem ID"}).',
      );
      return message;
    });
  }

  Stream<RemoteMessage> get onMessageOpenedApp {
    return FirebaseMessaging.onMessageOpenedApp.map((message) {
      debugPrint(
        'MessagingService: notificação abriu a app '
        '(${message.messageId ?? "sem ID"}).',
      );
      return message;
    });
  }

  Future<RemoteMessage?> getInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message == null) {
      debugPrint('MessagingService: arranque sem notificação pendente.');
      return null;
    }
    debugPrint(
      'MessagingService: arranque provocado por notificação '
      '(${message.messageId ?? "sem ID"}).',
    );
    return message;
  }

  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission();
    debugPrint(
      'MessagingService: permissões = ${settings.authorizationStatus}.',
    );
    return settings;
  }

  Future<void> setForegroundPresentationOptions() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    debugPrint('MessagingService: token apagado.');
  }
}
