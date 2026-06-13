import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';

/// Client-facing catalog item backed by Firestore `tripPackages`.
class CatalogPackage {
  const CatalogPackage({
    required this.id,
    required this.title,
    required this.description,
    required this.destination,
    required this.priceMinor,
    this.photoUrl,
  });

  final String id;
  final String title;
  final String description;
  final String destination;
  final int priceMinor;
  final String? photoUrl;

  double get priceEur => priceMinor / 100.0;

  factory CatalogPackage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final record = AdminTripPackageRecord.fromFirestore(doc);
    return CatalogPackage(
      id: record.id,
      title: record.title,
      description: record.description,
      destination: record.destination,
      priceMinor: (record.priceEur * 100).round(),
      photoUrl: record.photoUrl,
    );
  }
}

/// Reads marketing/catalog prices from Firebase for client screens.
class CatalogRepository {
  CatalogRepository({
    FirebaseFirestore? firestore,
    this.disabled = false,
  }) : _firestore = firestore;

  final FirebaseFirestore? _firestore;
  final bool disabled;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  Stream<List<CatalogPackage>> watchActivePackages() {
    if (disabled) return Stream.value(const []);
    return _db
        .collection('tripPackages')
        .where('isActive', isEqualTo: true)
        .limit(30)
        .snapshots()
        .map((snap) {
      final packages =
          snap.docs.map(CatalogPackage.fromFirestore).toList(growable: false);
      packages.sort((a, b) => a.title.compareTo(b.title));
      return packages;
    });
  }

  Stream<int?> watchCheapestPackageMinor() {
    return watchActivePackages().map((packages) {
      if (packages.isEmpty) return null;
      return packages
          .map((p) => p.priceMinor)
          .reduce((a, b) => a < b ? a : b);
    });
  }

  Stream<int?> watchMinimumBaseFareMinor() {
    if (disabled) return Stream.value(null);
    return _db.collection('transport_types').limit(20).snapshots().map((snap) {
      final minors = snap.docs
          .map(AdminTransportTypeRecord.fromFirestore)
          .where((t) => t.isActive)
          .map((t) => (t.baseFareEur * 100).round())
          .toList();
      if (minors.isEmpty) return null;
      return minors.reduce((a, b) => a < b ? a : b);
    });
  }

  /// Event booking service fee from `config/booking.serviceFee`.
  Stream<int> watchEventServiceFeeMinor() {
    if (disabled) return Stream.value(0);
    return _db.collection('config').doc('booking').snapshots().map((snap) {
      final data = snap.data() ?? {};
      final fee = data['serviceFee'] ?? data['eventServiceFee'];
      if (fee is Map) {
        return (fee['amountMinor'] as num?)?.toInt() ?? 0;
      }
      return (data['serviceFeeMinor'] as num?)?.toInt() ?? 0;
    });
  }
}
