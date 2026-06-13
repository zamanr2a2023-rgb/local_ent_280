import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/features/auth/data/user_session.dart';
import 'package:local_ent_280/presentation/widgets/drawer_user_card.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/auth/data/auth_repository.dart';
import 'package:local_ent_280/presentation/login/login_screen.dart';
import 'package:material_symbols_icons/symbols.dart';

enum AdminDrawerSection {
  home,
  hub,
  users,
  managerPermissions,
  support,
  incidents,
  monitoring,
  reservations,
  supportSettings,
  events,
  fleet,
  transportTypes,
  tripPackages,
  tariffs,
  balances,
  currency,
  reports,
  audit,
  profile,
  settings,
}

/// Admin navigation drawer with all module links.
class AdminDrawer extends StatelessWidget {
  const AdminDrawer({
    super.key,
    required this.selected,
    AuthRepository? authRepository,
  }) : _authRepository = authRepository;

  final AdminDrawerSection selected;
  final AuthRepository? _authRepository;

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = context.l10n;
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);

    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.signOutTitle),
          content: Text(l10n.signOutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                l10n.signOut,
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true) return;

    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    try {
      await (_authRepository ?? AuthRepository()).signOut();
      rootNavigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.signOutFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Drawer(
      backgroundColor: AppColors.background,
      width: 300.w,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppLayout.md,
                AppLayout.lg,
                AppLayout.md,
                AppLayout.lg,
              ),
              child: Text(
                l10n.adminAppBarTitle,
                style: AppTypography.manrope(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            DrawerUserCard(profile: UserSession.instance.profile),
            SizedBox(height: AppLayout.md),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: AppLayout.md),
                children: [
                  _nav(context, Symbols.dashboard, l10n.navHome, AdminDrawerSection.home, AppNavigation.goAdminDashboard),
                  _nav(context, Symbols.apps, l10n.adminHubTitle, AdminDrawerSection.hub, AppNavigation.toAdminHub),
                  _nav(context, Symbols.group, l10n.adminUsersTitle, AdminDrawerSection.users, AppNavigation.toAdminUsers),
                  _nav(context, Symbols.admin_panel_settings, l10n.adminManagerPermissionsTitle, AdminDrawerSection.managerPermissions, AppNavigation.toAdminManagerPermissions),
                  _nav(context, Symbols.support_agent, l10n.adminSupportRequestsTitle, AdminDrawerSection.support, AppNavigation.toAdminSupportRequests),
                  _nav(context, Symbols.warning, l10n.adminIncidentsTitle, AdminDrawerSection.incidents, AppNavigation.toAdminIncidents),
                  _nav(context, Symbols.local_shipping, l10n.adminFleetTitle, AdminDrawerSection.fleet, AppNavigation.toAdminFleet),
                  _nav(context, Symbols.account_balance_wallet, l10n.adminBalancesTitle, AdminDrawerSection.balances, AppNavigation.toAdminBalances),
                  _nav(context, Symbols.calendar_month, l10n.adminReservationsTitle, AdminDrawerSection.reservations, AppNavigation.toAdminReservations),
                  _nav(context, Symbols.campaign, l10n.adminEventsTitle, AdminDrawerSection.events, AppNavigation.toAdminEvents),
                  _nav(context, Symbols.category, l10n.adminTransportTypesTitle, AdminDrawerSection.transportTypes, AppNavigation.toAdminTransportTypes),
                  _nav(context, Symbols.luggage, l10n.adminTripPackagesTitle, AdminDrawerSection.tripPackages, AppNavigation.toAdminTripPackages),
                  _nav(context, Symbols.payments, l10n.adminTariffsTitle, AdminDrawerSection.tariffs, AppNavigation.toAdminTariffs),
                  _nav(context, Symbols.currency_exchange, l10n.adminCurrencyTitle, AdminDrawerSection.currency, AppNavigation.toAdminCurrencySettings),
                  _nav(context, Symbols.call, l10n.adminSupportSettingsTitle, AdminDrawerSection.supportSettings, AppNavigation.toAdminSupportSettings),
                  _nav(context, Symbols.tune, l10n.adminMonitoringTitle, AdminDrawerSection.monitoring, AppNavigation.toAdminMonitoringSettings),
                  _nav(context, Symbols.analytics, l10n.adminReportsTitle, AdminDrawerSection.reports, AppNavigation.goAdminReports, filled: true),
                  _nav(context, Symbols.receipt_long, l10n.adminAuditTitle, AdminDrawerSection.audit, AppNavigation.toAdminAudit),
                  _nav(context, Symbols.person, l10n.navProfile, AdminDrawerSection.profile, AppNavigation.toProfile),
                  _nav(context, Symbols.settings, l10n.settingsTitle, AdminDrawerSection.settings, AppNavigation.toSettings),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppLayout.md),
              child: _DrawerNavItem(
                icon: Symbols.logout,
                label: l10n.signOut,
                isSelected: false,
                isDestructive: true,
                onTap: () => _confirmSignOut(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nav(
    BuildContext context,
    IconData icon,
    String label,
    AdminDrawerSection section,
    void Function(BuildContext context) onTap, {
    bool filled = false,
  }) {
    return _DrawerNavItem(
      icon: icon,
      label: label,
      isSelected: selected == section,
      filledIcon: filled,
      onTap: () {
        Navigator.of(context).pop();
        if (selected != section) onTap(context);
      },
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  const _DrawerNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.filledIcon = false,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool filledIcon;
  final bool isDestructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isDestructive
        ? AppColors.error
        : isSelected
            ? AppColors.onSecondaryContainer
            : AppColors.onSurfaceVariant;
    final background = isSelected
        ? AppColors.secondaryContainer
        : Colors.transparent;

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999.r),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppLayout.md,
              vertical: 10.h,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22.sp,
                  color: foreground,
                  fill: filledIcon && isSelected ? 1 : 0,
                ),
                SizedBox(width: AppLayout.md),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
