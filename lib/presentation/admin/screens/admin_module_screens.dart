import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/features/admin/data/admin_modules_repository.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';
import 'package:local_ent_280/presentation/admin/admin_drawer.dart';
import 'package:local_ent_280/presentation/admin/widgets/admin_balance_adjustment_sheet.dart';
import 'package:local_ent_280/presentation/admin/widgets/admin_transport_type_form_sheet.dart';
import 'package:local_ent_280/presentation/admin/widgets/admin_trip_package_form_sheet.dart';
import 'package:local_ent_280/presentation/admin/widgets/admin_vehicle_form_sheet.dart';
import 'package:local_ent_280/presentation/admin/screens/admin_tariff_editor_screen.dart';
import 'package:local_ent_280/presentation/admin/widgets/admin_scaffold.dart';

class AdminFleetScreen extends StatefulWidget {
  const AdminFleetScreen({super.key, this.repository});

  final AdminModulesRepository? repository;

  @override
  State<AdminFleetScreen> createState() => _AdminFleetScreenState();
}

class _AdminFleetScreenState extends State<AdminFleetScreen> {
  late final AdminModulesRepository _repo;
  StreamSubscription? _sub;
  StreamSubscription? _typesSub;
  List<AdminVehicleRecord> _vehicles = const [];
  List<AdminTransportTypeRecord> _transportTypes = const [];

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AdminModulesRepository();
    _sub = _repo.watchFleet().listen((items) {
      if (!mounted) return;
      setState(() => _vehicles = items);
    });
    _typesSub = _repo.watchTransportTypes().listen((items) {
      if (!mounted) return;
      setState(() => _transportTypes = items);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _typesSub?.cancel();
    super.dispose();
  }

  Future<void> _openCreateVehicle() async {
    final created = await showAdminVehicleFormSheet(
      context,
      repository: _repo,
      transportTypes: _transportTypes,
    );
    if (!mounted || !created) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.adminVehicleCreateSuccess)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AdminScaffold(
      title: l10n.adminFleetTitle,
      drawerSection: AdminDrawerSection.fleet,
      actions: [
        IconButton(
          tooltip: l10n.adminVehicleCreateTitle,
          onPressed: _openCreateVehicle,
          icon: Icon(Icons.add, color: AppColors.primary),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminSectionHeader(
            title: l10n.adminFleetTitle,
            subtitle: l10n.adminFleetDesc,
          ),
          Expanded(
            child: _vehicles.isEmpty
                ? AdminEmptyState(message: l10n.adminNoFleetVehicles)
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      AppLayout.marginMobile,
                      0,
                      AppLayout.marginMobile,
                      AppLayout.xxl,
                    ),
                    itemCount: _vehicles.length,
                    separatorBuilder: (_, __) => SizedBox(height: AppLayout.md),
                    itemBuilder: (context, index) {
                      final vehicle = _vehicles[index];
                      return AdminListCard(
                        title: vehicle.label,
                        subtitle: vehicle.assignedDriverName == null
                            ? l10n.adminFleetNoDriver
                            : '${l10n.adminFleetDriver}: ${vehicle.assignedDriverName}',
                        badge: vehicle.isActive
                            ? l10n.adminStatusActive
                            : l10n.adminStatusInactive,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () async {
                              final updated = await showAdminVehicleFormSheet(
                                context,
                                repository: _repo,
                                transportTypes: _transportTypes,
                                vehicle: vehicle,
                              );
                              if (!mounted || !updated) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.save)),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              vehicle.isActive
                                  ? Icons.pause_circle_outline
                                  : Icons.check_circle_outline,
                            ),
                            onPressed: () => _repo.setVehicleActive(
                              vehicle.id,
                              !vehicle.isActive,
                            ),
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
}

class AdminBalancesScreen extends StatefulWidget {
  const AdminBalancesScreen({super.key, this.repository});

  final AdminModulesRepository? repository;

  @override
  State<AdminBalancesScreen> createState() => _AdminBalancesScreenState();
}

class _AdminBalancesScreenState extends State<AdminBalancesScreen> {
  late final AdminModulesRepository _repo;
  StreamSubscription? _sub;
  List<AdminBalanceRecord> _balances = const [];

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AdminModulesRepository();
    _sub = _repo.watchBalances().listen((items) {
      if (!mounted) return;
      setState(() => _balances = items);
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
      title: l10n.adminBalancesTitle,
      drawerSection: AdminDrawerSection.balances,
      body: _balances.isEmpty
          ? AdminEmptyState(message: l10n.adminBalancesEmpty)
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(
                AppLayout.marginMobile,
                AppLayout.md,
                AppLayout.marginMobile,
                AppLayout.xxl,
              ),
              itemCount: _balances.length,
              separatorBuilder: (_, __) => SizedBox(height: AppLayout.md),
              itemBuilder: (context, index) {
                final item = _balances[index];
                return AdminListCard(
                  title: item.userName,
                  subtitle:
                      '${item.userId}\n${l10n.adminBalanceCurrent}: ${AppCurrencyFormatter.instance.formatEurMajor(item.amountEur)}\n${l10n.adminBalanceDebtLimit}: ${AppCurrencyFormatter.instance.formatEurMajor(item.debtLimitEur)}',
                  badge: item.isDebt ? l10n.adminBalancesDebt : l10n.adminBalancesCredit,
                  actions: [
                    TextButton(
                      onPressed: () async {
                        final adjusted = await showAdminBalanceAdjustmentSheet(
                          context,
                          balance: item,
                          repository: _repo,
                        );
                        if (!context.mounted || !adjusted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.adminBalanceAdjustSuccess)),
                        );
                      },
                      child: Text(l10n.adminBalanceAdjustAction),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({super.key, this.repository});

  final AdminModulesRepository? repository;

  @override
  State<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends State<AdminAuditScreen> {
  late final AdminModulesRepository _repo;
  StreamSubscription? _sub;
  List<AdminAuditRecord> _entries = const [];

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AdminModulesRepository();
    _sub = _repo.watchAudit().listen((items) {
      if (!mounted) return;
      setState(() => _entries = items);
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
      title: l10n.adminAuditTitle,
      drawerSection: AdminDrawerSection.audit,
      body: _entries.isEmpty
          ? AdminEmptyState(message: l10n.adminAuditEmpty)
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(
                AppLayout.marginMobile,
                AppLayout.md,
                AppLayout.marginMobile,
                AppLayout.xxl,
              ),
              itemCount: _entries.length,
              separatorBuilder: (_, __) => SizedBox(height: AppLayout.md),
              itemBuilder: (context, index) {
                final item = _entries[index];
                return AdminListCard(
                  title: item.action,
                  subtitle:
                      '${item.actorEmail}\n${item.subjectType} · ${item.subjectId}\n${item.summary}',
                  badge: item.createdAt?.toLocal().toString().substring(0, 16),
                );
              },
            ),
    );
  }
}

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key, this.repository});

  final AdminModulesRepository? repository;

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  late final AdminModulesRepository _repo;
  StreamSubscription? _sub;
  List<AdminEventRecord> _events = const [];

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AdminModulesRepository();
    _sub = _repo.watchEvents().listen((items) {
      if (!mounted) return;
      setState(() => _events = items);
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
      title: l10n.adminEventsTitle,
      drawerSection: AdminDrawerSection.events,
      body: _events.isEmpty
          ? AdminEmptyState(message: l10n.adminEventsEmpty)
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(
                AppLayout.marginMobile,
                AppLayout.md,
                AppLayout.marginMobile,
                AppLayout.xxl,
              ),
              itemCount: _events.length,
              separatorBuilder: (_, __) => SizedBox(height: AppLayout.md),
              itemBuilder: (context, index) {
                final item = _events[index];
                return AdminListCard(
                  title: item.title,
                  subtitle:
                      '${item.message}\n${item.scheduledAt?.toLocal() ?? '—'}',
                  badge: '${item.targetCount} drivers',
                );
              },
            ),
    );
  }
}

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key, this.repository});

  final AdminModulesRepository? repository;

  @override
  State<AdminReservationsScreen> createState() =>
      _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  late final AdminModulesRepository _repo;
  StreamSubscription? _sub;
  List<AdminReservationRecord> _items = const [];

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AdminModulesRepository();
    _sub = _repo.watchReservations().listen((items) {
      if (!mounted) return;
      setState(() => _items = items);
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
      title: l10n.adminReservationsTitle,
      drawerSection: AdminDrawerSection.reservations,
      body: _items.isEmpty
          ? AdminEmptyState(message: l10n.adminReservationsEmpty)
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(
                AppLayout.marginMobile,
                AppLayout.md,
                AppLayout.marginMobile,
                AppLayout.xxl,
              ),
              itemCount: _items.length,
              separatorBuilder: (_, __) => SizedBox(height: AppLayout.md),
              itemBuilder: (context, index) {
                final item = _items[index];
                return AdminListCard(
                  title: item.clientName,
                  subtitle:
                      '${item.pickupAddress}\n${item.scheduledAt?.toLocal() ?? '—'}',
                  badge: item.status,
                );
              },
            ),
    );
  }
}

class AdminTransportTypesScreen extends StatefulWidget {
  const AdminTransportTypesScreen({super.key, this.repository});

  final AdminModulesRepository? repository;

  @override
  State<AdminTransportTypesScreen> createState() =>
      _AdminTransportTypesScreenState();
}

class _AdminTransportTypesScreenState extends State<AdminTransportTypesScreen> {
  late final AdminModulesRepository _repo;
  StreamSubscription? _sub;
  List<AdminTransportTypeRecord> _items = const [];

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AdminModulesRepository();
    _sub = _repo.watchTransportTypes().listen((items) {
      if (!mounted) return;
      setState(() => _items = items);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _openCreate() async {
    final created = await showAdminTransportTypeFormSheet(context, repository: _repo);
    if (!mounted || !created) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.adminTransportTypeCreateSuccess)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AdminScaffold(
      title: l10n.adminTransportTypesTitle,
      drawerSection: AdminDrawerSection.transportTypes,
      actions: [
        IconButton(
          tooltip: l10n.adminTransportTypeCreateTitle,
          onPressed: _openCreate,
          icon: Icon(Icons.add, color: AppColors.primary),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminSectionHeader(
            title: l10n.adminTransportTypesTitle,
            subtitle: l10n.adminTransportTypesDesc,
          ),
          Expanded(
            child: _items.isEmpty
                ? AdminEmptyState(message: l10n.adminTransportTypesEmpty)
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      AppLayout.marginMobile,
                      0,
                      AppLayout.marginMobile,
                      AppLayout.xxl,
                    ),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => SizedBox(height: AppLayout.md),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return AdminListCard(
                        title: item.name,
                        subtitle:
                            '${l10n.adminTransportTypeBaseFareLabel}: ${AppCurrencyFormatter.instance.formatEurMajor(item.baseFareEur)}\n${l10n.adminTransportTypeMultiplierLabel}: ${item.packageMultiplier.toStringAsFixed(2)}x',
                        badge: item.isActive
                            ? l10n.adminStatusActive
                            : l10n.adminStatusInactive,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () async {
                              final updated = await showAdminTransportTypeFormSheet(
                                context,
                                repository: _repo,
                                type: item,
                              );
                              if (!mounted || !updated) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.save)),
                              );
                            },
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
}

class AdminTripPackagesScreen extends StatefulWidget {
  const AdminTripPackagesScreen({super.key, this.repository});

  final AdminModulesRepository? repository;

  @override
  State<AdminTripPackagesScreen> createState() =>
      _AdminTripPackagesScreenState();
}

class _AdminTripPackagesScreenState extends State<AdminTripPackagesScreen>
    with SingleTickerProviderStateMixin {
  late final AdminModulesRepository _repo;
  late final TabController _tabs;
  StreamSubscription? _packagesSub;
  StreamSubscription? _typesSub;
  List<AdminTripPackageRecord> _packages = const [];
  List<AdminTransportTypeRecord> _transportTypes = const [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _repo = widget.repository ?? AdminModulesRepository();
    _packagesSub = _repo.watchTripPackages().listen((items) {
      if (!mounted) return;
      setState(() => _packages = items);
    });
    _typesSub = _repo.watchTransportTypes().listen((items) {
      if (!mounted) return;
      setState(() => _transportTypes = items);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _packagesSub?.cancel();
    _typesSub?.cancel();
    super.dispose();
  }

  Future<void> _openCreate({AdminTripPackageRecord? package}) async {
    final created = await showAdminTripPackageFormSheet(
      context,
      repository: _repo,
      transportTypes: _transportTypes,
      package: package,
    );
    if (!mounted || !created) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          package == null
              ? context.l10n.adminPackageCreateSuccess
              : context.l10n.save,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AdminScaffold(
      title: l10n.adminTripPackagesTitle,
      drawerSection: AdminDrawerSection.tripPackages,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            controller: _tabs,
            labelColor: AppColors.primary,
            tabs: [
              Tab(text: l10n.adminTripPackagesOpsTab),
              Tab(text: l10n.adminTripPackagesCatalogTab),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                AdminEmptyState(message: l10n.adminTripPackagesOpsEmpty),
                _buildCatalog(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalog(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppLayout.marginMobile,
        AppLayout.md,
        AppLayout.marginMobile,
        AppLayout.xxl,
      ),
      children: [
        AdminSectionHeader(
          title: l10n.adminTripPackagesCatalogHeading,
          subtitle: l10n.adminTripPackagesCatalogSubtitle,
        ),
        FilledButton(
          onPressed: _transportTypes.isEmpty ? null : () => _openCreate(),
          child: Text(l10n.adminPackageCreateAction),
        ),
        SizedBox(height: AppLayout.lg),
        if (_packages.isEmpty)
          AdminEmptyState(message: l10n.adminTripPackagesEmpty)
        else
          ..._packages.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppLayout.md),
              child: AdminListCard(
                title: item.title,
                subtitle:
                    '${item.destination}\n${item.description}\n${AppCurrencyFormatter.instance.formatEurMajor(item.priceEur)}',
                badge: item.isActive
                    ? l10n.adminPackageSalesActive
                    : l10n.adminStatusInactive,
                actions: [
                  TextButton(
                    onPressed: () => _openCreate(package: item),
                    child: Text(l10n.adminPackageEditAction),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class AdminTariffsScreen extends AdminTariffEditorScreen {
  const AdminTariffsScreen({super.key, super.repository});
}

class AdminCurrencySettingsScreen extends StatefulWidget {
  const AdminCurrencySettingsScreen({super.key, this.repository});

  final AdminModulesRepository? repository;

  @override
  State<AdminCurrencySettingsScreen> createState() =>
      _AdminCurrencySettingsScreenState();
}

class _AdminCurrencySettingsScreenState
    extends State<AdminCurrencySettingsScreen> {
  late final AdminModulesRepository _repo;
  StreamSubscription? _sub;
  final _cveToEur = TextEditingController();
  final _cveToUsd = TextEditingController();
  Map<String, dynamic> _config = const {};
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AdminModulesRepository();
    _sub = _repo.watchConfig('currency').listen((config) {
      if (!mounted) return;
      setState(() {
        _config = config.data;
        if (!_loaded || !_saving) {
          _cveToEur.text = '${config.data['cveToEur'] ?? ''}';
          _cveToUsd.text = '${config.data['cveToUsd'] ?? ''}';
          _loaded = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _cveToEur.dispose();
    _cveToUsd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final updatedAt = adminTimestamp(_config['updatedAt']);
    final updatedBy = _config['updatedBy'] as String?;

    return AdminScaffold(
      title: l10n.adminCurrencyTitle,
      drawerSection: AdminDrawerSection.currency,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppLayout.marginMobile,
          AppLayout.md,
          AppLayout.marginMobile,
          AppLayout.xxl,
        ),
        children: [
          AdminSectionHeader(
            title: l10n.adminCurrencyHeading,
            subtitle: l10n.adminCurrencySubtitle,
          ),
          if (!_loaded && _config.isEmpty)
            AdminEmptyState(message: l10n.adminMonitoringLoading)
          else ...[
            TextField(
              controller: _cveToEur,
              enabled: !_saving,
              decoration: InputDecoration(labelText: l10n.adminCurrencyCveToEur),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: AppLayout.md),
            TextField(
              controller: _cveToUsd,
              enabled: !_saving,
              decoration: InputDecoration(labelText: l10n.adminCurrencyCveToUsd),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            if (updatedAt != null || (updatedBy?.isNotEmpty ?? false)) ...[
              SizedBox(height: AppLayout.md),
              AdminListCard(
                title: l10n.adminMonitoringLastUpdated,
                subtitle: [
                  if (updatedAt != null) updatedAt.toLocal().toString(),
                  if (updatedBy?.isNotEmpty ?? false) updatedBy!,
                ].join(' · '),
              ),
            ],
            SizedBox(height: AppLayout.lg),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.save),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _save() async {
    final cveToEur = double.tryParse(_cveToEur.text.trim());
    final cveToUsd = double.tryParse(_cveToUsd.text.trim());
    if (cveToEur == null ||
        cveToUsd == null ||
        cveToEur <= 0 ||
        cveToUsd <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminCurrencyInvalidRate)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final fields = <String, dynamic>{
        'cveToEur': cveToEur,
        'cveToUsd': cveToUsd,
      };
      final updatedBy = FirebaseAuth.instance.currentUser?.email ??
          FirebaseAuth.instance.currentUser?.uid;
      if (updatedBy != null && updatedBy.isNotEmpty) {
        fields['updatedBy'] = updatedBy;
      }
      await _repo.saveConfig('currency', fields);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminCurrencySaveSuccess)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.tryAgain)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class AdminSupportSettingsScreen extends StatefulWidget {
  const AdminSupportSettingsScreen({super.key, this.repository});

  final AdminModulesRepository? repository;

  @override
  State<AdminSupportSettingsScreen> createState() =>
      _AdminSupportSettingsScreenState();
}

class _AdminSupportSettingsScreenState extends State<AdminSupportSettingsScreen> {
  late final AdminModulesRepository _repo;
  StreamSubscription? _sub;
  final _phone = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AdminModulesRepository();
    _sub = _repo.watchConfig('support').listen((config) {
      if (!mounted) return;
      _phone.text = config.data['supportPhone'] as String? ?? '';
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AdminScaffold(
      title: l10n.adminSupportSettingsTitle,
      drawerSection: AdminDrawerSection.supportSettings,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppLayout.marginMobile,
          AppLayout.md,
          AppLayout.marginMobile,
          AppLayout.xxl,
        ),
        children: [
          AdminSectionHeader(
            title: l10n.adminSupportSettingsHeading,
            subtitle: l10n.adminSupportSettingsSubtitle,
          ),
          TextField(
            controller: _phone,
            decoration: InputDecoration(labelText: l10n.adminSupportPhoneLabel),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: AppLayout.lg),
          FilledButton(
            onPressed: () => _repo.saveConfig('support', {
              'supportPhone': _phone.text.trim(),
            }),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class AdminMonitoringSettingsScreen extends StatefulWidget {
  const AdminMonitoringSettingsScreen({super.key, this.repository});

  final AdminModulesRepository? repository;

  @override
  State<AdminMonitoringSettingsScreen> createState() =>
      _AdminMonitoringSettingsScreenState();
}

class _AdminMonitoringSettingsScreenState
    extends State<AdminMonitoringSettingsScreen> {
  static const _numericFields = [
    'dropoffWaitingRadiusMeters',
    'postDropoffGracePeriodMinutes',
    'routeDeviationCorridorMeters',
    'sustainedDeviationThresholdSeconds',
    'activeTripVarianceToleranceKm',
    'activeTripVarianceTolerancePct',
    'postDropoffLocalMovementAllowanceKm',
    'postDropoffVarianceToleranceKm',
    'postDropoffVarianceTolerancePct',
    'noTripLocalMovementAllowanceKm',
    'noTripMovementGracePeriodMinutes',
    'nextAssignmentSuppressionLookaheadMinutes',
    'staleTelemetryThresholdSeconds',
    'incidentClearanceThresholdSeconds',
    'replaySampleMinDistanceMeters',
    'replaySampleMinIntervalSeconds',
    'approvalDestinationArrivalRadiusMeters',
  ];

  late final AdminModulesRepository _repo;
  StreamSubscription? _sub;
  Map<String, dynamic> _config = const {};
  final Map<String, TextEditingController> _controllers = {};
  bool _enabled = false;
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AdminModulesRepository();
    for (final field in _numericFields) {
      _controllers[field] = TextEditingController();
    }
    _sub = _repo.watchConfig('operations_monitoring').listen((config) {
      if (!mounted) return;
      setState(() {
        _config = config.data;
        _enabled = config.data['enabled'] as bool? ?? false;
        if (!_loaded || !_saving) {
          _populateControllers(config.data);
          _loaded = true;
        }
      });
    });
  }

  void _populateControllers(Map<String, dynamic> data) {
    for (final field in _numericFields) {
      final value = data[field];
      _controllers[field]?.text = value == null ? '' : '$value';
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _fieldLabel(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match[0]}')
        .replaceFirstMapped(RegExp(r'^[a-z]'), (match) => match[0]!.toUpperCase());
  }

  String? _geofenceSummary(dynamic value) {
    if (value is! Map) return null;
    final map = Map<String, dynamic>.from(value);
    final label = map['label'] as String? ?? 'Base geofence';
    final radius = map['radiusMeters'];
    return '$label${radius == null ? '' : ' · ${radius}m'}';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final fields = <String, dynamic>{
        'enabled': _enabled,
        for (final field in _numericFields)
          field: double.tryParse(_controllers[field]!.text.trim()),
      };
      final updatedBy = FirebaseAuth.instance.currentUser?.email ??
          FirebaseAuth.instance.currentUser?.uid;
      if (updatedBy != null && updatedBy.isNotEmpty) {
        fields['updatedBy'] = updatedBy;
      }
      await _repo.saveConfig('operations_monitoring', fields);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminMonitoringSaveSuccess)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final baseGeofence = _geofenceSummary(_config['baseGeofence']);
    final serviceGeofences = _config['serviceGeofences'];
    final serviceCount = serviceGeofences is List ? serviceGeofences.length : 0;
    final updatedAt = adminTimestamp(_config['updatedAt']);
    final updatedBy = _config['updatedBy'] as String?;

    return AdminScaffold(
      title: l10n.adminMonitoringTitle,
      drawerSection: AdminDrawerSection.monitoring,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppLayout.marginMobile,
          AppLayout.md,
          AppLayout.marginMobile,
          AppLayout.xxl,
        ),
        children: [
          AdminSectionHeader(
            title: l10n.adminMonitoringHeading,
            subtitle: l10n.adminMonitoringSubtitle,
          ),
          if (!_loaded && _config.isEmpty)
            AdminEmptyState(message: l10n.adminMonitoringLoading)
          else ...[
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.adminMonitoringEnabled),
              subtitle: Text(l10n.adminMonitoringEnabledHint),
              value: _enabled,
              onChanged: _saving ? null : (value) => setState(() => _enabled = value),
            ),
            if (baseGeofence != null)
              AdminListCard(
                title: l10n.adminMonitoringBaseGeofence,
                subtitle: baseGeofence,
              ),
            if (serviceCount > 0) ...[
              SizedBox(height: AppLayout.md),
              AdminListCard(
                title: l10n.adminMonitoringServiceGeofences,
                subtitle: l10n.adminMonitoringServiceGeofenceCount(serviceCount),
              ),
            ],
            if (updatedAt != null || (updatedBy?.isNotEmpty ?? false)) ...[
              SizedBox(height: AppLayout.md),
              AdminListCard(
                title: l10n.adminMonitoringLastUpdated,
                subtitle: [
                  if (updatedAt != null) updatedAt.toLocal().toString(),
                  if (updatedBy?.isNotEmpty ?? false) updatedBy!,
                ].join('\n'),
              ),
            ],
            SizedBox(height: AppLayout.lg),
            for (final field in _numericFields) ...[
              TextField(
                controller: _controllers[field],
                enabled: !_saving,
                decoration: InputDecoration(labelText: _fieldLabel(field)),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: AppLayout.md),
            ],
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
          ],
        ],
      ),
    );
  }
}
