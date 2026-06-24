import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/local_notification_service.dart';
import '../flutter_local_notification_service.dart';

final localNotificationServiceImplementationProvider =
    Provider<LocalNotificationService>((ref) {
      return FlutterLocalNotificationService(
        FlutterLocalNotificationsPlugin(),
      );
    });
