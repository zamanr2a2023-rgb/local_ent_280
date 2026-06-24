import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';

class AdminSupportTicketCard extends StatelessWidget {
  const AdminSupportTicketCard({
    super.key,
    required this.request,
    required this.onReply,
    this.onResolve,
  });

  final AdminSupportRequestRecord request;
  final VoidCallback onReply;
  final VoidCallback? onResolve;

  String _formatDate(DateTime? value) {
    if (value == null) return '—';
    return DateFormat('dd/MM/yyyy HH:mm').format(value.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isOpen = request.isOpen;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.surfaceVariant.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppLayout.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    request.displayName,
                    style: AppTypography.manrope(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      height: 1.25,
                    ),
                  ),
                ),
                SizedBox(width: AppLayout.sm),
                _StatusChip(
                  label: isOpen ? l10n.adminStatusOpen : l10n.adminStatusResolved,
                  isOpen: isOpen,
                ),
              ],
            ),
            SizedBox(height: AppLayout.sm),
            Text(
              '${request.role} · ${l10n.adminSupportRequestedAt(_formatDate(request.requestedAt))}',
              style: AppTypography.inter(
                fontSize: 12.sp,
                color: AppColors.labelMuted,
              ),
            ),
            if (request.subject.isNotEmpty) ...[
              SizedBox(height: AppLayout.sm),
              Text(
                request.subject,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
            if (request.message.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                request.message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.inter(
                  fontSize: 13.sp,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
            SizedBox(height: AppLayout.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReply,
                    icon: Icon(Icons.chat_bubble_outline, size: 18.sp),
                    label: Text(l10n.adminSupportReplyAction),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: BorderSide(color: AppColors.accent.withValues(alpha: 0.35)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                if (onResolve != null) ...[
                  SizedBox(width: AppLayout.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onResolve,
                      icon: Icon(Icons.check_circle_outline, size: 18.sp),
                      label: Text(
                        l10n.adminSupportResolveAction,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.outlineVariant),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.isOpen});

  final String label;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final bg = isOpen ? const Color(0xFFFFF4E5) : const Color(0xFFE8F2FF);
    final fg = isOpen ? const Color(0xFFB45309) : AppColors.secondary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: AppTypography.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
