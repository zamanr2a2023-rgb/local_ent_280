import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/features/admin/data/admin_repository.dart';
import 'package:local_ent_280/features/admin/data/models/admin_stats.dart';
import 'package:local_ent_280/l10n/app_localizations.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/presentation/admin/admin_drawer.dart';
import 'package:local_ent_280/presentation/widgets/session_profile_avatar.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/presentation/admin/widgets/admin_report_statement_tabs.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Detailed Reports — `roles/details.md`.
class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key, this.adminRepository});

  final AdminRepository? adminRepository;

  static List<BoxShadow> get _cardShadow => [
        BoxShadow(
          color: const Color(0x0A001736),
          blurRadius: 8.r,
          offset: Offset(0, 2.h),
        ),
      ];

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen>
    with SingleTickerProviderStateMixin {
  late final AdminRepository _repository;
  late final TabController _tabs;
  StreamSubscription? _reportsSubscription;

  AdminReportsStats _stats = AdminReportsStats.empty;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _repository = widget.adminRepository ?? AdminRepository();
    _reportsSubscription = _repository.watchReportsStats().listen((stats) {
      if (!mounted) return;
      setState(() => _stats = stats);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _reportsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AdminDrawer(selected: AdminDrawerSection.reports),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ReportsAppBar(title: l10n.adminReportsTitle),
            TabBar(
              controller: _tabs,
              labelColor: AppColors.primary,
              isScrollable: true,
              tabs: [
                Tab(text: l10n.adminReportsTabOverview),
                Tab(text: l10n.adminReportsTabClient),
                Tab(text: l10n.adminReportsTabDriver),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  ListView(
                    padding: EdgeInsets.fromLTRB(
                      AppLayout.marginMobile,
                      AppLayout.md,
                      AppLayout.marginMobile,
                      AppLayout.xxl,
                    ),
                    children: [
                      _FiltersCard(l10n: l10n),
                      SizedBox(height: AppLayout.lg),
                      _MetricsGrid(l10n: l10n, stats: _stats),
                      SizedBox(height: AppLayout.lg),
                      _PerformanceSection(l10n: l10n, stats: _stats),
                    ],
                  ),
                  AdminClientStatementTab(),
                  AdminDriverStatementTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsAppBar extends StatelessWidget {
  const _ReportsAppBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
      color: AppColors.background,
      child: Row(
        children: [
          IconButton(
            onPressed: () => AppNavigation.goAdminDashboard(context),
            icon: Icon(Icons.arrow_back, color: AppColors.primary, size: 24.sp),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
          ),
          SizedBox(width: AppLayout.sm),
          Expanded(
            child: Text(
              title,
              style: AppTypography.manrope(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                height: 32 / 24,
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_outlined, color: AppColors.primary, size: 24.sp),
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

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({required this.l10n});

  final AppLocalizations l10n;

  String _currentMonthRange() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final now = DateTime.now();
    final month = months[now.month - 1];
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    return '1 $month – $lastDay $month ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppLayout.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: AdminReportsScreen._cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FilterField(
            label: l10n.adminReportsDateRangeLabel,
            icon: Icons.calendar_today_outlined,
            value: _currentMonthRange(),
          ),
          SizedBox(height: AppLayout.md),
          _FilterField(
            label: l10n.adminReportsVehicleFleetLabel,
            icon: Icons.directions_car_outlined,
            value: l10n.adminReportsAllVehicles,
            showDropdown: true,
          ),
          SizedBox(height: AppLayout.md),
          SizedBox(
            height: 56.h,
            child: FilledButton.icon(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.onSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              icon: Icon(Icons.file_download_outlined, size: 20.sp),
              label: Text(
                l10n.adminReportsExport,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.label,
    required this.icon,
    required this.value,
    this.showDropdown = false,
  });

  final String label;
  final IconData icon;
  final String value;
  final bool showDropdown;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppLayout.sm, bottom: AppLayout.sm),
          child: Text(
            label,
            style: AppTypography.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppLayout.md, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: AppColors.outline),
              SizedBox(width: AppLayout.md),
              Expanded(
                child: Text(
                  value,
                  style: AppTypography.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              if (showDropdown)
                Icon(Icons.expand_more, size: 20.sp, color: AppColors.outline),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.l10n, required this.stats});

  final AppLocalizations l10n;
  final AdminReportsStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: l10n.adminReportsTotalTrips,
                value: stats.totalTripsFormatted,
                badge: stats.tripsTrendLabel,
                accentBorder: true,
              ),
            ),
            SizedBox(width: AppLayout.md),
            Expanded(
              child: _MetricCard(
                label: l10n.adminReportsTotalDistance,
                value: stats.totalDistanceFormatted,
                unit: 'km',
              ),
            ),
          ],
        ),
        SizedBox(height: AppLayout.md),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: l10n.adminReportsTimeOnRoute,
                value: stats.timeOnRouteFormatted,
                unit: 'h',
              ),
            ),
            SizedBox(width: AppLayout.md),
            Expanded(
              child: _MetricCard(
                label: l10n.adminReportsTotalCost,
                value: stats.totalCostFormatted,
                unit: AppCurrencyFormatter.instance.displaySymbol,
              ),
            ),
          ],
        ),
        SizedBox(height: AppLayout.md),
        _PendingDebtCard(l10n: l10n, stats: stats),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    this.unit,
    this.badge,
    this.accentBorder = false,
  });

  final String label;
  final String value;
  final String? unit;
  final String? badge;
  final bool accentBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppLayout.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: accentBorder
            ? Border(left: BorderSide(color: AppColors.secondary, width: 4.w))
            : null,
        boxShadow: AdminReportsScreen._cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppLayout.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: AppTypography.manrope(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          height: 32 / 24,
                          color: AppColors.primary,
                        ),
                      ),
                      if (unit != null)
                        TextSpan(
                          text: ' $unit',
                          style: AppTypography.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (badge != null) ...[
                SizedBox(width: AppLayout.sm),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryFixed,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    badge!,
                    style: AppTypography.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingDebtCard extends StatelessWidget {
  const _PendingDebtCard({required this.l10n, required this.stats});

  final AppLocalizations l10n;
  final AdminReportsStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppLayout.md),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
        boxShadow: AdminReportsScreen._cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.adminReportsPendingDebt,
                  style: AppTypography.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: AppLayout.sm),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: stats.pendingDebtFormatted,
                        style: AppTypography.manrope(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                      TextSpan(
                        text: ' ${AppCurrencyFormatter.instance.displaySymbol}',
                        style: AppTypography.inter(
                          fontSize: 12.sp,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppLayout.sm),
                Text(
                  l10n.adminReportsOverdueInvoices,
                  style: AppTypography.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28.sp),
        ],
      ),
    );
  }
}

class _PerformanceSection extends StatelessWidget {
  const _PerformanceSection({required this.l10n, required this.stats});

  final AppLocalizations l10n;
  final AdminReportsStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(AppLayout.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.adminReportsMonthlyPerformance,
                    style: AppTypography.manrope(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      height: 28 / 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.surfaceVariant),
          Padding(
            padding: EdgeInsets.all(AppLayout.lg),
            child: Column(
              children: [
                _ChartPlaceholder(hint: l10n.adminReportsChartHint),
                SizedBox(height: AppLayout.lg),
                _ActivitiesAndEfficiency(l10n: l10n, stats: stats),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: AspectRatio(
        aspectRatio: 21 / 9,
        child: ColoredBox(
          color: AppColors.surfaceContainerLow,
          child: Padding(
            padding: EdgeInsets.all(AppLayout.md),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Symbols.query_stats,
                      size: 32.sp,
                      color: AppColors.primaryContainer.withValues(alpha: 0.4),
                    ),
                    SizedBox(height: AppLayout.sm),
                    SizedBox(
                      width: 220.w,
                      child: Text(
                        hint,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          height: 20 / 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivitiesAndEfficiency extends StatelessWidget {
  const _ActivitiesAndEfficiency({required this.l10n, required this.stats});

  final AppLocalizations l10n;
  final AdminReportsStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.adminReportsLatestActivities,
          style: AppTypography.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: AppLayout.md),
        if (stats.recentActivities.isEmpty)
          Text(
            l10n.adminNoReportActivities,
            style: AppTypography.inter(
              fontSize: 13.sp,
              color: AppColors.onSurfaceVariant,
            ),
          )
        else
          for (final activity in stats.recentActivities) ...[
            _ActivityTile(activity: activity),
            SizedBox(height: AppLayout.sm),
          ],
        SizedBox(height: AppLayout.md),
        _FleetEfficiencyCard(l10n: l10n, stats: stats),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final AdminReportActivityRow activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppLayout.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Symbols.commute, color: AppColors.secondary, size: 22.sp),
          ),
          SizedBox(width: AppLayout.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  '${activity.reference} • ${activity.time}',
                  style: AppTypography.inter(
                    fontSize: 12.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity.amount,
            style: AppTypography.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FleetEfficiencyCard extends StatelessWidget {
  const _FleetEfficiencyCard({required this.l10n, required this.stats});

  final AppLocalizations l10n;
  final AdminReportsStats stats;

  @override
  Widget build(BuildContext context) {
    final percent = stats.fleetEfficiencyPercent;

    return Container(
      padding: EdgeInsets.all(AppLayout.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            l10n.adminReportsFleetEfficiency,
            style: AppTypography.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.primaryFixed,
            ),
          ),
          SizedBox(height: AppLayout.md),
          SizedBox(
            width: 128.w,
            height: 128.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: percent / 100,
                    strokeWidth: 3.w,
                    backgroundColor: const Color(0xFF264778),
                    color: AppColors.primaryFixedDim,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percent%',
                      style: AppTypography.manrope(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryFixed,
                      ),
                    ),
                    Text(
                      l10n.adminReportsOptimizedStatus,
                      style: AppTypography.inter(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppColors.primaryFixed.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppLayout.md),
          Text(
            l10n.adminReportsEfficiencyFooter,
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              height: 16 / 12,
              color: AppColors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
