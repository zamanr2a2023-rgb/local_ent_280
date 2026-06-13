import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/features/auth/data/user_session.dart';
import 'package:local_ent_280/features/balance/data/balance_repository.dart';
import 'package:local_ent_280/presentation/widgets/app_bottom_nav.dart';
import 'package:local_ent_280/presentation/widgets/client_drawer.dart';

class ClientBalanceScreen extends StatefulWidget {
  const ClientBalanceScreen({super.key, this.balanceRepository});

  final BalanceRepository? balanceRepository;

  @override
  State<ClientBalanceScreen> createState() => _ClientBalanceScreenState();
}

class _ClientBalanceScreenState extends State<ClientBalanceScreen> {
  late final BalanceRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = widget.balanceRepository ?? BalanceRepository();
  }

  void _showTopUpComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.clientBalanceTopUpComingSoon)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final clientId = UserSession.instance.profile?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const ClientDrawer(selected: ClientDrawerSection.home),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _BalanceAppBar(title: l10n.clientBalanceTitle),
            Expanded(
              child: clientId == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: EdgeInsets.fromLTRB(
                        AppLayout.marginMobile,
                        16.h,
                        AppLayout.marginMobile,
                        96.h,
                      ),
                      children: [
                        Text(
                          l10n.clientBalanceSubtitle,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        StreamBuilder<ClientBalanceProfile?>(
                          stream: _repository.watchClientBalanceProfile(clientId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final profile = snapshot.data;
                            if (profile == null) {
                              return _InfoCard(
                                title: l10n.clientBalanceUnavailable,
                                subtitle: l10n.tryAgain,
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _BalanceHeroCard(profile: profile),
                                if (profile.isBlockedByDebtLimit) ...[
                                  SizedBox(height: 12.h),
                                  _DebtWarningCard(
                                    title: l10n.clientBalanceDebtWarningTitle,
                                    body: l10n.clientBalanceDebtWarningBody,
                                  ),
                                ],
                                SizedBox(height: 12.h),
                                _InfoCard(
                                  title: l10n.clientBalanceDebtLimit,
                                  subtitle: profile.formattedDebtLimit,
                                  trailing: Icons.trending_down,
                                ),
                                if (profile.updatedAt != null) ...[
                                  SizedBox(height: 12.h),
                                  _InfoCard(
                                    title: l10n.clientBalanceLastUpdated,
                                    subtitle: profile.updatedAt!
                                        .toLocal()
                                        .toString(),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 24.h),
                        FilledButton(
                          onPressed: _showTopUpComingSoon,
                          child: Text(l10n.homeTopUp),
                        ),
                        SizedBox(height: 28.h),
                        Text(
                          l10n.clientBalanceHistoryTitle,
                          style: GoogleFonts.manrope(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        StreamBuilder<List<BalanceAdjustmentRecord>>(
                          stream: _repository.watchClientBalanceAdjustments(
                            clientId,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final items = snapshot.data ?? const [];
                            if (items.isEmpty) {
                              return _InfoCard(
                                title: l10n.clientBalanceHistoryEmpty,
                                subtitle: l10n.clientBalanceHistoryEmptyBody,
                              );
                            }
                            return Column(
                              children: [
                                for (final item in items) ...[
                                  _AdjustmentCard(record: item),
                                  SizedBox(height: 10.h),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
            ),
            AppBottomNav(
              selectedIndex: AppNavIndex.inicio,
              onItemTap: (index) => AppNavigation.onBottomNavTap(context, index),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceAppBar extends StatelessWidget {
  const _BalanceAppBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: AppLayout.marginMobile),
      color: AppColors.background,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back, color: AppColors.primary, size: 24.sp),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceHeroCard extends StatelessWidget {
  const _BalanceHeroCard({required this.profile});

  final ClientBalanceProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isNegative = profile.balanceMinor < 0;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.surfaceVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.secondary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeAvailableBalance,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.labelMuted,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  profile.formattedBalance,
                  style: GoogleFonts.manrope(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: isNegative ? AppColors.error : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtWarningCard extends StatelessWidget {
  const _DebtWarningCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  body,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.surfaceVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          if (trailing != null) ...[
            Icon(trailing, color: AppColors.secondary, size: 20.sp),
            SizedBox(width: 10.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.labelMuted,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdjustmentCard extends StatelessWidget {
  const _AdjustmentCard({required this.record});

  final BalanceAdjustmentRecord record;

  @override
  Widget build(BuildContext context) {
    final isCredit = record.deltaMinor >= 0;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.surfaceVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCredit ? Icons.add_circle_outline : Icons.remove_circle_outline,
            color: isCredit ? AppColors.secondary : AppColors.error,
            size: 22.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.reason.isEmpty
                      ? context.l10n.clientBalanceAdjustmentDefault
                      : record.reason,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (record.createdAt != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    record.createdAt!.toLocal().toString(),
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            record.formattedDelta,
            style: GoogleFonts.manrope(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: isCredit ? AppColors.secondary : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
