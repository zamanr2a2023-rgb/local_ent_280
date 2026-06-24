import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/app/theme/app_theme.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/admin/presentation/screens/admin_reports_screen.dart';
import 'package:local_transport/features/admin/presentation/widgets/reports/admin_client_statement_tab.dart';
import 'package:local_transport/features/admin/presentation/widgets/reports/admin_driver_statement_tab.dart';
import 'package:local_transport/features/auth/domain/entities/auth_status.dart';
import 'package:local_transport/features/auth/domain/entities/profile_role.dart';
import 'package:local_transport/features/auth/presentation/providers/auth_status_provider.dart';
import 'package:local_transport/features/reports/application/providers/reports_domain_providers.dart';
import 'package:local_transport/features/reports/domain/entities/client_statement_dataset.dart';
import 'package:local_transport/features/reports/domain/entities/client_statement_page.dart';
import 'package:local_transport/features/reports/domain/entities/client_statement_query.dart';
import 'package:local_transport/features/reports/domain/entities/client_statement_reconciliation.dart';
import 'package:local_transport/features/reports/domain/entities/panorama_mode.dart';
import 'package:local_transport/features/reports/domain/entities/reports_tab.dart';
import 'package:local_transport/features/reports/domain/entities/trip_explorer_dataset.dart';
import 'package:local_transport/features/reports/domain/entities/trip_explorer_page.dart';
import 'package:local_transport/features/reports/domain/entities/trip_explorer_query.dart';
import 'package:local_transport/features/reports/domain/entities/trip_explorer_record.dart';
import 'package:local_transport/features/reports/domain/repositories/client_statement_repository.dart';
import 'package:local_transport/features/reports/domain/repositories/trip_explorer_repository.dart';
import 'package:local_transport/features/reports/presentation/providers/operational_panorama_provider.dart';
import 'package:local_transport/features/trips/domain/entities/trip_payment_status.dart';
import 'package:local_transport/features/trips/domain/entities/trip_state.dart';
import 'package:local_transport/features/trips/domain/entities/trip_transport_type.dart';
import 'package:local_transport/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'admin sees all report workspaces and operational mode switch works',
    (tester) async {
      final container = await _pumpScreen(tester, role: ProfileRole.admin);
      addTearDown(container.dispose);

      expect(_reportTab('Panorama Operacional'), findsOneWidget);
      expect(_reportTab('Extrato do Cliente'), findsOneWidget);
      expect(_reportTab('Extrato do Motorista'), findsOneWidget);
      expect(container.read(panoramaModeProvider), PanoramaMode.detail);

      await tester.tap(_panoramaModeButton('Cliente'));
      await tester.pumpAndSettle();

      expect(container.read(panoramaModeProvider), PanoramaMode.client);

      await tester.tap(_reportTab('Extrato do Cliente'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminClientStatementTab), findsOneWidget);
      expect(find.text('Todos os clientes'), findsWidgets);

      await tester.tap(_reportTab('Extrato do Motorista'));
      await tester.pumpAndSettle();

      expect(find.byType(AdminDriverStatementTab), findsOneWidget);
      expect(find.text('Todos os motoristas'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('manager cannot access the client statement workspace', (
    tester,
  ) async {
    final container = await _pumpScreen(tester, role: ProfileRole.manager);
    addTearDown(container.dispose);

    expect(_reportTab('Panorama Operacional'), findsOneWidget);
    expect(_reportTab('Extrato do Cliente'), findsNothing);
    expect(_reportTab('Extrato do Motorista'), findsOneWidget);

    await tester.tap(_reportTab('Extrato do Motorista'));
    await tester.pumpAndSettle();

    expect(find.byType(AdminDriverStatementTab), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Finder _reportTab(String label) {
  return find.descendant(
    of: find.byType(SegmentedButton<ReportsTab>),
    matching: find.text(label),
  );
}

Finder _panoramaModeButton(String label) {
  return find.descendant(
    of: find.byType(SegmentedButton<PanoramaMode>),
    matching: find.text(label),
  );
}

Future<ProviderContainer> _pumpScreen(
  WidgetTester tester, {
  required ProfileRole role,
}) async {
  final container = ProviderContainer(
    overrides: [
      authStatusProvider.overrideWith(
        (ref) => Stream<AuthStatus>.value(
          AuthStatus(isAvailable: true, role: role),
        ),
      ),
      tripExplorerRepositoryProvider.overrideWith(
        (ref) => _FakeTripExplorerRepository(_sampleTripRecords),
      ),
      clientStatementRepositoryProvider.overrideWith(
        (ref) => const _FakeClientStatementRepository(),
      ),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('pt', 'PT'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AdminReportsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

class _FakeTripExplorerRepository implements TripExplorerRepository {
  const _FakeTripExplorerRepository(this.records);

  final List<TripExplorerRecord> records;

  @override
  Future<TripExplorerDataset> fetchDataset(
    TripExplorerQuery query, {
    required int maxRecords,
  }) async {
    final filtered = _filter(query).toList(growable: false);
    return TripExplorerDataset(
      records: filtered.take(maxRecords).toList(growable: false),
      isComplete: filtered.length <= maxRecords,
    );
  }

  @override
  Future<TripExplorerPage> fetchPage(TripExplorerQuery query) async {
    final filtered = _filter(query).toList(growable: false);
    return TripExplorerPage(
      records: filtered.take(query.pageSize).toList(growable: false),
      nextCursor: null,
      hasMore: false,
    );
  }

  Iterable<TripExplorerRecord> _filter(TripExplorerQuery query) {
    return records.where((record) {
      if (query.exactClientId != null &&
          record.relational.clientId != query.exactClientId) {
        return false;
      }
      if (query.exactDriverId != null &&
          record.relational.driverId != query.exactDriverId) {
        return false;
      }
      if (query.exactVehicleId != null &&
          record.relational.vehicleId != query.exactVehicleId) {
        return false;
      }
      if (query.tripStatus != null &&
          record.operational.status != query.tripStatus) {
        return false;
      }
      return true;
    });
  }
}

class _FakeClientStatementRepository implements ClientStatementRepository {
  const _FakeClientStatementRepository();

  @override
  Future<ClientStatementDataset> fetchDataset(
    ClientStatementQuery query, {
    required int maxRecords,
  }) async {
    return const ClientStatementDataset(entries: [], isComplete: true);
  }

  @override
  Future<ClientStatementPage> fetchPage(ClientStatementQuery query) async {
    return const ClientStatementPage(
      entries: [],
      nextCursor: null,
      hasMore: false,
    );
  }

  @override
  Future<ClientStatementReconciliation> fetchReconciliation({
    required String? clientId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    const zero = Money(amountMinor: 0, currency: CurrencyCode.eur);
    return const ClientStatementReconciliation(
      openingBalance: zero,
      creditsTotal: zero,
      debitsTotal: zero,
      closingBalance: zero,
      debtAtPeriodEnd: zero,
    );
  }
}

final _sampleTripRecords = <TripExplorerRecord>[
  _buildTripRecord(
    tripId: 'trip-1',
    clientId: 'client-a',
    clientName: 'Cliente A',
    driverId: 'driver-1',
    driverName: 'Motorista 1',
    vehicleId: 'vehicle-1',
    vehiclePlate: 'AA-11-AA',
    status: TripState.chargeApplied,
    requestedAt: DateTime(2026, 3, 1, 10),
    acceptedAt: DateTime(2026, 3, 1, 10, 5),
    arrivedAt: DateTime(2026, 3, 1, 10, 12),
    completedAt: DateTime(2026, 3, 1, 10, 35),
    distanceKm: 12.4,
    duration: const Duration(minutes: 35),
    finalCostMinor: 2300,
    totalDebtMinor: 0,
  ),
  _buildTripRecord(
    tripId: 'trip-2',
    clientId: 'client-b',
    clientName: 'Cliente B',
    driverId: 'driver-2',
    driverName: 'Motorista 2',
    vehicleId: 'vehicle-2',
    vehiclePlate: 'BB-22-BB',
    status: TripState.completed,
    requestedAt: DateTime(2026, 3, 2, 11),
    acceptedAt: DateTime(2026, 3, 2, 11, 3),
    arrivedAt: DateTime(2026, 3, 2, 11, 9),
    completedAt: DateTime(2026, 3, 2, 11, 40),
    distanceKm: 8.6,
    duration: const Duration(minutes: 40),
    finalCostMinor: 1800,
    totalDebtMinor: 400,
  ),
];

TripExplorerRecord _buildTripRecord({
  required String tripId,
  required String clientId,
  required String clientName,
  required String? driverId,
  required String? driverName,
  required String? vehicleId,
  required String? vehiclePlate,
  required TripState status,
  required DateTime requestedAt,
  required DateTime? acceptedAt,
  required DateTime? arrivedAt,
  required DateTime? completedAt,
  required double distanceKm,
  required Duration duration,
  required int finalCostMinor,
  required int totalDebtMinor,
}) {
  return TripExplorerRecord(
    operational: TripExplorerOperationalBlock(
      tripId: tripId,
      status: status,
      transportType: const TripTransportType(id: 'standard', name: 'Standard'),
      requestedAt: requestedAt,
      driverAssignedAt: acceptedAt,
      acceptedAt: acceptedAt,
      driverArrivedAt: arrivedAt,
      startedAt: acceptedAt,
      arrivedDestinationAt: completedAt,
      completedAt: completedAt,
      cancelledAt: null,
      totalDuration: duration,
      waitDuration: const Duration(minutes: 2),
      distanceKm: distanceKm,
      hasMeteringData: true,
      pickupAddress: 'Origem $tripId',
      destinationAddress: 'Destino $tripId',
      pickupLatitude: 14.9,
      pickupLongitude: -23.5,
      destinationLatitude: 15.1,
      destinationLongitude: -23.4,
    ),
    financial: TripExplorerFinancialBlock(
      estimatedTotal: Money(
        amountMinor: finalCostMinor - 100,
        currency: CurrencyCode.eur,
      ),
      finalCost: Money(amountMinor: finalCostMinor, currency: CurrencyCode.eur),
      totalDebt: Money(amountMinor: totalDebtMinor, currency: CurrencyCode.eur),
      baseFare: const Money(amountMinor: 500, currency: CurrencyCode.eur),
      distanceCharge: const Money(amountMinor: 900, currency: CurrencyCode.eur),
      waitCharge: const Money(amountMinor: 100, currency: CurrencyCode.eur),
      penalties: null,
      surcharge: null,
      subtotal: Money(amountMinor: finalCostMinor, currency: CurrencyCode.eur),
      discount: null,
      multiplier: 1,
      multiplierCharge: null,
      cancellationFee: null,
      paymentStatus: TripPaymentStatus.paid,
      paymentPaidAt: completedAt,
      paymentFailedAt: null,
      pricingSchemaVersion: 2,
      appliedMultiplierId: null,
      tariffId: 'tariff-1',
      tariffUpdatedAt: DateTime(2026, 1, 1),
      pricingScheduleId: 'schedule-1',
      specialDayId: null,
      transportMultiplier: 1,
      timeRangeMultiplier: 1.1,
      holidayMultiplier: null,
      evaluationTimestamp: requestedAt,
      evaluationTimeZone: 'Europe/Lisbon',
    ),
    relational: TripExplorerRelationalBlock(
      clientId: clientId,
      clientName: clientName,
      driverId: driverId,
      driverName: driverName,
      vehicleId: vehicleId,
      vehicleName: vehiclePlate,
      vehiclePlate: vehiclePlate,
      hasPostChargeExtension: false,
      postChargeExtensionCyclesCount: 0,
      postChargeExtensionChargedTotal: null,
    ),
    audit: const TripExplorerAuditBlock(
      statusEnteredAt: null,
      supportStatus: null,
      supportNote: null,
      supportUpdatedBy: null,
      supportUpdatedAt: null,
      unfulfilledReason: null,
      hasManualSurchargeFlow: false,
      manualSurchargeReason: null,
      cancellationReason: null,
      cancellationActor: null,
      cancellationType: null,
      hasClientRating: false,
    ),
  );
}
