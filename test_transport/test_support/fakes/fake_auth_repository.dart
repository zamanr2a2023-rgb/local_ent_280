import 'dart:async';

import 'package:local_transport/features/auth/domain/entities/auth_status.dart';
import 'package:local_transport/features/auth/domain/entities/manager_permissions_snapshot.dart';
import 'package:local_transport/features/auth/domain/entities/password_help_request_result.dart';
import 'package:local_transport/features/auth/domain/entities/profile_role.dart';
import 'package:local_transport/features/auth/domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    AuthStatus initialStatus = const AuthStatus(
      isAvailable: false,
      role: ProfileRole.client,
    ),
    String? currentUserId,
    String? currentUserEmail,
    ManagerPermissionsSnapshot? managerPermissionsSnapshot,
  }) : _status = initialStatus,
       _currentUserId = currentUserId,
       _currentUserEmail = currentUserEmail,
       _managerPermissionsSnapshot =
           managerPermissionsSnapshot ??
           ManagerPermissionsSnapshot.managerBlocked();

  factory FakeAuthRepository.authenticated({
    required String userId,
    required ProfileRole role,
    String? email,
    ManagerPermissionsSnapshot? managerPermissionsSnapshot,
  }) {
    return FakeAuthRepository(
      initialStatus: AuthStatus(isAvailable: true, role: role),
      currentUserId: userId,
      currentUserEmail: email,
      managerPermissionsSnapshot: managerPermissionsSnapshot,
    );
  }

  factory FakeAuthRepository.unauthenticated({
    ProfileRole role = ProfileRole.client,
  }) {
    return FakeAuthRepository(
      initialStatus: AuthStatus(isAvailable: false, role: role),
    );
  }

  final StreamController<AuthStatus> _statusController =
      StreamController<AuthStatus>.broadcast();

  AuthStatus _status;
  String? _currentUserId;
  String? _currentUserEmail;
  ManagerPermissionsSnapshot _managerPermissionsSnapshot;

  void setSession({
    required AuthStatus status,
    String? userId,
    String? userEmail,
    ManagerPermissionsSnapshot? managerPermissionsSnapshot,
  }) {
    _status = status;
    _currentUserId = status.isAvailable ? userId : null;
    _currentUserEmail = status.isAvailable ? userEmail : null;
    if (managerPermissionsSnapshot != null) {
      _managerPermissionsSnapshot = managerPermissionsSnapshot;
    }
    _statusController.add(_status);
  }

  Future<void> dispose() async {
    await _statusController.close();
  }

  @override
  String? currentUserEmail() => _currentUserEmail;

  @override
  String? currentUserId() => _currentUserId;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}

  @override
  Future<ManagerPermissionsSnapshot> fetchManagerPermissions({
    bool forceRefresh = false,
  }) async {
    return _managerPermissionsSnapshot;
  }

  @override
  Future<ProfileRole> fetchProfileRole() async => _status.role;

  @override
  Future<AuthStatus> fetchStatus() async => _status;

  @override
  Future<PasswordHelpRequestResult> requestPasswordHelp({
    required String emailOrLogin,
  }) async {
    return const PasswordHelpRequestResult(ok: true);
  }

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    setSession(
      status: AuthStatus(isAvailable: true, role: _status.role),
      userId: _currentUserId ?? email,
      userEmail: email,
    );
  }

  @override
  Future<void> signOut() async {
    setSession(
      status: AuthStatus(isAvailable: false, role: _status.role),
    );
  }

  @override
  Stream<AuthStatus> watchStatus() async* {
    yield _status;
    yield* _statusController.stream;
  }
}
