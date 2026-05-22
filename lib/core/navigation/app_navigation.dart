import 'package:flutter/material.dart';
import 'package:local_ent_280/presentation/discover/discover_screen.dart';
import 'package:local_ent_280/presentation/event/event_detail_screen.dart';
import 'package:local_ent_280/presentation/home/home_screen.dart';
import 'package:local_ent_280/presentation/home/premium_home_screen.dart';
import 'package:local_ent_280/presentation/delivery/delivery_screen.dart';
import 'package:local_ent_280/presentation/jetski/jetski_screen.dart';
import 'package:local_ent_280/presentation/login/login_screen.dart';
import 'package:local_ent_280/presentation/reservation/reservation_review_screen.dart';

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
        _goEvent(context);
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

  static void _goEvent(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const EventDetailScreen()),
      (_) => false,
    );
  }
}
