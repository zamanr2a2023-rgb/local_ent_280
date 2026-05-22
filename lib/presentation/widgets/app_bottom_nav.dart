import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';

/// Shared bottom navigation — same layout on every tab/screen.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    this.onItemTap,
  });

  final int selectedIndex;
  final ValueChanged<int>? onItemTap;

  static const _items = [
    (Icons.home, 'Início'),
    (Icons.directions_car, 'Viagens'),
    (Icons.calendar_today, 'Reservas'),
    (Icons.person, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16.r,
            offset: Offset(0, -4.h),
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
        children: List.generate(_items.length, (index) {
          final item = _items[index];
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
                      item.$1,
                      size: 22.sp,
                      color: isSelected
                          ? AppColors.onAccent
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.$2,
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
