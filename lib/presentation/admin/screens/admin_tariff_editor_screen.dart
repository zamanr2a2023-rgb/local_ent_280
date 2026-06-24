import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/admin/data/admin_functions_service.dart';
import 'package:local_ent_280/features/admin/data/admin_modules_repository.dart';
import 'package:local_ent_280/features/admin/data/admin_tariff_payload.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';
import 'package:local_ent_280/presentation/admin/admin_drawer.dart';
import 'package:local_ent_280/presentation/admin/widgets/admin_scaffold.dart';

class AdminTariffEditorScreen extends StatefulWidget {
  const AdminTariffEditorScreen({super.key, this.repository});

  final AdminModulesRepository? repository;

  @override
  State<AdminTariffEditorScreen> createState() =>
      _AdminTariffEditorScreenState();
}

class _AdminTariffEditorScreenState extends State<AdminTariffEditorScreen> {
  late final AdminModulesRepository _repo;
  StreamSubscription? _tariffSub;
  StreamSubscription? _transportSub;
  Map<String, dynamic> _tariff = const {};
  List<AdminTransportTypeRecord> _transportTypes = const [];
  final _perKm = TextEditingController();
  final _perWaitMinute = TextEditingController();
  final _lateCancellation = TextEditingController();
  final _noShow = TextEditingController();
  final Map<String, TextEditingController> _baseFareControllers = {};
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AdminModulesRepository();
    _tariffSub = _repo.watchTariff('admin_default').listen((doc) {
      if (!mounted) return;
      final data = doc.data() ?? {};
      setState(() {
        _tariff = data;
        if (!_loaded || !_saving) {
          _syncFormFromTariff(data);
          _loaded = true;
        }
      });
    });
    _transportSub = _repo.watchTransportTypes().listen((types) {
      if (!mounted) return;
      setState(() {
        _transportTypes = types.where((t) => t.isActive).toList();
        _ensureBaseControllers();
        if (_loaded) _syncBaseFaresFromTariff(_tariff);
      });
    });
  }

  void _ensureBaseControllers() {
    for (final type in _transportTypes) {
      _baseFareControllers.putIfAbsent(type.id, TextEditingController.new);
    }
  }

  void _syncFormFromTariff(Map<String, dynamic> data) {
    _perKm.text = readEurMajor(data['perKm']).toStringAsFixed(2);
    _perWaitMinute.text = readEurMajor(data['perWaitMinute']).toStringAsFixed(2);
    final penalties = data['penaltyFees'];
    if (penalties is Map) {
      _lateCancellation.text =
          readEurMajor(penalties['lateCancellation']).toStringAsFixed(2);
      _noShow.text = readEurMajor(penalties['noShow']).toStringAsFixed(2);
    }
    _syncBaseFaresFromTariff(data);
  }

  void _syncBaseFaresFromTariff(Map<String, dynamic> data) {
    final baseByType = data['baseByTransportType'];
    for (final type in _transportTypes) {
      final controller = _baseFareControllers[type.id];
      if (controller == null) continue;
      if (baseByType is Map && baseByType[type.id] != null) {
        controller.text =
            readEurMajor(baseByType[type.id]).toStringAsFixed(2);
      } else {
        controller.text = type.baseFareEur.toStringAsFixed(2);
      }
    }
  }

  @override
  void dispose() {
    _tariffSub?.cancel();
    _transportSub?.cancel();
    _perKm.dispose();
    _perWaitMinute.dispose();
    _lateCancellation.dispose();
    _noShow.dispose();
    for (final controller in _baseFareControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double? _parseEur(String text) {
    final normalized = text.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    if (_transportTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminTariffNoTransportTypes)),
      );
      return;
    }

    final perKm = _parseEur(_perKm.text);
    final perWait = _parseEur(_perWaitMinute.text);
    final lateCancel = _parseEur(_lateCancellation.text);
    final noShow = _parseEur(_noShow.text);
    if (perKm == null ||
        perWait == null ||
        lateCancel == null ||
        noShow == null ||
        perKm < 0 ||
        perWait < 0 ||
        lateCancel < 0 ||
        noShow < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminTariffInvalidAmounts)),
      );
      return;
    }

    final baseFares = <String, int>{};
    for (final type in _transportTypes) {
      final controller = _baseFareControllers[type.id];
      final value = _parseEur(controller?.text ?? '');
      if (value == null || value < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.adminTariffInvalidBaseFare(type.name))),
        );
        return;
      }
      baseFares[type.id] = (value * 100).round();
    }

    final payload = buildAdminTariffCallablePayload(
      currentTariff: _tariff,
      baseFareMinorByTransportType: baseFares,
      perKmMinor: (perKm * 100).round(),
      perWaitMinuteMinor: (perWait * 100).round(),
      lateCancellationMinor: (lateCancel * 100).round(),
      noShowMinor: (noShow * 100).round(),
    );

    setState(() => _saving = true);
    try {
      await _repo.saveAdminTariff(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.save)),
      );
    } on AdminFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatter = AppCurrencyFormatter.instance;

    return AdminScaffold(
      title: l10n.adminTariffsTitle,
      drawerSection: AdminDrawerSection.tariffs,
      body: !_loaded && _tariff.isEmpty
          ? AdminEmptyState(message: l10n.adminMonitoringLoading)
          : ListView(
              padding: EdgeInsets.fromLTRB(
                AppLayout.marginMobile,
                AppLayout.md,
                AppLayout.marginMobile,
                AppLayout.xxl,
              ),
              children: [
                AdminSectionHeader(
                  title: l10n.adminTariffsTitle,
                  subtitle: l10n.adminTariffsDesc,
                ),
                _MoneyField(
                  label: 'Per km (${formatter.displaySymbol})',
                  controller: _perKm,
                ),
                SizedBox(height: AppLayout.md),
                _MoneyField(
                  label: 'Per wait minute (${formatter.displaySymbol})',
                  controller: _perWaitMinute,
                ),
                SizedBox(height: AppLayout.lg),
                Text(
                  'Base fare by transport type',
                  style: AppTypography.manrope(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: AppLayout.sm),
                for (final type in _transportTypes) ...[
                  _MoneyField(
                    label: type.name,
                    controller: _baseFareControllers[type.id]!,
                  ),
                  SizedBox(height: AppLayout.sm),
                ],
                SizedBox(height: AppLayout.md),
                Text(
                  'Penalty fees',
                  style: AppTypography.manrope(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: AppLayout.sm),
                _MoneyField(
                  label: 'Late cancellation',
                  controller: _lateCancellation,
                ),
                SizedBox(height: AppLayout.sm),
                _MoneyField(
                  label: 'No show',
                  controller: _noShow,
                ),
                if (_tariff.isNotEmpty) ...[
                  SizedBox(height: AppLayout.lg),
                  AdminListCard(
                    title: l10n.adminTariffPublicDefault,
                    subtitle: formatTariffSummary(_tariff),
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
            ),
    );
  }
}

class _MoneyField extends StatelessWidget {
  const _MoneyField({
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }
}
