import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/data/admin_home_data.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/presentation/admin/admin_drawer.dart';
import 'package:local_ent_280/presentation/widgets/session_profile_avatar.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Painel Admin — Mobilidade Premium (`roles/details.md`).
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  static List<BoxShadow> get _cardShadow => [
        BoxShadow(
          color: const Color(0x0A001736),
          blurRadius: 8.r,
          offset: Offset(0, 2.h),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AdminDrawer(selected: AdminDrawerSection.home),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _AdminAppBar(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppLayout.marginMobile,
                  AppLayout.md,
                  AppLayout.marginMobile,
                  AppLayout.xxl,
                ),
                children: [
                  const _FleetStatusSection(),
                  SizedBox(height: AppLayout.lg),
                  const _CriticalOperationsSection(),
                  SizedBox(height: AppLayout.lg),
                  const _ActivityMapSection(),
                  SizedBox(height: AppLayout.lg),
                  const _RatesSection(),
                  SizedBox(height: AppLayout.lg),
                  const _RecentFleetSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminAppBar extends StatelessWidget {
  const _AdminAppBar();

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
          SizedBox(width: AppLayout.md),
          Expanded(
            child: Text(
              context.l10n.adminAppBarTitle,
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
            size: 32.w,
            fontSize: 11.sp,
            onTap: () => AppNavigation.toProfile(context),
          ),
        ],
      ),
    );
  }
}

class _FleetStatusSection extends StatelessWidget {
  const _FleetStatusSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                context.l10n.adminFleetStatusTitle,
                style: AppTypography.manrope(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  height: 28 / 18,
                  color: AppColors.primary,
                ),
              ),
            ),
            Text(
              context.l10n.adminFleetStatusUpdated,
              style: AppTypography.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                height: 16 / 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: AppLayout.sm),
        Row(
          children: [
            Expanded(
              child: _FleetStatCard(
                icon: Symbols.directions_car,
                iconColor: AppColors.secondary,
                value: AdminHomeData.activeTripsCount,
                label: context.l10n.adminActiveTripsLabel,
                footerDotColor: AppColors.secondary,
                footerText: context.l10n.adminActiveTripsTrend,
                footerTextColor: AppColors.secondary,
              ),
            ),
            SizedBox(width: AppLayout.md),
            Expanded(
              child: _FleetStatCard(
                icon: Symbols.person_pin,
                iconColor: AppColors.tertiary,
                value: AdminHomeData.availableDriversCount,
                label: context.l10n.adminAvailableDriversLabel,
                footerDotColor: AppColors.tertiaryContainer,
                footerText: context.l10n.adminAvailableDriversHint,
                footerTextColor: AppColors.onTertiaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FleetStatCard extends StatelessWidget {
  const _FleetStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.footerDotColor,
    required this.footerText,
    required this.footerTextColor,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color footerDotColor;
  final String footerText;
  final Color footerTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppLayout.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: AdminHomeScreen._cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24.sp, fill: 1.0),
          SizedBox(height: AppLayout.unit),
          Text(
            value,
            style: AppTypography.manrope(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              height: 40 / 32,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: AppTypography.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 20 / 14,
              letterSpacing: 0.1,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppLayout.unit),
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: footerDotColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: AppLayout.unit),
              Expanded(
                child: Text(
                  footerText,
                  style: AppTypography.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    height: 16 / 12,
                    color: footerTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CriticalOperationsSection extends StatelessWidget {
  const _CriticalOperationsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.adminCriticalOpsTitle,
          style: AppTypography.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            height: 28 / 18,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: AppLayout.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.surfaceVariant),
            boxShadow: AdminHomeScreen._cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _CriticalOpRow(
                icon: Symbols.payments,
                iconBg: AppColors.errorContainer,
                iconColor: AppColors.error,
                title: context.l10n.adminPendingDebtorsTitle,
                subtitle: context.l10n.adminPendingDebtorsSubtitle,
                onTap: () => AppNavigation.toAdminReports(context),
                trailing: Text(
                  AdminHomeData.pendingDebtorsAmount,
                  style: AppTypography.manrope(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    height: 28 / 18,
                    color: AppColors.error,
                  ),
                ),
                showDivider: true,
              ),
              _CriticalOpRow(
                icon: Symbols.analytics,
                iconBg: AppColors.secondaryFixed,
                iconColor: AppColors.secondary,
                title: context.l10n.adminMonthlyReportsTitle,
                subtitle: context.l10n.adminMonthlyReportsSubtitle,
                backgroundColor: AppColors.surfaceContainerLow,
                onTap: () => AppNavigation.toAdminReports(context),
                trailing: Icon(
                  Icons.chevron_right,
                  color: AppColors.outline,
                  size: 24.sp,
                ),
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CriticalOpRow extends StatelessWidget {
  const _CriticalOpRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    this.backgroundColor,
    this.showDivider = false,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? AppColors.surfaceContainerLowest,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(AppLayout.md),
              child: Row(
                children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22.sp),
                ),
                SizedBox(width: AppLayout.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          height: 20 / 14,
                          letterSpacing: 0.1,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTypography.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          height: 24 / 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                  trailing,
                ],
              ),
            ),
            if (showDivider)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.surfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

class _ActivityMapSection extends StatelessWidget {
  const _ActivityMapSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.adminActivityMapTitle,
          style: AppTypography.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            height: 28 / 18,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: AppLayout.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: SizedBox(
            height: 192.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  AdminHomeData.activityMapImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => ColoredBox(
                    color: AppColors.surfaceContainerHigh,
                    child: Icon(
                      Icons.map,
                      size: 48.sp,
                      color: AppColors.outline,
                    ),
                  ),
                ),
                Positioned(
                  top: AppLayout.md,
                  left: AppLayout.md,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest
                          .withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8.r,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppLayout.sm,
                        vertical: AppLayout.unit,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: AppLayout.unit),
                          Text(
                            AdminHomeData.activityMapLocation,
                            style: AppTypography.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              height: 16 / 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: AppLayout.md,
                  bottom: AppLayout.md,
                  child: Material(
                    color: AppColors.surfaceContainerLowest,
                    shape: const CircleBorder(),
                    elevation: 4,
                    child: SizedBox(
                      width: 40.w,
                      height: 40.h,
                      child: Icon(
                        Symbols.my_location,
                        color: AppColors.primary,
                        size: 22.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RatesSection extends StatelessWidget {
  const _RatesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.adminRatesTitle,
          style: AppTypography.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            height: 28 / 18,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: AppLayout.sm),
        SizedBox(
          height: 140.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _BaseRateCard(),
              SizedBox(width: AppLayout.md),
              _FuelCostCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class _BaseRateCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,
      padding: EdgeInsets.all(AppLayout.md),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.adminBaseRateLabel,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  color: AppColors.onPrimary.withValues(alpha: 0.8),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  context.l10n.live,
                  style: AppTypography.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            AdminHomeData.baseRateValue,
            style: AppTypography.manrope(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              height: 32 / 22,
              color: AppColors.onPrimary,
            ),
          ),
          Text(
            context.l10n.adminBaseRateDynamic,
            style: AppTypography.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              height: 16 / 12,
              color: AppColors.onPrimary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _FuelCostCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,
      padding: EdgeInsets.all(AppLayout.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.adminFuelCostLabel,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Icon(
                Symbols.trending_up,
                color: AppColors.error,
                size: 18.sp,
              ),
            ],
          ),
          const Spacer(),
          Text(
            AdminHomeData.fuelCostValue,
            style: AppTypography.manrope(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              height: 32 / 22,
              color: AppColors.primary,
            ),
          ),
          Text(
            context.l10n.adminFuelCostHint,
            style: AppTypography.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              height: 16 / 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentFleetSection extends StatelessWidget {
  const _RecentFleetSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.adminRecentFleetTitle,
                style: AppTypography.manrope(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  height: 28 / 18,
                  color: AppColors.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                context.l10n.seeAll,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppLayout.sm),
        for (var i = 0; i < AdminHomeData.recentFleet.length; i++) ...[
          _FleetVehicleCard(vehicle: AdminHomeData.recentFleet[i]),
          if (i < AdminHomeData.recentFleet.length - 1)
            SizedBox(height: AppLayout.md),
        ],
      ],
    );
  }
}

class _FleetVehicleCard extends StatelessWidget {
  const _FleetVehicleCard({required this.vehicle});

  final AdminFleetVehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final isActive = vehicle.status == AdminFleetStatus.emViagem;
    final l10n = context.l10n;
    final statusLabel = isActive
        ? l10n.adminFleetStatusOnTrip
        : l10n.adminFleetStatusInactive;

    return Container(
      padding: EdgeInsets.all(AppLayout.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: AdminHomeScreen._cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Symbols.local_taxi,
              color: AppColors.primaryContainer,
              size: 28.sp,
            ),
          ),
          SizedBox(width: AppLayout.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.vehicle,
                  style: AppTypography.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                    letterSpacing: 0.1,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  vehicle.driver,
                  style: AppTypography.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    height: 24 / 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppLayout.sm,
              vertical: AppLayout.unit,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryContainer.withValues(alpha: 0.1)
                  : const Color(0x33D8DADC),
              borderRadius: BorderRadius.circular(999.r),
              border: isActive
                  ? null
                  : Border.all(color: AppColors.outlineVariant),
            ),
            child: Text(
              statusLabel,
              style: AppTypography.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                height: 16 / 12,
                color: isActive
                    ? AppColors.onPrimaryContainer
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
