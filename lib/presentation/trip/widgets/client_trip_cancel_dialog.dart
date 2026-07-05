import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/features/trips/data/models/trip_cancellation.dart';

/// Asks the client to pick a cancellation reason before calling [cancelTrip].
Future<String?> showClientTripCancelReasonDialog(
  BuildContext context, {
  String? confirmMessage,
}) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => _ClientTripCancelReasonDialog(
      confirmMessage: confirmMessage,
    ),
  );
}

class _ClientTripCancelReasonDialog extends StatefulWidget {
  const _ClientTripCancelReasonDialog({this.confirmMessage});

  final String? confirmMessage;

  @override
  State<_ClientTripCancelReasonDialog> createState() =>
      _ClientTripCancelReasonDialogState();
}

class _ClientTripCancelReasonDialogState
    extends State<_ClientTripCancelReasonDialog> {
  ClientTripCancelReasonOption? _selected;
  final _otherController = TextEditingController();

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    final selected = _selected;
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tripCancelReasonRequired)),
      );
      return;
    }
    if (selected == ClientTripCancelReasonOption.other) {
      final custom = _otherController.text.trim();
      if (custom.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tripCancelReasonRequired)),
        );
        return;
      }
      Navigator.of(context).pop(selected.encode(customText: custom));
      return;
    }
    Navigator.of(context).pop(selected.encode());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final confirmMessage = widget.confirmMessage?.trim();

    return AlertDialog(
      title: Text(l10n.tripCancelReasonTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (confirmMessage != null && confirmMessage.isNotEmpty) ...[
              Text(
                confirmMessage,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 12.h),
            ],
            Text(
              l10n.tripCancelReasonSubtitle,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 12.h),
            ...ClientTripCancelReasonOption.values.map((option) {
              return RadioListTile<ClientTripCancelReasonOption>(
                value: option,
                groupValue: _selected,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  option.label(l10n),
                  style: GoogleFonts.inter(fontSize: 14.sp),
                ),
                onChanged: (value) => setState(() => _selected = value),
              );
            }),
            if (_selected == ClientTripCancelReasonOption.other) ...[
              SizedBox(height: 4.h),
              TextField(
                controller: _otherController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l10n.tripCancelReasonOtherHint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.errorContainer,
            foregroundColor: AppColors.onErrorContainer,
          ),
          child: Text(l10n.tripCancelSubmit),
        ),
      ],
    );
  }
}
