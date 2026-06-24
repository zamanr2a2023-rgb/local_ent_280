import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography with system fallbacks when Google Fonts CDN is unavailable (APK/offline).
abstract final class AppTypography {
  static const List<String> _fallbackFamilies = ['Roboto', 'sans-serif'];

  static TextStyle manrope({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.manrope(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
      letterSpacing: letterSpacing,
    ).copyWith(fontFamilyFallback: _fallbackFamilies);
  }

  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
      letterSpacing: letterSpacing,
    ).copyWith(fontFamilyFallback: _fallbackFamilies);
  }
}
