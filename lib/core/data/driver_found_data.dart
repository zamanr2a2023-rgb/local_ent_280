import 'package:local_ent_280/core/constants/app_assets.dart';

/// Dados do ecrã «Motorista encontrado» — `roles/details.md`.
abstract final class DriverFoundData {
  static const mapImage = AppAssets.driverFoundMapImage;
  static const profileAvatarImage = AppAssets.driverFoundProfileAvatarImage;
  static const driverPhotoImage = AppAssets.driverFoundDriverImage;

  static const statusTitle = 'Motorista encontrado';
  static const statusSubtitle = 'A aguardar confirmação...';

  static const driverName = 'Ricardo Santos';
  static const vehicleInfo = 'Tesla Model 3 • Preto • 22-AA-00';
  static const rating = '4.9';
  static const serviceTier = 'Premium';

  static const estimatedTime = '4 min';
  static const fareEur = 14.50;

  static const cancelHint =
      'Pode cancelar sem custos nos próximos 2 minutos enquanto o motorista confirma a reserva.';
}
