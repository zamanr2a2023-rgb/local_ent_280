abstract interface class NotificationTokenRepository {
  Future<void> registerToken({
    required String token,
    required String userId,
  });

  Future<void> removeCurrentToken({required String userId});
}
