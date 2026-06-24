import 'package:local_ent_280/core/constants/app_assets.dart';

/// Status de uma viagem no histórico — `roles/details.md`.
enum TripHistoryStatus { concluida, cancelada, emCurso, agendada }

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
    required this.createdAt,
    required this.costMinor,
    required this.statusCode,
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
  final DateTime? createdAt;
  final int costMinor;
  final String statusCode;

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
  static const monthSpendMinor = 12800;
  static const monthSpendLabel = 'Este Mês';

  static const trips = <TripHistoryItem>[
    TripHistoryItem(
      id: 'trip-1',
      date: '12 Oct, 2023',
      title: 'Lisboa Marina Hotel',
      location: 'Doca de Belém, Lisboa',
      price: '',
      tier: 'Executive',
      duration: '18 min',
      status: TripHistoryStatus.concluida,
      imageUrl: AppAssets.tripHistoryMarinaImage,
      createdAt: null,
      costMinor: 2450,
      statusCode: 'COMPLETED',
    ),
    TripHistoryItem(
      id: 'trip-2',
      date: '08 Oct, 2023',
      title: 'Lisbon Airport (LIS)',
      location: 'Terminal 1, Partidas',
      price: '',
      tier: 'Comfort',
      duration: '25 min',
      status: TripHistoryStatus.concluida,
      imageUrl: AppAssets.tripHistoryAirportImage,
      createdAt: null,
      costMinor: 1280,
      statusCode: 'COMPLETED',
    ),
    TripHistoryItem(
      id: 'trip-3',
      date: '05 Oct, 2023',
      title: 'Torre Vasco da Gama',
      location: 'Parque das Nações',
      price: '',
      tier: 'Executive',
      duration: '',
      status: TripHistoryStatus.cancelada,
      imageUrl: AppAssets.tripHistoryTorreImage,
      createdAt: null,
      costMinor: 0,
      statusCode: 'CANCELLED_BY_CLIENT',
    ),
  ];
}
