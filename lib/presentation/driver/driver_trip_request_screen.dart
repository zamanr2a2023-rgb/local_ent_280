import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local_ent_280/core/services/client_functions_service.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
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
import 'package:local_ent_280/app/presentation/providers/repository_scope.dart';
import 'package:local_ent_280/features/trips/domain/repositories/trip_repository.dart';
import 'package:local_ent_280/presentation/driver/widgets/driver_trip_cancelled_dialog.dart';
import 'package:local_ent_280/presentation/widgets/driver_map_layer.dart';

/// Pedido de viagem recebido — aceitar ou recusar dentro de 12 segundos.
class DriverTripRequestScreen extends StatefulWidget {
  const DriverTripRequestScreen({
    super.key,
    required this.tripId,
    this.trip,
    this.driverRepository,
  });

  final String tripId;
  final TripRecord? trip;
  final DriverRepository? driverRepository;

  static const acceptCountdownSeconds = 12;

  @override
  State<DriverTripRequestScreen> createState() =>
      _DriverTripRequestScreenState();
}

class _DriverTripRequestScreenState extends State<DriverTripRequestScreen> {
  late final DriverRepository _driverRepository;
  late final TripRepository _tripRepository;
  final _directionsService = DirectionsService();
  final _locationService = CurrentLocationService();

  late int _secondsLeft;
  Timer? _countdownTimer;
  StreamSubscription<TripRecord?>? _tripSubscription;
  TripRecord? _trip;
  String _pickupDistance = DriverTripRequestData.pickupDistance;
  String _destinationInfo = DriverTripRequestData.destinationInfo;
  bool _isSubmitting = false;
  bool _handledClientCancellation = false;

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
    final driverId = _driverId;
    if (driverId != null) {
      DriverLocationTracker.instance.start(driverId);
    }
    _tripSubscription =
        _tripRepository.watchTrip(widget.tripId).listen((trip) {
      if (!mounted || trip == null) return;
      if (!_handledClientCancellation &&
          trip.status.toUpperCase() == 'CANCELLED_BY_CLIENT') {
        _handledClientCancellation = true;
        _countdownTimer?.cancel();
        unawaited(showDriverTripCancelledByClientDialog(context, trip: trip));
        return;
      }
      setState(() => _trip = trip);
    });
    _secondsLeft = DriverTripRequestScreen.acceptCountdownSeconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        _onExpired();
        return;
      }
      setState(() => _secondsLeft--);
    });
    _loadRouteDetails();
  }

  Future<void> _loadRouteDetails() async {
    final trip = _trip;
    if (trip == null) return;

    final location = await _locationService.getLastKnownLocation() ??
        await _locationService.getCurrentLocation();
    if (location != null) {
      final toPickup = await _directionsService.getDrivingRoute(
        origin: LatLng(location.latitude, location.longitude),
        destination: LatLng(trip.pickup.latitude, trip.pickup.longitude),
      );
      if (mounted) {
        setState(() {
          _pickupDistance = '${toPickup.distanceKm.toStringAsFixed(1)} km';
        });
      }
    }

    final route = await _directionsService.getDrivingRoute(
      origin: LatLng(trip.pickup.latitude, trip.pickup.longitude),
      destination: LatLng(trip.destination.latitude, trip.destination.longitude),
    );
    if (mounted) {
      setState(() {
        _destinationInfo =
            '${route.distanceKm.toStringAsFixed(1)} km • ${route.durationMinutes} min';
      });
    }
  }

  Future<void> _onExpired() async {
    final driverId = _driverId;
    if (driverId != null) {
      await _driverRepository.releaseTrip(driverId, widget.tripId);
    }
    if (!mounted) return;
    AppNavigation.toDriverRequestExpired(
      context,
      tripId: widget.tripId,
      driverRepository: _driverRepository,
    );
  }

  static const _navigableAfterAccept = {
    'DRIVER_ACCEPTED',
    'DRIVER_EN_ROUTE',
    'DRIVER_ARRIVED',
    'IN_TRIP',
    'ARRIVED_DESTINATION',
    'EXTENSION_WINDOW',
  };

  Future<TripRecord?> _loadTripForNavigation() async {
    for (var attempt = 0; attempt < 30; attempt++) {
      final doc = await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .get(const GetOptions(source: Source.server));
      if (doc.exists) {
        final trip = TripRecord.fromFirestore(doc);
        if (_navigableAfterAccept.contains(trip.status.toUpperCase())) {
          return trip;
        }
      }
      if (attempt < 29) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
    }
    return _tripRepository.getTrip(widget.tripId);
  }

  Future<void> _accept() async {
    if (_isSubmitting) return;
    final driverId = _driverId;
    final profile = UserSession.instance.profile;
    if (driverId == null || profile == null) return;

    _countdownTimer?.cancel();
    setState(() => _isSubmitting = true);
    try {
      await _driverRepository.acceptTrip(
        driverId: driverId,
        tripId: widget.tripId,
        profile: profile,
      );
      if (!mounted) return;

      final activeTrip = await _loadTripForNavigation();

      if (!mounted) return;
      if (activeTrip == null ||
          !_navigableAfterAccept.contains(activeTrip.status.toUpperCase())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.tryAgain)),
        );
        return;
      }
      AppNavigation.toDriverActiveTrip(
        context,
        tripId: widget.tripId,
        trip: activeTrip,
        driverRepository: _driverRepository,
      );
    } on ClientFunctionsException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.tryAgain)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _decline() async {
    if (_isSubmitting) return;
    final driverId = _driverId;
    _countdownTimer?.cancel();
    if (driverId != null) {
      await _driverRepository.declineTrip(driverId, widget.tripId);
    }
    if (!mounted) return;
    AppNavigation.toDriverHome(context);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _tripSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.35),
              BlendMode.darken,
            ),
            child: DriverMapLayer(
              pickup: trip?.pickup,
              destination: trip?.destination,
              showRoute: true,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const _RequestAppBar(),
                const Spacer(),
                _RequestCard(
                  trip: trip,
                  secondsLeft: _secondsLeft,
                  pickupDistance: _pickupDistance,
                  destinationInfo: _destinationInfo,
                  isSubmitting: _isSubmitting,
                  onAccept: _accept,
                  onDecline: _decline,
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestAppBar extends StatelessWidget {
  const _RequestAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
      child: Row(
        children: [
          IconButton(
            onPressed: () => AppNavigation.toDriverHome(context),
            icon: Icon(Icons.close, color: AppColors.onPrimary, size: 24.sp),
          ),
          Expanded(
            child: Text(
              context.l10n.appNameLocalTransport,
              textAlign: TextAlign.center,
              style: AppTypography.manrope(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.onPrimary,
              ),
            ),
          ),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.trip,
    required this.secondsLeft,
    required this.pickupDistance,
    required this.destinationInfo,
    required this.isSubmitting,
    required this.onAccept,
    required this.onDecline,
  });

  final TripRecord? trip;
  final int secondsLeft;
  final String pickupDistance;
  final String destinationInfo;
  final bool isSubmitting;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pickupAddress =
        trip?.pickup.address ?? DriverTripRequestData.pickupAddress;
    final destinationAddress =
        trip?.destination.address ?? DriverTripRequestData.destinationAddress;
    final passengerName =
        trip?.passengerName ?? DriverTripRequestData.passengerName;
    final passengerRating =
        trip?.passengerRatingLabel ?? '—';
    final fare = trip?.fareFormatted ??
        AppCurrencyFormatter.instance.formatEurMajor(
          DriverTripRequestData.fareEur,
        );
    final tripTitle = trip?.tripTypeLabel ?? l10n.driverPremiumTrip;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 24.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.accentSurface,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    l10n.driverNewRequest.toUpperCase(),
                    style: AppTypography.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const Spacer(),
                _CountdownBadge(secondsLeft: secondsLeft),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              tripTitle,
              style: AppTypography.manrope(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 20.h),
            _RouteRow(
              icon: Icons.trip_origin,
              iconColor: AppColors.accent,
              label: l10n.driverPickup.toUpperCase(),
              address: pickupAddress,
              detail: pickupDistance,
            ),
            SizedBox(height: 16.h),
            _RouteRow(
              icon: Icons.location_on,
              iconColor: AppColors.error,
              label: l10n.driverDestination.toUpperCase(),
              address: destinationAddress,
              detail: destinationInfo,
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  child: Icon(Icons.person, color: AppColors.accent),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        passengerName,
                        style: AppTypography.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
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
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  fare,
                  style: AppTypography.manrope(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSubmitting ? null : onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurfaceVariant,
                      side: BorderSide(color: AppColors.outlineVariant),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      l10n.driverDecline,
                      style: AppTypography.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: isSubmitting ? null : onAccept,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.onAccent,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: isSubmitting
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onAccent,
                            ),
                          )
                        : Text(
                            l10n.driverAcceptTrip,
                            style: AppTypography.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge({required this.secondsLeft});

  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    final progress =
        secondsLeft / DriverTripRequestScreen.acceptCountdownSeconds;

    return SizedBox(
      width: 48.w,
      height: 48.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3.w,
            backgroundColor: AppColors.surfaceContainer,
            color: AppColors.accent,
          ),
          Text(
            '${secondsLeft}s',
            style: AppTypography.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.address,
    required this.detail,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String address;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: iconColor),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: AppColors.labelMuted,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                address,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                detail,
                style: AppTypography.inter(
                  fontSize: 12.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
