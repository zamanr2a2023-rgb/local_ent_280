import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/data/driver_home_data.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';

/// Confirmação após aceitar o pedido de viagem.
class DriverTripAcceptedScreen extends StatelessWidget {
  const DriverTripAcceptedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            DriverTripAcceptedData.mapImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                ColoredBox(color: AppColors.surfaceContainer),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withValues(alpha: 0.3),
                  AppColors.background.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
                  child: _AcceptedCard(
                    onStartNavigation: () =>
                        AppNavigation.toDriverActiveTrip(context),
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AcceptedCard extends StatelessWidget {
  const _AcceptedCard({required this.onStartNavigation});

  final VoidCallback onStartNavigation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 24.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.h),
            color: AppColors.accent,
            child: Column(
              children: [
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: const BoxDecoration(
                    color: AppColors.onAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 32.sp, color: AppColors.accent),
                ),
                SizedBox(height: 12.h),
                Text(
                  l10n.driverTripAcceptedTitle,
                  style: AppTypography.manrope(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onAccent,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.driverTripAcceptedSubtitle,
                  style: AppTypography.inter(
                    fontSize: 14.sp,
                    color: AppColors.onAccent.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.person_outline,
                  label: l10n.driverPassenger,
                  value: DriverTripAcceptedData.passengerName,
                ),
                SizedBox(height: 12.h),
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: l10n.driverPickup,
                  value: DriverTripAcceptedData.pickupAddress,
                ),
                SizedBox(height: 12.h),
                _DetailRow(
                  icon: Icons.schedule,
                  label: l10n.driverEstimatedArrival,
                  value: DriverTripAcceptedData.eta,
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onStartNavigation,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: Icon(Icons.navigation, size: 20.sp),
                    label: Text(
                      l10n.driverStartNavigation,
                      style: AppTypography.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.accent),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.inter(
                  fontSize: 12.sp,
                  color: AppColors.labelMuted,
                ),
              ),
              Text(
                value,
                style: AppTypography.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
