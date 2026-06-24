import '../repositories/notification_token_repository.dart';

class RegisterNotificationToken {
  const RegisterNotificationToken(this.repository);

  final NotificationTokenRepository repository;

  Future<void> call({
    required String token,
    required String userId,
  }) {
    return repository.registerToken(token: token, userId: userId);
  }
}
