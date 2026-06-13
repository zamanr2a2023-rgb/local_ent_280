import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:local_ent_280/core/data/trip_confirm_data.dart';

/// Uber-style transport tier with distance-based pricing.
class TransportTypeOption {
  const TransportTypeOption({
    required this.id,
    required this.label,
    required this.baseFare,
    required this.perKmRate,
    required this.icon,
    required this.sortOrder,
  });

  final String id;
  final String label;
  final double baseFare;
  final double perKmRate;
  final IconData icon;
  final int sortOrder;

  double priceForDistanceKm(double distanceKm) {
    return baseFare + (distanceKm * perKmRate);
  }
}

/// Loads active transport types from Firestore with local fallback.
class TransportTypesService {
  TransportTypesService({FirebaseFirestore? firestore, bool useDefaultsOnly = false})
      : _firestore = firestore,
        _useDefaultsOnly = useDefaultsOnly;

  final FirebaseFirestore? _firestore;
  final bool _useDefaultsOnly;

  static const _defaults = [
    TransportTypeOption(
      id: 'premium',
      label: 'Premium',
      baseFare: 2.5,
      perKmRate: 1.19,
      icon: Icons.directions_car,
      sortOrder: 0,
    ),
    TransportTypeOption(
      id: 'eco',
      label: 'Eco-Eletric',
      baseFare: 2.0,
      perKmRate: 1.05,
      icon: Icons.electric_car,
      sortOrder: 1,
    ),
    TransportTypeOption(
      id: 'shared',
      label: 'Partilhado',
      baseFare: 1.5,
      perKmRate: 0.58,
      icon: Icons.hail,
      sortOrder: 2,
    ),
  ];

  Future<List<TransportTypeOption>> fetchActiveTypes() async {
    if (_useDefaultsOnly) return _defaults;

    try {
      final firestore = _firestore ?? FirebaseFirestore.instance;
      final snapshot = await firestore.collection('transport_types').get();
      if (snapshot.docs.isEmpty) return _defaults;

      final options = snapshot.docs.map(_fromFirestore).whereType<TransportTypeOption>().toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      return options.isEmpty ? _defaults : options;
    } catch (_) {
      return _defaults;
    }
  }

  TransportTypeOption? _fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final isActive = data['isActive'] as bool? ?? true;
    if (!isActive) return null;

    final id = (data['id'] as String?) ?? doc.id;
    final label = data['label'] as String? ?? data['name'] as String? ?? id;
    final baseFare = (data['baseFare'] as num?)?.toDouble() ?? 2.0;
    final perKmRate = (data['perKmRate'] as num?)?.toDouble() ??
        (data['pricePerKm'] as num?)?.toDouble() ??
        1.0;
    final sortOrder = (data['sortOrder'] as num?)?.toInt() ?? 0;

    return TransportTypeOption(
      id: id,
      label: label,
      baseFare: baseFare,
      perKmRate: perKmRate,
      icon: _iconForId(id),
      sortOrder: sortOrder,
    );
  }

  IconData _iconForId(String id) {
    return switch (id) {
      'premium' => Icons.directions_car,
      'eco' => Icons.electric_car,
      'shared' => Icons.hail,
      _ => switch (TripConfirmData.transportOptions.where((o) => o.id == id)) {
            final matches when matches.isNotEmpty => matches.first.icon,
            _ => Icons.local_taxi,
          },
    };
  }
}
