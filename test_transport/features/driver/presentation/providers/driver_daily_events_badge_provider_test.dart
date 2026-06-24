import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/auth/domain/entities/auth_status.dart';
import 'package:local_transport/features/auth/domain/entities/manager_permissions_snapshot.dart';
import 'package:local_transport/features/auth/domain/entities/password_help_request_result.dart';
import 'package:local_transport/features/auth/domain/entities/profile_role.dart';
import 'package:local_transport/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_transport/features/auth/domain/usecases/get_current_user_id.dart';
import 'package:local_transport/features/driver/presentation/providers/driver_daily_events_badge_provider.dart';
import 'package:local_transport/features/events/domain/entities/scheduled_event.dart';
import 'package:local_transport/features/events/domain/repositories/scheduled_event_repository.dart';
import 'package:local_transport/features/events/domain/usecases/get_driver_daily_events.dart';
import 'package:local_transport/features/trips/domain/entities/reservation.dart';
import 'package:local_transport/features/trips/domain/entities/reservation_source.dart';
import 'package:local_transport/features/trips/domain/entities/reservation_status.dart';
import 'package:local_transport/features/trips/domain/entities/trip_location.dart';
import 'package:local_transport/features/trips/domain/entities/trip_transport_type.dart';
import 'package:local_transport/features/trips/domain/repositories/reservation_repository.dart';
import 'package:local_transport/features/trips/domain/usecases/get_driver_daily_reservations.dart';

void main() {
  test(
    'keeps reservation badge when driver events query is permission denied',
    () async {
      final now = DateTime.now();
      final controller = DriverDailyEventsBadgeController(
        GetDriverDailyEvents(
          _FakeScheduledEventRepository(
            driverEventsError: FirebaseException(
              plugin: 'cloud_firestore',
              code: 'permission-denied',
            ),
            broadcastEvents: const <ScheduledEvent>[],
          ),
        ),
        GetDriverDailyReservations(
          _FakeReservationRepository(
            reservations: <Reservation>[
              _buildReservation(
                scheduledAt: now.add(const Duration(hours: 2)),
                status: ReservationStatus.confirmed,
              ),
            ],
          ),
        ),
        GetCurrentUserId(_FakeAuthRepository(userId: 'driver-1')),
      );

      await _settleBadgeRefresh(controller);

      expect(controller.state.hasPendingItems, isTrue);
      expect(controller.state.pendingEventsCount, 0);
      expect(controller.state.pendingReservationsCount, 1);
      expect(controller.state.errorMessage, isNull);

      controller.dispose();
    },
  );
}

Future<void> _settleBadgeRefresh(
  DriverDailyEventsBadgeController controller,
) async {
  for (var attempt = 0; attempt < 20; attempt += 1) {
    if (!controller.state.isLoading && controller.state.lastUpdatedAt != null) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

class _FakeScheduledEventRepository implements ScheduledEventRepository {
  _FakeScheduledEventRepository({
    this.broadcastEvents = const <ScheduledEvent>[],
    this.driverEventsError,
  });

  final List<ScheduledEvent> broadcastEvents;
  final FirebaseException? driverEventsError;

  @override
  Future<void> createEvent(ScheduledEvent event) async {}

  @override
  Future<List<ScheduledEvent>> fetchBroadcastEvents({
    required DateTime start,
    required DateTime end,
  }) async => broadcastEvents;

  @override
  Future<List<ScheduledEvent>> fetchDriverEvents({
    required String driverId,
    required DateTime start,
    required DateTime end,
  }) async {
    if (driverEventsError != null) {
      throw driverEventsError!;
    }
    return const <ScheduledEvent>[];
  }
}

class _FakeReservationRepository implements ReservationRepository {
  _FakeReservationRepository({required this.reservations});

  final List<Reservation> reservations;

  @override
  Future<void> createReservation(Reservation reservation) async {}

  @override
  Future<Reservation?> fetchReservation(String reservationId) async => null;

  @override
  Future<List<Reservation>> fetchReservationsForDriver({
    required String driverId,
    required DateTime start,
    required DateTime end,
  }) async {
    return reservations;
  }

  @override
  Future<void> updateReservation(Reservation reservation) async {}

  @override
  Stream<List<Reservation>> watchUpcomingOperationalReservations() {
    return const Stream<List<Reservation>>.empty();
  }
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.userId});

  final String? userId;

  @override
  String? currentUserId() => userId;

  @override
  String? currentUserEmail() => null;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ManagerPermissionsSnapshot> fetchManagerPermissions({
    bool forceRefresh = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ProfileRole> fetchProfileRole() {
    throw UnimplementedError();
  }

  @override
  Future<AuthStatus> fetchStatus() {
    throw UnimplementedError();
  }

  @override
  Future<PasswordHelpRequestResult> requestPasswordHelp({
    required String emailOrLogin,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  Stream<AuthStatus> watchStatus() {
    throw UnimplementedError();
  }
}

Reservation _buildReservation({
  required DateTime scheduledAt,
  required ReservationStatus status,
}) {
  return Reservation(
    id: 'reservation-1',
    source: ReservationSource.internalStaff,
    clientId: 'client-1',
    assignedDriverId: 'driver-1',
    scheduledAt: scheduledAt,
    status: status,
    pickup: const TripLocation(
      latitude: 0,
      longitude: 0,
      address: 'Pickup',
    ),
    destination: const TripLocation(
      latitude: 1,
      longitude: 1,
      address: 'Destination',
    ),
    transportType: const TripTransportType(id: 'standard', name: 'Standard'),
  );
}
