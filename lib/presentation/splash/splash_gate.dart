import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/features/auth/application/providers/auth_domain_providers.dart';
import 'package:local_ent_280/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_ent_280/presentation/splash/splash_screen.dart';

class SplashGate extends ConsumerStatefulWidget {
  const SplashGate({super.key, AuthRepository? authRepository})
      : _authRepository = authRepository;

  final AuthRepository? _authRepository;

  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate> {
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreSession();
    });
  }

  Future<void> _restoreSession() async {
    try {
      final AuthRepository repository =
          widget._authRepository ?? ref.read(authRepositoryProvider);
      final profile = await repository.restoreSession();
      if (!mounted) return;
      if (profile != null) {
        AppNavigation.afterAuthenticatedLogin(context, profile);
        return;
      }
    } catch (_) {
      // Remain on splash when session restore is unavailable or invalid.
    } finally {
      if (mounted) {
        setState(() => _checkingSession = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
      );
    }
    return const SplashScreen();
  }
}
