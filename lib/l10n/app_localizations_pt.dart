// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appNameLocalTransport => 'Local Transport';

  @override
  String get signIn => 'Entrar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get signOut => 'Sair';

  @override
  String get signOutTitle => 'Terminar sessão';

  @override
  String get signOutConfirmMessage =>
      'Tem a certeza de que pretende sair da sua conta?';

  @override
  String get signOutFailed =>
      'Não foi possível terminar sessão. Tente novamente.';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String featureComingSoon(String feature) {
    return '$feature estará disponível em breve.';
  }

  @override
  String get navHome => 'Início';

  @override
  String get navTrips => 'Viagens';

  @override
  String get navReservations => 'Reservas';

  @override
  String get navProfile => 'Perfil';

  @override
  String get loginSubtitle => 'Inicie sessão para gerir as suas viagens.';

  @override
  String get loginSettingsTooltip => 'Definições';

  @override
  String get loginEmailOrMobileLabel => 'E-mail ou Telemóvel';

  @override
  String get loginEmailHint => 'ex: joao@email.com';

  @override
  String get loginPasswordLabel => 'Palavra-passe';

  @override
  String get loginForgotPassword => 'Esqueceu-se?';

  @override
  String get loginFillEmailPassword => 'Preencha o e-mail e a palavra-passe.';

  @override
  String get loginNoAccountPrompt => 'Ainda não tem conta? ';

  @override
  String get loginRegisterNow => 'Registar agora';

  @override
  String get loginPrivacy => 'Privacidade';

  @override
  String get loginTermsOfUse => 'Termos de Uso';

  @override
  String get loginSupport => 'Suporte';

  @override
  String get loginRoleClient => 'Cliente';

  @override
  String get loginRoleProfessional => 'Profissional';

  @override
  String get secureConnectionE2E =>
      'Ligação segura e encriptada ponta-a-ponta.';

  @override
  String get authErrorUnexpected =>
      'Ocorreu um erro inesperado. Tente novamente.';

  @override
  String get authErrorProfileNotFound => 'Perfil de utilizador não encontrado.';

  @override
  String get authErrorAccountInactive =>
      'Esta conta está inactiva. Contacte o suporte.';

  @override
  String get authErrorRoleMismatch =>
      'Perfil não corresponde ao tipo selecionado.';

  @override
  String get authErrorInvalidEmail => 'E-mail inválido.';

  @override
  String get authErrorUserDisabled => 'Esta conta está desactivada.';

  @override
  String get authErrorWrongCredentials =>
      'E-mail ou palavra-passe incorrectos.';

  @override
  String get authErrorTooManyRequests =>
      'Demasiadas tentativas. Tente mais tarde.';

  @override
  String get authErrorSignInFailed =>
      'Não foi possível iniciar sessão. Tente novamente.';

  @override
  String get settingsTitle => 'Definições';

  @override
  String get settingsSubtitle =>
      'Ajuste preferências e mantenha a aplicação pronta para si.';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageDescription =>
      'Escolha o idioma da aplicação. Pode repor o idioma do dispositivo a qualquer momento.';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguagePortuguese => 'Português (Portugal)';

  @override
  String settingsLanguageFollowingDevice(String language) {
    return 'A seguir o idioma do dispositivo ($language).';
  }

  @override
  String settingsLanguageManual(String language) {
    return 'Idioma selecionado manualmente: $language.';
  }

  @override
  String get settingsLanguageResetSnack =>
      'Idioma reposto para o do dispositivo.';

  @override
  String get settingsUseDeviceLanguage => 'Repor idioma do dispositivo';

  @override
  String get settingsDisplayCurrency => 'Moeda de visualização';

  @override
  String get settingsDisplayCurrencyDescription =>
      'Escolha a moeda em que pretende ver os valores na aplicação.';

  @override
  String get settingsCurrencyCve => 'Escudo cabo-verdiano (CVE)';

  @override
  String get settingsCurrencyEur => 'Euro (€)';

  @override
  String get settingsCurrencyUsd => 'Dólar americano (USD)';

  @override
  String get settingsAccountSection => 'Conta';

  @override
  String get settingsChangePassword => 'Alterar palavra-passe';

  @override
  String get settingsSignOutAction => 'Terminar sessão';

  @override
  String get settingsSignOutLoading => 'A terminar sessão...';

  @override
  String get settingsDeveloperSection => 'Ferramentas de desenvolvedor';

  @override
  String get settingsDriverLocationSimulationTitle =>
      'Simulação de localização (demo)';

  @override
  String get settingsDriverLocationSimulationDescription =>
      'Disponível apenas em builds de desenvolvimento. No dispositivo do motorista, publica movimento simulado em direção à recolha na viagem ativa, sem marcar chegada automaticamente.';

  @override
  String get settingsDriverLocationSimulationSwitchLabel =>
      'Simular movimento do motorista';

  @override
  String get settingsResetOnboarding => 'Repor onboarding';

  @override
  String get settingsResetDone => 'Onboarding reposto.';

  @override
  String get settingsDeveloperDebugOnly =>
      'Secção visível apenas em builds de debug.';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileDefaultUserName => 'Utilizador';

  @override
  String get profileSessionNotFound =>
      'Sessão não encontrada. Inicie sessão novamente.';

  @override
  String get profileLoadFailed =>
      'Não foi possível carregar o perfil. Tente novamente.';

  @override
  String get profileRoleClient => 'Utilizador';

  @override
  String get profileRoleDriver => 'Motorista';

  @override
  String get profileRoleAdmin => 'Administrador';

  @override
  String get profilePhone => 'Telefone';

  @override
  String get profilePhoneNotSet => 'Não definido';

  @override
  String get profileAccountType => 'Tipo de conta';

  @override
  String get profileStatus => 'Estado';

  @override
  String get profileStatusActive => 'Activa';

  @override
  String get profileStatusInactive => 'Inactiva';

  @override
  String get profileMenuSettings => 'Definições';

  @override
  String get profileMenuPaymentMethods => 'Métodos de pagamento';

  @override
  String get profileMenuHelpCenter => 'Centro de ajuda';

  @override
  String get profileMenuPrivacySecurity => 'Privacidade e segurança';

  @override
  String get profileSessionSection => 'Sessão';

  @override
  String get profileGoToLogin => 'Ir para o login';

  @override
  String get homeAvailableBalance => 'Saldo Disponível';

  @override
  String get homeTopUp => 'Carregar';

  @override
  String get homeActionRequest => 'Pedir';

  @override
  String get homeActionBook => 'Reservar';

  @override
  String get homeActionRent => 'Alugar';

  @override
  String get homeActionHistory => 'Histórico';

  @override
  String get homeActionBalance => 'Saldo';

  @override
  String get homeWhereToday => 'Para onde vamos hoje?';

  @override
  String get homeCurrentLocation => 'Localização Atual';

  @override
  String get homeDestination => 'Destino';

  @override
  String get homeDestinationHint => 'Para onde deseja ir?';

  @override
  String get homeConfirmRoute => 'Confirmar Trajeto';

  @override
  String get reservationsTitle => 'Reservas';

  @override
  String get reservationsSubtitle => 'Gerencie as suas próximas viagens';

  @override
  String get reservationsNew => 'Nova reserva';

  @override
  String get reservationsPickup => 'Recolha';

  @override
  String get reservationsDestination => 'Destino';

  @override
  String get reservationsDetails => 'Detalhes';

  @override
  String get reservationsCancel => 'Cancelar';

  @override
  String get reservationsStatusConfirmed => 'Confirmada';

  @override
  String get reservationsStatusPending => 'Pendente';

  @override
  String get tripHistoryTitle => 'Histórico de Viagens';

  @override
  String get tripHistoryDetails => 'Detalhes';

  @override
  String get tripDetailsSummary => 'Resumo da Viagem';

  @override
  String get tripDetailsStatusCompleted => 'Concluída';

  @override
  String get rentalTitle => 'Aluguer de Veículos';

  @override
  String get rentalSubtitle =>
      'Encontre o parceiro perfeito para a sua próxima viagem.';

  @override
  String get rentalSearchAvailable => 'Pesquisar Veículos Disponíveis';

  @override
  String get driverSearchTitle => 'A procurar motorista disponível';

  @override
  String get driverFoundTitle => 'Motorista encontrado';

  @override
  String get driverEnRouteStatus => 'Motorista a caminho';

  @override
  String get tripInProgressEndTrip => 'Terminar Viagem';

  @override
  String get tripInProgressSupport => 'Suporte';

  @override
  String get tripCompletedTitle => 'Viagem Concluída!';

  @override
  String get tripCompletedBackHome => 'Voltar ao início';

  @override
  String get premiumHomeOrderNow => 'Pedir agora';

  @override
  String get support => 'Suporte';

  @override
  String get destination => 'Destino';

  @override
  String get details => 'Detalhes';

  @override
  String get premiumMobility => 'Mobilidade Premium';

  @override
  String get seeAll => 'Ver todos';

  @override
  String get edit => 'Editar';

  @override
  String get total => 'Total';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get quantity => 'Quantidade';

  @override
  String get distance => 'Distância';

  @override
  String get duration => 'Duração';

  @override
  String get premium => 'Premium';

  @override
  String get newBadge => 'Novo';

  @override
  String get promotion => 'Promoção';

  @override
  String get free => 'Grátis';

  @override
  String get live => 'LIVE';

  @override
  String get verified => 'Verificado';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get splashSecureConnection => 'Conexão Segura & Encriptada';

  @override
  String get splashExecutiveBadge => 'EXECUTIVO';

  @override
  String get splashHeroTitle => 'O seu tempo,\nvalorizado.';

  @override
  String get splashHeroSubtitle =>
      'Transporte personalizado com conforto e pontualidade.';

  @override
  String get splashInstantBookingTitle => 'Reservas Instantâneas';

  @override
  String get splashInstantBookingSubtitle =>
      'Planeie a sua viagem em segundos com a nossa rede exclusiva.';

  @override
  String get splashDriverOfToday => 'MOTORISTA DE HOJE';

  @override
  String get adminAppBarTitle => 'Mobilidade Premium';

  @override
  String get adminFleetStatusTitle => 'Estado da Frota';

  @override
  String get adminFleetStatusUpdated => 'Atualizado: Agora';

  @override
  String get adminActiveTripsLabel => 'Viagens Ativas';

  @override
  String get adminActiveTripsTrend => '+12% vs. ontem';

  @override
  String get adminAvailableDriversLabel => 'Motoristas Disponíveis';

  @override
  String get adminAvailableDriversHint => 'Pronto para despacho';

  @override
  String get adminCriticalOpsTitle => 'Operações Críticas';

  @override
  String get adminPendingDebtorsTitle => 'Devedores Pendentes';

  @override
  String get adminPendingDebtorsSubtitle => '3 faturas em atraso';

  @override
  String get adminMonthlyReportsTitle => 'Relatórios Mensais';

  @override
  String get adminMonthlyReportsSubtitle => 'Performance de Outubro';

  @override
  String get adminActivityMapTitle => 'Mapa de Atividade';

  @override
  String get adminRatesTitle => 'Tarifas & Mercado';

  @override
  String get adminBaseRateLabel => 'Tarifa Base';

  @override
  String get adminBaseRateDynamic => 'Dinâmica: Ativa (1.2x)';

  @override
  String get adminFuelCostLabel => 'Custo Combustível';

  @override
  String get adminFuelCostHint => 'Média Nacional';

  @override
  String get adminRecentFleetTitle => 'Frota Recente';

  @override
  String get adminFleetStatusOnTrip => 'Em Viagem';

  @override
  String get adminFleetStatusInactive => 'Inativo';

  @override
  String adminFleetDriverPrefix(String name) {
    return 'Motorista: $name';
  }

  @override
  String get deliveryDeliverTo => 'Entregar em: Av. da Liberdade, Lisboa';

  @override
  String get deliverySearchHint => 'O que procura hoje?';

  @override
  String get deliveryExploreCategories => 'Explorar Categorias';

  @override
  String get deliveryCategorySupermarket => 'Supermercado';

  @override
  String get deliveryCategorySupermarketSubtitle =>
      'Essenciais frescos à sua porta';

  @override
  String get deliveryCategoryPharmacy => 'Farmácia';

  @override
  String get deliveryCategoryBeverages => 'Bebidas';

  @override
  String get deliveryCategoryHealth => 'Saúde & Bem-estar';

  @override
  String get deliveryPartnersTitle => 'Parceiros Premium';

  @override
  String get deliveryPartnersSubtitle =>
      'Qualidade garantida e entregas rápidas';

  @override
  String get deliveryHighlightsTitle => 'Destaques da Semana';

  @override
  String get discoverSummerHighlight => 'DESTAQUE DE VERÃO';

  @override
  String get discoverHeroTitle => 'A Essência do Mediterrâneo';

  @override
  String get discoverHeroSubtitle =>
      'Descubra refúgios secretos e experiências de luxo desenhadas para o viajante exigente.';

  @override
  String get discoverSearchHint => 'Procurar restaurantes, festas ou praias...';

  @override
  String get discoverFilters => 'Filtros';

  @override
  String get discoverExploreMap => 'Explorar Mapa';

  @override
  String get discoverExperiencesTitle => 'Experiências Exclusivas';

  @override
  String get discoverCategoryGastronomy => 'Gastronomia';

  @override
  String get discoverExperienceRestaurants => 'Restaurantes de Autor';

  @override
  String get discoverCategoryExploration => 'Exploração';

  @override
  String get discoverExperienceSecretSpots => 'Recantos Secretos';

  @override
  String get discoverUpcomingEvents => 'Próximos Eventos';

  @override
  String get discoverTickets => 'Bilhetes';

  @override
  String get discoverInteractiveMapTitle => 'Mapa Interativo';

  @override
  String get discoverInteractiveMapSubtitle =>
      'Explore os pontos de interesse perto de si.';

  @override
  String get discoverCurrentLocation => 'Localização Atual';

  @override
  String get eventDateTimeLabel => 'Data e Hora';

  @override
  String get eventLocationLabel => 'Localização';

  @override
  String get eventAboutTitle => 'Sobre o Evento';

  @override
  String get eventDirectionsTitle => 'Como chegar';

  @override
  String get eventOpenGps => 'Abrir no GPS';

  @override
  String get eventStandardTicket => 'Bilhete Normal';

  @override
  String get eventStandardTicketDesc => 'Acesso geral + 1 bebida';

  @override
  String get eventServiceFee => 'Taxa de Serviço';

  @override
  String get eventPayNow => 'Pagar Agora';

  @override
  String get eventVipExperience => 'Experiência VIP';

  @override
  String get eventLimited => 'LIMITADO';

  @override
  String get eventVipDescription =>
      'Mesa reservada, garrafa incluída e acesso ao backstage.';

  @override
  String get eventCheckAvailability => 'Ver disponibilidade →';

  @override
  String get jetskiAdventureTag => 'Aventura no Mar';

  @override
  String get jetskiHeroTitle => 'Domine as Ondas';

  @override
  String get jetskiHeroSubtitle =>
      'Aluguer premium de motas de água de alta performance.';

  @override
  String get jetskiDurationLabel => 'DURAÇÃO';

  @override
  String get jetskiDurationValue => '1 Hora — Passeio Rápido';

  @override
  String get jetskiExploreFleet => 'Explorar Frota';

  @override
  String get jetskiOurFleet => 'Nossa Frota';

  @override
  String get jetskiBookNow => 'Reservar Agora';

  @override
  String get jetskiSafetyTitle => 'Segurança Primeiro';

  @override
  String get jetskiSafetyLifeJacketTitle => 'Colete Salva-vidas Incluído';

  @override
  String get jetskiSafetyLifeJacketSubtitle =>
      'Equipamento homologado para todos os pesos.';

  @override
  String get jetskiSafetyBriefingTitle => 'Briefing de Segurança';

  @override
  String get jetskiSafetyBriefingSubtitle =>
      'Instrução obrigatória de 15 min antes da partida.';

  @override
  String get jetskiSafetyGpsTitle => 'Monitorização GPS';

  @override
  String get jetskiSafetyGpsSubtitle =>
      'Equipa de apoio pronta para intervir 24/7.';

  @override
  String get jetskiOurBase => 'Nossa Base';

  @override
  String get jetskiOpenMap => 'Abrir Mapa';

  @override
  String get premiumHomeSearchHint => 'Procure destino ou serviço...';

  @override
  String get premiumHomeNoResults => 'Nenhum resultado encontrado';

  @override
  String get premiumHomeFastDelivery => 'Entregas Rápidas';

  @override
  String get premiumHomeGroceryPharmacy => 'Mercearia e Farmácia';

  @override
  String get premiumHomeIslandGuide => 'Guia de Ilhas';

  @override
  String get premiumHomeJetski => 'Mota de Água';

  @override
  String get premiumHomeTransportTitle => 'Transporte e Mobilidade';

  @override
  String get premiumHomeTransportTrip => 'Viagem';

  @override
  String get premiumHomeTransportMoto => 'Moto';

  @override
  String get premiumHomeTransportScooter => 'Trotinete';

  @override
  String get premiumHomeTransportBike => 'Bicicleta';

  @override
  String get premiumHomeExperiencesTitle => 'Experiências Premium';

  @override
  String get premiumHomeJetskiRentalTitle => 'Aluguer de Motas de Água';

  @override
  String get premiumHomeJetskiRentalDesc =>
      'Explore as águas cristalinas com o nosso novo serviço de aluguer premium.';

  @override
  String get premiumHomeFromPrice => 'Desde 45€';

  @override
  String get premiumHomeIslandGuideTitle => 'Guia Exclusivo de Ilhas';

  @override
  String get premiumHomeIslandGuideDesc =>
      'Descubra os segredos das ilhas com roteiros personalizados pelos locais.';

  @override
  String get rentalPickupLocation => 'Local de Recolha';

  @override
  String get rentalDropoffLocation => 'Local de Entrega';

  @override
  String get rentalSamePickupHint => 'Mesmo local de recolha';

  @override
  String get rentalDateSelection => 'Seleção de Datas';

  @override
  String get rentalDriverAge => 'Idade do Condutor';

  @override
  String get rentalDriverAgeNote =>
      'Taxas adicionais podem ser aplicadas para condutores fora do intervalo padrão.';

  @override
  String get rentalPremiumOnly => 'Premium Only';

  @override
  String get rentalLuxuryFleetOnly => 'Mostrar apenas frota de luxo';

  @override
  String get rentalViewFleetOnMap => 'Ver frota no mapa';

  @override
  String get rentalCarType => 'Tipo de Carro';

  @override
  String get rentalMaxPrice => 'Preço Máximo';

  @override
  String get rentalTransmission => 'Transmissão';

  @override
  String get rentalFilter => 'Filtrar';

  @override
  String get rentalPremiumHighlights => 'Destaques Premium';

  @override
  String rentalResultsFound(String count) {
    return '$count resultados encontrados';
  }

  @override
  String get rentalPremiumChoice => 'Premium Choice';

  @override
  String get rentalAllCars => 'Todos os Carros';

  @override
  String get rentalLoadMore => 'Carregar mais veículos';

  @override
  String get rentalVehicleDetails => 'Detalhes do Veículo';

  @override
  String get rentalRating => 'Classificação';

  @override
  String get rentalPowertrain => 'Motorização';

  @override
  String get rentalCapacity => 'Capacidade';

  @override
  String get rentalAcceleration => 'Aceleração';

  @override
  String get rentalInsuranceIncluded => 'Seguro Incluído';

  @override
  String get rentalFuelPolicy => 'Combustível';

  @override
  String get rentalCurrentBattery => 'Bateria Atual';

  @override
  String get rentalBookingSummary => 'Resumo da Reserva';

  @override
  String get rentalTotalCost => 'Custo Total';

  @override
  String get rentalTechnicalSpecs => 'ESPECIFICAÇÕES TÉCNICAS';

  @override
  String get rentalReservationTotal => 'Total da reserva';

  @override
  String get rentalContinueToPayment => 'Continuar para Pagamento';

  @override
  String get rentalPerDay => '/dia';

  @override
  String rentalSeats(String count) {
    return '$count Lugares';
  }

  @override
  String get rentalBag => 'Mala';

  @override
  String get rentalBags => 'Malas';

  @override
  String get reservationReviewTitle => 'Revisão da Reserva';

  @override
  String get reservationItinerary => 'Itinerário';

  @override
  String get reservationPickupLabel => 'LEVANTAMENTO';

  @override
  String get reservationReturnLabel => 'DEVOLUÇÃO';

  @override
  String get reservationSecurePayment => 'Pagamento 100% Seguro';

  @override
  String get reservationSecurePaymentDesc =>
      'Utilizamos encriptação SSL de 256 bits para proteger os seus dados.';

  @override
  String get reservationCostSummary => 'Resumo de Custos';

  @override
  String get reservationNoHiddenFees => 'Sem custos ocultos';

  @override
  String get reservationPaymentMethod => 'Método de Pagamento';

  @override
  String get reservationCreditCard => 'Cartão de Crédito';

  @override
  String get reservationPayWithApplePay => 'Pagar com Apple Pay';

  @override
  String get reservationConfirmAndPay => 'Confirmar e Pagar';

  @override
  String get reservationTermsPrefix =>
      'Ao clicar em \"Confirmar e Pagar\", aceita os nossos ';

  @override
  String get reservationTermsLink => 'Termos e Condições';

  @override
  String get reservationFullInsurance => 'Seguro Total Incluído';

  @override
  String get reservationsEmptyTitle => 'Ainda não tem mais reservas';

  @override
  String get reservationsEmptyBody =>
      'Planeie a sua próxima viagem com a nossa frota premium. Conforto e pontualidade garantidos.';

  @override
  String get reservationsExploreDestinations => 'Explorar destinos';

  @override
  String get tripHistoryActivity => 'A Minha Atividade';

  @override
  String get tripHistoryTrips => 'Viagens';

  @override
  String get tripHistoryThisMonth => 'Este Mês';

  @override
  String get tripHistoryFilterAll => 'Todos';

  @override
  String get tripHistoryFilterRecent => 'Viagens Recentes';

  @override
  String get tripHistoryFilterCompleted => 'Concluídas';

  @override
  String get tripHistoryFilterCancelled => 'Canceladas';

  @override
  String get tripHistoryFilterThisYear => 'Este Ano';

  @override
  String get tripHistoryStatusCancelled => 'Cancelada';

  @override
  String get tripHistoryNoDetails => 'Sem detalhes';

  @override
  String get tripDetailsRateExperience => 'Avalie a sua experiência';

  @override
  String get tripDetailsDigitalInvoice => 'Fatura Digital';

  @override
  String get tripDetailsTotalPaid => 'Total Pago';

  @override
  String get tripDetailsMethod => 'Método';

  @override
  String get tripDetailsDownloadPdf => 'Descarregar PDF';

  @override
  String get tripDetailsFareBase => 'Tarifa Base';

  @override
  String get tripDetailsFareDistance => 'Distância (12.5 km)';

  @override
  String get tripDetailsFareTime => 'Tempo (24 min)';

  @override
  String get tripDetailsFareDiscount => 'Desconto Promocional';

  @override
  String get tripDetailsSupportTitle => 'Algo correu mal?';

  @override
  String get tripDetailsSupportLostItem => 'Reportar objeto perdido';

  @override
  String get tripDetailsSupportSafety => 'Reclamação de segurança';

  @override
  String get tripDetailsSupportCustomer => 'Apoio ao cliente';

  @override
  String get tripCompletedThanks => 'Obrigado por viajar connosco.';

  @override
  String get tripCompletedFinalPrice => 'Preço Final';

  @override
  String get tripCompletedOptimizedRoute => 'Trajeto otimizado';

  @override
  String get tripCompletedRateTrip => 'Avalie a Viagem';

  @override
  String get tripCompletedRateHint =>
      'Como correu a sua experiência com o motorista e o veículo?';

  @override
  String get tripCompletedCommentOptional => 'Comentário (opcional)';

  @override
  String get tripCompletedCommentHint => 'Partilhe a sua opinião...';

  @override
  String get tripCompletedSubmitRating => 'Enviar avaliação';

  @override
  String get tripCompletedRatingSent => 'Avaliação enviada';

  @override
  String get tripCompletedReportIssue => 'Reportar problema';

  @override
  String get tripInProgressStatusLabel => 'Status da Viagem';

  @override
  String get tripInProgressStatusValue => 'Em viagem';

  @override
  String get tripInProgressArrivalLabel => 'Chegada prevista';

  @override
  String get tripInProgressCostLabel => 'Custo Estimado';

  @override
  String get driverSearchSubtitle =>
      'Estamos a ligar-te aos veículos mais próximos em Lisboa Central.';

  @override
  String get driverSearchOrigin => 'ORIGEM';

  @override
  String get driverSearchEstimate => 'ESTIMATIVA';

  @override
  String get driverSearchCancelTrip => 'Cancelar Viagem';

  @override
  String get driverSearchOptimizing => 'Otimizando percurso em tempo real...';

  @override
  String get driverFoundWaiting => 'A aguardar confirmação...';

  @override
  String get driverFoundEstimatedTime => 'Tempo estimado';

  @override
  String get driverFoundFare => 'Tarifa';

  @override
  String get driverFoundCancelHint =>
      'Pode cancelar sem custos nos próximos 2 minutos enquanto o motorista confirma a reserva.';

  @override
  String get driverEnRouteYourLocation => 'A sua localização';

  @override
  String get driverEnRouteMessage => 'Mensagem';

  @override
  String get driverEnRouteCall => 'Ligar';

  @override
  String get tripDestinationSubtitle =>
      'Procure um destino ou escolha um dos seus locais frequentes.';

  @override
  String get tripDestinationSearchHint =>
      'Pesquisar endereço ou ponto de interesse';

  @override
  String get tripDestinationRecentPlaces => 'Locais Recentes';

  @override
  String get tripDestinationSuggestions => 'Sugestões e Favoritos';

  @override
  String get tripDestinationExploreMap => 'Explorar Mapa';

  @override
  String get tripDestinationTodaySuggestion => 'SUGESTÃO DE HOJE';

  @override
  String get tripDestinationViewFullMap => 'Ver Mapa Completo';

  @override
  String get tripConfirmTransportType => 'Tipo de Transporte';

  @override
  String tripConfirmTotal(String amount) {
    return 'Total: $amount';
  }

  @override
  String get tripConfirmTrip => 'Confirmar viagem';

  @override
  String get tripConfirmPickupPoint => 'PONTO DE RECOLHA';

  @override
  String get tripConfirmFinalDestination => 'DESTINO FINAL';

  @override
  String get tripConfirmTransportPremium => 'Premium';

  @override
  String get tripConfirmTransportEco => 'Eco-Eletric';

  @override
  String get tripConfirmTransportShared => 'Partilhado';

  @override
  String get driverAvailable => 'Disponível';

  @override
  String get driverUnavailable => 'Indisponível';

  @override
  String get driverFleetStatus => 'Status da Frota';

  @override
  String get driverVerified => 'Verificado';

  @override
  String get driverInOperation => 'Em Operação';

  @override
  String get driverTodayEarnings => 'Ganhos de Hoje';

  @override
  String get driverEarningsChange => '+12% vs. ontem';

  @override
  String get driverTripsLabel => 'Viagens';

  @override
  String get driverDistanceLabel => 'Distância';

  @override
  String get driverRecentTrips => 'Últimas Viagens';

  @override
  String get driverLocationCity => 'Lisboa, PT';

  @override
  String driverHoursAgo(int hours) {
    return 'há ${hours}h';
  }

  @override
  String get driverNewRequest => 'Nova Solicitação';

  @override
  String get driverPremiumTrip => 'Viagem Premium';

  @override
  String get driverPickup => 'Recolha';

  @override
  String get driverDestination => 'Destino';

  @override
  String get driverDecline => 'RECUSAR';

  @override
  String get driverAcceptTrip => 'ACEITAR VIAGEM';

  @override
  String get driverTripAcceptedTitle => 'Viagem Aceite!';

  @override
  String get driverTripAcceptedSubtitle => 'A preparar a rota de navegação...';

  @override
  String get driverPassenger => 'Passageiro';

  @override
  String get driverEstimatedArrival => 'Chegada estimada';

  @override
  String get driverStartNavigation => 'Iniciar Navegação Agora';

  @override
  String get driverRequestExpiredTitle => 'Pedido Expirado';

  @override
  String get driverRequestExpiredMessage =>
      'O tempo limite de 12 segundos para aceitar a viagem esgotou.';

  @override
  String get driverUnavailableForRequests =>
      'Atualmente indisponível para novos pedidos';

  @override
  String get driverBackToDashboard => 'Voltar ao Dashboard';

  @override
  String get driverViewTripHistory => 'Ver Histórico de Viagens';

  @override
  String driverDistanceToDestination(String distance) {
    return 'A $distance do destino';
  }

  @override
  String get driverVipPassenger => 'Passageiro VIP';

  @override
  String get driverEstimatedTimeLabel => 'TEMPO ESTIMADO';

  @override
  String get driverDistanceStatLabel => 'DISTÂNCIA';

  @override
  String get driverOnTheWay => 'A caminho';

  @override
  String get driverArrivedStatus => 'Chegou ao local';

  @override
  String get driverTripInProgressStatus => 'Viagem em curso';

  @override
  String get driverArrivedButton => 'Cheguei';

  @override
  String get driverStartTripButton => 'Iniciar viagem';

  @override
  String get driverFinishTripButton => 'Finalizar viagem';

  @override
  String get adminReportsTitle => 'Relatórios Detalhados';

  @override
  String get adminReportsExport => 'Exportar';

  @override
  String get adminReportsDateRangeLabel => 'Intervalo de Datas';

  @override
  String get adminReportsVehicleFleetLabel => 'Veículo / Frota';

  @override
  String get adminReportsAllVehicles => 'Todos os Veículos';

  @override
  String get adminReportsTotalTrips => 'Total de Viagens';

  @override
  String get adminReportsTotalDistance => 'Distância Total';

  @override
  String get adminReportsTimeOnRoute => 'Tempo em Rota';

  @override
  String get adminReportsTotalCost => 'Custo Total';

  @override
  String get adminReportsPendingDebt => 'Dívida Pendente';

  @override
  String get adminReportsOverdueInvoices => 'FATURAS EM ATRASO';

  @override
  String get adminReportsMonthlyPerformance => 'Análise de Performance Mensal';

  @override
  String get adminReportsChartHint =>
      'Visualização detalhada das tendências de custo e quilometragem do período selecionado.';

  @override
  String get adminReportsLatestActivities => 'ÚLTIMAS ATIVIDADES';

  @override
  String get adminReportsFleetEfficiency => 'EFICIÊNCIA DA FROTA';

  @override
  String get adminReportsOptimizedStatus => 'OTIMIZADO';

  @override
  String adminReportsOptimized(int percent) {
    return '$percent% OTIMIZADO';
  }

  @override
  String get adminReportsEfficiencyFooter =>
      'A sua frota está a operar 15% acima da média do setor neste trimestre.';

  @override
  String get adminDrawerFleetManager => 'Gestor de Frota';

  @override
  String get adminDrawerFleetSubtitle => 'Frota Central Lisboa';

  @override
  String get adminDrawerRoleBadge => 'Admin';
}
