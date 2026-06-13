import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';

enum AuthUserRole { cliente, profissional }

abstract final class AuthFormLayout {
  static double get inputRadius => 12.r;
  static double get buttonRadius => 12.r;
}

class AuthRoleSelector extends StatelessWidget {
  const AuthRoleSelector({
    super.key,
    required this.clientLabel,
    required this.professionalLabel,
    required this.selected,
    required this.onChanged,
  });

  final String clientLabel;
  final String professionalLabel;
  final AuthUserRole selected;
  final ValueChanged<AuthUserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AuthFormLayout.inputRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AuthRoleTab(
              label: clientLabel,
              icon: Icons.person,
              isSelected: selected == AuthUserRole.cliente,
              onTap: () => onChanged(AuthUserRole.cliente),
            ),
          ),
          Expanded(
            child: _AuthRoleTab(
              label: professionalLabel,
              icon: Icons.directions_car,
              isSelected: selected == AuthUserRole.profissional,
              onTap: () => onChanged(AuthUserRole.profissional),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthRoleTab extends StatelessWidget {
  const _AuthRoleTab({
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

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      textCapitalization: textCapitalization,
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
          borderRadius: BorderRadius.circular(AuthFormLayout.inputRadius),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthFormLayout.inputRadius),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthFormLayout.inputRadius),
          borderSide: BorderSide(color: AppColors.secondary, width: 1.5.w),
        ),
        constraints: BoxConstraints(minHeight: 56.h),
      ),
    );
  }
}

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel({super.key, required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: 4),
      child: trailing == null
          ? Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                height: 20 / 14,
                letterSpacing: 0.1,
                color: AppColors.onSurfaceVariant,
              ),
            )
          : Row(
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                    letterSpacing: 0.1,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                trailing!,
              ],
            ),
    );
  }
}

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({super.key, required this.label, required this.onTap});

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

class AuthSecurityNote extends StatelessWidget {
  const AuthSecurityNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
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
              text,
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
}
