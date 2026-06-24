import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/trips/domain/entities/trip.dart';
import 'package:local_transport/features/trips/domain/entities/trip_extension_request.dart';
import 'package:local_transport/features/trips/domain/entities/trip_extension_status.dart';
import 'package:local_transport/features/trips/domain/entities/trip_location.dart';
import 'package:local_transport/features/trips/domain/entities/trip_package_coverage.dart';
import 'package:local_transport/features/trips/domain/entities/trip_participants.dart';
import 'package:local_transport/features/trips/domain/entities/trip_pricing_snapshot.dart';
import 'package:local_transport/features/trips/domain/entities/trip_receipt.dart';
import 'package:local_transport/features/trips/domain/entities/trip_state.dart';
import 'package:local_transport/features/trips/domain/entities/trip_timestamps.dart';
import 'package:local_transport/features/trips/domain/entities/trip_transport_type.dart';
import 'package:local_transport/features/trips/domain/usecases/build_client_trip_summary.dart';

void main() {
  const useCase = BuildClientTripSummary();

  group('BuildClientTripSummary', () {
    test('returns null final cost for package-covered trip', () {
      final summary = useCase(
        _buildTrip(
          packageCoverage: const TripPackageCoverage(
            bookingId: 'booking_1',
            packageId: 'package_1',
            snapshotVersion: 2,
            isIncludedFare: true,
          ),
        ),
      );

      expect(summary, isNotNull);
      expect(summary!.finalCostMinor, isNull);
    });

    test('keeps receipt total for non-package trip', () {
      final summary = useCase(_buildTrip());

      expect(summary, isNotNull);
      expect(summary!.finalCostMinor, 3200);
    });
  });
}

Trip _buildTrip({TripPackageCoverage? packageCoverage}) {
  return Trip(
    id: 'trip_1',
    state: TripState.chargeApplied,
    participants: const TripParticipants(clientId: 'client_1'),
    pickup: const TripLocation(
      latitude: 14.9,
      longitude: -23.5,
      address: 'Hotel',
    ),
    destination: const TripLocation(
      latitude: 14.91,
      longitude: -23.52,
      address: 'Praia central',
    ),
    transportType: const TripTransportType(id: 'standard', name: 'Standard'),
    pricingSnapshot: TripPricingSnapshot(
      base: const Money(amountMinor: 500, currency: CurrencyCode.eur),
      perKm: const Money(amountMinor: 200, currency: CurrencyCode.eur),
      perWaitMinute: const Money(amountMinor: 50, currency: CurrencyCode.eur),
      lateCancellationFee: const Money(
        amountMinor: 0,
        currency: CurrencyCode.eur,
      ),
      noShowFee: const Money(amountMinor: 0, currency: CurrencyCode.eur),
      estimatedTotal: const Money(
        amountMinor: 3200,
        currency: CurrencyCode.eur,
      ),
    ),
    timestamps: TripTimestamps(
      requestedAt: DateTime.utc(2026, 6, 1, 10),
      updatedAt: DateTime.utc(2026, 6, 1, 10, 30),
    ),
    extensionRequest: const TripExtensionRequest(
      status: TripExtensionStatus.none,
    ),
    receipt: const TripReceipt(
      baseMinor: 500,
      distanceChargeMinor: 2400,
      waitChargeMinor: 0,
      penaltiesMinor: 0,
      surchargeMinor: 0,
      subtotalMinor: 2900,
      discountMinor: 0,
      multiplier: 1.1,
      multiplierChargeMinor: 300,
      totalMinor: 3200,
      totalDistanceKm: 12,
      totalMinutes: 35,
      totalWaitMinutes: 0,
      hasMeteringData: true,
    ),
    packageCoverage: packageCoverage,
  );
}
