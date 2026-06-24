import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';

Future<bool> showAdminAssignDriverSheet(
  BuildContext context, {
  required AdminVehicleRecord vehicle,
  required List<AdminUserRecord> drivers,
  required Future<void> Function(String driverId) onAssign,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (context) => _AdminAssignDriverSheet(
      vehicle: vehicle,
      drivers: drivers,
      onAssign: onAssign,
    ),
  );
  return result ?? false;
}

class _AdminAssignDriverSheet extends StatefulWidget {
  const _AdminAssignDriverSheet({
    required this.vehicle,
    required this.drivers,
    required this.onAssign,
  });

  final AdminVehicleRecord vehicle;
  final List<AdminUserRecord> drivers;
  final Future<void> Function(String driverId) onAssign;

  @override
  State<_AdminAssignDriverSheet> createState() => _AdminAssignDriverSheetState();
}

class _AdminAssignDriverSheetState extends State<_AdminAssignDriverSheet> {
  bool _submitting = false;
  String? _error;

  Future<void> _assign(String driverId) async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.onAssign(driverId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.55;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppLayout.marginMobile,
          AppLayout.lg,
          AppLayout.marginMobile,
          AppLayout.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.adminFleetAssignDriverTitle,
                    style: AppTypography.manrope(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(
              l10n.adminFleetAssignDriverDesc,
              style: AppTypography.inter(
                fontSize: 14.sp,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppLayout.sm),
            Text(
              widget.vehicle.label,
              style: AppTypography.manrope(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            if (_submitting) ...[
              SizedBox(height: AppLayout.md),
              const LinearProgressIndicator(),
            ],
            if (_error != null) ...[
              SizedBox(height: AppLayout.sm),
              Text(_error!, style: TextStyle(color: AppColors.error)),
            ],
            SizedBox(height: AppLayout.md),
            if (widget.drivers.isEmpty)
              Text(l10n.adminFleetAssignDriverEmpty)
            else
              SizedBox(
                height: maxHeight,
                child: ListView.separated(
                  itemCount: widget.drivers.length,
                  separatorBuilder: (_, __) => SizedBox(height: AppLayout.sm),
                  itemBuilder: (context, index) {
                    final driver = widget.drivers[index];
                    final isSelected =
                        driver.id == widget.vehicle.assignedDriverId;
                    return Material(
                      color: AppColors.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                        ),
                      ),
                      child: InkWell(
                        onTap: _submitting ? null : () => _assign(driver.id),
                        borderRadius: BorderRadius.circular(12.r),
                        child: Padding(
                          padding: EdgeInsets.all(AppLayout.md),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driver.name.isNotEmpty
                                          ? driver.name
                                          : driver.email,
                                      style: AppTypography.inter(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (driver.email.isNotEmpty)
                                      Text(
                                        driver.email,
                                        style: AppTypography.inter(
                                          fontSize: 12.sp,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
