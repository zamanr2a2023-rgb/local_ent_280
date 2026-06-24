import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../messaging_service.dart';

final messagingServiceProvider = Provider<MessagingService>((ref) {
  return MessagingService(FirebaseMessaging.instance);
});
