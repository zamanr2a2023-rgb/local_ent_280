import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/data/driver_home_data.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';

/// Request expired — `roles/details.md` (dead-end state, no bottom nav).
class DriverRequestExpiredScreen extends StatefulWidget {
  const DriverRequestExpiredScreen({super.key});

  @override
  State<DriverRequestExpiredScreen> createState() =>
      _DriverRequestExpiredScreenState();
}

class _DriverRequestExpiredScreenState extends State<DriverRequestExpiredScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _ExpiredAppBar(
              onProfileTap: () => AppNavigation.onDriverBottomNavTap(
                context,
                AppNavIndex.perfil,
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const _BackgroundGlow(),
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.marginMobile,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _PulsingExpiredIcon(pulse: _pulseController),
                        SizedBox(height: AppLayout.xl),
                        Text(
                          l10n.driverRequestExpiredTitle,
                          textAlign: TextAlign.center,
                          style: AppTypography.manrope(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            height: 36 / 28,
                            color: AppColors.onSurface,
                          ),
                        ),
                        SizedBox(height: AppLayout.sm),
                        Text(
                          l10n.driverRequestExpiredMessage,
                          textAlign: TextAlign.center,
                          style: AppTypography.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w400,
                            height: 28 / 18,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: AppLayout.xxl),
                        _StatusChip(label: l10n.driverUnavailableForRequests),
                        SizedBox(height: AppLayout.xxl),
                        _PrimaryActionButton(
                          label: l10n.driverBackToDashboard,
                          onPressed: () => AppNavigation.toDriverHome(context),
                        ),
                        SizedBox(height: AppLayout.md),
                        _SecondaryActionButton(
                          label: l10n.driverViewTripHistory,
                          onPressed: () =>
                              AppNavigation.toDriverTripHistory(context),
                        ),
                        SizedBox(height: AppLayout.xxl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiredAppBar extends StatelessWidget {
  const _ExpiredAppBar({required this.onProfileTap});

  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
      color: AppColors.background,
      child: Row(
        children: [
          IconButton(
            onPressed: () => AppNavigation.toDriverHome(context),
            icon: Icon(Icons.menu, color: AppColors.primary, size: 24.sp),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
          ),
          SizedBox(width: AppLayout.md),
          Expanded(
            child: Text(
              context.l10n.premiumMobility,
              style: AppTypography.manrope(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                height: 32 / 24,
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerHigh,
                border: Border.all(color: AppColors.outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                DriverHomeData.profileAvatarImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person,
                  size: 18.sp,
                  color: AppColors.outline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300.w,
        height: 300.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.errorContainer.withValues(alpha: 0.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.errorContainer.withValues(alpha: 0.35),
              blurRadius: 80.r,
              spreadRadius: 20.r,
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingExpiredIcon extends StatelessWidget {
  const _PulsingExpiredIcon({required this.pulse});

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final scale = 1.0 + pulse.value * 0.05;
        final opacity = 0.9 + pulse.value * 0.1;
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: Container(
        width: 128.w,
        height: 128.h,
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.12),
              blurRadius: 16.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Icon(
          Icons.timer_off,
          size: 64.sp,
          color: AppColors.error,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppLayout.md, vertical: AppLayout.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.h,
            decoration: const BoxDecoration(
              color: AppColors.outline,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppLayout.sm),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                height: 16 / 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          elevation: 0,
          shadowColor: AppColors.secondary.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999.r),
          ),
        ),
        icon: Icon(Icons.dashboard_outlined, size: 20.sp),
        label: Text(
          label,
          style: AppTypography.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            height: 20 / 14,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: const BorderSide(color: AppColors.secondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999.r),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            height: 20 / 14,
            letterSpacing: 0.1,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }
}
