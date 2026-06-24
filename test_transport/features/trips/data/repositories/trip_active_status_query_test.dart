import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/trips/data/repositories/trip_active_status_query.dart';

void main() {
  test('driver active status query excludes waiting acceptance', () {
    expect(
      TripActiveStatusQuery.driverStatuses,
      isNot(contains('DRIVER_ASSIGNED_WAITING_ACCEPTANCE')),
    );
    expect(
      TripActiveStatusQuery.driverStatuses,
      containsAll(<String>[
        'DRIVER_ACCEPTED',
        'DRIVER_EN_ROUTE',
        'DRIVER_ARRIVED',
        'IN_TRIP',
        'ARRIVED_DESTINATION',
        'EXTENSION_WINDOW',
      ]),
    );
  });

  test('client active status query keeps pending and assigned states', () {
    expect(
      TripActiveStatusQuery.clientStatuses,
      containsAll(<String>[
        'REQUESTED',
        'DRIVER_ASSIGNED_WAITING_ACCEPTANCE',
        'DRIVER_ACCEPTED',
        'DRIVER_EN_ROUTE',
      ]),
    );
  });
}
