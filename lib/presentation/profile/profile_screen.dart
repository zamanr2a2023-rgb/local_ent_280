import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/constants/app_assets.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/auth/data/auth_repository.dart';
import 'package:local_ent_280/features/auth/data/user_session.dart';
import 'package:local_ent_280/features/auth/data/models/app_user_profile.dart';
import 'package:local_ent_280/features/auth/data/models/app_user_role.dart';
import 'package:local_ent_280/presentation/widgets/app_bottom_nav.dart';

/// Perfil do utilizador — dados da conta e terminar sessão.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    AuthRepository? authRepository,
    AppUserProfile? initialProfile,
  })  : _authRepository = authRepository,
        _initialProfile = initialProfile;

  final AuthRepository? _authRepository;
  final AppUserProfile? _initialProfile;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthRepository _authRepository =
      widget._authRepository ?? AuthRepository();

  AppUserProfile? _profile;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    final sessionProfile = UserSession.instance.profile;
    if (widget._initialProfile != null) {
      _profile = widget._initialProfile;
      _isLoading = false;
    } else if (sessionProfile != null) {
      _profile = sessionProfile;
      _isLoading = false;
      _loadProfile();
    } else {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final uid = _authRepository.currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = context.l10n.profileSessionNotFound;
      });
      return;
    }

    try {
      final profile = await _authRepository.fetchUserProfile(uid);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
        if (profile == null) {
          _errorMessage = context.l10n.authErrorProfileNotFound;
        } else {
          UserSession.instance.setProfile(profile);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = context.l10n.profileLoadFailed;
      });
    }
  }

  Future<void> _confirmSignOut() async {
    if (_isSigningOut) return;
    final l10n = context.l10n;

    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            l10n.signOutTitle,
            style: AppTypography.manrope(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          content: Text(
            l10n.signOutConfirmMessage,
            style: AppTypography.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              height: 20 / 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                l10n.cancel,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                l10n.signOut,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true || !mounted) return;
    await _signOut();
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await _authRepository.signOut();
      if (!mounted) return;
      AppNavigation.signOutToLogin(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.signOutFailed,
            style: AppTypography.inter(
              fontSize: 14.sp,
              color: AppColors.onPrimary,
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  bool get _isAdmin =>
      _profile?.role == AppUserRole.admin ||
      widget._initialProfile?.role == AppUserRole.admin ||
      UserSession.instance.profile?.role == AppUserRole.admin;

  bool get _isDriver =>
      _profile?.role == AppUserRole.driver ||
      widget._initialProfile?.role == AppUserRole.driver ||
      UserSession.instance.profile?.role == AppUserRole.driver;

  void _onBackTap() {
    if (_isAdmin) {
      AppNavigation.goAdminDashboard(context);
    } else if (_isDriver) {
      AppNavigation.onDriverBottomNavTap(context, AppNavIndex.inicio);
    } else {
      AppNavigation.onBottomNavTap(context, AppNavIndex.inicio);
    }
  }

  void _onBottomNavTap(int index) {
    if (_isDriver) {
      AppNavigation.onDriverBottomNavLocalTap(context, index);
    } else {
      AppNavigation.onBottomNavTap(context, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ProfileAppBar(onBackTap: _onBackTap),
            Expanded(
              child: _buildBody(),
            ),
            if (!_isAdmin)
              AppBottomNav(
                mode: _isDriver ? AppBottomNavMode.driver : AppBottomNavMode.full,
                selectedIndex:
                    _isDriver ? 1 : AppNavIndex.perfil,
                onItemTap: _onBottomNavTap,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _ProfileErrorState(
        message: _errorMessage!,
        onRetry: _loadProfile,
        onLogin: () => AppNavigation.toLogin(context),
      );
    }

    final profile = _profile!;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppLayout.marginMobile,
        8.h,
        AppLayout.marginMobile,
        24.h,
      ),
      children: [
        _ProfileHeader(profile: profile),
        SizedBox(height: 24.h),
        _AccountInfoCard(profile: profile),
        SizedBox(height: 24.h),
        const _MenuSection(),
        SizedBox(height: 32.h),
        _LogoutSection(
          isLoading: _isSigningOut,
          onSignOut: _confirmSignOut,
        ),
      ],
    );
  }
}

class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar({required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
      color: AppColors.background,
      child: Row(
        children: [
          IconButton(
            onPressed: onBackTap,
            icon: Icon(Icons.arrow_back, color: AppColors.primary, size: 24.sp),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              context.l10n.profileTitle,
              style: AppTypography.manrope(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                height: 32 / 22,
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final AppUserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayName = profile.name.trim().isEmpty
        ? l10n.profileDefaultUserName
        : profile.name.trim();

    return Column(
      children: [
        Container(
          width: 96.w,
          height: 96.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accent, width: 3.w),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            AppAssets.profileAvatarImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => ColoredBox(
              color: AppColors.accentSurface,
              child: Icon(
                Icons.person,
                size: 48.sp,
                color: AppColors.accent,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: AppTypography.manrope(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            height: 32 / 24,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          profile.email,
          textAlign: TextAlign.center,
          style: AppTypography.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AccountInfoCard extends StatelessWidget {
  const _AccountInfoCard({required this.profile});

  final AppUserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.surfaceVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.phone_outlined,
            label: l10n.profilePhone,
            value: profile.phone.trim().isEmpty
                ? l10n.profilePhoneNotSet
                : profile.phone,
          ),
          Divider(height: 1.h, color: AppColors.surfaceVariant),
          _InfoRow(
            icon: Icons.badge_outlined,
            label: l10n.profileAccountType,
            value: profile.roleLabel(l10n),
          ),
          Divider(height: 1.h, color: AppColors.surfaceVariant),
          _InfoRow(
            icon: Icons.verified_user_outlined,
            label: l10n.profileStatus,
            value: profile.isActive
                ? l10n.profileStatusActive
                : l10n.profileStatusInactive,
            valueColor:
                profile.isActive ? AppColors.accent : AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(icon, size: 22.sp, color: AppColors.accent),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    height: 16 / 12,
                    color: AppColors.labelMuted,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: AppTypography.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    height: 20 / 15,
                    color: valueColor ?? AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection();

  static const _icons = [
    Icons.settings_outlined,
    Icons.payment_outlined,
    Icons.help_outline,
    Icons.shield_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (l10n.profileMenuSettings, () => AppNavigation.toSettings(context)),
      (l10n.profileMenuPaymentMethods, null),
      (l10n.profileMenuHelpCenter, null),
      (l10n.profileMenuPrivacySecurity, null),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsAccountSection,
          style: AppTypography.manrope(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.surfaceVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) Divider(height: 1.h, color: AppColors.surfaceVariant),
                _MenuTile(
                  icon: _icons[i],
                  label: items[i].$1,
                  onTap: items[i].$2,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(icon, size: 22.sp, color: AppColors.accent),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    height: 20 / 15,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 22.sp,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutSection extends StatelessWidget {
  const _LogoutSection({
    required this.isLoading,
    required this.onSignOut,
  });

  final bool isLoading;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profileSessionSection,
          style: AppTypography.manrope(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 12.h),
        Material(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16.r),
          child: InkWell(
            onTap: isLoading ? null : onSignOut,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(Icons.logout, size: 22.sp, color: AppColors.error),
                  SizedBox(width: 10.w),
                  Text(
                    l10n.signOutTitle,
                    style: AppTypography.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      height: 20 / 15,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  const _ProfileErrorState({
    required this.message,
    required this.onRetry,
    required this.onLogin,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.all(AppLayout.marginMobile),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
          SizedBox(height: 16.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              height: 20 / 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 24.h),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.onAccent,
            ),
            child: Text(l10n.tryAgain),
          ),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: onLogin,
            child: Text(l10n.profileGoToLogin),
          ),
        ],
      ),
    );
  }
}
