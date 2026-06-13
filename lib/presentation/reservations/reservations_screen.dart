import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/data/reservations_data.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/auth/data/user_session.dart';
import 'package:local_ent_280/features/reservations/data/reservation_repository.dart';
import 'package:local_ent_280/presentation/widgets/app_bottom_nav.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/l10n/app_localizations.dart';

String _reservationStatusLabel(
  AppLocalizations l10n,
  ReservationStatus status,
) {
  return switch (status) {
    ReservationStatus.confirmada => l10n.reservationsStatusConfirmed,
    ReservationStatus.pendente => l10n.reservationsStatusPending,
  };
}

/// Reservas — `roles/details.md`.
class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key, this.reservationRepository});

  final ReservationRepository? reservationRepository;

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  late final ReservationRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = widget.reservationRepository ?? ReservationRepository();
  }

  @override
  Widget build(BuildContext context) {
    final clientId = UserSession.instance.profile?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _ReservationsAppBar(),
            Expanded(
              child: clientId == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder(
                      stream: _repository.watchClientReservations(clientId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final records = snapshot.data ?? const [];
                        final reservations =
                            records.map((record) => record.toItem()).toList();

                        return ListView(
                          padding: EdgeInsets.fromLTRB(
                            AppLayout.marginMobile,
                            16.h,
                            AppLayout.marginMobile,
                            24.h,
                          ),
                          children: [
                            const _Header(),
                            SizedBox(height: 16.h),
                            _NewReservationButton(
                              onTap: () =>
                                  AppNavigation.toTripDestination(context),
                            ),
                            SizedBox(height: 24.h),
                            if (reservations.isEmpty)
                              const _EmptyState()
                            else
                              for (final reservation in reservations) ...[
                                _ReservationCard(
                                  reservation: reservation,
                                  onDetails: () =>
                                      AppNavigation.toTripConfirm(context),
                                  onCancel: () {},
                                ),
                                SizedBox(height: 16.h),
                              ],
                            SizedBox(height: 16.h),
                          ],
                        );
                      },
                    ),
            ),
            AppBottomNav(
              selectedIndex: AppNavIndex.reservas,
              onItemTap: (index) =>
                  AppNavigation.onBottomNavTap(context, index),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationsAppBar extends StatelessWidget {
  const _ReservationsAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
      color: AppColors.background,
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.premiumMobility,
              style: AppTypography.manrope(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                height: 32 / 22,
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            width: 36.w,
            height: 36.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHigh,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              ReservationsData.profileAvatarImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.person,
                size: 18.sp,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.reservationsTitle,
          style: AppTypography.manrope(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            height: 36 / 28,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          context.l10n.reservationsSubtitle,
          style: AppTypography.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _NewReservationButton extends StatelessWidget {
  const _NewReservationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        icon: Icon(Icons.add, size: 22.sp, color: AppColors.onSecondary),
        label: Text(
          context.l10n.reservationsNew,
          style: AppTypography.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            height: 20 / 15,
            letterSpacing: 0.1,
            color: AppColors.onSecondary,
          ),
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
    required this.onDetails,
    required this.onCancel,
  });

  final ReservationItem reservation;
  final VoidCallback onDetails;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final isConfirmed = reservation.status == ReservationStatus.confirmada;

    return Opacity(
      opacity: isConfirmed ? 1 : 0.92,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.surfaceVariant.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              reservation: reservation,
              isConfirmed: isConfirmed,
            ),
            SizedBox(height: 12.h),
            _RouteTimeline(
              reservation: reservation,
              isConfirmed: isConfirmed,
            ),
            SizedBox(height: 12.h),
            Container(
              height: 1,
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
            ),
            SizedBox(height: 12.h),
            _CardFooter(
              reservation: reservation,
              isConfirmed: isConfirmed,
              onDetails: onDetails,
              onCancel: onCancel,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.reservation,
    required this.isConfirmed,
  });

  final ReservationItem reservation;
  final bool isConfirmed;

  @override
  Widget build(BuildContext context) {
    final iconBg = isConfirmed
        ? AppColors.secondaryContainer.withValues(alpha: 0.12)
        : AppColors.surfaceContainer;
    final iconColor =
        isConfirmed ? AppColors.secondary : AppColors.onSurfaceVariant;
    final pillBg =
        isConfirmed ? AppColors.secondaryFixed : AppColors.surfaceContainerHigh;
    final pillFg = isConfirmed
        ? AppColors.onSecondaryFixed
        : AppColors.onSurfaceVariant;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            isConfirmed ? Icons.event : Icons.calendar_month,
            size: 20.sp,
            color: iconColor,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reservation.date,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  letterSpacing: 0.1,
                  color: AppColors.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                reservation.timeMeta,
                style: AppTypography.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  height: 16 / 12,
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Text(
            _reservationStatusLabel(
              context.l10n,
              reservation.status,
            ),
            style: AppTypography.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              height: 16 / 11,
              color: pillFg,
            ),
          ),
        ),
      ],
    );
  }
}

class _RouteTimeline extends StatelessWidget {
  const _RouteTimeline({
    required this.reservation,
    required this.isConfirmed,
  });

  final ReservationItem reservation;
  final bool isConfirmed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 11.w,
          top: 28.h,
          bottom: 28.h,
          child: Container(
            width: 2.w,
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TimelineRow(
              icon: Icons.radio_button_checked,
              iconColor: isConfirmed ? AppColors.secondary : AppColors.outline,
              label: context.l10n.reservationsPickup,
              value: reservation.pickup,
            ),
            SizedBox(height: 14.h),
            _TimelineRow(
              icon: Icons.location_on,
              iconColor: isConfirmed ? AppColors.error : AppColors.outline,
              label: context.l10n.reservationsDestination,
              value: reservation.destination,
            ),
          ],
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24.w,
          height: 24.h,
          alignment: Alignment.center,
          color: AppColors.surfaceContainerLowest,
          child: Icon(icon, size: 20.sp, color: iconColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  height: 16 / 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: AppTypography.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  height: 22 / 15,
                  color: AppColors.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardFooter extends StatelessWidget {
  const _CardFooter({
    required this.reservation,
    required this.isConfirmed,
    required this.onDetails,
    required this.onCancel,
  });

  final ReservationItem reservation;
  final bool isConfirmed;
  final VoidCallback onDetails;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    if (isConfirmed) {
      return Row(
        children: [
          Icon(
            Icons.directions_car,
            size: 18.sp,
            color: AppColors.onSurfaceVariant,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              reservation.vehicleInfo ?? '',
              style: AppTypography.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                height: 16 / 12,
                color: AppColors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          InkWell(
            onTap: onDetails,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: Text(
                context.l10n.reservationsDetails,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  letterSpacing: 0.1,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: onCancel,
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: Text(
            context.l10n.reservationsCancel,
            style: AppTypography.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 20 / 14,
              letterSpacing: 0.1,
              color: AppColors.error,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 160.w,
          height: 160.w,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainer,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: Opacity(
            opacity: 0.4,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0, 0, 0, 1, 0,
              ]),
              child: Image.network(
                ReservationsData.emptyStateImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.directions_car_filled,
                  size: 64.sp,
                  color: AppColors.outline,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          context.l10n.reservationsEmptyTitle,
          style: AppTypography.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            height: 26 / 18,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            context.l10n.reservationsEmptyBody,
            style: AppTypography.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              height: 20 / 13,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
