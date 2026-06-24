import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/core/data/trip_in_progress_data.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/presentation/widgets/app_bottom_nav.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/features/driver/data/driver_location_repository.dart';
import 'package:local_ent_280/features/trips/data/active_trip_session.dart';
import 'package:local_ent_280/features/trips/data/client_trip_flow.dart';
import 'package:local_ent_280/features/trips/data/client_trip_watcher.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';
import 'package:local_ent_280/features/trips/data/trip_repository.dart';
import 'package:local_ent_280/presentation/widgets/driver_map_layer.dart';

/// Viagem em curso — `roles/details.md`.
class TripInProgressScreen extends StatefulWidget {
  const TripInProgressScreen({
    super.key,
    this.tripId,
    this.trip,
    this.tripRepository,
  });

  final String? tripId;
  final TripRecord? trip;
  final TripRepository? tripRepository;

  @override
  State<TripInProgressScreen> createState() => _TripInProgressScreenState();
}

class _TripInProgressScreenState extends State<TripInProgressScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _carPulseController;
  late final ClientTripWatcher _tripWatcher;
  final _driverLocationRepository = DriverLocationRepository();
  StreamSubscription<DriverLocationSnapshot?>? _driverLocationSubscription;
  TripRecord? _trip;
  DriverLocationSnapshot? _driverLocation;

  String get _tripId =>
      widget.tripId ?? ActiveTripSession.instance.tripId ?? '';

  @override
  void initState() {
    super.initState();
    _trip = widget.trip ?? ActiveTripSession.instance.trip;
    _carPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _tripWatcher = ClientTripWatcher(
      screen: ClientTripScreen.tripInProgress,
      repository: widget.tripRepository,
      onTripChanged: (trip) {
        setState(() => _trip = trip);
        _watchDriverLocation(trip.assignedDriverId);
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripId = _tripId;
      if (tripId.isNotEmpty && mounted) {
        _tripWatcher.start(tripId: tripId, context: context);
      }
      _watchDriverLocation(_trip?.assignedDriverId);
    });
  }

  void _watchDriverLocation(String? driverId) {
    if (driverId == null || driverId.isEmpty) return;
    _driverLocationSubscription?.cancel();
    _driverLocationSubscription =
        _driverLocationRepository.watchLocation(driverId).listen((location) {
      if (!mounted || location == null) return;
      setState(() => _driverLocation = location);
    });
  }

  @override
  void dispose() {
    _tripWatcher.dispose();
    _driverLocationSubscription?.cancel();
    _carPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;
    final driverMarker = _driverLocation == null
        ? const <({double latitude, double longitude, bool isDriver})>[]
        : [
            (
              latitude: _driverLocation!.latitude,
              longitude: _driverLocation!.longitude,
              isDriver: true,
            ),
          ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _TripAppBar(onMenu: () {}),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (trip?.pickup != null && trip?.destination != null)
                  DriverMapLayer(
                    pickup: trip!.pickup,
                    destination: trip.destination,
                    showRoute: true,
                    myLocationEnabled: true,
                    extraMarkers: driverMarker,
                    fitToExtraMarkers: driverMarker.isNotEmpty,
                  )
                else
                  const _MapLayer(),
                if (trip == null || _driverLocation == null)
                  Center(child: _VehicleMarker(pulse: _carPulseController)),
                Positioned(
                  top: 16.h,
                  right: AppLayout.marginMobile,
                  child: Column(
                    children: [
                      _MapFabButton(icon: Icons.my_location, onTap: () {}),
                      SizedBox(height: 8.h),
                      _MapFabButton(icon: Icons.layers, onTap: () {}),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _InTripBottomSheet(
                    trip: trip,
                    onSupport: () {},
                  ),
                ),
              ],
            ),
          ),
          AppBottomNav(
            selectedIndex: AppNavIndex.viagens,
            onItemTap: (index) => AppNavigation.onBottomNavTap(context, index),
          ),
        ],
      ),
    );
  }
}

class _TripAppBar extends StatelessWidget {
  const _TripAppBar({required this.onMenu});

  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 56.h,
        color: AppColors.background,
        padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
        child: Row(
          children: [
            IconButton(
              onPressed: onMenu,
              icon: Icon(Icons.menu, color: AppColors.primary, size: 24.sp),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                context.l10n.appNameLocalTransport,
                style: GoogleFonts.manrope(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  height: 32 / 24,
                  color: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryFixedDim, width: 2.w),
              ),
              child: ClipOval(
                child: Image.network(
                  TripInProgressData.profileAvatarImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    size: 20.sp,
                    color: AppColors.primary,
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

class _MapLayer extends StatelessWidget {
  const _MapLayer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          TripInProgressData.mapImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => ColoredBox(
            color: AppColors.surfaceContainerHigh,
            child: Icon(Icons.map, size: 64.sp, color: AppColors.outline),
          ),
        ),
        ColoredBox(
          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.05),
        ),
      ],
    );
  }
}

class _VehicleMarker extends StatelessWidget {
  const _VehicleMarker({required this.pulse});

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.92 + pulse.value * 0.08,
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.35),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Icon(
          Icons.directions_car,
          color: AppColors.onSecondary,
          size: 28.sp,
        ),
      ),
    );
  }
}

class _MapFabButton extends StatelessWidget {
  const _MapFabButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(8.r),
      elevation: 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(
          width: 48.w,
          height: 48.h,
          child: Icon(icon, color: AppColors.primary, size: 24.sp),
        ),
      ),
    );
  }
}

class _InTripBottomSheet extends StatelessWidget {
  const _InTripBottomSheet({
    required this.trip,
    required this.onSupport,
  });

  final TripRecord? trip;
  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) {
    final arrivalTime = trip == null
        ? TripInProgressData.arrivalTime
        : '${trip!.meteringSnapshot.totalMinutes} min';
    final destinationAddress =
        trip?.destination.address ?? TripInProgressData.destinationAddress;
    final estimatedCost = trip?.fareFormatted ??
        AppCurrencyFormatter.instance.formatEurMajor(
          TripInProgressData.estimatedCostEur,
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(
          top: BorderSide(color: AppColors.surfaceVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 32.r,
            offset: Offset(0, -8.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppLayout.marginMobile,
          8.h,
          AppLayout.marginMobile,
          16.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.tripInProgressStatusLabel.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          height: 16 / 12,
                          letterSpacing: 0.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Container(
                            width: 10.w,
                            height: 10.h,
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              context.l10n.tripInProgressStatusValue,
                              style: GoogleFonts.manrope(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                height: 28 / 20,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          context.l10n.tripInProgressArrivalLabel,
                          textAlign: TextAlign.end,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            height: 16 / 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          arrivalTime,
                          style: GoogleFonts.manrope(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            height: 28 / 20,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _InfoCard(
              icon: Icons.location_on,
              iconBackground: AppColors.secondaryContainer,
              iconColor: AppColors.onSecondaryContainer,
              label: context.l10n.destination,
              value: destinationAddress,
            ),
            SizedBox(height: 12.h),
            _InfoCard(
              icon: Icons.payments,
              iconBackground: AppColors.tertiaryContainer,
              iconColor: AppColors.onTertiaryContainer,
              label: context.l10n.tripInProgressCostLabel,
              value: estimatedCost,
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: OutlinedButton(
                onPressed: onSupport,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  side: BorderSide(color: AppColors.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.help_center, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      context.l10n.support,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                        letterSpacing: 0.1,
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 24.sp, color: iconColor),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    height: 16 / 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    height: 24 / 16,
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
