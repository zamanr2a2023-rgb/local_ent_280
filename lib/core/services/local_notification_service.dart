abstract class LocalNotificationService {
  Future<void> initialize();

  Future<void> show({
    required String title,
    required String body,
    String? payload,
  });
}
