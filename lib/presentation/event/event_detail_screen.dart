import 'dart:ui';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/core/constants/app_assets.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/presentation/widgets/app_bottom_nav.dart';
import 'package:local_ent_280/features/catalog/data/catalog_repository.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key});

  static double get _heroHeight => 353.h;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  int _quantity = 1;
  double _ticketPriceEur = 0;
  double _serviceFeeEur = 0;
  final _catalog = CatalogRepository();

  @override
  void initState() {
    super.initState();
    _catalog.watchActivePackages().first.then((packages) {
      if (!mounted) return;
      setState(() {
        _ticketPriceEur =
            packages.isEmpty ? 0 : packages.first.priceEur;
      });
    });
    _catalog.watchEventServiceFeeMinor().first.then((feeMinor) {
      if (!mounted) return;
      setState(() => _serviceFeeEur = feeMinor / 100);
    });
  }

  double get _subtotal => _quantity * _ticketPriceEur;
  double get _total => _subtotal + _serviceFeeEur;

  String _formatPrice(double value) =>
      AppCurrencyFormatter.instance.formatEurMajor(value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _EventAppBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _EventHero(),
                  Transform.translate(
                    offset: Offset(0, -40.h),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppLayout.marginMobile,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 12.h),
                          const _EventInfoCard(),
                          SizedBox(height: 24.h),
                          const _MapCard(),
                          SizedBox(height: 24.h),
                          _TicketCard(
                            quantity: _quantity,
                            ticketPriceEur: _ticketPriceEur,
                            serviceFeeEur: _serviceFeeEur,
                            subtotal: _subtotal,
                            total: _total,
                            formatPrice: _formatPrice,
                            onDecrement: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                            onIncrement: () => setState(() => _quantity++),
                          ),
                          SizedBox(height: 24.h),
                          const _VipCard(),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppBottomNav(
            selectedIndex: AppNavIndex.reservas,
            onItemTap: (index) => AppNavigation.onBottomNavTap(context, index),
          ),
        ],
      ),
    );
  }
}

class _EventAppBar extends StatelessWidget {
  const _EventAppBar();

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
            SizedBox(width: 16.w),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    context.l10n.appNameLocalTransport,
                    maxLines: 1,
                    style: GoogleFonts.manrope(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 32.w,
              height: 32.h,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer,
              ),
              child: ClipOval(
                child: Image.network(
                  AppAssets.eventProfileAvatarImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    size: 18.sp,
                    color: AppColors.onSecondaryContainer,
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

class _EventHero extends StatelessWidget {
  const _EventHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: EventDetailScreen._heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            AppAssets.eventHeroImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => ColoredBox(
              color: AppColors.primary,
              child: Icon(Icons.event, color: Colors.white54, size: 48.sp),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            left: AppLayout.marginMobile,
            right: AppLayout.marginMobile,
            bottom: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'MÚSICA ELETRÓNICA',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: AppColors.secondaryFixed,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Gala de Verão: Porto Sunset',
                  style: GoogleFonts.manrope(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: -0.64,
                    color: Colors.white,
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

class _EventInfoCard extends StatelessWidget {
  const _EventInfoCard();

  static const _description =
      'Prepare-se para a noite mais exclusiva do ano. A Gala de Verão no Porto combina o melhor da música eletrónica melódica com uma vista deslumbrante sobre o Rio Douro. O evento contará com serviço de catering premium, áreas lounge VIP e uma experiência audiovisual imersiva sem precedentes na cidade.';

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24.r),
        bottom: Radius.circular(12.r),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 32,
            runSpacing: 16,
            children: [
              _InfoRow(
                icon: Icons.calendar_today,
                label: context.l10n.eventDateTimeLabel,
                value: '15 de Julho, 18:00',
              ),
              _InfoRow(
                icon: Icons.location_on,
                label: context.l10n.eventLocationLabel,
                value: 'Alfândega do Porto',
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          SizedBox(height: 16.h),
          Text(
            context.l10n.eventAboutTitle,
            style: GoogleFonts.manrope(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              height: 28 / 20,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _description,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              height: 24 / 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
        Container(
          width: 40.w,
          height: 40.h,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.secondary, size: 22.sp),
        ),
        SizedBox(width: 8.w),
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
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  letterSpacing: 0.1,
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

class _MapCard extends StatelessWidget {
  const _MapCard();

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 8.h),
            child: Text(
              context.l10n.eventDirectionsTitle,
              style: GoogleFonts.manrope(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                height: 28 / 20,
                color: AppColors.onSurface,
              ),
            ),
          ),
          SizedBox(height: 192.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0.5,
                    0,
                  ]),
                  child: Image.network(
                    AppAssets.eventMapImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const ColoredBox(color: AppColors.surfaceContainerHigh),
                  ),
                ),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondary, width: 2.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 12.r,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.secondary,
                      size: 24.sp,
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    elevation: 4,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(8.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.directions,
                              size: 18.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              context.l10n.eventOpenGps,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.quantity,
    required this.ticketPriceEur,
    required this.serviceFeeEur,
    required this.subtotal,
    required this.total,
    required this.formatPrice,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final double ticketPriceEur;
  final double serviceFeeEur;
  final double subtotal;
  final double total;
  final String Function(double) formatPrice;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
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
                    Text(
                      context.l10n.eventStandardTicket,
                      style: GoogleFonts.manrope(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        height: 28 / 20,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      context.l10n.eventStandardTicketDesc,
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
              Text(
                formatPrice(ticketPriceEur),
                style: GoogleFonts.manrope(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  height: 28 / 20,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            context.l10n.quantity,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 20 / 14,
              letterSpacing: 0.1,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _QuantityButton(
                  icon: Icons.remove,
                  isPrimary: false,
                  onTap: onDecrement,
                ),
                Text(
                  '$quantity',
                  style: GoogleFonts.manrope(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                _QuantityButton(
                  icon: Icons.add,
                  isPrimary: true,
                  onTap: onIncrement,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Divider(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          SizedBox(height: 16.h),
          _PriceRow(label: context.l10n.subtotal, value: formatPrice(subtotal)),
          SizedBox(height: 4.h),
          _PriceRow(
            label: context.l10n.eventServiceFee,
            value: formatPrice(serviceFeeEur),
          ),
          SizedBox(height: 8.h),
          _PriceRow(
            label: context.l10n.total,
            value: formatPrice(total),
            isBold: true,
            valueColor: AppColors.secondary,
          ),
          SizedBox(height: 24.h),
          SizedBox(height: 56.h,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
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
                  Icon(Icons.shopping_cart_checkout, size: 22.sp),
                  SizedBox(width: 8.w),
                  Text(
                    context.l10n.eventPayNow,
                    style: GoogleFonts.manrope(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Opacity(
            opacity: 0.6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.credit_card, color: AppColors.onSurfaceVariant),
                SizedBox(width: 16.w),
                Icon(Icons.account_balance, color: AppColors.onSurfaceVariant),
                SizedBox(width: 16.w),
                Text(
                  'MBWAY',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
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

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.secondary : Colors.white,
      borderRadius: BorderRadius.circular(8.r),
      elevation: isPrimary ? 0 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(width: 48.w,
          height: 48.h,
          child: Icon(
            icon,
            color: isPrimary ? AppColors.onSecondary : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.inter(
      fontSize: isBold ? 20 : 14,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
      height: isBold ? 28 / 20 : 20 / 14,
      letterSpacing: isBold ? 0 : 0.1,
      color: isBold ? AppColors.onSurface : AppColors.onSurfaceVariant,
    );
    final valueStyle = GoogleFonts.inter(
      fontSize: isBold ? 20 : 14,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
      height: isBold ? 28 / 20 : 20 / 14,
      letterSpacing: isBold ? 0 : 0.1,
      color:
          valueColor ??
          (isBold ? AppColors.onSurface : AppColors.onSurfaceVariant),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _VipCard extends StatelessWidget {
  const _VipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.outlineVariant,
          style: BorderStyle.solid,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.eventVipExperience,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                    letterSpacing: 0.1,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tertiary,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  context.l10n.eventLimited,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onTertiary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            context.l10n.eventVipDescription,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              height: 16 / 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () {},
            child: Text(
              context.l10n.eventCheckAvailability,
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
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child, this.padding, this.borderRadius});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: borderRadius ?? BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: child,
    );
  }
}
