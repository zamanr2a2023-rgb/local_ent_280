import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/admin/data/admin_functions_service.dart';
import 'package:local_ent_280/features/admin/data/admin_modules_repository.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';

Future<bool> showAdminTransportTypeFormSheet(
  BuildContext context, {
  required AdminModulesRepository repository,
  AdminTransportTypeRecord? type,
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
      child: _AdminTransportTypeFormSheet(repository: repository, type: type),
    ),
  );
  return result ?? false;
}

class _AdminTransportTypeFormSheet extends StatefulWidget {
  const _AdminTransportTypeFormSheet({required this.repository, this.type});

  final AdminModulesRepository repository;
  final AdminTransportTypeRecord? type;

  @override
  State<_AdminTransportTypeFormSheet> createState() =>
      _AdminTransportTypeFormSheetState();
}

class _AdminTransportTypeFormSheetState extends State<_AdminTransportTypeFormSheet> {
  final _name = TextEditingController();
  final _baseFare = TextEditingController();
  final _multiplier = TextEditingController(text: '1.00');
  final _description = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final type = widget.type;
    if (type != null) {
      _name.text = type.name;
      _baseFare.text = type.baseFareEur.toStringAsFixed(2);
      _multiplier.text = type.packageMultiplier.toStringAsFixed(2);
      _description.text = type.description;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _baseFare.dispose();
    _multiplier.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = context.l10n.adminTransportTypeNameRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final baseFare = double.tryParse(_baseFare.text.trim().replaceAll(',', '.')) ?? 0;
      final multiplier =
          double.tryParse(_multiplier.text.trim().replaceAll(',', '.')) ?? 1;
      if (widget.type == null) {
        await widget.repository.createTransportType(
          name: _name.text,
          description: _description.text,
          baseFareEur: baseFare,
          packageMultiplier: multiplier,
        );
      } else {
        await widget.repository.updateTransportType(
          id: widget.type!.id,
          name: _name.text,
          description: _description.text,
          baseFareEur: baseFare,
          packageMultiplier: multiplier,
        );
      }
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
    final isEdit = widget.type != null;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppLayout.marginMobile,
          AppLayout.lg,
          AppLayout.marginMobile,
          AppLayout.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isEdit
                        ? l10n.adminTransportTypeEditTitle
                        : l10n.adminTransportTypeCreateTitle,
                    style: AppTypography.manrope(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.adminTransportTypeNameLabel),
            ),
            SizedBox(height: AppLayout.md),
            TextField(
              controller: _baseFare,
              decoration: InputDecoration(labelText: l10n.adminTransportTypeBaseFareLabel),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: AppLayout.md),
            TextField(
              controller: _multiplier,
              decoration:
                  InputDecoration(labelText: l10n.adminTransportTypeMultiplierLabel),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: AppLayout.md),
            TextField(
              controller: _description,
              decoration: InputDecoration(labelText: l10n.adminTransportTypeDescriptionLabel),
              maxLines: 3,
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
                  : Text(isEdit ? l10n.save : l10n.adminTransportTypeCreateAction),
            ),
          ],
        ),
      ),
    );
  }
}
