import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/admin/data/admin_reports_statement_repository.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';
import 'package:local_ent_280/features/admin/data/models/admin_statement_models.dart';

class AdminClientStatementTab extends StatefulWidget {
  const AdminClientStatementTab({super.key, this.repository});

  final AdminReportsStatementRepository? repository;

  @override
  State<AdminClientStatementTab> createState() => _AdminClientStatementTabState();
}

class _AdminClientStatementTabState extends State<AdminClientStatementTab> {
  late final AdminReportsStatementRepository _repo;
  StreamSubscription? _clientsSub;
  List<AdminBalanceRecord> _clients = const [];
  AdminBalanceRecord? _selectedClient;
  ClientStatementSummary _summary = ClientStatementSummary.empty;
  bool _loading = false;

  DateTime get _rangeStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  DateTime get _rangeEnd {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AdminReportsStatementRepository();
    _clientsSub = _repo.watchClients().listen((clients) {
      if (!mounted) return;
      setState(() {
        _clients = clients;
        if (_selectedClient == null && clients.isNotEmpty) {
          _selectedClient = clients.first;
          _loadStatement();
        }
      });
    });
  }

  @override
  void dispose() {
    _clientsSub?.cancel();
    super.dispose();
  }

  Future<void> _loadStatement() async {
    final client = _selectedClient;
    if (client == null) return;
    setState(() => _loading = true);
    try {
      final summary = await _repo.buildClientStatement(
        clientId: client.userId,
        clientName: client.userName,
        rangeStart: _rangeStart,
        rangeEnd: _rangeEnd,
      );
      if (!mounted) return;
      setState(() => _summary = summary);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatMoney(int minor) =>
      AppCurrencyFormatter.instance.formatEurMinor(minor);

  String _monthLabel() => DateFormat.yMMMM().format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_clients.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppLayout.marginMobile),
          child: Text(
            l10n.adminReportsTabComingSoon,
            textAlign: TextAlign.center,
            style: AppTypography.inter(color: AppColors.onSurfaceVariant),
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppLayout.marginMobile,
        AppLayout.md,
        AppLayout.marginMobile,
        AppLayout.xxl,
      ),
      children: [
        Text(
          _monthLabel(),
          style: AppTypography.inter(
            fontSize: 13.sp,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppLayout.sm),
        DropdownButtonFormField<AdminBalanceRecord>(
          value: _selectedClient,
          decoration: InputDecoration(
            labelText: l10n.adminReportsTabClient,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          items: _clients
              .map(
                (client) => DropdownMenuItem(
                  value: client,
                  child: Text(client.userName),
                ),
              )
              .toList(),
          onChanged: (client) {
            if (client == null) return;
            setState(() => _selectedClient = client);
            _loadStatement();
          },
        ),
        SizedBox(height: AppLayout.md),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else ...[
          _SummaryCard(
            title: l10n.adminBalanceCurrent,
            value: _formatMoney(_summary.currentBalanceMinor),
          ),
          SizedBox(height: AppLayout.sm),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Debits',
                  value: _formatMoney(_summary.totalDebitsMinor),
                  accent: AppColors.error,
                ),
              ),
              SizedBox(width: AppLayout.sm),
              Expanded(
                child: _SummaryCard(
                  title: 'Credits',
                  value: _formatMoney(_summary.totalCreditsMinor),
                  accent: AppColors.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppLayout.lg),
          Text(
            'Movements',
            style: AppTypography.manrope(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppLayout.sm),
          if (_summary.entries.isEmpty)
            Text(
              l10n.adminNoReportActivities,
              style: AppTypography.inter(color: AppColors.onSurfaceVariant),
            )
          else
            for (final entry in _summary.entries)
              _MovementTile(
                date: entry.date,
                description: entry.description,
                amount: entry.debitMinor > 0
                    ? '-${_formatMoney(entry.debitMinor)}'
                    : '+${_formatMoney(entry.creditMinor)}',
                isDebit: entry.debitMinor > 0,
              ),
        ],
      ],
    );
  }
}

class AdminDriverStatementTab extends StatefulWidget {
  const AdminDriverStatementTab({super.key, this.repository});

  final AdminReportsStatementRepository? repository;

  @override
  State<AdminDriverStatementTab> createState() => _AdminDriverStatementTabState();
}

class _AdminDriverStatementTabState extends State<AdminDriverStatementTab> {
  late final AdminReportsStatementRepository _repo;
  StreamSubscription? _driversSub;
  List<AdminUserRecord> _drivers = const [];
  AdminUserRecord? _selectedDriver;
  DriverStatementSummary _summary = DriverStatementSummary.empty;
  bool _loading = false;

  DateTime get _rangeStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  DateTime get _rangeEnd {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AdminReportsStatementRepository();
    _driversSub = _repo.watchDrivers().listen((drivers) {
      if (!mounted) return;
      setState(() {
        _drivers = drivers;
        if (_selectedDriver == null && drivers.isNotEmpty) {
          _selectedDriver = drivers.first;
          _loadStatement();
        }
      });
    });
  }

  @override
  void dispose() {
    _driversSub?.cancel();
    super.dispose();
  }

  Future<void> _loadStatement() async {
    final driver = _selectedDriver;
    if (driver == null) return;
    setState(() => _loading = true);
    try {
      final summary = await _repo.buildDriverStatement(
        driverId: driver.id,
        driverName: driver.name,
        rangeStart: _rangeStart,
        rangeEnd: _rangeEnd,
      );
      if (!mounted) return;
      setState(() => _summary = summary);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatMoney(int minor) =>
      AppCurrencyFormatter.instance.formatEurMinor(minor);

  String _monthLabel() => DateFormat.yMMMM().format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_drivers.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppLayout.marginMobile),
          child: Text(
            l10n.adminNoReportActivities,
            textAlign: TextAlign.center,
            style: AppTypography.inter(color: AppColors.onSurfaceVariant),
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppLayout.marginMobile,
        AppLayout.md,
        AppLayout.marginMobile,
        AppLayout.xxl,
      ),
      children: [
        Text(
          _monthLabel(),
          style: AppTypography.inter(
            fontSize: 13.sp,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppLayout.sm),
        DropdownButtonFormField<AdminUserRecord>(
          value: _selectedDriver,
          decoration: InputDecoration(
            labelText: l10n.adminReportsTabDriver,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          items: _drivers
              .map(
                (driver) => DropdownMenuItem(
                  value: driver,
                  child: Text(driver.name),
                ),
              )
              .toList(),
          onChanged: (driver) {
            if (driver == null) return;
            setState(() => _selectedDriver = driver);
            _loadStatement();
          },
        ),
        SizedBox(height: AppLayout.md),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else ...[
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: l10n.adminReportsTotalTrips,
                  value: '${_summary.tripCount}',
                ),
              ),
              SizedBox(width: AppLayout.sm),
              Expanded(
                child: _SummaryCard(
                  title: l10n.adminReportsTotalDistance,
                  value: '${_summary.totalDistanceKm.toStringAsFixed(1)} km',
                ),
              ),
            ],
          ),
          SizedBox(height: AppLayout.sm),
          _SummaryCard(
            title: l10n.adminReportsTotalCost,
            value: _formatMoney(_summary.totalGrossMinor),
          ),
          SizedBox(height: AppLayout.lg),
          if (_summary.entries.isEmpty)
            Text(
              l10n.adminNoReportActivities,
              style: AppTypography.inter(color: AppColors.onSurfaceVariant),
            )
          else
            for (final entry in _summary.entries)
              _DriverTripTile(
                date: entry.date,
                destination: entry.destination,
                distanceKm: entry.distanceKm,
                minutes: entry.minutes,
                gross: _formatMoney(entry.grossMinor),
                reference: entry.tripId.length > 8
                    ? entry.tripId.substring(0, 8).toUpperCase()
                    : entry.tripId,
              ),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    this.accent,
  });

  final String title;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppLayout.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: accent != null
            ? Border(left: BorderSide(color: accent!, width: 3.w))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.inter(
              fontSize: 12.sp,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: AppTypography.manrope(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: accent ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  const _MovementTile({
    required this.date,
    required this.description,
    required this.amount,
    required this.isDebit,
  });

  final DateTime? date;
  final String description;
  final String amount;
  final bool isDebit;

  @override
  Widget build(BuildContext context) {
    final dateLabel = date == null
        ? '—'
        : DateFormat('dd/MM/yyyy').format(date!.toLocal());

    return Container(
      margin: EdgeInsets.only(bottom: AppLayout.sm),
      padding: EdgeInsets.all(AppLayout.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.surfaceVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  dateLabel,
                  style: AppTypography.inter(
                    fontSize: 12.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTypography.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: isDebit ? AppColors.error : AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverTripTile extends StatelessWidget {
  const _DriverTripTile({
    required this.date,
    required this.destination,
    required this.distanceKm,
    required this.minutes,
    required this.gross,
    required this.reference,
  });

  final DateTime? date;
  final String destination;
  final double distanceKm;
  final int minutes;
  final String gross;
  final String reference;

  @override
  Widget build(BuildContext context) {
    final dateLabel = date == null
        ? '—'
        : DateFormat('dd/MM/yyyy').format(date!.toLocal());

    return Container(
      margin: EdgeInsets.only(bottom: AppLayout.sm),
      padding: EdgeInsets.all(AppLayout.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.surfaceVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$reference · $dateLabel · ${distanceKm.toStringAsFixed(1)} km · $minutes min',
                  style: AppTypography.inter(
                    fontSize: 12.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            gross,
            style: AppTypography.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
