Map<String, dynamic> eurMoneyMinor(int minor) => {
      'amountMinor': minor,
      'currency': 'EUR',
    };

int readEurMinor(dynamic value) {
  if (value is Map) {
    return (value['amountMinor'] as num?)?.toInt() ?? 0;
  }
  if (value is num) return value.round();
  return 0;
}

double readEurMajor(dynamic value) => readEurMinor(value) / 100.0;

/// Builds a `saveAdminTariff` callable payload from form values and the
/// currently loaded tariff document (preserves tiers/rules not edited in UI).
Map<String, dynamic> buildAdminTariffCallablePayload({
  required Map<String, dynamic> currentTariff,
  required Map<String, int> baseFareMinorByTransportType,
  required int perKmMinor,
  required int perWaitMinuteMinor,
  required int lateCancellationMinor,
  required int noShowMinor,
}) {
  final distanceTiers = _resolveDistanceTiers(currentTariff, perKmMinor);
  final multiplierRules = currentTariff['multiplierRules'];
  final baseByTransportType = <String, dynamic>{};
  for (final entry in baseFareMinorByTransportType.entries) {
    baseByTransportType[entry.key] = eurMoneyMinor(entry.value);
  }

  return {
    'id': 'admin_default',
    'baseByTransportType': baseByTransportType,
    'perKm': eurMoneyMinor(perKmMinor),
    'perWaitMinute': eurMoneyMinor(perWaitMinuteMinor),
    'distanceTiers': distanceTiers,
    'penaltyFees': {
      'lateCancellation': eurMoneyMinor(lateCancellationMinor),
      'noShow': eurMoneyMinor(noShowMinor),
    },
    'multiplierRules': multiplierRules is List ? multiplierRules : <dynamic>[],
  };
}

List<Map<String, dynamic>> _resolveDistanceTiers(
  Map<String, dynamic> currentTariff,
  int perKmMinor,
) {
  final existing = currentTariff['distanceTiers'];
  if (existing is List && existing.isNotEmpty) {
    return existing
        .whereType<Map>()
        .map((tier) => Map<String, dynamic>.from(tier))
        .toList();
  }
  return [
    {
      'startMetersInclusive': 0,
      'perKm': eurMoneyMinor(perKmMinor),
    },
  ];
}
