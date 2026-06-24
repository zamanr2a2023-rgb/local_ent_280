import '../entities/notification_event.dart';

abstract interface class NotificationEventRepository {
  Stream<NotificationEvent> watchEvents();
}
