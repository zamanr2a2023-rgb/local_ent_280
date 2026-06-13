import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/admin/data/admin_functions_service.dart';
import 'package:local_ent_280/features/admin/data/admin_modules_repository.dart';

Future<bool> showAdminSupportReplySheet(
  BuildContext context, {
  required AdminModulesRepository repository,
  required String requestId,
  required String displayName,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: _AdminSupportReplySheet(
        repository: repository,
        requestId: requestId,
        displayName: displayName,
      ),
    ),
  );
  return result ?? false;
}

class _AdminSupportReplySheet extends StatefulWidget {
  const _AdminSupportReplySheet({
    required this.repository,
    required this.requestId,
    required this.displayName,
  });

  final AdminModulesRepository repository;
  final String requestId;
  final String displayName;

  @override
  State<_AdminSupportReplySheet> createState() => _AdminSupportReplySheetState();
}

class _AdminSupportReplySheetState extends State<_AdminSupportReplySheet> {
  final _message = TextEditingController();
  final _focus = FocusNode();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _message.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_message.text.trim().isEmpty) {
      setState(() => _error = context.l10n.adminSupportReplyRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.repository.sendSupportReply(
        requestId: widget.requestId,
        message: _message.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AdminFunctionsException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.message;
      });
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
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;

    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppLayout.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 24.r,
              offset: Offset(0, -4.h),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppLayout.marginMobile,
              AppLayout.md,
              AppLayout.marginMobile,
              AppLayout.xxl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                ),
                SizedBox(height: AppLayout.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.adminSupportReplyTitle,
                        style: AppTypography.manrope(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: AppColors.labelMuted),
                    ),
                  ],
                ),
                SizedBox(height: AppLayout.sm),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.accentSurface,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 18.sp, color: AppColors.accent),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          widget.displayName,
                          style: AppTypography.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppLayout.lg),
                Text(
                  l10n.adminSupportReplyLabel,
                  style: AppTypography.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: AppLayout.sm),
                TextField(
                  controller: _message,
                  focusNode: _focus,
                  autofocus: true,
                  maxLines: 5,
                  minLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: l10n.adminSupportReplyHint,
                    filled: true,
                    fillColor: AppColors.inputFill,
                    contentPadding: EdgeInsets.all(AppLayout.md),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide(color: AppColors.surfaceVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide(color: AppColors.accent, width: 1.5),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  SizedBox(height: AppLayout.sm),
                  Text(
                    _error!,
                    style: AppTypography.inter(
                      fontSize: 13.sp,
                      color: AppColors.error,
                    ),
                  ),
                ],
                SizedBox(height: AppLayout.lg),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.onAccent,
                    minimumSize: Size.fromHeight(52.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: _submitting
                      ? SizedBox(
                          width: 22.w,
                          height: 22.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.adminSupportReplyAction,
                          style: AppTypography.manrope(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
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
