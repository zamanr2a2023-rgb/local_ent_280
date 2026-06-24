import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/features/admin/data/admin_functions_service.dart';
import 'package:local_ent_280/features/admin/data/admin_modules_repository.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';
import 'package:local_ent_280/features/auth/data/models/manager_permission.dart';
import 'package:local_ent_280/presentation/admin/admin_drawer.dart';
import 'package:local_ent_280/presentation/admin/widgets/admin_scaffold.dart';

class AdminManagerPermissionsScreen extends StatefulWidget {
  const AdminManagerPermissionsScreen({super.key, this.repository});

  final AdminModulesRepository? repository;

  @override
  State<AdminManagerPermissionsScreen> createState() =>
      _AdminManagerPermissionsScreenState();
}

class _AdminManagerPermissionsScreenState
    extends State<AdminManagerPermissionsScreen> {
  late final AdminModulesRepository _repo;
  StreamSubscription? _sub;
  List<AdminUserRecord> _managers = const [];
  AdminUserRecord? _selected;
  final Map<String, Map<ManagerPermission, bool>> _drafts = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AdminModulesRepository();
    _sub = _repo.watchManagers().listen((managers) {
      if (!mounted) return;
      setState(() {
        _managers = managers;
        if (_selected == null && managers.isNotEmpty) {
          _selected = managers.first;
        } else if (_selected != null) {
          _selected = managers.cast<AdminUserRecord?>().firstWhere(
                (manager) => manager?.id == _selected!.id,
                orElse: () => managers.isNotEmpty ? managers.first : null,
              );
        }
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Map<ManagerPermission, bool> _draftFor(AdminUserRecord manager) {
    return _drafts.putIfAbsent(
      manager.id,
      () => managerPermissionsFromFirestore(manager.managerPermissions),
    );
  }

  bool _isConfigured(AdminUserRecord manager) {
    return managerPermissionsAreConfigured(manager.managerPermissions);
  }

  Future<void> _save(AdminUserRecord manager) async {
    final draft = _drafts[manager.id];
    if (draft == null) return;

    setState(() => _saving = true);
    try {
      await _repo.setManagerPermissions(
        userId: manager.id,
        permissions: draft,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminManagerPermissionsSaveSuccess)),
      );
    } on AdminFunctionsException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminManagerPermissionsSaveError)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _permissionLabel(ManagerPermission permission) {
    final l10n = context.l10n;
    return switch (permission) {
      ManagerPermission.viewTrips => l10n.managerPermissionViewTrips,
      ManagerPermission.viewReports => l10n.managerPermissionViewReports,
      ManagerPermission.viewAudit => l10n.managerPermissionViewAudit,
      ManagerPermission.viewDrivers => l10n.managerPermissionViewDrivers,
      ManagerPermission.viewClients => l10n.managerPermissionViewClients,
      ManagerPermission.viewSupportRequests =>
        l10n.managerPermissionViewSupportRequests,
      ManagerPermission.manageClientChats => l10n.managerPermissionManageClientChats,
      ManagerPermission.cancelTripBySupport =>
        l10n.managerPermissionCancelTripBySupport,
      ManagerPermission.updateTripSupport =>
        l10n.managerPermissionUpdateTripSupport,
      ManagerPermission.resolvePasswordHelpRequest =>
        l10n.managerPermissionResolvePasswordHelpRequest,
      ManagerPermission.manageEvents => l10n.managerPermissionManageEvents,
      ManagerPermission.assignVehicleToDriver =>
        l10n.managerPermissionAssignVehicleToDriver,
      ManagerPermission.editDriverStatus =>
        l10n.managerPermissionEditDriverStatus,
      ManagerPermission.manageTariffs => l10n.managerPermissionManageTariffs,
      ManagerPermission.manageTripPackages =>
        l10n.managerPermissionManageTripPackages,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = _selected;

    return AdminScaffold(
      title: l10n.adminManagerPermissionsTitle,
      drawerSection: AdminDrawerSection.managerPermissions,
      body: _managers.isEmpty
          ? AdminEmptyState(message: l10n.adminManagersEmpty)
          : ListView(
              padding: EdgeInsets.only(bottom: AppLayout.xxl),
              children: [
                AdminSectionHeader(
                  title: l10n.adminManagerPermissionsHeading,
                  subtitle: l10n.adminManagerPermissionsSubtitle,
                ),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.marginMobile,
                    ),
                    itemCount: _managers.length,
                    itemBuilder: (context, index) {
                      final manager = _managers[index];
                      final isSelected = manager.id == selected?.id;
                      return Padding(
                        padding: EdgeInsets.only(right: AppLayout.sm),
                        child: ChoiceChip(
                          label: Text(
                            manager.name.isNotEmpty ? manager.name : manager.email,
                          ),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selected = manager),
                        ),
                      );
                    },
                  ),
                ),
                if (selected != null) ...[
                  SizedBox(height: AppLayout.md),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.marginMobile,
                    ),
                    child: AdminListCard(
                      title: selected.name,
                      subtitle: selected.email,
                      badge: _isConfigured(selected)
                          ? l10n.adminStatusConfigured
                          : l10n.adminStatusUnconfigured,
                      badgeColor: _isConfigured(selected)
                          ? AppColors.secondaryContainer
                          : AppColors.surfaceContainerHigh,
                    ),
                  ),
                  SizedBox(height: AppLayout.sm),
                  for (final permission in ManagerPermission.values)
                    SwitchListTile(
                      title: Text(_permissionLabel(permission)),
                      value: _draftFor(selected)[permission] ?? false,
                      onChanged: _saving
                          ? null
                          : (value) {
                              setState(() {
                                _draftFor(selected)[permission] = value;
                              });
                            },
                    ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppLayout.marginMobile,
                      vertical: AppLayout.md,
                    ),
                    child: FilledButton(
                      onPressed: _saving ? null : () => _save(selected),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.adminManagerPermissionsSaveAction),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
