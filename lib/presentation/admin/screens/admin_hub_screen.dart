import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/presentation/admin/admin_drawer.dart';
import 'package:local_ent_280/presentation/admin/widgets/admin_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';

class AdminHubScreen extends StatelessWidget {
  const AdminHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final modules = _modules(context);

    return AdminScaffold(
      title: l10n.adminHubTitle,
      drawerSection: AdminDrawerSection.hub,
      showBack: false,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppLayout.marginMobile,
          AppLayout.md,
          AppLayout.marginMobile,
          AppLayout.xxl,
        ),
        children: [
          AdminSectionHeader(
            title: l10n.adminHubHeading,
            subtitle: l10n.adminHubSubtitle,
          ),
          for (final module in modules) ...[
            _ModuleCard(module: module),
            SizedBox(height: AppLayout.md),
          ],
        ],
      ),
    );
  }

  List<_AdminModule> _modules(BuildContext context) {
    final l10n = context.l10n;
    return [
      _AdminModule(l10n.adminUsersTitle, l10n.adminUsersDesc, Symbols.group, AppNavigation.toAdminUsers),
      _AdminModule(l10n.adminManagerPermissionsTitle, l10n.adminManagerPermissionsDesc, Symbols.admin_panel_settings, AppNavigation.toAdminManagerPermissions),
      _AdminModule(l10n.adminSupportRequestsTitle, l10n.adminSupportRequestsDesc, Symbols.support_agent, AppNavigation.toAdminSupportRequests),
      _AdminModule(l10n.adminIncidentsTitle, l10n.adminIncidentsDesc, Symbols.warning, AppNavigation.toAdminIncidents),
      _AdminModule(l10n.adminMonitoringTitle, l10n.adminMonitoringDesc, Symbols.tune, AppNavigation.toAdminMonitoringSettings),
      _AdminModule(l10n.adminReservationsTitle, l10n.adminReservationsDesc, Symbols.calendar_month, AppNavigation.toAdminReservations),
      _AdminModule(l10n.adminSupportSettingsTitle, l10n.adminSupportSettingsDesc, Symbols.call, AppNavigation.toAdminSupportSettings),
      _AdminModule(l10n.adminEventsTitle, l10n.adminEventsDesc, Symbols.campaign, AppNavigation.toAdminEvents),
      _AdminModule(l10n.adminFleetTitle, l10n.adminFleetDesc, Symbols.local_shipping, AppNavigation.toAdminFleet),
      _AdminModule(l10n.adminTransportTypesTitle, l10n.adminTransportTypesDesc, Symbols.category, AppNavigation.toAdminTransportTypes),
      _AdminModule(l10n.adminTripPackagesTitle, l10n.adminTripPackagesDesc, Symbols.luggage, AppNavigation.toAdminTripPackages),
      _AdminModule(l10n.adminTariffsTitle, l10n.adminTariffsDesc, Symbols.payments, AppNavigation.toAdminTariffs),
      _AdminModule(l10n.adminBalancesTitle, l10n.adminBalancesDesc, Symbols.account_balance_wallet, AppNavigation.toAdminBalances),
      _AdminModule(l10n.adminCurrencyTitle, l10n.adminCurrencyDesc, Symbols.currency_exchange, AppNavigation.toAdminCurrencySettings),
      _AdminModule(l10n.adminReportsTitle, l10n.adminReportsDesc, Symbols.bar_chart, AppNavigation.toAdminReports),
      _AdminModule(l10n.adminAuditTitle, l10n.adminAuditDesc, Symbols.receipt_long, AppNavigation.toAdminAudit),
    ];
  }
}

class _AdminModule {
  const _AdminModule(this.title, this.description, this.icon, this.onTap);

  final String title;
  final String description;
  final IconData icon;
  final void Function(BuildContext context) onTap;
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});

  final _AdminModule module;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: () => module.onTap(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(AppLayout.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.surfaceVariant),
          ),
          child: Row(
            children: [
              Icon(module.icon, color: AppColors.secondary, size: 28.sp),
              SizedBox(width: AppLayout.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: AppTypography.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      module.description,
                      style: AppTypography.inter(
                        fontSize: 13.sp,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.outline),
            ],
          ),
        ),
      ),
    );
  }
}
