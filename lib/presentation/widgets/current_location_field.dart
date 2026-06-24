import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';

/// Read-only field showing the user's GPS address (not manually editable).
class CurrentLocationField extends StatelessWidget {
  const CurrentLocationField({
    super.key,
    required this.address,
    required this.isLoading,
    required this.onRefresh,
    this.onMapTap,
  });

  final String? address;
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback? onMapTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayText = isLoading
        ? l10n.homeLocationLoading
        : (address?.trim().isNotEmpty == true
            ? address!.trim()
            : l10n.homeLocationUnavailable);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              Icons.my_location,
              color: AppColors.accent,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeCurrentLocation,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    color: AppColors.accent,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  displayText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.25,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: SizedBox(
                width: 18.w,
                height: 18.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              ),
            )
          else ...[
            if (onMapTap != null)
              IconButton(
                onPressed: onMapTap,
                icon: Icon(
                  Icons.map_outlined,
                  color: AppColors.accent,
                  size: 20.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                tooltip: l10n.homeSelectLocationOnMap,
              ),
            IconButton(
              onPressed: onRefresh,
              icon: Icon(
                Icons.refresh,
                color: AppColors.accent,
                size: 20.sp,
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
              tooltip: l10n.homeRefreshLocation,
            ),
          ],
        ],
      ),
    );
  }
}
