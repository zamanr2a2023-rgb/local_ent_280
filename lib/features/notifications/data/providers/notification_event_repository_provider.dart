import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_ent_280/core/data/firebase/providers/messaging_service_provider.dart';
import '../../domain/repositories/notification_event_repository.dart';
import '../mappers/notification_event_mapper.dart';
import '../repositories/notification_event_repository_impl.dart';

final notificationEventRepositoryImplementationProvider =
    Provider<NotificationEventRepository>((ref) {
      return NotificationEventRepositoryImpl(
        ref.watch(messagingServiceProvider),
        NotificationEventMapper(),
      );
    });
