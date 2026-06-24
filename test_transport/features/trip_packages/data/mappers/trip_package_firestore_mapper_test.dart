import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/trip_packages/data/mappers/trip_package_firestore_mapper.dart';

void main() {
  group('TripPackageFirestoreMapper', () {
    const mapper = TripPackageFirestoreMapper();

    test(
      'maps transport snapshots with package price multiplier basis points',
      () {
        final package = mapper.fromJson(<String, dynamic>{
          'name': 'Tarrafal',
          'photoUrl': 'https://example.com/tarrafal.jpg',
          'description': 'Praia e passeio.',
          'destination': <String, dynamic>{
            'latitude': 15.2788,
            'longitude': -23.7519,
            'address': 'Tarrafal',
          },
          'price': <String, dynamic>{
            'amountMinor': 2500,
            'currency': 'EUR',
          },
          'allowedTransportTypes': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'standard',
              'name': 'Standard',
              'packagePriceMultiplierBasisPoints': 10000,
            },
            <String, dynamic>{
              'id': 'van',
              'name': 'Van',
              'packagePriceMultiplierBasisPoints': 12500,
            },
          ],
          'isActive': true,
          'snapshotVersion': 2,
        }, id: 'package-1');

        expect(
          package.allowedTransportTypes.first.packagePriceMultiplierBasisPoints,
          10000,
        );
        expect(
          package.allowedTransportTypes.last.packagePriceMultiplierBasisPoints,
          12500,
        );

        final serialized = mapper.transportSnapshotToJson(
          package.allowedTransportTypes.last,
        );
        expect(serialized['packagePriceMultiplierBasisPoints'], 12500);
      },
    );

    test('defaults legacy transport snapshots to the neutral multiplier', () {
      final package = mapper.fromJson(<String, dynamic>{
        'name': 'Tarrafal',
        'photoUrl': 'https://example.com/tarrafal.jpg',
        'description': 'Praia e passeio.',
        'destination': <String, dynamic>{
          'latitude': 15.2788,
          'longitude': -23.7519,
          'address': 'Tarrafal',
        },
        'price': <String, dynamic>{
          'amountMinor': 2500,
          'currency': 'EUR',
        },
        'allowedTransportTypes': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'standard',
            'name': 'Standard',
          },
        ],
        'isActive': true,
        'snapshotVersion': 2,
      }, id: 'package-1');

      expect(
        package.allowedTransportTypes.single.packagePriceMultiplierBasisPoints,
        10000,
      );
    });
  });
}
