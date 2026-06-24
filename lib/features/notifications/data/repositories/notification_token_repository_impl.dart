import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:local_ent_280/core/data/firebase/messaging_service.dart';
import '../../domain/repositories/notification_token_repository.dart';

class NotificationTokenRepositoryImpl implements NotificationTokenRepository {
  NotificationTokenRepositoryImpl(
    this._firestore,
    this._messagingService,
  );

  static const int _tokenTtlDays = 60;

  final FirebaseFirestore _firestore;
  final MessagingService _messagingService;

  @override
  Future<void> registerToken({
    required String token,
    required String userId,
  }) async {
    const appVersion = String.fromEnvironment('APP_VERSION');
    final platform = _resolvePlatform();
    final tokenPath = 'users/$userId/fcmTokens/$token';
    developer.log(
      'A registar token de notificações para $userId em $tokenPath.',
      name: 'NotificationTokenRepositoryImpl',
    );
    await _firestore.doc(tokenPath).set(
      <String, dynamic>{
        'token': token,
        'platform': platform,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastSeenAt': FieldValue.serverTimestamp(),
        'enabled': true,
        'tokenExpiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: _tokenTtlDays)),
        ),
        if (appVersion.isNotEmpty) 'appVersion': appVersion,
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> removeCurrentToken({required String userId}) async {
    final token = await _messagingService.getToken();
    if (token == null) {
      return;
    }

    final tokenPath = 'users/$userId/fcmTokens/$token';
    try {
      await _firestore.doc(tokenPath).update(<String, dynamic>{
        'enabled': false,
        'updatedAt': FieldValue.serverTimestamp(),
        'tokenExpiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: _tokenTtlDays)),
        ),
      });
    } catch (error, stackTrace) {
      developer.log(
        'Falha ao desativar token em Firestore.',
        name: 'NotificationTokenRepositoryImpl',
        error: error,
        stackTrace: stackTrace,
      );
    }

    try {
      await _messagingService.deleteToken();
    } catch (error, stackTrace) {
      developer.log(
        'Falha ao remover token no MessagingService.',
        name: 'NotificationTokenRepositoryImpl',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  String _resolvePlatform() {
    if (kIsWeb) {
      return 'web';
    }
    return defaultTargetPlatform.name;
  }
}
