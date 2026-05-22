import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_ent_280/main.dart';
import 'package:local_ent_280/presentation/discover/discover_screen.dart';
import 'package:local_ent_280/presentation/event/event_detail_screen.dart';
import 'package:local_ent_280/presentation/delivery/delivery_screen.dart';
import 'package:local_ent_280/presentation/jetski/jetski_screen.dart';
import 'package:local_ent_280/presentation/home/home_screen.dart';
import 'package:local_ent_280/presentation/home/premium_home_screen.dart';
import 'package:local_ent_280/presentation/reservation/reservation_review_screen.dart';
import 'package:local_ent_280/presentation/login/login_screen.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';

void _setPhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  testWidgets('Splash screen shows app title', (WidgetTester tester) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.init(child: const MobilidadePremiumApp()),
    );

    expect(find.text('Mobilidade Premium'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
  });

  testWidgets('Login screen shows form fields', (WidgetTester tester) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const LoginScreen()));

    expect(
      find.text('Inicie sessão para gerir as suas viagens.'),
      findsOneWidget,
    );
    expect(find.text('Cliente'), findsOneWidget);
    expect(find.text('Profissional'), findsOneWidget);
    expect(find.text('E-mail ou Telemóvel'), findsOneWidget);
    expect(find.text('Palavra-passe'), findsOneWidget);
    expect(find.text('Esqueceu-se?'), findsOneWidget);
    expect(find.text('Registar agora'), findsOneWidget);
    expect(find.text('Privacidade'), findsOneWidget);
  });

  testWidgets('Login Entrar opens trip map home', (WidgetTester tester) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const LoginScreen()));
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Saldo Disponível'), findsOneWidget);
    expect(find.text('Confirmar Trajeto'), findsOneWidget);
  });

  testWidgets('Premium home search opens reservation review', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);

    await tester.pumpWidget(AppScreenUtil.testWrap(const PremiumHomeScreen()));
    await tester.enterText(
      find.byType(TextField),
      'tesla',
    );
    await tester.pump();
    expect(find.text('Tesla Model 3 Performance'), findsOneWidget);
    await tester.tap(find.text('Tesla Model 3 Performance'));
    await tester.pumpAndSettle();

    expect(find.text('Revisão da Reserva'), findsOneWidget);
    expect(find.text('Tesla Model 3 Performance'), findsWidgets);
    expect(find.text('472,94 €'), findsOneWidget);
  });

  testWidgets('Reservation review screen shows booking UI', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);

    await tester.pumpWidget(
      AppScreenUtil.testWrap(const ReservationReviewScreen()),
    );

    expect(find.text('Revisão da Reserva'), findsOneWidget);
    expect(find.text('Itinerário'), findsOneWidget);
    expect(find.text('Resumo de Custos'), findsOneWidget);
    expect(find.text('Confirmar e Pagar'), findsOneWidget);
    expect(find.text('Pagamento 100% Seguro'), findsOneWidget);
  });

  testWidgets('Premium home screen shows hub UI', (WidgetTester tester) async {
    _setPhoneSize(tester);

    await tester.pumpWidget(AppScreenUtil.testWrap(const PremiumHomeScreen()));

    expect(find.text('Mobilidade Premium'), findsOneWidget);
    expect(find.text('Para onde vamos hoje?'), findsOneWidget);
    expect(find.text('Procure destino ou serviço...'), findsOneWidget);
    expect(find.text('Entregas Rápidas'), findsOneWidget);
    expect(find.text('Pedir agora'), findsOneWidget);
    expect(find.text('Guia de Ilhas'), findsOneWidget);
    expect(find.text('Mota de Água'), findsOneWidget);
    expect(find.text('Transporte e Mobilidade'), findsOneWidget);
    expect(find.text('Experiências Premium'), findsOneWidget);
    expect(find.text('Aluguer de Motas de Água'), findsOneWidget);
    expect(find.text('Início'), findsOneWidget);
  });

  testWidgets('Trip map screen shows planning UI', (WidgetTester tester) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const HomeScreen()));

    expect(find.text('Saldo Disponível'), findsOneWidget);
    expect(find.text('42,50 €'), findsOneWidget);
    expect(find.text('Confirmar Trajeto'), findsOneWidget);
    expect(find.text('Reservar'), findsOneWidget);
    expect(find.text('Explorar Ilhas'), findsOneWidget);
  });

  testWidgets('Event detail screen shows booking UI', (WidgetTester tester) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const EventDetailScreen()));

    expect(find.text('Gala de Verão: Porto Sunset'), findsOneWidget);
    expect(find.text('Bilhete Normal'), findsOneWidget);
    expect(find.text('Pagar Agora'), findsOneWidget);
    expect(find.text('Experiência VIP'), findsOneWidget);
    expect(find.text('Reservas'), findsOneWidget);
  });

  testWidgets('Jetski screen shows fleet UI', (WidgetTester tester) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const JetskiScreen()));

    expect(find.text('Domine as Ondas'), findsOneWidget);
    expect(find.text('Nossa Frota'), findsOneWidget);
    expect(find.text('Yamaha GP1800R'), findsOneWidget);
    expect(find.text('Segurança Primeiro'), findsOneWidget);
    expect(find.text('Marina de Vilamoura'), findsOneWidget);
  });

  testWidgets('Discover screen shows Mediterranean UI', (WidgetTester tester) async {
    _setPhoneSize(tester);

    await tester.pumpWidget(AppScreenUtil.testWrap(const DiscoverScreen()));

    expect(find.text('A Essência do Mediterrâneo'), findsOneWidget);
    expect(find.text('Experiências Exclusivas'), findsOneWidget);
    expect(find.text('Próximos Eventos'), findsOneWidget);
    expect(find.text('Mapa Interativo'), findsOneWidget);
    expect(find.text('Sunset Ritual: Deep House'), findsOneWidget);
  });

  testWidgets('Delivery category tap opens premium home', (WidgetTester tester) async {
    _setPhoneSize(tester);

    await tester.pumpWidget(AppScreenUtil.testWrap(const DeliveryScreen()));
    await tester.tap(find.text('Farmácia'));
    await tester.pumpAndSettle();

    expect(find.text('Transporte e Mobilidade'), findsOneWidget);
    expect(find.text('Explorar Categorias'), findsNothing);
  });

  testWidgets('Delivery screen shows marketplace UI', (WidgetTester tester) async {
    _setPhoneSize(tester);

    await tester.pumpWidget(AppScreenUtil.testWrap(const DeliveryScreen()));

    expect(find.text('Entregar em: Av. da Liberdade, Lisboa'), findsOneWidget);
    expect(find.text('Explorar Categorias'), findsOneWidget);
    expect(find.text('Parceiros Premium'), findsOneWidget);
    expect(find.text('Destaques da Semana'), findsOneWidget);
    expect(find.text('Market Gourmet'), findsOneWidget);
    expect(find.text('Aspargos Biológicos'), findsOneWidget);
    expect(find.text('Viagens'), findsOneWidget);
  });
}
