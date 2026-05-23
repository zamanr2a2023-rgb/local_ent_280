import 'package:local_ent_280/core/constants/app_assets.dart';

/// Dados do ecrã «Viagem concluída» — `roles/details.md`.
abstract final class TripCompletedData {
  static const profileAvatarImage = AppAssets.tripCompletedProfileAvatarImage;
  static const routePreviewImage = AppAssets.tripCompletedRouteImage;

  static const title = 'Viagem Concluída!';
  static const subtitle = 'Obrigado por viajar connosco.';

  static const summaryTitle = 'Resumo da Viagem';
  static const finalPriceLabel = 'Preço Final';
  static const finalPrice = '12,45€';
  static const distance = '8.4 km';
  static const duration = '18 min';
  static const routeBadge = 'Trajeto otimizado';

  static const ratingTitle = 'Avalie a Viagem';
  static const ratingHint =
      'Como correu a sua experiência com o motorista e o veículo?';
  static const commentLabel = 'Comentário (opcional)';
  static const commentHint = 'Partilhe a sua opinião...';
  static const defaultRating = 4;
}
