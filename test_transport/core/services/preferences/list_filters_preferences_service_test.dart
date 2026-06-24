import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/services/preferences/list_filters_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ListFiltersPreferencesService service;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    service = ListFiltersPreferencesService();
  });

  test('writes and reads persisted map for scope', () async {
    await service.write('clientTrips', <String, dynamic>{
      'status': 'completed',
      'sortOrder': 'descending',
      'searchQuery': 'porto',
      'dateStartMs': 1000,
      'dateEndMs': 2000,
    });

    final persisted = await service.read('clientTrips');

    expect(persisted, isNotNull);
    expect(persisted!['status'], 'completed');
    expect(persisted['sortOrder'], 'descending');
    expect(persisted['searchQuery'], 'porto');
    expect(persisted['dateStartMs'], 1000);
    expect(persisted['dateEndMs'], 2000);
  });

  test('clears scope data', () async {
    await service.write('adminAudit', <String, dynamic>{
      'actionType': 'tariffEdit',
    });

    await service.clear('adminAudit');

    final persisted = await service.read('adminAudit');
    expect(persisted, isNull);
  });
}
