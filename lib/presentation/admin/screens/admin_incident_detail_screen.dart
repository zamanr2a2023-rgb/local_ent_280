import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/features/admin/data/admin_modules_repository.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';
import 'package:local_ent_280/presentation/widgets/admin_activity_map_layer.dart';
import 'package:local_ent_280/presentation/admin/widgets/admin_scaffold.dart';
import 'package:local_ent_280/features/admin/data/models/admin_stats.dart';

class AdminIncidentDetailScreen extends StatefulWidget {
  const AdminIncidentDetailScreen({
    super.key,
    required this.incidentId,
    this.repository,
  });

  final String incidentId;
  final AdminModulesRepository? repository;

  @override
  State<AdminIncidentDetailScreen> createState() =>
      _AdminIncidentDetailScreenState();
}

class _AdminIncidentDetailScreenState extends State<AdminIncidentDetailScreen> {
  late final AdminModulesRepository _repo;
  StreamSubscription? _sub;
  AdminIncidentRecord? _incident;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AdminModulesRepository();
    _sub = _repo.watchIncident(widget.incidentId).listen((item) {
      if (!mounted) return;
      setState(() => _incident = item);
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
    final incident = _incident;

    if (incident == null) {
      return AdminScaffold(
        title: l10n.adminIncidentDetailTitle,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final mapData = AdminActivityMapData(
      markers: incident.latestLatitude != null && incident.latestLongitude != null
          ? [
              AdminMapMarker(
                latitude: incident.latestLatitude!,
                longitude: incident.latestLongitude!,
                kind: AdminMapMarkerKind.driver,
                label: incident.driverName,
              ),
            ]
          : const [],
      locationLabel: incident.driverName,
    );

    return AdminScaffold(
      title: l10n.adminIncidentDetailTitle,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppLayout.marginMobile,
          AppLayout.md,
          AppLayout.marginMobile,
          AppLayout.xxl,
        ),
        children: [
          AdminListCard(
            title: incident.incidentType,
            subtitle:
                '${l10n.adminIncidentCurrentState}: ${incident.currentState}\n${l10n.adminIncidentTrip}: ${incident.tripId}\n${l10n.adminIncidentStarted}: ${incident.startedAt?.toLocal()}',
            badge: incident.status,
          ),
          SizedBox(height: AppLayout.md),
          Text(l10n.adminIncidentRouteSummary,
              style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: AppLayout.sm),
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AdminActivityMapLayer(data: mapData),
            ),
          ),
          SizedBox(height: AppLayout.md),
          AdminListCard(
            title: l10n.adminIncidentKmSummary,
            subtitle: incident.kmSummary,
          ),
        ],
      ),
    );
  }
}
