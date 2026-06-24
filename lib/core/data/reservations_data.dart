import 'package:local_ent_280/core/constants/app_assets.dart';

/// Estado de uma reserva — `roles/details.md`.
enum ReservationStatus { confirmada, pendente }

extension ReservationStatusLabel on ReservationStatus {
  String get label {
    switch (this) {
      case ReservationStatus.confirmada:
        return 'Confirmada';
      case ReservationStatus.pendente:
        return 'Pendente';
    }
  }
}

/// Item individual no separador Reservas.
class ReservationItem {
  const ReservationItem({
    required this.id,
    required this.date,
    required this.timeMeta,
    required this.pickup,
    required this.destination,
    required this.status,
    this.vehicleInfo,
  });

  final String id;
  final String date;
  final String timeMeta;
  final String pickup;
  final String destination;
  final ReservationStatus status;
  final String? vehicleInfo;
}

/// Dados do ecrã «Reservas» — `roles/details.md`.
abstract final class ReservationsData {
  static const profileAvatarImage = AppAssets.tripHistoryProfileAvatarImage;
  static const emptyStateImage = AppAssets.reservationsEmptyImage;

  static const screenTitle = 'Reservas';
  static const screenSubtitle = 'Gerencie as suas próximas viagens';
  static const newReservationCta = 'Nova reserva';

  static const pickupLabel = 'Recolha';
  static const destinationLabel = 'Destino';
  static const detailsCta = 'Detalhes';
  static const cancelCta = 'Cancelar';

  static const emptyTitle = 'Ainda não tem mais reservas';
  static const emptyBody =
      'Planeie a sua próxima viagem com a nossa frota premium. Conforto e pontualidade garantidos.';
  static const exploreCta = 'Explorar destinos';

  static const reservations = <ReservationItem>[
    ReservationItem(
      id: 'res-1',
      date: '15 de Outubro, 2023',
      timeMeta: '14:30 · Partida prevista',
      pickup: 'Lisbon Airport (LIS)',
      destination: 'Avenida da Liberdade, 120',
      status: ReservationStatus.confirmada,
      vehicleInfo: 'Executivo · Tesla Model S',
    ),
    ReservationItem(
      id: 'res-2',
      date: '18 de Outubro, 2023',
      timeMeta: '09:00 · Aguardando motorista',
      pickup: 'Hotel Altis Grand',
      destination: 'Oriente Station',
      status: ReservationStatus.pendente,
    ),
  ];
}
