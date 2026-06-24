import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local_transport/features/operational_incidents/domain/entities/operational_location_sample.dart';
import 'package:local_transport/features/operational_incidents/presentation/formatters/operational_incident_map_route_resolver.dart';

void main() {
  const resolver = OperationalIncidentMapRouteResolver();
  final origin = OperationalLocationSample(
    latitude: 38.7223,
    longitude: -9.1393,
    recordedAt: DateTime.parse('2026-03-30T13:00:00Z'),
  );
  final latest = OperationalLocationSample(
    latitude: 38.7486,
    longitude: -9.1542,
    recordedAt: DateTime.parse('2026-03-30T14:16:00Z'),
  );

  group('OperationalIncidentMapRouteResolver', () {
    test('keeps encoded routes that stay near the incident area', () {
      final points = resolver.resolveExpectedRoute(
        encodedPolyline: 'k}ikFr_xv@kcDb|A',
        origin: origin,
        latest: latest,
      );

      expect(points, hasLength(2));
      expect(points.first, const LatLng(38.7223, -9.1393));
      expect(points.last, const LatLng(38.7486, -9.1542));
    });

    test('rejects placeholder values that decode far from the incident', () {
      final points = resolver.resolveExpectedRoute(
        encodedPolyline: 'demo-active-trip-route',
        origin: origin,
        latest: latest,
      );

      expect(points, isEmpty);
    });
  });
}
