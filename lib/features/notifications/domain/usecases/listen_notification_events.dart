import '../entities/notification_event.dart';
import '../repositories/notification_event_repository.dart';

class ListenNotificationEvents {
  const ListenNotificationEvents(this._repository);

  final NotificationEventRepository _repository;

  Stream<NotificationEvent> call() {
    return _repository.watchEvents();
  }
}
