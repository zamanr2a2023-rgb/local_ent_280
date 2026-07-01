import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? adminTimestamp(dynamic value) {
  if (value is Timestamp) return value.toDate();
  return null;
}

/// Converts Firestore field values into JSON-encodable primitives.
dynamic firestoreToJsonEncodable(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate().toIso8601String();
  if (value is DateTime) return value.toIso8601String();
  if (value is GeoPoint) {
    return {'latitude': value.latitude, 'longitude': value.longitude};
  }
  if (value is DocumentReference) return value.path;
  if (value is Map) {
    return Map<String, dynamic>.from(value).map(
      (key, nested) => MapEntry(key, firestoreToJsonEncodable(nested)),
    );
  }
  if (value is Iterable && value is! String) {
    return value.map(firestoreToJsonEncodable).toList();
  }
  return value;
}

String formatFirestoreMapAsJson(Map<String, dynamic> data) {
  try {
    final encoded = firestoreToJsonEncodable(data);
    if (encoded is! Map) return '{}';
    return const JsonEncoder.withIndent('  ').convert(encoded);
  } catch (_) {
    return formatTariffSummary(data);
  }
}

int adminMoneyMinor(dynamic value) {
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    return (map['amountMinor'] as num?)?.toInt() ?? 0;
  }
  if (value is num) return value.round();
  return 0;
}

String adminMoneyFormatted(dynamic value) {
  if (value is! Map) return '—';
  final map = Map<String, dynamic>.from(value);
  final minor = (map['amountMinor'] as num?)?.toInt() ?? 0;
  final currency = map['currency'] as String? ?? 'EUR';
  return '${(minor / 100).toStringAsFixed(2)} $currency';
}

String formatTariffSummary(Map<String, dynamic> data) {
  if (data.isEmpty) return 'No tariff data';

  final lines = <String>[];
  if (data['perKm'] != null) {
    lines.add('Per km: ${adminMoneyFormatted(data['perKm'])}');
  }
  if (data['perWaitMinute'] != null) {
    lines.add('Per wait minute: ${adminMoneyFormatted(data['perWaitMinute'])}');
  }

  final baseByType = data['baseByTransportType'];
  if (baseByType is Map) {
    for (final entry in Map<String, dynamic>.from(baseByType).entries) {
      lines.add('Base (${entry.key}): ${adminMoneyFormatted(entry.value)}');
    }
  }

  final tiers = data['distanceTiers'];
  if (tiers is List && tiers.isNotEmpty) {
    lines.add('Distance tiers: ${tiers.length}');
    for (var i = 0; i < tiers.length; i++) {
      final tier = tiers[i];
      if (tier is! Map) continue;
      final map = Map<String, dynamic>.from(tier);
      final start = map['startMetersInclusive'] ?? map['startKm'] ?? 0;
      final end = map['endKm'] ?? map['endMetersExclusive'];
      final rate = adminMoneyFormatted(map['perKm']);
      lines.add(
        end == null
            ? '  Tier ${i + 1}: from $start m · $rate'
            : '  Tier ${i + 1}: $start–$end m · $rate',
      );
    }
  }

  final multipliers = data['multiplierRules'];
  if (multipliers is List && multipliers.isNotEmpty) {
    lines.add('Multiplier rules: ${multipliers.length}');
    for (final rule in multipliers) {
      if (rule is! Map) continue;
      final map = Map<String, dynamic>.from(rule);
      final label = map['label'] ?? map['name'] ?? 'Rule';
      final mult = map['multiplier'];
      lines.add('  $label: ${mult ?? '—'}x');
    }
  }

  final penalties = data['penaltyFees'];
  if (penalties is Map) {
    final map = Map<String, dynamic>.from(penalties);
    if (map['lateCancellation'] != null) {
      lines.add(
        'Late cancellation: ${adminMoneyFormatted(map['lateCancellation'])}',
      );
    }
    if (map['noShow'] != null) {
      lines.add('No show: ${adminMoneyFormatted(map['noShow'])}');
    }
  }

  final updated = adminTimestamp(data['updatedAt']);
  if (updated != null) {
    lines.add('Updated: ${updated.toLocal()}');
  }

  return lines.isEmpty ? 'No tariff fields loaded' : lines.join('\n');
}

class AdminUserRecord {
  const AdminUserRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    this.photoUrl,
    this.managerPermissions,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isActive;
  final String? photoUrl;
  final Map<String, dynamic>? managerPermissions;
  final DateTime? updatedAt;

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return email.isNotEmpty ? email[0].toUpperCase() : '?';
    }
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory AdminUserRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AdminUserRecord(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: data['role'] as String? ?? 'client',
      isActive: data['isActive'] as bool? ?? false,
      photoUrl: data['photoUrl'] as String?,
      managerPermissions:
          data['managerPermissions'] as Map<String, dynamic>?,
      updatedAt: adminTimestamp(data['updatedAt']),
    );
  }
}

class AdminVehicleRecord {
  const AdminVehicleRecord({
    required this.id,
    required this.make,
    required this.model,
    required this.plate,
    required this.isActive,
    this.capacity,
    this.assignedDriverId,
    this.assignedDriverName,
  });

  final String id;
  final String make;
  final String model;
  final String plate;
  final bool isActive;
  final int? capacity;
  final String? assignedDriverId;
  final String? assignedDriverName;

  String get label {
    final name = make.trim().isNotEmpty ? make.trim() : model.trim();
    return [if (name.isNotEmpty) name, if (plate.trim().isNotEmpty) plate.trim()]
        .join(' • ');
  }

  factory AdminVehicleRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    String? assignedDriverId,
    String? assignedDriverName,
  }) {
    final data = doc.data() ?? {};
    return AdminVehicleRecord(
      id: doc.id,
      make: data['make'] as String? ?? '',
      model: data['model'] as String? ?? '',
      plate: data['plate'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      capacity: (data['capacity'] as num?)?.toInt(),
      assignedDriverId: assignedDriverId,
      assignedDriverName: assignedDriverName,
    );
  }
}

class AdminSupportRequestRecord {
  const AdminSupportRequestRecord({
    required this.id,
    required this.status,
    required this.displayName,
    required this.role,
    required this.subject,
    required this.message,
    required this.requestedAt,
    this.userId,
    this.chatThreadId,
  });

  final String id;
  final String status;
  final String displayName;
  final String role;
  final String subject;
  final String message;
  final DateTime? requestedAt;
  final String? userId;
  final String? chatThreadId;

  bool get isOpen => status.toLowerCase() == 'open';

  factory AdminSupportRequestRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AdminSupportRequestRecord(
      id: doc.id,
      status: data['status'] as String? ?? 'unknown',
      displayName: data['displayName'] as String? ??
          data['userId'] as String? ??
          '—',
      role: data['role'] as String? ?? '—',
      subject: data['subject'] as String? ?? data['type'] as String? ?? '—',
      message: data['message'] as String? ?? '',
      requestedAt: adminTimestamp(data['requestedAt']),
      userId: data['userId'] as String?,
      chatThreadId: data['chatThreadId'] as String?,
    );
  }
}

class AdminIncidentRecord {
  const AdminIncidentRecord({
    required this.id,
    required this.driverName,
    required this.incidentType,
    required this.status,
    required this.currentState,
    required this.tripId,
    required this.startedAt,
    required this.latestLatitude,
    required this.latestLongitude,
    required this.kmSummary,
  });

  final String id;
  final String driverName;
  final String incidentType;
  final String status;
  final String currentState;
  final String tripId;
  final DateTime? startedAt;
  final double? latestLatitude;
  final double? latestLongitude;
  final String kmSummary;

  factory AdminIncidentRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final latest = data['latestCoordinates'] as Map<String, dynamic>?;
    final totalEvidence =
        data['totalEvidence'] as Map<String, dynamic>? ?? {};
    final actual = (totalEvidence['actualKm'] as num?)?.toDouble() ?? 0;
    final expected = (totalEvidence['expectedKm'] as num?)?.toDouble() ?? 0;
    final delta = (totalEvidence['deltaKm'] as num?)?.toDouble() ??
        (actual - expected);

    return AdminIncidentRecord(
      id: doc.id,
      driverName: data['driverName'] as String? ??
          data['driverId'] as String? ??
          '—',
      incidentType: data['incidentType'] as String? ?? '—',
      status: data['status'] as String? ?? 'open',
      currentState: data['currentState'] as String? ?? '—',
      tripId: data['tripId'] as String? ?? '—',
      startedAt: adminTimestamp(data['startedAt']),
      latestLatitude: (latest?['latitude'] as num?)?.toDouble(),
      latestLongitude: (latest?['longitude'] as num?)?.toDouble(),
      kmSummary:
          '${actual.toStringAsFixed(1)} / ${expected.toStringAsFixed(2)} km · ${delta.toStringAsFixed(2)} km',
    );
  }
}

class AdminBalanceRecord {
  const AdminBalanceRecord({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.amountEur,
    required this.debtLimitEur,
    required this.isDebt,
    required this.hasBalanceDocument,
  });

  final String userId;
  final String userName;
  final String userEmail;
  final double amountEur;
  final double debtLimitEur;
  final bool isDebt;
  final bool hasBalanceDocument;

  factory AdminBalanceRecord.fromFirestoreData({
    required String userId,
    required String userName,
    required String userEmail,
    required Map<String, dynamic> data,
  }) {
    final amountMinor = adminMoneyMinor(data['balance']);
    final debtLimitMinor = adminMoneyMinor(data['debtLimit']);
    return AdminBalanceRecord(
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      amountEur: amountMinor / 100,
      debtLimitEur: debtLimitMinor / 100,
      isDebt: amountMinor < 0,
      hasBalanceDocument: true,
    );
  }

  factory AdminBalanceRecord.fromAmount({
    required String userId,
    required String userName,
    required String userEmail,
    required int amountMinor,
    int debtLimitMinor = -2000,
    bool hasBalanceDocument = false,
  }) {
    return AdminBalanceRecord(
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      amountEur: amountMinor / 100,
      debtLimitEur: debtLimitMinor / 100,
      isDebt: amountMinor < 0,
      hasBalanceDocument: hasBalanceDocument,
    );
  }
}

enum AdminBalanceAdjustmentMode { add, remove, set }

class AdminAuditRecord {
  const AdminAuditRecord({
    required this.id,
    required this.action,
    required this.subjectType,
    required this.subjectId,
    required this.actorEmail,
    required this.createdAt,
    required this.summary,
  });

  final String id;
  final String action;
  final String subjectType;
  final String subjectId;
  final String actorEmail;
  final DateTime? createdAt;
  final String summary;

  factory AdminAuditRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AdminAuditRecord(
      id: doc.id,
      action: data['action'] as String? ?? '—',
      subjectType: data['subjectType'] as String? ?? '—',
      subjectId: data['subjectId'] as String? ?? '—',
      actorEmail: data['actorEmail'] as String? ?? '—',
      createdAt: adminTimestamp(data['createdAt']),
      summary: data['summary'] as String? ??
          data['changeSummary'] as String? ??
          '—',
    );
  }
}

class AdminEventRecord {
  const AdminEventRecord({
    required this.id,
    required this.title,
    required this.message,
    required this.scheduledAt,
    required this.targetCount,
  });

  final String id;
  final String title;
  final String message;
  final DateTime? scheduledAt;
  final int targetCount;

  factory AdminEventRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final targets = data['targetDriverIds'] as List<dynamic>? ?? [];
    return AdminEventRecord(
      id: doc.id,
      title: data['title'] as String? ?? data['type'] as String? ?? '—',
      message: data['message'] as String? ?? data['body'] as String? ?? '',
      scheduledAt: adminTimestamp(data['scheduledAt'] ?? data['sendAt']),
      targetCount: targets.length,
    );
  }
}

class AdminReservationRecord {
  const AdminReservationRecord({
    required this.id,
    required this.clientName,
    required this.pickupAddress,
    required this.scheduledAt,
    required this.status,
  });

  final String id;
  final String clientName;
  final String pickupAddress;
  final DateTime? scheduledAt;
  final String status;

  factory AdminReservationRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final pickup = data['pickup'] as Map<String, dynamic>?;
    return AdminReservationRecord(
      id: doc.id,
      clientName: data['clientName'] as String? ??
          data['clientId'] as String? ??
          '—',
      pickupAddress: pickup?['address'] as String? ?? '—',
      scheduledAt: adminTimestamp(data['scheduledAt'] ?? data['pickupAt']),
      status: data['status'] as String? ?? '—',
    );
  }
}

class AdminTransportTypeRecord {
  const AdminTransportTypeRecord({
    required this.id,
    required this.name,
    required this.description,
    required this.baseFareEur,
    required this.packageMultiplier,
    required this.packageMultiplierBasisPoints,
    required this.isActive,
  });

  final String id;
  final String name;
  final String description;
  final double baseFareEur;
  final double packageMultiplier;
  final int packageMultiplierBasisPoints;
  final bool isActive;

  factory AdminTransportTypeRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final multiplierBps =
        (data['packagePriceMultiplierBasisPoints'] as num?)?.toInt() ?? 10000;
    return AdminTransportTypeRecord(
      id: doc.id,
      name: data['name'] as String? ?? doc.id,
      description: data['description'] as String? ?? '',
      baseFareEur: adminMoneyMinor(data['baseFare'] ?? data['baseFareMinor']) / 100,
      packageMultiplier: multiplierBps / 10000,
      packageMultiplierBasisPoints: multiplierBps,
      isActive: data['isActive'] as bool? ?? true,
    );
  }
}

class AdminTripPackageRecord {
  const AdminTripPackageRecord({
    required this.id,
    required this.title,
    required this.destination,
    required this.description,
    required this.priceEur,
    required this.isActive,
    this.photoUrl,
    this.transportTypeCount,
  });

  final String id;
  final String title;
  final String destination;
  final String description;
  final double priceEur;
  final bool isActive;
  final String? photoUrl;
  final int? transportTypeCount;

  factory AdminTripPackageRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final allowed = data['allowedTransportTypes'];
    return AdminTripPackageRecord(
      id: doc.id,
      title: data['name'] as String? ?? data['title'] as String? ?? doc.id,
      destination: data['destinationLabel'] as String? ??
          (data['destination'] is Map
              ? (data['destination'] as Map)['address'] as String?
              : null) ??
          data['destinationAddress'] as String? ??
          '—',
      description: data['description'] as String? ?? '',
      priceEur: adminMoneyMinor(data['price'] ?? data['fixedPrice']) / 100,
      isActive: data['isActive'] as bool? ?? true,
      photoUrl: data['photoUrl'] as String?,
      transportTypeCount: allowed is List ? allowed.length : null,
    );
  }
}

class AdminConfigSnapshot {
  const AdminConfigSnapshot({
    required this.docId,
    required this.data,
    required this.exists,
  });

  final String docId;
  final Map<String, dynamic> data;
  final bool exists;
}

class AdminCreateUserDraft {
  const AdminCreateUserDraft({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
  });

  final String name;
  final String email;
  final String password;
  final String phone;
  final String role;

  static const roles = ['client', 'driver', 'manager', 'admin'];
}
