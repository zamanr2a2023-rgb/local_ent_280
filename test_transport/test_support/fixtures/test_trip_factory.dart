import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/trips/domain/entities/trip.dart';
import 'package:local_transport/features/trips/domain/entities/trip_extension_request.dart';
import 'package:local_transport/features/trips/domain/entities/trip_extension_status.dart';
import 'package:local_transport/features/trips/domain/entities/trip_location.dart';
import 'package:local_transport/features/trips/domain/entities/trip_participants.dart';
import 'package:local_transport/features/trips/domain/entities/trip_pricing_snapshot.dart';
import 'package:local_transport/features/trips/domain/entities/trip_state.dart';
import 'package:local_transport/features/trips/domain/entities/trip_timestamps.dart';
import 'package:local_transport/features/trips/domain/entities/trip_transport_type.dart';

Trip buildTestTrip({
  required String id,
  required String pickupAddress,
  required String destinationAddress,
  required DateTime requestedAt,
  TripState state = TripState.requested,
}) {
  const zeroMoney = Money(amountMinor: 0, currency: CurrencyCode.eur);
  return Trip(
    id: id,
    state: state,
    participants: const TripParticipants(clientId: 'client-1'),
    pickup: TripLocation(
      latitude: 38.7223,
      longitude: -9.1393,
      address: pickupAddress,
    ),
    destination: TripLocation(
      latitude: 38.7071,
      longitude: -9.1355,
      address: destinationAddress,
    ),
    transportType: const TripTransportType(id: 'standard', name: 'Standard'),
    pricingSnapshot: const TripPricingSnapshot(
      base: zeroMoney,
      perKm: zeroMoney,
      perWaitMinute: zeroMoney,
      lateCancellationFee: zeroMoney,
      noShowFee: zeroMoney,
    ),
    timestamps: TripTimestamps(requestedAt: requestedAt),
    extensionRequest: const TripExtensionRequest(
      status: TripExtensionStatus.none,
    ),
  );
}
