import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/client/domain/entities/transport_type.dart';
import 'package:local_transport/features/client/domain/entities/trip_draft.dart';
import 'package:local_transport/features/client/domain/usecases/build_trip_request.dart';
import 'package:local_transport/features/pricing/domain/entities/tariff.dart';
import 'package:local_transport/features/pricing/domain/entities/tariff_multiplier_rule.dart';
import 'package:local_transport/features/pricing/domain/entities/tariff_penalty_fees.dart';
import 'package:local_transport/features/pricing/domain/usecases/resolve_tariff_multiplier.dart';
import 'package:local_transport/features/trips/domain/entities/trip_pricing_snapshot.dart';

void main() {
  final useCase = BuildTripRequest(const ResolveTariffMultiplier());

  group('BuildTripRequest', () {
    test(
      'persists combined transport, time range and holiday multiplier lock',
      () {
        final tripStart = DateTime.utc(2026, 12, 25, 8, 30);
        final result = useCase(
          clientId: 'client_1',
          draft: _draft(
            transportType: const TransportType(
              id: 'standard',
              name: 'Standard',
              description: 'Viagem padrão',
              packagePriceMultiplierBasisPoints: 10000,
            ),
          ),
          tariff: _tariff(
            rules: [
              TariffMultiplierRule(
                id: 'time_range_0800_1000',
                type: TariffMultiplierType.timeRange,
                multiplier: 1.2,
                timeRange: const TariffTimeRange(
                  startMinutes: 8 * 60,
                  endMinutes: 10 * 60,
                ),
              ),
              TariffMultiplierRule(
                id: 'holiday_2026_12_25',
                type: TariffMultiplierType.holiday,
                multiplier: 1.5,
                holidayDates: [DateTime(2026, 12, 25)],
              ),
            ],
          ),
          estimatedTotalMinor: 1980,
          tripStart: tripStart,
        );

        expect(result.isSuccess, isTrue);
        final snapshot = result.request!.pricingSnapshot;

        expect(
          snapshot.pricingSchemaVersion,
          TripPricingSnapshot.latestPricingSchemaVersion,
        );
        expect(snapshot.appliedMultiplier, closeTo(1.8, 0.000001));
        expect(
          snapshot.appliedMultiplierId,
          'transport:standard|time:time_range_0800_1000|holiday:holiday_2026_12_25',
        );
        expect(snapshot.base.amountMinor, 500);
        expect(snapshot.resolvedBaseTransportTypeId, 'standard');
        expect(snapshot.resolvedBaseSource, 'tariff.baseByTransportType');
        expect(snapshot.pricingScheduleId, 'time_range_0800_1000');
        expect(snapshot.specialDayId, 'holiday_2026_12_25');
        expect(snapshot.transportMultiplier, isNull);
        expect(snapshot.timeRangeMultiplier, 1.2);
        expect(snapshot.holidayMultiplier, 1.5);
        expect(snapshot.evaluationTimestamp, tripStart);
        expect(snapshot.evaluationTimeZone, 'Europe/Lisbon');
        expect(
          snapshot.multipliers[snapshot.appliedMultiplierId],
          closeTo(1.8, 0.000001),
        );
        expect(snapshot.multipliers['standard'], isNull);
      },
    );

    test('keeps deterministic combined id when no dynamic rule matches', () {
      final result = useCase(
        clientId: 'client_1',
        draft: _draft(
          transportType: const TransportType(
            id: 'premium',
            name: 'Premium',
            description: 'Viagem premium',
            packagePriceMultiplierBasisPoints: 10000,
          ),
        ),
        tariff: _tariff(),
        estimatedTotalMinor: 1400,
        tripStart: DateTime.utc(2026, 3, 20, 11, 0),
      );

      expect(result.isSuccess, isTrue);
      final snapshot = result.request!.pricingSnapshot;

      expect(
        snapshot.appliedMultiplierId,
        'transport:premium|time:none|holiday:none',
      );
      expect(snapshot.appliedMultiplier, 1);
      expect(snapshot.pricingScheduleId, isNull);
      expect(snapshot.specialDayId, isNull);
      expect(snapshot.transportMultiplier, isNull);
      expect(snapshot.timeRangeMultiplier, isNull);
      expect(snapshot.holidayMultiplier, isNull);
    });
  });
}

TripDraft _draft({required TransportType transportType}) {
  return TripDraft(
    destinationLatitude: 14.92,
    destinationLongitude: -23.51,
    destinationAddress: 'Destino',
    pickupLatitude: 14.91,
    pickupLongitude: -23.52,
    pickupAddress: 'Origem',
    transportType: transportType,
  );
}

Tariff _tariff({List<TariffMultiplierRule> rules = const []}) {
  return Tariff(
    id: 'tariff_1',
    baseByTransportType: const {
      'premium': Money(amountMinor: 700, currency: CurrencyCode.eur),
      'standard': Money(amountMinor: 500, currency: CurrencyCode.eur),
    },
    perKm: const Money(amountMinor: 200, currency: CurrencyCode.eur),
    perWaitMinute: const Money(amountMinor: 50, currency: CurrencyCode.eur),
    penaltyFees: const TariffPenaltyFees.empty(),
    multiplierRules: rules,
  );
}
