import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/entities/sort_order.dart';
import 'package:local_transport/features/reports/data/helpers/report_processing.dart';
import 'package:local_transport/features/reports/data/models/report_trip_record.dart';
import 'package:local_transport/features/reports/domain/entities/report_date_range.dart';
import 'package:local_transport/features/reports/domain/entities/report_query.dart';
import 'package:local_transport/features/reports/domain/entities/report_sort.dart';
import 'package:local_transport/features/reports/domain/entities/report_type.dart';

void main() {
  List<ReportTripRecord> buildRecords() {
    return <ReportTripRecord>[
      ReportTripRecord(
        id: 't1',
        clientName: 'Cliente A',
        driverName: 'Motorista 1',
        vehicleName: 'AA-11-BB',
        startedAt: DateTime(2026, 3, 1, 10),
        duration: const Duration(minutes: 10),
        distanceKm: 4,
        totalCostMinor: 1200,
        totalDebtMinor: 0,
      ),
      ReportTripRecord(
        id: 't2',
        clientName: 'Cliente B',
        driverName: 'Motorista 2',
        vehicleName: 'CC-22-DD',
        startedAt: DateTime(2026, 3, 1, 12),
        duration: const Duration(minutes: 15),
        distanceKm: 5.5,
        totalCostMinor: 2500,
        totalDebtMinor: 100,
      ),
      ReportTripRecord(
        id: 't3',
        clientName: 'Cliente C',
        driverName: 'Motorista 3',
        vehicleName: 'EE-33-FF',
        startedAt: DateTime(2026, 3, 1, 13),
        duration: const Duration(minutes: 8),
        distanceKm: 2.1,
        totalCostMinor: 900,
        totalDebtMinor: 0,
      ),
    ];
  }

  test('orders report rows by total cost descending', () {
    final query = ReportQuery(
      type: ReportType.client,
      dateRange: ReportDateRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 2),
      ),
      sort: const ReportSort(
        by: ReportSortBy.totalCost,
        order: SortOrder.descending,
      ),
    );

    final input = buildReportRowsInput(query, buildRecords());
    final rowsData = buildReportRowsInIsolate(input);
    final rows = deserializeReportRows(rowsData);

    expect(rows.map((row) => row.label).toList(), <String>[
      'Cliente B',
      'Cliente A',
      'Cliente C',
    ]);
  });

  test('orders report rows alphabetically ascending', () {
    final query = ReportQuery(
      type: ReportType.client,
      dateRange: ReportDateRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 2),
      ),
      sort: const ReportSort(
        by: ReportSortBy.label,
        order: SortOrder.ascending,
      ),
    );

    final input = buildReportRowsInput(query, buildRecords());
    final rowsData = buildReportRowsInIsolate(input);
    final rows = deserializeReportRows(rowsData);

    expect(rows.map((row) => row.label).toList(), <String>[
      'Cliente A',
      'Cliente B',
      'Cliente C',
    ]);
  });
}
