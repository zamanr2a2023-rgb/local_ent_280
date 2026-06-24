import 'package:local_transport/features/auth/domain/entities/auth_status.dart';
import 'package:local_transport/features/auth/domain/entities/manager_permissions_snapshot.dart';
import 'package:local_transport/features/auth/domain/entities/password_help_request_result.dart';
import 'package:local_transport/features/auth/domain/entities/profile_role.dart';
import 'package:local_transport/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_transport/features/auth/domain/usecases/get_manager_permissions.dart';
import 'package:local_transport/features/auth/presentation/providers/manager_permissions_controller.dart';

class FakeManagerPermissionsController extends ManagerPermissionsController {
  FakeManagerPermissionsController({
    ManagerPermissionsState? initialState,
  }) : super(_FakeGetManagerPermissions()) {
    state =
        initialState ??
        ManagerPermissionsState(
          snapshot: ManagerPermissionsSnapshot.managerBlocked(),
          isLoading: false,
          revision: 0,
          lastRefreshAt: null,
          failure: null,
        );
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> refreshManual() async {}

  @override
  Future<void> refreshOnForeground() async {}
}

class _FakeGetManagerPermissions extends GetManagerPermissions {
  _FakeGetManagerPermissions() : super(const _FakeAuthRepository());
}

class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository();

  @override
  String? currentUserEmail() => null;

  @override
  String? currentUserId() => null;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}

  @override
  Future<ManagerPermissionsSnapshot> fetchManagerPermissions({
    bool forceRefresh = false,
  }) async {
    return ManagerPermissionsSnapshot.managerBlocked();
  }

  @override
  Future<ProfileRole> fetchProfileRole() async => ProfileRole.manager;

  @override
  Future<AuthStatus> fetchStatus() async {
    return const AuthStatus(
      isAvailable: true,
      role: ProfileRole.manager,
    );
  }

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
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Stream<AuthStatus> watchStatus() {
    return Stream<AuthStatus>.value(
      const AuthStatus(
        isAvailable: true,
        role: ProfileRole.manager,
      ),
    );
  }
}
