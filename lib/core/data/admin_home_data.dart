/// Admin home (Painel Admin) — `roles/details.md`.
abstract final class AdminHomeData {
  static const profileAvatarImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDW8-qb-lQXrW3W0-mJ-YNm5JXT5vAUJp-RFAcV65EXVIGvNOqx4HcSsRM1YuoaMaB6Q7Ko_rmXaYmX5OKzWE9Vdnj_Lj3Q3ex7QJqxIxLtu3RoN--KYbAsbLrjo-r0TpAk3qnwOlEe80Yz7ah-nsmL_kRRZ4mxD1b3O9Ciiqeh3LuzPIMk1E5o99hAVw2i0uAMZLNuVyIJk5kCm7isLCLEYEh9brsBuetn0lDcDx7s2CfrReWqGBFgOzd2u42tCMi5Nha0JTeN3ug';

  static const activityMapImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAHI-WJ4OOJ5X_QOSgU0gE2g9fWV6TXJUXrUrODDDM3pVB5nb-pzwvSeYRbv38AWj4FrfrBVAVmFcj19xZFP5RHuReHXeZozbtTfzv4TyB1r1kM6Ud3bNczvJk1_zDpUy80SXrPjGW36NIR7iHrAcWDTdV8iDjq_MnZMlUkFPwCkfh6Ay8YJHiEie0nJ56aDBrXeSx87i6Z_HdmxYi8EcIOXpo-Fn_9tx5Z4hHridhMk-74y6CAozYDv5nVC0c_mr_zi2IRv5D8y0E';

  static const appBarTitle = 'Local Transport';

  static const fleetStatusTitle = 'Estado da Frota';
  static const fleetStatusUpdated = 'Atualizado: Agora';

  static const activeTripsCount = '42';
  static const activeTripsLabel = 'Viagens Ativas';
  static const activeTripsTrend = '+12% vs. ontem';

  static const availableDriversCount = '18';
  static const availableDriversLabel = 'Motoristas Disponíveis';
  static const availableDriversHint = 'Pronto para despacho';

  static const criticalOpsTitle = 'Operações Críticas';
  static const pendingDebtorsTitle = 'Devedores Pendentes';
  static const pendingDebtorsSubtitle = '3 faturas em atraso';
  static const pendingDebtorsAmountEur = 1420.0;
  static const monthlyReportsTitle = 'Relatórios Mensais';
  static const monthlyReportsSubtitle = 'Performance de Outubro';

  static const activityMapTitle = 'Mapa de Atividade';
  static const activityMapLocation = 'Lisboa Central';

  static const ratesTitle = 'Tarifas & Mercado';
  static const baseRateLabel = 'Tarifa Base';
  static const baseRateEurPerKm = 2.45;
  static const baseRateDynamic = 'Dinâmica: Ativa (1.2x)';
  static const fuelCostLabel = 'Custo Combustível';
  static const fuelCostEurPerLiter = 1.74;
  static const fuelCostHint = 'Média Nacional';

  static const recentFleetTitle = 'Frota Recente';
  static const recentFleetSeeAll = 'Ver Todos';

  static const List<AdminFleetVehicle> recentFleet = [
    AdminFleetVehicle(
      vehicle: 'Tesla Model 3 • AA-12-BB',
      driver: 'Motorista: Ricardo S.',
      status: AdminFleetStatus.emViagem,
    ),
    AdminFleetVehicle(
      vehicle: 'Mercedes EQE • CC-34-DD',
      driver: 'Motorista: Ana M.',
      status: AdminFleetStatus.inativo,
    ),
  ];
}

enum AdminFleetStatus { emViagem, inativo }

class AdminFleetVehicle {
  const AdminFleetVehicle({
    required this.vehicle,
    required this.driver,
    required this.status,
  });

  final String vehicle;
  final String driver;
  final AdminFleetStatus status;

  String get statusLabel => switch (status) {
    AdminFleetStatus.emViagem => 'Em Viagem',
    AdminFleetStatus.inativo => 'Inativo',
  };
}
