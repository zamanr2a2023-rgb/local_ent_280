import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local_ent_280/core/data/driver_home_data.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/services/current_location_service.dart';
import 'package:local_ent_280/core/services/directions_service.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/auth/data/user_session.dart';
import 'package:local_ent_280/features/driver/data/driver_location_tracker.dart';
import 'package:local_ent_280/features/driver/data/driver_repository.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';
import 'package:local_ent_280/presentation/widgets/driver_map_layer.dart';
import 'package:local_ent_280/app/presentation/providers/repository_scope.dart';
import 'package:local_ent_280/features/trips/domain/repositories/trip_repository.dart';

enum _DriverTripPhase { onWay, arrived, inProgress }

/// Viagem ativa — motorista a caminho do passageiro ou em curso.
class DriverActiveTripScreen extends StatefulWidget {
  const DriverActiveTripScreen({
    super.key,
    required this.tripId,
    this.trip,
    this.driverRepository,
  });

  final String tripId;
  final TripRecord? trip;
  final DriverRepository? driverRepository;

  @override
  State<DriverActiveTripScreen> createState() => _DriverActiveTripScreenState();
}

class _DriverActiveTripScreenState extends State<DriverActiveTripScreen> {
  late final DriverRepository _driverRepository;
  late final TripRepository _tripRepository;
  final _directionsService = DirectionsService();
  final _locationService = CurrentLocationService();
  StreamSubscription<TripRecord?>? _tripSubscription;
  Timer? _routeRefreshTimer;

  TripRecord? _trip;
  _DriverTripPhase _phase = _DriverTripPhase.onWay;
  bool _isUpdating = false;
  String _navigationDistance = '—';
  String _estimatedTime = '—';
  String _distanceStat = '—';
  String _passengerRating = '—';
  bool _isVipPassenger = false;

  String? get _driverId => UserSession.instance.profile?.uid;

  bool _repositoriesReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_repositoriesReady) return;
    _repositoriesReady = true;
    _driverRepository = widget.driverRepository ?? DriverRepository();
    _tripRepository = tripRepositoryOf(context);
    _trip = widget.trip;
    _syncPhaseFromTrip(_trip);
    _syncPassengerMeta(_trip);
    final driverId = _driverId;
    if (driverId != null) {
      DriverLocationTracker.instance.start(driverId);
    }
    _refreshRouteMetrics();
    _routeRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshRouteMetrics(),
    );
    _tripSubscription = _tripRepository.watchTrip(widget.tripId).listen((trip) {
      if (!mounted) return;
      if (trip == null) return;
      final previousPhase = _phase;
      setState(() {
        _trip = trip;
        _syncPhaseFromTrip(trip);
        _syncPassengerMeta(trip);
      });
      if (previousPhase != _phase) {
        _refreshRouteMetrics();
      }
    });
  }

  void _syncPassengerMeta(TripRecord? trip) {
    _passengerRating = trip?.passengerRatingLabel ?? '—';
    _isVipPassenger = trip?.isVipPassenger ?? false;
  }

  Future<void> _refreshRouteMetrics() async {
    final trip = _trip;
    if (trip == null) return;

    final location =
        await _locationService.getLastKnownLocation() ??
        await _locationService.getCurrentLocation();
    if (location == null || !mounted) return;

    final target = _phase == _DriverTripPhase.inProgress
        ? trip.destination
        : trip.pickup;

    final route = await _directionsService.getDrivingRoute(
      origin: LatLng(location.latitude, location.longitude),
      destination: LatLng(target.latitude, target.longitude),
    );
    if (!mounted) return;

    final km = route.distanceKm;
    final navigationDistance = km < 1
        ? '${(km * 1000).round()}m'
        : '${km.toStringAsFixed(1)} km';

    setState(() {
      _navigationDistance = navigationDistance;
      _estimatedTime = '${route.durationMinutes} min';
      _distanceStat = navigationDistance;
    });

    final driverId = _driverId;
    if (driverId != null) {
      await _driverRepository.recordPathPoint(
        tripId: widget.tripId,
        latitude: location.latitude,
        longitude: location.longitude,
      );
      await _driverRepository.updateTripMetering(
        tripId: widget.tripId,
        totalDistanceKm: route.distanceKm,
        totalMinutes: route.durationMinutes,
        estimatedCostMinor: trip.meteringSnapshot.estimatedCostMinor,
      );
    }
  }

  void _syncPhaseFromTrip(TripRecord? trip) {
    if (trip == null) return;
    switch (trip.status) {
      case 'DRIVER_ARRIVED':
        _phase = _DriverTripPhase.arrived;
      case 'IN_TRIP':
      case 'ARRIVED_DESTINATION':
      case 'EXTENSION_WINDOW':
        _phase = _DriverTripPhase.inProgress;
      default:
        _phase = _DriverTripPhase.onWay;
    }
  }

  String _primaryLabel(BuildContext context) => switch (_phase) {
    _DriverTripPhase.onWay => context.l10n.driverOnTheWay,
    _DriverTripPhase.arrived => context.l10n.driverArrivedStatus,
    _DriverTripPhase.inProgress => context.l10n.driverTripInProgressStatus,
  };

  Future<void> _onArrived() async {
    if (_isUpdating) return;
    final driverId = _driverId;
    if (driverId == null) return;
    setState(() => _isUpdating = true);
    try {
      await _driverRepository.markArrived(widget.tripId, driverId: driverId);
      if (mounted) setState(() => _phase = _DriverTripPhase.arrived);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.tryAgain)));
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _onStartTrip() async {
    if (_isUpdating) return;
    final driverId = _driverId;
    if (driverId == null) return;
    setState(() => _isUpdating = true);
    try {
      await _driverRepository.startTrip(widget.tripId, driverId: driverId);
      if (mounted) setState(() => _phase = _DriverTripPhase.inProgress);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.tryAgain)));
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _onFinishTrip() async {
    if (_isUpdating) return;
    final driverId = _driverId;
    if (driverId == null) return;
    setState(() => _isUpdating = true);
    try {
      await _driverRepository.completeTrip(
        driverId: driverId,
        tripId: widget.tripId,
      );
      if (!mounted) return;
      AppNavigation.toDriverHome(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.tryAgain)));
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  void dispose() {
    _routeRefreshTimer?.cancel();
    _tripSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;
    final destinationAddress =
        trip?.destination.address ?? DriverActiveTripData.destinationAddress;
    final passengerName =
        trip?.passengerName ?? DriverActiveTripData.passengerName;
    final estimatedTime = _estimatedTime;
    final distance = _distanceStat;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                DriverMapLayer(
                  pickup: trip?.pickup,
                  destination: trip?.destination,
                  showRoute: true,
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
                    child: _NavigationBanner(
                      destinationAddress: destinationAddress,
                      navigationDistance: _navigationDistance,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _ActiveTripSheet(
                    passengerName: passengerName,
                    passengerRating: _passengerRating,
                    isVipPassenger: _isVipPassenger,
                    estimatedTime: estimatedTime,
                    distance: distance,
                    phase: _phase,
                    primaryLabel: _primaryLabel(context),
                    isUpdating: _isUpdating,
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
  const _NavigationBanner({
    required this.destinationAddress,
    required this.navigationDistance,
  });

  final String destinationAddress;
  final String navigationDistance;

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
                  context.l10n.driverDistanceToDestination(navigationDistance),
                  style: AppTypography.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
                Text(
                  destinationAddress,
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
    required this.passengerName,
    required this.passengerRating,
    required this.isVipPassenger,
    required this.estimatedTime,
    required this.distance,
    required this.phase,
    required this.primaryLabel,
    required this.isUpdating,
    required this.onArrived,
    required this.onStartTrip,
    required this.onFinishTrip,
  });

  final String passengerName;
  final String passengerRating;
  final bool isVipPassenger;
  final String estimatedTime;
  final String distance;
  final _DriverTripPhase phase;
  final String primaryLabel;
  final bool isUpdating;
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
                            passengerName,
                            style: AppTypography.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        if (isVipPassenger)
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
                          passengerRating,
                          style: AppTypography.inter(
                            fontSize: 13.sp,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        if (isVipPassenger)
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
                  value: estimatedTime,
                ),
              ),
              Expanded(
                child: _TripStat(
                  label: l10n.driverDistanceStatLabel,
                  value: distance,
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
                  onTap: phase == _DriverTripPhase.onWay && !isUpdating
                      ? onArrived
                      : null,
                  isEnabled: phase == _DriverTripPhase.onWay && !isUpdating,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _WorkflowButton(
                  label: l10n.driverStartTripButton,
                  onTap: phase == _DriverTripPhase.arrived && !isUpdating
                      ? onStartTrip
                      : null,
                  isEnabled: phase == _DriverTripPhase.arrived && !isUpdating,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _WorkflowButton(
                  label: l10n.driverFinishTripButton,
                  onTap: phase == _DriverTripPhase.inProgress && !isUpdating
                      ? onFinishTrip
                      : null,
                  isEnabled:
                      phase == _DriverTripPhase.inProgress && !isUpdating,
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
