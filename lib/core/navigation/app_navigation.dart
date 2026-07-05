import 'package:flutter/material.dart';
import 'package:local_ent_280/features/auth/data/models/app_user_profile.dart';
import 'package:local_ent_280/features/balance/data/balance_repository.dart';
import 'package:local_ent_280/features/rental/data/rental_booking_draft.dart';
import 'package:local_ent_280/features/trips/data/trip_repository.dart';
import 'package:local_ent_280/features/auth/data/models/app_user_role.dart';
import 'package:local_ent_280/features/auth/data/user_session.dart';
import 'package:local_ent_280/presentation/admin/admin_home_screen.dart';
import 'package:local_ent_280/presentation/admin/admin_reports_screen.dart';
import 'package:local_ent_280/presentation/admin/screens/admin_hub_screen.dart';
import 'package:local_ent_280/presentation/admin/screens/admin_incident_detail_screen.dart';
import 'package:local_ent_280/presentation/admin/screens/admin_manager_permissions_screen.dart';
import 'package:local_ent_280/presentation/admin/screens/admin_module_screens.dart';
import 'package:local_ent_280/presentation/admin/screens/admin_tariff_editor_screen.dart';
import 'package:local_ent_280/presentation/admin/screens/admin_operational_incidents_screen.dart';
import 'package:local_ent_280/presentation/admin/screens/admin_support_requests_screen.dart';
import 'package:local_ent_280/presentation/admin/screens/admin_users_screen.dart';
import 'package:local_ent_280/presentation/balance/client_balance_screen.dart';
import 'package:local_ent_280/presentation/discover/discover_screen.dart';
import 'package:local_ent_280/presentation/event/event_detail_screen.dart';
import 'package:local_ent_280/presentation/home/home_screen.dart';
import 'package:local_ent_280/presentation/home/premium_home_screen.dart';
import 'package:local_ent_280/presentation/delivery/delivery_screen.dart';
import 'package:local_ent_280/presentation/jetski/jetski_screen.dart';
import 'package:local_ent_280/presentation/login/login_screen.dart';
import 'package:local_ent_280/presentation/login/register_screen.dart';
import 'package:local_ent_280/presentation/reservation/reservation_review_screen.dart';
import 'package:local_ent_280/presentation/reservations/reservations_screen.dart';
import 'package:local_ent_280/presentation/rental/vehicle_detail_screen.dart';
import 'package:local_ent_280/presentation/rental/vehicle_rental_screen.dart';
import 'package:local_ent_280/presentation/rental/vehicle_search_results_screen.dart';
import 'package:local_ent_280/presentation/driver/driver_active_trip_screen.dart';
import 'package:local_ent_280/presentation/driver/driver_home_screen.dart';
import 'package:local_ent_280/presentation/driver/driver_request_expired_screen.dart';
import 'package:local_ent_280/presentation/driver/driver_trip_accepted_screen.dart';
import 'package:local_ent_280/presentation/driver/driver_trip_request_screen.dart';
import 'package:local_ent_280/presentation/trip/driver_en_route_screen.dart';
import 'package:local_ent_280/presentation/trip/trip_completed_screen.dart';
import 'package:local_ent_280/presentation/trip/trip_in_progress_screen.dart';
import 'package:local_ent_280/presentation/trip/driver_found_screen.dart';
import 'package:local_ent_280/presentation/trip/driver_search_screen.dart';
import 'package:local_ent_280/core/models/trip_route_draft.dart';
import 'package:local_ent_280/presentation/trip/trip_confirm_screen.dart';
import 'package:local_ent_280/presentation/trip/trip_destination_screen.dart';
import 'package:local_ent_280/presentation/trip/trip_details_screen.dart';
import 'package:local_ent_280/presentation/profile/profile_screen.dart';
import 'package:local_ent_280/presentation/settings/settings_screen.dart';
import 'package:local_ent_280/presentation/trip/trip_history_screen.dart';
import 'package:local_ent_280/features/driver/data/driver_repository.dart';
import 'package:local_ent_280/features/trips/data/active_trip_session.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';

/// Bottom navigation indices (Fluxo do Utilizador).
abstract final class AppNavIndex {
  static const int inicio = 0;
  static const int viagens = 1;
  /// Client balance tab (replaces legacy reservations tab).
  static const int saldo = 2;
  static const int perfil = 3;

  @Deprecated('Use AppNavIndex.saldo')
  static const int reservas = saldo;
}

/// Central navigation matching the product user-flow diagram.
abstract final class AppNavigation {
  /// Optional overrides for widget/integration tests (do not use in production).
  static BalanceRepository? balanceRepositoryOverride;
  static TripRepository? tripHistoryRepositoryOverride;

  static void toLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  static void toRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
    );
  }

  /// Termina sessão e volta ao ecrã de login (limpa a pilha de navegação).
  static void signOutToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  /// Definições da aplicação (idioma, moeda, conta).
  static void toSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }

  /// Tab Perfil → ecrã de perfil do utilizador.
  static void toProfile(BuildContext context) {
    final profile = UserSession.instance.profile;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => ProfileScreen(initialProfile: profile),
      ),
      (_) => false,
    );
  }

  /// Post-authentication routing by Firestore `users/{uid}.role`.
  static void afterAuthenticatedLogin(
    BuildContext context,
    AppUserProfile profile,
  ) {
    UserSession.instance.setProfile(profile);
    final Widget home = switch (profile.role) {
      AppUserRole.client => const HomeScreen(),
      AppUserRole.driver => const DriverHomeScreen(),
      AppUserRole.admin => const AdminHomeScreen(),
    };
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => home),
    );
  }

  /// Login → mapa / planeamento de viagem (Página Inicial).
  static void toHomeAfterLogin(BuildContext context) {
    final profile = UserSession.instance.profile;
    if (profile != null) {
      afterAuthenticatedLogin(context, profile);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  /// Login (admin) → painel admin Local Transport.
  static void toAdminHome(BuildContext context) {
    final profile = UserSession.instance.profile;
    if (profile != null) {
      afterAuthenticatedLogin(context, profile);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AdminHomeScreen()),
      (_) => false,
    );
  }

  /// Admin → relatórios detalhados (`roles/details.md`).
  static void toAdminReports(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdminReportsScreen()),
    );
  }

  /// Admin drawer → painel principal (limpa a pilha).
  static void goAdminDashboard(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AdminHomeScreen()),
      (_) => false,
    );
  }

  /// Admin drawer / bottom nav → relatórios detalhados (limpa a pilha).
  static void goAdminReports(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AdminReportsScreen()),
      (_) => false,
    );
  }

  static void toAdminHub(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdminHubScreen()),
    );
  }

  static void toAdminUsers(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdminUsersScreen()),
    );
  }

  static void toAdminManagerPermissions(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AdminManagerPermissionsScreen(),
      ),
    );
  }

  static void toAdminSupportRequests(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdminSupportRequestsScreen()),
    );
  }

  static void toAdminIncidents(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AdminOperationalIncidentsScreen(),
      ),
    );
  }

  static void toAdminIncidentDetail(
    BuildContext context, {
    required String incidentId,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminIncidentDetailScreen(incidentId: incidentId),
      ),
    );
  }

  static void toAdminFleet(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdminFleetScreen()),
    );
  }

  static void toAdminBalances(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdminBalancesScreen()),
    );
  }

  static void toAdminReservations(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdminReservationsScreen()),
    );
  }

  static void toAdminEvents(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdminEventsScreen()),
    );
  }

  static void toAdminTransportTypes(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AdminTransportTypesScreen(),
      ),
    );
  }

  static void toAdminTripPackages(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdminTripPackagesScreen()),
    );
  }

  static void toAdminTariffs(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdminTariffEditorScreen()),
    );
  }

  static void toAdminCurrencySettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AdminCurrencySettingsScreen(),
      ),
    );
  }

  static void toAdminSupportSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AdminSupportSettingsScreen(),
      ),
    );
  }

  static void toAdminMonitoringSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AdminMonitoringSettingsScreen(),
      ),
    );
  }

  static void toAdminAudit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdminAuditScreen()),
    );
  }

  /// Mapa / planeamento de viagem (ecrã legado).
  static void toTripMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }

  /// Home → Explorar Ilhas.
  static void toDiscover(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DiscoverScreen()),
    );
  }

  /// Home → Reserva de Evento.
  static void toEventBooking(BuildContext context, {String? packageId}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EventDetailScreen(packageId: packageId),
      ),
    );
  }

  /// Home quick action → vehicle rental search.
  static void toVehicleRental(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const VehicleRentalScreen()),
    );
  }

  /// Pesquisa → resultados de veículos disponíveis.
  static void toVehicleSearchResults(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const VehicleSearchResultsScreen(),
      ),
    );
  }

  /// Ver Detalhes (frota) → destino da viagem.
  static void toTripDestination(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TripDestinationScreen()),
    );
  }

  /// Cancelar viagem → volta ao ecrã inicial.
  static void cancelToTripDestination(BuildContext context) {
    ActiveTripSession.instance.clear();
    _goHome(context);
  }

  /// Ver Mapa Completo → confirmação de viagem.
  static void toTripConfirm(BuildContext context, TripRouteDraft route) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TripConfirmScreen(route: route),
      ),
    );
  }

  /// Confirmar viagem → a procurar motorista (substitui o ecrã de confirmação).
  static void toDriverSearch(
    BuildContext context, {
    String? tripId,
    TripRepository? tripRepository,
    bool showNoDriversMessage = true,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => DriverSearchScreen(
          tripId: tripId,
          tripRepository: tripRepository,
          showNoDriversMessage: showNoDriversMessage,
        ),
      ),
    );
  }

  /// Motorista encontrado → a aguardar confirmação.
  static void toDriverFound(
    BuildContext context, {
    String? tripId,
    TripRecord? trip,
    TripRepository? tripRepository,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => DriverFoundScreen(
          tripId: tripId,
          trip: trip,
          tripRepository: tripRepository,
        ),
      ),
    );
  }

  /// Motorista confirmado → a caminho.
  static void toDriverEnRoute(
    BuildContext context, {
    String? tripId,
    TripRecord? trip,
    TripRepository? tripRepository,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => DriverEnRouteScreen(
          tripId: tripId,
          trip: trip,
          tripRepository: tripRepository,
        ),
      ),
    );
  }

  /// Viagem iniciada → em curso.
  static void toTripInProgress(
    BuildContext context, {
    String? tripId,
    TripRecord? trip,
    TripRepository? tripRepository,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => TripInProgressScreen(
          tripId: tripId,
          trip: trip,
          tripRepository: tripRepository,
        ),
      ),
    );
  }

  /// Terminar viagem → viagem concluída.
  static void toTripCompleted(
    BuildContext context, {
    String? tripId,
    TripRecord? trip,
    TripRepository? tripRepository,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => TripCompletedScreen(
          tripId: tripId,
          trip: trip,
          tripRepository: tripRepository,
        ),
      ),
    );
  }

  /// Lista → revisão de reserva (aluguer).
  static void toReservationReview(
    BuildContext context, {
    String? vehicleId,
    String? vehicleLabel,
    double? pricePerDayEur,
    String? imageUrl,
    int? seats,
    String? transmission,
    String? category,
    bool? isElectric,
    bool? isPremium,
  }) {
    if (vehicleId != null) {
      RentalBookingDraft.instance.setVehicle(
        id: vehicleId,
        label: vehicleLabel ?? 'Vehicle',
        category: category,
        pricePerDayEur: pricePerDayEur,
        imageUrl: imageUrl,
        seats: seats,
        transmission: transmission,
        isElectric: isElectric,
        isPremium: isPremium,
      );
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ReservationReviewScreen()),
    );
  }

  /// Histórico de viagens → detalhes da viagem.
  static void toTripDetails(BuildContext context, {String? tripId}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TripDetailsScreen(
          tripId: tripId,
          tripRepository: tripHistoryRepositoryOverride,
        ),
      ),
    );
  }

  /// Home → saldo do cliente (Firebase balances).
  static void toClientBalance(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClientBalanceScreen(
          balanceRepository: balanceRepositoryOverride,
        ),
      ),
    );
  }

  /// Tab Viagens → histórico de viagens.
  static void toTripHistory(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const TripHistoryScreen()),
      (_) => false,
    );
  }

  /// Tab Reservas → lista de reservas do utilizador.
  static void toReservations(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const ReservationsScreen()),
      (_) => false,
    );
  }

  /// Lista → detalhes do veículo (Firebase vehicles).
  static void toVehicleDetail(BuildContext context, {String? vehicleId}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VehicleDetailScreen(vehicleId: vehicleId),
      ),
    );
  }

  /// Home → Aluguer de Motas de Água.
  static void toJetskiRental(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const JetskiScreen()),
    );
  }

  /// Página Inicial — hub premium (tab Início, categorias de entrega).
  static void toPremiumHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const PremiumHomeScreen()),
      (_) => false,
    );
  }

  /// Entregas / marketplace (tab Viagens, Pedir agora).
  static void toDelivery(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DeliveryScreen()),
    );
  }

  static void openEventBooking(BuildContext context) => toEventBooking(context);

  /// Motorista — dashboard principal.
  static void toDriverHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const DriverHomeScreen()),
      (_) => false,
    );
  }

  /// Motorista — novo pedido de viagem.
  static Future<void> toDriverTripRequest(
    BuildContext context, {
    required String tripId,
    TripRecord? trip,
    DriverRepository? driverRepository,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => DriverTripRequestScreen(
          tripId: tripId,
          trip: trip,
          driverRepository: driverRepository,
        ),
      ),
    );
  }

  /// Motorista — pedido aceite.
  static void toDriverTripAccepted(
    BuildContext context, {
    required String tripId,
    TripRecord? trip,
    DriverRepository? driverRepository,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => DriverTripAcceptedScreen(
          tripId: tripId,
          trip: trip,
          driverRepository: driverRepository,
        ),
      ),
    );
  }

  /// Motorista — pedido expirado.
  static void toDriverRequestExpired(
    BuildContext context, {
    String? tripId,
    DriverRepository? driverRepository,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => DriverRequestExpiredScreen(
          tripId: tripId,
          driverRepository: driverRepository,
        ),
      ),
    );
  }

  /// Motorista — viagem ativa.
  static Future<void> toDriverActiveTrip(
    BuildContext context, {
    required String tripId,
    TripRecord? trip,
    DriverRepository? driverRepository,
  }) {
    return Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => DriverActiveTripScreen(
          tripId: tripId,
          trip: trip,
          driverRepository: driverRepository,
        ),
      ),
    );
  }

  /// Tab Viagens (motorista) → histórico de viagens do motorista.
  static void toDriverTripHistory(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const TripHistoryScreen(
          audience: TripHistoryAudience.driver,
        ),
      ),
      (_) => false,
    );
  }

  static void onDriverBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case AppNavIndex.inicio:
        toDriverHome(context);
      case AppNavIndex.viagens:
        toDriverTripHistory(context);
      case AppNavIndex.saldo:
        _goClientBalance(context);
      case AppNavIndex.perfil:
        _goProfile(context);
    }
  }

  /// Driver bottom nav: 0 = Home, 1 = Trips, 2 = Profile.
  static void onDriverBottomNavLocalTap(BuildContext context, int localIndex) {
    switch (localIndex) {
      case 0:
        onDriverBottomNavTap(context, AppNavIndex.inicio);
      case 1:
        onDriverBottomNavTap(context, AppNavIndex.viagens);
      case 2:
        onDriverBottomNavTap(context, AppNavIndex.perfil);
    }
  }

  /// Voltar — returns to the previous screen (e.g. Home).
  static void back(BuildContext context) {
    Navigator.of(context).maybePop();
  }

  static void onBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case AppNavIndex.inicio:
        _goHome(context);
      case AppNavIndex.viagens:
        _goTripHistory(context);
      case AppNavIndex.saldo:
        _goClientBalance(context);
      case AppNavIndex.perfil:
        _goProfile(context);
    }
  }

  /// Tab Início → mapa / planeamento de viagem.
  static void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => HomeScreen(
          balanceRepository: balanceRepositoryOverride,
        ),
      ),
      (_) => false,
    );
  }

  static void _goTripHistory(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => TripHistoryScreen(
          tripRepository: tripHistoryRepositoryOverride,
        ),
      ),
      (_) => false,
    );
  }

  static void _goClientBalance(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => ClientBalanceScreen(
          balanceRepository: balanceRepositoryOverride,
        ),
      ),
      (_) => false,
    );
  }

  static void _goProfile(BuildContext context) {
    final profile = UserSession.instance.profile;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => ProfileScreen(initialProfile: profile),
      ),
      (_) => false,
    );
  }
}
