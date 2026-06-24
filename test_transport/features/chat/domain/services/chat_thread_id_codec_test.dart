import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/chat/domain/services/chat_thread_id_codec.dart';

void main() {
  group('ChatThreadIdCodec', () {
    const codec = ChatThreadIdCodec();

    test('builds deterministic support thread ids', () {
      expect(codec.supportThreadId(' client-1 '), 'support_client_client-1');
    });

    test('builds deterministic support request thread ids', () {
      expect(
        codec.supportRequestThreadId(' request-1 '),
        'support_request_request-1',
      );
    });

    test('sanitizes unsupported characters in support ids', () {
      expect(codec.supportThreadId('cli/ent 1'), 'support_client_cli_ent_1');
    });

    test('builds deterministic trip thread ids', () {
      expect(codec.tripThreadId('trip:123'), 'trip_trip:123');
    });
  });
}
