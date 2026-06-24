import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/trips/domain/entities/reservation.dart';
import 'package:local_transport/features/trips/domain/entities/reservation_draft.dart';
import 'package:local_transport/features/trips/domain/entities/reservation_source.dart';
import 'package:local_transport/features/trips/domain/entities/reservation_status.dart';
import 'package:local_transport/features/trips/domain/entities/trip_location.dart';
import 'package:local_transport/features/trips/domain/entities/trip_transport_type.dart';
import 'package:local_transport/features/trips/domain/repositories/reservation_repository.dart';
import 'package:local_transport/features/trips/domain/services/reservation_id_generator.dart';
import 'package:local_transport/features/trips/domain/usecases/create_reservation.dart';

void main() {
  group('CreateReservation', () {
    late _FakeReservationRepository repository;
    late CreateReservation useCase;

    setUp(() {
      repository = _FakeReservationRepository();
      useCase = CreateReservation(
        repository,
        const _FakeReservationIdGenerator(),
      );
    });

    test(
      'cria reserva internal_staff com motorista planeado e metadata do criador',
      () async {
        final pickup = TripLocation(
          latitude: 38.7223,
          longitude: -9.1393,
          address: 'Praça do Comércio',
        );
        final destination = TripLocation(
          latitude: 38.7071,
          longitude: -9.1355,
          address: 'Cais do Sodré',
        );
        final draft = ReservationDraft(
          scheduledAt: DateTime(2026, 4, 1, 10, 0),
          pickup: pickup,
          destination: destination,
          transportType: const TripTransportType(
            id: 'standard',
            name: 'Standard',
          ),
          assignedDriverId: 'driver_1',
        );

        final reservation = await useCase(
          clientId: 'client_1',
          createdByUserId: 'admin_1',
          createdByRole: 'admin',
          draft: draft,
        );

        expect(reservation.id, 'reservation_test_1');
        expect(reservation.source, ReservationSource.internalStaff);
        expect(reservation.clientId, 'client_1');
        expect(reservation.assignedDriverId, 'driver_1');
        expect(reservation.status, ReservationStatus.scheduled);
        expect(reservation.createdByUserId, 'admin_1');
        expect(reservation.createdByRole, 'admin');
        expect(reservation.pickup.address, 'Praça do Comércio');
        expect(reservation.destination.address, 'Cais do Sodré');

        expect(repository.createdReservations, hasLength(1));
        expect(
          repository.createdReservations.single.source,
          ReservationSource.internalStaff,
        );
        expect(
          repository.createdReservations.single.assignedDriverId,
          'driver_1',
        );
        expect(
          repository.createdReservations.single.createdByUserId,
          'admin_1',
        );
        expect(repository.createdReservations.single.createdByRole, 'admin');
      },
    );

    test('rejeita criação sem assignedDriverId', () async {
      final draft = ReservationDraft(
        scheduledAt: DateTime(2026, 4, 1, 10, 0),
        pickup: const TripLocation(
          latitude: 38.7223,
          longitude: -9.1393,
          address: 'Praça do Comércio',
        ),
        destination: const TripLocation(
          latitude: 38.7071,
          longitude: -9.1355,
          address: 'Cais do Sodré',
        ),
        transportType: const TripTransportType(
          id: 'standard',
          name: 'Standard',
        ),
      );

      expect(
        () => useCase(
          clientId: 'client_1',
          createdByUserId: 'admin_1',
          createdByRole: 'admin',
          draft: draft,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(repository.createdReservations, isEmpty);
    });
  });
}

class _FakeReservationRepository implements ReservationRepository {
  final List<Reservation> createdReservations = <Reservation>[];

  @override
  Future<void> createReservation(Reservation reservation) async {
    createdReservations.add(reservation);
  }

  @override
  Future<Reservation?> fetchReservation(String reservationId) async {
    return null;
  }

  @override
  Future<List<Reservation>> fetchReservationsForDriver({
    required String driverId,
    required DateTime start,
    required DateTime end,
  }) async {
    return const <Reservation>[];
  }

  @override
  Future<void> updateReservation(Reservation reservation) async {
    throw UnimplementedError();
  }

  @override
  Stream<List<Reservation>> watchUpcomingOperationalReservations() {
    return const Stream<List<Reservation>>.empty();
  }
}

class _FakeReservationIdGenerator implements ReservationIdGenerator {
  const _FakeReservationIdGenerator();

  @override
  String generateReservationId() => 'reservation_test_1';
}
