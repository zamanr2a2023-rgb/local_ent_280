import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../services/local_notification_service.dart';

class FlutterLocalNotificationService implements LocalNotificationService {
  FlutterLocalNotificationService(this._plugin);

  static const String _channelId = 'local_transport_alertas';
  static const String _channelName = 'Alertas Local Transport';
  static const String _channelDescription =
      'Notificacoes de viagens e mensagens operacionais.';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;
  int _nextNotificationId = 1;

  @override
  Future<void> initialize() async {
    if (_isInitialized || kIsWeb) {
      return;
    }
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings),
    );
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
      ),
    );
    _isInitialized = true;
    developer.log(
      'Notificacoes locais preparadas para foreground.',
      name: 'FlutterLocalNotificationService',
    );
  }

  @override
  Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) {
      return;
    }
    if (!_isInitialized) {
      await initialize();
    }
    if (title.trim().isEmpty && body.trim().isEmpty) {
      return;
    }
    await _plugin.show(
      _nextNotificationId++,
      title.trim().isEmpty ? null : title,
      body.trim().isEmpty ? null : body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.message,
        ),
      ),
      payload: payload,
    );
  }
}
