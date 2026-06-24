import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_ent_280/features/admin/data/admin_tariff_payload.dart';

class ClientTariff {
  const ClientTariff({
    required this.id,
    required this.baseByTransportType,
    required this.perKmMinor,
    required this.perWaitMinuteMinor,
    required this.lateCancellationMinor,
    required this.noShowMinor,
    required this.distanceTiers,
    required this.multiplierRules,
  });

  final String id;
  final Map<String, int> baseByTransportType;
  final int perKmMinor;
  final int perWaitMinuteMinor;
  final int lateCancellationMinor;
  final int noShowMinor;
  final List<Map<String, dynamic>> distanceTiers;
  final List<dynamic> multiplierRules;

  int baseMinorForTransportType(
    String transportTypeId, {
    int fallbackMinor = 250,
  }) {
    final normalized = transportTypeId.trim();
    return baseByTransportType[normalized] ?? fallbackMinor;
  }

  List<Map<String, dynamic>> resolvedDistanceTiers() {
    if (distanceTiers.isNotEmpty) return distanceTiers;
    return [
      {
        'startMetersInclusive': 0,
        'perKm': eurMoneyMinor(perKmMinor),
      },
    ];
  }
}

/// Loads the public client tariff from Firestore (`tariffs/public_default`).
class ClientTariffService {
  ClientTariffService({FirebaseFirestore? firestore})
      : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  static const _defaultTariffId = 'public_default';

  static final ClientTariff _fallback = ClientTariff(
    id: _defaultTariffId,
    baseByTransportType: const {
      'premium': 250,
      'eco': 200,
      'shared': 150,
      'standard': 250,
    },
    perKmMinor: 120,
    perWaitMinuteMinor: 10,
    lateCancellationMinor: 0,
    noShowMinor: 0,
    distanceTiers: const [
      {
        'startMetersInclusive': 0,
        'perKm': {'amountMinor': 120, 'currency': 'EUR'},
      },
    ],
    multiplierRules: const [],
  );

  Future<ClientTariff> fetchCurrentTariff() async {
    try {
      final firestore = _firestore ?? FirebaseFirestore.instance;
      final doc =
          await firestore.collection('tariffs').doc(_defaultTariffId).get();
      if (!doc.exists) return _fallback;
      return _fromFirestore(doc.data() ?? const {});
    } catch (_) {
      return _fallback;
    }
  }

  ClientTariff _fromFirestore(Map<String, dynamic> data) {
    final baseByTransportType = <String, int>{};
    final rawBase = data['baseByTransportType'];
    if (rawBase is Map) {
      for (final entry in rawBase.entries) {
        final key = entry.key.toString().trim();
        if (key.isEmpty) continue;
        baseByTransportType[key] = readEurMinor(entry.value);
      }
    }

    final perKmMinor = readEurMinor(data['perKm']);
    final distanceTiers = _parseDistanceTiers(data['distanceTiers'], perKmMinor);
    final penaltyFees = data['penaltyFees'];
    final lateCancellationMinor = penaltyFees is Map
        ? readEurMinor(penaltyFees['lateCancellation'])
        : 0;
    final noShowMinor =
        penaltyFees is Map ? readEurMinor(penaltyFees['noShow']) : 0;

    return ClientTariff(
      id: _defaultTariffId,
      baseByTransportType: baseByTransportType.isEmpty
          ? _fallback.baseByTransportType
          : baseByTransportType,
      perKmMinor: perKmMinor > 0 ? perKmMinor : _fallback.perKmMinor,
      perWaitMinuteMinor: readEurMinor(data['perWaitMinute']) > 0
          ? readEurMinor(data['perWaitMinute'])
          : _fallback.perWaitMinuteMinor,
      lateCancellationMinor: lateCancellationMinor,
      noShowMinor: noShowMinor,
      distanceTiers: distanceTiers,
      multiplierRules:
          data['multiplierRules'] is List ? data['multiplierRules'] as List : [],
    );
  }

  List<Map<String, dynamic>> _parseDistanceTiers(
    Object? value,
    int perKmMinor,
  ) {
    if (value is! List || value.isEmpty) {
      return _fallback.distanceTiers
          .map((tier) => Map<String, dynamic>.from(tier))
          .toList();
    }
    return value
        .whereType<Map>()
        .map((tier) => Map<String, dynamic>.from(tier))
        .toList();
  }
}
