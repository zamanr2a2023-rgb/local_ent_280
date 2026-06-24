import 'dart:developer' as developer;

import 'package:local_ent_280/core/data/firebase/messaging_service.dart';
import '../../domain/entities/notification_event.dart';
import '../../domain/repositories/notification_event_repository.dart';
import '../mappers/notification_event_mapper.dart';

class NotificationEventRepositoryImpl implements NotificationEventRepository {
  NotificationEventRepositoryImpl(this._messagingService, this._mapper);

  final MessagingService _messagingService;
  final NotificationEventMapper _mapper;

  @override
  Stream<NotificationEvent> watchEvents() {
    developer.log(
      'A escutar notificações em primeiro plano.',
      name: 'NotificationEventRepositoryImpl',
    );
    return _messagingService.onMessage.map(_mapper.fromRemoteMessage);
  }
}
