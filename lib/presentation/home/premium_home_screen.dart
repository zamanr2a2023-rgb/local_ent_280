import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:local_ent_280/core/constants/app_assets.dart';
import 'package:local_ent_280/core/data/premium_search_items.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/presentation/widgets/app_bottom_nav.dart';
import 'package:local_ent_280/presentation/widgets/client_drawer.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/features/catalog/data/catalog_repository.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';

/// Local Transport — Início (app_details/details.md).
class PremiumHomeScreen extends StatefulWidget {
  const PremiumHomeScreen({super.key});

  
  @override
  State<PremiumHomeScreen> createState() => _PremiumHomeScreenState();
}

class _PremiumHomeScreenState extends State<PremiumHomeScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  List<PremiumSearchItem> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchResults = PremiumSearchItems.filter(_searchController.text);
    });
  }

  void _onSearchResultTap(PremiumSearchItem item) {
    _searchFocusNode.unfocus();
    AppNavigation.toReservationReview(context);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const ClientDrawer(selected: ClientDrawerSection.home),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 72.h + bottomInset),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          elevation: 8,
          child: Icon(Icons.add, size: 32.sp),
        ),
      ),
      body: Column(
        children: [
          const _PremiumHomeAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppLayout.marginMobile,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 24.h),
                    _HeroSearchSection(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      results: _searchResults,
                      onResultTap: _onSearchResultTap,
                    ),
                    SizedBox(height: 48.h),
                    _BentoServicesSection(
                      onDelivery: () => AppNavigation.toDelivery(context),
                      onIslandGuide: () => AppNavigation.toDiscover(context),
                      onJetski: () => AppNavigation.toJetskiRental(context),
                    ),
                    SizedBox(height: 48.h),
                    _TransportSection(
                      onTrip: () => AppNavigation.toTripMap(context),
                    ),
                    SizedBox(height: 32.h),
                    _ExperiencesSection(
                      onJetskiCard: () => AppNavigation.toJetskiRental(context),
                      onIslandCard: () => AppNavigation.toDiscover(context),
                    ),
                  ],
                ),
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

class _PremiumHomeAppBar extends StatelessWidget {
  const _PremiumHomeAppBar();

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
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu, color: AppColors.primary),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                context.l10n.appNameLocalTransport,
                style: GoogleFonts.manrope(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  height: 32 / 24,
                  color: AppColors.primary,
                ),
              ),
            ),
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryContainer,
                  width: 2.w,
                ),
                color: AppColors.surfaceContainerHigh,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                AppAssets.premiumHomeProfileAvatarImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person,
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

class _HeroSearchSection extends StatelessWidget {
  const _HeroSearchSection({
    required this.controller,
    required this.focusNode,
    required this.results,
    required this.onResultTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<PremiumSearchItem> results;
  final ValueChanged<PremiumSearchItem> onResultTap;

  static final _cardShadow = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.04),
      blurRadius: 8.r,
      offset: Offset(0, 2.h),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final hasQuery = controller.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.homeWhereToday,
          style: GoogleFonts.manrope(
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
            height: 40 / 32,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.surfaceContainer),
            boxShadow: _cardShadow,
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.secondary, size: 24.sp),
              SizedBox(width: 16.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    height: 24 / 16,
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: context.l10n.premiumHomeSearchHint,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: AppColors.outline,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (hasQuery)
                GestureDetector(
                  onTap: () {
                    controller.clear();
                    focusNode.unfocus();
                  },
                  child: Icon(
                    Icons.close,
                    size: 20.sp,
                    color: AppColors.outline,
                  ),
                ),
            ],
          ),
        ),
        if (hasQuery) ...[
          SizedBox(height: 8.h),
          Material(
            elevation: 4,
            shadowColor: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r),
            color: AppColors.surfaceContainerLowest,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: results.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        context.l10n.premiumHomeNoResults,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      itemCount: results.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1.0,
                        indent: 56,
                        color: AppColors.surfaceContainer,
                      ),
                      itemBuilder: (context, index) {
                        final item = results[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.directions_car,
                            color: AppColors.secondary,
                          ),
                          title: Text(
                            item.title,
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          subtitle: Text(
                            item.subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          onTap: () => onResultTap(item),
                        );
                      },
                    ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BentoServicesSection extends StatelessWidget {
  const _BentoServicesSection({
    required this.onDelivery,
    required this.onIslandGuide,
    required this.onJetski,
  });

  final VoidCallback onDelivery;
  final VoidCallback onIslandGuide;
  final VoidCallback onJetski;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DeliveryPromoCard(onTap: onDelivery),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _ServiceTileCard(
                icon: Symbols.explore,
                label: context.l10n.premiumHomeIslandGuide,
                onTap: onIslandGuide,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _ServiceTileCard(
                icon: Symbols.water_ec,
                label: context.l10n.premiumHomeJetski,
                onTap: onJetski,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DeliveryPromoCard extends StatelessWidget {
  const _DeliveryPromoCard({required this.onTap});

  static double get _height => 160.h;
  static double get _radius => 12.r;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: Ink(
          height: _height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(_radius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.premiumHomeFastDelivery,
                            style: GoogleFonts.manrope(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              height: 28 / 20,
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            context.l10n.premiumHomeGroceryPharmacy,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              height: 20 / 14,
                              letterSpacing: 0.1,
                              color: AppColors.onPrimaryContainer.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Material(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(999.r),
                        child: InkWell(
                          onTap: onTap,
                          borderRadius: BorderRadius.circular(999.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w,
                              vertical: 4,
                            ),
                            child: Text(
                              context.l10n.premiumHomeOrderNow,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                height: 20 / 14,
                                letterSpacing: 0.1,
                                color: AppColors.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: -16,
                  bottom: -16,
                  child: Icon(
                    Icons.shopping_basket_outlined,
                    size: 120.sp,
                    color: AppColors.onPrimaryContainer.withValues(alpha: 0.1),
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

class _ServiceTileCard extends StatelessWidget {
  const _ServiceTileCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Ink(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.surfaceContainer),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56.w,
                height: 56.h,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32.sp,
                  color: AppColors.secondary,
                  weight: 400,
                  grade: 0,
                  opticalSize: 24,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  letterSpacing: 0.1,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransportSection extends StatelessWidget {
  const _TransportSection({required this.onTrip});

  final VoidCallback onTrip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final modes = [
      (Icons.directions_car, l10n.premiumHomeTransportTrip),
      (Icons.two_wheeler, l10n.premiumHomeTransportMoto),
      (Icons.electric_scooter, l10n.premiumHomeTransportScooter),
      (Icons.pedal_bike, l10n.premiumHomeTransportBike),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.premiumHomeTransportTitle,
                style: GoogleFonts.manrope(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  height: 28 / 20,
                  color: AppColors.primary,
                ),
              ),
            ),
            Text(
              context.l10n.seeAll,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                height: 20 / 14,
                letterSpacing: 0.1,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            for (var index = 0; index < modes.length; index++) ...[
              if (index > 0) SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Material(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12.r),
                        child: InkWell(
                          onTap: index == 0 ? onTrip : () {},
                          borderRadius: BorderRadius.circular(12.r),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.04,
                                  ),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                modes[index].$1,
                                size: 28.sp,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      modes[index].$2,
                      textAlign: TextAlign.center,
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
          ],
        ),
      ],
    );
  }
}

class _ExperiencesSection extends StatelessWidget {
  const _ExperiencesSection({
    required this.onJetskiCard,
    required this.onIslandCard,
  });

  final VoidCallback onJetskiCard;
  final VoidCallback onIslandCard;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int?>(
      stream: CatalogRepository().watchCheapestPackageMinor(),
      builder: (context, snapshot) {
        final formatter = AppCurrencyFormatter.instance;
        final fromPrice = snapshot.data == null
            ? null
            : context.l10n.premiumHomeFromPrice(
                formatter.formatEurMinor(snapshot.data!),
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.premiumHomeExperiencesTitle,
              style: GoogleFonts.manrope(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                height: 28 / 20,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 422.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                children: [
                  _ExperienceCard(
                    imageUrl: AppAssets.premiumHomeJetskiExperienceImage,
                    badge: context.l10n.newBadge,
                    title: context.l10n.premiumHomeJetskiRentalTitle,
                    description: context.l10n.premiumHomeJetskiRentalDesc,
                    footer: fromPrice ?? '—',
                    onTap: onJetskiCard,
                  ),
                  SizedBox(width: 16.w),
                  _ExperienceCard(
                    imageUrl: AppAssets.premiumHomeIslandExperienceImage,
                    title: context.l10n.premiumHomeIslandGuideTitle,
                    description: context.l10n.premiumHomeIslandGuideDesc,
                    footer: context.l10n.discoverExploreMap,
                    onTap: onIslandCard,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.footer,
    required this.onTap,
    this.badge,
  });

  final String imageUrl;
  final String? badge;
  final String title;
  final String description;
  final String footer;
  final VoidCallback onTap;

  static double get _cardWidth => 288.w;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _cardWidth,
      child: Material(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 210.h,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(
                        color: AppColors.surfaceContainerHigh,
                      ),
                    ),
                    if (badge != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            badge!,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              height: 16 / 12,
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
                        fontWeight: FontWeight.w400,
                        height: 24 / 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            footer,
                            style: GoogleFonts.manrope(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              height: 28 / 20,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: AppColors.secondary,
                          size: 24.sp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
