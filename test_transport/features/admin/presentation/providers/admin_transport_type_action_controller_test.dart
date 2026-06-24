import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/admin/domain/entities/admin_transport_type.dart';
import 'package:local_transport/features/admin/domain/entities/admin_transport_type_draft.dart';
import 'package:local_transport/features/admin/domain/entities/admin_transport_type_update.dart';
import 'package:local_transport/features/admin/domain/entities/admin_transport_type_update_result.dart';
import 'package:local_transport/features/admin/domain/repositories/admin_transport_type_repository.dart';
import 'package:local_transport/features/admin/domain/usecases/create_admin_transport_type.dart';
import 'package:local_transport/features/admin/domain/usecases/update_admin_transport_type.dart';
import 'package:local_transport/features/admin/presentation/providers/admin_transport_type_action_controller.dart';
import 'package:local_transport/features/admin/presentation/providers/admin_transport_type_action_state.dart';

void main() {
  group('AdminTransportTypeActionController', () {
    test('rejects invalid base fare before calling backend', () async {
      final repository = _FakeAdminTransportTypeRepository();
      final controller = AdminTransportTypeActionController(
        CreateAdminTransportType(repository),
        UpdateAdminTransportType(repository),
      );

      final success = await controller.createType(
        name: 'Standard Plus',
        description: 'Mais espaço',
        initialBaseFareText: 'abc',
        packagePriceMultiplierText: '1.25',
      );

      expect(success, isFalse);
      expect(
        controller.state.status,
        AdminTransportTypeActionStatus.error,
      );
      expect(
        controller.state.error,
        AdminTransportTypeActionError.missingFields,
      );
      expect(repository.createdDraft, isNull);
    });

    test('creates transport type with parsed initial base fare', () async {
      final repository = _FakeAdminTransportTypeRepository();
      final controller = AdminTransportTypeActionController(
        CreateAdminTransportType(repository),
        UpdateAdminTransportType(repository),
      );

      final success = await controller.createType(
        name: 'Standard Plus',
        description: 'Mais espaço',
        initialBaseFareText: '12,50',
        packagePriceMultiplierText: '1.25',
      );

      expect(success, isTrue);
      expect(
        controller.state.status,
        AdminTransportTypeActionStatus.success,
      );
      expect(repository.createdDraft, isNotNull);
      expect(
        repository.createdDraft!.initialBaseFare.amountMinor,
        1250,
      );
      expect(
        repository.createdDraft!.initialBaseFare.currency,
        CurrencyCode.eur,
      );
      expect(repository.createdDraft!.packagePriceMultiplierBasisPoints, 12500);
    });

    test('creates transport type with formatter-produced euro text', () async {
      final repository = _FakeAdminTransportTypeRepository();
      final controller = AdminTransportTypeActionController(
        CreateAdminTransportType(repository),
        UpdateAdminTransportType(repository),
      );

      final success = await controller.createType(
        name: 'Standard Plus',
        description: 'Mais espaço',
        initialBaseFareText: '€1.00',
        packagePriceMultiplierText: '1.00',
      );

      expect(success, isTrue);
      expect(repository.createdDraft, isNotNull);
      expect(repository.createdDraft!.initialBaseFare.amountMinor, 100);
    });

    test('updates transport type with parsed base fare', () async {
      final repository = _FakeAdminTransportTypeRepository();
      final controller = AdminTransportTypeActionController(
        CreateAdminTransportType(repository),
        UpdateAdminTransportType(repository),
      );

      final success = await controller.updateType(
        id: 'standard_plus',
        name: 'Standard Plus',
        description: 'Mais espaço',
        baseFareText: '15,00',
        packagePriceMultiplierText: '1.50',
      );

      expect(success, isTrue);
      expect(repository.updatedDraft, isNotNull);
      expect(repository.updatedDraft!.id, 'standard_plus');
      expect(repository.updatedDraft!.baseFare.amountMinor, 1500);
      expect(repository.updatedDraft!.baseFare.currency, CurrencyCode.eur);
      expect(repository.updatedDraft!.packagePriceMultiplierBasisPoints, 15000);
    });

    test('rejects package multiplier outside the allowed range', () async {
      final repository = _FakeAdminTransportTypeRepository();
      final controller = AdminTransportTypeActionController(
        CreateAdminTransportType(repository),
        UpdateAdminTransportType(repository),
      );

      final success = await controller.createType(
        name: 'Standard Plus',
        description: 'Mais espaço',
        initialBaseFareText: '12,50',
        packagePriceMultiplierText: '3.50',
      );

      expect(success, isFalse);
      expect(repository.createdDraft, isNull);
      expect(
        controller.state.error,
        AdminTransportTypeActionError.missingFields,
      );
    });
  });
}

class _FakeAdminTransportTypeRepository
    implements AdminTransportTypeRepository {
  AdminTransportTypeDraft? createdDraft;
  AdminTransportTypeUpdate? updatedDraft;

  @override
  Future<void> createTransportType(AdminTransportTypeDraft draft) async {
    createdDraft = draft;
  }

  @override
  Future<AdminTransportTypeUpdateResult> updateTransportType(
    AdminTransportTypeUpdate update,
  ) async {
    updatedDraft = update;
    return const AdminTransportTypeUpdateResult(
      matchedVehicles: 0,
      updatedVehicles: 0,
      failedVehicles: 0,
      backfillCompleted: true,
    );
  }

  @override
  Stream<List<AdminTransportType>> watchTransportTypes() {
    return Stream.value(const <AdminTransportType>[]);
  }
}
