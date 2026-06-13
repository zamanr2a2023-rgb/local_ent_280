import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/admin/data/admin_functions_service.dart';
import 'package:local_ent_280/features/admin/data/admin_modules_repository.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';

Future<bool> showAdminTripPackageFormSheet(
  BuildContext context, {
  required AdminModulesRepository repository,
  required List<AdminTransportTypeRecord> transportTypes,
  AdminTripPackageRecord? package,
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
      child: _AdminTripPackageFormSheet(
        repository: repository,
        transportTypes: transportTypes,
        package: package,
      ),
    ),
  );
  return result ?? false;
}

class _AdminTripPackageFormSheet extends StatefulWidget {
  const _AdminTripPackageFormSheet({
    required this.repository,
    required this.transportTypes,
    this.package,
  });

  final AdminModulesRepository repository;
  final List<AdminTransportTypeRecord> transportTypes;
  final AdminTripPackageRecord? package;

  @override
  State<_AdminTripPackageFormSheet> createState() =>
      _AdminTripPackageFormSheetState();
}

class _AdminTripPackageFormSheetState extends State<_AdminTripPackageFormSheet> {
  final _name = TextEditingController();
  final _destination = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final Set<String> _selectedTypes = {};
  bool _isActive = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final package = widget.package;
    if (package != null) {
      _name.text = package.title;
      _destination.text = package.destination;
      _description.text = package.description;
      _price.text = package.priceEur.toStringAsFixed(2);
      _isActive = package.isActive;
    } else if (widget.transportTypes.isNotEmpty) {
      _selectedTypes.add(widget.transportTypes.first.id);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _destination.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().length < 3) {
      setState(() => _error = context.l10n.adminPackageNameMin);
      return;
    }
    if (_description.text.trim().length < 10) {
      setState(() => _error = context.l10n.adminPackageDescriptionMin);
      return;
    }
    final price = double.tryParse(_price.text.trim().replaceAll(',', '.'));
    if (price == null || price <= 0) {
      setState(() => _error = context.l10n.adminPackagePriceInvalid);
      return;
    }
    if (_selectedTypes.isEmpty) {
      setState(() => _error = context.l10n.adminPackageTransportRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final allowed = widget.transportTypes
          .where((type) => _selectedTypes.contains(type.id))
          .toList();
      await widget.repository.saveTripPackage(
        id: widget.package?.id,
        name: _name.text,
        description: _description.text,
        destinationAddress: _destination.text,
        priceEur: price,
        isActive: _isActive,
        allowedTypes: allowed,
        photoUrl: widget.package?.photoUrl,
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
    final isEdit = widget.package != null;
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
            Text(
              isEdit ? l10n.adminPackageEditTitle : l10n.adminPackageCreateTitle,
              style: AppTypography.manrope(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppLayout.lg),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.adminPackageNameLabel),
            ),
            SizedBox(height: AppLayout.md),
            TextField(
              controller: _destination,
              decoration: InputDecoration(labelText: l10n.adminPackageDestinationLabel),
            ),
            SizedBox(height: AppLayout.md),
            TextField(
              controller: _description,
              decoration: InputDecoration(labelText: l10n.adminPackageDescriptionLabel),
              maxLines: 3,
            ),
            SizedBox(height: AppLayout.md),
            TextField(
              controller: _price,
              decoration: InputDecoration(labelText: l10n.adminPackagePriceLabel),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.adminPackageSalesActive),
              subtitle: Text(l10n.adminPackageSalesActiveHint),
              value: _isActive,
              onChanged: _submitting ? null : (v) => setState(() => _isActive = v),
            ),
            Text(
              l10n.adminPackageAllowedTransport,
              style: AppTypography.manrope(fontWeight: FontWeight.w600),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.transportTypes.map((type) {
                final selected = _selectedTypes.contains(type.id);
                return FilterChip(
                  label: Text(type.name),
                  selected: selected,
                  onSelected: _submitting
                      ? null
                      : (value) {
                          setState(() {
                            if (value) {
                              _selectedTypes.add(type.id);
                            } else {
                              _selectedTypes.remove(type.id);
                            }
                          });
                        },
                );
              }).toList(),
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
                  : Text(isEdit ? l10n.save : l10n.adminPackageCreateAction),
            ),
          ],
        ),
      ),
    );
  }
}
