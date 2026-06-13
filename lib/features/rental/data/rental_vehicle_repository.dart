import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_ent_280/core/constants/app_assets.dart';

class RentalVehicleRecord {
  const RentalVehicleRecord({
    required this.id,
    required this.name,
    required this.pricePerDay,
    required this.imageUrl,
    required this.seats,
    required this.bags,
    required this.hasAc,
    required this.transmissionLabel,
    required this.categoryLabel,
    required this.isPremium,
    required this.isElectric,
    required this.notes,
  });

  final String id;
  final String name;
  final int pricePerDay;
  final String imageUrl;
  final int seats;
  final int bags;
  final bool hasAc;
  final String transmissionLabel;
  final String categoryLabel;
  final bool isPremium;
  final bool isElectric;
  final String notes;

  factory RentalVehicleRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final make = (data['make'] as String? ?? '').trim();
    final model = (data['model'] as String? ?? '').trim();
    final name = [if (make.isNotEmpty) make, if (model.isNotEmpty) model]
        .join(' ')
        .trim()
        .ifEmpty(doc.id);

    final priceMinor = (data['rentalPricePerDayMinor'] as num?)?.toInt() ??
        (data['pricePerDayMinor'] as num?)?.toInt() ??
        9000;
    final category = _normalizeCategory(
      data['vehicleCategory'] as String? ??
          data['category'] as String? ??
          data['defaultTransportType']?['name'] as String?,
    );
    final transmission = _normalizeTransmission(
      data['transmission'] as String? ?? data['transmissionLabel'] as String?,
    );

    return RentalVehicleRecord(
      id: doc.id,
      name: name,
      pricePerDay: (priceMinor / 100).round(),
      imageUrl: (data['photoUrl'] as String?)?.trim().isNotEmpty == true
          ? data['photoUrl'] as String
          : AppAssets.tripHistoryMarinaImage,
      seats: (data['capacity'] as num?)?.toInt() ?? 5,
      bags: (data['bags'] as num?)?.toInt() ?? 2,
      hasAc: data['hasAc'] as bool? ?? true,
      transmissionLabel: transmission,
      categoryLabel: category,
      isPremium: data['isRentalPremium'] as bool? ??
          data['isPremium'] as bool? ??
          priceMinor >= 10000,
      isElectric: data['isElectric'] as bool? ??
          category.toLowerCase().contains('elétric') ||
              category.toLowerCase().contains('electric'),
      notes: data['notes'] as String? ?? '',
    );
  }

  static String _normalizeCategory(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    return switch (value) {
      'suv' => 'SUV',
      'executivo' || 'executive' || 'premium' => 'Executivo',
      'elétrico' || 'eletrico' || 'electric' => 'Elétrico',
      'sedan' || 'sedan' => 'Sedan',
      _ when value.isNotEmpty => raw!.trim(),
      _ => 'Sedan',
    };
  }

  static String _normalizeTransmission(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    return switch (value) {
      'manual' => 'Manual',
      'auto' || 'automatic' || 'automático' || 'automatico' => 'Automático',
      _ => 'Automático',
    };
  }
}

extension _StringEmpty on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

class RentalVehicleRepository {
  RentalVehicleRepository({
    FirebaseFirestore? firestore,
    this.disabled = false,
    List<RentalVehicleRecord>? mockVehicles,
  })  : _firestore = firestore,
        _mockVehicles = mockVehicles;

  final FirebaseFirestore? _firestore;
  final bool disabled;
  final List<RentalVehicleRecord>? _mockVehicles;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  Stream<List<RentalVehicleRecord>> watchActiveVehicles() {
    if (disabled) {
      return Stream<List<RentalVehicleRecord>>.value(_mockVehicles ?? const []);
    }
    return _db
        .collection('vehicles')
        .where('isActive', isEqualTo: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      final records = snapshot.docs.map(RentalVehicleRecord.fromFirestore).toList();
      records.sort((a, b) {
        if (a.isPremium != b.isPremium) return a.isPremium ? -1 : 1;
        return a.pricePerDay.compareTo(b.pricePerDay);
      });
      return records;
    });
  }

  Stream<RentalVehicleRecord?> watchVehicle(String vehicleId) {
    if (disabled) {
      RentalVehicleRecord? match;
      for (final vehicle in _mockVehicles ?? const <RentalVehicleRecord>[]) {
        if (vehicle.id == vehicleId) {
          match = vehicle;
          break;
        }
      }
      return Stream<RentalVehicleRecord?>.value(match);
    }
    return _db.collection('vehicles').doc(vehicleId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final isActive = doc.data()?['isActive'] as bool? ?? true;
      if (!isActive) return null;
      return RentalVehicleRecord.fromFirestore(doc);
    });
  }

  static List<RentalVehicleRecord> applyFilters(
    List<RentalVehicleRecord> vehicles, {
    required String carType,
    required String maxPrice,
    required String transmission,
  }) {
    return vehicles.where((vehicle) {
      if (carType != 'Todos os tipos' &&
          vehicle.categoryLabel.toLowerCase() != carType.toLowerCase()) {
        return false;
      }
      if (maxPrice != 'Qualquer preço') {
        final limit = _maxPriceLimit(maxPrice);
        if (limit != null && vehicle.pricePerDay > limit) return false;
      }
      if (transmission != 'Todas' &&
          vehicle.transmissionLabel.toLowerCase() !=
              transmission.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  static int? _maxPriceLimit(String label) {
    return switch (label) {
      'Até 50€/dia' => 50,
      'Até 100€/dia' => 100,
      'Até 200€/dia' => 200,
      _ => null,
    };
  }
}
