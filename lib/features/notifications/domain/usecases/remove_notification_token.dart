import '../repositories/notification_token_repository.dart';

class RemoveNotificationToken {
  const RemoveNotificationToken(this._repository);

  final NotificationTokenRepository _repository;

  Future<void> call({required String userId}) {
    return _repository.removeCurrentToken(userId: userId);
  }
}
