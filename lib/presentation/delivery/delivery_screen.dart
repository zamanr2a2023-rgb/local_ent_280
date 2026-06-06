import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/constants/app_assets.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/presentation/widgets/app_bottom_nav.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';

class DeliveryScreen extends StatelessWidget {
  const DeliveryScreen({super.key});

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 72.h + MediaQuery.paddingOf(context).bottom,
        ),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.shopping_basket, size: 26.sp),
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 20.w,
                  height: 20.h,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '2',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const _DeliveryAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.marginMobile,
                    ),
                    child: _LocationAndSearch(),
                  ),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.marginMobile,
                    ),
                    child: _CategoriesSection(),
                  ),
                  SizedBox(height: 32.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.marginMobile,
                    ),
                    child: _PartnersSection(),
                  ),
                  SizedBox(height: 32.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.marginMobile,
                    ),
                    child: _HighlightsSection(),
                  ),
                ],
              ),
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

class _DeliveryAppBar extends StatelessWidget {
  const _DeliveryAppBar();

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
              icon: const Icon(Icons.menu, color: AppColors.primary),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
            ),
            SizedBox(width: 8.w),
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
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: ClipOval(
                child: Image.network(
                  AppAssets.deliveryProfileAvatarImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.person,
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

class _LocationAndSearch extends StatelessWidget {
  const _LocationAndSearch();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, size: 18.sp, color: AppColors.primary),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                context.l10n.deliveryDeliverTo,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            Icon(Icons.expand_more, size: 18.sp, color: AppColors.primary),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          height: 56.h,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              SizedBox(width: 16.w),
              const Icon(Icons.search, color: AppColors.outline),
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: context.l10n.deliverySearchHint,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.deliveryExploreCategories,
          style: GoogleFonts.manrope(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            height: 28 / 20,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 16.h),
        _CategoryCard(
          imageUrl: AppAssets.deliverySupermarketImage,
          title: context.l10n.deliveryCategorySupermarket,
          subtitle: context.l10n.deliveryCategorySupermarketSubtitle,
          height: 180.h,
          titleSize: 24,
          onTap: () => AppNavigation.toPremiumHome(context),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _CategoryCard(
                imageUrl: AppAssets.deliveryPharmacyImage,
                title: context.l10n.deliveryCategoryPharmacy,
                height: 140.h,
                onTap: () => AppNavigation.toPremiumHome(context),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _CategoryCard(
                imageUrl: AppAssets.deliveryBeveragesImage,
                title: context.l10n.deliveryCategoryBeverages,
                height: 140.h,
                onTap: () => AppNavigation.toPremiumHome(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _CategoryCard(
          imageUrl: AppAssets.deliveryHealthImage,
          title: context.l10n.deliveryCategoryHealth,
          height: 120.h,
          onTap: () => AppNavigation.toPremiumHome(context),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.imageUrl,
    required this.title,
    this.subtitle,
    required this.height,
    this.titleSize = 14,
    this.onTap,
  });

  final String imageUrl;
  final String title;
  final String? subtitle;
  final double height;
  final double titleSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: AppColors.surfaceContainerHigh),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: subtitle != null ? 0.8 : 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
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

class _PartnersSection extends StatelessWidget {
  const _PartnersSection();

  static const _partners = [
    (
      image: AppAssets.deliveryPartnerMarketImage,
      name: 'Market Gourmet',
      rating: '4.9',
      time: '15-25 min',
      fee: '€2.50 entrega',
      premium: true,
      feeIsFree: false,
    ),
    (
      image: AppAssets.deliveryPartnerPharmaImage,
      name: 'Pharma Care',
      rating: '4.8',
      time: '20-35 min',
      fee: 'Grátis',
      premium: false,
      feeIsFree: true,
    ),
    (
      image: AppAssets.deliveryPartnerAdegaImage,
      name: 'Adega Real',
      rating: '5.0',
      time: '10-20 min',
      fee: '€1.90 entrega',
      premium: false,
      feeIsFree: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.deliveryPartnersTitle,
                    style: GoogleFonts.manrope(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      height: 28 / 20,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    context.l10n.deliveryPartnersSubtitle,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                context.l10n.seeAll,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < _partners.length; i++) ...[
                if (i > 0) SizedBox(width: 16.w),
                Builder(
                  builder: (context) {
                    final p = _partners[i];
                    return _PartnerCard(
                      imageUrl: p.image,
                      name: p.name,
                      rating: p.rating,
                      time: p.time,
                      fee: p.feeIsFree ? context.l10n.free : p.fee,
                      showPremiumBadge: p.premium,
                      feeIsFree: p.feeIsFree,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({
    required this.imageUrl,
    required this.name,
    required this.rating,
    required this.time,
    required this.fee,
    required this.showPremiumBadge,
    required this.feeIsFree,
  });

  final String imageUrl;
  final String name;
  final String rating;
  final String time;
  final String fee;
  final bool showPremiumBadge;
  final bool feeIsFree;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280.w,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8.r,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 160.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(color: AppColors.surfaceContainerHigh),
                ),
                if (showPremiumBadge)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        context.l10n.premium,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.manrope(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 16.sp,
                            color: AppColors.secondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            rating,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 18.sp, color: AppColors.onSurfaceVariant),
                        SizedBox(width: 4.w),
                        Text(
                          time,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      fee,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: feeIsFree ? FontWeight.w700 : FontWeight.w400,
                        color: feeIsFree ? AppColors.secondary : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightsSection extends StatelessWidget {
  const _HighlightsSection();

  static final TextStyle _sectionTitleStyle = GoogleFonts.manrope(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    letterSpacing: -0.2,
    color: AppColors.primary,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.deliveryHighlightsTitle, style: _sectionTitleStyle),
        SizedBox(height: 16.h),
        _HighlightCard(
          imageUrl: AppAssets.deliveryAsparagusImage,
          tag: context.l10n.promotion,
          tagColor: AppColors.secondary,
          tagBackground: AppColors.secondaryContainer.withValues(alpha: 0.1),
          title: 'Aspargos Biológicos',
          subtitle: 'Maço de 250g - Local',
          price: '€3.49',
          oldPrice: '€4.99',
        ),
        SizedBox(height: 16.h),
        _HighlightCard(
          imageUrl: AppAssets.deliveryChocolateImage,
          tag: context.l10n.newBadge,
          tagColor: AppColors.onPrimaryContainer,
          tagBackground: AppColors.primaryFixed.withValues(alpha: 0.3),
          title: 'Chocolate Negro 85%',
          subtitle: 'Origem Única - 100g',
          price: '€5.20',
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.imageUrl,
    required this.tag,
    required this.tagColor,
    required this.tagBackground,
    required this.title,
    required this.subtitle,
    required this.price,
    this.oldPrice,
  });

  static double get _imageSize => 96.w;
  static double get _cardRadius => 16.r;
  static double get _imageRadius => 12.r;

  final String imageUrl;
  final String tag;
  final Color tagColor;
  final Color tagBackground;
  final String title;
  final String subtitle;
  final String price;
  final String? oldPrice;

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.manrope(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      height: 24 / 18,
      letterSpacing: -0.15,
      color: AppColors.primary,
    );
    final subtitleStyle = GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      height: 20 / 14,
      color: AppColors.onSurfaceVariant,
    );
    final priceStyle = GoogleFonts.manrope(
      fontSize: 18.sp,
      fontWeight: FontWeight.w700,
      height: 24 / 18,
      letterSpacing: -0.2,
      color: AppColors.primary,
    );
    final oldPriceStyle = GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      height: 20 / 14,
      decoration: TextDecoration.lineThrough,
      decorationColor: AppColors.outline,
      color: AppColors.outline,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(_cardRadius),
        splashColor: AppColors.secondary.withValues(alpha: 0.08),
        highlightColor: AppColors.secondary.withValues(alpha: 0.04),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(_cardRadius),
            border: Border.all(
              color: AppColors.surfaceContainerLow,
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 2.r,
                offset: Offset(0, 1.h),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 16.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_imageRadius),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_imageRadius),
                    child: Image.network(
                      imageUrl,
                      width: _imageSize,
                      height: _imageSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          ColoredBox(
                        color: AppColors.surfaceContainerHigh,
                        child: SizedBox(
                          width: _imageSize,
                          height: _imageSize,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: tagBackground,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            height: 16 / 12,
                            letterSpacing: 0.2,
                            color: tagColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: subtitleStyle,
                      ),
                      SizedBox(height: 10.h),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(price, style: priceStyle),
                          if (oldPrice != null)
                            Text(oldPrice!, style: oldPriceStyle),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.28),
                        blurRadius: 12.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Material(
                    color: AppColors.secondary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () {},
                      customBorder: const CircleBorder(),
                      child: SizedBox(width: 48.w,
                        height: 48.h,
                        child: Icon(
                          Icons.add_rounded,
                          color: AppColors.onSecondary,
                          size: 26.sp,
                        ),
                      ),
                    ),
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
