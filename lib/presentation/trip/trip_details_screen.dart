import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/data/trip_details_data.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';

/// Detalhes da Viagem — `roles/details.md`.
class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _DetailsAppBar(onBack: () => AppNavigation.back(context)),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppLayout.marginMobile,
                  12.h,
                  AppLayout.marginMobile,
                  24.h,
                ),
                children: [
                  const _MapCard(),
                  SizedBox(height: 16.h),
                  const _SummaryCard(),
                  SizedBox(height: 16.h),
                  const _RatingCard(),
                  SizedBox(height: 16.h),
                  const _InvoiceCard(),
                  SizedBox(height: 16.h),
                  const _DriverCard(),
                  SizedBox(height: 16.h),
                  const _SupportCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsAppBar extends StatelessWidget {
  const _DetailsAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
      color: AppColors.background,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.primary,
              size: 24.sp,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Mobilidade Premium',
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceVariant,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              TripDetailsData.profileAvatarImage,
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

class _CardContainer extends StatelessWidget {
  const _CardContainer({
    required this.child,
    this.topBorderColor,
    this.border,
  });

  final Widget child;
  final Color? topBorderColor;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: border,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (topBorderColor != null) Container(height: 4.h, color: topBorderColor),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              TripDetailsData.mapImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: AppColors.surfaceContainer,
                child: Icon(
                  Icons.map,
                  size: 48.sp,
                  color: AppColors.outline,
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background.withValues(alpha: 0),
                      AppColors.background.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16.w,
              bottom: 16.h,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 6.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16.sp,
                      color: AppColors.secondary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      TripDetailsData.tripDurationDistance,
                      style: AppTypography.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        height: 18 / 13,
                        letterSpacing: 0.1,
                        color: AppColors.onSurface,
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TripDetailsData.summaryTitle,
                      style: AppTypography.manrope(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        height: 24 / 18,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      TripDetailsData.summaryDate,
                      style: AppTypography.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  TripDetailsData.summaryStatus,
                  style: AppTypography.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    height: 16 / 11,
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _RouteTimeline(),
        ],
      ),
    );
  }
}

class _RouteTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 11.w,
          top: 24.h,
          bottom: 24.h,
          child: Container(width: 2.w, color: AppColors.outlineVariant),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TimelineRow(
              icon: Icons.location_on,
              iconColor: AppColors.secondary,
              title: TripDetailsData.pickupAddress,
              subtitle: TripDetailsData.pickupCity,
            ),
            SizedBox(height: 12.h),
            _TimelineRow(
              icon: Icons.trip_origin,
              iconColor: AppColors.primary,
              title: TripDetailsData.destinationAddress,
              subtitle: TripDetailsData.destinationDetails,
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
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

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
                title,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  letterSpacing: 0.1,
                  color: AppColors.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
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
      ],
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard();

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TripDetailsData.ratingTitle,
            style: AppTypography.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 20 / 14,
              letterSpacing: 0.1,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Row(
                  children: List.generate(5, (i) {
                    final filled = i < TripDetailsData.ratingStars;
                    return Padding(
                      padding: EdgeInsets.only(right: 2.w),
                      child: Icon(
                        filled ? Icons.star : Icons.star_border,
                        size: 22.sp,
                        color: AppColors.secondary,
                      ),
                    );
                  }),
                ),
                const Spacer(),
                Text(
                  TripDetailsData.ratingEditCta,
                  style: AppTypography.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                    letterSpacing: 0.1,
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

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard();

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      topBorderColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  TripDetailsData.invoiceTitle,
                  style: AppTypography.manrope(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    height: 24 / 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Icon(
                Icons.receipt_long,
                size: 22.sp,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
          SizedBox(height: 14.h),
          for (final line in TripDetailsData.invoiceLines) ...[
            _FareLineRow(line: line),
            SizedBox(height: 8.h),
          ],
          SizedBox(height: 4.h),
          Container(height: 1, color: AppColors.outlineVariant),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TripDetailsData.totalLabel,
                      style: AppTypography.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        TripDetailsData.totalAmount,
                        style: AppTypography.manrope(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w700,
                          height: 38 / 32,
                          letterSpacing: -0.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    TripDetailsData.methodLabel,
                    style: AppTypography.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.credit_card,
                        size: 14.sp,
                        color: AppColors.onSurface,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        TripDetailsData.methodValue,
                        style: AppTypography.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          height: 18 / 13,
                          letterSpacing: 0.1,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: FilledButton.tonalIcon(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLow,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              icon: Icon(
                Icons.download,
                size: 18.sp,
                color: AppColors.primary,
              ),
              label: Text(
                TripDetailsData.downloadCta,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  letterSpacing: 0.1,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FareLineRow extends StatelessWidget {
  const _FareLineRow({required this.line});

  final FareLine line;

  @override
  Widget build(BuildContext context) {
    final color = line.isDiscount
        ? AppColors.secondary
        : AppColors.onSurface;
    final labelColor = line.isDiscount
        ? AppColors.secondary
        : AppColors.onSurfaceVariant;

    return Row(
      children: [
        Expanded(
          child: Text(
            line.label,
            style: AppTypography.inter(
              fontSize: 13.sp,
              fontWeight: line.isDiscount ? FontWeight.w500 : FontWeight.w400,
              height: 20 / 13,
              color: labelColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          line.amount,
          style: AppTypography.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            height: 20 / 14,
            letterSpacing: 0.1,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard();

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      child: Row(
        children: [
          SizedBox(
            width: 64.w,
            height: 64.w,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceVariant,
                    border: Border.all(
                      color: AppColors.secondary,
                      width: 2.w,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    TripDetailsData.driverAvatarImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person,
                      size: 32.sp,
                      color: AppColors.outline,
                    ),
                  ),
                ),
                Positioned(
                  right: -2.w,
                  bottom: -2.h,
                  child: Container(
                    width: 22.w,
                    height: 22.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary,
                      border: Border.all(
                        color: AppColors.surfaceContainerLowest,
                        width: 2.w,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        TripDetailsData.driverRating,
                        style: AppTypography.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          height: 1,
                          color: AppColors.onSecondary,
                        ),
                      ),
                    ),
                  ),
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
                  TripDetailsData.driverName,
                  style: AppTypography.manrope(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    height: 24 / 18,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  TripDetailsData.driverCar,
                  style: AppTypography.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    height: 18 / 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  TripDetailsData.driverTier,
                  style: AppTypography.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    height: 16 / 12,
                    letterSpacing: 0.1,
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

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      border: Border.all(color: AppColors.errorContainer),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.report_outlined,
                size: 22.sp,
                color: AppColors.error,
              ),
              SizedBox(width: 10.w),
              Text(
                TripDetailsData.supportTitle,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  height: 20 / 14,
                  letterSpacing: 0.1,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          for (final action in TripDetailsData.supportActions)
            _SupportActionRow(action: action, onTap: () {}),
        ],
      ),
    );
  }
}

class _SupportActionRow extends StatelessWidget {
  const _SupportActionRow({required this.action, required this.onTap});

  final SupportAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  action.label,
                  style: AppTypography.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    height: 20 / 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18.sp,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
