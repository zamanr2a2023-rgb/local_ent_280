import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/app/presentation/navigation/app_routes.dart';

void main() {
  group('AppRoutes operational incidents', () {
    test('builds and parses admin incident detail route', () {
      final route = AppRoutes.adminOperationalIncidentDetail('incident_123');

      expect(route, '/admin/operational-incidents/incident_123');
      expect(
        AppRoutes.parseAdminOperationalIncidentDetail(route),
        'incident_123',
      );
    });

    test('builds and parses manager incident detail route', () {
      final route = AppRoutes.managerOperationalIncidentDetail('incident_456');

      expect(route, '/manager/operational-incidents/incident_456');
      expect(
        AppRoutes.parseManagerOperationalIncidentDetail(route),
        'incident_456',
      );
    });

    test('returns null when operational incident route is invalid', () {
      expect(
        AppRoutes.parseAdminOperationalIncidentDetail(
          '/admin/operational-incidents/',
        ),
        isNull,
      );
      expect(
        AppRoutes.parseManagerOperationalIncidentDetail(
          '/manager/trips/trip_1',
        ),
        isNull,
      );
      expect(AppRoutes.parseAdminOperationalIncidentDetail(null), isNull);
    });
  });

  group('AppRoutes support request chat', () {
    test('builds and parses support request chat route', () {
      final route = AppRoutes.supportRequestChat('request_123');

      expect(route, '/ops/support-requests/request_123');
      expect(AppRoutes.parseSupportRequestChat(route), 'request_123');
    });

    test('returns null when support request chat route is invalid', () {
      expect(
        AppRoutes.parseSupportRequestChat('/ops/support-requests/'),
        isNull,
      );
      expect(
        AppRoutes.parseSupportRequestChat('/ops/chats/request_123'),
        isNull,
      );
      expect(AppRoutes.parseSupportRequestChat(null), isNull);
    });
  });
}
