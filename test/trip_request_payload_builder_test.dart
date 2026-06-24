import 'package:flutter_test/flutter_test.dart';
import 'package:local_ent_280/core/services/client_tariff_service.dart';
import 'package:local_ent_280/features/trips/data/models/trip_location.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';
import 'package:local_ent_280/features/trips/data/trip_request_payload_builder.dart';

void main() {
  test('TripRequestPayloadBuilder includes requestTrip pricing snapshot', () {
    const builder = TripRequestPayloadBuilder();
    const tariff = ClientTariff(
      id: 'public_default',
      baseByTransportType: {'premium': 250},
      perKmMinor: 120,
      perWaitMinuteMinor: 10,
      lateCancellationMinor: 0,
      noShowMinor: 0,
      distanceTiers: [
        {
          'startMetersInclusive': 0,
          'perKm': {'amountMinor': 120, 'currency': 'EUR'},
        },
      ],
      multiplierRules: [],
    );

    final payload = builder.build(
      clientId: 'client-1',
      pickup: const TripLocation(
        address: 'Pickup',
        latitude: 38.72,
        longitude: -9.14,
      ),
      destination: const TripLocation(
        address: 'Destination',
        latitude: 38.73,
        longitude: -9.15,
      ),
      transportType: const TripTransportType(id: 'premium', name: 'Premium'),
      tariff: tariff,
      distanceKm: 5,
      durationMinutes: 12,
      estimatedTotalMinor: 850,
    );

    expect(payload['status'], 'REQUESTED');
    expect(payload['clientId'], 'client-1');
    final pricing = payload['pricingSnapshot'] as Map<String, dynamic>;
    expect(pricing['estimatedTotal'], {
      'amountMinor': 850,
      'currency': 'EUR',
    });
    expect(pricing['base'], {'amountMinor': 250, 'currency': 'EUR'});
    final metering = payload['meteringSnapshot'] as Map<String, dynamic>;
    expect(metering['totalDistanceKm'], 5);
    expect(metering['estimatedCostMinor'], 850);
  });
}
