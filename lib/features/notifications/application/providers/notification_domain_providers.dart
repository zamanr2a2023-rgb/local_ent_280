import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/notification_event_repository.dart';
import '../../domain/repositories/notification_token_repository.dart';
import '../../domain/usecases/listen_notification_events.dart';
import '../../domain/usecases/register_notification_token.dart';
import '../../domain/usecases/remove_notification_token.dart';

final notificationTokenRepositoryProvider =
    Provider<NotificationTokenRepository>((ref) {
      throw UnimplementedError(
        'NotificationTokenRepository deve ser fornecido.',
      );
    });

final notificationEventRepositoryProvider =
    Provider<NotificationEventRepository>((ref) {
      throw UnimplementedError(
        'NotificationEventRepository deve ser fornecido.',
      );
    });

final registerNotificationTokenProvider = Provider<RegisterNotificationToken>((
  ref,
) {
  return RegisterNotificationToken(
    ref.watch(notificationTokenRepositoryProvider),
  );
});

final removeNotificationTokenProvider = Provider<RemoveNotificationToken>((
  ref,
) {
  return RemoveNotificationToken(
    ref.watch(notificationTokenRepositoryProvider),
  );
});

final listenNotificationEventsProvider = Provider<ListenNotificationEvents>((
  ref,
) {
  return ListenNotificationEvents(
    ref.watch(notificationEventRepositoryProvider),
  );
});
