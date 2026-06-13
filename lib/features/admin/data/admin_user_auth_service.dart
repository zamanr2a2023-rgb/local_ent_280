import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:local_ent_280/firebase_options.dart';

/// Creates Firebase Auth users from the admin app without signing out the admin.
class AdminUserAuthService {
  AdminUserAuthService({FirebaseOptions? options})
      : _options = options ?? DefaultFirebaseOptions.currentPlatform;

  static const _appName = 'adminUserCreator';

  final FirebaseOptions _options;
  FirebaseAuth? _auth;

  Future<UserCredential> createUser({
    required String email,
    required String password,
  }) async {
    final auth = await _resolveAuth();
    try {
      return await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } finally {
      await auth.signOut();
    }
  }

  Future<FirebaseAuth> _resolveAuth() async {
    if (_auth != null) return _auth!;
    FirebaseApp app;
    try {
      app = Firebase.app(_appName);
    } catch (_) {
      app = await Firebase.initializeApp(
        name: _appName,
        options: _options,
      );
    }
    _auth = FirebaseAuth.instanceFor(app: app);
    return _auth!;
  }
}

class AdminCreateUserException implements Exception {
  const AdminCreateUserException(this.message);

  final String message;

  @override
  String toString() => message;
}
