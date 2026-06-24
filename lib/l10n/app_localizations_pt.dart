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
  String get save => 'Guardar';

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
  String get navBalance => 'Saldo';

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
  String get authErrorEmailInUse => 'Este e-mail já está registado.';

  @override
  String get authErrorWeakPassword =>
      'Palavra-passe demasiado fraca. Use pelo menos 6 caracteres.';

  @override
  String get authErrorRegistrationFailed =>
      'Não foi possível criar a conta. Tente novamente.';

  @override
  String get registerSubtitle =>
      'Crie a sua conta como cliente ou motorista profissional.';

  @override
  String get registerNameLabel => 'Nome completo';

  @override
  String get registerNameHint => 'ex. João Silva';

  @override
  String get registerPhoneLabel => 'Telemóvel (opcional)';

  @override
  String get registerPhoneHint => 'ex. +351910000000';

  @override
  String get registerConfirmPasswordLabel => 'Confirmar palavra-passe';

  @override
  String get registerFillRequiredFields =>
      'Preencha nome, e-mail e palavra-passe.';

  @override
  String get registerPasswordTooShort =>
      'A palavra-passe deve ter pelo menos 6 caracteres.';

  @override
  String get registerPasswordMismatch => 'As palavras-passe não coincidem.';

  @override
  String get registerAlreadyHaveAccount => 'Já tem conta? ';

  @override
  String get registerSignInNow => 'Iniciar sessão';

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
  String get profileChangePhoto => 'Alterar foto de perfil';

  @override
  String get profilePhotoFromGallery => 'Escolher da galeria';

  @override
  String get profilePhotoTakePhoto => 'Tirar foto';

  @override
  String get profilePhotoUpdated => 'Foto de perfil actualizada';

  @override
  String get profilePhotoUpdateFailed =>
      'Não foi possível actualizar a foto. Tente novamente.';

  @override
  String get profilePhotoPermissionDenied =>
      'Sem permissão para enviar a foto. Contacte o suporte se o problema persistir.';

  @override
  String get profilePhotoUploading => 'A enviar foto...';

  @override
  String get profileEditName => 'Editar nome';

  @override
  String get profileNameHint => 'O seu nome';

  @override
  String get profileNameUpdated => 'Nome atualizado';

  @override
  String get profileNameUpdateFailed =>
      'Não foi possível atualizar o nome. Tente novamente.';

  @override
  String get profileNamePermissionDenied =>
      'Não foi possível actualizar o nome. Verifique a sua sessão ou contacte o suporte.';

  @override
  String get profileNameEmpty => 'Introduza o seu nome.';

  @override
  String get homeAvailableBalance => 'Saldo Disponível';

  @override
  String get homeTopUp => 'Ver saldo';

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
  String get clientBalanceTitle => 'Saldo';

  @override
  String get clientBalanceSubtitle =>
      'Saldo da sua conta actualizado em tempo real.';

  @override
  String get clientBalanceDebtLimit => 'Limite de dívida';

  @override
  String get clientBalanceLastUpdated => 'Última atualização';

  @override
  String get clientBalanceHistoryTitle => 'Ajustes recentes';

  @override
  String get clientBalanceHistoryEmpty => 'Ainda sem ajustes';

  @override
  String get clientBalanceHistoryEmptyBody =>
      'Alterações de saldo feitas pelo admin aparecem aqui.';

  @override
  String get clientBalanceAdjustmentDefault => 'Ajuste de saldo';

  @override
  String get clientBalanceDebtWarningTitle => 'Limite de dívida atingido';

  @override
  String get clientBalanceDebtWarningBody =>
      'Contacte o suporte para carregar o saldo e continuar a pedir viagens.';

  @override
  String get clientBalanceTopUpTitle => 'Como carregar';

  @override
  String get clientBalanceTopUpBody =>
      'O carregamento do saldo é gerido pelo suporte. Ligue para pedir crédito — aparecerá aqui após aprovação do administrador.';

  @override
  String get clientBalanceContactSupport => 'Contactar suporte';

  @override
  String get clientBalanceSupportUnavailable =>
      'Telefone de suporte indisponível. Contacte a equipa de apoio.';

  @override
  String get clientBalanceSupportCallFailed =>
      'Não foi possível abrir o marcador telefónico neste dispositivo.';

  @override
  String get tripConfirmLimitExceededCallSupport => 'Ligar para suporte';

  @override
  String get clientBalanceUnavailable => 'Saldo indisponível';

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
  String get homeLocationLoading => 'A obter a sua localização...';

  @override
  String get homeLocationUnavailable => 'Não foi possível obter a localização';

  @override
  String get homeRefreshLocation => 'Atualizar localização';

  @override
  String get homeSelectLocationOnMap => 'Selecionar no mapa';

  @override
  String get homeSelectLocationOnMapHint =>
      'Mova o mapa ou toque no botão de localização para usar a posição atual.';

  @override
  String get homeUseMapLocation => 'Usar esta localização';

  @override
  String get homeLocationPermissionTitle => 'Permitir localização';

  @override
  String get homeLocationPermissionMessage =>
      'O Local Transport precisa da sua localização para definir automaticamente o ponto de recolha.';

  @override
  String get homeLocationPermissionAllow => 'Permitir';

  @override
  String get homeLocationPermissionDeny => 'Agora não';

  @override
  String get homeLocationPermissionSettingsMessage =>
      'A permissão de localização está desativada. Abra as definições para permitir o acesso.';

  @override
  String get homeLocationOpenSettings => 'Abrir definições';

  @override
  String get homeLocationServicesDisabled =>
      'Ative os serviços de localização no dispositivo para usar o seu endereço atual.';

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
  String get premiumMobility => 'Local Transport';

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
  String get adminAppBarTitle => 'Local Transport';

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
  String adminPendingDebtorsCount(int count) {
    return '$count faturas em atraso';
  }

  @override
  String adminActiveTripsTrendDynamic(String change) {
    return '$change vs. ontem';
  }

  @override
  String get adminNoFleetVehicles => 'Ainda sem viaturas na frota';

  @override
  String get adminNoReportActivities => 'Ainda sem viagens concluídas';

  @override
  String adminBaseRateLive(String multiplier) {
    return 'Dinâmica: Ativa ($multiplier)';
  }

  @override
  String get adminMonthlyReportsTitle => 'Relatórios Mensais';

  @override
  String get adminMonthlyReportsSubtitle => 'Performance de Outubro';

  @override
  String get adminActivityMapTitle => 'Mapa de Atividade';

  @override
  String get adminActivityMapWaiting =>
      'À espera de viagens e localizações em tempo real';

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
  String get adminHubTitle => 'Área de administração';

  @override
  String get adminHubHeading => 'Área de administração';

  @override
  String get adminHubSubtitle => 'Gerir operações, frota, tarifas e suporte.';

  @override
  String get adminUsersTitle => 'Utilizadores';

  @override
  String get adminUsersDesc => 'Gestão de contas e permissões.';

  @override
  String get adminUsersHeading => 'Gestão de contas e permissões';

  @override
  String get adminUsersSubtitle => 'Gerir perfis, funções e acessos da equipa.';

  @override
  String get adminUsersSearchHint =>
      'Pesquisar por nome, email, telefone ou ID';

  @override
  String get adminUsersEmpty => 'Nenhum utilizador encontrado';

  @override
  String get adminUsersCreateTitle => 'Adicionar utilizador';

  @override
  String get adminUsersCreateSubtitle =>
      'Criar conta de cliente, motorista, gestor ou admin.';

  @override
  String get adminUsersCreateAction => 'Criar utilizador';

  @override
  String get adminUsersCreateSuccess => 'Utilizador criado com sucesso';

  @override
  String get adminUsersCreateFailed => 'Não foi possível criar o utilizador';

  @override
  String get adminUsersRoleLabel => 'Função';

  @override
  String get adminUsersAddTooltip => 'Adicionar utilizador';

  @override
  String get adminStatusActive => 'Ativo';

  @override
  String get adminStatusInactive => 'Inativo';

  @override
  String get adminStatusOpen => 'Aberto';

  @override
  String get adminStatusResolved => 'Resolvido';

  @override
  String get adminStatusConfigured => 'Configurado';

  @override
  String get adminManagerPermissionsTitle => 'Permissões de gestor';

  @override
  String get adminManagerPermissionsDesc =>
      'Configurar permissões operacionais por gestor.';

  @override
  String get adminManagerPermissionsHeading =>
      'Configuração de permissões operacionais';

  @override
  String get adminManagerPermissionsSubtitle =>
      'Configure, por gestor, os módulos e ações permitidas.';

  @override
  String get adminManagersEmpty => 'Nenhum gestor encontrado';

  @override
  String get adminStatusUnconfigured => 'Não configurado';

  @override
  String get adminManagerPermissionsSaveAction => 'Guardar permissões';

  @override
  String get adminManagerPermissionsSaveSuccess =>
      'Permissões do gestor guardadas';

  @override
  String get adminManagerPermissionsSaveError =>
      'Não foi possível guardar as permissões';

  @override
  String get managerPermissionViewTrips => 'Ver viagens';

  @override
  String get managerPermissionViewReports => 'Ver relatórios';

  @override
  String get managerPermissionViewAudit => 'Ver auditoria';

  @override
  String get managerPermissionViewDrivers => 'Ver motoristas';

  @override
  String get managerPermissionViewClients => 'Ver clientes';

  @override
  String get managerPermissionViewSupportRequests => 'Ver pedidos de suporte';

  @override
  String get managerPermissionManageClientChats =>
      'Gerir conversas de clientes';

  @override
  String get managerPermissionCancelTripBySupport =>
      'Cancelar viagem por suporte';

  @override
  String get managerPermissionUpdateTripSupport =>
      'Atualizar suporte da viagem';

  @override
  String get managerPermissionResolvePasswordHelpRequest =>
      'Resolver pedidos de ajuda de password';

  @override
  String get managerPermissionManageEvents => 'Gerir eventos';

  @override
  String get managerPermissionAssignVehicleToDriver => 'Atribuir veículo';

  @override
  String get managerPermissionEditDriverStatus => 'Editar estado do motorista';

  @override
  String get managerPermissionManageTariffs => 'Gerir tarifas';

  @override
  String get managerPermissionManageTripPackages => 'Gerir pacotes de viagem';

  @override
  String get adminSupportRequestsTitle => 'Pedidos de suporte';

  @override
  String get adminSupportRequestsDesc =>
      'Caixa de entrada de suporte e ajuda de password.';

  @override
  String get adminSupportEmpty => 'Sem pedidos de suporte';

  @override
  String get adminIncidentsTitle => 'Incidentes operacionais';

  @override
  String get adminIncidentsDesc => 'Incidentes de monitorização e aprovações.';

  @override
  String get adminIncidentsEmpty => 'Sem incidentes operacionais';

  @override
  String get adminIncidentDetailTitle => 'Detalhes do incidente';

  @override
  String get adminIncidentCurrentState => 'Estado atual';

  @override
  String get adminIncidentTrip => 'Viagem';

  @override
  String get adminIncidentStarted => 'Iniciado';

  @override
  String get adminIncidentRouteSummary => 'Resumo da rota';

  @override
  String get adminIncidentKmSummary => 'Resumo de km';

  @override
  String get adminMonitoringTitle => 'Definições de monitorização';

  @override
  String get adminMonitoringDesc => 'Limites para monitorização operacional.';

  @override
  String get adminMonitoringHeading => 'Monitorização operacional';

  @override
  String get adminMonitoringSubtitle =>
      'Rever limites de monitorização operacional.';

  @override
  String get adminMonitoringConfig => 'Configuração atual';

  @override
  String get adminMonitoringLoading =>
      'A carregar configuração de monitorização...';

  @override
  String get adminMonitoringEnabled => 'Monitorização ativa';

  @override
  String get adminMonitoringEnabledHint =>
      'A monitorização operacional só corre quando está ativa.';

  @override
  String get adminMonitoringBaseGeofence => 'Geofence base';

  @override
  String get adminMonitoringServiceGeofences => 'Geofences de serviço';

  @override
  String adminMonitoringServiceGeofenceCount(int count) {
    return '$count configuradas';
  }

  @override
  String get adminMonitoringLastUpdated => 'Última atualização';

  @override
  String get adminMonitoringSaveSuccess =>
      'Configuração de monitorização guardada';

  @override
  String get adminReservationsTitle => 'Reservas operacionais';

  @override
  String get adminReservationsDesc => 'Agendar viagens futuras para clientes.';

  @override
  String get adminReservationsEmpty => 'Sem reservas';

  @override
  String get adminSupportSettingsTitle => 'Contacto de suporte';

  @override
  String get adminSupportSettingsDesc =>
      'Telefone oficial para recuperação de password.';

  @override
  String get adminSupportSettingsHeading => 'Contacto de suporte';

  @override
  String get adminSupportSettingsSubtitle =>
      'Definir o número oficial de contacto.';

  @override
  String get adminSupportPhoneLabel => 'Telefone de suporte';

  @override
  String get adminEventsTitle => 'Eventos e alertas';

  @override
  String get adminEventsDesc => 'Enviar lembretes e avisos aos motoristas.';

  @override
  String get adminEventsEmpty => 'Sem eventos agendados';

  @override
  String get adminFleetTitle => 'Frota';

  @override
  String get adminFleetDesc => 'Acompanhar viaturas, estado e disponibilidade.';

  @override
  String get adminFleetNoDriver => 'Sem motorista atribuído';

  @override
  String get adminFleetDriver => 'Motorista';

  @override
  String get adminFleetAssignDriverTitle => 'Atribuir motorista';

  @override
  String get adminFleetAssignDriverDesc =>
      'Selecione um motorista para esta viatura.';

  @override
  String get adminFleetAssignDriverEmpty =>
      'Nenhum motorista ativo encontrado.';

  @override
  String get adminFleetAssignDriverSuccess =>
      'Motorista atribuído com sucesso.';

  @override
  String get adminTransportTypesTitle => 'Tipos de transporte';

  @override
  String get adminTransportTypesDesc => 'Criar e gerir tipos disponíveis.';

  @override
  String get adminTransportTypesEmpty => 'Sem tipos de transporte';

  @override
  String get adminTripPackagesTitle => 'Pacotes de viagem';

  @override
  String get adminTripPackagesDesc =>
      'Pacotes pré-pagos com destino e preço fixos.';

  @override
  String get adminTripPackagesEmpty => 'Sem pacotes de viagem';

  @override
  String get adminTariffsTitle => 'Tarifas';

  @override
  String get adminTariffsDesc => 'Definir preços, regras e ajustes sazonais.';

  @override
  String get adminTariffAdminDefault => 'Tarifa admin default';

  @override
  String get adminTariffPublicDefault => 'Tarifa public default';

  @override
  String get adminBalancesTitle => 'Vendas';

  @override
  String get adminBalancesDesc =>
      'Controlar saldos, limites e operações pendentes.';

  @override
  String get adminBalancesEmpty => 'Sem saldos';

  @override
  String get adminBalancesDebt => 'Dívida';

  @override
  String get adminBalancesCredit => 'Crédito';

  @override
  String get adminBalanceCurrent => 'Saldo atual';

  @override
  String get adminBalanceDebtLimit => 'Limite de dívida';

  @override
  String get adminBalanceAdjustAction => 'Ajustar saldo';

  @override
  String get adminBalanceAdjustTitle => 'Ajuste manual de saldo';

  @override
  String get adminBalanceCredit => 'Crédito';

  @override
  String get adminBalanceDebt => 'Débito';

  @override
  String get adminBalanceAmountLabel => 'Valor (EUR)';

  @override
  String get adminBalanceAmountRequired => 'Introduza um valor válido.';

  @override
  String get adminBalanceReasonLabel => 'Motivo';

  @override
  String get adminBalanceReasonRequired => 'Introduza um motivo.';

  @override
  String get adminBalanceConfirm => 'Confirmar ajuste';

  @override
  String get adminBalanceAdjustSuccess => 'Saldo atualizado';

  @override
  String get adminVehicleCreateTitle => 'Nova viatura';

  @override
  String get adminVehicleEditTitle => 'Editar viatura';

  @override
  String get adminVehicleCreateAction => 'Criar viatura';

  @override
  String get adminVehicleCreateSuccess => 'Viatura criada';

  @override
  String get adminVehicleAddPhoto => 'Adicionar foto';

  @override
  String get adminVehiclePlateLabel => 'Matrícula';

  @override
  String get adminVehicleModelLabel => 'Modelo';

  @override
  String get adminVehicleCapacityLabel => 'Capacidade';

  @override
  String get adminVehicleTransportTypeLabel => 'Tipo de transporte predefinido';

  @override
  String get adminVehicleNoPreference => 'Sem preferência';

  @override
  String get adminVehicleNotesLabel => 'Notas';

  @override
  String get adminVehicleActiveLabel => 'Viatura ativa';

  @override
  String get adminVehicleRequiredFields => 'Preencha matrícula e modelo.';

  @override
  String get adminTransportTypeCreateTitle => 'Novo tipo de transporte';

  @override
  String get adminTransportTypeEditTitle => 'Editar tipo de transporte';

  @override
  String get adminTransportTypeCreateAction => 'Criar tipo';

  @override
  String get adminTransportTypeCreateSuccess => 'Tipo de transporte criado';

  @override
  String get adminTransportTypeNameLabel => 'Nome';

  @override
  String get adminTransportTypeNameRequired => 'Introduza um nome.';

  @override
  String get adminTransportTypeBaseFareLabel => 'Tarifa base inicial';

  @override
  String get adminTransportTypeMultiplierLabel => 'Ajuste de preço do package';

  @override
  String get adminTransportTypeDescriptionLabel => 'Descrição';

  @override
  String get adminTripPackagesOpsTab => 'Operação';

  @override
  String get adminTripPackagesCatalogTab => 'Catálogo';

  @override
  String get adminTripPackagesOpsEmpty => 'Sem reservas na fila de operação.';

  @override
  String get adminTripPackagesCatalogHeading => 'Catálogo de packages';

  @override
  String get adminTripPackagesCatalogSubtitle =>
      'Gerir produtos comerciais com destino fixo, preço fixo e tipos de transporte permitidos.';

  @override
  String get adminPackageCreateTitle => 'Criar package';

  @override
  String get adminPackageEditTitle => 'Editar package';

  @override
  String get adminPackageCreateAction => 'Criar package';

  @override
  String get adminPackageEditAction => 'Editar package';

  @override
  String get adminPackageCreateSuccess => 'Package guardado';

  @override
  String get adminPackageNameLabel => 'Nome do package';

  @override
  String get adminPackageNameMin =>
      'Introduza um nome com pelo menos 3 caracteres.';

  @override
  String get adminPackageDestinationLabel => 'Destino fixo';

  @override
  String get adminPackageDescriptionLabel => 'Descrição';

  @override
  String get adminPackageDescriptionMin =>
      'Introduza uma descrição com pelo menos 10 caracteres.';

  @override
  String get adminPackagePriceLabel => 'Preço fixo (EUR)';

  @override
  String get adminPackagePriceInvalid => 'Introduza um preço válido.';

  @override
  String get adminPackageTransportRequired =>
      'Selecione pelo menos um tipo de transporte.';

  @override
  String get adminPackageSalesActive => 'Vendas ativas';

  @override
  String get adminPackageSalesActiveHint =>
      'Quando desativado, o package deixa de aparecer para novas compras.';

  @override
  String get adminPackageAllowedTransport => 'Tipos de transporte permitidos';

  @override
  String get adminSupportReplyTitle => 'Responder ao pedido';

  @override
  String get adminSupportReplyLabel => 'Mensagem';

  @override
  String get adminSupportReplyHint => 'Escreva a sua resposta ao cliente...';

  @override
  String adminSupportRequestedAt(String date) {
    return 'pedido em $date';
  }

  @override
  String get adminSupportReplyAction => 'Responder';

  @override
  String get adminSupportReplyRequired => 'Introduza uma mensagem.';

  @override
  String get adminSupportReplySuccess => 'Resposta enviada';

  @override
  String get adminSupportResolveAction => 'Marcar como resolvido';

  @override
  String get adminSupportResolveSuccess => 'Pedido resolvido';

  @override
  String get adminReportsTabOverview => 'Panorama operacional';

  @override
  String get adminReportsTabClient => 'Extrato do cliente';

  @override
  String get adminReportsTabDriver => 'Extrato do motorista';

  @override
  String get adminReportsTabComingSoon =>
      'Relatórios de viagens e movimentos de saldo estarão disponíveis em breve.';

  @override
  String get adminCurrencyTitle => 'Definições de moeda';

  @override
  String get adminCurrencyDesc => 'Taxas FX usadas para CVE, EUR e USD.';

  @override
  String get adminCurrencyHeading => 'Definições de moeda';

  @override
  String get adminCurrencySubtitle =>
      'Definir taxas de câmbio para a visualização em EUR, CVE e USD.';

  @override
  String get adminCurrencyCveToEur => 'CVE para EUR';

  @override
  String get adminCurrencyCveToUsd => 'CVE para USD';

  @override
  String get adminCurrencySaveSuccess => 'Definições de moeda guardadas';

  @override
  String get adminCurrencyInvalidRate =>
      'Introduza taxas de câmbio válidas superiores a zero';

  @override
  String get adminReportsDesc => 'Analisar métricas de operação e desempenho.';

  @override
  String get adminAuditTitle => 'Auditoria';

  @override
  String get adminAuditDesc => 'Ver quem ajustou saldos e tarifas.';

  @override
  String get adminAuditEmpty => 'Sem entradas de auditoria';

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
  String premiumHomeFromPrice(String price) {
    return 'Desde $price';
  }

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
  String get rentalLoadError =>
      'Não foi possível carregar veículos. Tente novamente.';

  @override
  String get rentalNoVehicles => 'Nenhum veículo disponível de momento.';

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
  String get tripHistoryStatusInProgress => 'Em curso';

  @override
  String get tripHistoryStatusScheduled => 'Agendada';

  @override
  String get tripHistoryEmpty => 'Ainda sem viagens';

  @override
  String get tripHistoryEmptyBody =>
      'As suas viagens aparecem aqui depois de pedir uma corrida.';

  @override
  String get tripHistoryLoadError =>
      'Não foi possível carregar viagens. Tente novamente.';

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
  String get driverSearchSubtitleFallback =>
      'A ligar aos veículos disponíveis mais próximos.';

  @override
  String driverSearchSubtitleArea(String area) {
    return 'A ligar aos veículos mais próximos perto de $area.';
  }

  @override
  String get driverSearchOrigin => 'ORIGEM';

  @override
  String get driverSearchEstimate => 'ESTIMATIVA';

  @override
  String get driverSearchWaitEstimate => '3–5 min';

  @override
  String driverSearchWaitMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get driverSearchCancelTrip => 'Cancelar Viagem';

  @override
  String get driverSearchCancelling => 'A cancelar...';

  @override
  String get driverSearchCancelFailed => 'Não foi possível cancelar a viagem.';

  @override
  String get driverSearchNoDrivers =>
      'Nenhum motorista disponível. Tente novamente.';

  @override
  String get driverSearchNoDriversNearby =>
      'Nenhum motorista perto do local de recolha. O motorista tem de estar disponível num raio de 100 km.';

  @override
  String get driverSearchNoDriversMissingVehicle =>
      'Motoristas próximos não têm viatura atribuída. Peça ao admin para atribuir uma viatura.';

  @override
  String get homePickupOutsideServiceArea =>
      'A recolha está fora da área de serviço. Use uma localização em Cabo Verde (ou Portugal em testes dev).';

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
  String get tripDestinationSuggestionTitle => 'Belém e Monumentos';

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
  String get tripConfirmSessionInvalid =>
      'Sessão inválida. Inicie sessão novamente.';

  @override
  String get tripConfirmRouteLoading => 'Aguarde o carregamento do percurso.';

  @override
  String get tripConfirmCreateFailed =>
      'Não foi possível criar a viagem. Tente novamente.';

  @override
  String get tripConfirmPermissionDenied =>
      'Não foi possível criar a viagem. Verifique o seu saldo e sessão, ou contacte o suporte.';

  @override
  String get tripConfirmDestinationFailed =>
      'Não foi possível localizar o destino. Verifique o endereço ou escolha uma sugestão da lista.';

  @override
  String get tripConfirmDirectionsFailed =>
      'Não foi possível calcular o percurso. Verifique a ligação e as definições da API Google Maps.';

  @override
  String get tripConfirmTransportTypesFailed =>
      'Tipos de transporte indisponíveis. Tente novamente dentro de momentos.';

  @override
  String get tripConfirmPriceUnavailable =>
      'Preço da viagem indisponível. Aguarde o carregamento do percurso ou escolha outro destino.';

  @override
  String get tripConfirmLimitExceeded =>
      'Saldo insuficiente para pedir esta viagem. Carregue a conta e tente novamente.';

  @override
  String get tripConfirmDirectionsApproximate =>
      'Percurso exacto indisponível. Distância e preço são aproximados.';

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
  String driverEarningsVsYesterday(String change) {
    return '$change vs. ontem';
  }

  @override
  String get driverNoRecentTrips => 'Ainda sem viagens concluídas';

  @override
  String get driverNoVehicleAssigned => 'Nenhum veículo atribuído';

  @override
  String get driverTripsLabel => 'Viagens';

  @override
  String get driverDistanceLabel => 'Distância';

  @override
  String get driverRecentTrips => 'Últimas Viagens';

  @override
  String get driverLocationCity => 'Praia, CV';

  @override
  String get driverLocationLoading => 'A localizar...';

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

  @override
  String get adminTariffNoTransportTypes =>
      'Configure primeiro os tipos de transporte.';

  @override
  String get adminTariffInvalidAmounts => 'Introduza valores válidos.';

  @override
  String adminTariffInvalidBaseFare(String typeName) {
    return 'Tarifa base inválida para $typeName.';
  }

  @override
  String get rentalAc => 'AC';

  @override
  String get rentalElectric => 'Elétrico';

  @override
  String get rentalAllTypes => 'Todos os tipos';

  @override
  String get rentalCarTypeSedan => 'Sedan';

  @override
  String get rentalCarTypeSuv => 'SUV';

  @override
  String get rentalCarTypeExecutive => 'Executivo';

  @override
  String get rentalCarTypeElectric => 'Elétrico';

  @override
  String get rentalTransmissionAll => 'Todas';

  @override
  String get rentalTransmissionAutomatic => 'Automático';

  @override
  String get rentalTransmissionManual => 'Manual';

  @override
  String get rentalAnyPrice => 'Qualquer preço';

  @override
  String rentalPriceUpTo(String price) {
    return 'Até $price';
  }

  @override
  String driverEnRouteEtaAt(String time) {
    return 'ETA • $time';
  }

  @override
  String get rentalWeekdaySun => 'DOM';

  @override
  String get rentalWeekdayMon => 'SEG';

  @override
  String get rentalWeekdayTue => 'TER';

  @override
  String get rentalWeekdayWed => 'QUA';

  @override
  String get rentalWeekdayThu => 'QUI';

  @override
  String get rentalWeekdayFri => 'SEX';

  @override
  String get rentalWeekdaySat => 'SÁB';

  @override
  String get rentalDemoPickupLocation => 'Aeroporto de Lisboa, PT';

  @override
  String get rentalDriverAgeYoung => '18 - 25 anos';

  @override
  String get rentalDriverAgeStandard => '26 - 65 anos';

  @override
  String get rentalDriverAgeSenior => '65+ anos';

  @override
  String get rentalDemoSportPremium => 'DESPORTIVO PREMIUM';

  @override
  String get rentalDemoVehicleName => 'Porsche Taycan 4S';

  @override
  String get rentalInsuranceDescription =>
      'Proteção total contra danos próprios e assistência em viagem 24/7 sem custos adicionais.';

  @override
  String get rentalInsuranceFranchiseWaiver => 'Isenção de Franquia';

  @override
  String get rentalInsuranceCdw => 'Danos de Colisão (CDW)';

  @override
  String get rentalFuelPolicyElectric =>
      'Política de Cheio/Cheio ou devolução com carga superior a 80% para veículos elétricos.';

  @override
  String rentalBookingRentalDays(int days) {
    return 'Aluguer ($days dias)';
  }

  @override
  String get rentalBookingPremiumInsurance => 'Seguro Premium';

  @override
  String get rentalBookingIncluded => 'Incluído';

  @override
  String get rentalBookingAirportFees => 'Taxas de aeroporto';

  @override
  String get rentalDemoAirportLocation => 'Aeroporto de Lisboa, LIS';

  @override
  String get rentalSpecPower => 'Potência';

  @override
  String get rentalSpecPowerValue => '530 cv';

  @override
  String get rentalSpecRange => 'Autonomia WLTP';

  @override
  String get rentalSpecRangeValue => '463 km';

  @override
  String get rentalSpecDrive => 'Tração';

  @override
  String get rentalSpecDriveValue => 'Integral (AWD)';

  @override
  String rentalVehicleSummary(String price, String seats, String transmission) {
    return '$price · $seats · $transmission';
  }

  @override
  String get eventDemoGenre => 'MÚSICA ELETRÓNICA';

  @override
  String get eventDemoTitle => 'Gala de Verão: Porto Sunset';

  @override
  String get eventDemoDescription =>
      'Prepare-se para a noite mais exclusiva do ano. A Gala de Verão no Porto combina o melhor da música eletrónica melódica com uma vista deslumbrante sobre o Rio Douro. O evento contará com serviço de catering premium, áreas lounge VIP e uma experiência audiovisual imersiva sem precedentes na cidade.';

  @override
  String get eventDemoVenue => 'Alfândega do Porto';

  @override
  String get eventPaymentMbway => 'MBWAY';

  @override
  String get discoverMapRestaurantLabel => 'Restaurante Maré';

  @override
  String get discoverMapBeachLabel => 'Praia Secreta';

  @override
  String get reservationDemoVehicleName => 'Tesla Model 3 Performance';

  @override
  String reservationDemoVehicleSpecs(
    String powertrain,
    String seats,
    String transmission,
  ) {
    return '$powertrain • $seats • $transmission';
  }

  @override
  String get reservationDemoAirport => 'Aeroporto de Lisboa (LIS)';

  @override
  String get reservationDemoPickupDateTime => '15 Out, 2023 às 10:00';

  @override
  String get reservationDemoReturnDateTime => '20 Out, 2023 às 18:00';

  @override
  String reservationRentalDaysLine(int days) {
    return 'Aluguer ($days dias)';
  }

  @override
  String get reservationInsuranceLine => 'Seguro total';

  @override
  String get reservationDefaultVehicle => 'Veículo';

  @override
  String get reservationDefaultCity => 'Lisboa';
}

/// The translations for Portuguese, as used in Portugal (`pt_PT`).
class AppLocalizationsPtPt extends AppLocalizationsPt {
  AppLocalizationsPtPt() : super('pt_PT');

  @override
  String get appNameLocalTransport => 'Local Transport';

  @override
  String get signIn => 'Entrar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

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
  String get navBalance => 'Saldo';

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
  String get authErrorEmailInUse => 'Este e-mail já está registado.';

  @override
  String get authErrorWeakPassword =>
      'Palavra-passe demasiado fraca. Use pelo menos 6 caracteres.';

  @override
  String get authErrorRegistrationFailed =>
      'Não foi possível criar a conta. Tente novamente.';

  @override
  String get registerSubtitle =>
      'Crie a sua conta como cliente ou motorista profissional.';

  @override
  String get registerNameLabel => 'Nome completo';

  @override
  String get registerNameHint => 'ex. João Silva';

  @override
  String get registerPhoneLabel => 'Telemóvel (opcional)';

  @override
  String get registerPhoneHint => 'ex. +351910000000';

  @override
  String get registerConfirmPasswordLabel => 'Confirmar palavra-passe';

  @override
  String get registerFillRequiredFields =>
      'Preencha nome, e-mail e palavra-passe.';

  @override
  String get registerPasswordTooShort =>
      'A palavra-passe deve ter pelo menos 6 caracteres.';

  @override
  String get registerPasswordMismatch => 'As palavras-passe não coincidem.';

  @override
  String get registerAlreadyHaveAccount => 'Já tem conta? ';

  @override
  String get registerSignInNow => 'Iniciar sessão';

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
  String get profileChangePhoto => 'Alterar foto de perfil';

  @override
  String get profilePhotoFromGallery => 'Escolher da galeria';

  @override
  String get profilePhotoTakePhoto => 'Tirar foto';

  @override
  String get profilePhotoUpdated => 'Foto de perfil actualizada';

  @override
  String get profilePhotoUpdateFailed =>
      'Não foi possível actualizar a foto. Tente novamente.';

  @override
  String get profilePhotoPermissionDenied =>
      'Sem permissão para enviar a foto. Contacte o suporte se o problema persistir.';

  @override
  String get profilePhotoUploading => 'A enviar foto...';

  @override
  String get profileEditName => 'Editar nome';

  @override
  String get profileNameHint => 'O seu nome';

  @override
  String get profileNameUpdated => 'Nome atualizado';

  @override
  String get profileNameUpdateFailed =>
      'Não foi possível atualizar o nome. Tente novamente.';

  @override
  String get profileNamePermissionDenied =>
      'Não foi possível actualizar o nome. Verifique a sua sessão ou contacte o suporte.';

  @override
  String get profileNameEmpty => 'Introduza o seu nome.';

  @override
  String get homeAvailableBalance => 'Saldo Disponível';

  @override
  String get homeTopUp => 'Ver saldo';

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
  String get clientBalanceTitle => 'Saldo';

  @override
  String get clientBalanceSubtitle =>
      'Saldo da sua conta actualizado em tempo real.';

  @override
  String get clientBalanceDebtLimit => 'Limite de dívida';

  @override
  String get clientBalanceLastUpdated => 'Última atualização';

  @override
  String get clientBalanceHistoryTitle => 'Ajustes recentes';

  @override
  String get clientBalanceHistoryEmpty => 'Ainda sem ajustes';

  @override
  String get clientBalanceHistoryEmptyBody =>
      'Alterações de saldo feitas pelo admin aparecem aqui.';

  @override
  String get clientBalanceAdjustmentDefault => 'Ajuste de saldo';

  @override
  String get clientBalanceDebtWarningTitle => 'Limite de dívida atingido';

  @override
  String get clientBalanceDebtWarningBody =>
      'Contacte o suporte para carregar o saldo e continuar a pedir viagens.';

  @override
  String get clientBalanceTopUpTitle => 'Como carregar';

  @override
  String get clientBalanceTopUpBody =>
      'O carregamento do saldo é gerido pelo suporte. Ligue para pedir crédito — aparecerá aqui após aprovação do administrador.';

  @override
  String get clientBalanceContactSupport => 'Contactar suporte';

  @override
  String get clientBalanceSupportUnavailable =>
      'Telefone de suporte indisponível. Contacte a equipa de apoio.';

  @override
  String get clientBalanceSupportCallFailed =>
      'Não foi possível abrir o marcador telefónico neste dispositivo.';

  @override
  String get tripConfirmLimitExceededCallSupport => 'Ligar para suporte';

  @override
  String get clientBalanceUnavailable => 'Saldo indisponível';

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
  String get homeLocationLoading => 'A obter a sua localização...';

  @override
  String get homeLocationUnavailable => 'Não foi possível obter a localização';

  @override
  String get homeRefreshLocation => 'Atualizar localização';

  @override
  String get homeSelectLocationOnMap => 'Selecionar no mapa';

  @override
  String get homeSelectLocationOnMapHint =>
      'Mova o mapa ou toque no botão de localização para usar a posição atual.';

  @override
  String get homeUseMapLocation => 'Usar esta localização';

  @override
  String get homeLocationPermissionTitle => 'Permitir localização';

  @override
  String get homeLocationPermissionMessage =>
      'O Local Transport precisa da sua localização para definir automaticamente o ponto de recolha.';

  @override
  String get homeLocationPermissionAllow => 'Permitir';

  @override
  String get homeLocationPermissionDeny => 'Agora não';

  @override
  String get homeLocationPermissionSettingsMessage =>
      'A permissão de localização está desativada. Abra as definições para permitir o acesso.';

  @override
  String get homeLocationOpenSettings => 'Abrir definições';

  @override
  String get homeLocationServicesDisabled =>
      'Ative os serviços de localização no dispositivo para usar o seu endereço atual.';

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
  String get premiumMobility => 'Local Transport';

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
  String get adminAppBarTitle => 'Local Transport';

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
  String adminPendingDebtorsCount(int count) {
    return '$count faturas em atraso';
  }

  @override
  String adminActiveTripsTrendDynamic(String change) {
    return '$change vs. ontem';
  }

  @override
  String get adminNoFleetVehicles => 'Ainda sem viaturas na frota';

  @override
  String get adminNoReportActivities => 'Ainda sem viagens concluídas';

  @override
  String adminBaseRateLive(String multiplier) {
    return 'Dinâmica: Ativa ($multiplier)';
  }

  @override
  String get adminMonthlyReportsTitle => 'Relatórios Mensais';

  @override
  String get adminMonthlyReportsSubtitle => 'Performance de Outubro';

  @override
  String get adminActivityMapTitle => 'Mapa de Atividade';

  @override
  String get adminActivityMapWaiting =>
      'À espera de viagens e localizações em tempo real';

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
  String get adminHubTitle => 'Área de administração';

  @override
  String get adminHubHeading => 'Área de administração';

  @override
  String get adminHubSubtitle => 'Gerir operações, frota, tarifas e suporte.';

  @override
  String get adminUsersTitle => 'Utilizadores';

  @override
  String get adminUsersDesc => 'Gestão de contas e permissões.';

  @override
  String get adminUsersHeading => 'Gestão de contas e permissões';

  @override
  String get adminUsersSubtitle => 'Gerir perfis, funções e acessos da equipa.';

  @override
  String get adminUsersSearchHint =>
      'Pesquisar por nome, email, telefone ou ID';

  @override
  String get adminUsersEmpty => 'Nenhum utilizador encontrado';

  @override
  String get adminUsersCreateTitle => 'Adicionar utilizador';

  @override
  String get adminUsersCreateSubtitle =>
      'Criar conta de cliente, motorista, gestor ou admin.';

  @override
  String get adminUsersCreateAction => 'Criar utilizador';

  @override
  String get adminUsersCreateSuccess => 'Utilizador criado com sucesso';

  @override
  String get adminUsersCreateFailed => 'Não foi possível criar o utilizador';

  @override
  String get adminUsersRoleLabel => 'Função';

  @override
  String get adminUsersAddTooltip => 'Adicionar utilizador';

  @override
  String get adminStatusActive => 'Ativo';

  @override
  String get adminStatusInactive => 'Inativo';

  @override
  String get adminStatusOpen => 'Aberto';

  @override
  String get adminStatusResolved => 'Resolvido';

  @override
  String get adminStatusConfigured => 'Configurado';

  @override
  String get adminManagerPermissionsTitle => 'Permissões de gestor';

  @override
  String get adminManagerPermissionsDesc =>
      'Configurar permissões operacionais por gestor.';

  @override
  String get adminManagerPermissionsHeading =>
      'Configuração de permissões operacionais';

  @override
  String get adminManagerPermissionsSubtitle =>
      'Configure, por gestor, os módulos e ações permitidas.';

  @override
  String get adminManagersEmpty => 'Nenhum gestor encontrado';

  @override
  String get adminStatusUnconfigured => 'Não configurado';

  @override
  String get adminManagerPermissionsSaveAction => 'Guardar permissões';

  @override
  String get adminManagerPermissionsSaveSuccess =>
      'Permissões do gestor guardadas';

  @override
  String get adminManagerPermissionsSaveError =>
      'Não foi possível guardar as permissões';

  @override
  String get managerPermissionViewTrips => 'Ver viagens';

  @override
  String get managerPermissionViewReports => 'Ver relatórios';

  @override
  String get managerPermissionViewAudit => 'Ver auditoria';

  @override
  String get managerPermissionViewDrivers => 'Ver motoristas';

  @override
  String get managerPermissionViewClients => 'Ver clientes';

  @override
  String get managerPermissionViewSupportRequests => 'Ver pedidos de suporte';

  @override
  String get managerPermissionManageClientChats =>
      'Gerir conversas de clientes';

  @override
  String get managerPermissionCancelTripBySupport =>
      'Cancelar viagem por suporte';

  @override
  String get managerPermissionUpdateTripSupport =>
      'Atualizar suporte da viagem';

  @override
  String get managerPermissionResolvePasswordHelpRequest =>
      'Resolver pedidos de ajuda de password';

  @override
  String get managerPermissionManageEvents => 'Gerir eventos';

  @override
  String get managerPermissionAssignVehicleToDriver => 'Atribuir veículo';

  @override
  String get managerPermissionEditDriverStatus => 'Editar estado do motorista';

  @override
  String get managerPermissionManageTariffs => 'Gerir tarifas';

  @override
  String get managerPermissionManageTripPackages => 'Gerir pacotes de viagem';

  @override
  String get adminSupportRequestsTitle => 'Pedidos de suporte';

  @override
  String get adminSupportRequestsDesc =>
      'Caixa de entrada de suporte e ajuda de password.';

  @override
  String get adminSupportEmpty => 'Sem pedidos de suporte';

  @override
  String get adminIncidentsTitle => 'Incidentes operacionais';

  @override
  String get adminIncidentsDesc => 'Incidentes de monitorização e aprovações.';

  @override
  String get adminIncidentsEmpty => 'Sem incidentes operacionais';

  @override
  String get adminIncidentDetailTitle => 'Detalhes do incidente';

  @override
  String get adminIncidentCurrentState => 'Estado atual';

  @override
  String get adminIncidentTrip => 'Viagem';

  @override
  String get adminIncidentStarted => 'Iniciado';

  @override
  String get adminIncidentRouteSummary => 'Resumo da rota';

  @override
  String get adminIncidentKmSummary => 'Resumo de km';

  @override
  String get adminMonitoringTitle => 'Definições de monitorização';

  @override
  String get adminMonitoringDesc => 'Limites para monitorização operacional.';

  @override
  String get adminMonitoringHeading => 'Monitorização operacional';

  @override
  String get adminMonitoringSubtitle =>
      'Rever limites de monitorização operacional.';

  @override
  String get adminMonitoringConfig => 'Configuração atual';

  @override
  String get adminMonitoringLoading =>
      'A carregar configuração de monitorização...';

  @override
  String get adminMonitoringEnabled => 'Monitorização ativa';

  @override
  String get adminMonitoringEnabledHint =>
      'A monitorização operacional só corre quando está ativa.';

  @override
  String get adminMonitoringBaseGeofence => 'Geofence base';

  @override
  String get adminMonitoringServiceGeofences => 'Geofences de serviço';

  @override
  String adminMonitoringServiceGeofenceCount(int count) {
    return '$count configuradas';
  }

  @override
  String get adminMonitoringLastUpdated => 'Última atualização';

  @override
  String get adminMonitoringSaveSuccess =>
      'Configuração de monitorização guardada';

  @override
  String get adminReservationsTitle => 'Reservas operacionais';

  @override
  String get adminReservationsDesc => 'Agendar viagens futuras para clientes.';

  @override
  String get adminReservationsEmpty => 'Sem reservas';

  @override
  String get adminSupportSettingsTitle => 'Contacto de suporte';

  @override
  String get adminSupportSettingsDesc =>
      'Telefone oficial para recuperação de password.';

  @override
  String get adminSupportSettingsHeading => 'Contacto de suporte';

  @override
  String get adminSupportSettingsSubtitle =>
      'Definir o número oficial de contacto.';

  @override
  String get adminSupportPhoneLabel => 'Telefone de suporte';

  @override
  String get adminEventsTitle => 'Eventos e alertas';

  @override
  String get adminEventsDesc => 'Enviar lembretes e avisos aos motoristas.';

  @override
  String get adminEventsEmpty => 'Sem eventos agendados';

  @override
  String get adminFleetTitle => 'Frota';

  @override
  String get adminFleetDesc => 'Acompanhar viaturas, estado e disponibilidade.';

  @override
  String get adminFleetNoDriver => 'Sem motorista atribuído';

  @override
  String get adminFleetDriver => 'Motorista';

  @override
  String get adminFleetAssignDriverTitle => 'Atribuir motorista';

  @override
  String get adminFleetAssignDriverDesc =>
      'Selecione um motorista para esta viatura.';

  @override
  String get adminFleetAssignDriverEmpty =>
      'Nenhum motorista ativo encontrado.';

  @override
  String get adminFleetAssignDriverSuccess =>
      'Motorista atribuído com sucesso.';

  @override
  String get adminTransportTypesTitle => 'Tipos de transporte';

  @override
  String get adminTransportTypesDesc => 'Criar e gerir tipos disponíveis.';

  @override
  String get adminTransportTypesEmpty => 'Sem tipos de transporte';

  @override
  String get adminTripPackagesTitle => 'Pacotes de viagem';

  @override
  String get adminTripPackagesDesc =>
      'Pacotes pré-pagos com destino e preço fixos.';

  @override
  String get adminTripPackagesEmpty => 'Sem pacotes de viagem';

  @override
  String get adminTariffsTitle => 'Tarifas';

  @override
  String get adminTariffsDesc => 'Definir preços, regras e ajustes sazonais.';

  @override
  String get adminTariffAdminDefault => 'Tarifa admin default';

  @override
  String get adminTariffPublicDefault => 'Tarifa public default';

  @override
  String get adminBalancesTitle => 'Vendas';

  @override
  String get adminBalancesDesc =>
      'Controlar saldos, limites e operações pendentes.';

  @override
  String get adminBalancesEmpty => 'Sem saldos';

  @override
  String get adminBalancesDebt => 'Dívida';

  @override
  String get adminBalancesCredit => 'Crédito';

  @override
  String get adminBalanceCurrent => 'Saldo atual';

  @override
  String get adminBalanceDebtLimit => 'Limite de dívida';

  @override
  String get adminBalanceAdjustAction => 'Ajustar saldo';

  @override
  String get adminBalanceAdjustTitle => 'Ajuste manual de saldo';

  @override
  String get adminBalanceCredit => 'Crédito';

  @override
  String get adminBalanceDebt => 'Débito';

  @override
  String get adminBalanceAmountLabel => 'Valor (EUR)';

  @override
  String get adminBalanceAmountRequired => 'Introduza um valor válido.';

  @override
  String get adminBalanceReasonLabel => 'Motivo';

  @override
  String get adminBalanceReasonRequired => 'Introduza um motivo.';

  @override
  String get adminBalanceConfirm => 'Confirmar ajuste';

  @override
  String get adminBalanceAdjustSuccess => 'Saldo atualizado';

  @override
  String get adminVehicleCreateTitle => 'Nova viatura';

  @override
  String get adminVehicleEditTitle => 'Editar viatura';

  @override
  String get adminVehicleCreateAction => 'Criar viatura';

  @override
  String get adminVehicleCreateSuccess => 'Viatura criada';

  @override
  String get adminVehicleAddPhoto => 'Adicionar foto';

  @override
  String get adminVehiclePlateLabel => 'Matrícula';

  @override
  String get adminVehicleModelLabel => 'Modelo';

  @override
  String get adminVehicleCapacityLabel => 'Capacidade';

  @override
  String get adminVehicleTransportTypeLabel => 'Tipo de transporte predefinido';

  @override
  String get adminVehicleNoPreference => 'Sem preferência';

  @override
  String get adminVehicleNotesLabel => 'Notas';

  @override
  String get adminVehicleActiveLabel => 'Viatura ativa';

  @override
  String get adminVehicleRequiredFields => 'Preencha matrícula e modelo.';

  @override
  String get adminTransportTypeCreateTitle => 'Novo tipo de transporte';

  @override
  String get adminTransportTypeEditTitle => 'Editar tipo de transporte';

  @override
  String get adminTransportTypeCreateAction => 'Criar tipo';

  @override
  String get adminTransportTypeCreateSuccess => 'Tipo de transporte criado';

  @override
  String get adminTransportTypeNameLabel => 'Nome';

  @override
  String get adminTransportTypeNameRequired => 'Introduza um nome.';

  @override
  String get adminTransportTypeBaseFareLabel => 'Tarifa base inicial';

  @override
  String get adminTransportTypeMultiplierLabel => 'Ajuste de preço do package';

  @override
  String get adminTransportTypeDescriptionLabel => 'Descrição';

  @override
  String get adminTripPackagesOpsTab => 'Operação';

  @override
  String get adminTripPackagesCatalogTab => 'Catálogo';

  @override
  String get adminTripPackagesOpsEmpty => 'Sem reservas na fila de operação.';

  @override
  String get adminTripPackagesCatalogHeading => 'Catálogo de packages';

  @override
  String get adminTripPackagesCatalogSubtitle =>
      'Gerir produtos comerciais com destino fixo, preço fixo e tipos de transporte permitidos.';

  @override
  String get adminPackageCreateTitle => 'Criar package';

  @override
  String get adminPackageEditTitle => 'Editar package';

  @override
  String get adminPackageCreateAction => 'Criar package';

  @override
  String get adminPackageEditAction => 'Editar package';

  @override
  String get adminPackageCreateSuccess => 'Package guardado';

  @override
  String get adminPackageNameLabel => 'Nome do package';

  @override
  String get adminPackageNameMin =>
      'Introduza um nome com pelo menos 3 caracteres.';

  @override
  String get adminPackageDestinationLabel => 'Destino fixo';

  @override
  String get adminPackageDescriptionLabel => 'Descrição';

  @override
  String get adminPackageDescriptionMin =>
      'Introduza uma descrição com pelo menos 10 caracteres.';

  @override
  String get adminPackagePriceLabel => 'Preço fixo (EUR)';

  @override
  String get adminPackagePriceInvalid => 'Introduza um preço válido.';

  @override
  String get adminPackageTransportRequired =>
      'Selecione pelo menos um tipo de transporte.';

  @override
  String get adminPackageSalesActive => 'Vendas ativas';

  @override
  String get adminPackageSalesActiveHint =>
      'Quando desativado, o package deixa de aparecer para novas compras.';

  @override
  String get adminPackageAllowedTransport => 'Tipos de transporte permitidos';

  @override
  String get adminSupportReplyTitle => 'Responder ao pedido';

  @override
  String get adminSupportReplyLabel => 'Mensagem';

  @override
  String get adminSupportReplyHint => 'Escreva a sua resposta ao cliente...';

  @override
  String adminSupportRequestedAt(String date) {
    return 'pedido em $date';
  }

  @override
  String get adminSupportReplyAction => 'Responder';

  @override
  String get adminSupportReplyRequired => 'Introduza uma mensagem.';

  @override
  String get adminSupportReplySuccess => 'Resposta enviada';

  @override
  String get adminSupportResolveAction => 'Marcar como resolvido';

  @override
  String get adminSupportResolveSuccess => 'Pedido resolvido';

  @override
  String get adminReportsTabOverview => 'Panorama operacional';

  @override
  String get adminReportsTabClient => 'Extrato do cliente';

  @override
  String get adminReportsTabDriver => 'Extrato do motorista';

  @override
  String get adminReportsTabComingSoon =>
      'Relatórios de viagens e movimentos de saldo estarão disponíveis em breve.';

  @override
  String get adminCurrencyTitle => 'Definições de moeda';

  @override
  String get adminCurrencyDesc => 'Taxas FX usadas para CVE, EUR e USD.';

  @override
  String get adminCurrencyHeading => 'Definições de moeda';

  @override
  String get adminCurrencySubtitle =>
      'Definir taxas de câmbio para a visualização em EUR, CVE e USD.';

  @override
  String get adminCurrencyCveToEur => 'CVE para EUR';

  @override
  String get adminCurrencyCveToUsd => 'CVE para USD';

  @override
  String get adminCurrencySaveSuccess => 'Definições de moeda guardadas';

  @override
  String get adminCurrencyInvalidRate =>
      'Introduza taxas de câmbio válidas superiores a zero';

  @override
  String get adminReportsDesc => 'Analisar métricas de operação e desempenho.';

  @override
  String get adminAuditTitle => 'Auditoria';

  @override
  String get adminAuditDesc => 'Ver quem ajustou saldos e tarifas.';

  @override
  String get adminAuditEmpty => 'Sem entradas de auditoria';

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
  String premiumHomeFromPrice(String price) {
    return 'Desde $price';
  }

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
  String get rentalLoadError =>
      'Não foi possível carregar veículos. Tente novamente.';

  @override
  String get rentalNoVehicles => 'Nenhum veículo disponível de momento.';

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
  String get tripHistoryStatusInProgress => 'Em curso';

  @override
  String get tripHistoryStatusScheduled => 'Agendada';

  @override
  String get tripHistoryEmpty => 'Ainda sem viagens';

  @override
  String get tripHistoryEmptyBody =>
      'As suas viagens aparecem aqui depois de pedir uma corrida.';

  @override
  String get tripHistoryLoadError =>
      'Não foi possível carregar viagens. Tente novamente.';

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
  String get driverSearchSubtitleFallback =>
      'A ligar aos veículos disponíveis mais próximos.';

  @override
  String driverSearchSubtitleArea(String area) {
    return 'A ligar aos veículos mais próximos perto de $area.';
  }

  @override
  String get driverSearchOrigin => 'ORIGEM';

  @override
  String get driverSearchEstimate => 'ESTIMATIVA';

  @override
  String get driverSearchWaitEstimate => '3–5 min';

  @override
  String driverSearchWaitMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get driverSearchCancelTrip => 'Cancelar Viagem';

  @override
  String get driverSearchCancelling => 'A cancelar...';

  @override
  String get driverSearchCancelFailed => 'Não foi possível cancelar a viagem.';

  @override
  String get driverSearchNoDrivers =>
      'Nenhum motorista disponível. Tente novamente.';

  @override
  String get driverSearchNoDriversNearby =>
      'Nenhum motorista perto do local de recolha. O motorista tem de estar disponível num raio de 100 km.';

  @override
  String get driverSearchNoDriversMissingVehicle =>
      'Motoristas próximos não têm viatura atribuída. Peça ao admin para atribuir uma viatura.';

  @override
  String get homePickupOutsideServiceArea =>
      'A recolha está fora da área de serviço. Use uma localização em Cabo Verde (ou Portugal em testes dev).';

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
  String get tripDestinationSuggestionTitle => 'Belém e Monumentos';

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
  String get tripConfirmSessionInvalid =>
      'Sessão inválida. Inicie sessão novamente.';

  @override
  String get tripConfirmRouteLoading => 'Aguarde o carregamento do percurso.';

  @override
  String get tripConfirmCreateFailed =>
      'Não foi possível criar a viagem. Tente novamente.';

  @override
  String get tripConfirmPermissionDenied =>
      'Não foi possível criar a viagem. Verifique o seu saldo e sessão, ou contacte o suporte.';

  @override
  String get tripConfirmDestinationFailed =>
      'Não foi possível localizar o destino. Verifique o endereço ou escolha uma sugestão da lista.';

  @override
  String get tripConfirmDirectionsFailed =>
      'Não foi possível calcular o percurso. Verifique a ligação e as definições da API Google Maps.';

  @override
  String get tripConfirmTransportTypesFailed =>
      'Tipos de transporte indisponíveis. Tente novamente dentro de momentos.';

  @override
  String get tripConfirmPriceUnavailable =>
      'Preço da viagem indisponível. Aguarde o carregamento do percurso ou escolha outro destino.';

  @override
  String get tripConfirmLimitExceeded =>
      'Saldo insuficiente para pedir esta viagem. Carregue a conta e tente novamente.';

  @override
  String get tripConfirmDirectionsApproximate =>
      'Percurso exacto indisponível. Distância e preço são aproximados.';

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
  String driverEarningsVsYesterday(String change) {
    return '$change vs. ontem';
  }

  @override
  String get driverNoRecentTrips => 'Ainda sem viagens concluídas';

  @override
  String get driverNoVehicleAssigned => 'Nenhum veículo atribuído';

  @override
  String get driverTripsLabel => 'Viagens';

  @override
  String get driverDistanceLabel => 'Distância';

  @override
  String get driverRecentTrips => 'Últimas Viagens';

  @override
  String get driverLocationCity => 'Praia, CV';

  @override
  String get driverLocationLoading => 'A localizar...';

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

  @override
  String get adminTariffNoTransportTypes =>
      'Configure primeiro os tipos de transporte.';

  @override
  String get adminTariffInvalidAmounts => 'Introduza valores válidos.';

  @override
  String adminTariffInvalidBaseFare(String typeName) {
    return 'Tarifa base inválida para $typeName.';
  }

  @override
  String get rentalAc => 'AC';

  @override
  String get rentalElectric => 'Elétrico';

  @override
  String get rentalAllTypes => 'Todos os tipos';

  @override
  String get rentalCarTypeSedan => 'Sedan';

  @override
  String get rentalCarTypeSuv => 'SUV';

  @override
  String get rentalCarTypeExecutive => 'Executivo';

  @override
  String get rentalCarTypeElectric => 'Elétrico';

  @override
  String get rentalTransmissionAll => 'Todas';

  @override
  String get rentalTransmissionAutomatic => 'Automático';

  @override
  String get rentalTransmissionManual => 'Manual';

  @override
  String get rentalAnyPrice => 'Qualquer preço';

  @override
  String rentalPriceUpTo(String price) {
    return 'Até $price';
  }

  @override
  String driverEnRouteEtaAt(String time) {
    return 'ETA • $time';
  }

  @override
  String get rentalWeekdaySun => 'DOM';

  @override
  String get rentalWeekdayMon => 'SEG';

  @override
  String get rentalWeekdayTue => 'TER';

  @override
  String get rentalWeekdayWed => 'QUA';

  @override
  String get rentalWeekdayThu => 'QUI';

  @override
  String get rentalWeekdayFri => 'SEX';

  @override
  String get rentalWeekdaySat => 'SÁB';

  @override
  String get rentalDemoPickupLocation => 'Aeroporto de Lisboa, PT';

  @override
  String get rentalDriverAgeYoung => '18 - 25 anos';

  @override
  String get rentalDriverAgeStandard => '26 - 65 anos';

  @override
  String get rentalDriverAgeSenior => '65+ anos';

  @override
  String get rentalDemoSportPremium => 'DESPORTIVO PREMIUM';

  @override
  String get rentalDemoVehicleName => 'Porsche Taycan 4S';

  @override
  String get rentalInsuranceDescription =>
      'Proteção total contra danos próprios e assistência em viagem 24/7 sem custos adicionais.';

  @override
  String get rentalInsuranceFranchiseWaiver => 'Isenção de Franquia';

  @override
  String get rentalInsuranceCdw => 'Danos de Colisão (CDW)';

  @override
  String get rentalFuelPolicyElectric =>
      'Política de Cheio/Cheio ou devolução com carga superior a 80% para veículos elétricos.';

  @override
  String rentalBookingRentalDays(int days) {
    return 'Aluguer ($days dias)';
  }

  @override
  String get rentalBookingPremiumInsurance => 'Seguro Premium';

  @override
  String get rentalBookingIncluded => 'Incluído';

  @override
  String get rentalBookingAirportFees => 'Taxas de aeroporto';

  @override
  String get rentalDemoAirportLocation => 'Aeroporto de Lisboa, LIS';

  @override
  String get rentalSpecPower => 'Potência';

  @override
  String get rentalSpecPowerValue => '530 cv';

  @override
  String get rentalSpecRange => 'Autonomia WLTP';

  @override
  String get rentalSpecRangeValue => '463 km';

  @override
  String get rentalSpecDrive => 'Tração';

  @override
  String get rentalSpecDriveValue => 'Integral (AWD)';

  @override
  String rentalVehicleSummary(String price, String seats, String transmission) {
    return '$price · $seats · $transmission';
  }

  @override
  String get eventDemoGenre => 'MÚSICA ELETRÓNICA';

  @override
  String get eventDemoTitle => 'Gala de Verão: Porto Sunset';

  @override
  String get eventDemoDescription =>
      'Prepare-se para a noite mais exclusiva do ano. A Gala de Verão no Porto combina o melhor da música eletrónica melódica com uma vista deslumbrante sobre o Rio Douro. O evento contará com serviço de catering premium, áreas lounge VIP e uma experiência audiovisual imersiva sem precedentes na cidade.';

  @override
  String get eventDemoVenue => 'Alfândega do Porto';

  @override
  String get eventPaymentMbway => 'MBWAY';

  @override
  String get discoverMapRestaurantLabel => 'Restaurante Maré';

  @override
  String get discoverMapBeachLabel => 'Praia Secreta';

  @override
  String get reservationDemoVehicleName => 'Tesla Model 3 Performance';

  @override
  String reservationDemoVehicleSpecs(
    String powertrain,
    String seats,
    String transmission,
  ) {
    return '$powertrain • $seats • $transmission';
  }

  @override
  String get reservationDemoAirport => 'Aeroporto de Lisboa (LIS)';

  @override
  String get reservationDemoPickupDateTime => '15 Out, 2023 às 10:00';

  @override
  String get reservationDemoReturnDateTime => '20 Out, 2023 às 18:00';

  @override
  String reservationRentalDaysLine(int days) {
    return 'Aluguer ($days dias)';
  }

  @override
  String get reservationInsuranceLine => 'Seguro total';

  @override
  String get reservationDefaultVehicle => 'Veículo';

  @override
  String get reservationDefaultCity => 'Lisboa';
}
