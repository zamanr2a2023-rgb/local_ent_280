import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/features/trips/data/models/trip_cancellation.dart';
import 'package:local_ent_280/features/trips/data/models/trip_location.dart';

class TripTransportType {
  const TripTransportType({required this.id, required this.name});

  final String id;
  final String name;

  Map<String, dynamic> toFirestore() => {'id': id, 'name': name};

  factory TripTransportType.fromFirestore(Map<String, dynamic>? data) {
    return TripTransportType(
      id: data?['id'] as String? ?? '',
      name: data?['name'] as String? ?? '',
    );
  }
}

class TripClientSupport {
  const TripClientSupport({
    required this.displayName,
    this.phone = '',
    this.averageRating,
    this.isVip = false,
    this.photoUrl,
  });

  final String displayName;
  final String phone;
  final double? averageRating;
  final bool isVip;
  final String? photoUrl;

  Map<String, dynamic> toFirestore() => {
        'displayName': displayName,
        'phone': phone,
        if (averageRating != null) 'averageRating': averageRating,
        if (isVip) 'isVip': isVip,
        if (photoUrl != null && photoUrl!.trim().isNotEmpty)
          'photoUrl': photoUrl,
      };

  factory TripClientSupport.fromFirestore(Map<String, dynamic>? data) {
    final ratingValue = data?['averageRating'];
    return TripClientSupport(
      displayName: data?['displayName'] as String? ?? '',
      phone: data?['phone'] as String? ?? '',
      averageRating: ratingValue is num ? ratingValue.toDouble() : null,
      isVip: data?['isVip'] as bool? ?? false,
      photoUrl: data?['photoUrl'] as String?,
    );
  }
}

class TripDriverSummary {
  const TripDriverSummary({
    required this.displayName,
    this.photoUrl,
    this.phone,
  });

  final String displayName;
  final String? photoUrl;
  final String? phone;

  Map<String, dynamic> toFirestore() => {
        'displayName': displayName,
        if (photoUrl != null && photoUrl!.isNotEmpty) 'photoUrl': photoUrl,
        if (phone != null && phone!.isNotEmpty) 'phone': phone,
      };

  factory TripDriverSummary.fromFirestore(Map<String, dynamic>? data) {
    return TripDriverSummary(
      displayName: data?['displayName'] as String? ?? '',
      photoUrl: data?['photoUrl'] as String?,
      phone: data?['phone'] as String?,
    );
  }
}

class TripMeteringSnapshot {
  const TripMeteringSnapshot({
    required this.totalDistanceKm,
    required this.totalMinutes,
    required this.totalWaitMinutes,
    required this.estimatedCostMinor,
  });

  final double totalDistanceKm;
  final int totalMinutes;
  final int totalWaitMinutes;
  final int estimatedCostMinor;

  Map<String, dynamic> toFirestore() => {
        'totalDistanceKm': totalDistanceKm,
        'totalMinutes': totalMinutes,
        'totalWaitMinutes': totalWaitMinutes,
        'estimatedCostMinor': estimatedCostMinor,
      };

  factory TripMeteringSnapshot.fromFirestore(Map<String, dynamic>? data) {
    return TripMeteringSnapshot(
      totalDistanceKm: (data?['totalDistanceKm'] as num?)?.toDouble() ?? 0,
      totalMinutes: (data?['totalMinutes'] as num?)?.toInt() ?? 0,
      totalWaitMinutes: (data?['totalWaitMinutes'] as num?)?.toInt() ?? 0,
      estimatedCostMinor: (data?['estimatedCostMinor'] as num?)?.toInt() ?? 0,
    );
  }
}

class TripRecord {
  const TripRecord({
    required this.id,
    required this.clientId,
    required this.pickup,
    required this.destination,
    required this.transportType,
    required this.status,
    required this.meteringSnapshot,
    this.assignedDriverId,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.clientSupport,
    this.driverSummary,
    this.unfulfilledReason,
    this.cancellation,
  });

  final String id;
  final String clientId;
  final TripLocation pickup;
  final TripLocation destination;
  final TripTransportType transportType;
  final String status;
  final TripMeteringSnapshot meteringSnapshot;
  final String? assignedDriverId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final TripClientSupport? clientSupport;
  final TripDriverSummary? driverSummary;
  final String? unfulfilledReason;
  final TripCancellation? cancellation;

  bool get hasAssignedDriver =>
      assignedDriverId != null && assignedDriverId!.trim().isNotEmpty;

  bool get isDriverAssignedStatus =>
      status == 'DRIVER_ASSIGNED_WAITING_ACCEPTANCE' ||
      status == 'DRIVER_ACCEPTED' ||
      status == 'DRIVER_EN_ROUTE';

  String get passengerName =>
      clientSupport?.displayName.trim().isNotEmpty == true
          ? clientSupport!.displayName.trim()
          : 'Passenger';

  String? get passengerRatingLabel {
    final rating = clientSupport?.averageRating;
    if (rating == null) return null;
    return rating.toStringAsFixed(1);
  }

  bool get isVipPassenger => clientSupport?.isVip ?? false;

  String get fareFormatted =>
      AppCurrencyFormatter.instance.formatEurMinor(
        meteringSnapshot.estimatedCostMinor,
      );

  String get tripTypeLabel =>
      transportType.name.trim().isNotEmpty
          ? transportType.name.trim()
          : 'Premium Trip';

  factory TripRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return TripRecord(
      id: doc.id,
      clientId: data['clientId'] as String? ?? '',
      pickup: TripLocation.fromFirestore(
        data['pickup'] as Map<String, dynamic>? ?? {},
      ),
      destination: TripLocation.fromFirestore(
        data['destination'] as Map<String, dynamic>? ?? {},
      ),
      transportType: TripTransportType.fromFirestore(
        data['transportType'] as Map<String, dynamic>?,
      ),
      status: data['status'] as String? ?? 'REQUESTED',
      meteringSnapshot: TripMeteringSnapshot.fromFirestore(
        data['meteringSnapshot'] as Map<String, dynamic>?,
      ),
      assignedDriverId: data['assignedDriverId'] as String?,
      isActive: data['isActive'] as bool? ?? false,
      createdAt: _timestampToDate(data['createdAt']),
      updatedAt: _timestampToDate(data['updatedAt']),
      completedAt: _timestampToDate(data['completedAt']),
      clientSupport: TripClientSupport.fromFirestore(
        data['clientSupport'] as Map<String, dynamic>?,
      ),
      driverSummary: data['driverSummary'] is Map<String, dynamic>
          ? TripDriverSummary.fromFirestore(
              data['driverSummary'] as Map<String, dynamic>,
            )
          : null,
      unfulfilledReason: data['unfulfilledReason'] as String?,
      cancellation: data['cancellation'] is Map<String, dynamic>
          ? TripCancellation.fromFirestore(
              data['cancellation'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  static DateTime? _timestampToDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
