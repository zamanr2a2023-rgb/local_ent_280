import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/support/data/mappers/support_request_firestore_mapper.dart';
import 'package:local_transport/features/support/domain/entities/support_request.dart';

void main() {
  group('SupportRequestFirestoreMapper', () {
    const mapper = SupportRequestFirestoreMapper();

    test('maps general support ticket fields', () {
      final requestedAt = DateTime.utc(2026, 4, 27, 10);
      final mapped = mapper.fromJson({
        'type': 'general',
        'sourceType': 'active_trip',
        'subject': 'Ajuda com viagem',
        'message': 'Preciso de confirmar uma cobrança.',
        'tripId': 'trip_1',
        'chatThreadId': 'support_request_ticket_1',
        'tripSnapshot': {
          'pickupAddress': 'Rua A',
          'destinationAddress': 'Rua B',
          'driverName': 'Motorista Teste',
          'vehiclePlate': 'AA-00-BB',
        },
        'userId': 'client_1',
        'role': 'client',
        'displayName': 'Cliente Teste',
        'email': 'cliente@example.com',
        'status': 'open',
        'requestedAt': Timestamp.fromDate(requestedAt),
        'requestedBy': 'client_support_ticket',
      }, 'ticket_1');

      expect(mapped.id, 'ticket_1');
      expect(mapped.type, 'general');
      expect(mapped.sourceType, 'active_trip');
      expect(mapped.subject, 'Ajuda com viagem');
      expect(mapped.message, 'Preciso de confirmar uma cobrança.');
      expect(mapped.tripId, 'trip_1');
      expect(mapped.chatThreadId, 'support_request_ticket_1');
      expect(mapped.tripSnapshot?.pickupAddress, 'Rua A');
      expect(mapped.tripSnapshot?.destinationAddress, 'Rua B');
      expect(mapped.tripSnapshot?.driverName, 'Motorista Teste');
      expect(mapped.tripSnapshot?.vehiclePlate, 'AA-00-BB');
      expect(mapped.userId, 'client_1');
      expect(mapped.status, SupportRequestStatus.open);
      expect(mapped.requestedAt?.toUtc(), requestedAt);
      expect(mapped.requestedBy, 'client_support_ticket');
    });
  });
}
