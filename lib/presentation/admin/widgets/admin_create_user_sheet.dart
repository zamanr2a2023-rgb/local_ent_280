import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/admin/data/admin_modules_repository.dart';
import 'package:local_ent_280/features/admin/data/admin_user_auth_service.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';

Future<bool> showAdminCreateUserSheet(
  BuildContext context, {
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
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: _AdminCreateUserSheet(repository: repository),
    ),
  );
  return result ?? false;
}

class _AdminCreateUserSheet extends StatefulWidget {
  const _AdminCreateUserSheet({required this.repository});

  final AdminModulesRepository repository;

  @override
  State<_AdminCreateUserSheet> createState() => _AdminCreateUserSheetState();
}

class _AdminCreateUserSheetState extends State<_AdminCreateUserSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  String _role = 'client';
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await widget.repository.createUser(
        AdminCreateUserDraft(
          name: _name.text,
          email: _email.text,
          password: _password.text,
          phone: _phone.text,
          role: _role,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AdminCreateUserException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = context.l10n.adminUsersCreateFailed;
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
                l10n.adminUsersCreateTitle,
                style: AppTypography.manrope(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: AppLayout.sm),
              Text(
                l10n.adminUsersCreateSubtitle,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppLayout.lg),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.registerNameLabel),
                textInputAction: TextInputAction.next,
                validator: (v) => v == null || v.trim().isEmpty
                    ? l10n.registerFillRequiredFields
                    : null,
              ),
              SizedBox(height: AppLayout.md),
              TextFormField(
                controller: _email,
                decoration:
                    InputDecoration(labelText: l10n.loginEmailOrMobileLabel),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) => v == null || v.trim().isEmpty
                    ? l10n.registerFillRequiredFields
                    : null,
              ),
              SizedBox(height: AppLayout.md),
              TextFormField(
                controller: _phone,
                decoration: InputDecoration(labelText: l10n.registerPhoneLabel),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: AppLayout.md),
              TextFormField(
                controller: _password,
                decoration: InputDecoration(labelText: l10n.loginPasswordLabel),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.length < 6) {
                    return l10n.registerPasswordTooShort;
                  }
                  return null;
                },
              ),
              SizedBox(height: AppLayout.md),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: InputDecoration(labelText: l10n.adminUsersRoleLabel),
                items: AdminCreateUserDraft.roles
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ),
                    )
                    .toList(),
                onChanged: _submitting
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() => _role = value);
                      },
              ),
              if (_error != null) ...[
                SizedBox(height: AppLayout.md),
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
                child: _submitting
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.adminUsersCreateAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
