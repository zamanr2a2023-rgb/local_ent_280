import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_ent_280/core/data/driver_home_data.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/services/current_location_service.dart';
import 'package:local_ent_280/core/services/location_permission_helper.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/auth/data/user_session.dart';
import 'package:local_ent_280/features/driver/data/models/driver_dashboard_stats.dart';
import 'package:local_ent_280/features/driver/data/models/driver_vehicle.dart';
import 'package:local_ent_280/features/driver/data/driver_location_tracker.dart';
import 'package:local_ent_280/features/driver/data/driver_repository.dart';
import 'package:local_ent_280/presentation/driver/driver_drawer.dart';
import 'package:local_ent_280/presentation/widgets/app_bottom_nav.dart';
import 'package:local_ent_280/presentation/widgets/driver_map_layer.dart';
import 'package:local_ent_280/presentation/widgets/session_profile_avatar.dart';

/// Página Inicial — Motorista (dashboard com disponibilidade e ganhos).
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key, this.driverRepository});

  final DriverRepository? driverRepository;

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with WidgetsBindingObserver {
  late final DriverRepository _driverRepository;
  final _locationService = CurrentLocationService();

  StreamSubscription? _statusSubscription;
  StreamSubscription? _pendingSubscription;
  StreamSubscription? _activeSubscription;
  StreamSubscription? _statsSubscription;
  StreamSubscription? _vehicleSubscription;

  bool _isAvailable = false;
  bool _locationReady = false;
  bool _handlingTripNavigation = false;
  DriverDashboardStats _stats = DriverDashboardStats.empty;
  DriverVehicle? _vehicle;
  String _locationLabel = '';

  String? get _driverId => UserSession.instance.profile?.uid;
  bool get _vehicleReady => _vehicle != null && _vehicle!.isActive == true;
  bool get _readinessComplete => _vehicleReady && _locationReady;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _driverRepository = widget.driverRepository ?? DriverRepository();
    _loadLocationLabel();
    _refreshLocationReadiness();
    _bindFirebase();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshLocationReadiness();
      _loadLocationLabel();
    }
  }

  Future<void> _refreshLocationReadiness() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();
    final ready =
        serviceEnabled &&
        (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always);
    if (!mounted) return;
    setState(() => _locationReady = ready);
  }

  Future<void> _loadLocationLabel() async {
    final location =
        await _locationService.getLastKnownLocation() ??
        await _locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() {
      _locationLabel = location == null
          ? ''
          : _shortLocationLabel(
              location.address,
              location.latitude,
              location.longitude,
            );
    });
  }

  String _shortLocationLabel(String address, double lat, double lng) {
    final trimmed = address.trim();
    if (trimmed.isEmpty) {
      return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    }
    final parts = trimmed
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      return '${parts[parts.length - 2]}, ${parts.last}';
    }
    return parts.first;
  }

  void _bindFirebase() {
    final driverId = _driverId;
    if (driverId == null || _driverRepository.disabled) return;

    _statusSubscription = _driverRepository.watchDriverStatus(driverId).listen((
      status,
    ) {
      if (!mounted) return;
      final available = status?.isDispatchEligible ?? false;
      setState(() => _isAvailable = available);
      if (available) {
        DriverLocationTracker.instance.start(driverId);
      } else {
        DriverLocationTracker.instance.stop();
      }
    });

    _activeSubscription = _driverRepository
        .watchActiveDriverTrip(driverId)
        .listen((trip) {
          if (!mounted || trip == null || _handlingTripNavigation) return;
          _handlingTripNavigation = true;
          AppNavigation.toDriverActiveTrip(
            context,
            tripId: trip.id,
            trip: trip,
            driverRepository: _driverRepository,
          ).whenComplete(() {
            _handlingTripNavigation = false;
          });
        });

    _pendingSubscription = _driverRepository
        .watchPendingAcceptanceTrip(driverId)
        .listen((trip) {
          if (!mounted || trip == null || _handlingTripNavigation) return;
          _handlingTripNavigation = true;
          AppNavigation.toDriverTripRequest(
            context,
            tripId: trip.id,
            trip: trip,
            driverRepository: _driverRepository,
          ).whenComplete(() {
            _handlingTripNavigation = false;
          });
        });

    _statsSubscription = _driverRepository
        .watchDriverDashboardStats(driverId)
        .listen((stats) {
          if (!mounted) return;
          setState(() => _stats = stats);
        });

    _vehicleSubscription = _driverRepository
        .watchAssignedVehicle(driverId)
        .listen((vehicle) {
          if (!mounted) return;
          setState(() => _vehicle = vehicle);
        });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _statusSubscription?.cancel();
    _pendingSubscription?.cancel();
    _activeSubscription?.cancel();
    _statsSubscription?.cancel();
    _vehicleSubscription?.cancel();
    super.dispose();
  }

  Future<void> _showVehicleRequiredDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => const _DriverVehicleRequiredDialog(),
    );
  }

  Future<bool> _ensureLocationForAvailability() async {
    final l10n = context.l10n;
    final granted = await LocationPermissionHelper.ensureGranted(
      context,
      title: l10n.driverLocationPermissionTitle,
      message: l10n.driverLocationPermissionMessage,
      settingsMessage: l10n.driverLocationPermissionSettingsMessage,
      servicesDisabledMessage: l10n.homeLocationServicesDisabled,
    );
    await _refreshLocationReadiness();
    return granted;
  }

  Future<void> _setAvailability(bool value) async {
    final driverId = _driverId;
    if (driverId == null) return;

    if (!value) {
      setState(() => _isAvailable = false);
      try {
        await _driverRepository.setAvailability(driverId, false);
        await DriverLocationTracker.instance.stop();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.tryAgain)));
        }
      }
      return;
    }

    if (!_vehicleReady) {
      if (!mounted) return;
      await _showVehicleRequiredDialog();
      setState(() => _isAvailable = false);
      return;
    }

    if (!await _ensureLocationForAvailability()) {
      if (!mounted) return;
      setState(() => _isAvailable = false);
      return;
    }

    setState(() => _isAvailable = true);
    try {
      await _driverRepository.setAvailability(driverId, true);
      await DriverLocationTracker.instance.start(driverId);
      await _loadLocationLabel();
    } catch (error) {
      if (!mounted) return;
      final message =
          error is StateError &&
              error.toString().contains('no_vehicle_assigned')
          ? context.l10n.driverReadinessVehicleSnackMessage
          : context.l10n.tryAgain;
      setState(() => _isAvailable = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                  SizedBox(height: 8.h),
                  Text(
                    _isAvailable
                        ? l10n.driverAvailabilityActiveHint
                        : l10n.driverAvailabilityInactiveHint,
                    style: AppTypography.inter(
                      fontSize: 13.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  if (!_isAvailable || !_readinessComplete) ...[
                    SizedBox(height: 12.h),
                    _DriverReadinessCard(
                      vehicleReady: _vehicleReady,
                      locationReady: _locationReady,
                      allReady: _readinessComplete,
                      onEnableLocation: () async {
                        await _ensureLocationForAvailability();
                        if (!mounted) return;
                        await _loadLocationLabel();
                      },
                      onVehicleHelp: _showVehicleRequiredDialog,
                    ),
                  ],
                  SizedBox(height: 16.h),
                  _MapPreview(locationLabel: _locationLabel),
                  SizedBox(height: 20.h),
                  const _FleetStatusSection(),
                  SizedBox(height: 16.h),
                  _VehicleCard(vehicle: _vehicle),
                  SizedBox(height: 20.h),
                  _EarningsCard(stats: _stats),
                  SizedBox(height: 12.h),
                  _StatsRow(
                    tripsCount: _stats.todayTripCountFormatted,
                    distance: _stats.todayDistanceFormatted,
                  ),
                  SizedBox(height: 24.h),
                  _RecentTripsSection(trips: _stats.recentTrips),
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
              context.l10n.appNameLocalTransport,
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

class _DriverVehicleRequiredDialog extends StatelessWidget {
  const _DriverVehicleRequiredDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppColors.accentSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_outlined,
                color: AppColors.accent,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.driverReadinessVehicleDialogTitle,
              textAlign: TextAlign.center,
              style: AppTypography.manrope(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                height: 1.25,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.driverReadinessVehicleDialogMessage,
              textAlign: TextAlign.center,
              style: AppTypography.inter(
                fontSize: 15.sp,
                color: AppColors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.onAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  l10n.driverReadinessVehicleDialogGotIt,
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
    );
  }
}

class _DriverReadinessCard extends StatelessWidget {
  const _DriverReadinessCard({
    required this.vehicleReady,
    required this.locationReady,
    required this.allReady,
    required this.onEnableLocation,
    required this.onVehicleHelp,
  });

  final bool vehicleReady;
  final bool locationReady;
  final bool allReady;
  final VoidCallback onEnableLocation;
  final VoidCallback onVehicleHelp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: allReady
            ? AppColors.accentSurface
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: allReady
              ? AppColors.accent.withValues(alpha: 0.35)
              : AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            allReady ? l10n.driverReadinessAllReady : l10n.driverReadinessTitle,
            style: AppTypography.manrope(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          if (!allReady) ...[
            SizedBox(height: 12.h),
            _ReadinessRow(
              isReady: vehicleReady,
              title: l10n.driverReadinessVehicleTitle,
              readyText: l10n.driverReadinessVehicleReady,
              missingText: l10n.driverReadinessVehicleMissing,
              actionLabel: l10n.driverReadinessVehicleHelpAction,
              onAction: vehicleReady ? null : onVehicleHelp,
            ),
            SizedBox(height: 10.h),
            _ReadinessRow(
              isReady: locationReady,
              title: l10n.driverReadinessLocationTitle,
              readyText: l10n.driverReadinessLocationReady,
              missingText: l10n.driverReadinessLocationMissing,
              actionLabel: l10n.driverReadinessLocationAction,
              onAction: locationReady ? null : onEnableLocation,
            ),
          ],
        ],
      ),
    );
  }
}

class _ReadinessRow extends StatelessWidget {
  const _ReadinessRow({
    required this.isReady,
    required this.title,
    required this.readyText,
    required this.missingText,
    required this.actionLabel,
    this.onAction,
  });

  final bool isReady;
  final String title;
  final String readyText;
  final String missingText;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isReady ? Icons.check_circle : Icons.error_outline,
          size: 20.sp,
          color: isReady ? AppColors.accent : AppColors.error,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                isReady ? readyText : missingText,
                style: AppTypography.inter(
                  fontSize: 12.sp,
                  color: AppColors.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              if (!isReady && onAction != null) ...[
                SizedBox(height: 6.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(actionLabel),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.locationLabel});

  final String locationLabel;

  @override
  Widget build(BuildContext context) {
    final label = locationLabel.trim().isNotEmpty
        ? locationLabel
        : context.l10n.driverLocationLoading;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        height: 140.h,
        width: double.infinity,
        child: DriverMapLayer(
          initialZoom: 12,
          overlay: Positioned(
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
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
  const _VehicleCard({required this.vehicle});

  final DriverVehicle? vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final model = vehicle?.model.trim().isNotEmpty == true
        ? vehicle!.model.trim()
        : l10n.driverNoVehicleAssigned;
    final plate = vehicle?.plate.trim().isNotEmpty == true
        ? vehicle!.plate.trim()
        : '—';
    final statusLabel = vehicle?.isActive == true
        ? l10n.driverInOperation
        : l10n.driverUnavailable;
    final battery = vehicle?.batteryLabel ?? '—';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.surfaceVariant.withValues(alpha: 0.4),
        ),
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
            child: Icon(
              Icons.directions_car,
              color: AppColors.accent,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model,
                  style: AppTypography.manrope(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '$plate • $statusLabel',
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
              Icon(
                Icons.battery_charging_full,
                color: AppColors.accent,
                size: 20.sp,
              ),
              Text(
                battery,
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
  const _EarningsCard({required this.stats});

  final DriverDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trendIcon = stats.earningsTrendingUp
        ? Icons.trending_up
        : Icons.trending_down;
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
            stats.todayEarningsFormatted,
            style: AppTypography.manrope(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.onPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(trendIcon, size: 14.sp, color: AppColors.primaryFixed),
              SizedBox(width: 4.w),
              Text(
                l10n.driverEarningsVsYesterday(stats.earningsChangePercent),
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
  const _StatsRow({required this.tripsCount, required this.distance});

  final String tripsCount;
  final String distance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: tripsCount,
            label: l10n.driverTripsLabel,
            icon: Icons.directions_car_outlined,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _StatCard(
            value: distance,
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
        border: Border.all(
          color: AppColors.surfaceVariant.withValues(alpha: 0.4),
        ),
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
  const _RecentTripsSection({required this.trips});

  final List<DriverRecentTrip> trips;

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
        if (trips.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.surfaceVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              context.l10n.driverNoRecentTrips,
              style: AppTypography.inter(
                fontSize: 13.sp,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final trip in trips) ...[
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
        border: Border.all(
          color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        ),
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
