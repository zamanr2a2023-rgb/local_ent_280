import 'package:cloud_firestore/cloud_firestore.dart';

class DriverStatus {
  const DriverStatus({
    required this.isActive,
    required this.isAvailable,
    required this.availabilityEnabled,
    this.currentTripId,
    this.vehicleId,
    this.updatedAt,
  });

  final bool isActive;
  final bool isAvailable;
  final bool availabilityEnabled;
  final String? currentTripId;
  final String? vehicleId;
  final DateTime? updatedAt;

  factory DriverStatus.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return DriverStatus(
      isActive: data['isActive'] as bool? ?? true,
      isAvailable: data['isAvailable'] as bool? ?? false,
      availabilityEnabled: data['availabilityEnabled'] as bool? ?? false,
      currentTripId: data['currentTripId'] as String?,
      vehicleId: data['vehicleId'] as String?,
      updatedAt: _timestampToDate(data['updatedAt']),
    );
  }

  static DateTime? _timestampToDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
