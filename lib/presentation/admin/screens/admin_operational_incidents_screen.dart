import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/features/admin/data/admin_modules_repository.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';
import 'package:local_ent_280/presentation/admin/admin_drawer.dart';
import 'package:local_ent_280/presentation/admin/widgets/admin_scaffold.dart';

class AdminOperationalIncidentsScreen extends StatefulWidget {
  const AdminOperationalIncidentsScreen({super.key, this.repository});

  final AdminModulesRepository? repository;

  @override
  State<AdminOperationalIncidentsScreen> createState() =>
      _AdminOperationalIncidentsScreenState();
}

class _AdminOperationalIncidentsScreenState
    extends State<AdminOperationalIncidentsScreen> {
  late final AdminModulesRepository _repo;
  StreamSubscription? _sub;
  List<AdminIncidentRecord> _incidents = const [];

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AdminModulesRepository();
    _sub = _repo.watchIncidents().listen((items) {
      if (!mounted) return;
      setState(() => _incidents = items);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AdminScaffold(
      title: l10n.adminIncidentsTitle,
      drawerSection: AdminDrawerSection.incidents,
      body: _incidents.isEmpty
          ? AdminEmptyState(message: l10n.adminIncidentsEmpty)
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(
                AppLayout.marginMobile,
                AppLayout.md,
                AppLayout.marginMobile,
                AppLayout.xxl,
              ),
              itemCount: _incidents.length,
              separatorBuilder: (_, __) => SizedBox(height: AppLayout.md),
              itemBuilder: (context, index) {
                final item = _incidents[index];
                return AdminListCard(
                  title: item.driverName,
                  subtitle:
                      '${item.incidentType}\n${l10n.adminIncidentCurrentState}: ${item.currentState}\n${l10n.adminIncidentTrip}: ${item.tripId}\n${item.kmSummary}',
                  badge: item.status,
                  badgeColor: AppColors.errorContainer,
                  onTap: () => AppNavigation.toAdminIncidentDetail(
                    context,
                    incidentId: item.id,
                  ),
                );
              },
            ),
    );
  }
}
