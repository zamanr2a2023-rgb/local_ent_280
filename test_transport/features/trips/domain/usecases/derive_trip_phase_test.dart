import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/trips/domain/entities/trip_payment_status.dart';
import 'package:local_transport/features/trips/domain/entities/trip_phase.dart';
import 'package:local_transport/features/trips/domain/entities/trip_state.dart';
import 'package:local_transport/features/trips/domain/usecases/derive_trip_phase.dart';

void main() {
  group('DeriveTripPhase', () {
    const deriveTripPhase = DeriveTripPhase();

    test('maps pending states', () {
      expect(deriveTripPhase.fromState(TripState.requested), TripPhase.pending);
      expect(
        deriveTripPhase.fromState(TripState.driverAssignedWaitingAcceptance),
        TripPhase.pending,
      );
      expect(
        deriveTripPhase.fromState(TripState.driverDeclined),
        TripPhase.pending,
      );
    });

    test('maps in-progress states', () {
      expect(
        deriveTripPhase.fromState(TripState.driverAccepted),
        TripPhase.inProgress,
      );
      expect(
        deriveTripPhase.fromState(TripState.driverEnRoute),
        TripPhase.inProgress,
      );
      expect(
        deriveTripPhase.fromState(TripState.driverArrived),
        TripPhase.inProgress,
      );
      expect(deriveTripPhase.fromState(TripState.inTrip), TripPhase.inProgress);
    });

    test('maps post-trip pending payment states', () {
      expect(
        deriveTripPhase.fromState(TripState.arrivedDestination),
        TripPhase.postTripPendingPayment,
      );
      expect(
        deriveTripPhase.fromState(TripState.extensionWindow),
        TripPhase.postTripPendingPayment,
      );
    });

    test('maps finalized states', () {
      expect(
        deriveTripPhase.fromState(TripState.completed),
        TripPhase.finalized,
      );
      expect(
        deriveTripPhase.fromState(TripState.chargeApplied),
        TripPhase.finalized,
      );
      expect(
        deriveTripPhase.fromState(TripState.noDriversAvailable),
        TripPhase.finalized,
      );
      expect(
        deriveTripPhase.fromState(TripState.cancelledByClient),
        TripPhase.finalized,
      );
      expect(
        deriveTripPhase.fromState(TripState.cancelledByDriver),
        TripPhase.finalized,
      );
      expect(deriveTripPhase.fromState(TripState.noShow), TripPhase.finalized);
    });

    test('finalizes post-trip states when payment is terminal', () {
      expect(
        deriveTripPhase.fromState(
          TripState.arrivedDestination,
          paymentStatus: TripPaymentStatus.paid,
        ),
        TripPhase.finalized,
      );
      expect(
        deriveTripPhase.fromState(
          TripState.extensionWindow,
          paymentStatus: TripPaymentStatus.failed,
        ),
        TripPhase.finalized,
      );
    });
  });
}
