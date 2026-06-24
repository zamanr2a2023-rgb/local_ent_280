import 'notification_event_type.dart';

class NotificationEvent {
  const NotificationEvent({
    required this.type,
    required this.data,
    this.title,
    this.body,
  });

  final NotificationEventType type;
  final Map<String, String> data;
  final String? title;
  final String? body;

  bool get hasFallbackContent {
    return (title != null && title!.isNotEmpty) ||
        (body != null && body!.isNotEmpty);
  }
}
