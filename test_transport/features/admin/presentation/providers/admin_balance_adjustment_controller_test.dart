import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/decimal_ratio.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/core/services/currency_conversion_engine.dart';
import 'package:local_transport/features/admin/domain/entities/balance_adjustment.dart';
import 'package:local_transport/features/admin/domain/entities/balance_adjustment_draft.dart';
import 'package:local_transport/features/admin/domain/entities/client_balance_summary.dart';
import 'package:local_transport/features/admin/domain/repositories/admin_balances_repository.dart';
import 'package:local_transport/features/admin/domain/usecases/apply_balance_adjustment.dart';
import 'package:local_transport/features/admin/presentation/providers/admin_balance_adjustment_controller.dart';
import 'package:local_transport/features/admin/presentation/providers/admin_balance_adjustment_state.dart';
import 'package:local_transport/features/currency/domain/entities/currency_fx_snapshot.dart';

void main() {
  group('AdminBalanceAdjustmentController', () {
    test('converts CVE input to EUR before persisting adjustment', () async {
      final capture = _FakeAdminBalancesRepository();
      final snapshot = _validSnapshot(cveToEur: '0.01', cveToUsd: '0.02');
      final controller = AdminBalanceAdjustmentController(
        ApplyBalanceAdjustment(capture),
        () => 'admin_1',
        () => 'admin@example.com',
        () => snapshot,
      );

      final success = await controller.submitAdjustment(
        clientId: 'client_1',
        amountText: '100',
        reason: 'Ajuste manual',
        isCredit: true,
        inputCurrency: CurrencyCode.cve,
      );

      expect(success, isTrue);
      expect(capture.lastDraft, isNotNull);
      expect(capture.lastDraft!.delta.currency, CurrencyCode.eur);
      expect(capture.lastDraft!.delta.amountMinor, 100);
      expect(controller.state.status, AdminBalanceAdjustmentStatus.success);
    });

    test('converts USD input and applies debit sign', () async {
      final capture = _FakeAdminBalancesRepository();
      final snapshot = _validSnapshot(cveToEur: '0.01', cveToUsd: '0.02');
      final controller = AdminBalanceAdjustmentController(
        ApplyBalanceAdjustment(capture),
        () => 'admin_1',
        () => 'admin@example.com',
        () => snapshot,
      );

      final success = await controller.submitAdjustment(
        clientId: 'client_1',
        amountText: '10',
        reason: 'Correção',
        isCredit: false,
        inputCurrency: CurrencyCode.usd,
      );

      expect(success, isTrue);
      expect(capture.lastDraft, isNotNull);
      expect(capture.lastDraft!.delta.currency, CurrencyCode.eur);
      expect(capture.lastDraft!.delta.amountMinor, -500);
    });

    test('accepts localized decimal input with comma', () async {
      final capture = _FakeAdminBalancesRepository();
      final snapshot = _validSnapshot(cveToEur: '0.01', cveToUsd: '0.02');
      final controller = AdminBalanceAdjustmentController(
        ApplyBalanceAdjustment(capture),
        () => 'admin_1',
        () => 'admin@example.com',
        () => snapshot,
      );

      final success = await controller.submitAdjustment(
        clientId: 'client_1',
        amountText: '10,50',
        reason: 'Correção',
        isCredit: true,
        inputCurrency: CurrencyCode.eur,
      );

      expect(success, isTrue);
      expect(capture.lastDraft, isNotNull);
      expect(capture.lastDraft!.delta.amountMinor, 1050);
    });

    test('returns missingFx when CVE input is used without valid FX', () async {
      final capture = _FakeAdminBalancesRepository();
      final controller = AdminBalanceAdjustmentController(
        ApplyBalanceAdjustment(capture),
        () => 'admin_1',
        () => 'admin@example.com',
        () => const CurrencyFxSnapshot(
          config: null,
          rates: null,
          isValid: false,
          fallbackReason: CurrencyFxFallbackReason.missingConfig,
        ),
      );

      final success = await controller.submitAdjustment(
        clientId: 'client_1',
        amountText: '10',
        reason: 'Teste',
        isCredit: true,
        inputCurrency: CurrencyCode.cve,
      );

      expect(success, isFalse);
      expect(capture.lastDraft, isNull);
      expect(controller.state.status, AdminBalanceAdjustmentStatus.error);
      expect(controller.state.error, AdminBalanceAdjustmentError.missingFx);
    });
  });
}

CurrencyFxSnapshot _validSnapshot({
  required String cveToEur,
  required String cveToUsd,
}) {
  return CurrencyFxSnapshot(
    config: null,
    rates: CurrencyFxRates(
      cveToEur: DecimalRatio.parse(cveToEur)!,
      cveToUsd: DecimalRatio.parse(cveToUsd)!,
    ),
    isValid: true,
  );
}

class _FakeAdminBalancesRepository implements AdminBalancesRepository {
  BalanceAdjustmentDraft? lastDraft;

  @override
  Future<void> applyBalanceAdjustment(BalanceAdjustmentDraft draft) async {
    lastDraft = draft;
  }

  @override
  Stream<List<BalanceAdjustment>> watchBalanceAdjustments({String? clientId}) {
    return Stream.value(const <BalanceAdjustment>[]);
  }

  @override
  Stream<List<ClientBalanceSummary>> watchClientBalances() {
    return Stream.value(const <ClientBalanceSummary>[]);
  }
}
