import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_ent_280/features/notifications/application/providers/notification_domain_providers.dart';
import '../firebase_messaging_initializer.dart';
import 'messaging_service_provider.dart';

final firebaseMessagingInitializerProvider =
    Provider<FirebaseMessagingInitializer>((ref) {
      final initializer = FirebaseMessagingInitializer(
        ref.watch(messagingServiceProvider),
        ref.watch(registerNotificationTokenProvider),
        FirebaseAuth.instance,
      );
      ref.onDispose(initializer.dispose);
      return initializer;
    });
