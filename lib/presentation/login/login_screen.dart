import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/features/auth/data/auth_exception.dart';
import 'package:local_ent_280/features/auth/data/auth_exception_localization.dart';
import 'package:local_ent_280/features/auth/data/auth_repository.dart';
import 'package:local_ent_280/features/auth/data/auth_signing.dart';
import 'package:local_ent_280/features/auth/data/models/login_selected_role.dart';
import 'package:local_ent_280/l10n/app_localizations.dart';

enum UserRole { cliente, profissional }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, AuthSigning? authRepository})
      : _authRepository = authRepository;

  final AuthSigning? _authRepository;

    static double get _inputRadius => 12.r;
  static double get _buttonRadius => 12.r;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _role = UserRole.cliente;
  bool _obscurePassword = true;
  bool _isLoading = false;

  late final AuthSigning _authRepository =
      widget._authRepository ?? AuthRepository();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginSelectedRole get _selectedLoginRole => switch (_role) {
        UserRole.cliente => LoginSelectedRole.client,
        UserRole.profissional => LoginSelectedRole.professional,
      };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
        actions: [
          IconButton(
            tooltip: l10n.loginSettingsTooltip,
            icon: Icon(
              Icons.settings_outlined,
              size: 24.sp,
              color: AppColors.onSurfaceVariant,
            ),
            onPressed: () => AppNavigation.toSettings(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppLayout.marginMobile,
            vertical: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                SizedBox(height: 20.h),
              _buildHeader(l10n),
              SizedBox(height: 60.h),
              _RoleSelector(
                clientLabel: l10n.loginRoleClient,
                professionalLabel: l10n.loginRoleProfessional,
                selected: _role,
                onChanged: (role) => setState(() => _role = role),
              ),
              SizedBox(height: 35.h),
              _buildEmailField(l10n),
              SizedBox(height: 30.h),
              _buildPasswordField(l10n),
              SizedBox(height: 12.h),
              _buildSecurityNote(l10n),
              SizedBox(height: 30.h),
              _buildLoginButton(l10n),
              SizedBox(height: 40.h),
              _buildRegisterPrompt(l10n),
              SizedBox(height: 60.h),
              _buildFooterLinks(l10n),
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
          l10n.appNameLocalTransport,
          style: GoogleFonts.manrope(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            height: 32 / 24,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          l10n.loginSubtitle,
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

  Widget _buildEmailField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            l10n.loginEmailOrMobileLabel,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 20 / 14,
              letterSpacing: 0.1,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        _AuthTextField(
          controller: _emailController,
          hintText: l10n.loginEmailHint,
          prefixIcon: Icons.alternate_email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 4),
          child: Row(
            children: [
              Text(
                l10n.loginPasswordLabel,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  letterSpacing: 0.1,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Text(
                  l10n.loginForgotPassword,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    height: 16 / 12,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        _AuthTextField(
          controller: _passwordController,
          hintText: '••••••••',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
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

  Widget _buildSecurityNote(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(
            Icons.verified_user,
            size: 18.sp,
            color: AppColors.onSurfaceVariant,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              l10n.secureConnectionE2E,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                height: 16 / 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onLoginPressed() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError(context.l10n.loginFillEmailPassword);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final profile = await _authRepository.signIn(
        email: email,
        password: password,
        selectedRole: _selectedLoginRole,
      );
      if (!mounted) return;
      AppNavigation.afterAuthenticatedLogin(context, profile);
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(e.localizedMessage(context.l10n));
    } catch (_) {
      if (!mounted) return;
      _showError(AuthException.unknown().localizedMessage(context.l10n));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildLoginButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onLoginPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LoginScreen._buttonRadius),
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
                    l10n.signIn,
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

  Widget _buildRegisterPrompt(AppLocalizations l10n) {
    final bodyStyle = GoogleFonts.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      height: 24 / 16,
      color: AppColors.onSurfaceVariant,
    );
    final linkStyle = GoogleFonts.inter(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      height: 20 / 14,
      letterSpacing: 0.1,
      color: AppColors.secondary,
    );

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(l10n.loginNoAccountPrompt, style: bodyStyle),
          GestureDetector(
            onTap: () {},
            child: Text(l10n.loginRegisterNow, style: linkStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLinks(AppLocalizations l10n) {
    return Opacity(
      opacity: 0.6,
      child: Column(
        children: [
          Divider(color: AppColors.surfaceContainer, height: 48.h),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16.w,
            runSpacing: 8.h,
            children: [
              _FooterLink(label: l10n.loginPrivacy, onTap: () {}),
              _FooterLink(label: l10n.loginTermsOfUse, onTap: () {}),
              _FooterLink(label: l10n.loginSupport, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.clientLabel,
    required this.professionalLabel,
    required this.selected,
    required this.onChanged,
  });

  final String clientLabel;
  final String professionalLabel;
  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(LoginScreen._inputRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RoleTab(
              label: clientLabel,
              icon: Icons.person,
              isSelected: selected == UserRole.cliente,
              onTap: () => onChanged(UserRole.cliente),
            ),
          ),
          Expanded(
            child: _RoleTab(
              label: professionalLabel,
              icon: Icons.directions_car,
              isSelected: selected == UserRole.profissional,
              onTap: () => onChanged(UserRole.profissional),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleTab extends StatelessWidget {
  const _RoleTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isSelected
                  ? AppColors.onSecondaryContainer
                  : AppColors.onSurfaceVariant,
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  letterSpacing: 0.1,
                  color: isSelected
                      ? AppColors.onSecondaryContainer
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
        prefixIcon: Icon(prefixIcon, color: AppColors.onSurfaceVariant, size: 22.sp),
        prefixIconConstraints: BoxConstraints(minWidth: 48.w, minHeight: 48.h),
        suffixIcon: suffixIcon,
        suffixIconConstraints: BoxConstraints(minWidth: 48.w, minHeight: 48.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LoginScreen._inputRadius),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LoginScreen._inputRadius),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LoginScreen._inputRadius),
          borderSide: BorderSide(color: AppColors.secondary, width: 1.5.w),
        ),
        constraints: BoxConstraints(minHeight: 56.h),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          height: 16 / 12,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
