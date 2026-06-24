import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';

/// Client: Home, Trips, Balance, Profile. Driver: Home, Trips, Profile.
enum AppBottomNavMode { full, driver }

/// Shared bottom navigation — same layout on every tab/screen.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    this.onItemTap,
    this.mode = AppBottomNavMode.full,
  });

  /// For [AppBottomNavMode.full], uses [AppNavIndex]. Driver mode: 0 Home, 1 Trips, 2 Profile.
  final int selectedIndex;
  final ValueChanged<int>? onItemTap;
  final AppBottomNavMode mode;

  static const _fullIcons = [
    Icons.home,
    Icons.directions_car,
    Icons.account_balance_wallet,
    Icons.person,
  ];

  static const _driverIcons = [
    Icons.home,
    Icons.directions_car,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDriver = mode == AppBottomNavMode.driver;
    final icons = isDriver ? _driverIcons : _fullIcons;
    final labels = isDriver
        ? [l10n.navHome, l10n.navTrips, l10n.navProfile]
        : [
            l10n.navHome,
            l10n.navTrips,
            l10n.navBalance,
            l10n.navProfile,
          ];
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12.r,
            spreadRadius: 0,
            offset: Offset(0, -2.h),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 24.r,
            spreadRadius: 0,
            offset: Offset(0, -8.h),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppLayout.gutter,
        6.h,
        AppLayout.gutter,
        6.h + bottomPadding,
      ),
      child: Row(
        children: List.generate(icons.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onItemTap?.call(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: AppLayout.bottomNavIconSlot,
                    height: AppLayout.bottomNavIconSlot,
                    alignment: Alignment.center,
                    decoration: isSelected
                        ? const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: Icon(
                      icons[index],
                      size: 22.sp,
                      color: isSelected
                          ? AppColors.onAccent
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    labels[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
