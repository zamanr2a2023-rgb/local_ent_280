import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/auth/data/user_session.dart';

/// Circular avatar showing Firebase user initials.
class SessionProfileAvatar extends StatelessWidget {
  const SessionProfileAvatar({
    super.key,
    this.size,
    this.onTap,
    this.fontSize,
  });

  final double? size;
  final double? fontSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? 40.w;
    final initials = UserSession.instance.profile?.initials ?? '?';

    final avatar = Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryContainer,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTypography.inter(
          fontSize: fontSize ?? (dimension * 0.32).sp,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimaryContainer,
        ),
      ),
    );

    if (onTap == null) return avatar;
    return GestureDetector(onTap: onTap, child: avatar);
  }
}
