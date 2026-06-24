import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/features/trips/domain/entities/trip_state.dart';
import 'package:local_transport/features/trips/domain/services/trip_state_machine.dart';

void main() {
  group('MVP smoke', () {
    test('currency metadata exponents are explicit', () {
      expect(CurrencyCode.eur.minorUnitExponent, 2);
      expect(CurrencyCode.jpy.minorUnitExponent, 0);
      expect(CurrencyCode.bhd.minorUnitExponent, 3);
    });

    test('money arithmetic enforces same-currency operations', () {
      const a = Money(amountMinor: 1250, currency: CurrencyCode.eur);
      const b = Money(amountMinor: 250, currency: CurrencyCode.eur);
      const c = Money(amountMinor: 100, currency: CurrencyCode.usd);

      expect(a.add(b).amountMinor, 1500);
      expect(a.subtract(b).amountMinor, 1000);
      expect(() => a.add(c), throwsArgumentError);
    });

    test('trip state machine keeps expected critical transitions', () {
      const machine = TripStateMachine();
      expect(
        machine.canTransition(
          TripState.driverAssignedWaitingAcceptance,
          TripState.noShow,
        ),
        isTrue,
      );
      expect(
        machine.canTransition(TripState.inTrip, TripState.noShow),
        isFalse,
      );
      expect(
        machine.canTransition(TripState.completed, TripState.chargeApplied),
        isTrue,
      );
    });
  });
}
