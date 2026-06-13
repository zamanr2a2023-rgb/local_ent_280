import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/admin/data/admin_functions_service.dart';
import 'package:local_ent_280/features/admin/data/admin_modules_repository.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';

Future<bool> showAdminBalanceAdjustmentSheet(
  BuildContext context, {
  required AdminBalanceRecord balance,
  required AdminModulesRepository repository,
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
      ),
    ),
  );
  return result ?? false;
}

class _AdminBalanceAdjustmentSheet extends StatefulWidget {
  const _AdminBalanceAdjustmentSheet({
    required this.balance,
    required this.repository,
  });

  final AdminBalanceRecord balance;
  final AdminModulesRepository repository;

  @override
  State<_AdminBalanceAdjustmentSheet> createState() =>
      _AdminBalanceAdjustmentSheetState();
}

class _AdminBalanceAdjustmentSheetState
    extends State<_AdminBalanceAdjustmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _reason = TextEditingController();
  bool _isCredit = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final amount = double.tryParse(_amount.text.trim().replaceAll(',', '.'));
      if (amount == null || amount <= 0) {
        throw const AdminFunctionsException('Enter a valid amount.');
      }
      await widget.repository.applyBalanceAdjustment(
        clientId: widget.balance.userId,
        clientName: widget.balance.userName,
        clientEmail: widget.balance.userId,
        amountEur: amount,
        isCredit: _isCredit,
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
                '${widget.balance.userName} · ${widget.balance.userId}',
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppLayout.lg),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: true, label: Text(l10n.adminBalanceCredit)),
                  ButtonSegment(value: false, label: Text(l10n.adminBalanceDebt)),
                ],
                selected: {_isCredit},
                onSelectionChanged: _submitting
                    ? null
                    : (value) => setState(() => _isCredit = value.first),
              ),
              SizedBox(height: AppLayout.md),
              TextFormField(
                controller: _amount,
                decoration: InputDecoration(labelText: l10n.adminBalanceAmountLabel),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? l10n.adminBalanceAmountRequired : null,
              ),
              SizedBox(height: AppLayout.md),
              TextFormField(
                controller: _reason,
                decoration: InputDecoration(labelText: l10n.adminBalanceReasonLabel),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? l10n.adminBalanceReasonRequired : null,
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
