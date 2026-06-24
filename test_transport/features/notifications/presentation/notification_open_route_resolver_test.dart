import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/app/presentation/navigation/app_routes.dart';
import 'package:local_transport/features/notifications/domain/entities/notification_event.dart';
import 'package:local_transport/features/notifications/domain/entities/notification_event_type.dart';
import 'package:local_transport/features/notifications/presentation/notification_open_route_resolver.dart';

void main() {
  group('NotificationOpenRouteResolver', () {
    const resolver = NotificationOpenRouteResolver();

    test('abre dashboard do motorista para nova viagem atribuída', () {
      const event = NotificationEvent(
        type: NotificationEventType.driverNewTripAssigned,
        data: <String, String>{'tripId': 'trip-1'},
      );

      expect(resolver.resolve(event), AppRoutes.driverHome);
    });

    test('abre chat da viagem do cliente para mensagem do motorista', () {
      const event = NotificationEvent(
        type: NotificationEventType.clientTripChatMessage,
        data: <String, String>{'tripId': 'trip-1'},
      );

      expect(resolver.resolve(event), AppRoutes.clientTripChat);
    });

    test('abre suporte do cliente para mensagem de suporte', () {
      const event = NotificationEvent(
        type: NotificationEventType.clientSupportChatMessage,
        data: <String, String>{
          'threadId': 'support_request_request-1',
          'requestId': 'request-1',
        },
      );

      expect(
        resolver.resolve(event),
        AppRoutes.supportRequestChat('request-1'),
      );
    });

    test('abre ticket de suporte operacional quando push inclui requestId', () {
      const event = NotificationEvent(
        type: NotificationEventType.opsChatMessage,
        data: <String, String>{
          'threadId': 'support_request_request-1',
          'requestId': 'request-1',
        },
      );

      expect(
        resolver.resolve(event),
        AppRoutes.supportRequestChat('request-1'),
      );
    });

    test('abre ticket quando push de novo ticket inclui requestId', () {
      const event = NotificationEvent(
        type: NotificationEventType.opsSupportTicket,
        data: <String, String>{
          'threadId': 'support_request_request-1',
          'requestId': 'request-1',
        },
      );

      expect(
        resolver.resolve(event),
        AppRoutes.supportRequestChat('request-1'),
      );
    });

    test(
      'abre lista de tickets quando push de novo ticket não inclui requestId',
      () {
        const event = NotificationEvent(
          type: NotificationEventType.opsSupportTicket,
          data: <String, String>{},
        );

        expect(resolver.resolve(event), AppRoutes.supportRequests);
      },
    );
  });
}
