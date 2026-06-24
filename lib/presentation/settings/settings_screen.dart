import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/settings/user_preferences.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/app/presentation/providers/repository_scope.dart';
import 'package:local_ent_280/features/auth/domain/repositories/auth_repository.dart';
import 'package:local_ent_280/l10n/app_localizations.dart';

/// App settings — language, currency and account actions.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, AuthRepository? authRepository})
      : _authRepository = authRepository;

  final AuthRepository? _authRepository;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AuthRepository get _authRepository =>
      widget._authRepository ?? authRepositoryOf(context);
  late final UserPreferences _preferences = UserPreferences.instance;

  bool _isSigningOut = false;
  bool _isUpdatingLanguage = false;
  bool _isUpdatingCurrency = false;

  @override
  void initState() {
    super.initState();
    _preferences.addListener(_onPreferencesChanged);
  }

  @override
  void dispose() {
    _preferences.removeListener(_onPreferencesChanged);
    super.dispose();
  }

  void _onPreferencesChanged() {
    if (mounted) setState(() {});
  }

  bool get _isAuthenticated => _authRepository.currentUser != null;

  String _languageLabel(AppLocalizations l10n, Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return l10n.settingsLanguageEnglish;
      case 'es':
        return l10n.settingsLanguageSpanish;
      default:
        return l10n.settingsLanguagePortuguese;
    }
  }

  String _currencyLabel(AppLocalizations l10n, DisplayCurrency currency) {
    switch (currency) {
      case DisplayCurrency.cve:
        return l10n.settingsCurrencyCve;
      case DisplayCurrency.eur:
        return l10n.settingsCurrencyEur;
      case DisplayCurrency.usd:
        return l10n.settingsCurrencyUsd;
    }
  }

  Future<void> _confirmSignOut() async {
    if (_isSigningOut) return;
    final l10n = context.l10n;

    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            l10n.signOutTitle,
            style: AppTypography.manrope(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          content: Text(
            l10n.signOutConfirmMessage,
            style: AppTypography.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              height: 20 / 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                l10n.cancel,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                l10n.signOut,
                style: AppTypography.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true || !mounted) return;
    await _signOut();
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await _authRepository.signOut();
      if (!mounted) return;
      AppNavigation.signOutToLogin(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.signOutFailed,
            style: AppTypography.inter(fontSize: 14.sp),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.featureComingSoon(feature),
          style: AppTypography.inter(fontSize: 14.sp),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(AppLocalizations l10n) {
    final deviceLocale = View.of(context).platformDispatcher.locale;
    final effectiveLocale = _preferences.effectiveLocale(deviceLocale);
    final selectedLocale = _preferences.localeOverride ?? effectiveLocale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsLanguage,
          style: AppTypography.manrope(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          l10n.settingsLanguageDescription,
          style: AppTypography.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 12.h),
        DropdownButtonFormField<Locale>(
          key: ValueKey<String>(selectedLocale.toLanguageTag()),
          initialValue: selectedLocale,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          items: UserPreferences.selectableLocales
              .map(
                (locale) => DropdownMenuItem<Locale>(
                  value: locale,
                  child: Text(
                    _languageLabel(l10n, locale),
                    style: AppTypography.inter(fontSize: 14.sp),
                  ),
                ),
              )
              .toList(),
          onChanged: _isUpdatingLanguage
              ? null
              : (locale) async {
                  if (locale == null) return;
                  setState(() => _isUpdatingLanguage = true);
                  await _preferences.setLanguage(locale);
                  if (!mounted) return;
                  setState(() => _isUpdatingLanguage = false);
                },
        ),
        SizedBox(height: 8.h),
        Text(
          _preferences.localeOverride == null
              ? l10n.settingsLanguageFollowingDevice(
                  _languageLabel(l10n, effectiveLocale),
                )
              : l10n.settingsLanguageManual(
                  _languageLabel(l10n, _preferences.localeOverride!),
                ),
          style: AppTypography.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            height: 16 / 12,
            color: AppColors.labelMuted,
          ),
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: _preferences.localeOverride == null || _isUpdatingLanguage
                ? null
                : () async {
                    setState(() => _isUpdatingLanguage = true);
                    await _preferences.resetToDeviceLanguage(
                      View.of(context).platformDispatcher.locale,
                    );
                    if (!mounted) return;
                    setState(() => _isUpdatingLanguage = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.settingsLanguageResetSnack,
                          style: AppTypography.inter(fontSize: 14.sp),
                        ),
                      ),
                    );
                  },
            child: Text(
              l10n.settingsUseDeviceLanguage,
              style: AppTypography.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencySelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsDisplayCurrency,
          style: AppTypography.manrope(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          l10n.settingsDisplayCurrencyDescription,
          style: AppTypography.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 12.h),
        DropdownButtonFormField<DisplayCurrency>(
          key: ValueKey<DisplayCurrency>(_preferences.displayCurrency),
          initialValue: _preferences.displayCurrency,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          items: UserPreferences.selectableCurrencies
              .map(
                (currency) => DropdownMenuItem<DisplayCurrency>(
                  value: currency,
                  child: Text(
                    _currencyLabel(l10n, currency),
                    style: AppTypography.inter(fontSize: 14.sp),
                  ),
                ),
              )
              .toList(),
          onChanged: _isUpdatingCurrency
              ? null
              : (currency) async {
                  if (currency == null) return;
                  setState(() => _isUpdatingCurrency = true);
                  await _preferences.setDisplayCurrency(currency);
                  if (!mounted) return;
                  setState(() => _isUpdatingCurrency = false);
                },
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsAccountSection,
          style: AppTypography.manrope(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 12.h),
        _buildPrimaryButton(
          label: l10n.settingsChangePassword,
          onPressed: () => _showComingSoon(l10n.settingsChangePassword),
        ),
        SizedBox(height: 12.h),
        _buildPrimaryButton(
          label: l10n.settingsSignOutAction,
          onPressed: _isAuthenticated && !_isSigningOut ? _confirmSignOut : null,
        ),
      ],
    );
  }

  Widget _buildDriverLocationSimulationToggle(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsDriverLocationSimulationTitle,
          style: AppTypography.manrope(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          l10n.settingsDriverLocationSimulationDescription,
          style: AppTypography.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 12.h),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(
            l10n.settingsDriverLocationSimulationSwitchLabel,
            style: AppTypography.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
          value: _preferences.driverLocationSimulationEnabled,
          onChanged: (enabled) {
            _preferences.setDriverLocationSimulationEnabled(enabled);
          },
        ),
      ],
    );
  }

  Widget _buildDeveloperSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsDeveloperSection,
          style: AppTypography.manrope(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 12.h),
        _buildDriverLocationSimulationToggle(l10n),
        SizedBox(height: 12.h),
        _buildPrimaryButton(
          label: l10n.settingsResetOnboarding,
          onPressed: () async {
            await _preferences.resetOnboarding();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n.settingsResetDone,
                  style: AppTypography.inter(fontSize: 14.sp),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.primary,
        title: Text(
          l10n.settingsTitle,
          style: AppTypography.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppLayout.marginMobile),
          children: [
            Text(
              l10n.settingsSubtitle,
              style: AppTypography.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                height: 20 / 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 24.h),
            _buildLanguageSelector(l10n),
            SizedBox(height: 24.h),
            _buildCurrencySelector(l10n),
            SizedBox(height: 24.h),
            _buildAccountSection(l10n),
            if (kDebugMode) ...[
              SizedBox(height: 24.h),
              _buildDeveloperSection(l10n),
            ],
          ],
        ),
      ),
    );
  }
}
