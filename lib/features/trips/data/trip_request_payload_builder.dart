import 'package:local_ent_280/core/services/client_tariff_service.dart';
import 'package:local_ent_280/core/services/trip_price_estimator.dart';
import 'package:local_ent_280/features/admin/data/admin_tariff_payload.dart';
import 'package:local_ent_280/features/trips/data/models/trip_location.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';

/// Builds the `requestTrip` callable payload to match [local_transport].
class TripRequestPayloadBuilder {
  const TripRequestPayloadBuilder({
    TripPriceEstimator estimator = const TripPriceEstimator(),
  }) : _estimator = estimator;

  static const _pricingSchemaVersion = 3;
  static const _evaluationTimeZone = 'Europe/Lisbon';

  final TripPriceEstimator _estimator;

  Map<String, dynamic> build({
    required String clientId,
    required TripLocation pickup,
    required TripLocation destination,
    required TripTransportType transportType,
    required ClientTariff tariff,
    required double distanceKm,
    required int durationMinutes,
    required int estimatedTotalMinor,
    int transportBaseFallbackMinor = 250,
  }) {
    final estimate = _estimator.estimate(
      tariff: tariff,
      transportTypeId: transportType.id,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      transportBaseFallbackMinor: transportBaseFallbackMinor,
    );
    final totalMinor = estimatedTotalMinor > 0
        ? estimatedTotalMinor
        : estimate.totalMinor;
    final baseMinor = tariff.baseMinorForTransportType(
      transportType.id,
      fallbackMinor: transportBaseFallbackMinor,
    );
    final now = DateTime.now().toUtc();

    return {
      'clientId': clientId,
      'pickup': pickup.toFirestore(),
      'destination': destination.toFirestore(),
      'transportType': transportType.toFirestore(),
      'status': 'REQUESTED',
      'pricingSnapshot': {
        'base': eurMoneyMinor(baseMinor),
        'perKm': eurMoneyMinor(tariff.perKmMinor),
        'perWaitMinute': eurMoneyMinor(tariff.perWaitMinuteMinor),
        'distanceTiers': tariff.resolvedDistanceTiers(),
        'lateCancellationFee': eurMoneyMinor(tariff.lateCancellationMinor),
        'noShowFee': eurMoneyMinor(tariff.noShowMinor),
        'pricingSchemaVersion': _pricingSchemaVersion,
        'appliedMultiplierId': estimate.multiplierId,
        'appliedMultiplier': estimate.multiplier,
        'tariffId': tariff.id,
        'resolvedBaseTransportTypeId': transportType.id,
        'resolvedBaseSource': 'tariff.baseByTransportType',
        'evaluationTimestamp': now.toIso8601String(),
        'evaluationTimeZone': _evaluationTimeZone,
        'multipliers': {estimate.multiplierId: estimate.multiplier},
        'estimatedTotal': eurMoneyMinor(totalMinor),
      },
      'meteringSnapshot': {
        'totalMinutes': durationMinutes,
        'totalWaitMinutes': 0,
        'totalDistanceKm': distanceKm,
        'estimatedCostMinor': totalMinor,
      },
      'assignedDriverId': null,
    };
  }
}
