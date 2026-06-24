import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/notifications/data/mappers/notification_event_mapper.dart';
import 'package:local_transport/features/notifications/domain/entities/notification_event_type.dart';

void main() {
  group('NotificationEventMapper', () {
    final mapper = NotificationEventMapper();

    test('maps package client events from the new contract', () {
      final event = mapper.fromRemoteMessage(
        RemoteMessage.fromMap(<String, dynamic>{
          'data': <String, dynamic>{
            'type': 'client.package_booking_pending_approval',
          },
        }),
      );

      expect(
        event.type,
        NotificationEventType.clientPackageBookingPendingApproval,
      );
    });

    test('maps package ops events from the new contract', () {
      final event = mapper.fromRemoteMessage(
        RemoteMessage.fromMap(<String, dynamic>{
          'data': <String, dynamic>{
            'type': 'ops.package_booking_activation_failed',
          },
        }),
      );

      expect(
        event.type,
        NotificationEventType.opsPackageBookingActivationFailed,
      );
    });

    test('maps support ticket ops event from the new contract', () {
      final event = mapper.fromRemoteMessage(
        RemoteMessage.fromMap(<String, dynamic>{
          'data': <String, dynamic>{
            'type': 'ops.support_ticket',
            'requestId': 'request-1',
          },
        }),
      );

      expect(event.type, NotificationEventType.opsSupportTicket);
      expect(event.data['requestId'], 'request-1');
    });

    test('maps package driver events from the new contract', () {
      final event = mapper.fromRemoteMessage(
        RemoteMessage.fromMap(<String, dynamic>{
          'data': <String, dynamic>{
            'type': 'driver.package_booking_assigned',
          },
        }),
      );

      expect(
        event.type,
        NotificationEventType.driverPackageBookingAssigned,
      );
    });
  });
}
