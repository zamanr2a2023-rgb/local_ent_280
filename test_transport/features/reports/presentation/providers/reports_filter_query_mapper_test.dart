import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/entities/sort_order.dart';
import 'package:local_transport/features/reports/domain/entities/report_debt_filter.dart';
import 'package:local_transport/features/reports/domain/entities/report_sort.dart';
import 'package:local_transport/features/reports/domain/entities/report_type.dart';
import 'package:local_transport/features/reports/presentation/providers/reports_filter_query_mapper.dart';
import 'package:local_transport/features/reports/presentation/providers/reports_filter_state.dart';

void main() {
  test('maps filter state to query including sort contract', () {
    final state = ReportsFilterState(
      type: ReportType.vehicle,
      dateRange: DateTimeRange(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31, 23, 59),
      ),
      debtFilter: ReportDebtFilter.withDebt,
      searchText: 'cliente a',
      clientSearchText: 'cliente 1',
      driverSearchText: 'motorista 1',
      vehicleSearchText: 'AA-11-BB',
      sortBy: ReportSortBy.tripCount,
      sortOrder: SortOrder.ascending,
    );

    final query = buildReportQueryFromFilter(state);

    expect(query.type, ReportType.vehicle);
    expect(query.debtFilter, ReportDebtFilter.withDebt);
    expect(query.dateRange.start, DateTime(2026, 1, 1));
    expect(query.dateRange.end, DateTime(2026, 1, 31, 23, 59));
    expect(query.searchText, 'cliente a');
    expect(query.clientSearchText, 'cliente 1');
    expect(query.driverSearchText, 'motorista 1');
    expect(query.vehicleSearchText, isNull);
    expect(query.sort.by, ReportSortBy.tripCount);
    expect(query.sort.order, SortOrder.ascending);
  });

  test('hides driver search for driver report type', () {
    final state = ReportsFilterState(
      type: ReportType.driver,
      dateRange: DateTimeRange(
        start: DateTime(2026, 2, 1),
        end: DateTime(2026, 2, 28, 23, 59),
      ),
      debtFilter: ReportDebtFilter.all,
      searchText: '',
      clientSearchText: '',
      driverSearchText: 'driver hidden',
      vehicleSearchText: 'still visible',
      sortBy: ReportSortBy.totalCost,
      sortOrder: SortOrder.descending,
    );

    final query = buildReportQueryFromFilter(state);

    expect(query.driverSearchText, isNull);
    expect(query.vehicleSearchText, 'still visible');
  });

  test(
    'preserves midnight date range end for datasource exclusive [from,to) window',
    () {
      final state = ReportsFilterState(
        type: ReportType.period,
        dateRange: DateTimeRange(
          start: DateTime(2026, 3, 1),
          end: DateTime(2026, 3, 31),
        ),
        debtFilter: ReportDebtFilter.all,
        searchText: '',
        clientSearchText: '',
        driverSearchText: '',
        vehicleSearchText: '',
        sortBy: ReportSortBy.label,
        sortOrder: SortOrder.ascending,
      );

      final query = buildReportQueryFromFilter(state);

      expect(query.dateRange.start, DateTime(2026, 3, 1));
      expect(query.dateRange.end, DateTime(2026, 3, 31));
    },
  );
}
