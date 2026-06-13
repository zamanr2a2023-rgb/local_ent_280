import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/auth/data/auth_repository.dart';
import 'package:local_ent_280/features/auth/data/user_session.dart';
import 'package:local_ent_280/features/auth/data/models/app_user_profile.dart';
import 'package:local_ent_280/features/auth/data/models/app_user_role.dart';
import 'package:local_ent_280/features/profile/data/profile_repository.dart';
import 'package:local_ent_280/l10n/app_localizations.dart';
import 'package:local_ent_280/presentation/widgets/app_bottom_nav.dart';
import 'package:local_ent_280/presentation/widgets/user_avatar.dart';

/// Perfil do utilizador — dados da conta e terminar sessão.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    AuthRepository? authRepository,
    ProfileRepository? profileRepository,
    AppUserProfile? initialProfile,
  })  : _authRepository = authRepository,
        _profileRepository = profileRepository,
        _initialProfile = initialProfile;

  final AuthRepository? _authRepository;
  final ProfileRepository? _profileRepository;
  final AppUserProfile? _initialProfile;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthRepository _authRepository =
      widget._authRepository ?? AuthRepository();
  late final ProfileRepository _profileRepository =
      widget._profileRepository ?? ProfileRepository();
  final _imagePicker = ImagePicker();

  AppUserProfile? _profile;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSigningOut = false;
  bool _isUploadingPhoto = false;
  bool _isSavingName = false;

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

  Future<void> _showPhotoOptions() async {
    if (_isUploadingPhoto || _profile == null) return;
    final l10n = context.l10n;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.profilePhotoFromGallery),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(l10n.profilePhotoTakePhoto),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null || !mounted) return;
    await _pickAndUploadPhoto(source);
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    final uid = _authRepository.currentUser?.uid;
    if (uid == null) return;

    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;

      setState(() => _isUploadingPhoto = true);
      final updatedProfile = await _profileRepository.updateProfilePhoto(
        uid: uid,
        imageFile: File(picked.path),
      );

      if (!mounted) return;
      setState(() {
        _profile = updatedProfile;
        _isUploadingPhoto = false;
      });
      UserSession.instance.setProfile(updatedProfile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profilePhotoUpdated)),
      );
    } catch (error, stackTrace) {
      debugPrint('Profile photo update failed: $error');
      debugPrint('$stackTrace');
      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_photoErrorMessage(context.l10n, error)),
        ),
      );
    }
  }

  Future<void> _showEditNameDialog() async {
    if (_profile == null || _isSavingName) return;
    final l10n = context.l10n;

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _EditNameDialog(
        initialName: _profile!.name.trim(),
      ),
    );

    if (newName == null || !mounted) return;

    if (newName == _profile!.name.trim()) return;

    final uid = _authRepository.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSavingName = true);

    try {
      final updatedProfile = await _profileRepository.updateProfileName(
        uid: uid,
        name: newName,
      );
      if (!mounted) return;
      setState(() {
        _profile = updatedProfile;
        _isSavingName = false;
      });
      UserSession.instance.setProfile(updatedProfile);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileNameUpdated)),
      );
    } catch (error, stackTrace) {
      debugPrint('Profile name update failed: $error');
      debugPrint('$stackTrace');
      if (!mounted) return;
      setState(() => _isSavingName = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_nameErrorMessage(context.l10n, error)),
        ),
      );
    }
  }

  String _photoErrorMessage(AppLocalizations l10n, Object error) {
    if (error is FirebaseException &&
        (error.code == 'unauthorized' || error.code == 'permission-denied')) {
      return l10n.profilePhotoPermissionDenied;
    }
    return l10n.profilePhotoUpdateFailed;
  }

  String _nameErrorMessage(AppLocalizations l10n, Object error) {
    if (error is FirebaseException && error.code == 'permission-denied') {
      return l10n.profileNamePermissionDenied;
    }
    return l10n.profileNameUpdateFailed;
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
                    _isDriver ? 2 : AppNavIndex.perfil,
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
        _ProfileHeader(
          profile: profile,
          isUploadingPhoto: _isUploadingPhoto,
          isSavingName: _isSavingName,
          onEditPhoto: _showPhotoOptions,
          onEditName: _showEditNameDialog,
        ),
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
  const _ProfileHeader({
    required this.profile,
    required this.isUploadingPhoto,
    required this.isSavingName,
    required this.onEditPhoto,
    required this.onEditName,
  });

  final AppUserProfile profile;
  final bool isUploadingPhoto;
  final bool isSavingName;
  final VoidCallback onEditPhoto;
  final VoidCallback onEditName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayName = profile.name.trim().isEmpty
        ? l10n.profileDefaultUserName
        : profile.name.trim();

    return Column(
      children: [
        UserAvatar(
          profile: profile,
          size: 96.w,
          fontSize: 32.sp,
          borderColor: AppColors.accent,
          borderWidth: 3.w,
          showEditBadge: !isUploadingPhoto,
          isLoading: isUploadingPhoto,
          onTap: isUploadingPhoto ? null : onEditPhoto,
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                displayName,
                textAlign: TextAlign.center,
                style: AppTypography.manrope(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  height: 32 / 24,
                  color: AppColors.primary,
                ),
              ),
            ),
            if (!isSavingName) ...[
              SizedBox(width: 4.w),
              IconButton(
                onPressed: onEditName,
                icon: Icon(
                  Icons.edit_outlined,
                  size: 20.sp,
                  color: AppColors.accent,
                ),
                tooltip: l10n.profileEditName,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
              ),
            ] else
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
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

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = context.l10n;
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileNameEmpty)),
      );
      return;
    }
    Navigator.of(context).pop(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(
        l10n.profileEditName,
        style: AppTypography.manrope(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        decoration: InputDecoration(
          hintText: l10n.profileNameHint,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _save,
          child: Text(l10n.save),
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
