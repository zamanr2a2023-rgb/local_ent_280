/// Firestore `users.role` values.
enum AppUserRole {
  client('client'),
  driver('driver'),
  admin('admin');

  const AppUserRole(this.firestoreValue);

  final String firestoreValue;

  static AppUserRole? fromFirestore(String? value) {
    if (value == null) return null;
    for (final role in AppUserRole.values) {
      if (role.firestoreValue == value) return role;
    }
    return null;
  }
}