import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/auth/data/models/app_user_profile.dart';

/// Circular avatar showing the user's photo or initials.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.profile,
    this.size,
    this.fontSize,
    this.borderColor,
    this.borderWidth,
    this.showEditBadge = false,
    this.isLoading = false,
    this.onTap,
  });

  final AppUserProfile? profile;
  final double? size;
  final double? fontSize;
  final Color? borderColor;
  final double? borderWidth;
  final bool showEditBadge;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? 48.w;
    final photoUrl = profile?.photoUrl?.trim();
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    final initials = profile?.initials ?? '?';

    Widget avatar = Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryContainer,
        border: Border.all(
          color: borderColor ?? AppColors.outlineVariant,
          width: borderWidth ?? 1.w,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: isLoading
          ? Center(
              child: SizedBox(
                width: dimension * 0.4,
                height: dimension * 0.4,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : hasPhoto
              ? Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _InitialsFallback(
                    initials: initials,
                    fontSize: fontSize ?? (dimension * 0.32).sp,
                  ),
                )
              : _InitialsFallback(
                  initials: initials,
                  fontSize: fontSize ?? (dimension * 0.32).sp,
                ),
    );

    if (showEditBadge) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: dimension * 0.32,
              height: dimension * 0.32,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surfaceContainerLowest,
                  width: 2.w,
                ),
              ),
              child: Icon(
                Icons.camera_alt,
                size: (dimension * 0.16).sp,
                color: AppColors.onAccent,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap == null) return avatar;
    return GestureDetector(onTap: onTap, child: avatar);
  }
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({
    required this.initials,
    required this.fontSize,
  });

  final String initials;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: AppTypography.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimaryContainer,
        ),
      ),
    );
  }
}
