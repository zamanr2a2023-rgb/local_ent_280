import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/core/data/trip_history_data.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/features/auth/data/user_session.dart';
import 'package:local_ent_280/features/driver/data/driver_repository.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';
import 'package:local_ent_280/features/trips/data/trip_history_mapper.dart';
import 'package:local_ent_280/app/presentation/providers/repository_scope.dart';
import 'package:local_ent_280/features/trips/domain/repositories/trip_repository.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/presentation/widgets/app_bottom_nav.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/l10n/app_localizations.dart';

/// Histórico de Viagens — `roles/details.md`.
enum TripHistoryAudience { client, driver }

/// Histórico de Viagens — `roles/details.md`.
class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({
    super.key,
    this.tripRepository,
    this.driverRepository,
    this.clientId,
    this.driverId,
    this.audience = TripHistoryAudience.client,
  });

  final TripRepository? tripRepository;
  final DriverRepository? driverRepository;
  final String? clientId;
  final String? driverId;
  final TripHistoryAudience audience;

  static String _filterLabel(
    AppLocalizations l10n,
    TripHistoryFilter filter,
  ) {
    return switch (filter) {
      TripHistoryFilter.todos => l10n.tripHistoryFilterAll,
      TripHistoryFilter.recentes => l10n.tripHistoryFilterRecent,
      TripHistoryFilter.concluidas => l10n.tripHistoryFilterCompleted,
      TripHistoryFilter.canceladas => l10n.tripHistoryFilterCancelled,
      TripHistoryFilter.esteAno => l10n.tripHistoryFilterThisYear,
    };
  }

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  TripHistoryFilter _filter = TripHistoryFilter.todos;
  TripRepository get _tripRepository =>
      widget.tripRepository ?? tripRepositoryOf(context);
  late final DriverRepository _driverRepository =
      widget.driverRepository ?? DriverRepository();

  bool get _isDriverMode => widget.audience == TripHistoryAudience.driver;

  List<TripHistoryItem> _filterTrips(List<TripHistoryItem> trips) {
    final now = DateTime.now();
    switch (_filter) {
      case TripHistoryFilter.todos:
        return trips;
      case TripHistoryFilter.recentes:
        final cutoff = now.subtract(const Duration(days: 30));
        return trips
            .where(
              (trip) =>
                  trip.createdAt != null && trip.createdAt!.isAfter(cutoff),
            )
            .toList();
      case TripHistoryFilter.esteAno:
        return trips
            .where((trip) => trip.createdAt?.year == now.year)
            .toList();
      case TripHistoryFilter.concluidas:
        return trips
            .where((t) => t.status == TripHistoryStatus.concluida)
            .toList();
      case TripHistoryFilter.canceladas:
        return trips
            .where((t) => t.status == TripHistoryStatus.cancelada)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = UserSession.instance.profile?.uid;
    final clientId = widget.clientId ?? userId;
    final driverId = widget.driverId ?? userId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _HistoryAppBar(),
            Expanded(
              child: Stack(
                children: [
                  _isDriverMode
                      ? (driverId == null
                          ? const Center(child: CircularProgressIndicator())
                          : StreamBuilder(
                              stream: _driverRepository
                                  .watchDriverTripHistory(driverId),
                              builder: (context, snapshot) =>
                                  _buildHistoryBody(context, snapshot),
                            ))
                      : (clientId == null
                          ? const Center(child: CircularProgressIndicator())
                          : StreamBuilder(
                              stream:
                                  _tripRepository.watchClientTrips(clientId),
                              builder: (context, snapshot) =>
                                  _buildHistoryBody(context, snapshot),
                            )),
                  if (!_isDriverMode)
                    Positioned(
                      right: AppLayout.marginMobile,
                      bottom: 16.h,
                      child: _FloatingAddButton(
                        onTap: () => AppNavigation.toTripDestination(context),
                      ),
                    ),
                ],
              ),
            ),
            AppBottomNav(
              mode: _isDriverMode
                  ? AppBottomNavMode.driver
                  : AppBottomNavMode.full,
              selectedIndex:
                  _isDriverMode ? 1 : AppNavIndex.viagens,
              onItemTap: (index) => _isDriverMode
                  ? AppNavigation.onDriverBottomNavLocalTap(context, index)
                  : AppNavigation.onBottomNavTap(context, index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryBody(
    BuildContext context,
    AsyncSnapshot<List<TripRecord>> snapshot,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Padding(
        padding: EdgeInsets.all(AppLayout.marginMobile),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 40.sp,
              color: AppColors.onSurfaceVariant,
            ),
            SizedBox(height: 12.h),
            Text(
              context.l10n.tripHistoryLoadError,
              textAlign: TextAlign.center,
              style: AppTypography.inter(
                fontSize: 14.sp,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final records = snapshot.data ?? const [];
    final trips = records
        .map(TripHistoryMapper.fromTripRecord)
        .toList(growable: false);
    final filteredTrips = _filterTrips(trips);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppLayout.marginMobile,
        16.h,
        AppLayout.marginMobile,
        96.h,
      ),
      children: [
        _HeaderStats(trips: trips),
        SizedBox(height: 24.h),
        _FilterChips(
          selected: _filter,
          onSelected: (f) => setState(() => _filter = f),
        ),
        SizedBox(height: 16.h),
        if (filteredTrips.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 32.h),
            child: Column(
              children: [
                Text(
                  context.l10n.tripHistoryEmpty,
                  textAlign: TextAlign.center,
                  style: AppTypography.manrope(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  context.l10n.tripHistoryEmptyBody,
                  textAlign: TextAlign.center,
                  style: AppTypography.inter(
                    fontSize: 14.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        for (final trip in filteredTrips) ...[
          _TripCard(trip: trip),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }
}

class _HistoryAppBar extends StatelessWidget {
  const _HistoryAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
      color: AppColors.background,
      alignment: Alignment.centerLeft,
      child: Text(
        context.l10n.appNameLocalTransport,
        style: AppTypography.manrope(
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
          height: 32 / 22,
          color: AppColors.primary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _HeaderStats extends StatelessWidget {
  const _HeaderStats({required this.trips});

  final List<TripHistoryItem> trips;

  String get _monthSpend {
    final now = DateTime.now();
    final monthTotalMinor = trips.fold<int>(0, (sum, trip) {
      final createdAt = trip.createdAt;
      if (createdAt == null) return sum;
      if (createdAt.year != now.year || createdAt.month != now.month) {
        return sum;
      }
      return sum + trip.costMinor;
    });
    return AppCurrencyFormatter.instance.formatEurMinor(monthTotalMinor);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.tripHistoryActivity.toUpperCase(),
          style: AppTypography.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            height: 20 / 14,
            letterSpacing: 1.2,
            color: AppColors.secondary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          context.l10n.tripHistoryTitle,
          style: AppTypography.manrope(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            height: 36 / 28,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _StatBox(
                value: '${trips.length}',
                label: context.l10n.tripHistoryTrips,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatBox(
                value: _monthSpend,
                label: context.l10n.tripHistoryThisMonth,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.manrope(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              height: 28 / 20,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
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

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final TripHistoryFilter selected;
  final ValueChanged<TripHistoryFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: TripHistoryFilter.values.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final filter = TripHistoryFilter.values[index];
          final isSelected = filter == selected;
          return GestureDetector(
            onTap: () => onSelected(filter),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.secondaryContainer
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    Icon(
                      Icons.filter_list,
                      size: 18.sp,
                      color: AppColors.onSecondaryContainer,
                    ),
                    SizedBox(width: 4.w),
                  ],
                  Text(
                    TripHistoryScreen._filterLabel(context.l10n, filter),
                    style: AppTypography.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                      letterSpacing: 0.1,
                      color: isSelected
                          ? AppColors.onSecondaryContainer
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});

  final TripHistoryItem trip;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: trip.isCancelled ? 0.78 : 1,
      child: Material(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => AppNavigation.toTripDetails(context, tripId: trip.id),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TripImageBanner(trip: trip),
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.title,
                              style: AppTypography.manrope(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                height: 22 / 16,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14.sp,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    trip.location,
                                    style: AppTypography.inter(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w400,
                                      height: 18 / 13,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppCurrencyFormatter.instance.formatEurMinor(
                              trip.costMinor,
                            ),
                            style: AppTypography.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              height: 22 / 16,
                              color: trip.isCancelled
                                  ? AppColors.onSurfaceVariant
                                  : AppColors.secondary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          _StatusPill(status: trip.status),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    height: 1,
                    color: AppColors.surfaceVariant,
                  ),
                  SizedBox(height: 8.h),
                  _TripMetaRow(trip: trip),
                ],
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TripImageBanner extends StatelessWidget {
  const _TripImageBanner({required this.trip});

  final TripHistoryItem trip;

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      trip.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => ColoredBox(
        color: AppColors.surfaceContainer,
        child: Icon(Icons.image, size: 32.sp, color: AppColors.outline),
      ),
    );

    return SizedBox(
      height: 120.h,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: trip.isCancelled
                ? ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0, 0, 0, 1, 0,
                    ]),
                    child: image,
                  )
                : image,
          ),
          Positioned(
            top: 8.h,
            left: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 4.r,
                  ),
                ],
              ),
              child: Text(
                trip.date,
                style: AppTypography.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  height: 16 / 12,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final TripHistoryStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (bg, fg, label) = switch (status) {
      TripHistoryStatus.cancelada => (
          AppColors.errorContainer,
          AppColors.onErrorContainer,
          l10n.tripHistoryStatusCancelled,
        ),
      TripHistoryStatus.concluida => (
          const Color(0xFFD1FAE5),
          const Color(0xFF065F46),
          l10n.tripDetailsStatusCompleted,
        ),
      TripHistoryStatus.agendada => (
          AppColors.secondaryContainer,
          AppColors.onSecondaryContainer,
          l10n.tripHistoryStatusScheduled,
        ),
      TripHistoryStatus.emCurso => (
          AppColors.primaryContainer,
          AppColors.onPrimaryContainer,
          l10n.tripHistoryStatusInProgress,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: AppTypography.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          height: 14 / 11,
          color: fg,
        ),
      ),
    );
  }
}

class _TripMetaRow extends StatelessWidget {
  const _TripMetaRow({required this.trip});

  final TripHistoryItem trip;

  @override
  Widget build(BuildContext context) {
    final disabledColor = AppColors.outlineVariant;
    final iconColor = trip.isCancelled
        ? disabledColor
        : AppColors.onTertiaryContainer;
    final textColor = trip.isCancelled
        ? disabledColor
        : AppColors.onSurfaceVariant;

    final metaStyle = AppTypography.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      height: 16 / 12,
      letterSpacing: 0.1,
      color: textColor,
    );

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(Icons.directions_car, size: 16.sp, color: iconColor),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  trip.tier,
                  style: metaStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!trip.isCancelled && trip.duration.isNotEmpty) ...[
                SizedBox(width: 12.w),
                Icon(Icons.schedule, size: 16.sp, color: iconColor),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    trip.duration,
                    style: metaStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 8.w),
        if (trip.isCancelled)
          Text(
            context.l10n.tripHistoryNoDetails,
            style: AppTypography.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              height: 16 / 12,
              letterSpacing: 0.1,
              color: AppColors.outline,
            ),
          )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.details,
                style: AppTypography.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  height: 16 / 12,
                  letterSpacing: 0.1,
                  color: AppColors.secondary,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 16.sp,
                color: AppColors.secondary,
              ),
            ],
          ),
      ],
    );
  }
}

class _FloatingAddButton extends StatelessWidget {
  const _FloatingAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondary,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: AppColors.secondary.withValues(alpha: 0.4),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 56.w,
          height: 56.w,
          child: Icon(Icons.add, color: AppColors.onSecondary, size: 28.sp),
        ),
      ),
    );
  }
}
