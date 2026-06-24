import 'dart:async';
import 'dart:collection';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_ent_280/core/data/firebase/messaging_service.dart';
import 'package:local_ent_280/core/data/firebase/providers/messaging_service_provider.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/navigation/app_navigator_key.dart';
import 'package:local_ent_280/features/notifications/data/mappers/notification_event_mapper.dart';
import 'package:local_ent_280/features/notifications/domain/entities/notification_event.dart';
import 'package:local_ent_280/features/notifications/presentation/notification_open_route_resolver.dart';
import 'package:local_ent_280/features/notifications/presentation/notification_open_target.dart';

class NotificationOpenListener extends ConsumerStatefulWidget {
  const NotificationOpenListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationOpenListener> createState() {
    return _NotificationOpenListenerState();
  }
}

class _NotificationOpenListenerState
    extends ConsumerState<NotificationOpenListener> {
  static const _routeResolver = NotificationOpenRouteResolver();

  final _mapper = NotificationEventMapper();
  final _handledMessagesCache = NotificationHandledMessageCache(maxSize: 200);
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  @override
  void initState() {
    super.initState();
    final messagingService = ref.read(messagingServiceProvider);
    _openedAppSubscription = messagingService.onMessageOpenedApp.listen(
      _handleMessage,
      onError: _handleError,
    );
    unawaited(_consumeInitialMessage(messagingService));
  }

  @override
  void dispose() {
    _openedAppSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  Future<void> _consumeInitialMessage(MessagingService messagingService) async {
    try {
      final message = await messagingService.getInitialMessage();
      if (message == null || !mounted) {
        return;
      }
      _handleMessage(message);
    } catch (error, stackTrace) {
      _handleError(error, stackTrace);
    }
  }

  void _handleMessage(RemoteMessage message) {
    if (!mounted) {
      return;
    }
    final event = _mapper.fromRemoteMessage(message);
    final target = _routeResolver.resolve(event);
    if (target == null) {
      return;
    }
    final messageKey = _messageKey(message, event);
    if (!_handledMessagesCache.register(messageKey)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _navigateToTarget(target);
    });
  }

  void _navigateToTarget(NotificationOpenTarget target) {
    final context = AppNavigatorKey.root.currentContext;
    if (context == null) {
      return;
    }
    switch (target) {
      case NotificationOpenTarget.driverHome:
        AppNavigation.toDriverHome(context);
      case NotificationOpenTarget.clientHome:
        AppNavigation.toHomeAfterLogin(context);
      case NotificationOpenTarget.adminSupportRequests:
        AppNavigation.toAdminSupportRequests(context);
    }
  }

  String _messageKey(RemoteMessage message, NotificationEvent event) {
    final tripId = event.data['tripId']?.toString();
    final requestId = event.data['requestId']?.toString();
    final threadId = event.data['threadId']?.toString();
    return message.messageId ??
        '${event.type.name}|${threadId ?? 'sem-thread'}|'
            '${requestId ?? 'sem-ticket'}|${tripId ?? 'sem-trip'}|'
            '${message.sentTime?.millisecondsSinceEpoch ?? 0}';
  }

  void _handleError(Object error, StackTrace stackTrace) {
    debugPrint('NotificationOpenListener: erro ao processar abertura push.');
    debugPrint('$error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class NotificationHandledMessageCache {
  NotificationHandledMessageCache({required this.maxSize});

  final int maxSize;
  final Set<String> _keys = <String>{};
  final Queue<String> _order = ListQueue<String>();

  bool register(String key) {
    if (!_keys.add(key)) {
      return false;
    }
    _order.addLast(key);
    while (_order.length > maxSize) {
      final evicted = _order.removeFirst();
      _keys.remove(evicted);
    }
    return true;
  }
}
