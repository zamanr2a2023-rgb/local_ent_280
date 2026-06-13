import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';
import 'package:local_ent_280/features/admin/data/models/admin_statement_models.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';

class AdminReportsStatementRepository {
  AdminReportsStatementRepository({
    FirebaseFirestore? firestore,
    this.disabled = false,
  }) : _firestore = firestore;

  final FirebaseFirestore? _firestore;
  final bool disabled;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  Stream<List<AdminBalanceRecord>> watchClients() {
    if (disabled) return Stream.value(const []);
    return _db.collection('balances').limit(200).snapshots().asyncMap(
      (snap) async {
        final rows = <AdminBalanceRecord>[];
        for (final doc in snap.docs) {
          final userDoc = await _db.collection('users').doc(doc.id).get();
          final userData = userDoc.data() ?? {};
          if ((userData['role'] as String? ?? '') != 'client') continue;
          rows.add(
            AdminBalanceRecord.fromFirestoreData(
              userId: doc.id,
              userName: userData['name'] as String? ?? doc.id,
              data: doc.data(),
            ),
          );
        }
        rows.sort((a, b) => a.userName.compareTo(b.userName));
        return rows;
      },
    );
  }

  Stream<List<AdminUserRecord>> watchDrivers() {
    if (disabled) return Stream.value(const []);
    return _db.collection('users').limit(200).snapshots().map((snap) {
      final drivers = snap.docs
          .map(AdminUserRecord.fromFirestore)
          .where((user) => user.role == 'driver' && user.isActive)
          .toList();
      drivers.sort((a, b) => a.name.compareTo(b.name));
      return drivers;
    });
  }

  Future<ClientStatementSummary> buildClientStatement({
    required String clientId,
    required String clientName,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    if (disabled) return ClientStatementSummary.empty;

    final balanceDoc = await _db.collection('balances').doc(clientId).get();
    final balanceData = balanceDoc.data() ?? {};
    final currentBalanceMinor = adminMoneyMinor(balanceData['balance']);

    final adjustmentsSnap = await _db
        .collection('balance_adjustments')
        .where('clientId', isEqualTo: clientId)
        .limit(100)
        .get();

    final tripsSnap = await _db
        .collection('trips')
        .where('clientId', isEqualTo: clientId)
        .limit(200)
        .get();

    final entries = <ClientStatementEntry>[];
    var totalDebits = 0;
    var totalCredits = 0;

    for (final doc in adjustmentsSnap.docs) {
      final data = doc.data();
      final createdAt = adminTimestamp(data['createdAt']);
      if (!_inRange(createdAt, rangeStart, rangeEnd)) continue;
      final delta = adminMoneyMinor(data['delta']);
      final reason = data['reason'] as String? ?? 'Balance adjustment';
      if (delta >= 0) {
        totalCredits += delta;
        entries.add(
          ClientStatementEntry(
            date: createdAt,
            description: reason,
            debitMinor: 0,
            creditMinor: delta,
            reference: doc.id,
          ),
        );
      } else {
        final debit = delta.abs();
        totalDebits += debit;
        entries.add(
          ClientStatementEntry(
            date: createdAt,
            description: reason,
            debitMinor: debit,
            creditMinor: 0,
            reference: doc.id,
          ),
        );
      }
    }

    for (final doc in tripsSnap.docs) {
      final trip = TripRecord.fromFirestore(doc);
      if (trip.status != 'COMPLETED') continue;
      final date = trip.completedAt ?? trip.updatedAt ?? trip.createdAt;
      if (!_inRange(date, rangeStart, rangeEnd)) continue;
      final cost = trip.meteringSnapshot.estimatedCostMinor;
      if (cost <= 0) continue;
      totalDebits += cost;
      entries.add(
        ClientStatementEntry(
          date: date,
          description: 'Trip · ${trip.destination.address}',
          debitMinor: cost,
          creditMinor: 0,
          reference: trip.id,
        ),
      );
    }

    entries.sort((a, b) {
      final aDate = a.date ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.date ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return ClientStatementSummary(
      clientId: clientId,
      clientName: clientName,
      currentBalanceMinor: currentBalanceMinor,
      totalDebitsMinor: totalDebits,
      totalCreditsMinor: totalCredits,
      entries: entries,
    );
  }

  Future<DriverStatementSummary> buildDriverStatement({
    required String driverId,
    required String driverName,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    if (disabled) return DriverStatementSummary.empty;

    final tripsSnap = await _db
        .collection('trips')
        .where('assignedDriverId', isEqualTo: driverId)
        .limit(200)
        .get();

    final entries = <DriverStatementEntry>[];
    var totalKm = 0.0;
    var totalMinutes = 0;
    var totalGross = 0;

    for (final doc in tripsSnap.docs) {
      final trip = TripRecord.fromFirestore(doc);
      if (trip.status != 'COMPLETED') continue;
      final date = trip.completedAt ?? trip.updatedAt ?? trip.createdAt;
      if (!_inRange(date, rangeStart, rangeEnd)) continue;
      final gross = trip.meteringSnapshot.estimatedCostMinor;
      totalKm += trip.meteringSnapshot.totalDistanceKm;
      totalMinutes += trip.meteringSnapshot.totalMinutes;
      totalGross += gross;
      entries.add(
        DriverStatementEntry(
          date: date,
          tripId: trip.id,
          destination: trip.destination.address,
          distanceKm: trip.meteringSnapshot.totalDistanceKm,
          minutes: trip.meteringSnapshot.totalMinutes,
          grossMinor: gross,
          status: trip.status,
        ),
      );
    }

    entries.sort((a, b) {
      final aDate = a.date ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.date ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return DriverStatementSummary(
      driverId: driverId,
      driverName: driverName,
      tripCount: entries.length,
      totalDistanceKm: totalKm,
      totalMinutes: totalMinutes,
      totalGrossMinor: totalGross,
      entries: entries,
    );
  }

  bool _inRange(DateTime? date, DateTime start, DateTime end) {
    if (date == null) return false;
    return !date.isBefore(start) && !date.isAfter(end);
  }
}
