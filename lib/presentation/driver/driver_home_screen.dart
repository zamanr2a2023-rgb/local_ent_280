import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/data/driver_home_data.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/presentation/driver/driver_drawer.dart';
import 'package:local_ent_280/presentation/widgets/app_bottom_nav.dart';
import 'package:local_ent_280/presentation/widgets/session_profile_avatar.dart';

/// Página Inicial — Motorista (dashboard com disponibilidade e ganhos).
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isAvailable = true;
  Timer? _requestSimulationTimer;

  @override
  void initState() {
    super.initState();
    _scheduleTripRequestSimulation();
  }

  @override
  void dispose() {
    _requestSimulationTimer?.cancel();
    super.dispose();
  }

  void _scheduleTripRequestSimulation() {
    _requestSimulationTimer?.cancel();
    if (!_isAvailable) return;
    _requestSimulationTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted || !_isAvailable) return;
      AppNavigation.toDriverTripRequest(context);
    });
  }

  void _setAvailability(bool value) {
    setState(() => _isAvailable = value);
    if (value) {
      _scheduleTripRequestSimulation();
    } else {
      _requestSimulationTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const DriverDrawer(selected: DriverDrawerSection.home),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _DriverAppBar(
              onProfileTap: () => AppNavigation.onDriverBottomNavTap(
                context,
                AppNavIndex.perfil,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppLayout.marginMobile,
                  12.h,
                  AppLayout.marginMobile,
                  16.h,
                ),
                children: [
                  _AvailabilityToggle(
                    isAvailable: _isAvailable,
                    onChanged: _setAvailability,
                  ),
                  SizedBox(height: 16.h),
                  const _MapPreview(),
                  SizedBox(height: 20.h),
                  const _FleetStatusSection(),
                  SizedBox(height: 16.h),
                  const _VehicleCard(),
                  SizedBox(height: 20.h),
                  const _EarningsCard(),
                  SizedBox(height: 12.h),
                  const _StatsRow(),
                  SizedBox(height: 24.h),
                  const _RecentTripsSection(),
                ],
              ),
            ),
            AppBottomNav(
              mode: AppBottomNavMode.driver,
              selectedIndex: 0,
              onItemTap: (index) =>
                  AppNavigation.onDriverBottomNavLocalTap(context, index),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverAppBar extends StatelessWidget {
  const _DriverAppBar({required this.onProfileTap});

  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
      color: AppColors.background,
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(Icons.menu, color: AppColors.primary, size: 24.sp),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              context.l10n.premiumMobility,
              style: AppTypography.manrope(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                height: 32 / 22,
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SessionProfileAvatar(
            size: 36.w,
            fontSize: 12.sp,
            onTap: onProfileTap,
          ),
        ],
      ),
    );
  }
}

class _AvailabilityToggle extends StatelessWidget {
  const _AvailabilityToggle({
    required this.isAvailable,
    required this.onChanged,
  });

  final bool isAvailable;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: l10n.driverAvailable,
              isSelected: isAvailable,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _ToggleOption(
              label: l10n.driverUnavailable,
              isSelected: !isAvailable,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(999.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.onAccent : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        height: 140.h,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              DriverHomeData.mapImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: AppColors.surfaceContainer,
                child: Icon(Icons.map, size: 40.sp, color: AppColors.outline),
              ),
            ),
            Positioned(
              left: 12.w,
              bottom: 12.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.my_location, size: 14.sp, color: AppColors.accent),
                    SizedBox(width: 4.w),
                    Text(
                      context.l10n.driverLocationCity,
                      style: AppTypography.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FleetStatusSection extends StatelessWidget {
  const _FleetStatusSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.driverFleetStatus,
            style: AppTypography.manrope(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.accentSurface,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Text(
            l10n.driverVerified,
            style: AppTypography.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.surfaceVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.directions_car, color: AppColors.accent, size: 28.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DriverHomeData.vehicleModel,
                  style: AppTypography.manrope(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${DriverHomeData.licensePlate} • ${l10n.driverInOperation}',
                  style: AppTypography.inter(
                    fontSize: 13.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.battery_charging_full, color: AppColors.accent, size: 20.sp),
              Text(
                DriverHomeData.batteryLevel,
                style: AppTypography.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  const _EarningsCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.driverTodayEarnings,
            style: AppTypography.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            DriverHomeData.todayEarnings,
            style: AppTypography.manrope(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.onPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.trending_up, size: 14.sp, color: AppColors.primaryFixed),
              SizedBox(width: 4.w),
              Text(
                l10n.driverEarningsChange,
                style: AppTypography.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryFixed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: DriverHomeData.tripsCount,
            label: l10n.driverTripsLabel,
            icon: Icons.directions_car_outlined,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _StatCard(
            value: DriverHomeData.distanceValue,
            label: l10n.driverDistanceLabel,
            icon: Icons.route_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.surfaceVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.sp, color: AppColors.accent),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AppTypography.manrope(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: AppTypography.inter(
              fontSize: 12.sp,
              color: AppColors.labelMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTripsSection extends StatelessWidget {
  const _RecentTripsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.driverRecentTrips,
          style: AppTypography.manrope(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 12.h),
        for (final trip in DriverHomeData.recentTrips) ...[
          _RecentTripTile(trip: trip),
          SizedBox(height: 8.h),
        ],
      ],
    );
  }
}

class _RecentTripTile extends StatelessWidget {
  const _RecentTripTile({required this.trip});

  final DriverRecentTrip trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.surfaceVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.accentSurface,
            child: Icon(Icons.person, size: 18.sp, color: AppColors.accent),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.passengerName,
                  style: AppTypography.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  trip.destination,
                  style: AppTypography.inter(
                    fontSize: 12.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                trip.price,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Text(
                context.l10n.driverHoursAgo(trip.hoursAgo),
                style: AppTypography.inter(
                  fontSize: 11.sp,
                  color: AppColors.labelMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
