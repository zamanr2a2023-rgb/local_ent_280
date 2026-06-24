import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/services/preferences/destination_preference_entry.dart';
import 'package:local_transport/core/services/preferences/recent_destinations_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RecentDestinationsPreferencesService service;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    service = RecentDestinationsPreferencesService();
  });

  test('writes and reads failed destination per client', () async {
    const destination = DestinationPreferenceEntry(
      latitude: 14.9177,
      longitude: -23.5092,
      formattedAddress: 'Palmarejo',
    );

    await service.writeFailedDestination(
      clientId: 'client-1',
      destination: destination,
    );

    final persisted = await service.readFailedDestination('client-1');
    final otherClient = await service.readFailedDestination('client-2');

    expect(persisted?.formattedAddress, 'Palmarejo');
    expect(persisted?.latitude, 14.9177);
    expect(otherClient, isNull);
  });

  test('saves, deduplicates, and removes favorites', () async {
    const destination = DestinationPreferenceEntry(
      latitude: 38.7223,
      longitude: -9.1393,
      formattedAddress: '  Lisboa   Centro  ',
    );
    const normalizedDuplicate = DestinationPreferenceEntry(
      latitude: 38.7223,
      longitude: -9.1393,
      formattedAddress: 'lisboa centro',
    );

    await service.saveFavoriteDestination(
      clientId: 'client-1',
      destination: destination,
    );
    await service.saveFavoriteDestination(
      clientId: 'client-1',
      destination: normalizedDuplicate,
    );

    final favorites = await service.readFavoriteDestinations('client-1');
    expect(favorites, hasLength(1));
    expect(favorites.single.formattedAddress, 'lisboa centro');

    await service.removeFavoriteDestination(
      clientId: 'client-1',
      destinationKey: service.destinationKey(normalizedDuplicate),
    );

    expect(await service.readFavoriteDestinations('client-1'), isEmpty);
  });

  test(
    'saves selected destinations with latest first and per client',
    () async {
      const first = DestinationPreferenceEntry(
        latitude: 14.9177,
        longitude: -23.5092,
        formattedAddress: 'Palmarejo',
      );
      const second = DestinationPreferenceEntry(
        latitude: 14.914,
        longitude: -23.516,
        formattedAddress: 'Chã de Areia',
      );
      const firstDuplicate = DestinationPreferenceEntry(
        latitude: 14.9177,
        longitude: -23.5092,
        formattedAddress: '  palmarejo  ',
      );

      await service.saveSelectedDestination(
        clientId: 'client-1',
        destination: first,
      );
      await service.saveSelectedDestination(
        clientId: 'client-1',
        destination: second,
      );
      await service.saveSelectedDestination(
        clientId: 'client-1',
        destination: firstDuplicate,
      );

      final selected = await service.readSelectedDestinations('client-1');
      expect(
        selected.map((destination) => destination.formattedAddress),
        <String>['palmarejo', 'Chã de Areia'],
      );
      expect(await service.readSelectedDestinations('client-2'), isEmpty);
    },
  );

  test('keeps favorites separated by client', () async {
    const destination = DestinationPreferenceEntry(
      latitude: 14.921,
      longitude: -23.508,
      formattedAddress: 'Achada Santo António',
    );

    await service.saveFavoriteDestination(
      clientId: 'client-1',
      destination: destination,
    );

    expect(await service.readFavoriteDestinations('client-1'), hasLength(1));
    expect(await service.readFavoriteDestinations('client-2'), isEmpty);
  });
}
