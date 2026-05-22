import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Design reference: 390×844 (details.md / widget tests).
abstract final class AppScreenUtil {
  static const Size designSize = Size(390, 844);

  static Widget init({required Widget child}) {
    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, appChild) => appChild ?? const SizedBox.shrink(),
      child: child,
    );
  }

  /// Wraps a widget for widget tests.
  static Widget testWrap(Widget child) {
    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      builder: (context, appChild) => MaterialApp(home: appChild),
      child: child,
    );
  }
}

/// Responsive spacing from design tokens.
abstract final class AppLayout {
  static double get marginMobile => 20.w;
  static double get gutter => 16.w;
  static double get unit => 4.w;
  static double get sm => 8.w;
  static double get md => 16.w;
  static double get lg => 24.w;
  static double get xl => 32.w;
  static double get xxl => 48.w;

  static double get appBarHeight => 56.h;
  static double get bottomNavIconSlot => 40.w;
  static double get fabBottomOffset => 72.h;
  static double get profileAvatarSm => 32.w;
  static double get profileAvatarMd => 40.w;
}

abstract final class AppRadius {
  static double get sm => 8.r;
  static double get md => 12.r;
  static double get lg => 16.r;
  static double get pill => 999.r;
}

/// Typography sizes (details.md scale).
abstract final class AppTextSize {
  static double get displayLg => 48.sp;
  static double get headlineLg => 32.sp;
  static double get headlineLgMobile => 28.sp;
  static double get headlineMd => 24.sp;
  static double get headlineSm => 20.sp;
  static double get bodyLg => 18.sp;
  static double get bodyMd => 16.sp;
  static double get labelLg => 14.sp;
  static double get labelSm => 12.sp;
  static double get iconMd => 24.sp;
  static double get iconLg => 32.sp;
}
