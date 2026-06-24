import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/notifications/presentation/widgets/notification_open_listener.dart';

void main() {
  group('NotificationHandledMessageCache', () {
    test('remove a chave mais antiga ao ultrapassar o limite', () {
      final cache = NotificationHandledMessageCache(maxSize: 2);

      expect(cache.register('k1'), isTrue);
      expect(cache.register('k2'), isTrue);
      expect(cache.register('k3'), isTrue);

      expect(cache.register('k1'), isTrue);
      expect(cache.register('k1'), isFalse);
      expect(cache.register('k2'), isTrue);
    });

    test('ignora duplicados enquanto a chave está no cache', () {
      final cache = NotificationHandledMessageCache(maxSize: 3);

      expect(cache.register('message-1'), isTrue);
      expect(cache.register('message-1'), isFalse);
      expect(cache.register('message-2'), isTrue);
    });
  });
}
