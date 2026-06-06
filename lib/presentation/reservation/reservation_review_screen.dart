import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/constants/app_assets.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';

/// Revisão da Reserva — app_details/details.md.
class ReservationReviewScreen extends StatefulWidget {
  const ReservationReviewScreen({super.key});

  
  @override
  State<ReservationReviewScreen> createState() => _ReservationReviewScreenState();
}

class _ReservationReviewScreenState extends State<ReservationReviewScreen> {
  bool _creditCardSelected = true;

  static final _cardDecoration = BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(12.r),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _ReservationAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppLayout.marginMobile,
                24,
                AppLayout.marginMobile,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _VehicleCard(decoration: _cardDecoration),
                  SizedBox(height: 24.h),
                  _ItineraryCard(decoration: _cardDecoration),
                  SizedBox(height: 16.h),
                  const _SecurityBanner(),
                  SizedBox(height: 24.h),
                  _CostAndPaymentCard(
                    decoration: _cardDecoration,
                    creditCardSelected: _creditCardSelected,
                    onCreditCardTap: () =>
                        setState(() => _creditCardSelected = true),
                    onApplePayTap: () =>
                        setState(() => _creditCardSelected = false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationAppBar extends StatelessWidget {
  const _ReservationAppBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 56.h,
        color: AppColors.background,
        padding: EdgeInsets.symmetric(
          horizontal: AppLayout.marginMobile,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => AppNavigation.back(context),
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                context.l10n.reservationReviewTitle,
                style: GoogleFonts.manrope(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  height: 32 / 24,
                  color: AppColors.primary,
                ),
              ),
            ),
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                AppAssets.reservationProfileAvatarImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person,
                  size: 18.sp,
                  color: AppColors.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.decoration});

  final BoxDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.network(
              AppAssets.reservationTeslaImage,
              height: 180.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: AppColors.surfaceContainerHigh,
                child: SizedBox(height: 180.h),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tesla Model 3 Performance',
                      style: GoogleFonts.manrope(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        height: 28 / 20,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Elétrico • 5 Lugares • Automático',
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
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  context.l10n.premium,
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
          SizedBox(height: 16.h),
          Row(
            children: [
              SizedBox(width: 20.w,
                height: 20.h,
                child: Icon(
                  Symbols.verified,
                  size: 20.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                context.l10n.reservationFullInsurance,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  letterSpacing: 0.1,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItineraryCard extends StatelessWidget {
  const _ItineraryCard({required this.decoration});

  final BoxDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.reservationItinerary,
            style: GoogleFonts.manrope(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              height: 28 / 20,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16.h),
          _ItineraryStop(
            icon: Icons.location_on,
            iconColor: AppColors.secondary,
            label: context.l10n.reservationPickupLabel,
            place: 'Aeroporto de Lisboa (LIS)',
            dateTime: '15 Out, 2023 às 10:00',
            showConnector: true,
          ),
          _ItineraryStop(
            icon: Icons.flag,
            iconColor: AppColors.primary,
            label: context.l10n.reservationReturnLabel,
            place: 'Aeroporto de Lisboa (LIS)',
            dateTime: '20 Out, 2023 às 18:00',
            showConnector: false,
          ),
        ],
      ),
    );
  }
}

class _ItineraryStop extends StatelessWidget {
  const _ItineraryStop({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.place,
    required this.dateTime,
    required this.showConnector,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String place;
  final String dateTime;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 24.w,
            child: Column(
              children: [
                Icon(icon, size: 24.sp, color: iconColor),
                if (showConnector)
                  Expanded(
                    child: Container(
                      width: 2.w,
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      color: AppColors.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showConnector ? 24 : 0),
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
                  SizedBox(height: 2.h),
                  Text(
                    place,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      height: 24 / 16,
                      color: AppColors.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    dateTime,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                      letterSpacing: 0.1,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityBanner extends StatelessWidget {
  const _SecurityBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Symbols.security,
            size: 24.sp,
            color: AppColors.secondaryContainer,
            fill: 1,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.reservationSecurePayment,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                    letterSpacing: 0.1,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  context.l10n.reservationSecurePaymentDesc,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    height: 16 / 12,
                    color: AppColors.onSurfaceVariant,
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

class _CostAndPaymentCard extends StatelessWidget {
  const _CostAndPaymentCard({
    required this.decoration,
    required this.creditCardSelected,
    required this.onCreditCardTap,
    required this.onApplePayTap,
  });

  final BoxDecoration decoration;
  final bool creditCardSelected;
  final VoidCallback onCreditCardTap;
  final VoidCallback onApplePayTap;

  static const _lineItems = [
    ('Aluguer (5 dias)', '345,00 €'),
    ('Taxas de Aeroporto', '24,50 €'),
    ('Cadeira de Criança (Extra)', '15,00 €'),
    ('IVA (23%)', '88,44 €'),
  ];

  @override
  Widget build(BuildContext context) {
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
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.reservationCostSummary,
            style: GoogleFonts.manrope(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              height: 28 / 20,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24.h),
          ..._lineItems.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
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
                      fontSize: 16.sp,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          const _DashedDivider(),
          SizedBox(height: 24.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  context.l10n.total,
                  style: GoogleFonts.manrope(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    height: 28 / 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                    '472,94 €',
                    style: GoogleFonts.manrope(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      height: 32 / 24,
                      color: AppColors.secondary,
                    ),
                  ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    context.l10n.reservationNoHiddenFees,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 32.h),
          Text(
            context.l10n.reservationPaymentMethod,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 20 / 14,
              letterSpacing: 0.1,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Material(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8.r),
            child: InkWell(
              onTap: onCreditCardTap,
              borderRadius: BorderRadius.circular(8.r),
              child: Ink(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: creditCardSelected
                        ? AppColors.secondaryContainer
                        : AppColors.outlineVariant,
                    width: creditCardSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Symbols.credit_card,
                      color: AppColors.secondaryContainer,
                      fill: 1,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.reservationCreditCard,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '•••• •••• •••• 4242',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondaryContainer,
                          width: creditCardSelected ? 6 : 2,
                        ),
                        color: AppColors.surfaceContainerLowest,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Material(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8.r),
            child: InkWell(
              onTap: onApplePayTap,
              borderRadius: BorderRadius.circular(8.r),
              child: Ink(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Symbols.ios, color: AppColors.primary),
                      SizedBox(width: 16.w),
                      Text(
                        context.l10n.reservationPayWithApplePay,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 32.h),
          Material(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(12.r),
            elevation: 4,
            shadowColor: AppColors.secondary.withValues(alpha: 0.2),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18.h),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.reservationConfirmAndPay,
                        style: GoogleFonts.manrope(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          height: 28 / 20,
                          color: AppColors.onSecondary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.onSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text.rich(
            TextSpan(
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                height: 16 / 12,
                color: AppColors.onSurfaceVariant,
              ),
              children: [
                TextSpan(
                  text: context.l10n.reservationTermsPrefix,
                ),
                TextSpan(
                  text: context.l10n.reservationTermsLink,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final dashCount =
            (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(dashCount, (index) {
            return Container(
              width: dashWidth,
              height: 1.0,
              margin: EdgeInsets.only(
                right: index < dashCount - 1 ? dashSpace : 0,
              ),
              color: AppColors.outlineVariant,
            );
          }),
        );
      },
    );
  }
}
