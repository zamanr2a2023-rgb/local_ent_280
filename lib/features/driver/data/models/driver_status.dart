import 'package:cloud_firestore/cloud_firestore.dart';

class DriverStatus {
  const DriverStatus({
    required this.isActive,
    required this.isAvailable,
    required this.availabilityEnabled,
    required this.isBusy,
    this.currentTripId,
    this.vehicleId,
    this.updatedAt,
  });

  final bool isActive;
  final bool isAvailable;
  final bool availabilityEnabled;
  final bool isBusy;
  final String? currentTripId;
  final String? vehicleId;
  final DateTime? updatedAt;

  bool get isDispatchEligible =>
      isActive &&
      availabilityEnabled &&
      isAvailable &&
      vehicleId != null &&
      vehicleId!.trim().isNotEmpty &&
      !isBusy &&
      (currentTripId == null || currentTripId!.trim().isEmpty);

  factory DriverStatus.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return DriverStatus(
      isActive: data['isActive'] as bool? ?? true,
      isAvailable: data['isAvailable'] as bool? ?? false,
      availabilityEnabled: data['availabilityEnabled'] as bool? ?? false,
      isBusy: data['isBusy'] as bool? ?? false,
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
