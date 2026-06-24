import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/data/firebase/validation/firestore_schema_validation_exception.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/admin/domain/repositories/admin_tariff_repository.dart';
import 'package:local_transport/features/admin/domain/usecases/save_tariff_with_audit.dart';
import 'package:local_transport/features/admin/presentation/providers/admin_tariff_controller.dart';
import 'package:local_transport/features/admin/presentation/providers/admin_tariff_state.dart';
import 'package:local_transport/features/pricing/domain/entities/tariff.dart';
import 'package:local_transport/features/pricing/domain/entities/tariff_distance_tier.dart';
import 'package:local_transport/features/pricing/domain/entities/tariff_penalty_fees.dart';
import 'package:local_transport/features/pricing/domain/repositories/tariff_repository.dart';

void main() {
  group('AdminTariffController', () {
    test('loads admin tariff from repository', () async {
      final tariffRepository = _FakeTariffRepository(
        fetchedTariff: _sampleTariff(),
      );
      final adminTariffRepository = _FakeAdminTariffRepository();
      final controller = AdminTariffController(
        tariffRepository: tariffRepository,
        saveTariff: SaveTariffWithAudit(
          adminTariffRepository: adminTariffRepository,
          tariffRepository: tariffRepository,
        ),
        getCurrentUserId: () => 'admin_1',
        getCurrentUserEmail: () => 'admin@example.com',
      );

      await _pumpAsync();

      expect(controller.state.status, AdminTariffStatus.idle);
      expect(controller.state.errorMessage, isNull);
      expect(controller.state.tariff, isNotNull);
      expect(
        controller.state.tariff!.baseForTransportType('standard').amountMinor,
        500,
      );
    });

    test('fails load when admin tariff is missing', () async {
      final tariffRepository = _FakeTariffRepository();
      final controller = AdminTariffController(
        tariffRepository: tariffRepository,
        saveTariff: SaveTariffWithAudit(
          adminTariffRepository: _FakeAdminTariffRepository(),
          tariffRepository: tariffRepository,
        ),
        getCurrentUserId: () => 'admin_1',
        getCurrentUserEmail: () => 'admin@example.com',
      );

      await _pumpAsync();

      expect(controller.state.status, AdminTariffStatus.error);
      expect(controller.state.errorMessage, 'load_failed');
      expect(controller.state.tariff, isNull);
    });

    test(
      'surfaces invalid schema when admin tariff payload is legacy',
      () async {
        final tariffRepository = _ThrowingTariffRepository(
          error: FirestoreSchemaValidationException(
            path: 'tariffs/admin_default',
            collectionKey: 'tariffs',
            issues: const ['baseByTransportType deve ser mapa.'],
          ),
        );
        final controller = AdminTariffController(
          tariffRepository: tariffRepository,
          saveTariff: SaveTariffWithAudit(
            adminTariffRepository: _FakeAdminTariffRepository(),
            tariffRepository: tariffRepository,
          ),
          getCurrentUserId: () => 'admin_1',
          getCurrentUserEmail: () => 'admin@example.com',
        );

        await _pumpAsync();

        expect(controller.state.status, AdminTariffStatus.error);
        expect(controller.state.errorMessage, 'load_invalid_schema');
        expect(controller.state.tariff, isNull);
      },
    );

    test('does not save when current admin is missing', () async {
      final tariffRepository = _FakeTariffRepository(
        fetchedTariff: _sampleTariff(),
      );
      final adminTariffRepository = _FakeAdminTariffRepository();
      final controller = AdminTariffController(
        tariffRepository: tariffRepository,
        saveTariff: SaveTariffWithAudit(
          adminTariffRepository: adminTariffRepository,
          tariffRepository: tariffRepository,
        ),
        getCurrentUserId: () => null,
        getCurrentUserEmail: () => null,
      );

      await _pumpAsync();
      await controller.saveTariff(_sampleTariff());

      expect(controller.state.status, AdminTariffStatus.error);
      expect(controller.state.errorMessage, 'missing_admin');
      expect(adminTariffRepository.savedTariff, isNull);
    });
  });
}

Future<void> _pumpAsync() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

Tariff _sampleTariff() {
  return const Tariff(
    id: 'admin_default',
    baseByTransportType: {
      'premium': Money(amountMinor: 700, currency: CurrencyCode.eur),
      'standard': Money(amountMinor: 500, currency: CurrencyCode.eur),
    },
    perKm: Money(amountMinor: 120, currency: CurrencyCode.eur),
    perWaitMinute: Money(amountMinor: 10, currency: CurrencyCode.eur),
    distanceTiers: [
      TariffDistanceTier(
        startMetersInclusive: 0,
        endMetersExclusive: null,
        perKm: Money(amountMinor: 120, currency: CurrencyCode.eur),
      ),
    ],
    penaltyFees: TariffPenaltyFees.empty(),
  );
}

class _FakeTariffRepository implements TariffRepository {
  _FakeTariffRepository({this.fetchedTariff});

  final Tariff? fetchedTariff;

  @override
  Future<Tariff?> fetchTariff(String tariffId) async {
    return fetchedTariff;
  }
}

class _FakeAdminTariffRepository implements AdminTariffRepository {
  Tariff? savedTariff;
  String? savedReason;

  @override
  Future<void> saveTariff({
    required Tariff tariff,
    String? reason,
  }) async {
    savedTariff = tariff;
    savedReason = reason;
  }
}

class _ThrowingTariffRepository implements TariffRepository {
  _ThrowingTariffRepository({required this.error});

  final Object error;

  @override
  Future<Tariff?> fetchTariff(String tariffId) {
    return Future<Tariff?>.error(error);
  }
}
