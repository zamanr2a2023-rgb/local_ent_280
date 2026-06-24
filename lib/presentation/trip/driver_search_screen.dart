import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/features/trips/data/active_trip_session.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';
import 'package:local_ent_280/features/trips/data/repositories/trip_repository_impl.dart';
import 'package:local_ent_280/app/presentation/providers/repository_scope.dart';
import 'package:local_ent_280/features/trips/domain/repositories/trip_repository.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/l10n/app_localizations.dart';
import 'package:local_ent_280/presentation/widgets/driver_map_layer.dart';

/// A procurar motorista disponível — `roles/details.md`.
class DriverSearchScreen extends StatefulWidget {
  const DriverSearchScreen({
    super.key,
    this.tripId,
    this.tripRepository,
    this.showNoDriversMessage = true,
  });

  final String? tripId;
  final TripRepository? tripRepository;
  final bool showNoDriversMessage;

  @override
  State<DriverSearchScreen> createState() => _DriverSearchScreenState();
}

class _DriverSearchScreenState extends State<DriverSearchScreen> {
  TripRepository? _tripRepository;
  StreamSubscription<TripRecord?>? _tripSubscription;
  TripRecord? _trip;
  bool _isCancelling = false;
  bool _hasNavigatedForward = false;
  bool _searchFailed = false;
  String? _failureMessage;

  String get _tripId =>
      widget.tripId ?? ActiveTripSession.instance.tripId ?? '';

  bool _tripListenerStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tripListenerStarted) return;
    _tripListenerStarted = true;
    _listenToTrip();
  }

  void _listenToTrip() {
    final tripId = _tripId;
    if (tripId.isEmpty) return;

    _tripRepository = widget.tripRepository ?? tripRepositoryOf(context);
    _tripSubscription = _tripRepository!.watchTrip(tripId).listen((trip) {
      if (!mounted || trip == null) return;
      setState(() => _trip = trip);
      ActiveTripSession.instance.updateTrip(trip);

      final status = trip.status.toUpperCase();
      if (!_hasNavigatedForward &&
          (trip.hasAssignedDriver || trip.isDriverAssignedStatus)) {
        _hasNavigatedForward = true;
        AppNavigation.toDriverFound(
          context,
          tripId: trip.id,
          trip: trip,
          tripRepository: _tripRepository,
        );
        return;
      }
      if (status == 'NO_DRIVERS_AVAILABLE' && !_hasNavigatedForward) {
        _hasNavigatedForward = true;
        final message = _noDriversMessage(trip, context.l10n);
        setState(() {
          _searchFailed = true;
          _failureMessage = message;
        });
        return;
      }
    });
  }

  String _noDriversMessage(TripRecord trip, AppLocalizations l10n) {
    final reason = trip.unfulfilledReason ?? '';
    if (reason.contains('no_locations_within') ||
        reason.contains('no_available_drivers_near_pickup')) {
      return l10n.driverSearchNoDriversNearby;
    }
    if (reason.contains('no_vehicle_assignment')) {
      return l10n.driverSearchNoDriversMissingVehicle;
    }
    return l10n.driverSearchNoDrivers;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _cancelTrip() async {
    final tripId = _tripId;
    if (tripId.isEmpty || _isCancelling) {
      AppNavigation.cancelToTripDestination(context);
      return;
    }

    setState(() => _isCancelling = true);
    try {
      final repository = _tripRepository ?? TripRepositoryImpl(disabled: true);
      await repository.cancelTripByClient(tripId);
      ActiveTripSession.instance.clear();
      if (!mounted) return;
      AppNavigation.cancelToTripDestination(context);
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.driverSearchCancelFailed);
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  void dispose() {
    _tripSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainer,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DriverMapLayer(
            pickup: _trip?.pickup,
            destination: _trip?.destination,
            showRoute: _trip != null,
            myLocationEnabled: false,
            trackMyLocation: false,
            includeMyLocationInCameraFit: false,
            initialZoom: 14,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topInset + 120.h,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: topInset + 8.h,
            left: 0,
            right: 0,
            child: _FloatingHeader(
              onBack: () => AppNavigation.cancelToTripDestination(context),
            ),
          ),
          if (!_searchFailed)
            Positioned(
              top: topInset + 64.h,
              left: 0,
              right: 0,
              child: const _StatusToast(),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _SearchBottomSheet(
              trip: _trip,
              isCancelling: _isCancelling,
              searchFailed: _searchFailed,
              failureMessage: _failureMessage,
              onCancel: _cancelTrip,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingHeader extends StatelessWidget {
  const _FloatingHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
      child: Row(
        children: [
          Material(
            color: AppColors.surfaceContainerLowest,
            shape: const CircleBorder(),
            elevation: 4,
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Icon(Icons.arrow_back, color: AppColors.primary, size: 22.sp),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Text(
                  context.l10n.appNameLocalTransport,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }
}

class _StatusToast extends StatefulWidget {
  const _StatusToast();

  @override
  State<_StatusToast> createState() => _StatusToastState();
}

class _StatusToastState extends State<_StatusToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pingController;

  @override
  void initState() {
    super.initState();
    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _pingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
            SizedBox(
              width: 8.w,
              height: 8.h,
              child: AnimatedBuilder(
                animation: _pingController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 8.w + _pingController.value * 6,
                        height: 8.h + _pingController.value * 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.secondary.withValues(
                            alpha: 0.4 * (1 - _pingController.value),
                          ),
                        ),
                      ),
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(width: 8.w),
                Text(
                  context.l10n.driverSearchOptimizing,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onPrimary,
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

class _SearchBottomSheet extends StatelessWidget {
  const _SearchBottomSheet({
    required this.trip,
    required this.isCancelling,
    required this.searchFailed,
    required this.failureMessage,
    required this.onCancel,
  });

  final TripRecord? trip;
  final bool isCancelling;
  final bool searchFailed;
  final String? failureMessage;
  final VoidCallback onCancel;

  static double get _radius => 24.r;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h + bottomInset),
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 32.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 6.h,
            margin: EdgeInsets.only(bottom: 24.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
          Text(
            searchFailed
                ? context.l10n.driverSearchNoDrivers
                : context.l10n.driverSearchTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              height: 32 / 24,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            searchFailed
                ? (failureMessage ?? context.l10n.driverSearchNoDrivers)
                : _searchSubtitle(context, trip),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              height: 24 / 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 24.h),
          if (!searchFailed) const _ProgressSegments(),
          if (!searchFailed) SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  label: context.l10n.driverSearchOrigin,
                  value: _originLabel(trip),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _InfoBox(
                  label: context.l10n.driverSearchEstimate,
                  value: _estimateLabel(context, trip),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 56.h,
            width: double.infinity,
            child: TextButton.icon(
              onPressed: isCancelling ? null : onCancel,
              icon: Icon(Icons.close, size: 20.sp, color: AppColors.primary),
              label: Text(
                isCancelling
                    ? context.l10n.driverSearchCancelling
                    : context.l10n.driverSearchCancelTrip,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: AppColors.primary,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerHigh,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _originLabel(TripRecord? trip) {
    final address = trip?.pickup.address.trim() ?? '';
    if (address.isEmpty) return '—';
    final parts = address.split(',').map((part) => part.trim()).where(
          (part) => part.isNotEmpty,
        );
    if (parts.isEmpty) return address;
    if (parts.length >= 2) {
      return '${parts.first}, ${parts.elementAt(1)}';
    }
    return parts.first;
  }

  static String _searchSubtitle(BuildContext context, TripRecord? trip) {
    final address = trip?.pickup.address.trim() ?? '';
    if (address.isEmpty) {
      return context.l10n.driverSearchSubtitleFallback;
    }
    final parts = address.split(',').map((part) => part.trim()).where(
          (part) => part.isNotEmpty,
        );
    final area = parts.length >= 2 ? parts.elementAt(1) : parts.first;
    return context.l10n.driverSearchSubtitleArea(area);
  }

  static String _estimateLabel(BuildContext context, TripRecord? trip) {
    final waitMinutes = trip?.meteringSnapshot.totalWaitMinutes;
    if (waitMinutes != null && waitMinutes > 0 && waitMinutes <= 60) {
      return context.l10n.driverSearchWaitMinutes(waitMinutes);
    }
    return context.l10n.driverSearchWaitEstimate;
  }
}

class _ProgressSegments extends StatefulWidget {
  const _ProgressSegments();

  @override
  State<_ProgressSegments> createState() => _ProgressSegmentsState();
}

class _ProgressSegmentsState extends State<_ProgressSegments>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          children: [
            Expanded(
              child: _SegmentBar(
                color: AppColors.secondary,
                opacity: 0.85 + _controller.value * 0.15,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _SegmentBar(
                color: AppColors.secondary,
                opacity: 0.35 + _controller.value * 0.1,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _SegmentBar(
                color: AppColors.secondary,
                opacity: 0.12 + _controller.value * 0.08,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SegmentBar extends StatelessWidget {
  const _SegmentBar({required this.color, required this.opacity});

  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity.clamp(0.0, 1.0)),
        borderRadius: BorderRadius.circular(999.r),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
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
