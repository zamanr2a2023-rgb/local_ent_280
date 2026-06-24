import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/app/presentation/providers/repository_scope.dart';
import 'package:local_ent_280/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_ent_280/features/auth/data/user_session.dart';
import 'package:local_ent_280/presentation/login/login_screen.dart';
import 'package:local_ent_280/presentation/widgets/drawer_user_card.dart';
import 'package:material_symbols_icons/symbols.dart';

enum DriverDrawerSection { home, profile, settings }

/// Driver navigation drawer — mirrors driver bottom nav.
class DriverDrawer extends StatelessWidget {
  const DriverDrawer({
    super.key,
    required this.selected,
    AuthRepository? authRepository,
  }) : _authRepository = authRepository;

  final DriverDrawerSection selected;
  final AuthRepository? _authRepository;

  Future<void> _closeAndRun(BuildContext context, VoidCallback action) async {
    Navigator.of(context).pop();
    action();
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = context.l10n;
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);

    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.signOutTitle),
          content: Text(l10n.signOutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                l10n.signOut,
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true) return;

    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    try {
      await (_authRepository ?? authRepositoryOf(context)).signOut();
      rootNavigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.signOutFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Drawer(
      backgroundColor: AppColors.background,
      width: 300.w,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppLayout.md,
                AppLayout.lg,
                AppLayout.md,
                AppLayout.lg,
              ),
              child: Text(
                l10n.appNameLocalTransport,
                style: AppTypography.manrope(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            DrawerUserCard(profile: UserSession.instance.profile),
            SizedBox(height: AppLayout.md),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: AppLayout.md),
                children: [
                  _DrawerNavItem(
                    icon: Symbols.home,
                    label: l10n.navHome,
                    isSelected: selected == DriverDrawerSection.home,
                    onTap: () {
                      Navigator.of(context).pop();
                      if (selected != DriverDrawerSection.home) {
                        AppNavigation.onDriverBottomNavTap(
                          context,
                          AppNavIndex.inicio,
                        );
                      }
                    },
                  ),
                  _DrawerNavItem(
                    icon: Symbols.person,
                    label: l10n.navProfile,
                    isSelected: selected == DriverDrawerSection.profile,
                    onTap: () => _closeAndRun(
                      context,
                      () => AppNavigation.toProfile(context),
                    ),
                  ),
                  _DrawerNavItem(
                    icon: Symbols.settings,
                    label: l10n.settingsTitle,
                    isSelected: selected == DriverDrawerSection.settings,
                    onTap: () => _closeAndRun(
                      context,
                      () => AppNavigation.toSettings(context),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppLayout.md),
              child: _DrawerNavItem(
                icon: Symbols.logout,
                label: l10n.signOut,
                isSelected: false,
                isDestructive: true,
                onTap: () => _confirmSignOut(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  const _DrawerNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDestructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isDestructive
        ? AppColors.error
        : isSelected
        ? AppColors.onSecondaryContainer
        : AppColors.onSurfaceVariant;
    final background = isSelected
        ? AppColors.secondaryContainer
        : Colors.transparent;

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999.r),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppLayout.md,
              vertical: 10.h,
            ),
            child: Row(
              children: [
                Icon(icon, size: 22.sp, color: foreground),
                SizedBox(width: AppLayout.md),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
