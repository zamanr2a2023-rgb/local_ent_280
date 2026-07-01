import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';

/// Shows rationale dialogs and triggers the OS location permission prompt.
class LocationPermissionHelper {
  const LocationPermissionHelper._();

  static Future<bool> ensureGranted(
    BuildContext context, {
    String? title,
    String? message,
    String? settingsMessage,
    String? servicesDisabledMessage,
  }) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) return false;
      await _showLocationServicesDialog(
        context,
        servicesDisabledMessage: servicesDisabledMessage,
      );
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return true;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!context.mounted) return false;
      return _showOpenSettingsDialog(
        context,
        title: title,
        settingsMessage: settingsMessage,
      );
    }

    if (!context.mounted) return false;
    final shouldRequest = await _showRationaleDialog(
      context,
      title: title,
      message: message,
    );
    if (!shouldRequest) return false;

    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return true;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!context.mounted) return false;
      return _showOpenSettingsDialog(
        context,
        title: title,
        settingsMessage: settingsMessage,
      );
    }

    return false;
  }

  static Future<bool> _showRationaleDialog(
    BuildContext context, {
    String? title,
    String? message,
  }) async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title ?? l10n.homeLocationPermissionTitle),
          content: Text(message ?? l10n.homeLocationPermissionMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.homeLocationPermissionDeny),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                l10n.homeLocationPermissionAllow,
                style: const TextStyle(color: AppColors.accent),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  static Future<bool> _showOpenSettingsDialog(
    BuildContext context, {
    String? title,
    String? settingsMessage,
  }) async {
    final l10n = context.l10n;
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title ?? l10n.homeLocationPermissionTitle),
          content: Text(
            settingsMessage ?? l10n.homeLocationPermissionSettingsMessage,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.homeLocationOpenSettings),
            ),
          ],
        );
      },
    );

    if (openSettings == true) {
      await Geolocator.openAppSettings();
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    }
    return false;
  }

  static Future<void> _showLocationServicesDialog(
    BuildContext context, {
    String? servicesDisabledMessage,
  }) async {
    final l10n = context.l10n;
    final enable = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.homeLocationPermissionTitle),
          content: Text(
            servicesDisabledMessage ?? l10n.homeLocationServicesDisabled,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.homeLocationOpenSettings),
            ),
          ],
        );
      },
    );

    if (enable == true) {
      await Geolocator.openLocationSettings();
    }
  }
}
