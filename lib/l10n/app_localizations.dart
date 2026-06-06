import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appNameLocalTransport.
  ///
  /// In pt, this message translates to:
  /// **'Local Transport'**
  String get appNameLocalTransport;

  /// No description provided for @signIn.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get signIn;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @signOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get signOut;

  /// No description provided for @signOutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Terminar sessão'**
  String get signOutTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In pt, this message translates to:
  /// **'Tem a certeza de que pretende sair da sua conta?'**
  String get signOutConfirmMessage;

  /// No description provided for @signOutFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível terminar sessão. Tente novamente.'**
  String get signOutFailed;

  /// No description provided for @tryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tryAgain;

  /// No description provided for @featureComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'{feature} estará disponível em breve.'**
  String featureComingSoon(String feature);

  /// No description provided for @navHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get navHome;

  /// No description provided for @navTrips.
  ///
  /// In pt, this message translates to:
  /// **'Viagens'**
  String get navTrips;

  /// No description provided for @navReservations.
  ///
  /// In pt, this message translates to:
  /// **'Reservas'**
  String get navReservations;

  /// No description provided for @navProfile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Inicie sessão para gerir as suas viagens.'**
  String get loginSubtitle;

  /// No description provided for @loginSettingsTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Definições'**
  String get loginSettingsTooltip;

  /// No description provided for @loginEmailOrMobileLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail ou Telemóvel'**
  String get loginEmailOrMobileLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In pt, this message translates to:
  /// **'ex: joao@email.com'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Palavra-passe'**
  String get loginPasswordLabel;

  /// No description provided for @loginForgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueceu-se?'**
  String get loginForgotPassword;

  /// No description provided for @loginFillEmailPassword.
  ///
  /// In pt, this message translates to:
  /// **'Preencha o e-mail e a palavra-passe.'**
  String get loginFillEmailPassword;

  /// No description provided for @loginNoAccountPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não tem conta? '**
  String get loginNoAccountPrompt;

  /// No description provided for @loginRegisterNow.
  ///
  /// In pt, this message translates to:
  /// **'Registar agora'**
  String get loginRegisterNow;

  /// No description provided for @loginPrivacy.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade'**
  String get loginPrivacy;

  /// No description provided for @loginTermsOfUse.
  ///
  /// In pt, this message translates to:
  /// **'Termos de Uso'**
  String get loginTermsOfUse;

  /// No description provided for @loginSupport.
  ///
  /// In pt, this message translates to:
  /// **'Suporte'**
  String get loginSupport;

  /// No description provided for @loginRoleClient.
  ///
  /// In pt, this message translates to:
  /// **'Cliente'**
  String get loginRoleClient;

  /// No description provided for @loginRoleProfessional.
  ///
  /// In pt, this message translates to:
  /// **'Profissional'**
  String get loginRoleProfessional;

  /// No description provided for @secureConnectionE2E.
  ///
  /// In pt, this message translates to:
  /// **'Ligação segura e encriptada ponta-a-ponta.'**
  String get secureConnectionE2E;

  /// No description provided for @authErrorUnexpected.
  ///
  /// In pt, this message translates to:
  /// **'Ocorreu um erro inesperado. Tente novamente.'**
  String get authErrorUnexpected;

  /// No description provided for @authErrorProfileNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Perfil de utilizador não encontrado.'**
  String get authErrorProfileNotFound;

  /// No description provided for @authErrorAccountInactive.
  ///
  /// In pt, this message translates to:
  /// **'Esta conta está inactiva. Contacte o suporte.'**
  String get authErrorAccountInactive;

  /// No description provided for @authErrorRoleMismatch.
  ///
  /// In pt, this message translates to:
  /// **'Perfil não corresponde ao tipo selecionado.'**
  String get authErrorRoleMismatch;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail inválido.'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In pt, this message translates to:
  /// **'Esta conta está desactivada.'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorWrongCredentials.
  ///
  /// In pt, this message translates to:
  /// **'E-mail ou palavra-passe incorrectos.'**
  String get authErrorWrongCredentials;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In pt, this message translates to:
  /// **'Demasiadas tentativas. Tente mais tarde.'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorSignInFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível iniciar sessão. Tente novamente.'**
  String get authErrorSignInFailed;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Definições'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Ajuste preferências e mantenha a aplicação pronta para si.'**
  String get settingsSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o idioma da aplicação. Pode repor o idioma do dispositivo a qualquer momento.'**
  String get settingsLanguageDescription;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In pt, this message translates to:
  /// **'Español'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsLanguagePortuguese.
  ///
  /// In pt, this message translates to:
  /// **'Português (Portugal)'**
  String get settingsLanguagePortuguese;

  /// No description provided for @settingsLanguageFollowingDevice.
  ///
  /// In pt, this message translates to:
  /// **'A seguir o idioma do dispositivo ({language}).'**
  String settingsLanguageFollowingDevice(String language);

  /// No description provided for @settingsLanguageManual.
  ///
  /// In pt, this message translates to:
  /// **'Idioma selecionado manualmente: {language}.'**
  String settingsLanguageManual(String language);

  /// No description provided for @settingsLanguageResetSnack.
  ///
  /// In pt, this message translates to:
  /// **'Idioma reposto para o do dispositivo.'**
  String get settingsLanguageResetSnack;

  /// No description provided for @settingsUseDeviceLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Repor idioma do dispositivo'**
  String get settingsUseDeviceLanguage;

  /// No description provided for @settingsDisplayCurrency.
  ///
  /// In pt, this message translates to:
  /// **'Moeda de visualização'**
  String get settingsDisplayCurrency;

  /// No description provided for @settingsDisplayCurrencyDescription.
  ///
  /// In pt, this message translates to:
  /// **'Escolha a moeda em que pretende ver os valores na aplicação.'**
  String get settingsDisplayCurrencyDescription;

  /// No description provided for @settingsCurrencyCve.
  ///
  /// In pt, this message translates to:
  /// **'Escudo cabo-verdiano (CVE)'**
  String get settingsCurrencyCve;

  /// No description provided for @settingsCurrencyEur.
  ///
  /// In pt, this message translates to:
  /// **'Euro (€)'**
  String get settingsCurrencyEur;

  /// No description provided for @settingsCurrencyUsd.
  ///
  /// In pt, this message translates to:
  /// **'Dólar americano (USD)'**
  String get settingsCurrencyUsd;

  /// No description provided for @settingsAccountSection.
  ///
  /// In pt, this message translates to:
  /// **'Conta'**
  String get settingsAccountSection;

  /// No description provided for @settingsChangePassword.
  ///
  /// In pt, this message translates to:
  /// **'Alterar palavra-passe'**
  String get settingsChangePassword;

  /// No description provided for @settingsSignOutAction.
  ///
  /// In pt, this message translates to:
  /// **'Terminar sessão'**
  String get settingsSignOutAction;

  /// No description provided for @settingsSignOutLoading.
  ///
  /// In pt, this message translates to:
  /// **'A terminar sessão...'**
  String get settingsSignOutLoading;

  /// No description provided for @settingsDeveloperSection.
  ///
  /// In pt, this message translates to:
  /// **'Ferramentas de desenvolvedor'**
  String get settingsDeveloperSection;

  /// No description provided for @settingsDriverLocationSimulationTitle.
  ///
  /// In pt, this message translates to:
  /// **'Simulação de localização (demo)'**
  String get settingsDriverLocationSimulationTitle;

  /// No description provided for @settingsDriverLocationSimulationDescription.
  ///
  /// In pt, this message translates to:
  /// **'Disponível apenas em builds de desenvolvimento. No dispositivo do motorista, publica movimento simulado em direção à recolha na viagem ativa, sem marcar chegada automaticamente.'**
  String get settingsDriverLocationSimulationDescription;

  /// No description provided for @settingsDriverLocationSimulationSwitchLabel.
  ///
  /// In pt, this message translates to:
  /// **'Simular movimento do motorista'**
  String get settingsDriverLocationSimulationSwitchLabel;

  /// No description provided for @settingsResetOnboarding.
  ///
  /// In pt, this message translates to:
  /// **'Repor onboarding'**
  String get settingsResetOnboarding;

  /// No description provided for @settingsResetDone.
  ///
  /// In pt, this message translates to:
  /// **'Onboarding reposto.'**
  String get settingsResetDone;

  /// No description provided for @settingsDeveloperDebugOnly.
  ///
  /// In pt, this message translates to:
  /// **'Secção visível apenas em builds de debug.'**
  String get settingsDeveloperDebugOnly;

  /// No description provided for @profileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @profileDefaultUserName.
  ///
  /// In pt, this message translates to:
  /// **'Utilizador'**
  String get profileDefaultUserName;

  /// No description provided for @profileSessionNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Sessão não encontrada. Inicie sessão novamente.'**
  String get profileSessionNotFound;

  /// No description provided for @profileLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o perfil. Tente novamente.'**
  String get profileLoadFailed;

  /// No description provided for @profileRoleClient.
  ///
  /// In pt, this message translates to:
  /// **'Utilizador'**
  String get profileRoleClient;

  /// No description provided for @profileRoleDriver.
  ///
  /// In pt, this message translates to:
  /// **'Motorista'**
  String get profileRoleDriver;

  /// No description provided for @profileRoleAdmin.
  ///
  /// In pt, this message translates to:
  /// **'Administrador'**
  String get profileRoleAdmin;

  /// No description provided for @profilePhone.
  ///
  /// In pt, this message translates to:
  /// **'Telefone'**
  String get profilePhone;

  /// No description provided for @profilePhoneNotSet.
  ///
  /// In pt, this message translates to:
  /// **'Não definido'**
  String get profilePhoneNotSet;

  /// No description provided for @profileAccountType.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de conta'**
  String get profileAccountType;

  /// No description provided for @profileStatus.
  ///
  /// In pt, this message translates to:
  /// **'Estado'**
  String get profileStatus;

  /// No description provided for @profileStatusActive.
  ///
  /// In pt, this message translates to:
  /// **'Activa'**
  String get profileStatusActive;

  /// No description provided for @profileStatusInactive.
  ///
  /// In pt, this message translates to:
  /// **'Inactiva'**
  String get profileStatusInactive;

  /// No description provided for @profileMenuSettings.
  ///
  /// In pt, this message translates to:
  /// **'Definições'**
  String get profileMenuSettings;

  /// No description provided for @profileMenuPaymentMethods.
  ///
  /// In pt, this message translates to:
  /// **'Métodos de pagamento'**
  String get profileMenuPaymentMethods;

  /// No description provided for @profileMenuHelpCenter.
  ///
  /// In pt, this message translates to:
  /// **'Centro de ajuda'**
  String get profileMenuHelpCenter;

  /// No description provided for @profileMenuPrivacySecurity.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade e segurança'**
  String get profileMenuPrivacySecurity;

  /// No description provided for @profileSessionSection.
  ///
  /// In pt, this message translates to:
  /// **'Sessão'**
  String get profileSessionSection;

  /// No description provided for @profileGoToLogin.
  ///
  /// In pt, this message translates to:
  /// **'Ir para o login'**
  String get profileGoToLogin;

  /// No description provided for @homeAvailableBalance.
  ///
  /// In pt, this message translates to:
  /// **'Saldo Disponível'**
  String get homeAvailableBalance;

  /// No description provided for @homeTopUp.
  ///
  /// In pt, this message translates to:
  /// **'Carregar'**
  String get homeTopUp;

  /// No description provided for @homeActionRequest.
  ///
  /// In pt, this message translates to:
  /// **'Pedir'**
  String get homeActionRequest;

  /// No description provided for @homeActionBook.
  ///
  /// In pt, this message translates to:
  /// **'Reservar'**
  String get homeActionBook;

  /// No description provided for @homeActionRent.
  ///
  /// In pt, this message translates to:
  /// **'Alugar'**
  String get homeActionRent;

  /// No description provided for @homeActionHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get homeActionHistory;

  /// No description provided for @homeActionBalance.
  ///
  /// In pt, this message translates to:
  /// **'Saldo'**
  String get homeActionBalance;

  /// No description provided for @homeWhereToday.
  ///
  /// In pt, this message translates to:
  /// **'Para onde vamos hoje?'**
  String get homeWhereToday;

  /// No description provided for @homeCurrentLocation.
  ///
  /// In pt, this message translates to:
  /// **'Localização Atual'**
  String get homeCurrentLocation;

  /// No description provided for @homeDestination.
  ///
  /// In pt, this message translates to:
  /// **'Destino'**
  String get homeDestination;

  /// No description provided for @homeDestinationHint.
  ///
  /// In pt, this message translates to:
  /// **'Para onde deseja ir?'**
  String get homeDestinationHint;

  /// No description provided for @homeConfirmRoute.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar Trajeto'**
  String get homeConfirmRoute;

  /// No description provided for @reservationsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Reservas'**
  String get reservationsTitle;

  /// No description provided for @reservationsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Gerencie as suas próximas viagens'**
  String get reservationsSubtitle;

  /// No description provided for @reservationsNew.
  ///
  /// In pt, this message translates to:
  /// **'Nova reserva'**
  String get reservationsNew;

  /// No description provided for @reservationsPickup.
  ///
  /// In pt, this message translates to:
  /// **'Recolha'**
  String get reservationsPickup;

  /// No description provided for @reservationsDestination.
  ///
  /// In pt, this message translates to:
  /// **'Destino'**
  String get reservationsDestination;

  /// No description provided for @reservationsDetails.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes'**
  String get reservationsDetails;

  /// No description provided for @reservationsCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get reservationsCancel;

  /// No description provided for @reservationsStatusConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'Confirmada'**
  String get reservationsStatusConfirmed;

  /// No description provided for @reservationsStatusPending.
  ///
  /// In pt, this message translates to:
  /// **'Pendente'**
  String get reservationsStatusPending;

  /// No description provided for @tripHistoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de Viagens'**
  String get tripHistoryTitle;

  /// No description provided for @tripHistoryDetails.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes'**
  String get tripHistoryDetails;

  /// No description provided for @tripDetailsSummary.
  ///
  /// In pt, this message translates to:
  /// **'Resumo da Viagem'**
  String get tripDetailsSummary;

  /// No description provided for @tripDetailsStatusCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Concluída'**
  String get tripDetailsStatusCompleted;

  /// No description provided for @rentalTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aluguer de Veículos'**
  String get rentalTitle;

  /// No description provided for @rentalSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Encontre o parceiro perfeito para a sua próxima viagem.'**
  String get rentalSubtitle;

  /// No description provided for @rentalSearchAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar Veículos Disponíveis'**
  String get rentalSearchAvailable;

  /// No description provided for @driverSearchTitle.
  ///
  /// In pt, this message translates to:
  /// **'A procurar motorista disponível'**
  String get driverSearchTitle;

  /// No description provided for @driverFoundTitle.
  ///
  /// In pt, this message translates to:
  /// **'Motorista encontrado'**
  String get driverFoundTitle;

  /// No description provided for @driverEnRouteStatus.
  ///
  /// In pt, this message translates to:
  /// **'Motorista a caminho'**
  String get driverEnRouteStatus;

  /// No description provided for @tripInProgressEndTrip.
  ///
  /// In pt, this message translates to:
  /// **'Terminar Viagem'**
  String get tripInProgressEndTrip;

  /// No description provided for @tripInProgressSupport.
  ///
  /// In pt, this message translates to:
  /// **'Suporte'**
  String get tripInProgressSupport;

  /// No description provided for @tripCompletedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Viagem Concluída!'**
  String get tripCompletedTitle;

  /// No description provided for @tripCompletedBackHome.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao início'**
  String get tripCompletedBackHome;

  /// No description provided for @premiumHomeOrderNow.
  ///
  /// In pt, this message translates to:
  /// **'Pedir agora'**
  String get premiumHomeOrderNow;

  /// No description provided for @support.
  ///
  /// In pt, this message translates to:
  /// **'Suporte'**
  String get support;

  /// No description provided for @destination.
  ///
  /// In pt, this message translates to:
  /// **'Destino'**
  String get destination;

  /// No description provided for @details.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes'**
  String get details;

  /// No description provided for @premiumMobility.
  ///
  /// In pt, this message translates to:
  /// **'Mobilidade Premium'**
  String get premiumMobility;

  /// No description provided for @seeAll.
  ///
  /// In pt, this message translates to:
  /// **'Ver todos'**
  String get seeAll;

  /// No description provided for @edit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @total.
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @subtotal.
  ///
  /// In pt, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @quantity.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade'**
  String get quantity;

  /// No description provided for @distance.
  ///
  /// In pt, this message translates to:
  /// **'Distância'**
  String get distance;

  /// No description provided for @duration.
  ///
  /// In pt, this message translates to:
  /// **'Duração'**
  String get duration;

  /// No description provided for @premium.
  ///
  /// In pt, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @newBadge.
  ///
  /// In pt, this message translates to:
  /// **'Novo'**
  String get newBadge;

  /// No description provided for @promotion.
  ///
  /// In pt, this message translates to:
  /// **'Promoção'**
  String get promotion;

  /// No description provided for @free.
  ///
  /// In pt, this message translates to:
  /// **'Grátis'**
  String get free;

  /// No description provided for @live.
  ///
  /// In pt, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @verified.
  ///
  /// In pt, this message translates to:
  /// **'Verificado'**
  String get verified;

  /// No description provided for @createAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get createAccount;

  /// No description provided for @splashSecureConnection.
  ///
  /// In pt, this message translates to:
  /// **'Conexão Segura & Encriptada'**
  String get splashSecureConnection;

  /// No description provided for @splashExecutiveBadge.
  ///
  /// In pt, this message translates to:
  /// **'EXECUTIVO'**
  String get splashExecutiveBadge;

  /// No description provided for @splashHeroTitle.
  ///
  /// In pt, this message translates to:
  /// **'O seu tempo,\nvalorizado.'**
  String get splashHeroTitle;

  /// No description provided for @splashHeroSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Transporte personalizado com conforto e pontualidade.'**
  String get splashHeroSubtitle;

  /// No description provided for @splashInstantBookingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Reservas Instantâneas'**
  String get splashInstantBookingTitle;

  /// No description provided for @splashInstantBookingSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Planeie a sua viagem em segundos com a nossa rede exclusiva.'**
  String get splashInstantBookingSubtitle;

  /// No description provided for @splashDriverOfToday.
  ///
  /// In pt, this message translates to:
  /// **'MOTORISTA DE HOJE'**
  String get splashDriverOfToday;

  /// No description provided for @adminAppBarTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mobilidade Premium'**
  String get adminAppBarTitle;

  /// No description provided for @adminFleetStatusTitle.
  ///
  /// In pt, this message translates to:
  /// **'Estado da Frota'**
  String get adminFleetStatusTitle;

  /// No description provided for @adminFleetStatusUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Atualizado: Agora'**
  String get adminFleetStatusUpdated;

  /// No description provided for @adminActiveTripsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Viagens Ativas'**
  String get adminActiveTripsLabel;

  /// No description provided for @adminActiveTripsTrend.
  ///
  /// In pt, this message translates to:
  /// **'+12% vs. ontem'**
  String get adminActiveTripsTrend;

  /// No description provided for @adminAvailableDriversLabel.
  ///
  /// In pt, this message translates to:
  /// **'Motoristas Disponíveis'**
  String get adminAvailableDriversLabel;

  /// No description provided for @adminAvailableDriversHint.
  ///
  /// In pt, this message translates to:
  /// **'Pronto para despacho'**
  String get adminAvailableDriversHint;

  /// No description provided for @adminCriticalOpsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Operações Críticas'**
  String get adminCriticalOpsTitle;

  /// No description provided for @adminPendingDebtorsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Devedores Pendentes'**
  String get adminPendingDebtorsTitle;

  /// No description provided for @adminPendingDebtorsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'3 faturas em atraso'**
  String get adminPendingDebtorsSubtitle;

  /// No description provided for @adminMonthlyReportsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Relatórios Mensais'**
  String get adminMonthlyReportsTitle;

  /// No description provided for @adminMonthlyReportsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Performance de Outubro'**
  String get adminMonthlyReportsSubtitle;

  /// No description provided for @adminActivityMapTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mapa de Atividade'**
  String get adminActivityMapTitle;

  /// No description provided for @adminRatesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tarifas & Mercado'**
  String get adminRatesTitle;

  /// No description provided for @adminBaseRateLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tarifa Base'**
  String get adminBaseRateLabel;

  /// No description provided for @adminBaseRateDynamic.
  ///
  /// In pt, this message translates to:
  /// **'Dinâmica: Ativa (1.2x)'**
  String get adminBaseRateDynamic;

  /// No description provided for @adminFuelCostLabel.
  ///
  /// In pt, this message translates to:
  /// **'Custo Combustível'**
  String get adminFuelCostLabel;

  /// No description provided for @adminFuelCostHint.
  ///
  /// In pt, this message translates to:
  /// **'Média Nacional'**
  String get adminFuelCostHint;

  /// No description provided for @adminRecentFleetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Frota Recente'**
  String get adminRecentFleetTitle;

  /// No description provided for @adminFleetStatusOnTrip.
  ///
  /// In pt, this message translates to:
  /// **'Em Viagem'**
  String get adminFleetStatusOnTrip;

  /// No description provided for @adminFleetStatusInactive.
  ///
  /// In pt, this message translates to:
  /// **'Inativo'**
  String get adminFleetStatusInactive;

  /// No description provided for @adminFleetDriverPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Motorista: {name}'**
  String adminFleetDriverPrefix(String name);

  /// No description provided for @deliveryDeliverTo.
  ///
  /// In pt, this message translates to:
  /// **'Entregar em: Av. da Liberdade, Lisboa'**
  String get deliveryDeliverTo;

  /// No description provided for @deliverySearchHint.
  ///
  /// In pt, this message translates to:
  /// **'O que procura hoje?'**
  String get deliverySearchHint;

  /// No description provided for @deliveryExploreCategories.
  ///
  /// In pt, this message translates to:
  /// **'Explorar Categorias'**
  String get deliveryExploreCategories;

  /// No description provided for @deliveryCategorySupermarket.
  ///
  /// In pt, this message translates to:
  /// **'Supermercado'**
  String get deliveryCategorySupermarket;

  /// No description provided for @deliveryCategorySupermarketSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Essenciais frescos à sua porta'**
  String get deliveryCategorySupermarketSubtitle;

  /// No description provided for @deliveryCategoryPharmacy.
  ///
  /// In pt, this message translates to:
  /// **'Farmácia'**
  String get deliveryCategoryPharmacy;

  /// No description provided for @deliveryCategoryBeverages.
  ///
  /// In pt, this message translates to:
  /// **'Bebidas'**
  String get deliveryCategoryBeverages;

  /// No description provided for @deliveryCategoryHealth.
  ///
  /// In pt, this message translates to:
  /// **'Saúde & Bem-estar'**
  String get deliveryCategoryHealth;

  /// No description provided for @deliveryPartnersTitle.
  ///
  /// In pt, this message translates to:
  /// **'Parceiros Premium'**
  String get deliveryPartnersTitle;

  /// No description provided for @deliveryPartnersSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Qualidade garantida e entregas rápidas'**
  String get deliveryPartnersSubtitle;

  /// No description provided for @deliveryHighlightsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Destaques da Semana'**
  String get deliveryHighlightsTitle;

  /// No description provided for @discoverSummerHighlight.
  ///
  /// In pt, this message translates to:
  /// **'DESTAQUE DE VERÃO'**
  String get discoverSummerHighlight;

  /// No description provided for @discoverHeroTitle.
  ///
  /// In pt, this message translates to:
  /// **'A Essência do Mediterrâneo'**
  String get discoverHeroTitle;

  /// No description provided for @discoverHeroSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Descubra refúgios secretos e experiências de luxo desenhadas para o viajante exigente.'**
  String get discoverHeroSubtitle;

  /// No description provided for @discoverSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Procurar restaurantes, festas ou praias...'**
  String get discoverSearchHint;

  /// No description provided for @discoverFilters.
  ///
  /// In pt, this message translates to:
  /// **'Filtros'**
  String get discoverFilters;

  /// No description provided for @discoverExploreMap.
  ///
  /// In pt, this message translates to:
  /// **'Explorar Mapa'**
  String get discoverExploreMap;

  /// No description provided for @discoverExperiencesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Experiências Exclusivas'**
  String get discoverExperiencesTitle;

  /// No description provided for @discoverCategoryGastronomy.
  ///
  /// In pt, this message translates to:
  /// **'Gastronomia'**
  String get discoverCategoryGastronomy;

  /// No description provided for @discoverExperienceRestaurants.
  ///
  /// In pt, this message translates to:
  /// **'Restaurantes de Autor'**
  String get discoverExperienceRestaurants;

  /// No description provided for @discoverCategoryExploration.
  ///
  /// In pt, this message translates to:
  /// **'Exploração'**
  String get discoverCategoryExploration;

  /// No description provided for @discoverExperienceSecretSpots.
  ///
  /// In pt, this message translates to:
  /// **'Recantos Secretos'**
  String get discoverExperienceSecretSpots;

  /// No description provided for @discoverUpcomingEvents.
  ///
  /// In pt, this message translates to:
  /// **'Próximos Eventos'**
  String get discoverUpcomingEvents;

  /// No description provided for @discoverTickets.
  ///
  /// In pt, this message translates to:
  /// **'Bilhetes'**
  String get discoverTickets;

  /// No description provided for @discoverInteractiveMapTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mapa Interativo'**
  String get discoverInteractiveMapTitle;

  /// No description provided for @discoverInteractiveMapSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Explore os pontos de interesse perto de si.'**
  String get discoverInteractiveMapSubtitle;

  /// No description provided for @discoverCurrentLocation.
  ///
  /// In pt, this message translates to:
  /// **'Localização Atual'**
  String get discoverCurrentLocation;

  /// No description provided for @eventDateTimeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Data e Hora'**
  String get eventDateTimeLabel;

  /// No description provided for @eventLocationLabel.
  ///
  /// In pt, this message translates to:
  /// **'Localização'**
  String get eventLocationLabel;

  /// No description provided for @eventAboutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sobre o Evento'**
  String get eventAboutTitle;

  /// No description provided for @eventDirectionsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como chegar'**
  String get eventDirectionsTitle;

  /// No description provided for @eventOpenGps.
  ///
  /// In pt, this message translates to:
  /// **'Abrir no GPS'**
  String get eventOpenGps;

  /// No description provided for @eventStandardTicket.
  ///
  /// In pt, this message translates to:
  /// **'Bilhete Normal'**
  String get eventStandardTicket;

  /// No description provided for @eventStandardTicketDesc.
  ///
  /// In pt, this message translates to:
  /// **'Acesso geral + 1 bebida'**
  String get eventStandardTicketDesc;

  /// No description provided for @eventServiceFee.
  ///
  /// In pt, this message translates to:
  /// **'Taxa de Serviço'**
  String get eventServiceFee;

  /// No description provided for @eventPayNow.
  ///
  /// In pt, this message translates to:
  /// **'Pagar Agora'**
  String get eventPayNow;

  /// No description provided for @eventVipExperience.
  ///
  /// In pt, this message translates to:
  /// **'Experiência VIP'**
  String get eventVipExperience;

  /// No description provided for @eventLimited.
  ///
  /// In pt, this message translates to:
  /// **'LIMITADO'**
  String get eventLimited;

  /// No description provided for @eventVipDescription.
  ///
  /// In pt, this message translates to:
  /// **'Mesa reservada, garrafa incluída e acesso ao backstage.'**
  String get eventVipDescription;

  /// No description provided for @eventCheckAvailability.
  ///
  /// In pt, this message translates to:
  /// **'Ver disponibilidade →'**
  String get eventCheckAvailability;

  /// No description provided for @jetskiAdventureTag.
  ///
  /// In pt, this message translates to:
  /// **'Aventura no Mar'**
  String get jetskiAdventureTag;

  /// No description provided for @jetskiHeroTitle.
  ///
  /// In pt, this message translates to:
  /// **'Domine as Ondas'**
  String get jetskiHeroTitle;

  /// No description provided for @jetskiHeroSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Aluguer premium de motas de água de alta performance.'**
  String get jetskiHeroSubtitle;

  /// No description provided for @jetskiDurationLabel.
  ///
  /// In pt, this message translates to:
  /// **'DURAÇÃO'**
  String get jetskiDurationLabel;

  /// No description provided for @jetskiDurationValue.
  ///
  /// In pt, this message translates to:
  /// **'1 Hora — Passeio Rápido'**
  String get jetskiDurationValue;

  /// No description provided for @jetskiExploreFleet.
  ///
  /// In pt, this message translates to:
  /// **'Explorar Frota'**
  String get jetskiExploreFleet;

  /// No description provided for @jetskiOurFleet.
  ///
  /// In pt, this message translates to:
  /// **'Nossa Frota'**
  String get jetskiOurFleet;

  /// No description provided for @jetskiBookNow.
  ///
  /// In pt, this message translates to:
  /// **'Reservar Agora'**
  String get jetskiBookNow;

  /// No description provided for @jetskiSafetyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Segurança Primeiro'**
  String get jetskiSafetyTitle;

  /// No description provided for @jetskiSafetyLifeJacketTitle.
  ///
  /// In pt, this message translates to:
  /// **'Colete Salva-vidas Incluído'**
  String get jetskiSafetyLifeJacketTitle;

  /// No description provided for @jetskiSafetyLifeJacketSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Equipamento homologado para todos os pesos.'**
  String get jetskiSafetyLifeJacketSubtitle;

  /// No description provided for @jetskiSafetyBriefingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Briefing de Segurança'**
  String get jetskiSafetyBriefingTitle;

  /// No description provided for @jetskiSafetyBriefingSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Instrução obrigatória de 15 min antes da partida.'**
  String get jetskiSafetyBriefingSubtitle;

  /// No description provided for @jetskiSafetyGpsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Monitorização GPS'**
  String get jetskiSafetyGpsTitle;

  /// No description provided for @jetskiSafetyGpsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Equipa de apoio pronta para intervir 24/7.'**
  String get jetskiSafetyGpsSubtitle;

  /// No description provided for @jetskiOurBase.
  ///
  /// In pt, this message translates to:
  /// **'Nossa Base'**
  String get jetskiOurBase;

  /// No description provided for @jetskiOpenMap.
  ///
  /// In pt, this message translates to:
  /// **'Abrir Mapa'**
  String get jetskiOpenMap;

  /// No description provided for @premiumHomeSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Procure destino ou serviço...'**
  String get premiumHomeSearchHint;

  /// No description provided for @premiumHomeNoResults.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum resultado encontrado'**
  String get premiumHomeNoResults;

  /// No description provided for @premiumHomeFastDelivery.
  ///
  /// In pt, this message translates to:
  /// **'Entregas Rápidas'**
  String get premiumHomeFastDelivery;

  /// No description provided for @premiumHomeGroceryPharmacy.
  ///
  /// In pt, this message translates to:
  /// **'Mercearia e Farmácia'**
  String get premiumHomeGroceryPharmacy;

  /// No description provided for @premiumHomeIslandGuide.
  ///
  /// In pt, this message translates to:
  /// **'Guia de Ilhas'**
  String get premiumHomeIslandGuide;

  /// No description provided for @premiumHomeJetski.
  ///
  /// In pt, this message translates to:
  /// **'Mota de Água'**
  String get premiumHomeJetski;

  /// No description provided for @premiumHomeTransportTitle.
  ///
  /// In pt, this message translates to:
  /// **'Transporte e Mobilidade'**
  String get premiumHomeTransportTitle;

  /// No description provided for @premiumHomeTransportTrip.
  ///
  /// In pt, this message translates to:
  /// **'Viagem'**
  String get premiumHomeTransportTrip;

  /// No description provided for @premiumHomeTransportMoto.
  ///
  /// In pt, this message translates to:
  /// **'Moto'**
  String get premiumHomeTransportMoto;

  /// No description provided for @premiumHomeTransportScooter.
  ///
  /// In pt, this message translates to:
  /// **'Trotinete'**
  String get premiumHomeTransportScooter;

  /// No description provided for @premiumHomeTransportBike.
  ///
  /// In pt, this message translates to:
  /// **'Bicicleta'**
  String get premiumHomeTransportBike;

  /// No description provided for @premiumHomeExperiencesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Experiências Premium'**
  String get premiumHomeExperiencesTitle;

  /// No description provided for @premiumHomeJetskiRentalTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aluguer de Motas de Água'**
  String get premiumHomeJetskiRentalTitle;

  /// No description provided for @premiumHomeJetskiRentalDesc.
  ///
  /// In pt, this message translates to:
  /// **'Explore as águas cristalinas com o nosso novo serviço de aluguer premium.'**
  String get premiumHomeJetskiRentalDesc;

  /// No description provided for @premiumHomeFromPrice.
  ///
  /// In pt, this message translates to:
  /// **'Desde 45€'**
  String get premiumHomeFromPrice;

  /// No description provided for @premiumHomeIslandGuideTitle.
  ///
  /// In pt, this message translates to:
  /// **'Guia Exclusivo de Ilhas'**
  String get premiumHomeIslandGuideTitle;

  /// No description provided for @premiumHomeIslandGuideDesc.
  ///
  /// In pt, this message translates to:
  /// **'Descubra os segredos das ilhas com roteiros personalizados pelos locais.'**
  String get premiumHomeIslandGuideDesc;

  /// No description provided for @rentalPickupLocation.
  ///
  /// In pt, this message translates to:
  /// **'Local de Recolha'**
  String get rentalPickupLocation;

  /// No description provided for @rentalDropoffLocation.
  ///
  /// In pt, this message translates to:
  /// **'Local de Entrega'**
  String get rentalDropoffLocation;

  /// No description provided for @rentalSamePickupHint.
  ///
  /// In pt, this message translates to:
  /// **'Mesmo local de recolha'**
  String get rentalSamePickupHint;

  /// No description provided for @rentalDateSelection.
  ///
  /// In pt, this message translates to:
  /// **'Seleção de Datas'**
  String get rentalDateSelection;

  /// No description provided for @rentalDriverAge.
  ///
  /// In pt, this message translates to:
  /// **'Idade do Condutor'**
  String get rentalDriverAge;

  /// No description provided for @rentalDriverAgeNote.
  ///
  /// In pt, this message translates to:
  /// **'Taxas adicionais podem ser aplicadas para condutores fora do intervalo padrão.'**
  String get rentalDriverAgeNote;

  /// No description provided for @rentalPremiumOnly.
  ///
  /// In pt, this message translates to:
  /// **'Premium Only'**
  String get rentalPremiumOnly;

  /// No description provided for @rentalLuxuryFleetOnly.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar apenas frota de luxo'**
  String get rentalLuxuryFleetOnly;

  /// No description provided for @rentalViewFleetOnMap.
  ///
  /// In pt, this message translates to:
  /// **'Ver frota no mapa'**
  String get rentalViewFleetOnMap;

  /// No description provided for @rentalCarType.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de Carro'**
  String get rentalCarType;

  /// No description provided for @rentalMaxPrice.
  ///
  /// In pt, this message translates to:
  /// **'Preço Máximo'**
  String get rentalMaxPrice;

  /// No description provided for @rentalTransmission.
  ///
  /// In pt, this message translates to:
  /// **'Transmissão'**
  String get rentalTransmission;

  /// No description provided for @rentalFilter.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar'**
  String get rentalFilter;

  /// No description provided for @rentalPremiumHighlights.
  ///
  /// In pt, this message translates to:
  /// **'Destaques Premium'**
  String get rentalPremiumHighlights;

  /// No description provided for @rentalResultsFound.
  ///
  /// In pt, this message translates to:
  /// **'{count} resultados encontrados'**
  String rentalResultsFound(String count);

  /// No description provided for @rentalPremiumChoice.
  ///
  /// In pt, this message translates to:
  /// **'Premium Choice'**
  String get rentalPremiumChoice;

  /// No description provided for @rentalAllCars.
  ///
  /// In pt, this message translates to:
  /// **'Todos os Carros'**
  String get rentalAllCars;

  /// No description provided for @rentalLoadMore.
  ///
  /// In pt, this message translates to:
  /// **'Carregar mais veículos'**
  String get rentalLoadMore;

  /// No description provided for @rentalVehicleDetails.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes do Veículo'**
  String get rentalVehicleDetails;

  /// No description provided for @rentalRating.
  ///
  /// In pt, this message translates to:
  /// **'Classificação'**
  String get rentalRating;

  /// No description provided for @rentalPowertrain.
  ///
  /// In pt, this message translates to:
  /// **'Motorização'**
  String get rentalPowertrain;

  /// No description provided for @rentalCapacity.
  ///
  /// In pt, this message translates to:
  /// **'Capacidade'**
  String get rentalCapacity;

  /// No description provided for @rentalAcceleration.
  ///
  /// In pt, this message translates to:
  /// **'Aceleração'**
  String get rentalAcceleration;

  /// No description provided for @rentalInsuranceIncluded.
  ///
  /// In pt, this message translates to:
  /// **'Seguro Incluído'**
  String get rentalInsuranceIncluded;

  /// No description provided for @rentalFuelPolicy.
  ///
  /// In pt, this message translates to:
  /// **'Combustível'**
  String get rentalFuelPolicy;

  /// No description provided for @rentalCurrentBattery.
  ///
  /// In pt, this message translates to:
  /// **'Bateria Atual'**
  String get rentalCurrentBattery;

  /// No description provided for @rentalBookingSummary.
  ///
  /// In pt, this message translates to:
  /// **'Resumo da Reserva'**
  String get rentalBookingSummary;

  /// No description provided for @rentalTotalCost.
  ///
  /// In pt, this message translates to:
  /// **'Custo Total'**
  String get rentalTotalCost;

  /// No description provided for @rentalTechnicalSpecs.
  ///
  /// In pt, this message translates to:
  /// **'ESPECIFICAÇÕES TÉCNICAS'**
  String get rentalTechnicalSpecs;

  /// No description provided for @rentalReservationTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total da reserva'**
  String get rentalReservationTotal;

  /// No description provided for @rentalContinueToPayment.
  ///
  /// In pt, this message translates to:
  /// **'Continuar para Pagamento'**
  String get rentalContinueToPayment;

  /// No description provided for @rentalPerDay.
  ///
  /// In pt, this message translates to:
  /// **'/dia'**
  String get rentalPerDay;

  /// No description provided for @rentalSeats.
  ///
  /// In pt, this message translates to:
  /// **'{count} Lugares'**
  String rentalSeats(String count);

  /// No description provided for @rentalBag.
  ///
  /// In pt, this message translates to:
  /// **'Mala'**
  String get rentalBag;

  /// No description provided for @rentalBags.
  ///
  /// In pt, this message translates to:
  /// **'Malas'**
  String get rentalBags;

  /// No description provided for @reservationReviewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Revisão da Reserva'**
  String get reservationReviewTitle;

  /// No description provided for @reservationItinerary.
  ///
  /// In pt, this message translates to:
  /// **'Itinerário'**
  String get reservationItinerary;

  /// No description provided for @reservationPickupLabel.
  ///
  /// In pt, this message translates to:
  /// **'LEVANTAMENTO'**
  String get reservationPickupLabel;

  /// No description provided for @reservationReturnLabel.
  ///
  /// In pt, this message translates to:
  /// **'DEVOLUÇÃO'**
  String get reservationReturnLabel;

  /// No description provided for @reservationSecurePayment.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento 100% Seguro'**
  String get reservationSecurePayment;

  /// No description provided for @reservationSecurePaymentDesc.
  ///
  /// In pt, this message translates to:
  /// **'Utilizamos encriptação SSL de 256 bits para proteger os seus dados.'**
  String get reservationSecurePaymentDesc;

  /// No description provided for @reservationCostSummary.
  ///
  /// In pt, this message translates to:
  /// **'Resumo de Custos'**
  String get reservationCostSummary;

  /// No description provided for @reservationNoHiddenFees.
  ///
  /// In pt, this message translates to:
  /// **'Sem custos ocultos'**
  String get reservationNoHiddenFees;

  /// No description provided for @reservationPaymentMethod.
  ///
  /// In pt, this message translates to:
  /// **'Método de Pagamento'**
  String get reservationPaymentMethod;

  /// No description provided for @reservationCreditCard.
  ///
  /// In pt, this message translates to:
  /// **'Cartão de Crédito'**
  String get reservationCreditCard;

  /// No description provided for @reservationPayWithApplePay.
  ///
  /// In pt, this message translates to:
  /// **'Pagar com Apple Pay'**
  String get reservationPayWithApplePay;

  /// No description provided for @reservationConfirmAndPay.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar e Pagar'**
  String get reservationConfirmAndPay;

  /// No description provided for @reservationTermsPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Ao clicar em \"Confirmar e Pagar\", aceita os nossos '**
  String get reservationTermsPrefix;

  /// No description provided for @reservationTermsLink.
  ///
  /// In pt, this message translates to:
  /// **'Termos e Condições'**
  String get reservationTermsLink;

  /// No description provided for @reservationFullInsurance.
  ///
  /// In pt, this message translates to:
  /// **'Seguro Total Incluído'**
  String get reservationFullInsurance;

  /// No description provided for @reservationsEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não tem mais reservas'**
  String get reservationsEmptyTitle;

  /// No description provided for @reservationsEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Planeie a sua próxima viagem com a nossa frota premium. Conforto e pontualidade garantidos.'**
  String get reservationsEmptyBody;

  /// No description provided for @reservationsExploreDestinations.
  ///
  /// In pt, this message translates to:
  /// **'Explorar destinos'**
  String get reservationsExploreDestinations;

  /// No description provided for @tripHistoryActivity.
  ///
  /// In pt, this message translates to:
  /// **'A Minha Atividade'**
  String get tripHistoryActivity;

  /// No description provided for @tripHistoryTrips.
  ///
  /// In pt, this message translates to:
  /// **'Viagens'**
  String get tripHistoryTrips;

  /// No description provided for @tripHistoryThisMonth.
  ///
  /// In pt, this message translates to:
  /// **'Este Mês'**
  String get tripHistoryThisMonth;

  /// No description provided for @tripHistoryFilterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get tripHistoryFilterAll;

  /// No description provided for @tripHistoryFilterRecent.
  ///
  /// In pt, this message translates to:
  /// **'Viagens Recentes'**
  String get tripHistoryFilterRecent;

  /// No description provided for @tripHistoryFilterCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Concluídas'**
  String get tripHistoryFilterCompleted;

  /// No description provided for @tripHistoryFilterCancelled.
  ///
  /// In pt, this message translates to:
  /// **'Canceladas'**
  String get tripHistoryFilterCancelled;

  /// No description provided for @tripHistoryFilterThisYear.
  ///
  /// In pt, this message translates to:
  /// **'Este Ano'**
  String get tripHistoryFilterThisYear;

  /// No description provided for @tripHistoryStatusCancelled.
  ///
  /// In pt, this message translates to:
  /// **'Cancelada'**
  String get tripHistoryStatusCancelled;

  /// No description provided for @tripHistoryNoDetails.
  ///
  /// In pt, this message translates to:
  /// **'Sem detalhes'**
  String get tripHistoryNoDetails;

  /// No description provided for @tripDetailsRateExperience.
  ///
  /// In pt, this message translates to:
  /// **'Avalie a sua experiência'**
  String get tripDetailsRateExperience;

  /// No description provided for @tripDetailsDigitalInvoice.
  ///
  /// In pt, this message translates to:
  /// **'Fatura Digital'**
  String get tripDetailsDigitalInvoice;

  /// No description provided for @tripDetailsTotalPaid.
  ///
  /// In pt, this message translates to:
  /// **'Total Pago'**
  String get tripDetailsTotalPaid;

  /// No description provided for @tripDetailsMethod.
  ///
  /// In pt, this message translates to:
  /// **'Método'**
  String get tripDetailsMethod;

  /// No description provided for @tripDetailsDownloadPdf.
  ///
  /// In pt, this message translates to:
  /// **'Descarregar PDF'**
  String get tripDetailsDownloadPdf;

  /// No description provided for @tripDetailsFareBase.
  ///
  /// In pt, this message translates to:
  /// **'Tarifa Base'**
  String get tripDetailsFareBase;

  /// No description provided for @tripDetailsFareDistance.
  ///
  /// In pt, this message translates to:
  /// **'Distância (12.5 km)'**
  String get tripDetailsFareDistance;

  /// No description provided for @tripDetailsFareTime.
  ///
  /// In pt, this message translates to:
  /// **'Tempo (24 min)'**
  String get tripDetailsFareTime;

  /// No description provided for @tripDetailsFareDiscount.
  ///
  /// In pt, this message translates to:
  /// **'Desconto Promocional'**
  String get tripDetailsFareDiscount;

  /// No description provided for @tripDetailsSupportTitle.
  ///
  /// In pt, this message translates to:
  /// **'Algo correu mal?'**
  String get tripDetailsSupportTitle;

  /// No description provided for @tripDetailsSupportLostItem.
  ///
  /// In pt, this message translates to:
  /// **'Reportar objeto perdido'**
  String get tripDetailsSupportLostItem;

  /// No description provided for @tripDetailsSupportSafety.
  ///
  /// In pt, this message translates to:
  /// **'Reclamação de segurança'**
  String get tripDetailsSupportSafety;

  /// No description provided for @tripDetailsSupportCustomer.
  ///
  /// In pt, this message translates to:
  /// **'Apoio ao cliente'**
  String get tripDetailsSupportCustomer;

  /// No description provided for @tripCompletedThanks.
  ///
  /// In pt, this message translates to:
  /// **'Obrigado por viajar connosco.'**
  String get tripCompletedThanks;

  /// No description provided for @tripCompletedFinalPrice.
  ///
  /// In pt, this message translates to:
  /// **'Preço Final'**
  String get tripCompletedFinalPrice;

  /// No description provided for @tripCompletedOptimizedRoute.
  ///
  /// In pt, this message translates to:
  /// **'Trajeto otimizado'**
  String get tripCompletedOptimizedRoute;

  /// No description provided for @tripCompletedRateTrip.
  ///
  /// In pt, this message translates to:
  /// **'Avalie a Viagem'**
  String get tripCompletedRateTrip;

  /// No description provided for @tripCompletedRateHint.
  ///
  /// In pt, this message translates to:
  /// **'Como correu a sua experiência com o motorista e o veículo?'**
  String get tripCompletedRateHint;

  /// No description provided for @tripCompletedCommentOptional.
  ///
  /// In pt, this message translates to:
  /// **'Comentário (opcional)'**
  String get tripCompletedCommentOptional;

  /// No description provided for @tripCompletedCommentHint.
  ///
  /// In pt, this message translates to:
  /// **'Partilhe a sua opinião...'**
  String get tripCompletedCommentHint;

  /// No description provided for @tripCompletedSubmitRating.
  ///
  /// In pt, this message translates to:
  /// **'Enviar avaliação'**
  String get tripCompletedSubmitRating;

  /// No description provided for @tripCompletedRatingSent.
  ///
  /// In pt, this message translates to:
  /// **'Avaliação enviada'**
  String get tripCompletedRatingSent;

  /// No description provided for @tripCompletedReportIssue.
  ///
  /// In pt, this message translates to:
  /// **'Reportar problema'**
  String get tripCompletedReportIssue;

  /// No description provided for @tripInProgressStatusLabel.
  ///
  /// In pt, this message translates to:
  /// **'Status da Viagem'**
  String get tripInProgressStatusLabel;

  /// No description provided for @tripInProgressStatusValue.
  ///
  /// In pt, this message translates to:
  /// **'Em viagem'**
  String get tripInProgressStatusValue;

  /// No description provided for @tripInProgressArrivalLabel.
  ///
  /// In pt, this message translates to:
  /// **'Chegada prevista'**
  String get tripInProgressArrivalLabel;

  /// No description provided for @tripInProgressCostLabel.
  ///
  /// In pt, this message translates to:
  /// **'Custo Estimado'**
  String get tripInProgressCostLabel;

  /// No description provided for @driverSearchSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Estamos a ligar-te aos veículos mais próximos em Lisboa Central.'**
  String get driverSearchSubtitle;

  /// No description provided for @driverSearchOrigin.
  ///
  /// In pt, this message translates to:
  /// **'ORIGEM'**
  String get driverSearchOrigin;

  /// No description provided for @driverSearchEstimate.
  ///
  /// In pt, this message translates to:
  /// **'ESTIMATIVA'**
  String get driverSearchEstimate;

  /// No description provided for @driverSearchCancelTrip.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar Viagem'**
  String get driverSearchCancelTrip;

  /// No description provided for @driverSearchOptimizing.
  ///
  /// In pt, this message translates to:
  /// **'Otimizando percurso em tempo real...'**
  String get driverSearchOptimizing;

  /// No description provided for @driverFoundWaiting.
  ///
  /// In pt, this message translates to:
  /// **'A aguardar confirmação...'**
  String get driverFoundWaiting;

  /// No description provided for @driverFoundEstimatedTime.
  ///
  /// In pt, this message translates to:
  /// **'Tempo estimado'**
  String get driverFoundEstimatedTime;

  /// No description provided for @driverFoundFare.
  ///
  /// In pt, this message translates to:
  /// **'Tarifa'**
  String get driverFoundFare;

  /// No description provided for @driverFoundCancelHint.
  ///
  /// In pt, this message translates to:
  /// **'Pode cancelar sem custos nos próximos 2 minutos enquanto o motorista confirma a reserva.'**
  String get driverFoundCancelHint;

  /// No description provided for @driverEnRouteYourLocation.
  ///
  /// In pt, this message translates to:
  /// **'A sua localização'**
  String get driverEnRouteYourLocation;

  /// No description provided for @driverEnRouteMessage.
  ///
  /// In pt, this message translates to:
  /// **'Mensagem'**
  String get driverEnRouteMessage;

  /// No description provided for @driverEnRouteCall.
  ///
  /// In pt, this message translates to:
  /// **'Ligar'**
  String get driverEnRouteCall;

  /// No description provided for @tripDestinationSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Procure um destino ou escolha um dos seus locais frequentes.'**
  String get tripDestinationSubtitle;

  /// No description provided for @tripDestinationSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar endereço ou ponto de interesse'**
  String get tripDestinationSearchHint;

  /// No description provided for @tripDestinationRecentPlaces.
  ///
  /// In pt, this message translates to:
  /// **'Locais Recentes'**
  String get tripDestinationRecentPlaces;

  /// No description provided for @tripDestinationSuggestions.
  ///
  /// In pt, this message translates to:
  /// **'Sugestões e Favoritos'**
  String get tripDestinationSuggestions;

  /// No description provided for @tripDestinationExploreMap.
  ///
  /// In pt, this message translates to:
  /// **'Explorar Mapa'**
  String get tripDestinationExploreMap;

  /// No description provided for @tripDestinationTodaySuggestion.
  ///
  /// In pt, this message translates to:
  /// **'SUGESTÃO DE HOJE'**
  String get tripDestinationTodaySuggestion;

  /// No description provided for @tripDestinationViewFullMap.
  ///
  /// In pt, this message translates to:
  /// **'Ver Mapa Completo'**
  String get tripDestinationViewFullMap;

  /// No description provided for @tripConfirmTransportType.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de Transporte'**
  String get tripConfirmTransportType;

  /// No description provided for @tripConfirmTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total: {amount}'**
  String tripConfirmTotal(String amount);

  /// No description provided for @tripConfirmTrip.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar viagem'**
  String get tripConfirmTrip;

  /// No description provided for @tripConfirmPickupPoint.
  ///
  /// In pt, this message translates to:
  /// **'PONTO DE RECOLHA'**
  String get tripConfirmPickupPoint;

  /// No description provided for @tripConfirmFinalDestination.
  ///
  /// In pt, this message translates to:
  /// **'DESTINO FINAL'**
  String get tripConfirmFinalDestination;

  /// No description provided for @tripConfirmTransportPremium.
  ///
  /// In pt, this message translates to:
  /// **'Premium'**
  String get tripConfirmTransportPremium;

  /// No description provided for @tripConfirmTransportEco.
  ///
  /// In pt, this message translates to:
  /// **'Eco-Eletric'**
  String get tripConfirmTransportEco;

  /// No description provided for @tripConfirmTransportShared.
  ///
  /// In pt, this message translates to:
  /// **'Partilhado'**
  String get tripConfirmTransportShared;

  /// No description provided for @driverAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Disponível'**
  String get driverAvailable;

  /// No description provided for @driverUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Indisponível'**
  String get driverUnavailable;

  /// No description provided for @driverFleetStatus.
  ///
  /// In pt, this message translates to:
  /// **'Status da Frota'**
  String get driverFleetStatus;

  /// No description provided for @driverVerified.
  ///
  /// In pt, this message translates to:
  /// **'Verificado'**
  String get driverVerified;

  /// No description provided for @driverInOperation.
  ///
  /// In pt, this message translates to:
  /// **'Em Operação'**
  String get driverInOperation;

  /// No description provided for @driverTodayEarnings.
  ///
  /// In pt, this message translates to:
  /// **'Ganhos de Hoje'**
  String get driverTodayEarnings;

  /// No description provided for @driverEarningsChange.
  ///
  /// In pt, this message translates to:
  /// **'+12% vs. ontem'**
  String get driverEarningsChange;

  /// No description provided for @driverTripsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Viagens'**
  String get driverTripsLabel;

  /// No description provided for @driverDistanceLabel.
  ///
  /// In pt, this message translates to:
  /// **'Distância'**
  String get driverDistanceLabel;

  /// No description provided for @driverRecentTrips.
  ///
  /// In pt, this message translates to:
  /// **'Últimas Viagens'**
  String get driverRecentTrips;

  /// No description provided for @driverLocationCity.
  ///
  /// In pt, this message translates to:
  /// **'Lisboa, PT'**
  String get driverLocationCity;

  /// No description provided for @driverHoursAgo.
  ///
  /// In pt, this message translates to:
  /// **'há {hours}h'**
  String driverHoursAgo(int hours);

  /// No description provided for @driverNewRequest.
  ///
  /// In pt, this message translates to:
  /// **'Nova Solicitação'**
  String get driverNewRequest;

  /// No description provided for @driverPremiumTrip.
  ///
  /// In pt, this message translates to:
  /// **'Viagem Premium'**
  String get driverPremiumTrip;

  /// No description provided for @driverPickup.
  ///
  /// In pt, this message translates to:
  /// **'Recolha'**
  String get driverPickup;

  /// No description provided for @driverDestination.
  ///
  /// In pt, this message translates to:
  /// **'Destino'**
  String get driverDestination;

  /// No description provided for @driverDecline.
  ///
  /// In pt, this message translates to:
  /// **'RECUSAR'**
  String get driverDecline;

  /// No description provided for @driverAcceptTrip.
  ///
  /// In pt, this message translates to:
  /// **'ACEITAR VIAGEM'**
  String get driverAcceptTrip;

  /// No description provided for @driverTripAcceptedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Viagem Aceite!'**
  String get driverTripAcceptedTitle;

  /// No description provided for @driverTripAcceptedSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'A preparar a rota de navegação...'**
  String get driverTripAcceptedSubtitle;

  /// No description provided for @driverPassenger.
  ///
  /// In pt, this message translates to:
  /// **'Passageiro'**
  String get driverPassenger;

  /// No description provided for @driverEstimatedArrival.
  ///
  /// In pt, this message translates to:
  /// **'Chegada estimada'**
  String get driverEstimatedArrival;

  /// No description provided for @driverStartNavigation.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar Navegação Agora'**
  String get driverStartNavigation;

  /// No description provided for @driverRequestExpiredTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pedido Expirado'**
  String get driverRequestExpiredTitle;

  /// No description provided for @driverRequestExpiredMessage.
  ///
  /// In pt, this message translates to:
  /// **'O tempo limite de 12 segundos para aceitar a viagem esgotou.'**
  String get driverRequestExpiredMessage;

  /// No description provided for @driverUnavailableForRequests.
  ///
  /// In pt, this message translates to:
  /// **'Atualmente indisponível para novos pedidos'**
  String get driverUnavailableForRequests;

  /// No description provided for @driverBackToDashboard.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao Dashboard'**
  String get driverBackToDashboard;

  /// No description provided for @driverViewTripHistory.
  ///
  /// In pt, this message translates to:
  /// **'Ver Histórico de Viagens'**
  String get driverViewTripHistory;

  /// No description provided for @driverDistanceToDestination.
  ///
  /// In pt, this message translates to:
  /// **'A {distance} do destino'**
  String driverDistanceToDestination(String distance);

  /// No description provided for @driverVipPassenger.
  ///
  /// In pt, this message translates to:
  /// **'Passageiro VIP'**
  String get driverVipPassenger;

  /// No description provided for @driverEstimatedTimeLabel.
  ///
  /// In pt, this message translates to:
  /// **'TEMPO ESTIMADO'**
  String get driverEstimatedTimeLabel;

  /// No description provided for @driverDistanceStatLabel.
  ///
  /// In pt, this message translates to:
  /// **'DISTÂNCIA'**
  String get driverDistanceStatLabel;

  /// No description provided for @driverOnTheWay.
  ///
  /// In pt, this message translates to:
  /// **'A caminho'**
  String get driverOnTheWay;

  /// No description provided for @driverArrivedStatus.
  ///
  /// In pt, this message translates to:
  /// **'Chegou ao local'**
  String get driverArrivedStatus;

  /// No description provided for @driverTripInProgressStatus.
  ///
  /// In pt, this message translates to:
  /// **'Viagem em curso'**
  String get driverTripInProgressStatus;

  /// No description provided for @driverArrivedButton.
  ///
  /// In pt, this message translates to:
  /// **'Cheguei'**
  String get driverArrivedButton;

  /// No description provided for @driverStartTripButton.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar viagem'**
  String get driverStartTripButton;

  /// No description provided for @driverFinishTripButton.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar viagem'**
  String get driverFinishTripButton;

  /// No description provided for @adminReportsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Relatórios Detalhados'**
  String get adminReportsTitle;

  /// No description provided for @adminReportsExport.
  ///
  /// In pt, this message translates to:
  /// **'Exportar'**
  String get adminReportsExport;

  /// No description provided for @adminReportsDateRangeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Intervalo de Datas'**
  String get adminReportsDateRangeLabel;

  /// No description provided for @adminReportsVehicleFleetLabel.
  ///
  /// In pt, this message translates to:
  /// **'Veículo / Frota'**
  String get adminReportsVehicleFleetLabel;

  /// No description provided for @adminReportsAllVehicles.
  ///
  /// In pt, this message translates to:
  /// **'Todos os Veículos'**
  String get adminReportsAllVehicles;

  /// No description provided for @adminReportsTotalTrips.
  ///
  /// In pt, this message translates to:
  /// **'Total de Viagens'**
  String get adminReportsTotalTrips;

  /// No description provided for @adminReportsTotalDistance.
  ///
  /// In pt, this message translates to:
  /// **'Distância Total'**
  String get adminReportsTotalDistance;

  /// No description provided for @adminReportsTimeOnRoute.
  ///
  /// In pt, this message translates to:
  /// **'Tempo em Rota'**
  String get adminReportsTimeOnRoute;

  /// No description provided for @adminReportsTotalCost.
  ///
  /// In pt, this message translates to:
  /// **'Custo Total'**
  String get adminReportsTotalCost;

  /// No description provided for @adminReportsPendingDebt.
  ///
  /// In pt, this message translates to:
  /// **'Dívida Pendente'**
  String get adminReportsPendingDebt;

  /// No description provided for @adminReportsOverdueInvoices.
  ///
  /// In pt, this message translates to:
  /// **'FATURAS EM ATRASO'**
  String get adminReportsOverdueInvoices;

  /// No description provided for @adminReportsMonthlyPerformance.
  ///
  /// In pt, this message translates to:
  /// **'Análise de Performance Mensal'**
  String get adminReportsMonthlyPerformance;

  /// No description provided for @adminReportsChartHint.
  ///
  /// In pt, this message translates to:
  /// **'Visualização detalhada das tendências de custo e quilometragem do período selecionado.'**
  String get adminReportsChartHint;

  /// No description provided for @adminReportsLatestActivities.
  ///
  /// In pt, this message translates to:
  /// **'ÚLTIMAS ATIVIDADES'**
  String get adminReportsLatestActivities;

  /// No description provided for @adminReportsFleetEfficiency.
  ///
  /// In pt, this message translates to:
  /// **'EFICIÊNCIA DA FROTA'**
  String get adminReportsFleetEfficiency;

  /// No description provided for @adminReportsOptimizedStatus.
  ///
  /// In pt, this message translates to:
  /// **'OTIMIZADO'**
  String get adminReportsOptimizedStatus;

  /// No description provided for @adminReportsOptimized.
  ///
  /// In pt, this message translates to:
  /// **'{percent}% OTIMIZADO'**
  String adminReportsOptimized(int percent);

  /// No description provided for @adminReportsEfficiencyFooter.
  ///
  /// In pt, this message translates to:
  /// **'A sua frota está a operar 15% acima da média do setor neste trimestre.'**
  String get adminReportsEfficiencyFooter;

  /// No description provided for @adminDrawerFleetManager.
  ///
  /// In pt, this message translates to:
  /// **'Gestor de Frota'**
  String get adminDrawerFleetManager;

  /// No description provided for @adminDrawerFleetSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Frota Central Lisboa'**
  String get adminDrawerFleetSubtitle;

  /// No description provided for @adminDrawerRoleBadge.
  ///
  /// In pt, this message translates to:
  /// **'Admin'**
  String get adminDrawerRoleBadge;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
