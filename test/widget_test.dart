import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_ent_280/main.dart';
import 'package:local_ent_280/presentation/discover/discover_screen.dart';
import 'package:local_ent_280/presentation/event/event_detail_screen.dart';
import 'package:local_ent_280/presentation/jetski/jetski_screen.dart';
import 'package:local_ent_280/presentation/home/home_screen.dart';
import 'package:local_ent_280/presentation/login/login_screen.dart';

void main() {
  testWidgets('Splash screen shows app title', (WidgetTester tester) async {
    await tester.pumpWidget(const MobilidadePremiumApp());

    expect(find.text('Mobilidade Premium'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar conta'), findsOneWidget);
  });

  testWidgets('Login screen shows form fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen()),
    );

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

  testWidgets('Home screen shows trip planning UI', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Saldo Disponível'), findsOneWidget);
    expect(find.text('42,50 €'), findsOneWidget);
    expect(find.text('Para onde vamos hoje?'), findsOneWidget);
    expect(find.text('Confirmar Trajeto'), findsOneWidget);
    expect(find.text('Pedir'), findsOneWidget);
    expect(find.text('Início'), findsOneWidget);
  });

  testWidgets('Event detail screen shows booking UI', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: EventDetailScreen()));

    expect(find.text('Gala de Verão: Porto Sunset'), findsOneWidget);
    expect(find.text('Bilhete Normal'), findsOneWidget);
    expect(find.text('Pagar Agora'), findsOneWidget);
    expect(find.text('Experiência VIP'), findsOneWidget);
    expect(find.text('Reservas'), findsOneWidget);
  });

  testWidgets('Jetski screen shows fleet UI', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: JetskiScreen()));

    expect(find.text('Domine as Ondas'), findsOneWidget);
    expect(find.text('Nossa Frota'), findsOneWidget);
    expect(find.text('Yamaha GP1800R'), findsOneWidget);
    expect(find.text('Segurança Primeiro'), findsOneWidget);
    expect(find.text('Marina de Vilamoura'), findsOneWidget);
  });

  testWidgets('Discover screen shows Mediterranean UI', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));

    expect(find.text('A Essência do Mediterrâneo'), findsOneWidget);
    expect(find.text('Experiências Exclusivas'), findsOneWidget);
    expect(find.text('Próximos Eventos'), findsOneWidget);
    expect(find.text('Mapa Interativo'), findsOneWidget);
    expect(find.text('Sunset Ritual: Deep House'), findsOneWidget);
  });
}
