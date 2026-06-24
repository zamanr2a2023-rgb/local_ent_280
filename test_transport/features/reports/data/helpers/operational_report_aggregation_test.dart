import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/reports/data/helpers/operational_report_aggregation.dart';
import 'package:local_transport/features/reports/domain/entities/panorama_mode.dart';
import 'package:local_transport/features/reports/domain/entities/trip_explorer_record.dart';
import 'package:local_transport/features/trips/domain/entities/trip_payment_status.dart';
import 'package:local_transport/features/trips/domain/entities/trip_state.dart';
import 'package:local_transport/features/trips/domain/entities/trip_transport_type.dart';

void main() {
  test(
    'buildOperationalReportSummary aggregates counts, totals and averages',
    () {
      final records = <TripExplorerRecord>[
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
          arrivedAt: DateTime(2026, 3, 1, 10, 15),
          duration: const Duration(minutes: 32),
          distanceKm: 12.5,
          finalCostMinor: 2000,
          totalDebtMinor: 100,
        ),
        _buildTripRecord(
          tripId: 'trip-2',
          clientId: 'client-b',
          clientName: 'Cliente B',
          driverId: 'driver-2',
          driverName: 'Motorista 2',
          vehicleId: 'vehicle-2',
          vehiclePlate: 'BB-22-BB',
          status: TripState.cancelledByDriver,
          requestedAt: DateTime(2026, 3, 1, 11),
          acceptedAt: null,
          arrivedAt: null,
          duration: const Duration(minutes: 4),
          distanceKm: 0.4,
          finalCostMinor: 0,
          totalDebtMinor: 0,
        ),
        _buildTripRecord(
          tripId: 'trip-3',
          clientId: 'client-a',
          clientName: 'Cliente A',
          driverId: 'driver-3',
          driverName: 'Motorista 3',
          vehicleId: 'vehicle-1',
          vehiclePlate: 'AA-11-AA',
          status: TripState.noShow,
          requestedAt: DateTime(2026, 3, 1, 12),
          acceptedAt: DateTime(2026, 3, 1, 12, 3),
          arrivedAt: DateTime(2026, 3, 1, 12, 9),
          duration: const Duration(minutes: 12),
          distanceKm: 1.1,
          finalCostMinor: 300,
          totalDebtMinor: 50,
        ),
      ];

      final summary = buildOperationalReportSummary(records);

      expect(summary.requestedCount, 3);
      expect(summary.completedCount, 1);
      expect(summary.cancelledCount, 2);
      expect(summary.noShowCount, 1);
      expect(summary.completionRate, closeTo(1 / 3, 0.0001));
      expect(summary.cancellationRate, closeTo(2 / 3, 0.0001));
      expect(summary.totalDistanceKm, closeTo(14.0, 0.0001));
      expect(summary.totalDuration, const Duration(minutes: 48));
      expect(summary.grossTotalMinor, 2300);
      expect(summary.totalDebtMinor, 150);
      expect(summary.averageAcceptanceDuration, const Duration(minutes: 4));
      expect(summary.averagePickupArrivalDuration, const Duration(minutes: 8));
    },
  );

  test(
    'buildOperationalReportGroupRows groups by vehicle and sorts by gross',
    () {
      final rows = buildOperationalReportGroupRows(
        records: <TripExplorerRecord>[
          _buildTripRecord(
            tripId: 'trip-1',
            clientId: 'client-a',
            clientName: 'Cliente A',
            driverId: 'driver-1',
            driverName: 'Motorista 1',
            vehicleId: 'vehicle-1',
            vehiclePlate: 'AA-11-AA',
            status: TripState.completed,
            requestedAt: DateTime(2026, 3, 1, 10),
            acceptedAt: DateTime(2026, 3, 1, 10, 5),
            arrivedAt: DateTime(2026, 3, 1, 10, 12),
            duration: const Duration(minutes: 30),
            distanceKm: 10,
            finalCostMinor: 900,
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
            requestedAt: DateTime(2026, 3, 2, 10),
            acceptedAt: DateTime(2026, 3, 2, 10, 5),
            arrivedAt: DateTime(2026, 3, 2, 10, 11),
            duration: const Duration(minutes: 25),
            distanceKm: 8,
            finalCostMinor: 2200,
            totalDebtMinor: 300,
          ),
        ],
        mode: PanoramaMode.vehicle,
      );

      expect(rows, hasLength(2));
      expect(rows.first.label, 'BB-22-BB');
      expect(rows.first.entityId, 'vehicle-2');
      expect(rows.first.summary.grossTotalMinor, 2200);
      expect(rows.last.label, 'AA-11-AA');
    },
  );

  test(
    'buildOperationalReportGroupRows creates daily buckets for period mode',
    () {
      final rows = buildOperationalReportGroupRows(
        records: <TripExplorerRecord>[
          _buildTripRecord(
            tripId: 'trip-1',
            clientId: 'client-a',
            clientName: 'Cliente A',
            driverId: 'driver-1',
            driverName: 'Motorista 1',
            vehicleId: 'vehicle-1',
            vehiclePlate: 'AA-11-AA',
            status: TripState.completed,
            requestedAt: DateTime(2026, 3, 1, 10, 30),
            acceptedAt: DateTime(2026, 3, 1, 10, 35),
            arrivedAt: DateTime(2026, 3, 1, 10, 45),
            duration: const Duration(minutes: 20),
            distanceKm: 6,
            finalCostMinor: 1200,
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
            requestedAt: DateTime(2026, 3, 2, 8, 15),
            acceptedAt: DateTime(2026, 3, 2, 8, 18),
            arrivedAt: DateTime(2026, 3, 2, 8, 24),
            duration: const Duration(minutes: 18),
            distanceKm: 5,
            finalCostMinor: 900,
            totalDebtMinor: 0,
          ),
        ],
        mode: PanoramaMode.period,
      );

      final march1 = rows.firstWhere((row) => row.label == '2026-03-01');
      final march2 = rows.firstWhere((row) => row.label == '2026-03-02');

      expect(march1.periodStart, DateTime(2026, 3, 1));
      expect(march1.summary.requestedCount, 1);
      expect(march2.periodStart, DateTime(2026, 3, 2));
      expect(march2.summary.grossTotalMinor, 900);
    },
  );
}

TripExplorerRecord _buildTripRecord({
  required String tripId,
  required String clientId,
  required String clientName,
  required String? driverId,
  required String? driverName,
  required String? vehicleId,
  required String? vehiclePlate,
  required TripState status,
  required DateTime? requestedAt,
  required DateTime? acceptedAt,
  required DateTime? arrivedAt,
  required Duration duration,
  required double distanceKm,
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
      arrivedDestinationAt: null,
      completedAt: null,
      cancelledAt: status == TripState.cancelledByDriver ? requestedAt : null,
      totalDuration: duration,
      waitDuration: const Duration(minutes: 1),
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
        amountMinor: finalCostMinor,
        currency: CurrencyCode.eur,
      ),
      finalCost: Money(amountMinor: finalCostMinor, currency: CurrencyCode.eur),
      totalDebt: Money(amountMinor: totalDebtMinor, currency: CurrencyCode.eur),
      baseFare: const Money(amountMinor: 500, currency: CurrencyCode.eur),
      distanceCharge: const Money(amountMinor: 500, currency: CurrencyCode.eur),
      waitCharge: null,
      penalties: null,
      surcharge: null,
      subtotal: Money(amountMinor: finalCostMinor, currency: CurrencyCode.eur),
      discount: null,
      multiplier: 1,
      multiplierCharge: null,
      cancellationFee: null,
      paymentStatus: TripPaymentStatus.paid,
      paymentPaidAt: null,
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
