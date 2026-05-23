import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Preloads fonts before first frame so debug APK matches `flutter run` on device.
abstract final class AppFonts {
  static Future<void> ensureLoaded() async {
    GoogleFonts.config.allowRuntimeFetching = true;
    try {
      await Future.wait<void>([
        GoogleFonts.pendingFonts([
          GoogleFonts.manrope(fontWeight: FontWeight.w400),
          GoogleFonts.manrope(fontWeight: FontWeight.w600),
          GoogleFonts.manrope(fontWeight: FontWeight.w700),
          GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ]),
        GoogleFonts.pendingFonts([
          GoogleFonts.inter(fontWeight: FontWeight.w400),
          GoogleFonts.inter(fontWeight: FontWeight.w500),
          GoogleFonts.inter(fontWeight: FontWeight.w600),
          GoogleFonts.inter(fontWeight: FontWeight.w700),
        ]),
      ]);
    } catch (_) {
      // Offline install: AppTypography fallbacks still render text.
    }
  }
}
