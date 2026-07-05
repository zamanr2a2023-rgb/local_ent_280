import 'package:local_ent_280/l10n/app_localizations.dart';

class TripCancellation {
  const TripCancellation({
    required this.actor,
    required this.type,
    required this.reason,
    this.feeAmountMinor = 0,
    this.feeCurrency = 'EUR',
  });

  final String actor;
  final String type;
  final String reason;
  final int feeAmountMinor;
  final String feeCurrency;

  factory TripCancellation.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) {
      return const TripCancellation(
        actor: '',
        type: '',
        reason: '',
      );
    }
    final fee = data['fee'];
    final feeMap = fee is Map ? Map<String, dynamic>.from(fee) : null;
    return TripCancellation(
      actor: data['actor'] as String? ?? '',
      type: data['type'] as String? ?? '',
      reason: data['reason'] as String? ?? '',
      feeAmountMinor: (feeMap?['amountMinor'] as num?)?.toInt() ?? 0,
      feeCurrency: feeMap?['currency'] as String? ?? 'EUR',
    );
  }
}

abstract final class ClientTripCancelReasonCode {
  static const changedPlans = 'changed_plans';
  static const driverTooLong = 'driver_too_long';
  static const wrongPickup = 'wrong_pickup';
  static const bookedByMistake = 'booked_by_mistake';
  static const otherPrefix = 'other:';
}

abstract final class TripCancellationLabels {
  static String displayReason(String? rawReason, AppLocalizations l10n) {
    final trimmed = rawReason?.trim() ?? '';
    if (trimmed.isEmpty) {
      return l10n.tripCancelReasonUnknown;
    }
    if (trimmed.startsWith(ClientTripCancelReasonCode.otherPrefix)) {
      final custom = trimmed
          .substring(ClientTripCancelReasonCode.otherPrefix.length)
          .trim();
      if (custom.isNotEmpty) return custom;
      return l10n.tripCancelReasonOther;
    }
    return switch (trimmed) {
      ClientTripCancelReasonCode.changedPlans =>
        l10n.tripCancelReasonChangedPlans,
      ClientTripCancelReasonCode.driverTooLong =>
        l10n.tripCancelReasonDriverTooLong,
      ClientTripCancelReasonCode.wrongPickup =>
        l10n.tripCancelReasonWrongPickup,
      ClientTripCancelReasonCode.bookedByMistake =>
        l10n.tripCancelReasonBookedByMistake,
      _ => trimmed,
    };
  }
}

enum ClientTripCancelReasonOption {
  changedPlans(ClientTripCancelReasonCode.changedPlans),
  driverTooLong(ClientTripCancelReasonCode.driverTooLong),
  wrongPickup(ClientTripCancelReasonCode.wrongPickup),
  bookedByMistake(ClientTripCancelReasonCode.bookedByMistake),
  other('other');

  const ClientTripCancelReasonOption(this.code);

  final String code;

  String label(AppLocalizations l10n) => switch (this) {
        ClientTripCancelReasonOption.changedPlans =>
          l10n.tripCancelReasonChangedPlans,
        ClientTripCancelReasonOption.driverTooLong =>
          l10n.tripCancelReasonDriverTooLong,
        ClientTripCancelReasonOption.wrongPickup =>
          l10n.tripCancelReasonWrongPickup,
        ClientTripCancelReasonOption.bookedByMistake =>
          l10n.tripCancelReasonBookedByMistake,
        ClientTripCancelReasonOption.other => l10n.tripCancelReasonOther,
      };

  String encode({String? customText}) {
    if (this == ClientTripCancelReasonOption.other) {
      return '${ClientTripCancelReasonCode.otherPrefix}${customText?.trim() ?? ''}';
    }
    return code;
  }
}
