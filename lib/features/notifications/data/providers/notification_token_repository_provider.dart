import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_ent_280/core/data/firebase/providers/messaging_service_provider.dart';
import '../../domain/repositories/notification_token_repository.dart';
import '../repositories/notification_token_repository_impl.dart';

final notificationTokenRepositoryImplementationProvider =
    Provider<NotificationTokenRepository>((ref) {
      return NotificationTokenRepositoryImpl(
        FirebaseFirestore.instance,
        ref.watch(messagingServiceProvider),
      );
    });
