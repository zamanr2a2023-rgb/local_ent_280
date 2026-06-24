import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/reports/domain/entities/client_statement_dataset.dart';
import 'package:local_transport/features/reports/domain/entities/client_statement_page.dart';
import 'package:local_transport/features/reports/domain/entities/client_statement_query.dart';
import 'package:local_transport/features/reports/domain/entities/client_statement_reconciliation.dart';
import 'package:local_transport/features/reports/domain/entities/trip_explorer_dataset.dart';
import 'package:local_transport/features/reports/domain/entities/trip_explorer_page.dart';
import 'package:local_transport/features/reports/domain/entities/trip_explorer_query.dart';
import 'package:local_transport/features/reports/domain/entities/trip_explorer_record.dart';
import 'package:local_transport/features/reports/domain/repositories/client_statement_repository.dart';
import 'package:local_transport/features/reports/domain/repositories/trip_explorer_repository.dart';

class FakeTripExplorerRepository implements TripExplorerRepository {
  const FakeTripExplorerRepository(this.records);

  final List<TripExplorerRecord> records;

  @override
  Future<TripExplorerDataset> fetchDataset(
    TripExplorerQuery query, {
    required int maxRecords,
  }) async {
    return TripExplorerDataset(
      records: records.take(maxRecords).toList(growable: false),
      isComplete: records.length <= maxRecords,
    );
  }

  @override
  Future<TripExplorerPage> fetchPage(TripExplorerQuery query) async {
    return TripExplorerPage(
      records: records.take(query.pageSize).toList(growable: false),
      nextCursor: null,
      hasMore: false,
    );
  }
}

class FakeClientStatementRepository implements ClientStatementRepository {
  const FakeClientStatementRepository();

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
