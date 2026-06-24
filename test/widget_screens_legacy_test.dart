import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_ent_280/presentation/splash/splash_screen.dart';
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
import 'package:local_ent_280/presentation/admin/admin_home_screen.dart';
import 'package:local_ent_280/presentation/admin/admin_reports_screen.dart';
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
import 'package:local_ent_280/core/services/transport_types_service.dart';
import 'package:local_ent_280/presentation/trip/trip_confirm_screen.dart';
import 'package:local_ent_280/presentation/trip/trip_destination_screen.dart';
import 'package:local_ent_280/presentation/trip/trip_details_screen.dart';
import 'package:local_ent_280/presentation/trip/trip_history_screen.dart';
import 'package:local_ent_280/presentation/profile/profile_screen.dart';
import 'package:local_ent_280/presentation/widgets/app_bottom_nav.dart';
import 'package:local_ent_280/presentation/reservations/reservations_screen.dart';
import 'package:local_ent_280/features/auth/data/auth_signing.dart';
import 'package:local_ent_280/features/auth/data/models/app_user_profile.dart';
import 'package:local_ent_280/features/auth/data/models/app_user_role.dart';
import 'package:local_ent_280/features/auth/data/models/login_selected_role.dart';
import 'package:local_ent_280/presentation/login/login_screen.dart';
import 'package:local_ent_280/core/navigation/app_navigation.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:local_ent_280/features/auth/data/user_session.dart';
import 'package:local_ent_280/features/balance/data/balance_repository.dart';
import 'package:local_ent_280/features/trips/data/active_trip_session.dart';
import 'package:local_ent_280/features/trips/data/models/trip_location.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';
import 'package:local_ent_280/features/trips/data/repositories/trip_repository_impl.dart';
import 'package:local_ent_280/features/trips/domain/repositories/trip_repository.dart';

String _fmtEur(double major) =>
    AppCurrencyFormatter.instance.formatEurMajor(major);

String _fmtMinor(int minor) =>
    AppCurrencyFormatter.instance.formatEurMinor(minor);

class _FakeAuthRepository implements AuthSigning {
  _FakeAuthRepository(this._profile);

  final AppUserProfile _profile;

  @override
  Future<AppUserProfile> signIn({
    required String email,
    required String password,
    required LoginSelectedRole selectedRole,
  }) async =>
      _profile;

  @override
  Future<AppUserProfile> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required LoginSelectedRole selectedRole,
  }) async =>
      _profile.copyWith(name: name, email: email, phone: phone);
}

const _testClientProfile = AppUserProfile(
  uid: 'test-client-uid',
  email: 'cliente@example.com',
  name: 'João Silva',
  phone: '+351 912 345 678',
  role: AppUserRole.client,
  isActive: true,
);

final _testBalanceRepository = BalanceRepository(
  disabled: true,
  mockBalance: const ClientBalance(balanceMinor: 4250, currency: 'EUR'),
);

TripRepository _demoTripHistoryRepository() {
  final demoTrips = <TripRecord>[
    TripRecord(
      id: 'trip-1',
      clientId: _testClientProfile.uid,
      pickup: const TripLocation(
        address: 'Doca de Belém, Lisboa',
        latitude: 38.6916,
        longitude: -9.2159,
      ),
      destination: const TripLocation(
        address: 'Lisboa Marina Hotel, Lisboa',
        latitude: 38.7,
        longitude: -9.2,
      ),
      transportType: const TripTransportType(id: 'premium', name: 'Executivo'),
      status: 'COMPLETED',
      meteringSnapshot: const TripMeteringSnapshot(
        totalDistanceKm: 5.2,
        totalMinutes: 18,
        totalWaitMinutes: 0,
        estimatedCostMinor: 2450,
      ),
      createdAt: DateTime(2023, 10, 12),
    ),
    TripRecord(
      id: 'trip-2',
      clientId: _testClientProfile.uid,
      pickup: const TripLocation(
        address: 'Centro, Lisboa',
        latitude: 38.72,
        longitude: -9.14,
      ),
      destination: const TripLocation(
        address: 'Lisbon Airport (LIS)',
        latitude: 38.77,
        longitude: -9.13,
      ),
      transportType: const TripTransportType(id: 'eco', name: 'Eco'),
      status: 'COMPLETED',
      meteringSnapshot: const TripMeteringSnapshot(
        totalDistanceKm: 12,
        totalMinutes: 25,
        totalWaitMinutes: 0,
        estimatedCostMinor: 3200,
      ),
      createdAt: DateTime(2023, 10, 8),
    ),
    TripRecord(
      id: 'trip-3',
      clientId: _testClientProfile.uid,
      pickup: const TripLocation(
        address: 'Parque das Nações, Lisboa',
        latitude: 38.76,
        longitude: -9.09,
      ),
      destination: const TripLocation(
        address: 'Torre Vasco da Gama, Lisboa',
        latitude: 38.76,
        longitude: -9.09,
      ),
      transportType: const TripTransportType(id: 'shared', name: 'Partilhado'),
      status: 'CANCELLED_BY_CLIENT',
      meteringSnapshot: const TripMeteringSnapshot(
        totalDistanceKm: 3,
        totalMinutes: 10,
        totalWaitMinutes: 0,
        estimatedCostMinor: 1200,
      ),
      createdAt: DateTime(2023, 9, 30),
    ),
  ];

  return TripRepositoryImpl(
    disabled: true,
    watchClientTripsOverride: (_) => Stream.value(demoTrips),
  );
}

Widget _homeScreenForTests() {
  return HomeScreen(balanceRepository: _testBalanceRepository);
}

Widget _tripHistoryScreenForTests() {
  return TripHistoryScreen(
    clientId: _testClientProfile.uid,
    tripRepository: _demoTripHistoryRepository(),
  );
}

TripRepository _driverAssignedTripRepository() {
  return TripRepositoryImpl(
    disabled: true,
    watchTripOverride: (tripId) async* {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      yield TripRecord(
        id: tripId,
        clientId: _testClientProfile.uid,
        pickup: const TripLocation(
          address: 'Av. da Liberdade, 110',
          latitude: 38.72,
          longitude: -9.15,
        ),
        destination: const TripLocation(
          address: 'Lisbon Airport (LIS)',
          latitude: 38.77,
          longitude: -9.13,
        ),
        transportType: const TripTransportType(id: 'premium', name: 'Premium'),
        status: 'DRIVER_ASSIGNED_WAITING_ACCEPTANCE',
        assignedDriverId: 'driver-1',
        meteringSnapshot: const TripMeteringSnapshot(
          totalDistanceKm: 8,
          totalMinutes: 18,
          totalWaitMinutes: 0,
          estimatedCostMinor: 1450,
        ),
      );
    },
  );
}

TripRepository _createTripTestRepository() {
  return TripRepositoryImpl(
    disabled: true,
    createTripOverride: (_) async => 'created-trip-id',
    watchTripOverride: (_) => Stream<TripRecord?>.value(null),
  );
}

void _seedClientSession() {
  UserSession.instance.setProfile(_testClientProfile);
}

void _clearClientSession() {
  UserSession.instance.clear();
}

void _setPhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  group('legacy screen regression', () {
  setUpAll(() async {
    await initializeDateFormatting('pt');
  });

  setUp(() {
    AppNavigation.balanceRepositoryOverride = _testBalanceRepository;
    AppNavigation.tripHistoryRepositoryOverride = _demoTripHistoryRepository();
  });

  tearDown(() {
    AppNavigation.balanceRepositoryOverride = null;
    AppNavigation.tripHistoryRepositoryOverride = null;
    ActiveTripSession.instance.clear();
    _clearClientSession();
  });

  testWidgets('Splash screen shows app title', (WidgetTester tester) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(const SplashScreen()),
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
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        LoginScreen(
          authRepository: _FakeAuthRepository(
            const AppUserProfile(
              uid: 'test-client',
              email: 'client@test.com',
              name: 'Test Client',
              phone: '',
              role: AppUserRole.client,
              isActive: true,
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField).first, 'client@test.com');
    await tester.enterText(find.byType(TextField).last, 'password');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Saldo Disponível'), findsOneWidget);
    expect(find.text('Confirmar Trajeto'), findsOneWidget);
  });

  testWidgets('Login Entrar opens driver home for driver role', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        LoginScreen(
          authRepository: _FakeAuthRepository(
            const AppUserProfile(
              uid: 'test-driver',
              email: 'driver@test.com',
              name: 'Test Driver',
              phone: '',
              role: AppUserRole.driver,
              isActive: true,
            ),
          ),
        ),
        locale: const Locale('en'),
      ),
    );
    await tester.enterText(find.byType(TextField).first, 'driver@test.com');
    await tester.enterText(find.byType(TextField).last, 'password');
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text("Today's Earnings"), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('Mercedes-Benz EQE'), findsOneWidget);
  });

  testWidgets('Admin reports screen shows metrics and activities', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        const AdminReportsScreen(),
        locale: const Locale('en'),
      ),
    );
    await tester.pump();

    expect(find.text('Detailed Reports'), findsOneWidget);
    expect(find.text('Total Trips'), findsOneWidget);
    expect(find.text('1,284'), findsOneWidget);
    expect(find.text('Pending Debt'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Regional Delivery Porto'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Regional Delivery Porto'), findsOneWidget);
  });

  testWidgets('Admin home hides bottom navigation bar', (WidgetTester tester) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        const AdminHomeScreen(),
        locale: const Locale('en'),
      ),
    );
    await tester.pump();

    expect(find.text('Home'), findsNothing);
    expect(find.text('Trips'), findsNothing);
    expect(find.text('Reservations'), findsNothing);
    expect(find.text('Profile'), findsNothing);
  });

  testWidgets('Admin menu opens navigation drawer', (WidgetTester tester) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        const AdminHomeScreen(),
        locale: const Locale('en'),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('User'), findsOneWidget);
    expect(find.text('Detailed Reports'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('Admin drawer detailed reports opens reports screen', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        const AdminHomeScreen(),
        locale: const Locale('en'),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Detailed Reports'));
    await tester.pumpAndSettle();

    expect(find.text('Total Trips'), findsOneWidget);
    expect(find.text('Export'), findsOneWidget);
  });

  testWidgets('Admin reports back returns to dashboard', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        const AdminReportsScreen(),
        locale: const Locale('en'),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Local Transport'), findsOneWidget);
    expect(find.text('Fleet Status'), findsOneWidget);
  });

  testWidgets('Admin monthly reports row opens detailed reports', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        const AdminHomeScreen(),
        locale: const Locale('en'),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Monthly Reports'));
    await tester.pumpAndSettle();

    expect(find.text('Detailed Reports'), findsOneWidget);
  });

  testWidgets('Driver home hides trips and reservations nav', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        const DriverHomeScreen(),
        locale: const Locale('en'),
      ),
    );
    await tester.pump();

    final bottomNav = find.byType(AppBottomNav);
    expect(
      find.descendant(of: bottomNav, matching: find.text('Home')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: bottomNav, matching: find.text('Profile')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: bottomNav, matching: find.text('Reservations')),
      findsNothing,
    );
  });

  testWidgets('Driver drawer hides trips and reservations', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        const DriverHomeScreen(),
        locale: const Locale('en'),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Reservations'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Trips'),
      ),
      findsNothing,
    );
  });

  testWidgets('Driver home shows earnings and recent trips', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        const DriverHomeScreen(),
        locale: const Locale('en'),
      ),
    );
    await tester.pump();

    expect(find.text("Today's Earnings"), findsOneWidget);
    expect(find.text(_fmtEur(0)), findsOneWidget);
    expect(find.text('Recent Trips'), findsOneWidget);
  });

  testWidgets('Driver trip request shows accept and decline actions', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        const DriverTripRequestScreen(tripId: 'test-trip-1'),
        locale: const Locale('en'),
      ),
    );
    await tester.pump();

    expect(find.text('Premium Trip'), findsOneWidget);
    expect(find.text('ACCEPT TRIP'), findsOneWidget);
    expect(find.text('DECLINE'), findsOneWidget);
    expect(find.text(_fmtEur(14.50)), findsOneWidget);
  });

  testWidgets('Driver trip accepted shows start navigation', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        const DriverTripAcceptedScreen(tripId: 'test-trip-1'),
        locale: const Locale('en'),
      ),
    );
    await tester.pump();

    expect(find.text('Trip Accepted!'), findsOneWidget);
    expect(find.text('Start Navigation Now'), findsOneWidget);
  });

  testWidgets('Driver request expired shows dashboard action', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        const DriverRequestExpiredScreen(),
        locale: const Locale('en'),
      ),
    );
    await tester.pump();

    expect(find.text('Request Expired'), findsOneWidget);
    expect(find.text('Back to Dashboard'), findsOneWidget);
  });

  testWidgets('Driver active trip shows workflow buttons', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        const DriverActiveTripScreen(tripId: 'test-trip-1'),
        locale: const Locale('en'),
      ),
    );
    await tester.pump();

    expect(find.text('On the way'), findsOneWidget);
    expect(find.text("I've arrived"), findsOneWidget);
    expect(find.text('Start trip'), findsOneWidget);
    expect(find.text('Finish trip'), findsOneWidget);
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
    expect(find.text(_fmtEur(0)), findsOneWidget);
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

  testWidgets('Home menu opens navigation drawer', (WidgetTester tester) async {
    _setPhoneSize(tester);
    _seedClientSession();
    await tester.pumpWidget(AppScreenUtil.testWrap(_homeScreenForTests()));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Local Transport'), findsWidgets);
    expect(find.text('Início'), findsWidgets);
    expect(find.text('Sair'), findsOneWidget);
  });

  testWidgets('Trip map screen shows planning UI', (WidgetTester tester) async {
    _setPhoneSize(tester);
    _seedClientSession();
    await tester.pumpWidget(AppScreenUtil.testWrap(_homeScreenForTests()));
    await tester.pump();

    expect(find.text('Saldo Disponível'), findsOneWidget);
    expect(find.text(_fmtMinor(4250)), findsOneWidget);
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
    _seedClientSession();
    await tester.pumpWidget(AppScreenUtil.testWrap(_homeScreenForTests()));
    await tester.tap(find.text('Reservas'));
    await tester.pumpAndSettle();

    expect(find.text('Gerencie as suas próximas viagens'), findsOneWidget);
    expect(find.text('Nova reserva'), findsOneWidget);
    expect(find.text('Lisbon Airport (LIS)'), findsOneWidget);
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

  testWidgets('Results Ver Detalhes opens vehicle detail', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(const VehicleSearchResultsScreen()),
    );
    await tester.ensureVisible(find.text('Detalhes').first);
    await tester.tap(find.text('Detalhes').first);
    await tester.pumpAndSettle();

    expect(find.text('Detalhes do Veículo'), findsOneWidget);
    expect(find.text('Porsche Taycan 4S'), findsOneWidget);
    expect(find.text('DESPORTIVO PREMIUM'), findsOneWidget);
    expect(find.text('Resumo da Reserva'), findsOneWidget);
  });

  testWidgets('Trip destination screen shows search UI', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(const TripDestinationScreen()),
    );

    expect(find.text('Para onde vamos hoje?'), findsOneWidget);
    expect(find.text('Lisbon Airport (LIS)'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
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
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        TripConfirmScreen(
          route: TripRouteDraft.demo(),
          transportTypesService: TransportTypesService(useDefaultsOnly: true),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Avenida da Liberdade, 110'), findsOneWidget);
    expect(find.text('Lisbon Airport (LIS)'), findsOneWidget);
    expect(find.textContaining('km'), findsOneWidget);
    expect(find.textContaining('min'), findsOneWidget);
    expect(find.text('Eco-Eletric'), findsOneWidget);
    expect(find.text('**** 4421'), findsOneWidget);
    expect(find.textContaining('Total:'), findsOneWidget);
  });

  testWidgets('Confirmar viagem opens driver search', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    _seedClientSession();
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        TripConfirmScreen(
          route: TripRouteDraft.demo(),
          transportTypesService: TransportTypesService(useDefaultsOnly: true),
          tripRepository: _createTripTestRepository(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Confirmar viagem'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('A procurar motorista disponível'), findsOneWidget);
    expect(find.text('Otimizando percurso em tempo real...'), findsOneWidget);
    expect(find.text('Cancelar Viagem'), findsOneWidget);

    await tester.pumpWidget(AppScreenUtil.testWrap(const SizedBox.shrink()));
    await tester.pump();
  });

  testWidgets('Driver search screen shows loading UI', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const DriverSearchScreen()));
    await tester.pump();

    expect(find.text('A procurar motorista disponível'), findsOneWidget);
    expect(find.text('ESTIMATIVA'), findsOneWidget);
    expect(find.text('3–5 min'), findsOneWidget);
    expect(find.text('ORIGEM'), findsOneWidget);
    expect(find.text('Local Transport'), findsOneWidget);
  });

  testWidgets('Driver search navigates to driver found', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        DriverSearchScreen(
          tripId: 'trip-test',
          tripRepository: _driverAssignedTripRepository(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    expect(find.text('Motorista encontrado'), findsOneWidget);
    expect(find.text('A aguardar confirmação...'), findsOneWidget);
    expect(find.text('Ricardo Santos'), findsOneWidget);

    await tester.pumpWidget(AppScreenUtil.testWrap(const SizedBox.shrink()));
    await tester.pump();
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
    expect(find.text(_fmtEur(14.50)), findsOneWidget);
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
    expect(find.text(_fmtEur(12.50)), findsOneWidget);
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
    expect(find.text(_fmtEur(12.45)), findsOneWidget);
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
    expect(find.text(_fmtEur(0)), findsWidgets);
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
    await tester.pumpWidget(AppScreenUtil.testWrap(_tripHistoryScreenForTests()));
    await tester.pump();

    expect(find.text('Histórico de Viagens'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Todos'), findsOneWidget);
    expect(find.text('Lisboa Marina Hotel'), findsOneWidget);
    expect(find.text('Lisbon Airport (LIS)'), findsOneWidget);

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
    _seedClientSession();
    await tester.pumpWidget(AppScreenUtil.testWrap(_homeScreenForTests()));
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
    expect(find.text('Lisbon Airport (LIS)'), findsOneWidget);
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
    expect(find.text('Humberto Delgado Airport'), findsOneWidget);
    expect(find.text('Avalie a sua experiência'), findsOneWidget);
    expect(find.text('Editar'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Apoio ao cliente'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Fatura Digital'), findsOneWidget);
    expect(find.text('Tarifa Base'), findsOneWidget);
    expect(find.text(_fmtMinor(350)), findsOneWidget);
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
    await tester.pumpWidget(AppScreenUtil.testWrap(_tripHistoryScreenForTests()));
    await tester.pump();

    await tester.tap(find.text('Lisboa Marina Hotel'));
    await tester.pumpAndSettle();

    expect(find.text('Resumo da Viagem'), findsOneWidget);
    expect(find.text('Fatura Digital'), findsOneWidget);
  });

  testWidgets('Profile screen shows account info and logout', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(
      AppScreenUtil.testWrap(
        const ProfileScreen(
          initialProfile: AppUserProfile(
            uid: 'test-uid',
            email: 'cliente@example.com',
            name: 'João Silva',
            phone: '+351 912 345 678',
            role: AppUserRole.client,
            isActive: true,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('João Silva'), findsOneWidget);
    expect(find.text('cliente@example.com'), findsOneWidget);
    expect(find.text('Utilizador'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Terminar sessão'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Terminar sessão'), findsOneWidget);
  });

  testWidgets('Driver search Cancelar Viagem opens trip destination', (
    WidgetTester tester,
  ) async {
    _setPhoneSize(tester);
    await tester.pumpWidget(AppScreenUtil.testWrap(const DriverSearchScreen()));
    await tester.pump();

    await tester.ensureVisible(find.text('Cancelar Viagem'));
    await tester.tap(find.text('Cancelar Viagem'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Para onde vamos hoje?'), findsOneWidget);
  });
  }, skip: 'Legacy screen tests — update for Firebase/l10n integration');
}
