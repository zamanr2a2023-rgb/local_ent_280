import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/features/trips/data/models/trip_cancellation.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';

/// Shows the client's cancellation reason, then returns the driver to home.
Future<void> showDriverTripCancelledByClientDialog(
  BuildContext context, {
  required TripRecord trip,
}) async {
  final l10n = context.l10n;
  final reason = TripCancellationLabels.displayReason(
    trip.cancellation?.reason,
    l10n,
  );

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.driverTripCancelledTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.driverTripCancelledBody,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.driverTripCancelledReasonLabel,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: AppColors.labelMuted,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              reason,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.driverTripCancelledAcknowledge),
          ),
        ],
      );
    },
  );

  if (!context.mounted) return;
  AppNavigation.toDriverHome(context);
}
