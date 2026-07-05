import 'package:intl/intl.dart';
import 'package:local_ent_280/core/constants/app_assets.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/core/data/trip_history_data.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';

class TripHistoryMapper {
  static TripHistoryItem fromTripRecord(TripRecord trip) {
    final costMinor = trip.meteringSnapshot.estimatedCostMinor;
    final price = AppCurrencyFormatter.instance.formatEurMinor(costMinor);
    final createdAt = trip.createdAt ?? trip.updatedAt;
    final date = createdAt == null
        ? '—'
        : DateFormat('d MMM, yyyy', 'en').format(createdAt);
    final minutes = trip.meteringSnapshot.totalMinutes;

    return TripHistoryItem(
      id: trip.id,
      date: date,
      title: _shortAddress(trip.destination.address),
      location: _shortAddress(trip.pickup.address),
      price: price,
      tier: trip.transportType.name.trim().isEmpty
          ? 'Premium'
          : trip.transportType.name.trim(),
      duration: minutes > 0 ? '$minutes min' : '',
      status: _mapStatus(trip),
      imageUrl: AppAssets.tripHistoryMarinaImage,
      createdAt: createdAt,
      costMinor: costMinor,
      statusCode: trip.status,
    );
  }

  static TripHistoryStatus _mapStatus(TripRecord trip) {
    if (trip.completedAt != null) {
      return TripHistoryStatus.concluida;
    }

    final status = trip.status.trim().toUpperCase();
    return switch (status) {
      'CANCELLED_BY_CLIENT' ||
      'CANCELLED_BY_DRIVER' ||
      'NO_SHOW' ||
      'NO_DRIVERS_AVAILABLE' ||
      'DRIVER_DECLINED' =>
        TripHistoryStatus.cancelada,
      'COMPLETED' ||
      'CHARGE_APPLIED' ||
      'TRIP_COMPLETED' ||
      'DONE' =>
        TripHistoryStatus.concluida,
      'REQUESTED' || 'DRIVER_ASSIGNED_WAITING_ACCEPTANCE' =>
        TripHistoryStatus.agendada,
      _ => TripHistoryStatus.emCurso,
    };
  }

  static String _shortAddress(String address) {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return '—';
    final comma = trimmed.indexOf(',');
    if (comma <= 0) return trimmed;
    return trimmed.substring(0, comma).trim();
  }
}
