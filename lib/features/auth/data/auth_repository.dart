import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:local_ent_280/features/auth/data/auth_exception.dart';
import 'package:local_ent_280/features/auth/data/auth_signing.dart';
import 'package:local_ent_280/features/auth/data/models/app_user_profile.dart';
import 'package:local_ent_280/features/auth/data/models/login_selected_role.dart';
import 'package:local_ent_280/features/auth/data/user_session.dart';

class AuthRepository implements AuthSigning {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Future<AppUserProfile?> fetchUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUserProfile.fromFirestore(doc);
  }

  @override
  Future<AppUserProfile> signIn({
    required String email,
    required String password,
    required LoginSelectedRole selectedRole,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        await _auth.signOut();
        throw AuthException.unknown();
      }

      final profile = await fetchUserProfile(uid);
      if (profile == null) {
        await _auth.signOut();
        throw const AuthException(
          code: AuthFailureCode.profileNotFound,
          message: 'Perfil de utilizador não encontrado.',
        );
      }

      if (!profile.isActive) {
        await _auth.signOut();
        throw const AuthException(
          code: AuthFailureCode.accountInactive,
          message: 'Esta conta está inactiva. Contacte o suporte.',
        );
      }

      if (!selectedRole.matchesProfileRole(profile.role)) {
        await _auth.signOut();
        throw const AuthException(
          code: AuthFailureCode.roleMismatch,
          message: 'Perfil não corresponde ao tipo selecionado.',
        );
      }

      UserSession.instance.setProfile(profile);
      return profile;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        code: AuthFailureCode.invalidCredentials,
        message: _mapFirebaseAuthError(e),
      );
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException.unknown();
    }
  }

  @override
  Future<AppUserProfile> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required LoginSelectedRole selectedRole,
  }) async {
    User? createdUser;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      createdUser = credential.user;
      final uid = createdUser?.uid;
      if (uid == null) {
        throw const AuthException(
          code: AuthFailureCode.registrationFailed,
          message: 'Não foi possível criar a conta.',
        );
      }

      final role = selectedRole.expectedAppRole.firestoreValue;
      await _firestore.collection('users').doc(uid).set({
        'role': role,
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (selectedRole == LoginSelectedRole.professional) {
        await _firestore.collection('driverStatus').doc(uid).set({
          'isActive': true,
          'isAvailable': false,
          'availabilityEnabled': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      final profile = await fetchUserProfile(uid);
      if (profile == null) {
        throw const AuthException(
          code: AuthFailureCode.registrationFailed,
          message: 'Perfil não foi criado.',
        );
      }

      UserSession.instance.setProfile(profile);
      return profile;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        code: _mapRegistrationAuthCode(e.code),
        message: _mapRegistrationAuthError(e),
      );
    } on AuthException {
      await _rollbackCreatedUser(createdUser);
      rethrow;
    } catch (_) {
      await _rollbackCreatedUser(createdUser);
      throw const AuthException(
        code: AuthFailureCode.registrationFailed,
        message: 'Não foi possível criar a conta.',
      );
    }
  }

  Future<void> _rollbackCreatedUser(User? user) async {
    if (user == null) return;
    try {
      await user.delete();
    } catch (_) {}
    try {
      await _auth.signOut();
    } catch (_) {}
  }

  Future<AppUserProfile?> restoreSession() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final profile = await fetchUserProfile(user.uid);
    if (profile == null || !profile.isActive) {
      await _auth.signOut();
      return null;
    }
    UserSession.instance.setProfile(profile);
    return profile;
  }

  Future<void> signOut() {
    UserSession.instance.clear();
    return _auth.signOut();
  }

  AuthFailureCode _mapRegistrationAuthCode(String code) {
    return switch (code) {
      'email-already-in-use' => AuthFailureCode.emailAlreadyInUse,
      'weak-password' => AuthFailureCode.weakPassword,
      'invalid-email' => AuthFailureCode.invalidCredentials,
      _ => AuthFailureCode.registrationFailed,
    };
  }

  String _mapRegistrationAuthError(FirebaseAuthException e) {
    return switch (e.code) {
      'email-already-in-use' => 'Este e-mail já está registado.',
      'weak-password' => 'A palavra-passe é demasiado fraca.',
      'invalid-email' => 'E-mail inválido.',
      _ => 'Não foi possível criar a conta.',
    };
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Esta conta está desactivada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou palavra-passe incorrectos.';
      case 'too-many-requests':
        return 'Demasiadas tentativas. Tente mais tarde.';
      default:
        return 'Não foi possível iniciar sessão. Tente novamente.';
    }
  }
}
