import 'package:cloud_firestore/cloud_firestore.dart';

/// Driver's assigned vehicle from `vehicles/{vehicleId}`.
class DriverVehicle {
  const DriverVehicle({
    required this.id,
    required this.model,
    required this.plate,
    required this.isActive,
    this.batteryPercent,
  });

  final String id;
  final String model;
  final String plate;
  final bool isActive;
  final int? batteryPercent;

  factory DriverVehicle.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final battery = data['batteryPercent'] as num? ??
        data['batteryLevel'] as num?;
    return DriverVehicle(
      id: doc.id,
      model: data['model'] as String? ?? '',
      plate: data['plate'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      batteryPercent: battery?.round(),
    );
  }

  String get batteryLabel =>
      batteryPercent == null ? '—' : '$batteryPercent%';
}
