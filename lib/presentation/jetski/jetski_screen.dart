import 'dart:ui';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/constants/app_assets.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/presentation/widgets/app_bottom_nav.dart';

class JetskiScreen extends StatelessWidget {
  const JetskiScreen({super.key});

    static double get _heroHeight => 320.h;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _JetskiAppBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _JetskiHero(),
                  Transform.translate(
                    offset: Offset(0, -48.h),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppLayout.marginMobile,
                      ),
                      child: _SearchFilterCard(),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.marginMobile,
                    ),
                    child: _FleetSection(),
                  ),
                  SizedBox(height: 32.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.marginMobile,
                    ),
                    child: _SafetySection(),
                  ),
                  SizedBox(height: 32.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.marginMobile,
                    ),
                    child: _MarinaSection(),
                  ),
                  SizedBox(height: 24.h),
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

class _JetskiAppBar extends StatelessWidget {
  const _JetskiAppBar();

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
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Mobilidade Premium',
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
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outlineVariant),
                color: AppColors.surfaceContainerHigh,
              ),
              child: ClipOval(
                child: Image.network(
                  AppAssets.jetskiProfileAvatarImage,
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

class _JetskiHero extends StatelessWidget {
  const _JetskiHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: JetskiScreen._heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            AppAssets.jetskiHeroImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => ColoredBox(
              color: AppColors.primary.withValues(alpha: 0.4),
              child: Icon(Icons.waves, color: Colors.white54, size: 48.sp),
            ),
          ),
          ColoredBox(color: AppColors.primary.withValues(alpha: 0.4)),
          Positioned(
            left: AppLayout.marginMobile,
            right: AppLayout.marginMobile,
            bottom: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    'Aventura no Mar',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Domine as Ondas',
                  style: GoogleFonts.manrope(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    height: 40 / 32,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Aluguer premium de motas de água de alta performance.',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    height: 24 / 16,
                    color: Colors.white.withValues(alpha: 0.9),
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

class _SearchFilterCard extends StatelessWidget {
  const _SearchFilterCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 32.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.outline,
                      size: 22.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DURAÇÃO',
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppColors.outline,
                            ),
                          ),
                          Text(
                            '1 Hora — Passeio Rápido',
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
                    const Icon(Icons.expand_more, color: AppColors.outline),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(height: 48.h,
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, size: 20.sp),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                'Explorar Frota',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SizedBox(width: 48.w,
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: const BorderSide(color: AppColors.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: const Icon(Icons.tune, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FleetSection extends StatelessWidget {
  const _FleetSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nossa Frota',
              style: GoogleFonts.manrope(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                height: 28 / 20,
                color: AppColors.primary,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Ver todos',
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
        _FleetCard(
          imageUrl: AppAssets.jetskiYamahaImage,
          title: 'Yamaha GP1800R',
          price: '120',
          description: 'Performance extrema para pilotos experientes.',
          rating: '4.9',
          tags: const ['3 LUGARES', 'SUPERCHARGED'],
          primaryLabel: 'Reservar Agora',
          isPrimaryFilled: true,
          onPrimaryTap: () => AppNavigation.openEventBooking(context),
        ),
        SizedBox(height: 16.h),
        _FleetCard(
          imageUrl: AppAssets.jetskiSeaDooImage,
          title: 'Sea-Doo Spark Trixx',
          price: '85',
          description: 'Agilidade e diversão para manobras leves.',
          primaryLabel: 'Ver Detalhes',
          isPrimaryFilled: false,
          onPrimaryTap: () {},
        ),
      ],
    );
  }
}

class _FleetCard extends StatelessWidget {
  const _FleetCard({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.description,
    required this.primaryLabel,
    required this.isPrimaryFilled,
    required this.onPrimaryTap,
    this.rating,
    this.tags = const [],
  });

  final String imageUrl;
  final String title;
  final String price;
  final String description;
  final String? rating;
  final List<String> tags;
  final String primaryLabel;
  final bool isPrimaryFilled;
  final VoidCallback onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 4.r,
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
                if (rating != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 14.sp,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            rating!,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.manrope(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          height: 28 / 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$price€',
                            style: GoogleFonts.manrope(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                          TextSpan(
                            text: '/h',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    height: 24 / 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (tags.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags
                        .map(
                          (tag) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.w,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              tag,
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.outline,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                SizedBox(height: 16.h),
                SizedBox(height: 40.h,
                  child: isPrimaryFilled
                      ? FilledButton(
                          onPressed: onPrimaryTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            primaryLabel,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                          ),
                        )
                      : OutlinedButton(
                          onPressed: onPrimaryTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                            side: const BorderSide(color: AppColors.secondary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            primaryLabel,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
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

class _SafetySection extends StatelessWidget {
  const _SafetySection();

  static const _items = [
    (
      title: 'Colete Salva-vidas Incluído',
      subtitle: 'Equipamento homologado para todos os pesos.',
    ),
    (
      title: 'Briefing de Segurança',
      subtitle: 'Instrução obrigatória de 15 min antes da partida.',
    ),
    (
      title: 'Monitorização GPS',
      subtitle: 'Equipa de apoio pronta para intervir 24/7.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield,
                color: AppColors.secondaryFixed,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Segurança Primeiro',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    height: 28 / 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          ..._items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.secondaryFixed,
                    size: 24.sp,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            height: 20 / 14,
                            letterSpacing: 0.1,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          item.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            height: 16 / 12,
                            color: AppColors.onTertiaryContainer,
                          ),
                        ),
                      ],
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

class _MarinaSection extends StatelessWidget {
  const _MarinaSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Nossa Base',
          style: GoogleFonts.manrope(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            height: 28 / 20,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 16.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: SizedBox(height: 192.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  AppAssets.jetskiMarinaImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(color: AppColors.surfaceContainerHigh),
                ),
                ColoredBox(color: Colors.black.withValues(alpha: 0.1)),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
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
              ],
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marina de Vilamoura',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                      letterSpacing: 0.1,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Cais 4, Lote B, 8125-401 Quarteira',
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
            GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Abrir Mapa',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.open_in_new,
                    size: 16.sp,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
