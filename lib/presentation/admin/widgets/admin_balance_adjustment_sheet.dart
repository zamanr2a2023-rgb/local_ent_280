import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/admin/data/admin_functions_service.dart';
import 'package:local_ent_280/features/admin/data/admin_modules_repository.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';
import 'package:local_ent_280/l10n/app_localizations.dart';

Future<bool> showAdminBalanceAdjustmentSheet(
  BuildContext context, {
  required AdminBalanceRecord balance,
  required AdminModulesRepository repository,
  AdminBalanceAdjustmentMode initialMode = AdminBalanceAdjustmentMode.add,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: _AdminBalanceAdjustmentSheet(
        balance: balance,
        repository: repository,
        initialMode: initialMode,
      ),
    ),
  );
  return result ?? false;
}

class _AdminBalanceAdjustmentSheet extends StatefulWidget {
  const _AdminBalanceAdjustmentSheet({
    required this.balance,
    required this.repository,
    required this.initialMode,
  });

  final AdminBalanceRecord balance;
  final AdminModulesRepository repository;
  final AdminBalanceAdjustmentMode initialMode;

  @override
  State<_AdminBalanceAdjustmentSheet> createState() =>
      _AdminBalanceAdjustmentSheetState();
}

class _AdminBalanceAdjustmentSheetState
    extends State<_AdminBalanceAdjustmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _reason = TextEditingController();
  late AdminBalanceAdjustmentMode _mode;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    if (_mode == AdminBalanceAdjustmentMode.set) {
      _amount.text = widget.balance.amountEur.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  String _amountLabel(AppLocalizations l10n) {
    return switch (_mode) {
      AdminBalanceAdjustmentMode.add => l10n.adminBalanceAddAmountLabel,
      AdminBalanceAdjustmentMode.remove => l10n.adminBalanceRemoveAmountLabel,
      AdminBalanceAdjustmentMode.set => l10n.adminBalanceSetAmountLabel,
    };
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final amount = double.tryParse(_amount.text.trim().replaceAll(',', '.'));
      if (amount == null || amount < 0) {
        throw const AdminFunctionsException('Enter a valid amount.');
      }
      if (_mode != AdminBalanceAdjustmentMode.set && amount == 0) {
        throw const AdminFunctionsException('Enter a valid amount.');
      }
      await widget.repository.applyBalanceAdjustment(
        clientId: widget.balance.userId,
        clientName: widget.balance.userName,
        clientEmail: widget.balance.userEmail.isNotEmpty
            ? widget.balance.userEmail
            : widget.balance.userId,
        amountEur: amount,
        mode: _mode,
        reason: _reason.text.trim(),
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
    final email = widget.balance.userEmail.trim();
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppLayout.marginMobile,
          AppLayout.lg,
          AppLayout.marginMobile,
          AppLayout.xxl,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.adminBalanceAdjustTitle,
                style: AppTypography.manrope(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: AppLayout.sm),
              Text(
                widget.balance.userName,
                style: AppTypography.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              if (email.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  email,
                  style: AppTypography.inter(
                    fontSize: 13.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
              SizedBox(height: 4.h),
              Text(
                '${l10n.adminBalanceCurrent}: ${AppCurrencyFormatter.instance.formatEurMajor(widget.balance.amountEur)}',
                style: AppTypography.inter(
                  fontSize: 13.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppLayout.lg),
              SegmentedButton<AdminBalanceAdjustmentMode>(
                segments: [
                  ButtonSegment(
                    value: AdminBalanceAdjustmentMode.add,
                    label: Text(l10n.adminBalanceModeAdd),
                  ),
                  ButtonSegment(
                    value: AdminBalanceAdjustmentMode.remove,
                    label: Text(l10n.adminBalanceModeRemove),
                  ),
                  ButtonSegment(
                    value: AdminBalanceAdjustmentMode.set,
                    label: Text(l10n.adminBalanceModeSet),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: _submitting
                    ? null
                    : (value) {
                        setState(() {
                          _mode = value.first;
                          if (_mode == AdminBalanceAdjustmentMode.set &&
                              _amount.text.trim().isEmpty) {
                            _amount.text =
                                widget.balance.amountEur.toStringAsFixed(2);
                          }
                        });
                      },
              ),
              SizedBox(height: AppLayout.md),
              TextFormField(
                controller: _amount,
                decoration: InputDecoration(labelText: _amountLabel(l10n)),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || v.trim().isEmpty
                    ? l10n.adminBalanceAmountRequired
                    : null,
              ),
              SizedBox(height: AppLayout.md),
              TextFormField(
                controller: _reason,
                decoration: InputDecoration(labelText: l10n.adminBalanceReasonLabel),
                maxLines: 3,
                validator: (v) => v == null || v.trim().isEmpty
                    ? l10n.adminBalanceReasonRequired
                    : null,
              ),
              if (_error != null) ...[
                SizedBox(height: AppLayout.md),
                Text(_error!, style: TextStyle(color: AppColors.error)),
              ],
              SizedBox(height: AppLayout.lg),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.adminBalanceConfirm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
