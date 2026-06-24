import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/features/auth/data/auth_exception.dart';
import 'package:local_ent_280/features/auth/data/auth_exception_localization.dart';
import 'package:local_ent_280/app/presentation/providers/repository_scope.dart';
import 'package:local_ent_280/features/auth/data/auth_signing.dart';
import 'package:local_ent_280/features/auth/data/models/login_selected_role.dart';
import 'package:local_ent_280/l10n/app_localizations.dart';
import 'package:local_ent_280/presentation/login/auth_form_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, AuthSigning? authRepository})
      : _authRepository = authRepository;

  final AuthSigning? _authRepository;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  AuthUserRole _role = AuthUserRole.cliente;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  AuthSigning get _authRepository =>
      widget._authRepository ?? authRepositoryOf(context);

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  LoginSelectedRole get _selectedRole => switch (_role) {
        AuthUserRole.cliente => LoginSelectedRole.client,
        AuthUserRole.profissional => LoginSelectedRole.professional,
      };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary, size: 24.sp),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppLayout.marginMobile,
            vertical: 16.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(l10n),
              SizedBox(height: 32.h),
              AuthRoleSelector(
                clientLabel: l10n.loginRoleClient,
                professionalLabel: l10n.loginRoleProfessional,
                selected: _role,
                onChanged: (role) => setState(() => _role = role),
              ),
              SizedBox(height: 28.h),
              _buildNameField(l10n),
              SizedBox(height: 20.h),
              _buildEmailField(l10n),
              SizedBox(height: 20.h),
              _buildPhoneField(l10n),
              SizedBox(height: 20.h),
              _buildPasswordField(l10n),
              SizedBox(height: 20.h),
              _buildConfirmPasswordField(l10n),
              SizedBox(height: 12.h),
              AuthSecurityNote(text: l10n.secureConnectionE2E),
              SizedBox(height: 24.h),
              _buildRegisterButton(l10n),
              SizedBox(height: 32.h),
              _buildSignInPrompt(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.createAccount,
          style: GoogleFonts.manrope(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            height: 32 / 24,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          l10n.registerSubtitle,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            height: 24 / 16,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthFieldLabel(label: l10n.registerNameLabel),
        AuthTextField(
          controller: _nameController,
          hintText: l10n.registerNameHint,
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }

  Widget _buildEmailField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthFieldLabel(label: l10n.loginEmailOrMobileLabel),
        AuthTextField(
          controller: _emailController,
          hintText: l10n.loginEmailHint,
          prefixIcon: Icons.alternate_email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildPhoneField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthFieldLabel(label: l10n.registerPhoneLabel),
        AuthTextField(
          controller: _phoneController,
          hintText: l10n.registerPhoneHint,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthFieldLabel(label: l10n.loginPasswordLabel),
        AuthTextField(
          controller: _passwordController,
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          suffixIcon: IconButton(
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              size: 22.sp,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthFieldLabel(label: l10n.registerConfirmPasswordLabel),
        AuthTextField(
          controller: _confirmPasswordController,
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _onRegisterPressed(),
          suffixIcon: IconButton(
            onPressed: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            ),
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
              size: 22.sp,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onRegisterPressed() async {
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError(l10n.registerFillRequiredFields);
      return;
    }
    if (password.length < 6) {
      _showError(l10n.registerPasswordTooShort);
      return;
    }
    if (password != confirmPassword) {
      _showError(l10n.registerPasswordMismatch);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final profile = await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
        phone: _phoneController.text.trim(),
        selectedRole: _selectedRole,
      );
      if (!mounted) return;
      AppNavigation.afterAuthenticatedLogin(context, profile);
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(e.localizedMessage(l10n));
    } catch (_) {
      if (!mounted) return;
      _showError(AuthException.unknown().localizedMessage(l10n));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildRegisterButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onRegisterPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuthFormLayout.buttonRadius),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onSecondary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.createAccount,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward, size: 20.sp),
                ],
              ),
      ),
    );
  }

  Widget _buildSignInPrompt(AppLocalizations l10n) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            l10n.registerAlreadyHaveAccount,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              height: 24 / 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Text(
              l10n.registerSignInNow,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                height: 20 / 14,
                letterSpacing: 0.1,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
