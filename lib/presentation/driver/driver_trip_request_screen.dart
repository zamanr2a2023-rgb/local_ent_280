import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/data/driver_home_data.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';

/// Pedido de viagem recebido — aceitar ou recusar dentro de 12 segundos.
class DriverTripRequestScreen extends StatefulWidget {
  const DriverTripRequestScreen({super.key});

  @override
  State<DriverTripRequestScreen> createState() =>
      _DriverTripRequestScreenState();
}

class _DriverTripRequestScreenState extends State<DriverTripRequestScreen> {
  late int _secondsLeft;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = DriverTripRequestData.acceptCountdownSeconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        AppNavigation.toDriverRequestExpired(context);
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _accept() {
    _countdownTimer?.cancel();
    AppNavigation.toDriverTripAccepted(context);
  }

  void _decline() {
    _countdownTimer?.cancel();
    AppNavigation.toDriverHome(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.35),
              BlendMode.darken,
            ),
            child: Image.network(
              DriverHomeData.mapImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  ColoredBox(color: AppColors.surfaceContainer),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const _RequestAppBar(),
                const Spacer(),
                _RequestCard(
                  secondsLeft: _secondsLeft,
                  onAccept: _accept,
                  onDecline: _decline,
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestAppBar extends StatelessWidget {
  const _RequestAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
      child: Row(
        children: [
          IconButton(
            onPressed: () => AppNavigation.toDriverHome(context),
            icon: Icon(Icons.close, color: AppColors.onPrimary, size: 24.sp),
          ),
          Expanded(
            child: Text(
              context.l10n.premiumMobility,
              textAlign: TextAlign.center,
              style: AppTypography.manrope(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.onPrimary,
              ),
            ),
          ),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.secondsLeft,
    required this.onAccept,
    required this.onDecline,
  });

  final int secondsLeft;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 24.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.accentSurface,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    l10n.driverNewRequest.toUpperCase(),
                    style: AppTypography.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const Spacer(),
                _CountdownBadge(secondsLeft: secondsLeft),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.driverPremiumTrip,
              style: AppTypography.manrope(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 20.h),
            _RouteRow(
              icon: Icons.trip_origin,
              iconColor: AppColors.accent,
              label: l10n.driverPickup.toUpperCase(),
              address: DriverTripRequestData.pickupAddress,
              detail: DriverTripRequestData.pickupDistance,
            ),
            SizedBox(height: 16.h),
            _RouteRow(
              icon: Icons.location_on,
              iconColor: AppColors.error,
              label: l10n.driverDestination.toUpperCase(),
              address: DriverTripRequestData.destinationAddress,
              detail: DriverTripRequestData.destinationInfo,
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundImage: NetworkImage(
                    DriverTripRequestData.passengerPhoto,
                  ),
                  onBackgroundImageError: (_, _) {},
                  child: Icon(Icons.person, color: AppColors.accent),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DriverTripRequestData.passengerName,
                        style: AppTypography.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14.sp, color: Colors.amber),
                          SizedBox(width: 4.w),
                          Text(
                            DriverTripRequestData.passengerRating,
                            style: AppTypography.inter(
                              fontSize: 13.sp,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  DriverTripRequestData.fare,
                  style: AppTypography.manrope(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurfaceVariant,
                      side: BorderSide(color: AppColors.outlineVariant),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      l10n.driverDecline,
                      style: AppTypography.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: onAccept,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.onAccent,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      l10n.driverAcceptTrip,
                      style: AppTypography.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge({required this.secondsLeft});

  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    final progress = secondsLeft / DriverTripRequestData.acceptCountdownSeconds;

    return SizedBox(
      width: 48.w,
      height: 48.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3.w,
            backgroundColor: AppColors.surfaceContainer,
            color: AppColors.accent,
          ),
          Text(
            '${secondsLeft}s',
            style: AppTypography.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.address,
    required this.detail,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String address;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: iconColor),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: AppColors.labelMuted,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                address,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                detail,
                style: AppTypography.inter(
                  fontSize: 12.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
