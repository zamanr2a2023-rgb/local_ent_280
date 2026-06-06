import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/constants/app_assets.dart';
import 'package:local_ent_280/core/data/driver_search_data.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';

/// A procurar motorista disponível — `roles/details.md`.
class DriverSearchScreen extends StatefulWidget {
  const DriverSearchScreen({super.key});

  @override
  State<DriverSearchScreen> createState() => _DriverSearchScreenState();
}

class _DriverSearchScreenState extends State<DriverSearchScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _foundNavigationTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _foundNavigationTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      AppNavigation.toDriverFound(context);
    });
  }

  @override
  void dispose() {
    _foundNavigationTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainer,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _MapBackground(),
          _PulsingCarMarker(animation: _pulseController),
          Positioned(
            top: topInset + 8.h,
            left: 0,
            right: 0,
            child: _FloatingHeader(
              onBack: () => AppNavigation.back(context),
            ),
          ),
          Positioned(
            top: topInset + 64.h,
            left: 0,
            right: 0,
            child: const _StatusToast(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _SearchBottomSheet(
              onCancel: () {
                _foundNavigationTimer?.cancel();
                AppNavigation.cancelToTripDestination(context);
              },
            ),
          ),
        ],
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
        ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0, 0, 0, 0.6, 0,
          ]),
          child: Image.network(
            AppAssets.driverSearchMapImage,
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
                Colors.black.withValues(alpha: 0.25),
                Colors.transparent,
                AppColors.surfaceContainerLowest.withValues(alpha: 0.15),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _PulsingCarMarker extends StatelessWidget {
  const _PulsingCarMarker({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final t = animation.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              _PulseRing(
                size: 128.w,
                opacity: 0.2 * (1 - t),
                scale: 0.7 + t * 0.5,
              ),
              _PulseRing(
                size: 80.w,
                opacity: 0.1 * (1 - ((t + 0.5) % 1.0)),
                scale: 0.7 + ((t + 0.5) % 1.0) * 0.5,
              ),
              child!,
            ],
          );
        },
        child: Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.surfaceContainerLowest,
              width: 4.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Icon(
            Icons.directions_car,
            color: AppColors.onPrimary,
            size: 24.sp,
          ),
        ),
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({
    required this.size,
    required this.opacity,
    required this.scale,
  });

  final double size;
  final double opacity;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondary.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

class _FloatingHeader extends StatelessWidget {
  const _FloatingHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
      child: Row(
        children: [
          Material(
            color: AppColors.surfaceContainerLowest,
            shape: const CircleBorder(),
            elevation: 4,
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Icon(Icons.arrow_back, color: AppColors.primary, size: 22.sp),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Text(
                  context.l10n.appNameLocalTransport,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }
}

class _StatusToast extends StatefulWidget {
  const _StatusToast();

  @override
  State<_StatusToast> createState() => _StatusToastState();
}

class _StatusToastState extends State<_StatusToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pingController;

  @override
  void initState() {
    super.initState();
    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _pingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
            SizedBox(
              width: 8.w,
              height: 8.h,
              child: AnimatedBuilder(
                animation: _pingController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 8.w + _pingController.value * 6,
                        height: 8.h + _pingController.value * 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.secondary.withValues(
                            alpha: 0.4 * (1 - _pingController.value),
                          ),
                        ),
                      ),
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(width: 8.w),
                Text(
                  context.l10n.driverSearchOptimizing,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onPrimary,
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

class _SearchBottomSheet extends StatelessWidget {
  const _SearchBottomSheet({required this.onCancel});

  final VoidCallback onCancel;

  static double get _radius => 24.r;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h + bottomInset),
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 32.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 6.h,
            margin: EdgeInsets.only(bottom: 24.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
          Text(
            context.l10n.driverSearchTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              height: 32 / 24,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            context.l10n.driverSearchSubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              height: 24 / 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 24.h),
          const _ProgressSegments(),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  label: context.l10n.driverSearchOrigin,
                  value: DriverSearchData.originShort,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _InfoBox(
                  label: context.l10n.driverSearchEstimate,
                  value: DriverSearchData.estimate,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 56.h,
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onCancel,
              icon: Icon(Icons.close, size: 20.sp, color: AppColors.primary),
              label: Text(
                context.l10n.driverSearchCancelTrip,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: AppColors.primary,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerHigh,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSegments extends StatefulWidget {
  const _ProgressSegments();

  @override
  State<_ProgressSegments> createState() => _ProgressSegmentsState();
}

class _ProgressSegmentsState extends State<_ProgressSegments>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          children: [
            Expanded(
              child: _SegmentBar(
                color: AppColors.secondary,
                opacity: 0.85 + _controller.value * 0.15,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _SegmentBar(
                color: AppColors.secondary,
                opacity: 0.35 + _controller.value * 0.1,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _SegmentBar(
                color: AppColors.secondary,
                opacity: 0.12 + _controller.value * 0.08,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SegmentBar extends StatelessWidget {
  const _SegmentBar({required this.color, required this.opacity});

  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity.clamp(0.0, 1.0)),
        borderRadius: BorderRadius.circular(999.r),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
