import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/client/data/mappers/transport_type_firestore_mapper.dart';

void main() {
  group('TransportTypeFirestoreMapper', () {
    const mapper = TransportTypeFirestoreMapper();

    test(
      'maps packagePriceMultiplierBasisPoints from transport type document',
      () {
        final transportType = mapper.fromJson(<String, dynamic>{
          'name': 'Van',
          'description': 'Carrinha para grupo',
          'packagePriceMultiplierBasisPoints': 12500,
        }, id: 'van');

        expect(transportType.id, 'van');
        expect(transportType.packagePriceMultiplierBasisPoints, 12500);
      },
    );
  });
}
