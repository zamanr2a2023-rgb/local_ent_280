import 'package:flutter/material.dart';
import 'package:local_ent_280/presentation/discover/discover_screen.dart';
import 'package:local_ent_280/presentation/event/event_detail_screen.dart';
import 'package:local_ent_280/presentation/home/home_screen.dart';
import 'package:local_ent_280/presentation/home/premium_home_screen.dart';
import 'package:local_ent_280/presentation/delivery/delivery_screen.dart';
import 'package:local_ent_280/presentation/jetski/jetski_screen.dart';
import 'package:local_ent_280/presentation/login/login_screen.dart';
import 'package:local_ent_280/presentation/reservation/reservation_review_screen.dart';
import 'package:local_ent_280/presentation/rental/vehicle_detail_screen.dart';
import 'package:local_ent_280/presentation/rental/vehicle_rental_screen.dart';
import 'package:local_ent_280/presentation/rental/vehicle_search_results_screen.dart';
import 'package:local_ent_280/presentation/trip/driver_en_route_screen.dart';
import 'package:local_ent_280/presentation/trip/trip_completed_screen.dart';
import 'package:local_ent_280/presentation/trip/trip_in_progress_screen.dart';
import 'package:local_ent_280/presentation/trip/driver_found_screen.dart';
import 'package:local_ent_280/presentation/trip/driver_search_screen.dart';
import 'package:local_ent_280/presentation/trip/trip_confirm_screen.dart';
import 'package:local_ent_280/presentation/trip/trip_destination_screen.dart';

/// Bottom navigation indices (Fluxo do Utilizador).
abstract final class AppNavIndex {
  static const int inicio = 0;
  static const int viagens = 1;
  static const int reservas = 2;
  static const int perfil = 3;
}

/// Central navigation matching the product user-flow diagram.
abstract final class AppNavigation {
  static void toLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  /// Login → mapa / planeamento de viagem (Página Inicial).
  static void toHomeAfterLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
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
  static void toEventBooking(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EventDetailScreen()),
    );
  }

  /// Tab Reservas → pesquisa de aluguer de veículos.
  static void toVehicleRental(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const VehicleRentalScreen()),
      (_) => false,
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

  /// Ver Mapa Completo → confirmação de viagem.
  static void toTripConfirm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TripConfirmScreen()),
    );
  }

  /// Confirmar viagem → a procurar motorista.
  static void toDriverSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DriverSearchScreen()),
    );
  }

  /// Motorista encontrado → a aguardar confirmação.
  static void toDriverFound(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DriverFoundScreen()),
    );
  }

  /// Motorista confirmado → a caminho.
  static void toDriverEnRoute(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DriverEnRouteScreen()),
    );
  }

  /// Viagem iniciada → em curso.
  static void toTripInProgress(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TripInProgressScreen()),
    );
  }

  /// Terminar viagem → viagem concluída.
  static void toTripCompleted(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const TripCompletedScreen()),
    );
  }

  /// Lista → detalhes do veículo (Porsche Taycan 4S).
  static void toVehicleDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const VehicleDetailScreen()),
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

  /// Pesquisa → Revisão da Reserva.
  static void toReservationReview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ReservationReviewScreen(),
      ),
    );
  }

  /// Entregas / marketplace (tab Viagens, Pedir agora).
  static void toDelivery(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DeliveryScreen()),
    );
  }

  static void openEventBooking(BuildContext context) => toEventBooking(context);

  /// Voltar — returns to the previous screen (e.g. Home).
  static void back(BuildContext context) {
    Navigator.of(context).maybePop();
  }

  static void onBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case AppNavIndex.inicio:
        _goHome(context);
      case AppNavIndex.viagens:
        _goDelivery(context);
      case AppNavIndex.reservas:
        _goVehicleRental(context);
      case AppNavIndex.perfil:
        _goHome(context);
    }
  }

  /// Tab Início → mapa / planeamento de viagem.
  static void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  static void _goDelivery(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const DeliveryScreen()),
      (_) => false,
    );
  }

  static void _goVehicleRental(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const VehicleRentalScreen()),
      (_) => false,
    );
  }
}
