import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/constants/app_assets.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/presentation/widgets/app_bottom_nav.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

    static double get _heroHeight => 300.h;
  static double get _cardRadius => 16.r;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 72.h + MediaQuery.paddingOf(context).bottom,
        ),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.secondaryContainer,
          foregroundColor: AppColors.onSecondaryContainer,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.add_location_alt, size: 28.sp),
        ),
      ),
      body: Column(
        children: [
          const _DiscoverAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.marginMobile,
                    ),
                    child: _DiscoverHero(),
                  ),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.marginMobile,
                    ),
                    child: _SearchFilterBar(),
                  ),
                  SizedBox(height: 32.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.marginMobile,
                    ),
                    child: _ExperiencesSection(),
                  ),
                  SizedBox(height: 32.h),
                  const _EventsSection(),
                  SizedBox(height: 32.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.marginMobile,
                    ),
                    child: _InteractiveMapSection(),
                  ),
                ],
              ),
            ),
          ),
          AppBottomNav(
            selectedIndex: AppNavIndex.inicio,
            onItemTap: (index) => AppNavigation.onBottomNavTap(context, index),
          ),
        ],
      ),
    );
  }
}

class _DiscoverAppBar extends StatelessWidget {
  const _DiscoverAppBar();

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
              onPressed: () {},
              icon: const Icon(Icons.menu, color: AppColors.primary),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
            ),
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
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outlineVariant),
                color: AppColors.surfaceContainerHigh,
              ),
              child: ClipOval(
                child: Image.network(
                  AppAssets.discoverProfileAvatarImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    size: 18.sp,
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

class _DiscoverHero extends StatelessWidget {
  const _DiscoverHero();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DiscoverScreen._cardRadius),
      child: SizedBox(
        height: DiscoverScreen._heroHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              AppAssets.discoverHeroImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: AppColors.primary.withValues(alpha: 0.3),
                child: Icon(
                  Icons.beach_access,
                  color: Colors.white54,
                  size: 48.sp,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.55),
                    AppColors.primary.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      context.l10n.discoverSummerHighlight,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    context.l10n.discoverHeroTitle,
                    style: GoogleFonts.manrope(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    context.l10n.discoverHeroSubtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                      color: AppColors.primaryFixedDim,
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

class _SearchFilterBar extends StatelessWidget {
  const _SearchFilterBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(DiscoverScreen._cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  size: 22.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: context.l10n.discoverSearchHint,
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.onSurfaceVariant,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Flexible(
                flex: 2,
                child: SizedBox(height: 48.h,
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.tune_rounded, size: 20.sp),
                    label: Text(
                      context.l10n.discoverFilters,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.onSurface,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Flexible(
                flex: 3,
                child: SizedBox(height: 48.h,
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      context.l10n.discoverExploreMap,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _ExperiencesSection extends StatelessWidget {
  const _ExperiencesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                context.l10n.discoverExperiencesTitle,
                style: GoogleFonts.manrope(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  height: 28 / 20,
                  color: AppColors.primary,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.seeAll,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                      color: AppColors.secondary,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 18.sp,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        _ExperienceCard(
          imageUrl: AppAssets.discoverRestaurantImage,
          category: context.l10n.discoverCategoryGastronomy,
          title: context.l10n.discoverExperienceRestaurants,
          height: 200.h,
        ),
        SizedBox(height: 16.h),
        _ExperienceCard(
          imageUrl: AppAssets.discoverPlacesImage,
          category: context.l10n.discoverCategoryExploration,
          title: context.l10n.discoverExperienceSecretSpots,
          height: 160.h,
        ),
      ],
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.height,
  });

  final String imageUrl;
  final String category;
  final String title;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: AppColors.surfaceContainerHigh),
            ),
            ColoredBox(color: Colors.black.withValues(alpha: 0.3)),
            Positioned(
              left: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: AppColors.primaryFixedDim,
                    ),
                  ),
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                      height: 32 / 24,
                      color: Colors.white,
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

class _EventsSection extends StatelessWidget {
  const _EventsSection();

  static const _events = [
    (
      image: AppAssets.discoverEventSunsetImage,
      day: '15',
      month: 'AGO',
      venue: 'Blue Horizon Beach Club',
      title: 'Sunset Ritual: Deep House',
      description:
          'Uma jornada musical inesquecível enquanto o sol se põe sobre o mar.',
      price: '45,00€',
    ),
    (
      image: AppAssets.discoverEventJazzImage,
      day: '18',
      month: 'AGO',
      venue: 'Palácio das Oliveiras',
      title: 'Noites de Jazz & Vinho',
      description:
          'Degustação premium acompanhada pelo melhor jazz contemporâneo.',
      price: '30,00€',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppLayout.marginMobile,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  context.l10n.discoverUpcomingEvents,
                  style: GoogleFonts.manrope(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    height: 28 / 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Row(
                children: [
                  _CircleNavButton(icon: Icons.chevron_left, onTap: () {}),
                  SizedBox(width: 4.w),
                  _CircleNavButton(icon: Icons.chevron_right, onTap: () {}),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: AppLayout.marginMobile,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < _events.length; i++) ...[
                if (i > 0) SizedBox(width: 24.w),
                Builder(
                  builder: (context) {
                    final event = _events[i];
                    return _EventCard(
                      imageUrl: event.image,
                      day: event.day,
                      month: event.month,
                      venue: event.venue,
                      title: event.title,
                      description: event.description,
                      price: event.price,
                      onTickets: () {
                        AppNavigation.toEventBooking(context);
                      },
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

class _CircleNavButton extends StatelessWidget {
  const _CircleNavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22.sp),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.imageUrl,
    required this.day,
    required this.month,
    required this.venue,
    required this.title,
    required this.description,
    required this.price,
    required this.onTickets,
  });

  final String imageUrl;
  final String day;
  final String month;
  final String venue;
  final String title;
  final String description;
  final String price;
  final VoidCallback onTickets;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.w,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.surfaceContainer),
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
          SizedBox(height: 192.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(color: AppColors.surfaceContainerHigh),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          day,
                          style: GoogleFonts.manrope(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          month,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
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
                    Icon(
                      Icons.location_on,
                      size: 18.sp,
                      color: AppColors.secondary,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        venue,
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
                SizedBox(height: 8.h),
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    height: 28 / 20,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Text(
                      price,
                      style: GoogleFonts.manrope(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: FilledButton(
                        onPressed: onTickets,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.secondaryContainer,
                          foregroundColor: AppColors.onSecondaryContainer,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                context.l10n.discoverTickets,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(Icons.confirmation_number, size: 18.sp),
                          ],
                        ),
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

class _InteractiveMapSection extends StatelessWidget {
  const _InteractiveMapSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.discoverInteractiveMapTitle,
          style: GoogleFonts.manrope(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            height: 28 / 20,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          context.l10n.discoverInteractiveMapSubtitle,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 24.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: SizedBox(height: 400.h,
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
                    0.95,
                    0,
                  ]),
                  child: Image.network(
                    AppAssets.discoverIslandMapImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const ColoredBox(color: AppColors.surfaceContainerHigh),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Column(
                    children: [
                      _MapControlButton(icon: Icons.add, onTap: () {}),
                      SizedBox(height: 8.h),
                      _MapControlButton(icon: Icons.remove, onTap: () {}),
                    ],
                  ),
                ),
                Positioned(
                  left: MediaQuery.sizeOf(context).width * 0.22,
                  top: 120,
                  child: _MapMarker(
                    label: 'Restaurante Maré',
                    color: AppColors.primary,
                  ),
                ),
                Positioned(
                  right: MediaQuery.sizeOf(context).width * 0.28,
                  bottom: 100,
                  child: _MapMarker(
                    label: 'Praia Secreta',
                    color: AppColors.secondary,
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.my_location, size: 20.sp),
                    label: Text(
                      context.l10n.discoverCurrentLocation,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: EdgeInsets.symmetric(horizontal: 24.w,
                        vertical: 8,
                      ),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.r),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(width: 48.w,
          height: 48.h,
          child: Icon(icon, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8.r,
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: color == AppColors.primary
                  ? AppColors.onPrimary
                  : AppColors.onSecondary,
            ),
          ),
        ),
        Icon(Icons.location_on, color: color, size: 36.sp),
      ],
    );
  }
}
