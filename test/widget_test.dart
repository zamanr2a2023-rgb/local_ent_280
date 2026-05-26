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
import 'package:local_ent_280/presentation/trip/trip_details_screen.dart';
import 'package:local_ent_280/presentation/trip/trip_history_screen.dart';
import 'package:local_ent_280/presentation/reservations/reservations_screen.dart';
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
      AppScreenUtil.init(child: const LocalTransportApp()),
    );

    expect(find.text('Local Transport'), findsOneWidget);
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
    await tester.enterText(find.byType(TextField), 'tesla');
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

    expect(find.text('Local Transport'), findsOneWidget);
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
    expect(find.text('Pedir'), findsOneWidget);
    expect(find.text('Reservar'), findsOneWidget);
    expect(find.text('Alugar'), findsOneWidget);
    expect(find.text('Histórico'), findsOneWidget);
    expect(find.text('Saldo'), findsOneWidget);
    expect(find.text('Explorar Ilhas'), findsNothing);
    expect(find.text('Aluguel'), findsNothing);
  });

  testWidgets('Home Reservas tab opens reservations screen', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const HomeScreen()));
    await tester.tap(find.text('Reservas'));
    await tester.pumpAndSettle();

    expect(find.text('Gerencie as suas próximas viagens'), findsOneWidget);
    expect(find.text('Nova reserva'), findsOneWidget);
    expect(find.text('Aeroporto de Lisboa (LIS)'), findsOneWidget);
  });

  testWidgets('Vehicle rental screen shows search UI', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(const VehicleRentalScreen()),
    );

    expect(find.text('Aluguer de Veículos'), findsOneWidget);
    expect(find.text('Local de Recolha'), findsOneWidget);
    expect(find.text('Seleção de Datas'), findsOneWidget);
    expect(find.text('Idade do Condutor'), findsOneWidget);
    expect(find.text('Pesquisar Veículos Disponíveis'), findsOneWidget);
    expect(find.text('Reservas'), findsOneWidget);
  });

  testWidgets('Search vehicles opens results list', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(const VehicleRentalScreen()),
    );
    await tester.ensureVisible(find.text('Pesquisar Veículos Disponíveis'));
    await tester.tap(find.text('Pesquisar Veículos Disponíveis'));
    await tester.pumpAndSettle();

    expect(find.text('Destaques Premium'), findsOneWidget);
    expect(find.text('Mercedes-Benz E-Class'), findsOneWidget);
    expect(find.text('Todos os Carros'), findsOneWidget);
    expect(find.text('Audi A3 Sedan'), findsOneWidget);
  });

  testWidgets('Results Ver Detalhes opens trip destination', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(const VehicleSearchResultsScreen()),
    );
    await tester.ensureVisible(find.text('Ver Detalhes').first);
    await tester.tap(find.text('Ver Detalhes').first);
    await tester.pumpAndSettle();

    expect(find.text('Para onde vamos hoje?'), findsWidgets);
    expect(find.text('Locais Recentes'), findsOneWidget);
    expect(find.text('Belém & Monumentos'), findsOneWidget);
    expect(find.text('Ver Mapa Completo'), findsOneWidget);
  });

  testWidgets('Trip destination screen shows search UI', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(const TripDestinationScreen()),
    );

    expect(find.text('Para onde vamos hoje?'), findsOneWidget);
    expect(find.text('Aeroporto de Lisboa (LIS)'), findsOneWidget);
    expect(find.text('Casa'), findsOneWidget);
    expect(find.text('Trabalho'), findsOneWidget);
    expect(find.text('Explorar Mapa'), findsOneWidget);
    expect(find.text('Viagens'), findsOneWidget);
  });

  testWidgets('Ver Mapa Completo opens trip confirm', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(const TripDestinationScreen()),
    );
    await tester.ensureVisible(find.text('Ver Mapa Completo'));
    await tester.tap(find.text('Ver Mapa Completo'));
    await tester.pumpAndSettle();

    expect(find.text('Confirmar viagem'), findsOneWidget);
    expect(find.text('PONTO DE RECOLHA'), findsOneWidget);
    expect(find.text('Tipo de Transporte'), findsOneWidget);
    expect(find.text('Premium'), findsOneWidget);
  });

  testWidgets('Trip confirm screen shows route and transport', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const TripConfirmScreen()));

    expect(find.text('Avenida da Liberdade, 110'), findsOneWidget);
    expect(find.text('8.4 km'), findsOneWidget);
    expect(find.text('14 min'), findsOneWidget);
    expect(find.text('Eco-Eletric'), findsOneWidget);
    expect(find.text('**** 4421'), findsOneWidget);
    expect(find.text('Total: 12,50€'), findsOneWidget);
  });

  testWidgets('Confirmar viagem opens driver search', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const TripConfirmScreen()));
    await tester.tap(find.text('Confirmar viagem'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('A procurar motorista disponível'), findsOneWidget);
    expect(find.text('Otimizando percurso em tempo real...'), findsOneWidget);
    expect(find.text('Cancelar Viagem'), findsOneWidget);
  });

  testWidgets('Driver search screen shows loading UI', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const DriverSearchScreen()));
    await tester.pump();

    expect(find.text('A procurar motorista disponível'), findsOneWidget);
    expect(find.text('ESTIMATIVA'), findsOneWidget);
    expect(find.text('3-5 minutos'), findsOneWidget);
    expect(find.text('ORIGEM'), findsOneWidget);
    expect(find.text('Local Transport'), findsOneWidget);
  });

  testWidgets('Driver search navigates to driver found', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const DriverSearchScreen()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();

    expect(find.text('Motorista encontrado'), findsOneWidget);
    expect(find.text('A aguardar confirmação...'), findsOneWidget);
    expect(find.text('Ricardo Santos'), findsOneWidget);
  });

  testWidgets('Driver found screen shows assignment UI', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const DriverFoundScreen()));
    await tester.pump();

    expect(find.text('Motorista encontrado'), findsOneWidget);
    expect(find.text('Ricardo Santos'), findsOneWidget);
    expect(find.text('Tesla Model 3 • Preto • 22-AA-00'), findsOneWidget);
    expect(find.text('Premium'), findsOneWidget);
    expect(find.text('4 min'), findsOneWidget);
    expect(find.text('14,50€'), findsOneWidget);
    expect(find.text('Cancelar Viagem'), findsOneWidget);
  });

  testWidgets('Driver found navigates to en route', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const DriverFoundScreen()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();

    expect(find.text('Motorista a caminho'), findsOneWidget);
    expect(find.text('Mensagem'), findsOneWidget);
    expect(find.text('Ligar'), findsOneWidget);
  });

  testWidgets('Driver en route screen shows trip UI', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(const DriverEnRouteScreen()),
    );
    await tester.pump();

    expect(find.text('Motorista a caminho'), findsOneWidget);
    expect(find.text('A sua localização'), findsOneWidget);
    expect(find.text('Ricardo Santos'), findsOneWidget);
    expect(find.text('4.9 • Tesla Model 3'), findsOneWidget);
    expect(find.text('AA-00-XX'), findsOneWidget);
    expect(find.text('Prateado Metalizado'), findsOneWidget);
    expect(find.text('ETA • 18:42'), findsOneWidget);
    expect(find.text('Mensagem'), findsOneWidget);
    expect(find.text('Ligar'), findsOneWidget);
  });

  testWidgets('Driver en route navigates to trip in progress', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(const DriverEnRouteScreen()),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();

    expect(find.text('Em viagem'), findsOneWidget);
    expect(find.text('Terminar Viagem'), findsOneWidget);
  });

  testWidgets('Trip in progress screen shows active trip UI', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(const TripInProgressScreen()),
    );
    await tester.pump();

    expect(find.text('Em viagem'), findsOneWidget);
    expect(find.text('Chegada prevista'), findsOneWidget);
    expect(find.text('14:45'), findsOneWidget);
    expect(find.text('Avenida da Liberdade, Lisboa'), findsOneWidget);
    expect(find.text('12,50€'), findsOneWidget);
    expect(find.text('Terminar Viagem'), findsOneWidget);
    expect(find.text('Suporte'), findsOneWidget);
    expect(find.text('Viagens'), findsOneWidget);
  });

  testWidgets('Terminar viagem opens trip completed', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(const TripInProgressScreen()),
    );
    await tester.pump();
    await tester.tap(find.text('Terminar Viagem'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Viagem Concluída!'), findsOneWidget);
    expect(find.text('Resumo da Viagem'), findsOneWidget);
    expect(find.text('Avalie a Viagem'), findsOneWidget);
  });

  testWidgets('Trip completed screen shows success UI', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(const TripCompletedScreen()),
    );
    await tester.pump();

    expect(find.text('Viagem Concluída!'), findsOneWidget);
    expect(find.text('Obrigado por viajar connosco.'), findsOneWidget);
    expect(find.text('12,45€'), findsOneWidget);
    expect(find.text('8.4 km'), findsOneWidget);
    expect(find.text('18 min'), findsOneWidget);
    expect(find.text('Trajeto otimizado'), findsOneWidget);
    expect(find.text('Enviar avaliação'), findsOneWidget);
    expect(find.text('Reportar problema'), findsOneWidget);
    expect(find.text('Voltar ao início'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNWidgets(4));
    expect(find.byIcon(Icons.star_border), findsOneWidget);
  });

  testWidgets('Vehicle search results screen shows fleet list', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(const VehicleSearchResultsScreen()),
    );

    expect(find.text('Tipo de Carro'), findsOneWidget);
    expect(find.text('Filtrar'), findsOneWidget);
    expect(find.text('2 resultados encontrados'), findsOneWidget);
    expect(find.text('BMW iX Electric'), findsOneWidget);
    expect(find.text('Volvo XC60'), findsOneWidget);
    expect(find.text('Carregar mais veículos'), findsOneWidget);
    expect(find.text('Viagens'), findsOneWidget);
  });

  testWidgets('Vehicle detail screen shows Taycan UI', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(const VehicleDetailScreen()),
    );

    expect(find.text('Porsche Taycan 4S'), findsOneWidget);
    expect(find.text('DESPORTIVO PREMIUM'), findsOneWidget);
    expect(find.text('Seguro Incluído'), findsOneWidget);
    expect(find.text('Resumo da Reserva'), findsOneWidget);
    expect(find.text('475,50 €'), findsWidgets);
    expect(find.text('ESPECIFICAÇÕES TÉCNICAS'), findsOneWidget);
  });

  testWidgets('Event detail screen shows booking UI', (
    WidgetTester tester,
  ) async {
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

  testWidgets('Discover screen shows Mediterranean UI', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);

    await tester.pumpWidget(AppScreenUtil.testWrap(const DiscoverScreen()));

    expect(find.text('A Essência do Mediterrâneo'), findsOneWidget);
    expect(find.text('Experiências Exclusivas'), findsOneWidget);
    expect(find.text('Próximos Eventos'), findsOneWidget);
    expect(find.text('Mapa Interativo'), findsOneWidget);
    expect(find.text('Sunset Ritual: Deep House'), findsOneWidget);
  });

  testWidgets('Delivery category tap opens premium home', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);

    await tester.pumpWidget(AppScreenUtil.testWrap(const DeliveryScreen()));
    await tester.tap(find.text('Farmácia'));
    await tester.pumpAndSettle();

    expect(find.text('Transporte e Mobilidade'), findsOneWidget);
    expect(find.text('Explorar Categorias'), findsNothing);
  });

  testWidgets('Delivery screen shows marketplace UI', (
    WidgetTester tester,
  ) async {
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

  testWidgets('Trip history screen shows trip list and stats', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const TripHistoryScreen()));
    await tester.pump();

    expect(find.text('Histórico de Viagens'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('128€'), findsOneWidget);
    expect(find.text('Todos'), findsOneWidget);
    expect(find.text('Lisboa Marina Hotel'), findsOneWidget);
    expect(find.text('Aeroporto de Lisboa (LIS)'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Torre Vasco da Gama'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Torre Vasco da Gama'), findsOneWidget);
    expect(find.text('Cancelada'), findsOneWidget);
  });

  testWidgets('Home Viagens tab opens trip history', (WidgetTester tester) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const HomeScreen()));
    await tester.tap(find.text('Viagens'));
    await tester.pumpAndSettle();

    expect(find.text('Histórico de Viagens'), findsOneWidget);
    expect(find.text('A MINHA ATIVIDADE'), findsOneWidget);
  });

  testWidgets('Reservations screen shows confirmed and pending cards', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const ReservationsScreen()));
    await tester.pump();

    expect(find.text('Gerencie as suas próximas viagens'), findsOneWidget);
    expect(find.text('Nova reserva'), findsOneWidget);
    expect(find.text('15 de Outubro, 2023'), findsOneWidget);
    expect(find.text('Aeroporto de Lisboa (LIS)'), findsOneWidget);
    expect(find.text('Avenida da Liberdade, 120'), findsOneWidget);
    expect(find.text('Confirmada'), findsOneWidget);
    expect(find.text('Executivo · Tesla Model S'), findsOneWidget);
    expect(find.text('Detalhes'), findsOneWidget);
    expect(find.text('18 de Outubro, 2023'), findsOneWidget);
    expect(find.text('Hotel Altis Grand'), findsOneWidget);
    expect(find.text('Pendente'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });

  testWidgets('Reservations empty state shows explore button', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const ReservationsScreen()));
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('Explorar destinos'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Ainda não tem mais reservas'), findsOneWidget);
    expect(find.text('Explorar destinos'), findsOneWidget);
  });

  testWidgets('Trip details screen shows summary invoice and driver', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const TripDetailsScreen()));
    await tester.pump();

    expect(find.text('Resumo da Viagem'), findsOneWidget);
    expect(find.text('14 de Outubro, 2023 • 18:42'), findsOneWidget);
    expect(find.text('Concluída'), findsOneWidget);
    expect(find.text('Avenida da Liberdade, 110'), findsOneWidget);
    expect(find.text('Aeroporto Humberto Delgado'), findsOneWidget);
    expect(find.text('Avalie a sua experiência'), findsOneWidget);
    expect(find.text('Editar'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Apoio ao cliente'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Fatura Digital'), findsOneWidget);
    expect(find.text('Tarifa Base'), findsOneWidget);
    expect(find.text('20,05 €'), findsOneWidget);
    expect(find.text('Descarregar PDF'), findsOneWidget);
    expect(find.text('Ricardo Santos'), findsOneWidget);
    expect(find.text('Tesla Model 3 • 42-XG-99'), findsOneWidget);
    expect(find.text('Algo correu mal?'), findsOneWidget);
    expect(find.text('Reportar objeto perdido'), findsOneWidget);
  });

  testWidgets('Trip history card opens trip details', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const TripHistoryScreen()));
    await tester.pump();

    await tester.tap(find.text('Lisboa Marina Hotel'));
    await tester.pumpAndSettle();

    expect(find.text('Resumo da Viagem'), findsOneWidget);
    expect(find.text('Fatura Digital'), findsOneWidget);
  });

  testWidgets('Driver search Cancelar Viagem opens trip destination', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const DriverSearchScreen()));
    await tester.pump();

    await tester.tap(find.text('Cancelar Viagem'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Para onde vamos hoje?'), findsOneWidget);
  });
}
