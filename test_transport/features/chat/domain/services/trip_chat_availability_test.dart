import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/chat/domain/services/trip_chat_availability.dart';
import 'package:local_transport/features/trips/domain/entities/trip_state.dart';

void main() {
  group('TripChatAvailability', () {
    const service = TripChatAvailability();

    test('allows chat during operational trip window', () {
      expect(service.canOpenForState(TripState.driverAccepted), isTrue);
      expect(service.canOpenForState(TripState.driverEnRoute), isTrue);
      expect(service.canOpenForState(TripState.driverArrived), isTrue);
      expect(service.canOpenForState(TripState.inTrip), isTrue);
      expect(service.canOpenForState(TripState.arrivedDestination), isTrue);
      expect(service.canOpenForState(TripState.extensionWindow), isTrue);
    });

    test('blocks chat outside operational trip window', () {
      expect(service.canOpenForState(TripState.requested), isFalse);
      expect(
        service.canOpenForState(TripState.driverAssignedWaitingAcceptance),
        isFalse,
      );
      expect(service.canOpenForState(TripState.driverDeclined), isFalse);
      expect(service.canOpenForState(TripState.noDriversAvailable), isFalse);
      expect(service.canOpenForState(TripState.cancelledByClient), isFalse);
      expect(service.canOpenForState(TripState.cancelledByDriver), isFalse);
      expect(service.canOpenForState(TripState.noShow), isFalse);
      expect(service.canOpenForState(TripState.completed), isFalse);
      expect(service.canOpenForState(TripState.chargeApplied), isFalse);
    });
  });
}
