import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/auth/data/models/app_user_profile.dart';
import 'package:local_ent_280/features/auth/data/user_session.dart';
import 'package:local_ent_280/presentation/widgets/user_avatar.dart';

/// Drawer header card showing the authenticated Firestore user.
class DrawerUserCard extends StatelessWidget {
  const DrawerUserCard({
    super.key,
    this.profile,
  });

  /// Optional override; defaults to [UserSession] profile.
  final AppUserProfile? profile;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserSession.instance,
      builder: (context, _) {
        final sessionProfile = profile ?? UserSession.instance.profile;
        final l10n = context.l10n;
        final displayName = sessionProfile?.name.trim().isNotEmpty == true
            ? sessionProfile!.name.trim()
            : l10n.profileDefaultUserName;
        final subtitle = sessionProfile?.email.trim().isNotEmpty == true
            ? sessionProfile!.email.trim()
            : sessionProfile?.phone.trim() ?? '';
        final roleLabel =
            sessionProfile?.roleLabel(l10n) ?? l10n.profileRoleClient;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppLayout.md),
          child: Container(
            padding: EdgeInsets.all(AppLayout.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                UserAvatar(
                  profile: sessionProfile,
                  size: 48.w,
                  fontSize: 16.sp,
                ),
                SizedBox(width: AppLayout.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: AppTypography.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: AppTypography.inter(
                            fontSize: 12.sp,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryFixed,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          roleLabel.toUpperCase(),
                          style: AppTypography.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
