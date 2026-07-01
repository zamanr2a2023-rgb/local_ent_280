import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/presentation/admin/admin_drawer.dart';

/// Shared scaffold for admin module screens.
class AdminScaffold extends StatelessWidget {
  const AdminScaffold({
    super.key,
    required this.title,
    required this.body,
    this.drawerSection,
    this.actions,
    this.floatingActionButton,
    this.showBack = true,
  });

  final String title;
  final Widget body;
  final AdminDrawerSection? drawerSection;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: drawerSection == null
          ? null
          : AdminDrawer(selected: drawerSection!),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Column(
          children: [
            _AdminModuleAppBar(
              title: title,
              showBack: showBack,
              actions: actions,
              showMenu: drawerSection != null,
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _AdminModuleAppBar extends StatelessWidget {
  const _AdminModuleAppBar({
    required this.title,
    required this.showBack,
    this.actions,
    this.showMenu = false,
  });

  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
      color: AppColors.background,
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(Icons.arrow_back, color: AppColors.primary, size: 24.sp),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
            )
          else if (showMenu)
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: Icon(Icons.menu, color: AppColors.primary, size: 24.sp),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
              ),
            ),
          SizedBox(width: AppLayout.sm),
          Expanded(
            child: Text(
              title,
              style: AppTypography.manrope(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

class AdminSectionHeader extends StatelessWidget {
  const AdminSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppLayout.marginMobile,
        AppLayout.md,
        AppLayout.marginMobile,
        AppLayout.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.manrope(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: AppLayout.unit),
            Text(
              subtitle!,
              style: AppTypography.inter(
                fontSize: 14.sp,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AdminListCard extends StatelessWidget {
  const AdminListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.badge,
    this.badgeColor,
    this.leading,
    this.onTap,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final String? trailing;
  final String? badge;
  final Color? badgeColor;
  final Widget? leading;
  final VoidCallback? onTap;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(AppLayout.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[
                leading!,
                SizedBox(width: AppLayout.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: (badgeColor ?? AppColors.secondaryContainer)
                                  .withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Text(
                              badge!,
                              style: AppTypography.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: badgeColor ?? AppColors.onSecondaryContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        subtitle!,
                        style: AppTypography.inter(
                          fontSize: 13.sp,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: AppLayout.sm),
                Text(
                  trailing!,
                  style: AppTypography.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}

class AdminEmptyState extends StatelessWidget {
  const AdminEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppLayout.xl),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.inter(
            fontSize: 14.sp,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class AdminLoadingState extends StatelessWidget {
  const AdminLoadingState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppLayout.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32.w,
              height: 32.h,
              child: const CircularProgressIndicator(strokeWidth: 2.5),
            ),
            if (message != null) ...[
              SizedBox(height: AppLayout.md),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AdminSearchField extends StatelessWidget {
  const AdminSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
  });

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(Icons.search, size: 20.sp),
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class AdminFilterChips extends StatelessWidget {
  const AdminFilterChips({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
        itemCount: labels.length,
        separatorBuilder: (_, __) => SizedBox(width: AppLayout.sm),
        itemBuilder: (context, index) {
          final label = labels[index];
          final isSelected = label == selected;
          return FilterChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onSelected(label),
            selectedColor: AppColors.secondaryContainer,
            checkmarkColor: AppColors.onSecondaryContainer,
          );
        },
      ),
    );
  }
}
