import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/admin/data/admin_modules_repository.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';

Future<bool> showAdminVehicleFormSheet(
  BuildContext context, {
  required AdminModulesRepository repository,
  required List<AdminTransportTypeRecord> transportTypes,
  AdminVehicleRecord? vehicle,
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
      child: _AdminVehicleFormSheet(
        repository: repository,
        transportTypes: transportTypes,
        vehicle: vehicle,
      ),
    ),
  );
  return result ?? false;
}

class _AdminVehicleFormSheet extends StatefulWidget {
  const _AdminVehicleFormSheet({
    required this.repository,
    required this.transportTypes,
    this.vehicle,
  });

  final AdminModulesRepository repository;
  final List<AdminTransportTypeRecord> transportTypes;
  final AdminVehicleRecord? vehicle;

  @override
  State<_AdminVehicleFormSheet> createState() => _AdminVehicleFormSheetState();
}

class _AdminVehicleFormSheetState extends State<_AdminVehicleFormSheet> {
  final _plate = TextEditingController();
  final _model = TextEditingController();
  final _capacity = TextEditingController();
  final _notes = TextEditingController();
  bool _isActive = true;
  String? _transportTypeId;
  Uint8List? _photoBytes;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final vehicle = widget.vehicle;
    if (vehicle != null) {
      _plate.text = vehicle.plate;
      _model.text = vehicle.model;
      _capacity.text = '${vehicle.capacity ?? ''}';
      _isActive = vehicle.isActive;
    }
  }

  @override
  void dispose() {
    _plate.dispose();
    _model.dispose();
    _capacity.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() => _photoBytes = bytes);
  }

  Future<void> _submit() async {
    if (_plate.text.trim().isEmpty || _model.text.trim().isEmpty) {
      setState(() => _error = context.l10n.adminVehicleRequiredFields);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final capacity = int.tryParse(_capacity.text.trim()) ?? 0;
      final type = widget.transportTypes
          .where((t) => t.id == _transportTypeId)
          .cast<AdminTransportTypeRecord?>()
          .firstWhere((t) => t != null, orElse: () => null);

      if (widget.vehicle == null) {
        final id = await widget.repository.createVehicle(
          plate: _plate.text,
          model: _model.text,
          capacity: capacity,
          isActive: _isActive,
          notes: _notes.text,
          defaultTransportTypeId: type?.id,
          defaultTransportTypeName: type?.name,
        );
        if (_photoBytes != null && id.isNotEmpty) {
          final url = await widget.repository.uploadVehiclePhoto(
            vehicleId: id,
            bytes: _photoBytes!,
          );
          await widget.repository.updateVehicle(
            vehicleId: id,
            plate: _plate.text,
            model: _model.text,
            capacity: capacity,
            isActive: _isActive,
            notes: _notes.text,
            photoUrl: url,
            defaultTransportTypeId: type?.id,
            defaultTransportTypeName: type?.name,
          );
        }
      } else {
        String? photoUrl;
        if (_photoBytes != null) {
          photoUrl = await widget.repository.uploadVehiclePhoto(
            vehicleId: widget.vehicle!.id,
            bytes: _photoBytes!,
          );
        }
        await widget.repository.updateVehicle(
          vehicleId: widget.vehicle!.id,
          plate: _plate.text,
          model: _model.text,
          capacity: capacity,
          isActive: _isActive,
          notes: _notes.text,
          photoUrl: photoUrl,
          defaultTransportTypeId: type?.id,
          defaultTransportTypeName: type?.name,
        );
      }
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
    final isEdit = widget.vehicle != null;
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
                    isEdit ? l10n.adminVehicleEditTitle : l10n.adminVehicleCreateTitle,
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
            OutlinedButton.icon(
              onPressed: _submitting ? null : _pickPhoto,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(l10n.adminVehicleAddPhoto),
            ),
            SizedBox(height: AppLayout.md),
            TextField(
              controller: _plate,
              decoration: InputDecoration(labelText: l10n.adminVehiclePlateLabel),
            ),
            SizedBox(height: AppLayout.md),
            TextField(
              controller: _model,
              decoration: InputDecoration(labelText: l10n.adminVehicleModelLabel),
            ),
            SizedBox(height: AppLayout.md),
            TextField(
              controller: _capacity,
              decoration: InputDecoration(labelText: l10n.adminVehicleCapacityLabel),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AppLayout.md),
            DropdownButtonFormField<String?>(
              initialValue: _transportTypeId,
              decoration: InputDecoration(labelText: l10n.adminVehicleTransportTypeLabel),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.adminVehicleNoPreference)),
                ...widget.transportTypes.map(
                  (type) => DropdownMenuItem(value: type.id, child: Text(type.name)),
                ),
              ],
              onChanged: _submitting ? null : (v) => setState(() => _transportTypeId = v),
            ),
            SizedBox(height: AppLayout.md),
            TextField(
              controller: _notes,
              decoration: InputDecoration(labelText: l10n.adminVehicleNotesLabel),
              maxLines: 3,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.adminVehicleActiveLabel),
              value: _isActive,
              onChanged: _submitting ? null : (v) => setState(() => _isActive = v),
            ),
            if (_error != null) Text(_error!, style: TextStyle(color: AppColors.error)),
            SizedBox(height: AppLayout.lg),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? l10n.save : l10n.adminVehicleCreateAction),
            ),
          ],
        ),
      ),
    );
  }
}
