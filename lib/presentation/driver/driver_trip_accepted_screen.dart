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

/// Confirmação após aceitar o pedido de viagem.
class DriverTripAcceptedScreen extends StatefulWidget {
  const DriverTripAcceptedScreen({
    super.key,
    required this.tripId,
    this.trip,
    this.driverRepository,
  });

  final String tripId;
  final TripRecord? trip;
  final DriverRepository? driverRepository;

  @override
  State<DriverTripAcceptedScreen> createState() =>
      _DriverTripAcceptedScreenState();
}

class _DriverTripAcceptedScreenState extends State<DriverTripAcceptedScreen> {
  late final DriverRepository _driverRepository;
  final _directionsService = DirectionsService();
  final _locationService = CurrentLocationService();

  String _eta = DriverTripAcceptedData.eta;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _driverRepository = widget.driverRepository ?? DriverRepository();
    final driverId = UserSession.instance.profile?.uid;
    if (driverId != null) {
      DriverLocationTracker.instance.start(driverId);
    }
    _loadEta();
  }

  Future<void> _loadEta() async {
    final trip = widget.trip;
    if (trip == null) return;

    final location = await _locationService.getLastKnownLocation() ??
        await _locationService.getCurrentLocation();
    if (location == null) return;

    final route = await _directionsService.getDrivingRoute(
      origin: LatLng(location.latitude, location.longitude),
      destination: LatLng(trip.pickup.latitude, trip.pickup.longitude),
    );
    if (mounted) {
      setState(() => _eta = '${route.durationMinutes} min');
    }
  }

  Future<void> _startNavigation() async {
    if (_isStarting) return;
    setState(() => _isStarting = true);
    try {
      await _driverRepository.startEnRoute(widget.tripId);
      if (!mounted) return;
      AppNavigation.toDriverActiveTrip(
        context,
        tripId: widget.tripId,
        trip: widget.trip,
        driverRepository: _driverRepository,
      );
    } catch (_) {
      if (mounted) {
        setState(() => _isStarting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.tryAgain)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DriverMapLayer(
            pickup: trip?.pickup,
            destination: trip?.destination,
            showRoute: true,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withValues(alpha: 0.3),
                  AppColors.background.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
                  child: _AcceptedCard(
                    trip: trip,
                    eta: _eta,
                    isStarting: _isStarting,
                    onStartNavigation: _startNavigation,
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AcceptedCard extends StatelessWidget {
  const _AcceptedCard({
    required this.trip,
    required this.eta,
    required this.isStarting,
    required this.onStartNavigation,
  });

  final TripRecord? trip;
  final String eta;
  final bool isStarting;
  final VoidCallback onStartNavigation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final passengerName =
        trip?.passengerName ?? DriverTripAcceptedData.passengerName;
    final pickupAddress =
        trip?.pickup.address ?? DriverTripAcceptedData.pickupAddress;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 24.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.h),
            color: AppColors.accent,
            child: Column(
              children: [
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: const BoxDecoration(
                    color: AppColors.onAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 32.sp, color: AppColors.accent),
                ),
                SizedBox(height: 12.h),
                Text(
                  l10n.driverTripAcceptedTitle,
                  style: AppTypography.manrope(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onAccent,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.driverTripAcceptedSubtitle,
                  style: AppTypography.inter(
                    fontSize: 14.sp,
                    color: AppColors.onAccent.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.person_outline,
                  label: l10n.driverPassenger,
                  value: passengerName,
                ),
                SizedBox(height: 12.h),
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: l10n.driverPickup,
                  value: pickupAddress,
                ),
                SizedBox(height: 12.h),
                _DetailRow(
                  icon: Icons.schedule,
                  label: l10n.driverEstimatedArrival,
                  value: eta,
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isStarting ? null : onStartNavigation,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: isStarting
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.navigation, size: 20.sp),
                    label: Text(
                      l10n.driverStartNavigation,
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
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.accent),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.inter(
                  fontSize: 12.sp,
                  color: AppColors.labelMuted,
                ),
              ),
              Text(
                value,
                style: AppTypography.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
