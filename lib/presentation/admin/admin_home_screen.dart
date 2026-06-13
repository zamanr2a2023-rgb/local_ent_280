import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/features/admin/data/admin_repository.dart';
import 'package:local_ent_280/features/admin/data/models/admin_stats.dart';
import 'package:local_ent_280/presentation/admin/admin_drawer.dart';
import 'package:local_ent_280/presentation/widgets/admin_activity_map_layer.dart';
import 'package:local_ent_280/presentation/widgets/session_profile_avatar.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Painel Admin — Mobilidade Premium (`roles/details.md`).
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key, this.adminRepository});

  final AdminRepository? adminRepository;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0x0A001736),
          blurRadius: 8.r,
          offset: Offset(0, 2.h),
        ),
      ];

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late final AdminRepository _repository;
  StreamSubscription? _dashboardSubscription;
  StreamSubscription? _tariffSubscription;
  StreamSubscription? _fleetSubscription;
  StreamSubscription? _marketSubscription;
  StreamSubscription? _activityMapSubscription;

  AdminDashboardStats _stats = AdminDashboardStats.empty;
  AdminTariffSummary? _tariff;
  AdminMarketSummary? _market;
  AdminActivityMapData _activityMap = AdminActivityMapData.empty;
  List<AdminFleetRow> _fleet = const [];

  @override
  void initState() {
    super.initState();
    _repository = widget.adminRepository ?? AdminRepository();
    _dashboardSubscription =
        _repository.watchDashboardStats().listen((stats) {
      if (!mounted) return;
      setState(() => _stats = stats);
    });
    _tariffSubscription = _repository.watchTariffSummary().listen((tariff) {
      if (!mounted) return;
      setState(() => _tariff = tariff);
    });
    _fleetSubscription = _repository.watchRecentFleet().listen((fleet) {
      if (!mounted) return;
      setState(() => _fleet = fleet);
    });
    _marketSubscription = _repository.watchMarketSummary().listen((market) {
      if (!mounted) return;
      setState(() => _market = market);
    });
    _activityMapSubscription = _repository.watchActivityMap().listen((mapData) {
      if (!mounted) return;
      setState(() => _activityMap = mapData);
    });
  }

  @override
  void dispose() {
    _dashboardSubscription?.cancel();
    _tariffSubscription?.cancel();
    _fleetSubscription?.cancel();
    _marketSubscription?.cancel();
    _activityMapSubscription?.cancel();
    super.dispose();
  }

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
                  _FleetStatusSection(stats: _stats),
                  SizedBox(height: AppLayout.lg),
                  _CriticalOperationsSection(stats: _stats),
                  SizedBox(height: AppLayout.lg),
                  _ActivityMapSection(activityMap: _activityMap),
                  SizedBox(height: AppLayout.lg),
                  _RatesSection(tariff: _tariff, market: _market),
                  SizedBox(height: AppLayout.lg),
                  _RecentFleetSection(fleet: _fleet),
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
  const _FleetStatusSection({required this.stats});

  final AdminDashboardStats stats;

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
                value: stats.activeTripsFormatted,
                label: context.l10n.adminActiveTripsLabel,
                footerDotColor: AppColors.secondary,
                footerText: context.l10n.adminActiveTripsTrendDynamic(
                  stats.activeTripsTrendLabel,
                ),
                footerTextColor: AppColors.secondary,
              ),
            ),
            SizedBox(width: AppLayout.md),
            Expanded(
              child: _FleetStatCard(
                icon: Symbols.person_pin,
                iconColor: AppColors.tertiary,
                value: stats.availableDriversFormatted,
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
        boxShadow: AdminHomeScreen.cardShadow,
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
  const _CriticalOperationsSection({required this.stats});

  final AdminDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final monthName = _monthLabel(context);
    final debtSubtitle = stats.pendingDebtorCount == 0
        ? context.l10n.adminPendingDebtorsCount(0)
        : context.l10n.adminPendingDebtorsCount(stats.pendingDebtorCount);

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
            boxShadow: AdminHomeScreen.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _CriticalOpRow(
                icon: Symbols.payments,
                iconBg: AppColors.errorContainer,
                iconColor: AppColors.error,
                title: context.l10n.adminPendingDebtorsTitle,
                subtitle: debtSubtitle,
                onTap: () => AppNavigation.toAdminReports(context),
                trailing: Text(
                  stats.pendingDebtFormatted,
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
                subtitle: context.l10n.adminMonthlyReportsSubtitle.replaceFirst(
                  'October',
                  monthName,
                ),
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

  String _monthLabel(BuildContext context) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[DateTime.now().month - 1];
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

class _ActivityMapSection extends StatefulWidget {
  const _ActivityMapSection({required this.activityMap});

  final AdminActivityMapData activityMap;

  @override
  State<_ActivityMapSection> createState() => _ActivityMapSectionState();
}

class _ActivityMapSectionState extends State<_ActivityMapSection> {
  final _mapKey = GlobalKey<AdminActivityMapLayerState>();

  @override
  Widget build(BuildContext context) {
    final activityMap = widget.activityMap;
    final locationLabel =
        activityMap.locationLabel ?? context.l10n.driverLocationCity;
    final liveSummary = activityMap.hasLiveMarkers
        ? '${activityMap.activeTripCount} trips • ${activityMap.activeDriverCount} drivers'
        : context.l10n.adminActivityMapWaiting;

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
        Text(
          liveSummary,
          style: AppTypography.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
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
                AdminActivityMapLayer(
                  key: _mapKey,
                  data: activityMap,
                  initialZoom: 11,
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
                            locationLabel,
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
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _mapKey.currentState?.recenter(),
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
  const _RatesSection({required this.tariff, required this.market});

  final AdminTariffSummary? tariff;
  final AdminMarketSummary? market;

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
              _BaseRateCard(tariff: tariff),
              SizedBox(width: AppLayout.md),
              _FuelCostCard(market: market),
            ],
          ),
        ),
      ],
    );
  }
}

class _BaseRateCard extends StatelessWidget {
  const _BaseRateCard({required this.tariff});

  final AdminTariffSummary? tariff;

  @override
  Widget build(BuildContext context) {
    final rate = tariff?.perKmFormatted ?? '—';
    final dynamicText = tariff?.dynamicLabel == null
        ? context.l10n.adminBaseRateDynamic
        : context.l10n.adminBaseRateLive(tariff!.dynamicLabel!);

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
            rate,
            style: AppTypography.manrope(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              height: 32 / 22,
              color: AppColors.onPrimary,
            ),
          ),
          Text(
            dynamicText,
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
  const _FuelCostCard({required this.market});

  final AdminMarketSummary? market;

  @override
  Widget build(BuildContext context) {
    final value = market?.hasFuelCost == true
        ? market!.fuelCostFormatted
        : '—';

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
            value,
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
  const _RecentFleetSection({required this.fleet});

  final List<AdminFleetRow> fleet;

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
              onPressed: () => AppNavigation.toAdminFleet(context),
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
        if (fleet.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppLayout.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: Text(
              context.l10n.adminNoFleetVehicles,
              style: AppTypography.inter(
                fontSize: 13.sp,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          )
        else
          for (var i = 0; i < fleet.length; i++) ...[
            _FleetVehicleCard(row: fleet[i]),
            if (i < fleet.length - 1) SizedBox(height: AppLayout.md),
          ],
      ],
    );
  }
}

class _FleetVehicleCard extends StatelessWidget {
  const _FleetVehicleCard({required this.row});

  final AdminFleetRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statusLabel =
        row.isOnTrip ? l10n.adminFleetStatusOnTrip : l10n.adminFleetStatusInactive;

    return Container(
      padding: EdgeInsets.all(AppLayout.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: AdminHomeScreen.cardShadow,
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
                  row.vehicleLabel.isNotEmpty ? row.vehicleLabel : '—',
                  style: AppTypography.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                    letterSpacing: 0.1,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  row.driverLabel,
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
              color: row.isOnTrip
                  ? AppColors.primaryContainer.withValues(alpha: 0.1)
                  : const Color(0x33D8DADC),
              borderRadius: BorderRadius.circular(999.r),
              border: row.isOnTrip
                  ? null
                  : Border.all(color: AppColors.outlineVariant),
            ),
            child: Text(
              statusLabel,
              style: AppTypography.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                height: 16 / 12,
                color: row.isOnTrip
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
