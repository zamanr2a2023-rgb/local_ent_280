import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/client/domain/entities/trip_draft.dart';
import 'package:local_transport/features/client/domain/entities/transport_type.dart';
import 'package:local_transport/features/client/presentation/providers/trip_preview_provider.dart';
import 'package:local_transport/features/pricing/domain/entities/tariff.dart';
import 'package:local_transport/features/pricing/domain/entities/tariff_penalty_fees.dart';
import 'package:local_transport/features/pricing/domain/usecases/estimate_trip_price_breakdown.dart';
import 'package:local_transport/features/pricing/domain/usecases/get_current_tariff.dart';
import 'package:local_transport/features/pricing/domain/usecases/resolve_tariff_multiplier.dart';
import 'package:local_transport/features/trips/domain/entities/trip_route_estimate.dart';
import 'package:local_transport/features/trips/domain/entities/trip_route_point.dart';
import 'package:local_transport/features/trips/domain/repositories/trip_route_repository.dart';
import 'package:local_transport/features/trips/domain/usecases/calculate_points_bounds.dart';
import 'package:local_transport/features/trips/domain/usecases/calculate_route_bounds.dart';
import 'package:local_transport/features/trips/domain/usecases/get_trip_route.dart';
import 'package:local_transport/features/pricing/domain/repositories/current_tariff_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TripPreviewController staleness', () {
    setUp(() {
      WidgetsBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
    });

    test('marks estimate as stale after threshold callback', () async {
      final draft = _buildDraft();
      final route = _buildRoute();
      final tariff = _buildTariff();
      var now = DateTime(2026, 3, 5, 10, 0);
      late Duration scheduledDuration;
      late void Function() scheduledCallback;

      final controller = TripPreviewController.configured(
        getTripRoute: GetTripRoute(_TripRouteRepositoryStub(route)),
        getCurrentTariff: GetCurrentTariff(
          _CurrentTariffRepositoryStub(tariff),
        ),
        estimateTripPriceBreakdown: const EstimateTripPriceBreakdown(),
        resolveTariffMultiplier: const ResolveTariffMultiplier(),
        calculateRouteBounds: const CalculateRouteBounds(),
        calculatePointsBounds: const CalculatePointsBounds(),
        draft: null,
        now: () => now,
        scheduleTimer: (duration, callback) {
          scheduledDuration = duration;
          scheduledCallback = callback;
          return Timer(const Duration(days: 1), () {});
        },
      );

      await controller.recalculate(draft);

      expect(controller.state.priceBreakdown, isNotNull);
      expect(controller.state.isStale, isFalse);
      expect(scheduledDuration, TripPreviewController.staleThreshold);

      now = now.add(const Duration(seconds: 121));
      scheduledCallback();

      expect(controller.state.isStale, isTrue);
      controller.dispose();
    });

    test(
      'manual recalculate renews reference time and clears stale state',
      () async {
        final draft = _buildDraft();
        final route = _buildRoute();
        final tariff = _buildTariff();
        var now = DateTime(2026, 3, 5, 10, 0);
        late void Function() scheduledCallback;

        final controller = TripPreviewController.configured(
          getTripRoute: GetTripRoute(_TripRouteRepositoryStub(route)),
          getCurrentTariff: GetCurrentTariff(
            _CurrentTariffRepositoryStub(tariff),
          ),
          estimateTripPriceBreakdown: const EstimateTripPriceBreakdown(),
          resolveTariffMultiplier: const ResolveTariffMultiplier(),
          calculateRouteBounds: const CalculateRouteBounds(),
          calculatePointsBounds: const CalculatePointsBounds(),
          draft: null,
          now: () => now,
          scheduleTimer: (duration, callback) {
            scheduledCallback = callback;
            return Timer(const Duration(days: 1), () {});
          },
        );

        await controller.recalculate(draft);
        final firstReference = controller.state.pricingReferenceAt;

        now = now.add(const Duration(seconds: 121));
        scheduledCallback();
        expect(controller.state.isStale, isTrue);

        now = now.add(const Duration(seconds: 5));
        await controller.recalculate(draft);

        expect(controller.state.isStale, isFalse);
        expect(controller.state.pricingReferenceAt, isNotNull);
        expect(
          controller.state.pricingReferenceAt!.isAfter(firstReference!),
          isTrue,
        );
        controller.dispose();
      },
    );
  });
}

TripDraft _buildDraft() {
  return const TripDraft(
    destinationLatitude: 14.92,
    destinationLongitude: -23.51,
    destinationAddress: 'Destino',
    pickupLatitude: 14.9,
    pickupLongitude: -23.5,
    pickupAddress: 'Recolha',
    transportType: TransportType(
      id: 'standard',
      name: 'Standard',
      description: 'Padrão',
      packagePriceMultiplierBasisPoints: 10000,
    ),
  );
}

TripRouteEstimate _buildRoute() {
  return const TripRouteEstimate(
    distanceKm: 8.4,
    durationMinutes: 18,
    isFallback: false,
    polylinePoints: <TripRoutePoint>[
      TripRoutePoint(latitude: 14.9, longitude: -23.5),
      TripRoutePoint(latitude: 14.92, longitude: -23.51),
    ],
  );
}

Tariff _buildTariff() {
  return Tariff(
    id: 'tariff_1',
    baseByTransportType: const {
      'standard': Money(amountMinor: 200, currency: CurrencyCode.eur),
    },
    perKm: const Money(amountMinor: 150, currency: CurrencyCode.eur),
    perWaitMinute: const Money(amountMinor: 5, currency: CurrencyCode.eur),
    penaltyFees: const TariffPenaltyFees.empty(),
  );
}

class _TripRouteRepositoryStub implements TripRouteRepository {
  const _TripRouteRepositoryStub(this.route);

  final TripRouteEstimate route;

  @override
  Future<TripRouteEstimate> fetchRoute({
    required TripRoutePoint origin,
    required TripRoutePoint destination,
  }) async {
    return route;
  }
}

class _CurrentTariffRepositoryStub implements CurrentTariffRepository {
  const _CurrentTariffRepositoryStub(this.tariff);

  final Tariff tariff;

  @override
  Future<Tariff> fetchCurrentTariff() async {
    return tariff;
  }
}
