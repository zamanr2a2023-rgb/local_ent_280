import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:local_ent_280/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FirebaseMessagingBackgroundHandler: mensagem recebida.');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint(
    'FirebaseMessagingBackgroundHandler: mensagem ${message.messageId ?? "sem ID"} '
    'com ${message.data.length} campos de dados.',
  );
}

void registerFirebaseMessagingBackgroundHandler() {
  debugPrint('FirebaseMessagingBackgroundHandler: a registar handler.');
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}
