import 'package:local_ent_280/core/constants/app_assets.dart';

/// Linha da Fatura Digital — `roles/details.md`.
class FareLine {
  const FareLine({
    required this.label,
    required this.amount,
    this.isDiscount = false,
  });

  final String label;
  final String amount;
  final bool isDiscount;
}

/// Item de suporte no card «Algo correu mal?».
class SupportAction {
  const SupportAction({required this.label, required this.id});

  final String label;
  final String id;
}

/// Dados do ecrã «Detalhes da Viagem» — `roles/details.md`.
abstract final class TripDetailsData {
  static const profileAvatarImage = AppAssets.tripHistoryProfileAvatarImage;
  static const mapImage = AppAssets.tripDetailsMapImage;
  static const driverAvatarImage = AppAssets.tripDetailsDriverAvatarImage;

  static const tripDurationDistance = '24 min • 12.5 km';

  static const summaryTitle = 'Resumo da Viagem';
  static const summaryDate = '14 de Outubro, 2023 • 18:42';
  static const summaryStatus = 'Concluída';

  static const pickupAddress = 'Avenida da Liberdade, 110';
  static const pickupCity = 'Lisboa, Portugal';
  static const destinationAddress = 'Aeroporto Humberto Delgado';
  static const destinationDetails = 'Terminal 1, Partidas';

  static const ratingTitle = 'Avalie a sua experiência';
  static const ratingStars = 4;
  static const ratingEditCta = 'Editar';

  static const invoiceTitle = 'Fatura Digital';
  static const invoiceLines = <FareLine>[
    FareLine(label: 'Tarifa Base', amount: '3,50 €'),
    FareLine(label: 'Distância (12.5 km)', amount: '14,25 €'),
    FareLine(label: 'Tempo (24 min)', amount: '4,80 €'),
    FareLine(label: 'Desconto Promocional', amount: '- 2,50 €', isDiscount: true),
  ];
  static const totalLabel = 'Total Pago';
  static const totalAmount = '20,05 €';
  static const methodLabel = 'Método';
  static const methodValue = 'Visa •••• 4242';
  static const downloadCta = 'Descarregar PDF';

  static const driverName = 'Ricardo Santos';
  static const driverCar = 'Tesla Model 3 • 42-XG-99';
  static const driverTier = 'Premium Electric';
  static const driverRating = '4.9';

  static const supportTitle = 'Algo correu mal?';
  static const supportActions = <SupportAction>[
    SupportAction(id: 'lost-item', label: 'Reportar objeto perdido'),
    SupportAction(id: 'safety', label: 'Reclamação de segurança'),
    SupportAction(id: 'support', label: 'Apoio ao cliente'),
  ];
}
