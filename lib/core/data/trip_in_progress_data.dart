import 'package:local_ent_280/core/constants/app_assets.dart';

/// Dados do ecrã «Viagem em curso» — `roles/details.md`.
abstract final class TripInProgressData {
  static const mapImage = AppAssets.tripInProgressMapImage;
  static const profileAvatarImage = AppAssets.tripInProgressProfileAvatarImage;

  static const statusLabel = 'Status da Viagem';
  static const statusValue = 'Em viagem';
  static const arrivalLabel = 'Chegada prevista';
  static const arrivalTime = '14:45';

  static const destinationLabel = 'Destino';
  static const destinationAddress = 'Avenida da Liberdade, Lisboa';

  static const costLabel = 'Custo Estimado';
  static const estimatedCostEur = 12.50;
}
