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
    Locale('pt', 'PT'),
  ];

  /// No description provided for @appNameLocalTransport.
  ///
  /// In pt_PT, this message translates to:
  /// **'Local Transport'**
  String get appNameLocalTransport;

  /// No description provided for @signIn.
  ///
  /// In pt_PT, this message translates to:
  /// **'Entrar'**
  String get signIn;

  /// No description provided for @cancel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In pt_PT, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @signOut.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sair'**
  String get signOut;

  /// No description provided for @signOutTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Terminar sessão'**
  String get signOutTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tem a certeza de que pretende sair da sua conta?'**
  String get signOutConfirmMessage;

  /// No description provided for @signOutFailed.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não foi possível terminar sessão. Tente novamente.'**
  String get signOutFailed;

  /// No description provided for @tryAgain.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tentar novamente'**
  String get tryAgain;

  /// No description provided for @featureComingSoon.
  ///
  /// In pt_PT, this message translates to:
  /// **'{feature} estará disponível em breve.'**
  String featureComingSoon(String feature);

  /// No description provided for @navHome.
  ///
  /// In pt_PT, this message translates to:
  /// **'Início'**
  String get navHome;

  /// No description provided for @navTrips.
  ///
  /// In pt_PT, this message translates to:
  /// **'Viagens'**
  String get navTrips;

  /// No description provided for @navReservations.
  ///
  /// In pt_PT, this message translates to:
  /// **'Reservas'**
  String get navReservations;

  /// No description provided for @navBalance.
  ///
  /// In pt_PT, this message translates to:
  /// **'Saldo'**
  String get navBalance;

  /// No description provided for @navProfile.
  ///
  /// In pt_PT, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Inicie sessão para gerir as suas viagens.'**
  String get loginSubtitle;

  /// No description provided for @loginSettingsTooltip.
  ///
  /// In pt_PT, this message translates to:
  /// **'Definições'**
  String get loginSettingsTooltip;

  /// No description provided for @loginEmailOrMobileLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'E-mail ou Telemóvel'**
  String get loginEmailOrMobileLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'ex: joao@email.com'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Palavra-passe'**
  String get loginPasswordLabel;

  /// No description provided for @loginForgotPassword.
  ///
  /// In pt_PT, this message translates to:
  /// **'Esqueceu-se?'**
  String get loginForgotPassword;

  /// No description provided for @loginFillEmailPassword.
  ///
  /// In pt_PT, this message translates to:
  /// **'Preencha o e-mail e a palavra-passe.'**
  String get loginFillEmailPassword;

  /// No description provided for @loginNoAccountPrompt.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ainda não tem conta? '**
  String get loginNoAccountPrompt;

  /// No description provided for @loginRegisterNow.
  ///
  /// In pt_PT, this message translates to:
  /// **'Registar agora'**
  String get loginRegisterNow;

  /// No description provided for @loginPrivacy.
  ///
  /// In pt_PT, this message translates to:
  /// **'Privacidade'**
  String get loginPrivacy;

  /// No description provided for @loginTermsOfUse.
  ///
  /// In pt_PT, this message translates to:
  /// **'Termos de Uso'**
  String get loginTermsOfUse;

  /// No description provided for @loginSupport.
  ///
  /// In pt_PT, this message translates to:
  /// **'Suporte'**
  String get loginSupport;

  /// No description provided for @loginRoleClient.
  ///
  /// In pt_PT, this message translates to:
  /// **'Cliente'**
  String get loginRoleClient;

  /// No description provided for @loginRoleProfessional.
  ///
  /// In pt_PT, this message translates to:
  /// **'Profissional'**
  String get loginRoleProfessional;

  /// No description provided for @secureConnectionE2E.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ligação segura e encriptada ponta-a-ponta.'**
  String get secureConnectionE2E;

  /// No description provided for @authErrorUnexpected.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ocorreu um erro inesperado. Tente novamente.'**
  String get authErrorUnexpected;

  /// No description provided for @authErrorProfileNotFound.
  ///
  /// In pt_PT, this message translates to:
  /// **'Perfil de utilizador não encontrado.'**
  String get authErrorProfileNotFound;

  /// No description provided for @authErrorAccountInactive.
  ///
  /// In pt_PT, this message translates to:
  /// **'Esta conta está inactiva. Contacte o suporte.'**
  String get authErrorAccountInactive;

  /// No description provided for @authErrorRoleMismatch.
  ///
  /// In pt_PT, this message translates to:
  /// **'Perfil não corresponde ao tipo selecionado.'**
  String get authErrorRoleMismatch;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In pt_PT, this message translates to:
  /// **'E-mail inválido.'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In pt_PT, this message translates to:
  /// **'Esta conta está desactivada.'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorWrongCredentials.
  ///
  /// In pt_PT, this message translates to:
  /// **'E-mail ou palavra-passe incorrectos.'**
  String get authErrorWrongCredentials;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In pt_PT, this message translates to:
  /// **'Demasiadas tentativas. Tente mais tarde.'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorSignInFailed.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não foi possível iniciar sessão. Tente novamente.'**
  String get authErrorSignInFailed;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In pt_PT, this message translates to:
  /// **'Este e-mail já está registado.'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In pt_PT, this message translates to:
  /// **'Palavra-passe demasiado fraca. Use pelo menos 6 caracteres.'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorRegistrationFailed.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não foi possível criar a conta. Tente novamente.'**
  String get authErrorRegistrationFailed;

  /// No description provided for @registerSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Crie a sua conta como cliente ou motorista profissional.'**
  String get registerSubtitle;

  /// No description provided for @registerNameLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nome completo'**
  String get registerNameLabel;

  /// No description provided for @registerNameHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'ex. João Silva'**
  String get registerNameHint;

  /// No description provided for @registerPhoneLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Telemóvel (opcional)'**
  String get registerPhoneLabel;

  /// No description provided for @registerPhoneHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'ex. +351910000000'**
  String get registerPhoneHint;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Confirmar palavra-passe'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerFillRequiredFields.
  ///
  /// In pt_PT, this message translates to:
  /// **'Preencha nome, e-mail e palavra-passe.'**
  String get registerFillRequiredFields;

  /// No description provided for @registerPasswordTooShort.
  ///
  /// In pt_PT, this message translates to:
  /// **'A palavra-passe deve ter pelo menos 6 caracteres.'**
  String get registerPasswordTooShort;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In pt_PT, this message translates to:
  /// **'As palavras-passe não coincidem.'**
  String get registerPasswordMismatch;

  /// No description provided for @registerAlreadyHaveAccount.
  ///
  /// In pt_PT, this message translates to:
  /// **'Já tem conta? '**
  String get registerAlreadyHaveAccount;

  /// No description provided for @registerSignInNow.
  ///
  /// In pt_PT, this message translates to:
  /// **'Iniciar sessão'**
  String get registerSignInNow;

  /// No description provided for @settingsTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Definições'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ajuste preferências e mantenha a aplicação pronta para si.'**
  String get settingsSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In pt_PT, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In pt_PT, this message translates to:
  /// **'Escolha o idioma da aplicação. Pode repor o idioma do dispositivo a qualquer momento.'**
  String get settingsLanguageDescription;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In pt_PT, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In pt_PT, this message translates to:
  /// **'Español'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsLanguagePortuguese.
  ///
  /// In pt_PT, this message translates to:
  /// **'Português (Portugal)'**
  String get settingsLanguagePortuguese;

  /// No description provided for @settingsLanguageFollowingDevice.
  ///
  /// In pt_PT, this message translates to:
  /// **'A seguir o idioma do dispositivo ({language}).'**
  String settingsLanguageFollowingDevice(String language);

  /// No description provided for @settingsLanguageManual.
  ///
  /// In pt_PT, this message translates to:
  /// **'Idioma selecionado manualmente: {language}.'**
  String settingsLanguageManual(String language);

  /// No description provided for @settingsLanguageResetSnack.
  ///
  /// In pt_PT, this message translates to:
  /// **'Idioma reposto para o do dispositivo.'**
  String get settingsLanguageResetSnack;

  /// No description provided for @settingsUseDeviceLanguage.
  ///
  /// In pt_PT, this message translates to:
  /// **'Repor idioma do dispositivo'**
  String get settingsUseDeviceLanguage;

  /// No description provided for @settingsDisplayCurrency.
  ///
  /// In pt_PT, this message translates to:
  /// **'Moeda de visualização'**
  String get settingsDisplayCurrency;

  /// No description provided for @settingsDisplayCurrencyDescription.
  ///
  /// In pt_PT, this message translates to:
  /// **'Escolha a moeda em que pretende ver os valores na aplicação.'**
  String get settingsDisplayCurrencyDescription;

  /// No description provided for @settingsCurrencyCve.
  ///
  /// In pt_PT, this message translates to:
  /// **'Escudo cabo-verdiano (CVE)'**
  String get settingsCurrencyCve;

  /// No description provided for @settingsCurrencyEur.
  ///
  /// In pt_PT, this message translates to:
  /// **'Euro (€)'**
  String get settingsCurrencyEur;

  /// No description provided for @settingsCurrencyUsd.
  ///
  /// In pt_PT, this message translates to:
  /// **'Dólar americano (USD)'**
  String get settingsCurrencyUsd;

  /// No description provided for @settingsAccountSection.
  ///
  /// In pt_PT, this message translates to:
  /// **'Conta'**
  String get settingsAccountSection;

  /// No description provided for @settingsChangePassword.
  ///
  /// In pt_PT, this message translates to:
  /// **'Alterar palavra-passe'**
  String get settingsChangePassword;

  /// No description provided for @settingsSignOutAction.
  ///
  /// In pt_PT, this message translates to:
  /// **'Terminar sessão'**
  String get settingsSignOutAction;

  /// No description provided for @settingsSignOutLoading.
  ///
  /// In pt_PT, this message translates to:
  /// **'A terminar sessão...'**
  String get settingsSignOutLoading;

  /// No description provided for @settingsDeveloperSection.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ferramentas de desenvolvedor'**
  String get settingsDeveloperSection;

  /// No description provided for @settingsDriverLocationSimulationTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Simulação de localização (demo)'**
  String get settingsDriverLocationSimulationTitle;

  /// No description provided for @settingsDriverLocationSimulationDescription.
  ///
  /// In pt_PT, this message translates to:
  /// **'Disponível apenas em builds de desenvolvimento. No dispositivo do motorista, publica movimento simulado em direção à recolha na viagem ativa, sem marcar chegada automaticamente.'**
  String get settingsDriverLocationSimulationDescription;

  /// No description provided for @settingsDriverLocationSimulationSwitchLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Simular movimento do motorista'**
  String get settingsDriverLocationSimulationSwitchLabel;

  /// No description provided for @settingsResetOnboarding.
  ///
  /// In pt_PT, this message translates to:
  /// **'Repor onboarding'**
  String get settingsResetOnboarding;

  /// No description provided for @settingsResetDone.
  ///
  /// In pt_PT, this message translates to:
  /// **'Onboarding reposto.'**
  String get settingsResetDone;

  /// No description provided for @settingsDeveloperDebugOnly.
  ///
  /// In pt_PT, this message translates to:
  /// **'Secção visível apenas em builds de debug.'**
  String get settingsDeveloperDebugOnly;

  /// No description provided for @profileTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @profileDefaultUserName.
  ///
  /// In pt_PT, this message translates to:
  /// **'Utilizador'**
  String get profileDefaultUserName;

  /// No description provided for @profileSessionNotFound.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sessão não encontrada. Inicie sessão novamente.'**
  String get profileSessionNotFound;

  /// No description provided for @profileLoadFailed.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não foi possível carregar o perfil. Tente novamente.'**
  String get profileLoadFailed;

  /// No description provided for @profileRoleClient.
  ///
  /// In pt_PT, this message translates to:
  /// **'Utilizador'**
  String get profileRoleClient;

  /// No description provided for @profileRoleDriver.
  ///
  /// In pt_PT, this message translates to:
  /// **'Motorista'**
  String get profileRoleDriver;

  /// No description provided for @profileRoleAdmin.
  ///
  /// In pt_PT, this message translates to:
  /// **'Administrador'**
  String get profileRoleAdmin;

  /// No description provided for @profilePhone.
  ///
  /// In pt_PT, this message translates to:
  /// **'Telefone'**
  String get profilePhone;

  /// No description provided for @profilePhoneNotSet.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não definido'**
  String get profilePhoneNotSet;

  /// No description provided for @profileAccountType.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tipo de conta'**
  String get profileAccountType;

  /// No description provided for @profileStatus.
  ///
  /// In pt_PT, this message translates to:
  /// **'Estado'**
  String get profileStatus;

  /// No description provided for @profileStatusActive.
  ///
  /// In pt_PT, this message translates to:
  /// **'Activa'**
  String get profileStatusActive;

  /// No description provided for @profileStatusInactive.
  ///
  /// In pt_PT, this message translates to:
  /// **'Inactiva'**
  String get profileStatusInactive;

  /// No description provided for @profileMenuSettings.
  ///
  /// In pt_PT, this message translates to:
  /// **'Definições'**
  String get profileMenuSettings;

  /// No description provided for @profileSessionSection.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sessão'**
  String get profileSessionSection;

  /// No description provided for @profileGoToLogin.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ir para o login'**
  String get profileGoToLogin;

  /// No description provided for @profileChangePhoto.
  ///
  /// In pt_PT, this message translates to:
  /// **'Alterar foto de perfil'**
  String get profileChangePhoto;

  /// No description provided for @profilePhotoFromGallery.
  ///
  /// In pt_PT, this message translates to:
  /// **'Escolher da galeria'**
  String get profilePhotoFromGallery;

  /// No description provided for @profilePhotoTakePhoto.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tirar foto'**
  String get profilePhotoTakePhoto;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In pt_PT, this message translates to:
  /// **'Foto de perfil actualizada'**
  String get profilePhotoUpdated;

  /// No description provided for @profilePhotoUpdateFailed.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não foi possível actualizar a foto. Tente novamente.'**
  String get profilePhotoUpdateFailed;

  /// No description provided for @profilePhotoPermissionDenied.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sem permissão para enviar a foto. Contacte o suporte se o problema persistir.'**
  String get profilePhotoPermissionDenied;

  /// No description provided for @profilePhotoUploading.
  ///
  /// In pt_PT, this message translates to:
  /// **'A enviar foto...'**
  String get profilePhotoUploading;

  /// No description provided for @profileEditName.
  ///
  /// In pt_PT, this message translates to:
  /// **'Editar nome'**
  String get profileEditName;

  /// No description provided for @profileNameHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'O seu nome'**
  String get profileNameHint;

  /// No description provided for @profileNameUpdated.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nome atualizado'**
  String get profileNameUpdated;

  /// No description provided for @profileNameUpdateFailed.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não foi possível atualizar o nome. Tente novamente.'**
  String get profileNameUpdateFailed;

  /// No description provided for @profileNamePermissionDenied.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não foi possível actualizar o nome. Verifique a sua sessão ou contacte o suporte.'**
  String get profileNamePermissionDenied;

  /// No description provided for @profileNameEmpty.
  ///
  /// In pt_PT, this message translates to:
  /// **'Introduza o seu nome.'**
  String get profileNameEmpty;

  /// No description provided for @homeAvailableBalance.
  ///
  /// In pt_PT, this message translates to:
  /// **'Saldo Disponível'**
  String get homeAvailableBalance;

  /// No description provided for @homeTopUp.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ver saldo'**
  String get homeTopUp;

  /// No description provided for @homeActionRequest.
  ///
  /// In pt_PT, this message translates to:
  /// **'Pedir'**
  String get homeActionRequest;

  /// No description provided for @homeActionBook.
  ///
  /// In pt_PT, this message translates to:
  /// **'Reservar'**
  String get homeActionBook;

  /// No description provided for @homeActionRent.
  ///
  /// In pt_PT, this message translates to:
  /// **'Alugar'**
  String get homeActionRent;

  /// No description provided for @homeActionHistory.
  ///
  /// In pt_PT, this message translates to:
  /// **'Histórico'**
  String get homeActionHistory;

  /// No description provided for @homeActionBalance.
  ///
  /// In pt_PT, this message translates to:
  /// **'Saldo'**
  String get homeActionBalance;

  /// No description provided for @clientBalanceTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Saldo'**
  String get clientBalanceTitle;

  /// No description provided for @clientBalanceSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Saldo da sua conta actualizado em tempo real.'**
  String get clientBalanceSubtitle;

  /// No description provided for @clientBalanceDebtLimit.
  ///
  /// In pt_PT, this message translates to:
  /// **'Limite de dívida'**
  String get clientBalanceDebtLimit;

  /// No description provided for @clientBalanceLastUpdated.
  ///
  /// In pt_PT, this message translates to:
  /// **'Última atualização'**
  String get clientBalanceLastUpdated;

  /// No description provided for @clientBalanceHistoryTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ajustes recentes'**
  String get clientBalanceHistoryTitle;

  /// No description provided for @clientBalanceHistoryEmpty.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ainda sem ajustes'**
  String get clientBalanceHistoryEmpty;

  /// No description provided for @clientBalanceHistoryEmptyBody.
  ///
  /// In pt_PT, this message translates to:
  /// **'Alterações de saldo feitas pelo admin aparecem aqui.'**
  String get clientBalanceHistoryEmptyBody;

  /// No description provided for @clientBalanceAdjustmentDefault.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ajuste de saldo'**
  String get clientBalanceAdjustmentDefault;

  /// No description provided for @clientBalanceDebtWarningTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Limite de dívida atingido'**
  String get clientBalanceDebtWarningTitle;

  /// No description provided for @clientBalanceDebtWarningBody.
  ///
  /// In pt_PT, this message translates to:
  /// **'Contacte o suporte para carregar o saldo e continuar a pedir viagens.'**
  String get clientBalanceDebtWarningBody;

  /// No description provided for @clientBalanceTopUpTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Como carregar'**
  String get clientBalanceTopUpTitle;

  /// No description provided for @clientBalanceTopUpBody.
  ///
  /// In pt_PT, this message translates to:
  /// **'O carregamento do saldo é gerido pelo suporte. Ligue para pedir crédito — aparecerá aqui após aprovação do administrador.'**
  String get clientBalanceTopUpBody;

  /// No description provided for @clientBalanceContactSupport.
  ///
  /// In pt_PT, this message translates to:
  /// **'Contactar suporte'**
  String get clientBalanceContactSupport;

  /// No description provided for @clientBalanceSupportUnavailable.
  ///
  /// In pt_PT, this message translates to:
  /// **'Telefone de suporte indisponível. Contacte a equipa de apoio.'**
  String get clientBalanceSupportUnavailable;

  /// No description provided for @clientBalanceSupportCallFailed.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não foi possível abrir o marcador telefónico neste dispositivo.'**
  String get clientBalanceSupportCallFailed;

  /// No description provided for @tripConfirmLimitExceededCallSupport.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ligar para suporte'**
  String get tripConfirmLimitExceededCallSupport;

  /// No description provided for @clientBalanceUnavailable.
  ///
  /// In pt_PT, this message translates to:
  /// **'Saldo indisponível'**
  String get clientBalanceUnavailable;

  /// No description provided for @homeWhereToday.
  ///
  /// In pt_PT, this message translates to:
  /// **'Para onde vamos hoje?'**
  String get homeWhereToday;

  /// No description provided for @homeCurrentLocation.
  ///
  /// In pt_PT, this message translates to:
  /// **'Localização Atual'**
  String get homeCurrentLocation;

  /// No description provided for @homeDestination.
  ///
  /// In pt_PT, this message translates to:
  /// **'Destino'**
  String get homeDestination;

  /// No description provided for @homeDestinationHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'Para onde deseja ir?'**
  String get homeDestinationHint;

  /// No description provided for @homeConfirmRoute.
  ///
  /// In pt_PT, this message translates to:
  /// **'Confirmar Trajeto'**
  String get homeConfirmRoute;

  /// No description provided for @homeLocationLoading.
  ///
  /// In pt_PT, this message translates to:
  /// **'A obter a sua localização...'**
  String get homeLocationLoading;

  /// No description provided for @homeLocationUnavailable.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não foi possível obter a localização'**
  String get homeLocationUnavailable;

  /// No description provided for @homeRefreshLocation.
  ///
  /// In pt_PT, this message translates to:
  /// **'Atualizar localização'**
  String get homeRefreshLocation;

  /// No description provided for @homeSelectLocationOnMap.
  ///
  /// In pt_PT, this message translates to:
  /// **'Selecionar no mapa'**
  String get homeSelectLocationOnMap;

  /// No description provided for @homeSelectLocationOnMapHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'Mova o mapa ou toque no botão de localização para usar a posição atual.'**
  String get homeSelectLocationOnMapHint;

  /// No description provided for @homeUseMapLocation.
  ///
  /// In pt_PT, this message translates to:
  /// **'Usar esta localização'**
  String get homeUseMapLocation;

  /// No description provided for @homeLocationPermissionTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Permitir localização'**
  String get homeLocationPermissionTitle;

  /// No description provided for @homeLocationPermissionMessage.
  ///
  /// In pt_PT, this message translates to:
  /// **'O Local Transport precisa da sua localização para definir automaticamente o ponto de recolha.'**
  String get homeLocationPermissionMessage;

  /// No description provided for @homeLocationPermissionAllow.
  ///
  /// In pt_PT, this message translates to:
  /// **'Permitir'**
  String get homeLocationPermissionAllow;

  /// No description provided for @homeLocationPermissionDeny.
  ///
  /// In pt_PT, this message translates to:
  /// **'Agora não'**
  String get homeLocationPermissionDeny;

  /// No description provided for @homeLocationPermissionSettingsMessage.
  ///
  /// In pt_PT, this message translates to:
  /// **'A permissão de localização está desativada. Abra as definições para permitir o acesso.'**
  String get homeLocationPermissionSettingsMessage;

  /// No description provided for @homeLocationOpenSettings.
  ///
  /// In pt_PT, this message translates to:
  /// **'Abrir definições'**
  String get homeLocationOpenSettings;

  /// No description provided for @homeLocationServicesDisabled.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ative os serviços de localização no dispositivo para usar o seu endereço atual.'**
  String get homeLocationServicesDisabled;

  /// No description provided for @reservationsTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Reservas'**
  String get reservationsTitle;

  /// No description provided for @reservationsSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Gerencie as suas próximas viagens'**
  String get reservationsSubtitle;

  /// No description provided for @reservationsNew.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nova reserva'**
  String get reservationsNew;

  /// No description provided for @reservationsPickup.
  ///
  /// In pt_PT, this message translates to:
  /// **'Recolha'**
  String get reservationsPickup;

  /// No description provided for @reservationsDestination.
  ///
  /// In pt_PT, this message translates to:
  /// **'Destino'**
  String get reservationsDestination;

  /// No description provided for @reservationsDetails.
  ///
  /// In pt_PT, this message translates to:
  /// **'Detalhes'**
  String get reservationsDetails;

  /// No description provided for @reservationsCancel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Cancelar'**
  String get reservationsCancel;

  /// No description provided for @reservationsStatusConfirmed.
  ///
  /// In pt_PT, this message translates to:
  /// **'Confirmada'**
  String get reservationsStatusConfirmed;

  /// No description provided for @reservationsStatusPending.
  ///
  /// In pt_PT, this message translates to:
  /// **'Pendente'**
  String get reservationsStatusPending;

  /// No description provided for @tripHistoryTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Histórico de Viagens'**
  String get tripHistoryTitle;

  /// No description provided for @tripHistoryDetails.
  ///
  /// In pt_PT, this message translates to:
  /// **'Detalhes'**
  String get tripHistoryDetails;

  /// No description provided for @tripDetailsSummary.
  ///
  /// In pt_PT, this message translates to:
  /// **'Resumo da Viagem'**
  String get tripDetailsSummary;

  /// No description provided for @tripDetailsStatusCompleted.
  ///
  /// In pt_PT, this message translates to:
  /// **'Concluída'**
  String get tripDetailsStatusCompleted;

  /// No description provided for @rentalTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Aluguer de Veículos'**
  String get rentalTitle;

  /// No description provided for @rentalSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Encontre o parceiro perfeito para a sua próxima viagem.'**
  String get rentalSubtitle;

  /// No description provided for @rentalSearchAvailable.
  ///
  /// In pt_PT, this message translates to:
  /// **'Pesquisar Veículos Disponíveis'**
  String get rentalSearchAvailable;

  /// No description provided for @driverSearchTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'A procurar motorista disponível'**
  String get driverSearchTitle;

  /// No description provided for @driverFoundTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Motorista encontrado'**
  String get driverFoundTitle;

  /// No description provided for @driverEnRouteStatus.
  ///
  /// In pt_PT, this message translates to:
  /// **'Motorista a caminho'**
  String get driverEnRouteStatus;

  /// No description provided for @tripInProgressEndTrip.
  ///
  /// In pt_PT, this message translates to:
  /// **'Terminar Viagem'**
  String get tripInProgressEndTrip;

  /// No description provided for @tripInProgressSupport.
  ///
  /// In pt_PT, this message translates to:
  /// **'Suporte'**
  String get tripInProgressSupport;

  /// No description provided for @tripCompletedTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Viagem Concluída!'**
  String get tripCompletedTitle;

  /// No description provided for @tripCompletedBackHome.
  ///
  /// In pt_PT, this message translates to:
  /// **'Voltar ao início'**
  String get tripCompletedBackHome;

  /// No description provided for @premiumHomeOrderNow.
  ///
  /// In pt_PT, this message translates to:
  /// **'Pedir agora'**
  String get premiumHomeOrderNow;

  /// No description provided for @support.
  ///
  /// In pt_PT, this message translates to:
  /// **'Suporte'**
  String get support;

  /// No description provided for @destination.
  ///
  /// In pt_PT, this message translates to:
  /// **'Destino'**
  String get destination;

  /// No description provided for @details.
  ///
  /// In pt_PT, this message translates to:
  /// **'Detalhes'**
  String get details;

  /// No description provided for @premiumMobility.
  ///
  /// In pt_PT, this message translates to:
  /// **'Local Transport'**
  String get premiumMobility;

  /// No description provided for @seeAll.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ver todos'**
  String get seeAll;

  /// No description provided for @edit.
  ///
  /// In pt_PT, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @total.
  ///
  /// In pt_PT, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @subtotal.
  ///
  /// In pt_PT, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @quantity.
  ///
  /// In pt_PT, this message translates to:
  /// **'Quantidade'**
  String get quantity;

  /// No description provided for @distance.
  ///
  /// In pt_PT, this message translates to:
  /// **'Distância'**
  String get distance;

  /// No description provided for @duration.
  ///
  /// In pt_PT, this message translates to:
  /// **'Duração'**
  String get duration;

  /// No description provided for @premium.
  ///
  /// In pt_PT, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @newBadge.
  ///
  /// In pt_PT, this message translates to:
  /// **'Novo'**
  String get newBadge;

  /// No description provided for @promotion.
  ///
  /// In pt_PT, this message translates to:
  /// **'Promoção'**
  String get promotion;

  /// No description provided for @free.
  ///
  /// In pt_PT, this message translates to:
  /// **'Grátis'**
  String get free;

  /// No description provided for @live.
  ///
  /// In pt_PT, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @verified.
  ///
  /// In pt_PT, this message translates to:
  /// **'Verificado'**
  String get verified;

  /// No description provided for @createAccount.
  ///
  /// In pt_PT, this message translates to:
  /// **'Criar conta'**
  String get createAccount;

  /// No description provided for @splashSecureConnection.
  ///
  /// In pt_PT, this message translates to:
  /// **'Conexão Segura & Encriptada'**
  String get splashSecureConnection;

  /// No description provided for @splashExecutiveBadge.
  ///
  /// In pt_PT, this message translates to:
  /// **'EXECUTIVO'**
  String get splashExecutiveBadge;

  /// No description provided for @splashHeroTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'O seu tempo,\nvalorizado.'**
  String get splashHeroTitle;

  /// No description provided for @splashHeroSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Transporte personalizado com conforto e pontualidade.'**
  String get splashHeroSubtitle;

  /// No description provided for @splashInstantBookingTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Reservas Instantâneas'**
  String get splashInstantBookingTitle;

  /// No description provided for @splashInstantBookingSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Planeie a sua viagem em segundos com a nossa rede exclusiva.'**
  String get splashInstantBookingSubtitle;

  /// No description provided for @splashDriverOfToday.
  ///
  /// In pt_PT, this message translates to:
  /// **'MOTORISTA DE HOJE'**
  String get splashDriverOfToday;

  /// No description provided for @adminAppBarTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Local Transport'**
  String get adminAppBarTitle;

  /// No description provided for @adminFleetStatusTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Estado da Frota'**
  String get adminFleetStatusTitle;

  /// No description provided for @adminFleetStatusUpdated.
  ///
  /// In pt_PT, this message translates to:
  /// **'Atualizado: Agora'**
  String get adminFleetStatusUpdated;

  /// No description provided for @adminFleetStatusUpdatedAt.
  ///
  /// In pt_PT, this message translates to:
  /// **'Atualizado: {time}'**
  String adminFleetStatusUpdatedAt(String time);

  /// No description provided for @adminActiveTripsLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Viagens Ativas'**
  String get adminActiveTripsLabel;

  /// No description provided for @adminActiveTripsTrend.
  ///
  /// In pt_PT, this message translates to:
  /// **'+12% vs. ontem'**
  String get adminActiveTripsTrend;

  /// No description provided for @adminAvailableDriversLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Motoristas Disponíveis'**
  String get adminAvailableDriversLabel;

  /// No description provided for @adminAvailableDriversHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'Pronto para despacho'**
  String get adminAvailableDriversHint;

  /// No description provided for @adminCriticalOpsTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Operações Críticas'**
  String get adminCriticalOpsTitle;

  /// No description provided for @adminPendingDebtorsTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Devedores Pendentes'**
  String get adminPendingDebtorsTitle;

  /// No description provided for @adminPendingDebtorsSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'3 faturas em atraso'**
  String get adminPendingDebtorsSubtitle;

  /// No description provided for @adminPendingDebtorsCount.
  ///
  /// In pt_PT, this message translates to:
  /// **'{count} faturas em atraso'**
  String adminPendingDebtorsCount(int count);

  /// No description provided for @adminActiveTripsTrendDynamic.
  ///
  /// In pt_PT, this message translates to:
  /// **'{change} vs. ontem'**
  String adminActiveTripsTrendDynamic(String change);

  /// No description provided for @adminNoFleetVehicles.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ainda sem viaturas na frota'**
  String get adminNoFleetVehicles;

  /// No description provided for @adminNoReportActivities.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ainda sem viagens concluídas'**
  String get adminNoReportActivities;

  /// No description provided for @adminBaseRateLive.
  ///
  /// In pt_PT, this message translates to:
  /// **'Dinâmica: Ativa ({multiplier})'**
  String adminBaseRateLive(String multiplier);

  /// No description provided for @adminMonthlyReportsTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Relatórios Mensais'**
  String get adminMonthlyReportsTitle;

  /// No description provided for @adminMonthlyReportsSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Performance de Outubro'**
  String get adminMonthlyReportsSubtitle;

  /// No description provided for @adminActivityMapTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Mapa de Atividade'**
  String get adminActivityMapTitle;

  /// No description provided for @adminActivityMapWaiting.
  ///
  /// In pt_PT, this message translates to:
  /// **'À espera de viagens e localizações em tempo real'**
  String get adminActivityMapWaiting;

  /// No description provided for @adminRatesTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tarifas & Mercado'**
  String get adminRatesTitle;

  /// No description provided for @adminBaseRateLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tarifa Base'**
  String get adminBaseRateLabel;

  /// No description provided for @adminBaseRateDynamic.
  ///
  /// In pt_PT, this message translates to:
  /// **'Dinâmica: Ativa (1.2x)'**
  String get adminBaseRateDynamic;

  /// No description provided for @adminFuelCostLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Custo Combustível'**
  String get adminFuelCostLabel;

  /// No description provided for @adminFuelCostHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'Média Nacional'**
  String get adminFuelCostHint;

  /// No description provided for @adminRecentFleetTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Frota Recente'**
  String get adminRecentFleetTitle;

  /// No description provided for @adminFleetStatusOnTrip.
  ///
  /// In pt_PT, this message translates to:
  /// **'Em Viagem'**
  String get adminFleetStatusOnTrip;

  /// No description provided for @adminFleetStatusInactive.
  ///
  /// In pt_PT, this message translates to:
  /// **'Inativo'**
  String get adminFleetStatusInactive;

  /// No description provided for @adminFleetDriverPrefix.
  ///
  /// In pt_PT, this message translates to:
  /// **'Motorista: {name}'**
  String adminFleetDriverPrefix(String name);

  /// No description provided for @adminHubTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Área de administração'**
  String get adminHubTitle;

  /// No description provided for @adminHubHeading.
  ///
  /// In pt_PT, this message translates to:
  /// **'Área de administração'**
  String get adminHubHeading;

  /// No description provided for @adminHubSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Gerir operações, frota, tarifas e suporte.'**
  String get adminHubSubtitle;

  /// No description provided for @adminUsersTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Utilizadores'**
  String get adminUsersTitle;

  /// No description provided for @adminUsersDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Gestão de contas e permissões.'**
  String get adminUsersDesc;

  /// No description provided for @adminUsersHeading.
  ///
  /// In pt_PT, this message translates to:
  /// **'Gestão de contas e permissões'**
  String get adminUsersHeading;

  /// No description provided for @adminUsersSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Gerir perfis, funções e acessos da equipa.'**
  String get adminUsersSubtitle;

  /// No description provided for @adminUsersSearchHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'Pesquisar por nome, email, telefone ou ID'**
  String get adminUsersSearchHint;

  /// No description provided for @adminUsersEmpty.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nenhum utilizador encontrado'**
  String get adminUsersEmpty;

  /// No description provided for @adminUsersCreateTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Adicionar utilizador'**
  String get adminUsersCreateTitle;

  /// No description provided for @adminUsersCreateSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Criar conta de cliente, motorista, gestor ou admin.'**
  String get adminUsersCreateSubtitle;

  /// No description provided for @adminUsersCreateAction.
  ///
  /// In pt_PT, this message translates to:
  /// **'Criar utilizador'**
  String get adminUsersCreateAction;

  /// No description provided for @adminUsersCreateSuccess.
  ///
  /// In pt_PT, this message translates to:
  /// **'Utilizador criado com sucesso'**
  String get adminUsersCreateSuccess;

  /// No description provided for @adminUsersCreateFailed.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não foi possível criar o utilizador'**
  String get adminUsersCreateFailed;

  /// No description provided for @adminUsersRoleLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Função'**
  String get adminUsersRoleLabel;

  /// No description provided for @adminUsersAddTooltip.
  ///
  /// In pt_PT, this message translates to:
  /// **'Adicionar utilizador'**
  String get adminUsersAddTooltip;

  /// No description provided for @adminStatusActive.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ativo'**
  String get adminStatusActive;

  /// No description provided for @adminStatusInactive.
  ///
  /// In pt_PT, this message translates to:
  /// **'Inativo'**
  String get adminStatusInactive;

  /// No description provided for @adminStatusOpen.
  ///
  /// In pt_PT, this message translates to:
  /// **'Aberto'**
  String get adminStatusOpen;

  /// No description provided for @adminStatusResolved.
  ///
  /// In pt_PT, this message translates to:
  /// **'Resolvido'**
  String get adminStatusResolved;

  /// No description provided for @adminStatusConfigured.
  ///
  /// In pt_PT, this message translates to:
  /// **'Configurado'**
  String get adminStatusConfigured;

  /// No description provided for @adminManagerPermissionsTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Permissões de gestor'**
  String get adminManagerPermissionsTitle;

  /// No description provided for @adminManagerPermissionsDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Configurar permissões operacionais por gestor.'**
  String get adminManagerPermissionsDesc;

  /// No description provided for @adminManagerPermissionsHeading.
  ///
  /// In pt_PT, this message translates to:
  /// **'Configuração de permissões operacionais'**
  String get adminManagerPermissionsHeading;

  /// No description provided for @adminManagerPermissionsSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Configure, por gestor, os módulos e ações permitidas.'**
  String get adminManagerPermissionsSubtitle;

  /// No description provided for @adminManagersEmpty.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nenhum gestor encontrado'**
  String get adminManagersEmpty;

  /// No description provided for @adminStatusUnconfigured.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não configurado'**
  String get adminStatusUnconfigured;

  /// No description provided for @adminManagerPermissionsSaveAction.
  ///
  /// In pt_PT, this message translates to:
  /// **'Guardar permissões'**
  String get adminManagerPermissionsSaveAction;

  /// No description provided for @adminManagerPermissionsSaveSuccess.
  ///
  /// In pt_PT, this message translates to:
  /// **'Permissões do gestor guardadas'**
  String get adminManagerPermissionsSaveSuccess;

  /// No description provided for @adminManagerPermissionsSaveError.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não foi possível guardar as permissões'**
  String get adminManagerPermissionsSaveError;

  /// No description provided for @managerPermissionViewTrips.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ver viagens'**
  String get managerPermissionViewTrips;

  /// No description provided for @managerPermissionViewReports.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ver relatórios'**
  String get managerPermissionViewReports;

  /// No description provided for @managerPermissionViewAudit.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ver auditoria'**
  String get managerPermissionViewAudit;

  /// No description provided for @managerPermissionViewDrivers.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ver motoristas'**
  String get managerPermissionViewDrivers;

  /// No description provided for @managerPermissionViewClients.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ver clientes'**
  String get managerPermissionViewClients;

  /// No description provided for @managerPermissionViewSupportRequests.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ver pedidos de suporte'**
  String get managerPermissionViewSupportRequests;

  /// No description provided for @managerPermissionManageClientChats.
  ///
  /// In pt_PT, this message translates to:
  /// **'Gerir conversas de clientes'**
  String get managerPermissionManageClientChats;

  /// No description provided for @managerPermissionCancelTripBySupport.
  ///
  /// In pt_PT, this message translates to:
  /// **'Cancelar viagem por suporte'**
  String get managerPermissionCancelTripBySupport;

  /// No description provided for @managerPermissionUpdateTripSupport.
  ///
  /// In pt_PT, this message translates to:
  /// **'Atualizar suporte da viagem'**
  String get managerPermissionUpdateTripSupport;

  /// No description provided for @managerPermissionResolvePasswordHelpRequest.
  ///
  /// In pt_PT, this message translates to:
  /// **'Resolver pedidos de ajuda de password'**
  String get managerPermissionResolvePasswordHelpRequest;

  /// No description provided for @managerPermissionManageEvents.
  ///
  /// In pt_PT, this message translates to:
  /// **'Gerir eventos'**
  String get managerPermissionManageEvents;

  /// No description provided for @managerPermissionAssignVehicleToDriver.
  ///
  /// In pt_PT, this message translates to:
  /// **'Atribuir veículo'**
  String get managerPermissionAssignVehicleToDriver;

  /// No description provided for @managerPermissionEditDriverStatus.
  ///
  /// In pt_PT, this message translates to:
  /// **'Editar estado do motorista'**
  String get managerPermissionEditDriverStatus;

  /// No description provided for @managerPermissionManageTariffs.
  ///
  /// In pt_PT, this message translates to:
  /// **'Gerir tarifas'**
  String get managerPermissionManageTariffs;

  /// No description provided for @managerPermissionManageTripPackages.
  ///
  /// In pt_PT, this message translates to:
  /// **'Gerir pacotes de viagem'**
  String get managerPermissionManageTripPackages;

  /// No description provided for @adminSupportRequestsTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Pedidos de suporte'**
  String get adminSupportRequestsTitle;

  /// No description provided for @adminSupportRequestsDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Caixa de entrada de suporte e ajuda de password.'**
  String get adminSupportRequestsDesc;

  /// No description provided for @adminSupportEmpty.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sem pedidos de suporte'**
  String get adminSupportEmpty;

  /// No description provided for @adminIncidentsTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Incidentes operacionais'**
  String get adminIncidentsTitle;

  /// No description provided for @adminIncidentsDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Incidentes de monitorização e aprovações.'**
  String get adminIncidentsDesc;

  /// No description provided for @adminIncidentsEmpty.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sem incidentes operacionais'**
  String get adminIncidentsEmpty;

  /// No description provided for @adminIncidentDetailTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Detalhes do incidente'**
  String get adminIncidentDetailTitle;

  /// No description provided for @adminIncidentCurrentState.
  ///
  /// In pt_PT, this message translates to:
  /// **'Estado atual'**
  String get adminIncidentCurrentState;

  /// No description provided for @adminIncidentTrip.
  ///
  /// In pt_PT, this message translates to:
  /// **'Viagem'**
  String get adminIncidentTrip;

  /// No description provided for @adminIncidentStarted.
  ///
  /// In pt_PT, this message translates to:
  /// **'Iniciado'**
  String get adminIncidentStarted;

  /// No description provided for @adminIncidentRouteSummary.
  ///
  /// In pt_PT, this message translates to:
  /// **'Resumo da rota'**
  String get adminIncidentRouteSummary;

  /// No description provided for @adminIncidentKmSummary.
  ///
  /// In pt_PT, this message translates to:
  /// **'Resumo de km'**
  String get adminIncidentKmSummary;

  /// No description provided for @adminMonitoringTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Definições de monitorização'**
  String get adminMonitoringTitle;

  /// No description provided for @adminMonitoringDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Limites para monitorização operacional.'**
  String get adminMonitoringDesc;

  /// No description provided for @adminMonitoringHeading.
  ///
  /// In pt_PT, this message translates to:
  /// **'Monitorização operacional'**
  String get adminMonitoringHeading;

  /// No description provided for @adminMonitoringSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Rever limites de monitorização operacional.'**
  String get adminMonitoringSubtitle;

  /// No description provided for @adminMonitoringConfig.
  ///
  /// In pt_PT, this message translates to:
  /// **'Configuração atual'**
  String get adminMonitoringConfig;

  /// No description provided for @adminMonitoringLoading.
  ///
  /// In pt_PT, this message translates to:
  /// **'A carregar configuração de monitorização...'**
  String get adminMonitoringLoading;

  /// No description provided for @adminMonitoringEnabled.
  ///
  /// In pt_PT, this message translates to:
  /// **'Monitorização ativa'**
  String get adminMonitoringEnabled;

  /// No description provided for @adminMonitoringEnabledHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'A monitorização operacional só corre quando está ativa.'**
  String get adminMonitoringEnabledHint;

  /// No description provided for @adminMonitoringBaseGeofence.
  ///
  /// In pt_PT, this message translates to:
  /// **'Geofence base'**
  String get adminMonitoringBaseGeofence;

  /// No description provided for @adminMonitoringServiceGeofences.
  ///
  /// In pt_PT, this message translates to:
  /// **'Geofences de serviço'**
  String get adminMonitoringServiceGeofences;

  /// No description provided for @adminMonitoringServiceGeofenceCount.
  ///
  /// In pt_PT, this message translates to:
  /// **'{count} configuradas'**
  String adminMonitoringServiceGeofenceCount(int count);

  /// No description provided for @adminMonitoringLastUpdated.
  ///
  /// In pt_PT, this message translates to:
  /// **'Última atualização'**
  String get adminMonitoringLastUpdated;

  /// No description provided for @adminMonitoringSaveSuccess.
  ///
  /// In pt_PT, this message translates to:
  /// **'Configuração de monitorização guardada'**
  String get adminMonitoringSaveSuccess;

  /// No description provided for @adminReservationsTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Reservas operacionais'**
  String get adminReservationsTitle;

  /// No description provided for @adminReservationsDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Agendar viagens futuras para clientes.'**
  String get adminReservationsDesc;

  /// No description provided for @adminReservationsEmpty.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sem reservas'**
  String get adminReservationsEmpty;

  /// No description provided for @adminSupportSettingsTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Contacto de suporte'**
  String get adminSupportSettingsTitle;

  /// No description provided for @adminSupportSettingsDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Telefone oficial para recuperação de password.'**
  String get adminSupportSettingsDesc;

  /// No description provided for @adminSupportSettingsHeading.
  ///
  /// In pt_PT, this message translates to:
  /// **'Contacto de suporte'**
  String get adminSupportSettingsHeading;

  /// No description provided for @adminSupportSettingsSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Definir o número oficial de contacto.'**
  String get adminSupportSettingsSubtitle;

  /// No description provided for @adminSupportPhoneLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Telefone de suporte'**
  String get adminSupportPhoneLabel;

  /// No description provided for @adminEventsTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Eventos e alertas'**
  String get adminEventsTitle;

  /// No description provided for @adminEventsDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Enviar lembretes e avisos aos motoristas.'**
  String get adminEventsDesc;

  /// No description provided for @adminEventsEmpty.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sem eventos agendados'**
  String get adminEventsEmpty;

  /// No description provided for @adminFleetTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Frota'**
  String get adminFleetTitle;

  /// No description provided for @adminFleetDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Acompanhar viaturas, estado e disponibilidade.'**
  String get adminFleetDesc;

  /// No description provided for @adminFleetNoDriver.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sem motorista atribuído'**
  String get adminFleetNoDriver;

  /// No description provided for @adminFleetDriver.
  ///
  /// In pt_PT, this message translates to:
  /// **'Motorista'**
  String get adminFleetDriver;

  /// No description provided for @adminFleetAssignDriverTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Atribuir motorista'**
  String get adminFleetAssignDriverTitle;

  /// No description provided for @adminFleetAssignDriverDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Selecione um motorista para esta viatura.'**
  String get adminFleetAssignDriverDesc;

  /// No description provided for @adminFleetAssignDriverEmpty.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nenhum motorista ativo encontrado.'**
  String get adminFleetAssignDriverEmpty;

  /// No description provided for @adminFleetAssignDriverSuccess.
  ///
  /// In pt_PT, this message translates to:
  /// **'Motorista atribuído com sucesso.'**
  String get adminFleetAssignDriverSuccess;

  /// No description provided for @adminTransportTypesTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tipos de transporte'**
  String get adminTransportTypesTitle;

  /// No description provided for @adminTransportTypesDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Criar e gerir tipos disponíveis.'**
  String get adminTransportTypesDesc;

  /// No description provided for @adminTransportTypesEmpty.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sem tipos de transporte'**
  String get adminTransportTypesEmpty;

  /// No description provided for @adminTripPackagesTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Pacotes de viagem'**
  String get adminTripPackagesTitle;

  /// No description provided for @adminTripPackagesDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Pacotes pré-pagos com destino e preço fixos.'**
  String get adminTripPackagesDesc;

  /// No description provided for @adminTripPackagesEmpty.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sem pacotes de viagem'**
  String get adminTripPackagesEmpty;

  /// No description provided for @adminTariffsTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tarifas'**
  String get adminTariffsTitle;

  /// No description provided for @adminTariffsDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Definir preços, regras e ajustes sazonais.'**
  String get adminTariffsDesc;

  /// No description provided for @adminTariffAdminDefault.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tarifa admin default'**
  String get adminTariffAdminDefault;

  /// No description provided for @adminTariffPublicDefault.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tarifa public default'**
  String get adminTariffPublicDefault;

  /// No description provided for @adminBalancesTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Gerir saldos'**
  String get adminBalancesTitle;

  /// No description provided for @adminBalancesDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ver, adicionar, remover e definir saldos dos clientes.'**
  String get adminBalancesDesc;

  /// No description provided for @adminBalancesEmpty.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nenhum cliente encontrado'**
  String get adminBalancesEmpty;

  /// No description provided for @adminBalancesNoResults.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nenhum cliente corresponde à pesquisa.'**
  String get adminBalancesNoResults;

  /// No description provided for @adminBalancesNoBalanceDoc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sem saldo'**
  String get adminBalancesNoBalanceDoc;

  /// No description provided for @adminBalancesDebt.
  ///
  /// In pt_PT, this message translates to:
  /// **'Dívida'**
  String get adminBalancesDebt;

  /// No description provided for @adminBalancesCredit.
  ///
  /// In pt_PT, this message translates to:
  /// **'Crédito'**
  String get adminBalancesCredit;

  /// No description provided for @adminBalancesSearchHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'Pesquisar cliente...'**
  String get adminBalancesSearchHint;

  /// No description provided for @adminBalanceCurrent.
  ///
  /// In pt_PT, this message translates to:
  /// **'Saldo atual'**
  String get adminBalanceCurrent;

  /// No description provided for @adminBalanceDebtLimit.
  ///
  /// In pt_PT, this message translates to:
  /// **'Limite de dívida'**
  String get adminBalanceDebtLimit;

  /// No description provided for @adminBalanceAdjustAction.
  ///
  /// In pt_PT, this message translates to:
  /// **'Gerir saldo'**
  String get adminBalanceAdjustAction;

  /// No description provided for @adminBalanceAdjustTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Gerir saldo do cliente'**
  String get adminBalanceAdjustTitle;

  /// No description provided for @adminBalanceModeAdd.
  ///
  /// In pt_PT, this message translates to:
  /// **'Adicionar'**
  String get adminBalanceModeAdd;

  /// No description provided for @adminBalanceModeRemove.
  ///
  /// In pt_PT, this message translates to:
  /// **'Remover'**
  String get adminBalanceModeRemove;

  /// No description provided for @adminBalanceModeSet.
  ///
  /// In pt_PT, this message translates to:
  /// **'Definir'**
  String get adminBalanceModeSet;

  /// No description provided for @adminBalanceCredit.
  ///
  /// In pt_PT, this message translates to:
  /// **'Crédito'**
  String get adminBalanceCredit;

  /// No description provided for @adminBalanceDebt.
  ///
  /// In pt_PT, this message translates to:
  /// **'Débito'**
  String get adminBalanceDebt;

  /// No description provided for @adminBalanceAddAmountLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Valor a adicionar (EUR)'**
  String get adminBalanceAddAmountLabel;

  /// No description provided for @adminBalanceRemoveAmountLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Valor a remover (EUR)'**
  String get adminBalanceRemoveAmountLabel;

  /// No description provided for @adminBalanceSetAmountLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Novo saldo (EUR)'**
  String get adminBalanceSetAmountLabel;

  /// No description provided for @adminBalanceAmountLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Valor (EUR)'**
  String get adminBalanceAmountLabel;

  /// No description provided for @adminBalanceAmountRequired.
  ///
  /// In pt_PT, this message translates to:
  /// **'Introduza um valor válido.'**
  String get adminBalanceAmountRequired;

  /// No description provided for @adminBalanceReasonLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Motivo'**
  String get adminBalanceReasonLabel;

  /// No description provided for @adminBalanceReasonRequired.
  ///
  /// In pt_PT, this message translates to:
  /// **'Introduza um motivo.'**
  String get adminBalanceReasonRequired;

  /// No description provided for @adminBalanceConfirm.
  ///
  /// In pt_PT, this message translates to:
  /// **'Confirmar'**
  String get adminBalanceConfirm;

  /// No description provided for @adminBalanceAdjustSuccess.
  ///
  /// In pt_PT, this message translates to:
  /// **'Saldo atualizado'**
  String get adminBalanceAdjustSuccess;

  /// No description provided for @adminVehicleCreateTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nova viatura'**
  String get adminVehicleCreateTitle;

  /// No description provided for @adminVehicleEditTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Editar viatura'**
  String get adminVehicleEditTitle;

  /// No description provided for @adminVehicleCreateAction.
  ///
  /// In pt_PT, this message translates to:
  /// **'Criar viatura'**
  String get adminVehicleCreateAction;

  /// No description provided for @adminVehicleCreateSuccess.
  ///
  /// In pt_PT, this message translates to:
  /// **'Viatura criada'**
  String get adminVehicleCreateSuccess;

  /// No description provided for @adminVehicleAddPhoto.
  ///
  /// In pt_PT, this message translates to:
  /// **'Adicionar foto'**
  String get adminVehicleAddPhoto;

  /// No description provided for @adminVehiclePlateLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Matrícula'**
  String get adminVehiclePlateLabel;

  /// No description provided for @adminVehicleModelLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Modelo'**
  String get adminVehicleModelLabel;

  /// No description provided for @adminVehicleCapacityLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Capacidade'**
  String get adminVehicleCapacityLabel;

  /// No description provided for @adminVehicleTransportTypeLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tipo de transporte predefinido'**
  String get adminVehicleTransportTypeLabel;

  /// No description provided for @adminVehicleNoPreference.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sem preferência'**
  String get adminVehicleNoPreference;

  /// No description provided for @adminVehicleNotesLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Notas'**
  String get adminVehicleNotesLabel;

  /// No description provided for @adminVehicleActiveLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Viatura ativa'**
  String get adminVehicleActiveLabel;

  /// No description provided for @adminVehicleRequiredFields.
  ///
  /// In pt_PT, this message translates to:
  /// **'Preencha matrícula e modelo.'**
  String get adminVehicleRequiredFields;

  /// No description provided for @adminTransportTypeCreateTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Novo tipo de transporte'**
  String get adminTransportTypeCreateTitle;

  /// No description provided for @adminTransportTypeEditTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Editar tipo de transporte'**
  String get adminTransportTypeEditTitle;

  /// No description provided for @adminTransportTypeCreateAction.
  ///
  /// In pt_PT, this message translates to:
  /// **'Criar tipo'**
  String get adminTransportTypeCreateAction;

  /// No description provided for @adminTransportTypeCreateSuccess.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tipo de transporte criado'**
  String get adminTransportTypeCreateSuccess;

  /// No description provided for @adminTransportTypeNameLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nome'**
  String get adminTransportTypeNameLabel;

  /// No description provided for @adminTransportTypeNameRequired.
  ///
  /// In pt_PT, this message translates to:
  /// **'Introduza um nome.'**
  String get adminTransportTypeNameRequired;

  /// No description provided for @adminTransportTypeBaseFareLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tarifa base inicial'**
  String get adminTransportTypeBaseFareLabel;

  /// No description provided for @adminTransportTypeMultiplierLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ajuste de preço do package'**
  String get adminTransportTypeMultiplierLabel;

  /// No description provided for @adminTransportTypeDescriptionLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Descrição'**
  String get adminTransportTypeDescriptionLabel;

  /// No description provided for @adminTripPackagesOpsTab.
  ///
  /// In pt_PT, this message translates to:
  /// **'Operação'**
  String get adminTripPackagesOpsTab;

  /// No description provided for @adminTripPackagesCatalogTab.
  ///
  /// In pt_PT, this message translates to:
  /// **'Catálogo'**
  String get adminTripPackagesCatalogTab;

  /// No description provided for @adminTripPackagesOpsEmpty.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sem reservas na fila de operação.'**
  String get adminTripPackagesOpsEmpty;

  /// No description provided for @adminTripPackagesCatalogHeading.
  ///
  /// In pt_PT, this message translates to:
  /// **'Catálogo de packages'**
  String get adminTripPackagesCatalogHeading;

  /// No description provided for @adminTripPackagesCatalogSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Gerir produtos comerciais com destino fixo, preço fixo e tipos de transporte permitidos.'**
  String get adminTripPackagesCatalogSubtitle;

  /// No description provided for @adminPackageCreateTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Criar package'**
  String get adminPackageCreateTitle;

  /// No description provided for @adminPackageEditTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Editar package'**
  String get adminPackageEditTitle;

  /// No description provided for @adminPackageCreateAction.
  ///
  /// In pt_PT, this message translates to:
  /// **'Criar package'**
  String get adminPackageCreateAction;

  /// No description provided for @adminPackageEditAction.
  ///
  /// In pt_PT, this message translates to:
  /// **'Editar package'**
  String get adminPackageEditAction;

  /// No description provided for @adminPackageCreateSuccess.
  ///
  /// In pt_PT, this message translates to:
  /// **'Package guardado'**
  String get adminPackageCreateSuccess;

  /// No description provided for @adminPackageNameLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nome do package'**
  String get adminPackageNameLabel;

  /// No description provided for @adminPackageNameMin.
  ///
  /// In pt_PT, this message translates to:
  /// **'Introduza um nome com pelo menos 3 caracteres.'**
  String get adminPackageNameMin;

  /// No description provided for @adminPackageDestinationLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Destino fixo'**
  String get adminPackageDestinationLabel;

  /// No description provided for @adminPackageDescriptionLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Descrição'**
  String get adminPackageDescriptionLabel;

  /// No description provided for @adminPackageDescriptionMin.
  ///
  /// In pt_PT, this message translates to:
  /// **'Introduza uma descrição com pelo menos 10 caracteres.'**
  String get adminPackageDescriptionMin;

  /// No description provided for @adminPackagePriceLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Preço fixo (EUR)'**
  String get adminPackagePriceLabel;

  /// No description provided for @adminPackagePriceInvalid.
  ///
  /// In pt_PT, this message translates to:
  /// **'Introduza um preço válido.'**
  String get adminPackagePriceInvalid;

  /// No description provided for @adminPackageTransportRequired.
  ///
  /// In pt_PT, this message translates to:
  /// **'Selecione pelo menos um tipo de transporte.'**
  String get adminPackageTransportRequired;

  /// No description provided for @adminPackageSalesActive.
  ///
  /// In pt_PT, this message translates to:
  /// **'Vendas ativas'**
  String get adminPackageSalesActive;

  /// No description provided for @adminPackageSalesActiveHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'Quando desativado, o package deixa de aparecer para novas compras.'**
  String get adminPackageSalesActiveHint;

  /// No description provided for @adminPackageAllowedTransport.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tipos de transporte permitidos'**
  String get adminPackageAllowedTransport;

  /// No description provided for @adminSupportReplyTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Responder ao pedido'**
  String get adminSupportReplyTitle;

  /// No description provided for @adminSupportReplyLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Mensagem'**
  String get adminSupportReplyLabel;

  /// No description provided for @adminSupportReplyHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'Escreva a sua resposta ao cliente...'**
  String get adminSupportReplyHint;

  /// No description provided for @adminSupportRequestedAt.
  ///
  /// In pt_PT, this message translates to:
  /// **'pedido em {date}'**
  String adminSupportRequestedAt(String date);

  /// No description provided for @adminSupportReplyAction.
  ///
  /// In pt_PT, this message translates to:
  /// **'Responder'**
  String get adminSupportReplyAction;

  /// No description provided for @adminSupportReplyRequired.
  ///
  /// In pt_PT, this message translates to:
  /// **'Introduza uma mensagem.'**
  String get adminSupportReplyRequired;

  /// No description provided for @adminSupportReplySuccess.
  ///
  /// In pt_PT, this message translates to:
  /// **'Resposta enviada'**
  String get adminSupportReplySuccess;

  /// No description provided for @adminSupportResolveAction.
  ///
  /// In pt_PT, this message translates to:
  /// **'Marcar como resolvido'**
  String get adminSupportResolveAction;

  /// No description provided for @adminSupportResolveSuccess.
  ///
  /// In pt_PT, this message translates to:
  /// **'Pedido resolvido'**
  String get adminSupportResolveSuccess;

  /// No description provided for @adminReportsTabOverview.
  ///
  /// In pt_PT, this message translates to:
  /// **'Panorama operacional'**
  String get adminReportsTabOverview;

  /// No description provided for @adminReportsTabClient.
  ///
  /// In pt_PT, this message translates to:
  /// **'Extrato do cliente'**
  String get adminReportsTabClient;

  /// No description provided for @adminReportsTabDriver.
  ///
  /// In pt_PT, this message translates to:
  /// **'Extrato do motorista'**
  String get adminReportsTabDriver;

  /// No description provided for @adminReportsTabComingSoon.
  ///
  /// In pt_PT, this message translates to:
  /// **'Relatórios de viagens e movimentos de saldo estarão disponíveis em breve.'**
  String get adminReportsTabComingSoon;

  /// No description provided for @adminCurrencyTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Definições de moeda'**
  String get adminCurrencyTitle;

  /// No description provided for @adminCurrencyDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Taxas FX usadas para CVE, EUR e USD.'**
  String get adminCurrencyDesc;

  /// No description provided for @adminCurrencyHeading.
  ///
  /// In pt_PT, this message translates to:
  /// **'Definições de moeda'**
  String get adminCurrencyHeading;

  /// No description provided for @adminCurrencySubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Definir taxas de câmbio para a visualização em EUR, CVE e USD.'**
  String get adminCurrencySubtitle;

  /// No description provided for @adminCurrencyCveToEur.
  ///
  /// In pt_PT, this message translates to:
  /// **'CVE para EUR'**
  String get adminCurrencyCveToEur;

  /// No description provided for @adminCurrencyCveToUsd.
  ///
  /// In pt_PT, this message translates to:
  /// **'CVE para USD'**
  String get adminCurrencyCveToUsd;

  /// No description provided for @adminCurrencySaveSuccess.
  ///
  /// In pt_PT, this message translates to:
  /// **'Definições de moeda guardadas'**
  String get adminCurrencySaveSuccess;

  /// No description provided for @adminCurrencyInvalidRate.
  ///
  /// In pt_PT, this message translates to:
  /// **'Introduza taxas de câmbio válidas superiores a zero'**
  String get adminCurrencyInvalidRate;

  /// No description provided for @adminReportsDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Analisar métricas de operação e desempenho.'**
  String get adminReportsDesc;

  /// No description provided for @adminAuditTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Auditoria'**
  String get adminAuditTitle;

  /// No description provided for @adminAuditDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ver quem ajustou saldos e tarifas.'**
  String get adminAuditDesc;

  /// No description provided for @adminAuditEmpty.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sem entradas de auditoria'**
  String get adminAuditEmpty;

  /// No description provided for @deliveryDeliverTo.
  ///
  /// In pt_PT, this message translates to:
  /// **'Entregar em: Av. da Liberdade, Lisboa'**
  String get deliveryDeliverTo;

  /// No description provided for @deliverySearchHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'O que procura hoje?'**
  String get deliverySearchHint;

  /// No description provided for @deliveryExploreCategories.
  ///
  /// In pt_PT, this message translates to:
  /// **'Explorar Categorias'**
  String get deliveryExploreCategories;

  /// No description provided for @deliveryCategorySupermarket.
  ///
  /// In pt_PT, this message translates to:
  /// **'Supermercado'**
  String get deliveryCategorySupermarket;

  /// No description provided for @deliveryCategorySupermarketSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Essenciais frescos à sua porta'**
  String get deliveryCategorySupermarketSubtitle;

  /// No description provided for @deliveryCategoryPharmacy.
  ///
  /// In pt_PT, this message translates to:
  /// **'Farmácia'**
  String get deliveryCategoryPharmacy;

  /// No description provided for @deliveryCategoryBeverages.
  ///
  /// In pt_PT, this message translates to:
  /// **'Bebidas'**
  String get deliveryCategoryBeverages;

  /// No description provided for @deliveryCategoryHealth.
  ///
  /// In pt_PT, this message translates to:
  /// **'Saúde & Bem-estar'**
  String get deliveryCategoryHealth;

  /// No description provided for @deliveryPartnersTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Parceiros Premium'**
  String get deliveryPartnersTitle;

  /// No description provided for @deliveryPartnersSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Qualidade garantida e entregas rápidas'**
  String get deliveryPartnersSubtitle;

  /// No description provided for @deliveryHighlightsTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Destaques da Semana'**
  String get deliveryHighlightsTitle;

  /// No description provided for @discoverSummerHighlight.
  ///
  /// In pt_PT, this message translates to:
  /// **'DESTAQUE DE VERÃO'**
  String get discoverSummerHighlight;

  /// No description provided for @discoverHeroTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'A Essência do Mediterrâneo'**
  String get discoverHeroTitle;

  /// No description provided for @discoverHeroSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Descubra refúgios secretos e experiências de luxo desenhadas para o viajante exigente.'**
  String get discoverHeroSubtitle;

  /// No description provided for @discoverSearchHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'Procurar restaurantes, festas ou praias...'**
  String get discoverSearchHint;

  /// No description provided for @discoverFilters.
  ///
  /// In pt_PT, this message translates to:
  /// **'Filtros'**
  String get discoverFilters;

  /// No description provided for @discoverExploreMap.
  ///
  /// In pt_PT, this message translates to:
  /// **'Explorar Mapa'**
  String get discoverExploreMap;

  /// No description provided for @discoverExperiencesTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Experiências Exclusivas'**
  String get discoverExperiencesTitle;

  /// No description provided for @discoverCategoryGastronomy.
  ///
  /// In pt_PT, this message translates to:
  /// **'Gastronomia'**
  String get discoverCategoryGastronomy;

  /// No description provided for @discoverExperienceRestaurants.
  ///
  /// In pt_PT, this message translates to:
  /// **'Restaurantes de Autor'**
  String get discoverExperienceRestaurants;

  /// No description provided for @discoverCategoryExploration.
  ///
  /// In pt_PT, this message translates to:
  /// **'Exploração'**
  String get discoverCategoryExploration;

  /// No description provided for @discoverExperienceSecretSpots.
  ///
  /// In pt_PT, this message translates to:
  /// **'Recantos Secretos'**
  String get discoverExperienceSecretSpots;

  /// No description provided for @discoverUpcomingEvents.
  ///
  /// In pt_PT, this message translates to:
  /// **'Próximos Eventos'**
  String get discoverUpcomingEvents;

  /// No description provided for @discoverTickets.
  ///
  /// In pt_PT, this message translates to:
  /// **'Bilhetes'**
  String get discoverTickets;

  /// No description provided for @discoverInteractiveMapTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Mapa Interativo'**
  String get discoverInteractiveMapTitle;

  /// No description provided for @discoverInteractiveMapSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Explore os pontos de interesse perto de si.'**
  String get discoverInteractiveMapSubtitle;

  /// No description provided for @discoverCurrentLocation.
  ///
  /// In pt_PT, this message translates to:
  /// **'Localização Atual'**
  String get discoverCurrentLocation;

  /// No description provided for @eventDateTimeLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Data e Hora'**
  String get eventDateTimeLabel;

  /// No description provided for @eventLocationLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Localização'**
  String get eventLocationLabel;

  /// No description provided for @eventAboutTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sobre o Evento'**
  String get eventAboutTitle;

  /// No description provided for @eventDirectionsTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Como chegar'**
  String get eventDirectionsTitle;

  /// No description provided for @eventOpenGps.
  ///
  /// In pt_PT, this message translates to:
  /// **'Abrir no GPS'**
  String get eventOpenGps;

  /// No description provided for @eventStandardTicket.
  ///
  /// In pt_PT, this message translates to:
  /// **'Bilhete Normal'**
  String get eventStandardTicket;

  /// No description provided for @eventStandardTicketDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Acesso geral + 1 bebida'**
  String get eventStandardTicketDesc;

  /// No description provided for @eventServiceFee.
  ///
  /// In pt_PT, this message translates to:
  /// **'Taxa de Serviço'**
  String get eventServiceFee;

  /// No description provided for @eventPayNow.
  ///
  /// In pt_PT, this message translates to:
  /// **'Pagar Agora'**
  String get eventPayNow;

  /// No description provided for @eventVipExperience.
  ///
  /// In pt_PT, this message translates to:
  /// **'Experiência VIP'**
  String get eventVipExperience;

  /// No description provided for @eventLimited.
  ///
  /// In pt_PT, this message translates to:
  /// **'LIMITADO'**
  String get eventLimited;

  /// No description provided for @eventVipDescription.
  ///
  /// In pt_PT, this message translates to:
  /// **'Mesa reservada, garrafa incluída e acesso ao backstage.'**
  String get eventVipDescription;

  /// No description provided for @eventCheckAvailability.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ver disponibilidade →'**
  String get eventCheckAvailability;

  /// No description provided for @jetskiAdventureTag.
  ///
  /// In pt_PT, this message translates to:
  /// **'Aventura no Mar'**
  String get jetskiAdventureTag;

  /// No description provided for @jetskiHeroTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Domine as Ondas'**
  String get jetskiHeroTitle;

  /// No description provided for @jetskiHeroSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Aluguer premium de motas de água de alta performance.'**
  String get jetskiHeroSubtitle;

  /// No description provided for @jetskiDurationLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'DURAÇÃO'**
  String get jetskiDurationLabel;

  /// No description provided for @jetskiDurationValue.
  ///
  /// In pt_PT, this message translates to:
  /// **'1 Hora — Passeio Rápido'**
  String get jetskiDurationValue;

  /// No description provided for @jetskiExploreFleet.
  ///
  /// In pt_PT, this message translates to:
  /// **'Explorar Frota'**
  String get jetskiExploreFleet;

  /// No description provided for @jetskiOurFleet.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nossa Frota'**
  String get jetskiOurFleet;

  /// No description provided for @jetskiBookNow.
  ///
  /// In pt_PT, this message translates to:
  /// **'Reservar Agora'**
  String get jetskiBookNow;

  /// No description provided for @jetskiSafetyTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Segurança Primeiro'**
  String get jetskiSafetyTitle;

  /// No description provided for @jetskiSafetyLifeJacketTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Colete Salva-vidas Incluído'**
  String get jetskiSafetyLifeJacketTitle;

  /// No description provided for @jetskiSafetyLifeJacketSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Equipamento homologado para todos os pesos.'**
  String get jetskiSafetyLifeJacketSubtitle;

  /// No description provided for @jetskiSafetyBriefingTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Briefing de Segurança'**
  String get jetskiSafetyBriefingTitle;

  /// No description provided for @jetskiSafetyBriefingSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Instrução obrigatória de 15 min antes da partida.'**
  String get jetskiSafetyBriefingSubtitle;

  /// No description provided for @jetskiSafetyGpsTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Monitorização GPS'**
  String get jetskiSafetyGpsTitle;

  /// No description provided for @jetskiSafetyGpsSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Equipa de apoio pronta para intervir 24/7.'**
  String get jetskiSafetyGpsSubtitle;

  /// No description provided for @jetskiOurBase.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nossa Base'**
  String get jetskiOurBase;

  /// No description provided for @jetskiOpenMap.
  ///
  /// In pt_PT, this message translates to:
  /// **'Abrir Mapa'**
  String get jetskiOpenMap;

  /// No description provided for @premiumHomeSearchHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'Procure destino ou serviço...'**
  String get premiumHomeSearchHint;

  /// No description provided for @premiumHomeNoResults.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nenhum resultado encontrado'**
  String get premiumHomeNoResults;

  /// No description provided for @premiumHomeFastDelivery.
  ///
  /// In pt_PT, this message translates to:
  /// **'Entregas Rápidas'**
  String get premiumHomeFastDelivery;

  /// No description provided for @premiumHomeGroceryPharmacy.
  ///
  /// In pt_PT, this message translates to:
  /// **'Mercearia e Farmácia'**
  String get premiumHomeGroceryPharmacy;

  /// No description provided for @premiumHomeIslandGuide.
  ///
  /// In pt_PT, this message translates to:
  /// **'Guia de Ilhas'**
  String get premiumHomeIslandGuide;

  /// No description provided for @premiumHomeJetski.
  ///
  /// In pt_PT, this message translates to:
  /// **'Mota de Água'**
  String get premiumHomeJetski;

  /// No description provided for @premiumHomeTransportTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Transporte e Mobilidade'**
  String get premiumHomeTransportTitle;

  /// No description provided for @premiumHomeTransportTrip.
  ///
  /// In pt_PT, this message translates to:
  /// **'Viagem'**
  String get premiumHomeTransportTrip;

  /// No description provided for @premiumHomeTransportMoto.
  ///
  /// In pt_PT, this message translates to:
  /// **'Moto'**
  String get premiumHomeTransportMoto;

  /// No description provided for @premiumHomeTransportScooter.
  ///
  /// In pt_PT, this message translates to:
  /// **'Trotinete'**
  String get premiumHomeTransportScooter;

  /// No description provided for @premiumHomeTransportBike.
  ///
  /// In pt_PT, this message translates to:
  /// **'Bicicleta'**
  String get premiumHomeTransportBike;

  /// No description provided for @premiumHomeExperiencesTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Experiências Premium'**
  String get premiumHomeExperiencesTitle;

  /// No description provided for @premiumHomeJetskiRentalTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Aluguer de Motas de Água'**
  String get premiumHomeJetskiRentalTitle;

  /// No description provided for @premiumHomeJetskiRentalDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Explore as águas cristalinas com o nosso novo serviço de aluguer premium.'**
  String get premiumHomeJetskiRentalDesc;

  /// No description provided for @premiumHomeFromPrice.
  ///
  /// In pt_PT, this message translates to:
  /// **'Desde {price}'**
  String premiumHomeFromPrice(String price);

  /// No description provided for @premiumHomeIslandGuideTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Guia Exclusivo de Ilhas'**
  String get premiumHomeIslandGuideTitle;

  /// No description provided for @premiumHomeIslandGuideDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Descubra os segredos das ilhas com roteiros personalizados pelos locais.'**
  String get premiumHomeIslandGuideDesc;

  /// No description provided for @rentalPickupLocation.
  ///
  /// In pt_PT, this message translates to:
  /// **'Local de Recolha'**
  String get rentalPickupLocation;

  /// No description provided for @rentalDropoffLocation.
  ///
  /// In pt_PT, this message translates to:
  /// **'Local de Entrega'**
  String get rentalDropoffLocation;

  /// No description provided for @rentalSamePickupHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'Mesmo local de recolha'**
  String get rentalSamePickupHint;

  /// No description provided for @rentalDateSelection.
  ///
  /// In pt_PT, this message translates to:
  /// **'Seleção de Datas'**
  String get rentalDateSelection;

  /// No description provided for @rentalDriverAge.
  ///
  /// In pt_PT, this message translates to:
  /// **'Idade do Condutor'**
  String get rentalDriverAge;

  /// No description provided for @rentalDriverAgeNote.
  ///
  /// In pt_PT, this message translates to:
  /// **'Taxas adicionais podem ser aplicadas para condutores fora do intervalo padrão.'**
  String get rentalDriverAgeNote;

  /// No description provided for @rentalPremiumOnly.
  ///
  /// In pt_PT, this message translates to:
  /// **'Premium Only'**
  String get rentalPremiumOnly;

  /// No description provided for @rentalLuxuryFleetOnly.
  ///
  /// In pt_PT, this message translates to:
  /// **'Mostrar apenas frota de luxo'**
  String get rentalLuxuryFleetOnly;

  /// No description provided for @rentalViewFleetOnMap.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ver frota no mapa'**
  String get rentalViewFleetOnMap;

  /// No description provided for @rentalCarType.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tipo de Carro'**
  String get rentalCarType;

  /// No description provided for @rentalMaxPrice.
  ///
  /// In pt_PT, this message translates to:
  /// **'Preço Máximo'**
  String get rentalMaxPrice;

  /// No description provided for @rentalTransmission.
  ///
  /// In pt_PT, this message translates to:
  /// **'Transmissão'**
  String get rentalTransmission;

  /// No description provided for @rentalFilter.
  ///
  /// In pt_PT, this message translates to:
  /// **'Filtrar'**
  String get rentalFilter;

  /// No description provided for @rentalPremiumHighlights.
  ///
  /// In pt_PT, this message translates to:
  /// **'Destaques Premium'**
  String get rentalPremiumHighlights;

  /// No description provided for @rentalResultsFound.
  ///
  /// In pt_PT, this message translates to:
  /// **'{count} resultados encontrados'**
  String rentalResultsFound(String count);

  /// No description provided for @rentalPremiumChoice.
  ///
  /// In pt_PT, this message translates to:
  /// **'Premium Choice'**
  String get rentalPremiumChoice;

  /// No description provided for @rentalAllCars.
  ///
  /// In pt_PT, this message translates to:
  /// **'Todos os Carros'**
  String get rentalAllCars;

  /// No description provided for @rentalLoadMore.
  ///
  /// In pt_PT, this message translates to:
  /// **'Carregar mais veículos'**
  String get rentalLoadMore;

  /// No description provided for @rentalLoadError.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não foi possível carregar veículos. Tente novamente.'**
  String get rentalLoadError;

  /// No description provided for @rentalNoVehicles.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nenhum veículo disponível de momento.'**
  String get rentalNoVehicles;

  /// No description provided for @rentalVehicleDetails.
  ///
  /// In pt_PT, this message translates to:
  /// **'Detalhes do Veículo'**
  String get rentalVehicleDetails;

  /// No description provided for @rentalRating.
  ///
  /// In pt_PT, this message translates to:
  /// **'Classificação'**
  String get rentalRating;

  /// No description provided for @rentalPowertrain.
  ///
  /// In pt_PT, this message translates to:
  /// **'Motorização'**
  String get rentalPowertrain;

  /// No description provided for @rentalCapacity.
  ///
  /// In pt_PT, this message translates to:
  /// **'Capacidade'**
  String get rentalCapacity;

  /// No description provided for @rentalAcceleration.
  ///
  /// In pt_PT, this message translates to:
  /// **'Aceleração'**
  String get rentalAcceleration;

  /// No description provided for @rentalInsuranceIncluded.
  ///
  /// In pt_PT, this message translates to:
  /// **'Seguro Incluído'**
  String get rentalInsuranceIncluded;

  /// No description provided for @rentalFuelPolicy.
  ///
  /// In pt_PT, this message translates to:
  /// **'Combustível'**
  String get rentalFuelPolicy;

  /// No description provided for @rentalCurrentBattery.
  ///
  /// In pt_PT, this message translates to:
  /// **'Bateria Atual'**
  String get rentalCurrentBattery;

  /// No description provided for @rentalBookingSummary.
  ///
  /// In pt_PT, this message translates to:
  /// **'Resumo da Reserva'**
  String get rentalBookingSummary;

  /// No description provided for @rentalTotalCost.
  ///
  /// In pt_PT, this message translates to:
  /// **'Custo Total'**
  String get rentalTotalCost;

  /// No description provided for @rentalTechnicalSpecs.
  ///
  /// In pt_PT, this message translates to:
  /// **'ESPECIFICAÇÕES TÉCNICAS'**
  String get rentalTechnicalSpecs;

  /// No description provided for @rentalReservationTotal.
  ///
  /// In pt_PT, this message translates to:
  /// **'Total da reserva'**
  String get rentalReservationTotal;

  /// No description provided for @rentalContinueToPayment.
  ///
  /// In pt_PT, this message translates to:
  /// **'Continuar para Pagamento'**
  String get rentalContinueToPayment;

  /// No description provided for @rentalPerDay.
  ///
  /// In pt_PT, this message translates to:
  /// **'/dia'**
  String get rentalPerDay;

  /// No description provided for @rentalSeats.
  ///
  /// In pt_PT, this message translates to:
  /// **'{count} Lugares'**
  String rentalSeats(String count);

  /// No description provided for @rentalBag.
  ///
  /// In pt_PT, this message translates to:
  /// **'Mala'**
  String get rentalBag;

  /// No description provided for @rentalBags.
  ///
  /// In pt_PT, this message translates to:
  /// **'Malas'**
  String get rentalBags;

  /// No description provided for @reservationReviewTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Revisão da Reserva'**
  String get reservationReviewTitle;

  /// No description provided for @reservationItinerary.
  ///
  /// In pt_PT, this message translates to:
  /// **'Itinerário'**
  String get reservationItinerary;

  /// No description provided for @reservationPickupLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'LEVANTAMENTO'**
  String get reservationPickupLabel;

  /// No description provided for @reservationReturnLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'DEVOLUÇÃO'**
  String get reservationReturnLabel;

  /// No description provided for @reservationSecurePayment.
  ///
  /// In pt_PT, this message translates to:
  /// **'Pagamento 100% Seguro'**
  String get reservationSecurePayment;

  /// No description provided for @reservationSecurePaymentDesc.
  ///
  /// In pt_PT, this message translates to:
  /// **'Utilizamos encriptação SSL de 256 bits para proteger os seus dados.'**
  String get reservationSecurePaymentDesc;

  /// No description provided for @reservationCostSummary.
  ///
  /// In pt_PT, this message translates to:
  /// **'Resumo de Custos'**
  String get reservationCostSummary;

  /// No description provided for @reservationNoHiddenFees.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sem custos ocultos'**
  String get reservationNoHiddenFees;

  /// No description provided for @reservationPaymentMethod.
  ///
  /// In pt_PT, this message translates to:
  /// **'Método de Pagamento'**
  String get reservationPaymentMethod;

  /// No description provided for @reservationCreditCard.
  ///
  /// In pt_PT, this message translates to:
  /// **'Cartão de Crédito'**
  String get reservationCreditCard;

  /// No description provided for @reservationPayWithApplePay.
  ///
  /// In pt_PT, this message translates to:
  /// **'Pagar com Apple Pay'**
  String get reservationPayWithApplePay;

  /// No description provided for @reservationConfirmAndPay.
  ///
  /// In pt_PT, this message translates to:
  /// **'Confirmar e Pagar'**
  String get reservationConfirmAndPay;

  /// No description provided for @reservationTermsPrefix.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ao clicar em \"Confirmar e Pagar\", aceita os nossos '**
  String get reservationTermsPrefix;

  /// No description provided for @reservationTermsLink.
  ///
  /// In pt_PT, this message translates to:
  /// **'Termos e Condições'**
  String get reservationTermsLink;

  /// No description provided for @reservationFullInsurance.
  ///
  /// In pt_PT, this message translates to:
  /// **'Seguro Total Incluído'**
  String get reservationFullInsurance;

  /// No description provided for @reservationsEmptyTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ainda não tem mais reservas'**
  String get reservationsEmptyTitle;

  /// No description provided for @reservationsEmptyBody.
  ///
  /// In pt_PT, this message translates to:
  /// **'Planeie a sua próxima viagem com a nossa frota premium. Conforto e pontualidade garantidos.'**
  String get reservationsEmptyBody;

  /// No description provided for @reservationsExploreDestinations.
  ///
  /// In pt_PT, this message translates to:
  /// **'Explorar destinos'**
  String get reservationsExploreDestinations;

  /// No description provided for @tripHistoryActivity.
  ///
  /// In pt_PT, this message translates to:
  /// **'A Minha Atividade'**
  String get tripHistoryActivity;

  /// No description provided for @tripHistoryTrips.
  ///
  /// In pt_PT, this message translates to:
  /// **'Viagens'**
  String get tripHistoryTrips;

  /// No description provided for @tripHistoryThisMonth.
  ///
  /// In pt_PT, this message translates to:
  /// **'Este Mês'**
  String get tripHistoryThisMonth;

  /// No description provided for @tripHistoryFilterAll.
  ///
  /// In pt_PT, this message translates to:
  /// **'Todos'**
  String get tripHistoryFilterAll;

  /// No description provided for @tripHistoryFilterRecent.
  ///
  /// In pt_PT, this message translates to:
  /// **'Viagens Recentes'**
  String get tripHistoryFilterRecent;

  /// No description provided for @tripHistoryFilterCompleted.
  ///
  /// In pt_PT, this message translates to:
  /// **'Concluídas'**
  String get tripHistoryFilterCompleted;

  /// No description provided for @tripHistoryFilterCancelled.
  ///
  /// In pt_PT, this message translates to:
  /// **'Canceladas'**
  String get tripHistoryFilterCancelled;

  /// No description provided for @tripHistoryFilterThisYear.
  ///
  /// In pt_PT, this message translates to:
  /// **'Este Ano'**
  String get tripHistoryFilterThisYear;

  /// No description provided for @tripHistoryStatusCancelled.
  ///
  /// In pt_PT, this message translates to:
  /// **'Cancelada'**
  String get tripHistoryStatusCancelled;

  /// No description provided for @tripHistoryStatusInProgress.
  ///
  /// In pt_PT, this message translates to:
  /// **'Em curso'**
  String get tripHistoryStatusInProgress;

  /// No description provided for @tripHistoryStatusScheduled.
  ///
  /// In pt_PT, this message translates to:
  /// **'Agendada'**
  String get tripHistoryStatusScheduled;

  /// No description provided for @tripHistoryEmpty.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ainda sem viagens'**
  String get tripHistoryEmpty;

  /// No description provided for @tripHistoryEmptyBody.
  ///
  /// In pt_PT, this message translates to:
  /// **'As suas viagens aparecem aqui depois de pedir uma corrida.'**
  String get tripHistoryEmptyBody;

  /// No description provided for @tripHistoryLoadError.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não foi possível carregar viagens. Tente novamente.'**
  String get tripHistoryLoadError;

  /// No description provided for @tripHistoryNoDetails.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sem detalhes'**
  String get tripHistoryNoDetails;

  /// No description provided for @tripDetailsRateExperience.
  ///
  /// In pt_PT, this message translates to:
  /// **'Avalie a sua experiência'**
  String get tripDetailsRateExperience;

  /// No description provided for @tripDetailsDigitalInvoice.
  ///
  /// In pt_PT, this message translates to:
  /// **'Fatura Digital'**
  String get tripDetailsDigitalInvoice;

  /// No description provided for @tripDetailsTotalPaid.
  ///
  /// In pt_PT, this message translates to:
  /// **'Total Pago'**
  String get tripDetailsTotalPaid;

  /// No description provided for @tripDetailsMethod.
  ///
  /// In pt_PT, this message translates to:
  /// **'Método'**
  String get tripDetailsMethod;

  /// No description provided for @tripDetailsDownloadPdf.
  ///
  /// In pt_PT, this message translates to:
  /// **'Descarregar PDF'**
  String get tripDetailsDownloadPdf;

  /// No description provided for @tripDetailsFareBase.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tarifa Base'**
  String get tripDetailsFareBase;

  /// No description provided for @tripDetailsFareDistance.
  ///
  /// In pt_PT, this message translates to:
  /// **'Distância (12.5 km)'**
  String get tripDetailsFareDistance;

  /// No description provided for @tripDetailsFareTime.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tempo (24 min)'**
  String get tripDetailsFareTime;

  /// No description provided for @tripDetailsFareDiscount.
  ///
  /// In pt_PT, this message translates to:
  /// **'Desconto Promocional'**
  String get tripDetailsFareDiscount;

  /// No description provided for @tripDetailsSupportTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Algo correu mal?'**
  String get tripDetailsSupportTitle;

  /// No description provided for @tripDetailsSupportLostItem.
  ///
  /// In pt_PT, this message translates to:
  /// **'Reportar objeto perdido'**
  String get tripDetailsSupportLostItem;

  /// No description provided for @tripDetailsSupportSafety.
  ///
  /// In pt_PT, this message translates to:
  /// **'Reclamação de segurança'**
  String get tripDetailsSupportSafety;

  /// No description provided for @tripDetailsSupportCustomer.
  ///
  /// In pt_PT, this message translates to:
  /// **'Apoio ao cliente'**
  String get tripDetailsSupportCustomer;

  /// No description provided for @tripCompletedThanks.
  ///
  /// In pt_PT, this message translates to:
  /// **'Obrigado por viajar connosco.'**
  String get tripCompletedThanks;

  /// No description provided for @tripCompletedFinalPrice.
  ///
  /// In pt_PT, this message translates to:
  /// **'Preço Final'**
  String get tripCompletedFinalPrice;

  /// No description provided for @tripCompletedOptimizedRoute.
  ///
  /// In pt_PT, this message translates to:
  /// **'Trajeto otimizado'**
  String get tripCompletedOptimizedRoute;

  /// No description provided for @tripCompletedRateTrip.
  ///
  /// In pt_PT, this message translates to:
  /// **'Avalie a Viagem'**
  String get tripCompletedRateTrip;

  /// No description provided for @tripCompletedRateHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'Como correu a sua experiência com o motorista e o veículo?'**
  String get tripCompletedRateHint;

  /// No description provided for @tripCompletedCommentOptional.
  ///
  /// In pt_PT, this message translates to:
  /// **'Comentário (opcional)'**
  String get tripCompletedCommentOptional;

  /// No description provided for @tripCompletedCommentHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'Partilhe a sua opinião...'**
  String get tripCompletedCommentHint;

  /// No description provided for @tripCompletedSubmitRating.
  ///
  /// In pt_PT, this message translates to:
  /// **'Enviar avaliação'**
  String get tripCompletedSubmitRating;

  /// No description provided for @tripCompletedRatingSent.
  ///
  /// In pt_PT, this message translates to:
  /// **'Avaliação enviada'**
  String get tripCompletedRatingSent;

  /// No description provided for @tripCompletedReportIssue.
  ///
  /// In pt_PT, this message translates to:
  /// **'Reportar problema'**
  String get tripCompletedReportIssue;

  /// No description provided for @tripInProgressStatusLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Status da Viagem'**
  String get tripInProgressStatusLabel;

  /// No description provided for @tripInProgressStatusValue.
  ///
  /// In pt_PT, this message translates to:
  /// **'Em viagem'**
  String get tripInProgressStatusValue;

  /// No description provided for @tripInProgressArrivalLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Chegada prevista'**
  String get tripInProgressArrivalLabel;

  /// No description provided for @tripInProgressCostLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Custo Estimado'**
  String get tripInProgressCostLabel;

  /// No description provided for @driverSearchSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Estamos a ligar-te aos veículos mais próximos em Lisboa Central.'**
  String get driverSearchSubtitle;

  /// No description provided for @driverSearchSubtitleFallback.
  ///
  /// In pt_PT, this message translates to:
  /// **'A ligar aos veículos disponíveis mais próximos.'**
  String get driverSearchSubtitleFallback;

  /// No description provided for @driverSearchSubtitleArea.
  ///
  /// In pt_PT, this message translates to:
  /// **'A ligar aos veículos mais próximos perto de {area}.'**
  String driverSearchSubtitleArea(String area);

  /// No description provided for @driverSearchOrigin.
  ///
  /// In pt_PT, this message translates to:
  /// **'ORIGEM'**
  String get driverSearchOrigin;

  /// No description provided for @driverSearchEstimate.
  ///
  /// In pt_PT, this message translates to:
  /// **'ESTIMATIVA'**
  String get driverSearchEstimate;

  /// No description provided for @driverSearchWaitEstimate.
  ///
  /// In pt_PT, this message translates to:
  /// **'3–5 min'**
  String get driverSearchWaitEstimate;

  /// No description provided for @driverSearchWaitMinutes.
  ///
  /// In pt_PT, this message translates to:
  /// **'{minutes} min'**
  String driverSearchWaitMinutes(int minutes);

  /// No description provided for @driverSearchCancelTrip.
  ///
  /// In pt_PT, this message translates to:
  /// **'Cancelar Viagem'**
  String get driverSearchCancelTrip;

  /// No description provided for @driverSearchCancelling.
  ///
  /// In pt_PT, this message translates to:
  /// **'A cancelar...'**
  String get driverSearchCancelling;

  /// No description provided for @driverSearchCancelFailed.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não foi possível cancelar a viagem.'**
  String get driverSearchCancelFailed;

  /// No description provided for @driverSearchNoDrivers.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nenhum motorista disponível. Tente novamente.'**
  String get driverSearchNoDrivers;

  /// No description provided for @driverSearchNoDriversNearby.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nenhum motorista perto do local de recolha. O motorista tem de estar disponível num raio de 100 km.'**
  String get driverSearchNoDriversNearby;

  /// No description provided for @driverSearchNoDriversMissingVehicle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Motoristas próximos não têm viatura atribuída. Peça ao admin para atribuir uma viatura.'**
  String get driverSearchNoDriversMissingVehicle;

  /// No description provided for @homePickupOutsideServiceArea.
  ///
  /// In pt_PT, this message translates to:
  /// **'A recolha está fora da área de serviço. Use uma localização em Cabo Verde.'**
  String get homePickupOutsideServiceArea;

  /// No description provided for @driverSearchOptimizing.
  ///
  /// In pt_PT, this message translates to:
  /// **'Otimizando percurso em tempo real...'**
  String get driverSearchOptimizing;

  /// No description provided for @driverFoundWaiting.
  ///
  /// In pt_PT, this message translates to:
  /// **'A aguardar confirmação...'**
  String get driverFoundWaiting;

  /// No description provided for @driverFoundEstimatedTime.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tempo estimado'**
  String get driverFoundEstimatedTime;

  /// No description provided for @driverFoundFare.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tarifa'**
  String get driverFoundFare;

  /// No description provided for @driverFoundCancelHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'Pode cancelar sem custos nos próximos 2 minutos enquanto o motorista confirma a reserva.'**
  String get driverFoundCancelHint;

  /// No description provided for @driverEnRouteYourLocation.
  ///
  /// In pt_PT, this message translates to:
  /// **'A sua localização'**
  String get driverEnRouteYourLocation;

  /// No description provided for @driverEnRouteMessage.
  ///
  /// In pt_PT, this message translates to:
  /// **'Mensagem'**
  String get driverEnRouteMessage;

  /// No description provided for @driverEnRouteCall.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ligar'**
  String get driverEnRouteCall;

  /// No description provided for @tripDestinationSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Procure um destino ou escolha um dos seus locais frequentes.'**
  String get tripDestinationSubtitle;

  /// No description provided for @tripDestinationSearchHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'Pesquisar endereço ou ponto de interesse'**
  String get tripDestinationSearchHint;

  /// No description provided for @tripDestinationRecentPlaces.
  ///
  /// In pt_PT, this message translates to:
  /// **'Locais Recentes'**
  String get tripDestinationRecentPlaces;

  /// No description provided for @tripDestinationSuggestions.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sugestões e Favoritos'**
  String get tripDestinationSuggestions;

  /// No description provided for @tripDestinationExploreMap.
  ///
  /// In pt_PT, this message translates to:
  /// **'Explorar Mapa'**
  String get tripDestinationExploreMap;

  /// No description provided for @tripDestinationTodaySuggestion.
  ///
  /// In pt_PT, this message translates to:
  /// **'SUGESTÃO DE HOJE'**
  String get tripDestinationTodaySuggestion;

  /// No description provided for @tripDestinationSuggestionTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Belém e Monumentos'**
  String get tripDestinationSuggestionTitle;

  /// No description provided for @tripDestinationViewFullMap.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ver Mapa Completo'**
  String get tripDestinationViewFullMap;

  /// No description provided for @tripConfirmTransportType.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tipo de Transporte'**
  String get tripConfirmTransportType;

  /// No description provided for @tripConfirmTotal.
  ///
  /// In pt_PT, this message translates to:
  /// **'Total: {amount}'**
  String tripConfirmTotal(String amount);

  /// No description provided for @tripConfirmTrip.
  ///
  /// In pt_PT, this message translates to:
  /// **'Confirmar viagem'**
  String get tripConfirmTrip;

  /// No description provided for @tripConfirmSessionInvalid.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sessão inválida. Inicie sessão novamente.'**
  String get tripConfirmSessionInvalid;

  /// No description provided for @tripConfirmRouteLoading.
  ///
  /// In pt_PT, this message translates to:
  /// **'Aguarde o carregamento do percurso.'**
  String get tripConfirmRouteLoading;

  /// No description provided for @tripConfirmCreateFailed.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não foi possível criar a viagem. Tente novamente.'**
  String get tripConfirmCreateFailed;

  /// No description provided for @tripConfirmPermissionDenied.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não foi possível criar a viagem. Verifique o seu saldo e sessão, ou contacte o suporte.'**
  String get tripConfirmPermissionDenied;

  /// No description provided for @tripConfirmDestinationFailed.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não foi possível localizar o destino. Verifique o endereço ou escolha uma sugestão da lista.'**
  String get tripConfirmDestinationFailed;

  /// No description provided for @tripConfirmDirectionsFailed.
  ///
  /// In pt_PT, this message translates to:
  /// **'Não foi possível calcular o percurso. Verifique a ligação e as definições da API Google Maps.'**
  String get tripConfirmDirectionsFailed;

  /// No description provided for @tripConfirmTransportTypesFailed.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tipos de transporte indisponíveis. Tente novamente dentro de momentos.'**
  String get tripConfirmTransportTypesFailed;

  /// No description provided for @tripConfirmPriceUnavailable.
  ///
  /// In pt_PT, this message translates to:
  /// **'Preço da viagem indisponível. Aguarde o carregamento do percurso ou escolha outro destino.'**
  String get tripConfirmPriceUnavailable;

  /// No description provided for @tripConfirmLimitExceeded.
  ///
  /// In pt_PT, this message translates to:
  /// **'Saldo insuficiente para pedir esta viagem. Carregue a conta e tente novamente.'**
  String get tripConfirmLimitExceeded;

  /// No description provided for @tripConfirmDirectionsApproximate.
  ///
  /// In pt_PT, this message translates to:
  /// **'Percurso exacto indisponível. Distância e preço são aproximados.'**
  String get tripConfirmDirectionsApproximate;

  /// No description provided for @tripConfirmPickupPoint.
  ///
  /// In pt_PT, this message translates to:
  /// **'PONTO DE RECOLHA'**
  String get tripConfirmPickupPoint;

  /// No description provided for @tripConfirmFinalDestination.
  ///
  /// In pt_PT, this message translates to:
  /// **'DESTINO FINAL'**
  String get tripConfirmFinalDestination;

  /// No description provided for @tripConfirmTransportPremium.
  ///
  /// In pt_PT, this message translates to:
  /// **'Premium'**
  String get tripConfirmTransportPremium;

  /// No description provided for @tripConfirmTransportEco.
  ///
  /// In pt_PT, this message translates to:
  /// **'Eco-Eletric'**
  String get tripConfirmTransportEco;

  /// No description provided for @tripConfirmTransportShared.
  ///
  /// In pt_PT, this message translates to:
  /// **'Partilhado'**
  String get tripConfirmTransportShared;

  /// No description provided for @driverAvailable.
  ///
  /// In pt_PT, this message translates to:
  /// **'Disponível'**
  String get driverAvailable;

  /// No description provided for @driverUnavailable.
  ///
  /// In pt_PT, this message translates to:
  /// **'Indisponível'**
  String get driverUnavailable;

  /// No description provided for @driverFleetStatus.
  ///
  /// In pt_PT, this message translates to:
  /// **'Status da Frota'**
  String get driverFleetStatus;

  /// No description provided for @driverVerified.
  ///
  /// In pt_PT, this message translates to:
  /// **'Verificado'**
  String get driverVerified;

  /// No description provided for @driverInOperation.
  ///
  /// In pt_PT, this message translates to:
  /// **'Em Operação'**
  String get driverInOperation;

  /// No description provided for @driverTodayEarnings.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ganhos de Hoje'**
  String get driverTodayEarnings;

  /// No description provided for @driverEarningsVsYesterday.
  ///
  /// In pt_PT, this message translates to:
  /// **'{change} vs. ontem'**
  String driverEarningsVsYesterday(String change);

  /// No description provided for @driverNoRecentTrips.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ainda sem viagens concluídas'**
  String get driverNoRecentTrips;

  /// No description provided for @driverNoVehicleAssigned.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nenhum veículo atribuído'**
  String get driverNoVehicleAssigned;

  /// No description provided for @driverAvailabilityInactiveHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ative para receber novas viagens.'**
  String get driverAvailabilityInactiveHint;

  /// No description provided for @driverAvailabilityActiveHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'A localização será partilhada com a central.'**
  String get driverAvailabilityActiveHint;

  /// No description provided for @driverReadinessTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Requisitos para ficar disponível'**
  String get driverReadinessTitle;

  /// No description provided for @driverReadinessVehicleTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Viatura atribuída'**
  String get driverReadinessVehicleTitle;

  /// No description provided for @driverReadinessVehicleReady.
  ///
  /// In pt_PT, this message translates to:
  /// **'Viatura ativa e pronta.'**
  String get driverReadinessVehicleReady;

  /// No description provided for @driverReadinessVehicleMissing.
  ///
  /// In pt_PT, this message translates to:
  /// **'Apenas o administrador pode associar uma viatura.'**
  String get driverReadinessVehicleMissing;

  /// No description provided for @driverReadinessVehicleDialogTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sem viatura atribuída'**
  String get driverReadinessVehicleDialogTitle;

  /// No description provided for @driverReadinessVehicleDialogMessage.
  ///
  /// In pt_PT, this message translates to:
  /// **'Apenas um administrador pode associar uma viatura à sua conta.'**
  String get driverReadinessVehicleDialogMessage;

  /// No description provided for @driverReadinessVehicleDialogGotIt.
  ///
  /// In pt_PT, this message translates to:
  /// **'Entendi'**
  String get driverReadinessVehicleDialogGotIt;

  /// No description provided for @driverReadinessVehicleHelpAction.
  ///
  /// In pt_PT, this message translates to:
  /// **'Saber mais'**
  String get driverReadinessVehicleHelpAction;

  /// No description provided for @driverReadinessVehicleSnackMessage.
  ///
  /// In pt_PT, this message translates to:
  /// **'Apenas um administrador pode associar uma viatura à sua conta.'**
  String get driverReadinessVehicleSnackMessage;

  /// No description provided for @driverReadinessLocationTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Localização do dispositivo'**
  String get driverReadinessLocationTitle;

  /// No description provided for @driverReadinessLocationReady.
  ///
  /// In pt_PT, this message translates to:
  /// **'Localização ativa.'**
  String get driverReadinessLocationReady;

  /// No description provided for @driverReadinessLocationMissing.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ative a localização para receber viagens.'**
  String get driverReadinessLocationMissing;

  /// No description provided for @driverReadinessLocationAction.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ativar localização'**
  String get driverReadinessLocationAction;

  /// No description provided for @driverLocationPermissionTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Permitir localização'**
  String get driverLocationPermissionTitle;

  /// No description provided for @driverLocationPermissionMessage.
  ///
  /// In pt_PT, this message translates to:
  /// **'O motorista precisa de partilhar a localização em tempo real para receber viagens e ser encontrado pelos clientes.'**
  String get driverLocationPermissionMessage;

  /// No description provided for @driverLocationPermissionSettingsMessage.
  ///
  /// In pt_PT, this message translates to:
  /// **'A permissão de localização está desativada. Abra as definições da app para permitir o acesso.'**
  String get driverLocationPermissionSettingsMessage;

  /// No description provided for @driverReadinessAllReady.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tudo pronto. Pode ficar disponível.'**
  String get driverReadinessAllReady;

  /// No description provided for @driverTripsLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Viagens'**
  String get driverTripsLabel;

  /// No description provided for @driverDistanceLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Distância'**
  String get driverDistanceLabel;

  /// No description provided for @driverRecentTrips.
  ///
  /// In pt_PT, this message translates to:
  /// **'Últimas Viagens'**
  String get driverRecentTrips;

  /// No description provided for @driverLocationCity.
  ///
  /// In pt_PT, this message translates to:
  /// **'Praia, CV'**
  String get driverLocationCity;

  /// No description provided for @driverLocationLoading.
  ///
  /// In pt_PT, this message translates to:
  /// **'A localizar...'**
  String get driverLocationLoading;

  /// No description provided for @driverHoursAgo.
  ///
  /// In pt_PT, this message translates to:
  /// **'há {hours}h'**
  String driverHoursAgo(int hours);

  /// No description provided for @driverNewRequest.
  ///
  /// In pt_PT, this message translates to:
  /// **'Nova Solicitação'**
  String get driverNewRequest;

  /// No description provided for @driverPremiumTrip.
  ///
  /// In pt_PT, this message translates to:
  /// **'Viagem Premium'**
  String get driverPremiumTrip;

  /// No description provided for @driverPickup.
  ///
  /// In pt_PT, this message translates to:
  /// **'Recolha'**
  String get driverPickup;

  /// No description provided for @driverDestination.
  ///
  /// In pt_PT, this message translates to:
  /// **'Destino'**
  String get driverDestination;

  /// No description provided for @driverDecline.
  ///
  /// In pt_PT, this message translates to:
  /// **'RECUSAR'**
  String get driverDecline;

  /// No description provided for @driverAcceptTrip.
  ///
  /// In pt_PT, this message translates to:
  /// **'ACEITAR VIAGEM'**
  String get driverAcceptTrip;

  /// No description provided for @driverTripAcceptedTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Viagem Aceite!'**
  String get driverTripAcceptedTitle;

  /// No description provided for @driverTripAcceptedSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'A preparar a rota de navegação...'**
  String get driverTripAcceptedSubtitle;

  /// No description provided for @driverPassenger.
  ///
  /// In pt_PT, this message translates to:
  /// **'Passageiro'**
  String get driverPassenger;

  /// No description provided for @driverEstimatedArrival.
  ///
  /// In pt_PT, this message translates to:
  /// **'Chegada estimada'**
  String get driverEstimatedArrival;

  /// No description provided for @driverStartNavigation.
  ///
  /// In pt_PT, this message translates to:
  /// **'Iniciar Navegação Agora'**
  String get driverStartNavigation;

  /// No description provided for @driverRequestExpiredTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Pedido Expirado'**
  String get driverRequestExpiredTitle;

  /// No description provided for @driverRequestExpiredMessage.
  ///
  /// In pt_PT, this message translates to:
  /// **'O tempo limite de 12 segundos para aceitar a viagem esgotou.'**
  String get driverRequestExpiredMessage;

  /// No description provided for @driverUnavailableForRequests.
  ///
  /// In pt_PT, this message translates to:
  /// **'Atualmente indisponível para novos pedidos'**
  String get driverUnavailableForRequests;

  /// No description provided for @driverBackToDashboard.
  ///
  /// In pt_PT, this message translates to:
  /// **'Voltar ao Dashboard'**
  String get driverBackToDashboard;

  /// No description provided for @driverViewTripHistory.
  ///
  /// In pt_PT, this message translates to:
  /// **'Ver Histórico de Viagens'**
  String get driverViewTripHistory;

  /// No description provided for @driverDistanceToDestination.
  ///
  /// In pt_PT, this message translates to:
  /// **'A {distance} do destino'**
  String driverDistanceToDestination(String distance);

  /// No description provided for @driverVipPassenger.
  ///
  /// In pt_PT, this message translates to:
  /// **'Passageiro VIP'**
  String get driverVipPassenger;

  /// No description provided for @driverEstimatedTimeLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'TEMPO ESTIMADO'**
  String get driverEstimatedTimeLabel;

  /// No description provided for @driverDistanceStatLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'DISTÂNCIA'**
  String get driverDistanceStatLabel;

  /// No description provided for @driverOnTheWay.
  ///
  /// In pt_PT, this message translates to:
  /// **'A caminho'**
  String get driverOnTheWay;

  /// No description provided for @driverArrivedStatus.
  ///
  /// In pt_PT, this message translates to:
  /// **'Chegou ao local'**
  String get driverArrivedStatus;

  /// No description provided for @driverTripInProgressStatus.
  ///
  /// In pt_PT, this message translates to:
  /// **'Viagem em curso'**
  String get driverTripInProgressStatus;

  /// No description provided for @driverArrivedButton.
  ///
  /// In pt_PT, this message translates to:
  /// **'Cheguei'**
  String get driverArrivedButton;

  /// No description provided for @driverStartTripButton.
  ///
  /// In pt_PT, this message translates to:
  /// **'Iniciar viagem'**
  String get driverStartTripButton;

  /// No description provided for @driverFinishTripButton.
  ///
  /// In pt_PT, this message translates to:
  /// **'Finalizar viagem'**
  String get driverFinishTripButton;

  /// No description provided for @adminReportsTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Relatórios Detalhados'**
  String get adminReportsTitle;

  /// No description provided for @adminReportsExport.
  ///
  /// In pt_PT, this message translates to:
  /// **'Exportar'**
  String get adminReportsExport;

  /// No description provided for @adminReportsDateRangeLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Intervalo de Datas'**
  String get adminReportsDateRangeLabel;

  /// No description provided for @adminReportsVehicleFleetLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Veículo / Frota'**
  String get adminReportsVehicleFleetLabel;

  /// No description provided for @adminReportsAllVehicles.
  ///
  /// In pt_PT, this message translates to:
  /// **'Todos os Veículos'**
  String get adminReportsAllVehicles;

  /// No description provided for @adminReportsTotalTrips.
  ///
  /// In pt_PT, this message translates to:
  /// **'Total de Viagens'**
  String get adminReportsTotalTrips;

  /// No description provided for @adminReportsTotalDistance.
  ///
  /// In pt_PT, this message translates to:
  /// **'Distância Total'**
  String get adminReportsTotalDistance;

  /// No description provided for @adminReportsTimeOnRoute.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tempo em Rota'**
  String get adminReportsTimeOnRoute;

  /// No description provided for @adminReportsTotalCost.
  ///
  /// In pt_PT, this message translates to:
  /// **'Custo Total'**
  String get adminReportsTotalCost;

  /// No description provided for @adminReportsPendingDebt.
  ///
  /// In pt_PT, this message translates to:
  /// **'Dívida Pendente'**
  String get adminReportsPendingDebt;

  /// No description provided for @adminReportsOverdueInvoices.
  ///
  /// In pt_PT, this message translates to:
  /// **'FATURAS EM ATRASO'**
  String get adminReportsOverdueInvoices;

  /// No description provided for @adminReportsMonthlyPerformance.
  ///
  /// In pt_PT, this message translates to:
  /// **'Análise de Performance Mensal'**
  String get adminReportsMonthlyPerformance;

  /// No description provided for @adminReportsChartHint.
  ///
  /// In pt_PT, this message translates to:
  /// **'Visualização detalhada das tendências de custo e quilometragem do período selecionado.'**
  String get adminReportsChartHint;

  /// No description provided for @adminReportsLatestActivities.
  ///
  /// In pt_PT, this message translates to:
  /// **'ÚLTIMAS ATIVIDADES'**
  String get adminReportsLatestActivities;

  /// No description provided for @adminReportsFleetEfficiency.
  ///
  /// In pt_PT, this message translates to:
  /// **'EFICIÊNCIA DA FROTA'**
  String get adminReportsFleetEfficiency;

  /// No description provided for @adminReportsOptimizedStatus.
  ///
  /// In pt_PT, this message translates to:
  /// **'OTIMIZADO'**
  String get adminReportsOptimizedStatus;

  /// No description provided for @adminReportsOptimized.
  ///
  /// In pt_PT, this message translates to:
  /// **'{percent}% OTIMIZADO'**
  String adminReportsOptimized(int percent);

  /// No description provided for @adminReportsEfficiencyFooter.
  ///
  /// In pt_PT, this message translates to:
  /// **'A sua frota está a operar 15% acima da média do setor neste trimestre.'**
  String get adminReportsEfficiencyFooter;

  /// No description provided for @adminDrawerFleetManager.
  ///
  /// In pt_PT, this message translates to:
  /// **'Gestor de Frota'**
  String get adminDrawerFleetManager;

  /// No description provided for @adminDrawerFleetSubtitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Frota Central Lisboa'**
  String get adminDrawerFleetSubtitle;

  /// No description provided for @adminDrawerRoleBadge.
  ///
  /// In pt_PT, this message translates to:
  /// **'Admin'**
  String get adminDrawerRoleBadge;

  /// No description provided for @adminTariffNoTransportTypes.
  ///
  /// In pt_PT, this message translates to:
  /// **'Configure primeiro os tipos de transporte.'**
  String get adminTariffNoTransportTypes;

  /// No description provided for @adminTariffInvalidAmounts.
  ///
  /// In pt_PT, this message translates to:
  /// **'Introduza valores válidos.'**
  String get adminTariffInvalidAmounts;

  /// No description provided for @adminTariffInvalidBaseFare.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tarifa base inválida para {typeName}.'**
  String adminTariffInvalidBaseFare(String typeName);

  /// No description provided for @rentalAc.
  ///
  /// In pt_PT, this message translates to:
  /// **'AC'**
  String get rentalAc;

  /// No description provided for @rentalElectric.
  ///
  /// In pt_PT, this message translates to:
  /// **'Elétrico'**
  String get rentalElectric;

  /// No description provided for @rentalAllTypes.
  ///
  /// In pt_PT, this message translates to:
  /// **'Todos os tipos'**
  String get rentalAllTypes;

  /// No description provided for @rentalCarTypeSedan.
  ///
  /// In pt_PT, this message translates to:
  /// **'Sedan'**
  String get rentalCarTypeSedan;

  /// No description provided for @rentalCarTypeSuv.
  ///
  /// In pt_PT, this message translates to:
  /// **'SUV'**
  String get rentalCarTypeSuv;

  /// No description provided for @rentalCarTypeExecutive.
  ///
  /// In pt_PT, this message translates to:
  /// **'Executivo'**
  String get rentalCarTypeExecutive;

  /// No description provided for @rentalCarTypeElectric.
  ///
  /// In pt_PT, this message translates to:
  /// **'Elétrico'**
  String get rentalCarTypeElectric;

  /// No description provided for @rentalTransmissionAll.
  ///
  /// In pt_PT, this message translates to:
  /// **'Todas'**
  String get rentalTransmissionAll;

  /// No description provided for @rentalTransmissionAutomatic.
  ///
  /// In pt_PT, this message translates to:
  /// **'Automático'**
  String get rentalTransmissionAutomatic;

  /// No description provided for @rentalTransmissionManual.
  ///
  /// In pt_PT, this message translates to:
  /// **'Manual'**
  String get rentalTransmissionManual;

  /// No description provided for @rentalAnyPrice.
  ///
  /// In pt_PT, this message translates to:
  /// **'Qualquer preço'**
  String get rentalAnyPrice;

  /// No description provided for @rentalPriceUpTo.
  ///
  /// In pt_PT, this message translates to:
  /// **'Até {price}'**
  String rentalPriceUpTo(String price);

  /// No description provided for @driverEnRouteEtaAt.
  ///
  /// In pt_PT, this message translates to:
  /// **'ETA • {time}'**
  String driverEnRouteEtaAt(String time);

  /// No description provided for @rentalWeekdaySun.
  ///
  /// In pt_PT, this message translates to:
  /// **'DOM'**
  String get rentalWeekdaySun;

  /// No description provided for @rentalWeekdayMon.
  ///
  /// In pt_PT, this message translates to:
  /// **'SEG'**
  String get rentalWeekdayMon;

  /// No description provided for @rentalWeekdayTue.
  ///
  /// In pt_PT, this message translates to:
  /// **'TER'**
  String get rentalWeekdayTue;

  /// No description provided for @rentalWeekdayWed.
  ///
  /// In pt_PT, this message translates to:
  /// **'QUA'**
  String get rentalWeekdayWed;

  /// No description provided for @rentalWeekdayThu.
  ///
  /// In pt_PT, this message translates to:
  /// **'QUI'**
  String get rentalWeekdayThu;

  /// No description provided for @rentalWeekdayFri.
  ///
  /// In pt_PT, this message translates to:
  /// **'SEX'**
  String get rentalWeekdayFri;

  /// No description provided for @rentalWeekdaySat.
  ///
  /// In pt_PT, this message translates to:
  /// **'SÁB'**
  String get rentalWeekdaySat;

  /// No description provided for @rentalDemoPickupLocation.
  ///
  /// In pt_PT, this message translates to:
  /// **'Aeroporto de Lisboa, PT'**
  String get rentalDemoPickupLocation;

  /// No description provided for @rentalDriverAgeYoung.
  ///
  /// In pt_PT, this message translates to:
  /// **'18 - 25 anos'**
  String get rentalDriverAgeYoung;

  /// No description provided for @rentalDriverAgeStandard.
  ///
  /// In pt_PT, this message translates to:
  /// **'26 - 65 anos'**
  String get rentalDriverAgeStandard;

  /// No description provided for @rentalDriverAgeSenior.
  ///
  /// In pt_PT, this message translates to:
  /// **'65+ anos'**
  String get rentalDriverAgeSenior;

  /// No description provided for @rentalDemoSportPremium.
  ///
  /// In pt_PT, this message translates to:
  /// **'DESPORTIVO PREMIUM'**
  String get rentalDemoSportPremium;

  /// No description provided for @rentalDemoVehicleName.
  ///
  /// In pt_PT, this message translates to:
  /// **'Porsche Taycan 4S'**
  String get rentalDemoVehicleName;

  /// No description provided for @rentalInsuranceDescription.
  ///
  /// In pt_PT, this message translates to:
  /// **'Proteção total contra danos próprios e assistência em viagem 24/7 sem custos adicionais.'**
  String get rentalInsuranceDescription;

  /// No description provided for @rentalInsuranceFranchiseWaiver.
  ///
  /// In pt_PT, this message translates to:
  /// **'Isenção de Franquia'**
  String get rentalInsuranceFranchiseWaiver;

  /// No description provided for @rentalInsuranceCdw.
  ///
  /// In pt_PT, this message translates to:
  /// **'Danos de Colisão (CDW)'**
  String get rentalInsuranceCdw;

  /// No description provided for @rentalFuelPolicyElectric.
  ///
  /// In pt_PT, this message translates to:
  /// **'Política de Cheio/Cheio ou devolução com carga superior a 80% para veículos elétricos.'**
  String get rentalFuelPolicyElectric;

  /// No description provided for @rentalBookingRentalDays.
  ///
  /// In pt_PT, this message translates to:
  /// **'Aluguer ({days} dias)'**
  String rentalBookingRentalDays(int days);

  /// No description provided for @rentalBookingPremiumInsurance.
  ///
  /// In pt_PT, this message translates to:
  /// **'Seguro Premium'**
  String get rentalBookingPremiumInsurance;

  /// No description provided for @rentalBookingIncluded.
  ///
  /// In pt_PT, this message translates to:
  /// **'Incluído'**
  String get rentalBookingIncluded;

  /// No description provided for @rentalBookingAirportFees.
  ///
  /// In pt_PT, this message translates to:
  /// **'Taxas de aeroporto'**
  String get rentalBookingAirportFees;

  /// No description provided for @rentalDemoAirportLocation.
  ///
  /// In pt_PT, this message translates to:
  /// **'Aeroporto de Lisboa, LIS'**
  String get rentalDemoAirportLocation;

  /// No description provided for @rentalSpecPower.
  ///
  /// In pt_PT, this message translates to:
  /// **'Potência'**
  String get rentalSpecPower;

  /// No description provided for @rentalSpecPowerValue.
  ///
  /// In pt_PT, this message translates to:
  /// **'530 cv'**
  String get rentalSpecPowerValue;

  /// No description provided for @rentalSpecRange.
  ///
  /// In pt_PT, this message translates to:
  /// **'Autonomia WLTP'**
  String get rentalSpecRange;

  /// No description provided for @rentalSpecRangeValue.
  ///
  /// In pt_PT, this message translates to:
  /// **'463 km'**
  String get rentalSpecRangeValue;

  /// No description provided for @rentalSpecDrive.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tração'**
  String get rentalSpecDrive;

  /// No description provided for @rentalSpecDriveValue.
  ///
  /// In pt_PT, this message translates to:
  /// **'Integral (AWD)'**
  String get rentalSpecDriveValue;

  /// No description provided for @rentalVehicleSummary.
  ///
  /// In pt_PT, this message translates to:
  /// **'{price} · {seats} · {transmission}'**
  String rentalVehicleSummary(String price, String seats, String transmission);

  /// No description provided for @eventDemoGenre.
  ///
  /// In pt_PT, this message translates to:
  /// **'MÚSICA ELETRÓNICA'**
  String get eventDemoGenre;

  /// No description provided for @eventDemoTitle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Gala de Verão: Porto Sunset'**
  String get eventDemoTitle;

  /// No description provided for @eventDemoDescription.
  ///
  /// In pt_PT, this message translates to:
  /// **'Prepare-se para a noite mais exclusiva do ano. A Gala de Verão no Porto combina o melhor da música eletrónica melódica com uma vista deslumbrante sobre o Rio Douro. O evento contará com serviço de catering premium, áreas lounge VIP e uma experiência audiovisual imersiva sem precedentes na cidade.'**
  String get eventDemoDescription;

  /// No description provided for @eventDemoVenue.
  ///
  /// In pt_PT, this message translates to:
  /// **'Alfândega do Porto'**
  String get eventDemoVenue;

  /// No description provided for @eventPaymentMbway.
  ///
  /// In pt_PT, this message translates to:
  /// **'MBWAY'**
  String get eventPaymentMbway;

  /// No description provided for @discoverMapRestaurantLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Restaurante Maré'**
  String get discoverMapRestaurantLabel;

  /// No description provided for @discoverMapBeachLabel.
  ///
  /// In pt_PT, this message translates to:
  /// **'Praia Secreta'**
  String get discoverMapBeachLabel;

  /// No description provided for @reservationDemoVehicleName.
  ///
  /// In pt_PT, this message translates to:
  /// **'Tesla Model 3 Performance'**
  String get reservationDemoVehicleName;

  /// No description provided for @reservationDemoVehicleSpecs.
  ///
  /// In pt_PT, this message translates to:
  /// **'{powertrain} • {seats} • {transmission}'**
  String reservationDemoVehicleSpecs(
    String powertrain,
    String seats,
    String transmission,
  );

  /// No description provided for @reservationDemoAirport.
  ///
  /// In pt_PT, this message translates to:
  /// **'Aeroporto de Lisboa (LIS)'**
  String get reservationDemoAirport;

  /// No description provided for @reservationDemoPickupDateTime.
  ///
  /// In pt_PT, this message translates to:
  /// **'15 Out, 2023 às 10:00'**
  String get reservationDemoPickupDateTime;

  /// No description provided for @reservationDemoReturnDateTime.
  ///
  /// In pt_PT, this message translates to:
  /// **'20 Out, 2023 às 18:00'**
  String get reservationDemoReturnDateTime;

  /// No description provided for @reservationRentalDaysLine.
  ///
  /// In pt_PT, this message translates to:
  /// **'Aluguer ({days} dias)'**
  String reservationRentalDaysLine(int days);

  /// No description provided for @reservationInsuranceLine.
  ///
  /// In pt_PT, this message translates to:
  /// **'Seguro total'**
  String get reservationInsuranceLine;

  /// No description provided for @reservationDefaultVehicle.
  ///
  /// In pt_PT, this message translates to:
  /// **'Veículo'**
  String get reservationDefaultVehicle;

  /// No description provided for @reservationDefaultCity.
  ///
  /// In pt_PT, this message translates to:
  /// **'Lisboa'**
  String get reservationDefaultCity;
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
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'PT':
            return AppLocalizationsPtPt();
        }
        break;
      }
  }

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
