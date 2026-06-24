import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_ent_280/core/data/reservations_data.dart';

class ClientReservationRecord {
  const ClientReservationRecord({
    required this.id,
    required this.scheduledAt,
    required this.pickup,
    required this.destination,
    required this.status,
    this.vehicleInfo,
    this.transportTypeName,
  });

  final String id;
  final DateTime? scheduledAt;
  final String pickup;
  final String destination;
  final ReservationStatus status;
  final String? vehicleInfo;
  final String? transportTypeName;

  ReservationItem toItem() {
    final date = scheduledAt;
    final dateLabel = date == null
        ? '—'
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final timeLabel = date == null
        ? '—'
        : '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final meta = transportTypeName == null || transportTypeName!.isEmpty
        ? '$timeLabel · ${status.label}'
        : '$timeLabel · $transportTypeName';

    return ReservationItem(
      id: id,
      date: dateLabel,
      timeMeta: meta,
      pickup: pickup,
      destination: destination,
      status: status,
      vehicleInfo: vehicleInfo,
    );
  }
}

class ReservationRepository {
  ReservationRepository({
    FirebaseFirestore? firestore,
    this.disabled = false,
    List<ClientReservationRecord>? mockReservations,
  })  : _firestore = firestore,
        _mockReservations = mockReservations;

  final FirebaseFirestore? _firestore;
  final bool disabled;
  final List<ClientReservationRecord>? _mockReservations;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  DateTime? _timestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  String _locationAddress(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value['address'] as String? ?? '—';
    }
    return '—';
  }

  ReservationStatus _mapStatus(String? raw) {
    return switch (raw?.toLowerCase()) {
      'confirmed' || 'scheduled' => ReservationStatus.confirmada,
      'pending' => ReservationStatus.pendente,
      _ => ReservationStatus.pendente,
    };
  }

  ClientReservationRecord _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final transport = data['transportType'] as Map<String, dynamic>?;
    return ClientReservationRecord(
      id: doc.id,
      scheduledAt: _timestamp(data['scheduledAt']),
      pickup: _locationAddress(data['pickup']),
      destination: _locationAddress(data['destination']),
      status: _mapStatus(data['status'] as String?),
      transportTypeName: transport?['name'] as String?,
      vehicleInfo: data['vehicleLabel'] as String?,
    );
  }

  Stream<List<ClientReservationRecord>> watchClientReservations(
    String clientId,
  ) {
    if (disabled) {
      return Stream<List<ClientReservationRecord>>.value(
        _mockReservations ?? const [],
      );
    }
    return _db
        .collection('reservations')
        .where('clientId', isEqualTo: clientId)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      final records = snapshot.docs.map(_fromDoc).toList();
      records.sort((a, b) {
        final aDate = a.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return records;
    });
  }

  Future<String> createVehicleRentalReservation({
    required String clientId,
    required String vehicleId,
    required String vehicleLabel,
    required DateTime scheduledAt,
    required String pickupAddress,
    required String returnAddress,
    required double totalEur,
    bool fullInsurance = false,
  }) async {
    if (disabled) return '';
    final ref = _db.collection('reservations').doc();
    await ref.set({
      'source': 'vehicle_rental',
      'clientId': clientId,
      'vehicleId': vehicleId,
      'vehicleLabel': vehicleLabel,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'status': 'pending',
      'pickup': {'address': pickupAddress},
      'destination': {'address': returnAddress},
      'transportType': {'id': 'vehicle_rental', 'name': 'Vehicle rental'},
      'estimatedTotalMinor': (totalEur * 100).round(),
      'fullInsurance': fullInsurance,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}
