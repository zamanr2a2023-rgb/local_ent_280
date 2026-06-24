import 'package:local_ent_280/l10n/app_localizations.dart';

String localizedTransportTypeLabel(
  AppLocalizations l10n,
  String id, {
  String? fallback,
}) {
  return switch (id) {
    'premium' => l10n.tripConfirmTransportPremium,
    'eco' => l10n.tripConfirmTransportEco,
    'shared' => l10n.tripConfirmTransportShared,
    _ => fallback ?? id,
  };
}
