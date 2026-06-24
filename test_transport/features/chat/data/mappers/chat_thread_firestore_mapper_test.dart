import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/chat/data/mappers/chat_thread_firestore_mapper.dart';
import 'package:local_transport/features/chat/domain/entities/chat_sender_role.dart';
import 'package:local_transport/features/chat/domain/entities/chat_thread_status.dart';
import 'package:local_transport/features/chat/domain/entities/chat_thread_type.dart';

void main() {
  group('ChatThreadFirestoreMapper', () {
    const mapper = ChatThreadFirestoreMapper();

    test('maps support thread summary', () {
      final mapped = mapper.fromJson({
        'type': 'support_client_ops',
        'status': 'open',
        'clientId': 'client_1',
        'createdAt': Timestamp.fromDate(DateTime.utc(2026, 4, 6, 9)),
        'updatedAt': Timestamp.fromDate(DateTime.utc(2026, 4, 6, 10)),
        'lastMessageAt': Timestamp.fromDate(DateTime.utc(2026, 4, 6, 11)),
        'lastMessageText': 'Olá',
        'lastSenderUserId': 'client_1',
        'lastSenderRole': 'client',
        'needsOpsAttention': true,
      }, 'support_client_client_1');

      expect(mapped.id, 'support_client_client_1');
      expect(mapped.type, ChatThreadType.supportClientOps);
      expect(mapped.status, ChatThreadStatus.open);
      expect(mapped.clientId, 'client_1');
      expect(mapped.lastMessageText, 'Olá');
      expect(mapped.lastSenderRole, ChatSenderRole.client);
      expect(mapped.needsOpsAttention, isTrue);
    });

    test('maps trip thread summary with optional identifiers', () {
      final mapped = mapper.fromJson({
        'type': 'trip_client_driver',
        'status': 'closed',
        'clientId': 'client_1',
        'tripId': 'trip_1',
        'driverId': 'driver_1',
        'needsOpsAttention': false,
      }, 'trip_trip_1');

      expect(mapped.type, ChatThreadType.tripClientDriver);
      expect(mapped.status, ChatThreadStatus.closed);
      expect(mapped.tripId, 'trip_1');
      expect(mapped.driverId, 'driver_1');
      expect(mapped.needsOpsAttention, isFalse);
    });
  });
}
