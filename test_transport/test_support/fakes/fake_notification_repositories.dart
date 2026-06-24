import 'dart:async';

import 'package:local_transport/features/notifications/domain/entities/notification_event.dart';
import 'package:local_transport/features/notifications/domain/repositories/notification_event_repository.dart';
import 'package:local_transport/features/notifications/domain/repositories/notification_token_repository.dart';

class FakeNotificationEventRepository implements NotificationEventRepository {
  final StreamController<NotificationEvent> _controller =
      StreamController<NotificationEvent>.broadcast();

  @override
  Stream<NotificationEvent> watchEvents() => _controller.stream;

  void emit(NotificationEvent event) {
    _controller.add(event);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

class FakeNotificationTokenRepository implements NotificationTokenRepository {
  final List<String> registeredTokens = <String>[];
  final List<String> removedUserIds = <String>[];

  @override
  Future<void> registerToken({
    required String token,
    required String userId,
  }) async {
    registeredTokens.add('$userId:$token');
  }

  @override
  Future<void> removeCurrentToken({required String userId}) async {
    removedUserIds.add(userId);
  }
}
