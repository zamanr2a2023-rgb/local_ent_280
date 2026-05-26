import 'package:local_ent_280/core/constants/app_assets.dart';

/// Status de uma viagem no histórico — `roles/details.md`.
enum TripHistoryStatus { concluida, cancelada }

/// Item individual no Histórico de Viagens.
class TripHistoryItem {
  const TripHistoryItem({
    required this.id,
    required this.date,
    required this.title,
    required this.location,
    required this.price,
    required this.tier,
    required this.duration,
    required this.status,
    required this.imageUrl,
  });

  final String id;
  final String date;
  final String title;
  final String location;
  final String price;
  final String tier;
  final String duration;
  final TripHistoryStatus status;
  final String imageUrl;

  bool get isCancelled => status == TripHistoryStatus.cancelada;
}

/// Categorias de filtro do histórico.
enum TripHistoryFilter { todos, recentes, concluidas, canceladas, esteAno }

extension TripHistoryFilterLabel on TripHistoryFilter {
  String get label {
    switch (this) {
      case TripHistoryFilter.todos:
        return 'Todos';
      case TripHistoryFilter.recentes:
        return 'Viagens Recentes';
      case TripHistoryFilter.concluidas:
        return 'Concluídas';
      case TripHistoryFilter.canceladas:
        return 'Canceladas';
      case TripHistoryFilter.esteAno:
        return 'Este Ano';
    }
  }
}

/// Dados do ecrã «Histórico de Viagens» — `roles/details.md`.
abstract final class TripHistoryData {
  static const profileAvatarImage = AppAssets.tripHistoryProfileAvatarImage;

  static const activityLabel = 'A Minha Atividade';
  static const screenTitle = 'Histórico de Viagens';

  static const totalTrips = '24';
  static const totalTripsLabel = 'Viagens';
  static const monthSpend = '128€';
  static const monthSpendLabel = 'Este Mês';

  static const trips = <TripHistoryItem>[
    TripHistoryItem(
      id: 'trip-1',
      date: '12 Out, 2023',
      title: 'Lisboa Marina Hotel',
      location: 'Doca de Belém, Lisboa',
      price: '24,50€',
      tier: 'Executivo',
      duration: '18 min',
      status: TripHistoryStatus.concluida,
      imageUrl: AppAssets.tripHistoryMarinaImage,
    ),
    TripHistoryItem(
      id: 'trip-2',
      date: '08 Out, 2023',
      title: 'Aeroporto de Lisboa (LIS)',
      location: 'Terminal 1, Partidas',
      price: '12,80€',
      tier: 'Conforto',
      duration: '25 min',
      status: TripHistoryStatus.concluida,
      imageUrl: AppAssets.tripHistoryAirportImage,
    ),
    TripHistoryItem(
      id: 'trip-3',
      date: '05 Out, 2023',
      title: 'Torre Vasco da Gama',
      location: 'Parque das Nações',
      price: '0,00€',
      tier: 'Executivo',
      duration: '',
      status: TripHistoryStatus.cancelada,
      imageUrl: AppAssets.tripHistoryTorreImage,
    ),
  ];
}
