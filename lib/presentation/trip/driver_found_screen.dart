import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/core/data/driver_found_data.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/features/trips/data/active_trip_session.dart';
import 'package:local_ent_280/features/trips/data/client_trip_flow.dart';
import 'package:local_ent_280/features/trips/data/client_trip_watcher.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';
import 'package:local_ent_280/features/trips/data/trip_repository.dart';
import 'package:local_ent_280/presentation/widgets/driver_map_layer.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';

/// Motorista encontrado — a aguardar confirmação (`roles/details.md`).
class DriverFoundScreen extends StatefulWidget {
  const DriverFoundScreen({
    super.key,
    this.tripId,
    this.trip,
    this.tripRepository,
  });

  final String? tripId;
  final TripRecord? trip;
  final TripRepository? tripRepository;

  @override
  State<DriverFoundScreen> createState() => _DriverFoundScreenState();
}

class _DriverFoundScreenState extends State<DriverFoundScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hourglassController;
  late final ClientTripWatcher _tripWatcher;
  TripRecord? _trip;

  String get _tripId =>
      widget.tripId ?? ActiveTripSession.instance.tripId ?? '';

  @override
  void initState() {
    super.initState();
    _trip = widget.trip ?? ActiveTripSession.instance.trip;
    _hourglassController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _tripWatcher = ClientTripWatcher(
      screen: ClientTripScreen.driverFound,
      repository: widget.tripRepository,
      onTripChanged: (trip) => setState(() => _trip = trip),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripId = _tripId;
      if (tripId.isNotEmpty && mounted) {
        _tripWatcher.start(tripId: tripId, context: context);
      }
    });
  }

  @override
  void dispose() {
    _tripWatcher.dispose();
    _hourglassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _DriverFoundAppBar(onMenu: () {}),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (trip?.pickup != null && trip?.destination != null)
                  DriverMapLayer(
                    pickup: trip!.pickup,
                    destination: trip.destination,
                    showRoute: true,
                    myLocationEnabled: false,
                  )
                else
                  const _MapBackground(),
                Positioned(
                  top: 24.h,
                  left: AppLayout.marginMobile,
                  right: AppLayout.marginMobile,
                  child: _WaitingStatusCard(
                    spinController: _hourglassController,
                  ),
                ),
                Positioned(
                  top: 96.h,
                  right: AppLayout.marginMobile,
                  child: Column(
                    children: [
                      _MapFabButton(icon: Icons.my_location, onTap: () {}),
                      SizedBox(height: 16.h),
                      _MapFabButton(icon: Icons.layers, onTap: () {}),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _DriverAssignmentSheet(
                    trip: trip,
                    onCancel: () => AppNavigation.back(context),
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

class _DriverFoundAppBar extends StatelessWidget {
  const _DriverFoundAppBar({required this.onMenu});

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
                border: Border.all(color: AppColors.primaryContainer, width: 2.w),
              ),
              child: ClipOval(
                child: Image.network(
                  DriverFoundData.profileAvatarImage,
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

class _MapBackground extends StatelessWidget {
  const _MapBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.6,
          child: Image.network(
            DriverFoundData.mapImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => ColoredBox(
              color: AppColors.surfaceContainer,
              child: Icon(Icons.map, size: 64.sp, color: AppColors.outline),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0.9),
                AppColors.background.withValues(alpha: 0),
                AppColors.background.withValues(alpha: 0),
                AppColors.background,
              ],
              stops: const [0.0, 0.2, 0.7, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _WaitingStatusCard extends StatelessWidget {
  const _WaitingStatusCard({required this.spinController});

  final AnimationController spinController;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            SizedBox(
              width: 32.w,
              height: 32.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  RotationTransition(
                    turns: spinController,
                    child: Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          width: 2.w,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 2.w,
                          height: 8.h,
                          margin: EdgeInsets.only(top: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(1.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.hourglass_empty,
                    size: 16.sp,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.driverFoundTitle,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                      letterSpacing: 0.1,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    context.l10n.driverFoundWaiting,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      height: 24 / 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
      borderRadius: BorderRadius.circular(12.r),
      elevation: 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          width: 48.w,
          height: 48.h,
          child: Icon(icon, color: AppColors.primary, size: 24.sp),
        ),
      ),
    );
  }
}

class _DriverAssignmentSheet extends StatelessWidget {
  const _DriverAssignmentSheet({required this.trip, required this.onCancel});

  final TripRecord? trip;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final driverName =
        trip?.driverSummary?.displayName ?? DriverFoundData.driverName;
    final vehicleInfo = trip?.transportType.name.trim().isNotEmpty == true
        ? trip!.transportType.name
        : DriverFoundData.vehicleInfo;
    final serviceTier = trip?.tripTypeLabel ?? DriverFoundData.serviceTier;
    final estimatedTime = trip == null
        ? DriverFoundData.estimatedTime
        : '${trip!.meteringSnapshot.totalMinutes} min';
    final fare = trip?.fareFormatted ??
        AppCurrencyFormatter.instance.formatEurMajor(DriverFoundData.fareEur);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.1),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 24.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _DriverAvatar(photoUrl: trip?.driverSummary?.photoUrl),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driverName,
                              style: GoogleFonts.manrope(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                height: 28 / 20,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              vehicleInfo,
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                                height: 24 / 16,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    serviceTier,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                      letterSpacing: 0.1,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _RideSummaryCard(
              estimatedTime: estimatedTime,
              fare: fare,
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: FilledButton(
                onPressed: onCancel,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.errorContainer,
                  foregroundColor: AppColors.onErrorContainer,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close, size: 20.sp),
                    SizedBox(width: 16.w),
                    Text(
                      context.l10n.driverSearchCancelTrip,
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
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                context.l10n.driverFoundCancelHint,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  height: 16 / 12,
                  color: AppColors.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverAvatar extends StatelessWidget {
  const _DriverAvatar({this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final imageUrl = photoUrl ?? DriverFoundData.driverPhotoImage;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 64.w,
          height: 64.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surfaceContainer, width: 2.w),
          ),
          child: ClipOval(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: AppColors.surfaceContainerLow,
                child: Icon(Icons.person, color: AppColors.primary, size: 32.sp),
              ),
            ),
          ),
        ),
        Positioned(
          right: -2.w,
          bottom: -2.h,
          child: Container(
            width: 24.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 4.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              DriverFoundData.rating,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.onSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RideSummaryCard extends StatelessWidget {
  const _RideSummaryCard({
    required this.estimatedTime,
    required this.fare,
  });

  final String estimatedTime;
  final String fare;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryStat(
              label: context.l10n.driverFoundEstimatedTime,
              icon: Icons.timer_outlined,
              value: estimatedTime,
            ),
          ),
          Expanded(
            child: _SummaryStat(
              label: context.l10n.driverFoundFare,
              icon: Icons.payments_outlined,
              value: fare,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.icon,
    required this.value,
  });

  final String label;
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
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
            Icon(icon, size: 18.sp, color: AppColors.primary),
            SizedBox(width: 4.w),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                height: 28 / 18,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
