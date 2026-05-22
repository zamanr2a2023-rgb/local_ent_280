import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';

enum UserRole { cliente, profissional }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

    static double get _inputRadius => 12.r;
  static double get _buttonRadius => 12.r;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _role = UserRole.cliente;
  bool _obscurePassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
              _buildHeader(),
              SizedBox(height: 60.h),
              _RoleSelector(
                selected: _role,
                onChanged: (role) => setState(() => _role = role),
              ),
              SizedBox(height: 35.h),
              _buildEmailField(),
              SizedBox(height: 30.h),
              _buildPasswordField(),
              SizedBox(height: 12.h),
              _buildSecurityNote(),
              SizedBox(height: 30.h),
              _buildLoginButton(),
              SizedBox(height: 40.h),
              _buildRegisterPrompt(),
              SizedBox(height: 60.h),
              _buildFooterLinks(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobilidade Premium',
          style: GoogleFonts.manrope(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            height: 32 / 24,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Inicie sessão para gerir as suas viagens.',
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

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            'E-mail ou Telemóvel',
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
          hintText: 'ex: joao@email.com',
          prefixIcon: Icons.alternate_email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 4),
          child: Row(
            children: [
              Text(
                'Palavra-passe',
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
                  'Esqueceu-se?',
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

  Widget _buildSecurityNote() {
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
              'Ligação segura e encriptada ponta-a-ponta.',
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

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: () => AppNavigation.toHomeAfterLogin(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LoginScreen._buttonRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Entrar',
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

  Widget _buildRegisterPrompt() {
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
          Text('Ainda não tem conta? ', style: bodyStyle),
          GestureDetector(
            onTap: () {},
            child: Text('Registar agora', style: linkStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLinks() {
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
              _FooterLink(label: 'Privacidade', onTap: () {}),
              _FooterLink(label: 'Termos de Uso', onTap: () {}),
              _FooterLink(label: 'Suporte', onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.selected,
    required this.onChanged,
  });

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
              label: 'Cliente',
              icon: Icons.person,
              isSelected: selected == UserRole.cliente,
              onTap: () => onChanged(UserRole.cliente),
            ),
          ),
          Expanded(
            child: _RoleTab(
              label: 'Profissional',
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
