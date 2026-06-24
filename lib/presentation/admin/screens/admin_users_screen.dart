import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/admin/data/admin_modules_repository.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';
import 'package:local_ent_280/presentation/admin/admin_drawer.dart';
import 'package:local_ent_280/presentation/admin/widgets/admin_create_user_sheet.dart';
import 'package:local_ent_280/presentation/admin/widgets/admin_scaffold.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key, this.repository});

  final AdminModulesRepository? repository;

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late final AdminModulesRepository _repo;
  StreamSubscription? _sub;
  List<AdminUserRecord> _users = const [];
  String _query = '';
  String _roleFilter = 'All';

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AdminModulesRepository();
    _sub = _repo.watchUsers().listen((users) {
      if (!mounted) return;
      setState(() => _users = users);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  List<AdminUserRecord> get _filtered {
    return _users.where((user) {
      final matchesRole = _roleFilter == 'All' ||
          user.role.toLowerCase() == _roleFilter.toLowerCase();
      if (!matchesRole) return false;
      if (_query.trim().isEmpty) return true;
      final q = _query.toLowerCase();
      return user.name.toLowerCase().contains(q) ||
          user.email.toLowerCase().contains(q) ||
          user.phone.toLowerCase().contains(q) ||
          user.id.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filtered = _filtered;

    return AdminScaffold(
      title: l10n.adminUsersTitle,
      drawerSection: AdminDrawerSection.users,
      actions: [
        IconButton(
          tooltip: l10n.adminUsersAddTooltip,
          onPressed: _openCreateUser,
          icon: Icon(Icons.person_add_alt_1, color: AppColors.primary),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminSectionHeader(
            title: l10n.adminUsersHeading,
            subtitle: l10n.adminUsersSubtitle,
          ),
          AdminSearchField(
            hint: l10n.adminUsersSearchHint,
            onChanged: (v) => setState(() => _query = v),
          ),
          SizedBox(height: AppLayout.sm),
          AdminFilterChips(
            labels: const ['All', 'client', 'driver', 'manager', 'admin'],
            selected: _roleFilter,
            onSelected: (v) => setState(() => _roleFilter = v),
          ),
          SizedBox(height: AppLayout.md),
          Expanded(
            child: filtered.isEmpty
                ? AdminEmptyState(message: l10n.adminUsersEmpty)
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      AppLayout.marginMobile,
                      0,
                      AppLayout.marginMobile,
                      AppLayout.xxl,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => SizedBox(height: AppLayout.md),
                    itemBuilder: (context, index) {
                      final user = filtered[index];
                      return AdminListCard(
                        leading: _UserAvatar(user: user),
                        title: user.name.isNotEmpty ? user.name : user.email,
                        subtitle: '${user.phone}\n${user.email}',
                        badge: user.role,
                        badgeColor: user.isActive
                            ? AppColors.secondaryContainer
                            : AppColors.surfaceContainerHigh,
                        trailing: user.isActive ? l10n.adminStatusActive : l10n.adminStatusInactive,
                        actions: [
                          IconButton(
                            icon: Icon(
                              user.isActive ? Icons.pause_circle_outline : Icons.check_circle_outline,
                              color: AppColors.primary,
                            ),
                            onPressed: () => _toggleActive(user),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(AdminUserRecord user) async {
    await _repo.setUserActive(user.id, !user.isActive);
  }

  Future<void> _openCreateUser() async {
    final created = await showAdminCreateUserSheet(
      context,
      repository: _repo,
    );
    if (!mounted || !created) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.adminUsersCreateSuccess)),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user});

  final AdminUserRecord user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8.r),
      ),
      alignment: Alignment.center,
      child: Text(
        user.initials,
        style: AppTypography.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
