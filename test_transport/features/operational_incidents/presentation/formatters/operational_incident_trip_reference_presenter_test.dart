import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/operational_incidents/presentation/formatters/operational_incident_trip_reference_presenter.dart';

void main() {
  const presenter = OperationalIncidentTripReferencePresenter();

  group('OperationalIncidentTripReferencePresenter', () {
    test('returns localized fallback when trip id is empty', () {
      final result = presenter.present(
        tripId: '  ',
        noTripLabel: 'Sem viagem',
      );

      expect(result, 'Sem viagem');
    });

    test('keeps full trip ids readable', () {
      final result = presenter.present(
        tripId: 'trip_1234567890',
        noTripLabel: 'Sem viagem',
      );

      expect(result, 'trip_1234567890');
    });

    test('keeps short trip ids readable', () {
      final result = presenter.present(
        tripId: 'TRIP-42',
        noTripLabel: 'Sem viagem',
      );

      expect(result, 'TRIP-42');
    });

    test('maps seeded active trip ids to user friendly labels', () {
      final result = presenter.present(
        tripId: 'trip_ops_route_deviation',
        noTripLabel: 'Sem viagem',
      );

      expect(result, 'Viagem ativa');
    });

    test('maps seeded post drop-off ids to user friendly labels', () {
      final result = presenter.present(
        tripId: 'trip_ops_post_dropoff',
        noTripLabel: 'Sem viagem',
      );

      expect(result, 'Pós-drop-off');
    });

    test('humanizes unknown technical trip ids', () {
      final result = presenter.present(
        tripId: 'trip_ops_false_positive',
        noTripLabel: 'Sem viagem',
      );

      expect(result, 'Falso positivo');
    });
  });
}
