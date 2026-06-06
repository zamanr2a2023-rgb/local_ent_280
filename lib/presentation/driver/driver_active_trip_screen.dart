import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/data/driver_home_data.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';

enum _DriverTripPhase { onWay, arrived, inProgress }

/// Viagem ativa — motorista a caminho do passageiro ou em curso.
class DriverActiveTripScreen extends StatefulWidget {
  const DriverActiveTripScreen({super.key});

  @override
  State<DriverActiveTripScreen> createState() => _DriverActiveTripScreenState();
}

class _DriverActiveTripScreenState extends State<DriverActiveTripScreen> {
  _DriverTripPhase _phase = _DriverTripPhase.onWay;

  String _primaryLabel(BuildContext context) => switch (_phase) {
        _DriverTripPhase.onWay => context.l10n.driverOnTheWay,
        _DriverTripPhase.arrived => context.l10n.driverArrivedStatus,
        _DriverTripPhase.inProgress => context.l10n.driverTripInProgressStatus,
      };

  void _onArrived() => setState(() => _phase = _DriverTripPhase.arrived);

  void _onStartTrip() => setState(() => _phase = _DriverTripPhase.inProgress);

  void _onFinishTrip() => AppNavigation.toDriverHome(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  DriverActiveTripData.mapImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      ColoredBox(color: AppColors.surfaceContainer),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppLayout.marginMobile,
                      8.h,
                      AppLayout.marginMobile,
                      0,
                    ),
                    child: _NavigationBanner(),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _ActiveTripSheet(
                    phase: _phase,
                    primaryLabel: _primaryLabel(context),
                    onArrived: _onArrived,
                    onStartTrip: _onStartTrip,
                    onFinishTrip: _onFinishTrip,
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

class _NavigationBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.navigation, color: AppColors.accent, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.driverDistanceToDestination(
                    DriverActiveTripData.navigationDistance,
                  ),
                  style: AppTypography.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
                Text(
                  DriverActiveTripData.destinationAddress,
                  style: AppTypography.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
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

class _ActiveTripSheet extends StatelessWidget {
  const _ActiveTripSheet({
    required this.phase,
    required this.primaryLabel,
    required this.onArrived,
    required this.onStartTrip,
    required this.onFinishTrip,
  });

  final _DriverTripPhase phase;
  final String primaryLabel;
  final VoidCallback onArrived;
  final VoidCallback onStartTrip;
  final VoidCallback onFinishTrip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppLayout.marginMobile,
        20.h,
        AppLayout.marginMobile,
        24.h + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundImage: NetworkImage(DriverActiveTripData.passengerPhoto),
                onBackgroundImageError: (_, _) {},
                child: Icon(Icons.person, color: AppColors.accent),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            DriverActiveTripData.passengerName,
                            style: AppTypography.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentSurface,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'VIP',
                            style: AppTypography.inter(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14.sp, color: Colors.amber),
                        SizedBox(width: 4.w),
                        Text(
                          DriverActiveTripData.passengerRating,
                          style: AppTypography.inter(
                            fontSize: 13.sp,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            ' • ${l10n.driverVipPassenger}',
                            style: AppTypography.inter(
                              fontSize: 12.sp,
                              color: AppColors.labelMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.chat_bubble_outline, color: AppColors.accent),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.phone, color: AppColors.accent),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _TripStat(
                  label: l10n.driverEstimatedTimeLabel,
                  value: DriverActiveTripData.estimatedTime,
                ),
              ),
              Expanded(
                child: _TripStat(
                  label: l10n.driverDistanceStatLabel,
                  value: DriverActiveTripData.distance,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                disabledBackgroundColor: AppColors.accent,
                disabledForegroundColor: AppColors.onAccent,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                primaryLabel,
                style: AppTypography.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onAccent,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _WorkflowButton(
                  label: l10n.driverArrivedButton,
                  onTap: phase == _DriverTripPhase.onWay ? onArrived : null,
                  isEnabled: phase == _DriverTripPhase.onWay,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _WorkflowButton(
                  label: l10n.driverStartTripButton,
                  onTap: phase == _DriverTripPhase.arrived ? onStartTrip : null,
                  isEnabled: phase == _DriverTripPhase.arrived,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _WorkflowButton(
                  label: l10n.driverFinishTripButton,
                  onTap: phase == _DriverTripPhase.inProgress
                      ? onFinishTrip
                      : null,
                  isEnabled: phase == _DriverTripPhase.inProgress,
                  isDestructive: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripStat extends StatelessWidget {
  const _TripStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: AppColors.labelMuted,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTypography.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _WorkflowButton extends StatelessWidget {
  const _WorkflowButton({
    required this.label,
    required this.onTap,
    required this.isEnabled,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.error
        : isEnabled
            ? AppColors.primary
            : AppColors.labelMuted;

    return OutlinedButton(
      onPressed: isEnabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        disabledForegroundColor: AppColors.labelMuted,
        side: BorderSide(
          color: isEnabled
              ? (isDestructive
                  ? AppColors.error.withValues(alpha: 0.4)
                  : AppColors.outlineVariant)
              : AppColors.surfaceVariant,
        ),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
