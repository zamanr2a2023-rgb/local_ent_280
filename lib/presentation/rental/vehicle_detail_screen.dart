import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/constants/app_assets.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/features/rental/data/rental_booking_draft.dart';
import 'package:local_ent_280/features/rental/data/rental_vehicle_repository.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/l10n/app_localizations.dart';
import 'package:local_ent_280/presentation/widgets/session_profile_avatar.dart';

/// Detalhes do Veículo — Firebase `vehicles/{id}` when [vehicleId] is set.
class VehicleDetailScreen extends StatelessWidget {
  const VehicleDetailScreen({super.key, this.vehicleId, this.repository});

  final String? vehicleId;
  final RentalVehicleRepository? repository;

  static final _cardDecoration = BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(12.r),
    border: Border.all(color: AppColors.surfaceVariant.withValues(alpha: 0.2)),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.04),
        blurRadius: 8.r,
        offset: Offset(0, 2.h),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final repository = this.repository ?? RentalVehicleRepository();
    if (vehicleId == null || vehicleId!.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const _DetailAppBar(),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppLayout.marginMobile),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.rentalNoVehicles,
                          style: GoogleFonts.inter(fontSize: 14.sp),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        FilledButton(
                          onPressed: () =>
                              AppNavigation.toVehicleSearchResults(context),
                          child: Text(context.l10n.rentalSearchAvailable),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (vehicleId != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: StreamBuilder<RentalVehicleRecord?>(
          stream: repository.watchVehicle(vehicleId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final vehicle = snapshot.data;
            if (vehicle == null) {
              return SafeArea(
                child: Column(
                  children: [
                    const _DetailAppBar(),
                    Expanded(
                      child: Center(
                        child: Text(
                          context.l10n.rentalNoVehicles,
                          style: GoogleFonts.inter(fontSize: 14.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return _FirebaseVehicleDetailBody(vehicle: vehicle);
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Center(child: CircularProgressIndicator())),
    );
  }
}

class _DetailAppBar extends StatelessWidget {
  const _DetailAppBar();

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
              onPressed: () => AppNavigation.back(context),
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.primary,
                size: 24.sp,
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                context.l10n.rentalVehicleDetails,
                style: GoogleFonts.manrope(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  height: 32 / 24,
                  color: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SessionProfileAvatar(
              size: 32.w,
              fontSize: 11.sp,
              onTap: () => AppNavigation.toProfile(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _GallerySection extends StatelessWidget {
  const _GallerySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GalleryImage(
          url: AppAssets.vehicleDetailExteriorImage,
          height: 220.h,
          showOverlayActions: true,
        ),
        SizedBox(height: 8.h),
        _GalleryImage(url: AppAssets.vehicleDetailInteriorImage, height: 160.h),
        SizedBox(height: 8.h),
        Stack(
          children: [
            _GalleryImage(
              url: AppAssets.vehicleDetailWheelImage,
              height: 160.h,
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GalleryImage extends StatelessWidget {
  const _GalleryImage({
    required this.url,
    required this.height,
    this.showOverlayActions = false,
  });

  final String url;
  final double height;
  final bool showOverlayActions;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: AppColors.surfaceContainerHigh,
                child: Icon(Icons.directions_car, size: 48.sp),
              ),
            ),
            if (showOverlayActions) ...[
              Positioned(
                top: 12.h,
                left: 12.w,
                child: _CircleIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => AppNavigation.back(context),
                ),
              ),
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Row(
                  children: [
                    _CircleIconButton(icon: Icons.ios_share, onTap: () {}),
                    SizedBox(width: 8.w),
                    _CircleIconButton(
                      icon: Icons.favorite_border,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 16.w,
                bottom: 16.h,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_camera,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '1/12',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40.w,
          height: 40.h,
          child: Icon(icon, size: 20.sp, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _MainInfoCard extends StatelessWidget {
  const _MainInfoCard({required this.decoration});

  final BoxDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        context.l10n.rentalDemoSportPremium,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      context.l10n.rentalDemoVehicleName,
                      style: GoogleFonts.manrope(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700,
                        height: 40 / 32,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    context.l10n.rentalRating,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.secondary, size: 20.sp),
                      SizedBox(width: 4.w),
                      Text(
                        '4.9 (124)',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Divider(
            height: 32.h,
            color: AppColors.surfaceVariant.withValues(alpha: 0.3),
          ),
          Row(
            children: [
              Expanded(
                child: _SpecItem(
                  icon: Icons.ev_station,
                  label: context.l10n.rentalPowertrain,
                  value: context.l10n.rentalElectric,
                ),
              ),
              Expanded(
                child: _SpecItem(
                  icon: Icons.settings_input_component,
                  label: context.l10n.rentalTransmission,
                  value: context.l10n.rentalTransmissionAutomatic,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _SpecItem(
                  icon: Icons.person_outline,
                  label: context.l10n.rentalCapacity,
                  value: context.l10n.rentalSeats('4'),
                ),
              ),
              Expanded(
                child: _SpecItem(
                  icon: Icons.speed,
                  label: context.l10n.rentalAcceleration,
                  value: '4.0s (0-100)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  const _SpecItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.secondaryContainer, size: 24.sp),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _InsuranceCard extends StatelessWidget {
  const _InsuranceCard({required this.decoration});

  final BoxDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: decoration.copyWith(
        color: AppColors.accentSurface.withValues(alpha: 0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user,
                  color: AppColors.secondary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  context.l10n.rentalInsuranceIncluded,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    height: 28 / 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            context.l10n.rentalInsuranceDescription,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              height: 24 / 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 12.h),
          _CheckListItem(text: context.l10n.rentalInsuranceFranchiseWaiver),
          SizedBox(height: 8.h),
          _CheckListItem(text: context.l10n.rentalInsuranceCdw),
        ],
      ),
    );
  }
}

class _FuelCard extends StatelessWidget {
  const _FuelCard({required this.decoration});

  final BoxDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: decoration.copyWith(
        color: AppColors.accentSurface.withValues(alpha: 0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_gas_station,
                  color: AppColors.secondary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  context.l10n.rentalFuelPolicy,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    height: 28 / 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            context.l10n.rentalFuelPolicyElectric,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              height: 24 / 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Text(
                  context.l10n.rentalCurrentBattery,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  '92%',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
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

class _CheckListItem extends StatelessWidget {
  const _CheckListItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: const Color(0xFF16A34A), size: 18.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingSummaryCard extends StatelessWidget {
  const _BookingSummaryCard({required this.decoration});

  final BoxDecoration decoration;

  @override
  Widget build(BuildContext context) {
    final formatter = AppCurrencyFormatter.instance;
    final l10n = context.l10n;
    final perDay = RentalBookingDraft.instance.pricePerDayEur;
    const days = 3;
    final rentalTotal = perDay * days;
    final airportFees = perDay * 0.056;
    final total = rentalTotal + airportFees;
    final lineItems = <(String, String, bool)>[
      (
        l10n.rentalBookingRentalDays(days),
        formatter.formatEurMajor(rentalTotal),
        false,
      ),
      (l10n.rentalBookingPremiumInsurance, l10n.rentalBookingIncluded, true),
      (
        l10n.rentalBookingAirportFees,
        formatter.formatEurMajor(airportFees),
        false,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: decoration.copyWith(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.rentalBookingSummary,
            style: GoogleFonts.manrope(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              height: 28 / 20,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16.h),
          for (final item in lineItems) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.$1,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  item.$2,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: item.$3
                        ? const Color(0xFF16A34A)
                        : AppColors.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],
          Divider(color: AppColors.surfaceVariant.withValues(alpha: 0.3)),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.rentalTotalCost,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      formatter.formatEurMajor(total),
                      style: GoogleFonts.manrope(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700,
                        height: 40 / 32,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatter.formatEurMajorWithSuffix(perDay, ' / dia'),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _InfoPill(icon: Icons.event, text: '12 Out — 15 Out 2023'),
          SizedBox(height: 8.h),
          _InfoPill(
            icon: Icons.location_on,
            text: context.l10n.rentalDemoAirportLocation,
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.onSurfaceVariant),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechnicalSpecsCard extends StatelessWidget {
  const _TechnicalSpecsCard();

  static List<(String, String)> _specs(AppLocalizations l10n) => [
    (l10n.rentalSpecPower, l10n.rentalSpecPowerValue),
    (l10n.rentalSpecRange, l10n.rentalSpecRangeValue),
    (l10n.rentalSpecDrive, l10n.rentalSpecDriveValue),
  ];

  @override
  Widget build(BuildContext context) {
    final specs = _specs(context.l10n);
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.rentalTechnicalSpecs,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.primaryFixedDim,
            ),
          ),
          SizedBox(height: 16.h),
          for (var i = 0; i < specs.length; i++) ...[
            Row(
              children: [
                Text(
                  specs[i].$1,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.onPrimary.withValues(alpha: 0.6),
                  ),
                ),
                const Spacer(),
                Text(
                  specs[i].$2,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
            if (i < specs.length - 1)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Divider(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.bottomInset});

  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final draft = RentalBookingDraft.instance;
    final totalLabel = AppCurrencyFormatter.instance.formatEurMajor(
      draft.estimatedTotalEur,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppLayout.marginMobile,
        12.h,
        AppLayout.marginMobile,
        12.h + bottomInset,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
        border: Border(
          top: BorderSide(
            color: AppColors.surfaceVariant.withValues(alpha: 0.2),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.rentalReservationTotal,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  totalLabel,
                  style: GoogleFonts.manrope(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    height: 28 / 20,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 56.h,
              child: FilledButton(
                onPressed: () => AppNavigation.toReservationReview(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.onSecondary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        context.l10n.rentalContinueToPayment,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_forward, size: 20.sp),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FirebaseVehicleDetailBody extends StatelessWidget {
  const _FirebaseVehicleDetailBody({required this.vehicle});

  final RentalVehicleRecord vehicle;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Column(
      children: [
        const _DetailAppBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppLayout.marginMobile,
              16.h,
              AppLayout.marginMobile,
              100.h + bottomInset,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    vehicle.imageUrl,
                    height: 220.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => ColoredBox(
                      color: AppColors.surfaceContainerHigh,
                      child: SizedBox(
                        height: 220.h,
                        child: Icon(Icons.directions_car, size: 48.sp),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  vehicle.name,
                  style: GoogleFonts.manrope(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  context.l10n.rentalVehicleSummary(
                    AppCurrencyFormatter.instance.formatEurMajorWithSuffix(
                      vehicle.pricePerDay.toDouble(),
                      context.l10n.rentalPerDay,
                    ),
                    context.l10n.rentalSeats('${vehicle.seats}'),
                    vehicle.transmissionLabel,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (vehicle.notes.trim().isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Text(
                    vehicle.notes.trim(),
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppLayout.marginMobile,
            8.h,
            AppLayout.marginMobile,
            16.h + bottomInset,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52.h,
            child: FilledButton(
              onPressed: () => AppNavigation.toReservationReview(
                context,
                vehicleId: vehicle.id,
                vehicleLabel: vehicle.name,
                pricePerDayEur: vehicle.pricePerDay.toDouble(),
                imageUrl: vehicle.imageUrl,
                seats: vehicle.seats,
                transmission: vehicle.transmissionLabel,
                category: vehicle.categoryLabel,
                isElectric: vehicle.isElectric,
                isPremium: vehicle.isPremium,
              ),
              child: Text(context.l10n.rentalContinueToPayment),
            ),
          ),
        ),
      ],
    );
  }
}
