// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appNameLocalTransport => 'Local Transport';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get signOut => 'Salir';

  @override
  String get signOutTitle => 'Cerrar sesión';

  @override
  String get signOutConfirmMessage => '¿Seguro que desea salir de su cuenta?';

  @override
  String get signOutFailed =>
      'No se pudo cerrar la sesión. Inténtelo de nuevo.';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String featureComingSoon(String feature) {
    return '$feature estará disponible pronto.';
  }

  @override
  String get navHome => 'Inicio';

  @override
  String get navTrips => 'Viajes';

  @override
  String get navReservations => 'Reservas';

  @override
  String get navBalance => 'Saldo';

  @override
  String get navProfile => 'Perfil';

  @override
  String get loginSubtitle => 'Inicie sesión para gestionar sus viajes.';

  @override
  String get loginSettingsTooltip => 'Ajustes';

  @override
  String get loginEmailOrMobileLabel => 'Correo o móvil';

  @override
  String get loginEmailHint => 'ej.: joao@email.com';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginForgotPassword => '¿Olvidó?';

  @override
  String get loginFillEmailPassword => 'Introduzca correo y contraseña.';

  @override
  String get loginNoAccountPrompt => '¿Aún no tiene cuenta? ';

  @override
  String get loginRegisterNow => 'Registrarse ahora';

  @override
  String get loginPrivacy => 'Privacidad';

  @override
  String get loginTermsOfUse => 'Términos de uso';

  @override
  String get loginSupport => 'Soporte';

  @override
  String get loginRoleClient => 'Cliente';

  @override
  String get loginRoleProfessional => 'Profesional';

  @override
  String get secureConnectionE2E =>
      'Conexión segura cifrada de extremo a extremo.';

  @override
  String get authErrorUnexpected =>
      'Ocurrió un error inesperado. Inténtelo de nuevo.';

  @override
  String get authErrorProfileNotFound => 'Perfil de usuario no encontrado.';

  @override
  String get authErrorAccountInactive =>
      'Esta cuenta está inactiva. Contacte con soporte.';

  @override
  String get authErrorRoleMismatch =>
      'El perfil no coincide con el tipo seleccionado.';

  @override
  String get authErrorInvalidEmail => 'Correo no válido.';

  @override
  String get authErrorUserDisabled => 'Esta cuenta está desactivada.';

  @override
  String get authErrorWrongCredentials => 'Correo o contraseña incorrectos.';

  @override
  String get authErrorTooManyRequests =>
      'Demasiados intentos. Inténtelo más tarde.';

  @override
  String get authErrorSignInFailed =>
      'No se pudo iniciar sesión. Inténtelo de nuevo.';

  @override
  String get authErrorEmailInUse => 'Este correo ya está registrado.';

  @override
  String get authErrorWeakPassword =>
      'Contraseña demasiado débil. Use al menos 6 caracteres.';

  @override
  String get authErrorRegistrationFailed =>
      'No se pudo crear la cuenta. Inténtelo de nuevo.';

  @override
  String get registerSubtitle =>
      'Cree su cuenta como cliente o conductor profesional.';

  @override
  String get registerNameLabel => 'Nombre completo';

  @override
  String get registerNameHint => 'ej. Juan García';

  @override
  String get registerPhoneLabel => 'Teléfono (opcional)';

  @override
  String get registerPhoneHint => 'ej. +351910000000';

  @override
  String get registerConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get registerFillRequiredFields =>
      'Complete nombre, correo y contraseña.';

  @override
  String get registerPasswordTooShort =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get registerPasswordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get registerAlreadyHaveAccount => '¿Ya tiene cuenta? ';

  @override
  String get registerSignInNow => 'Iniciar sesión';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSubtitle =>
      'Ajuste preferencias y mantenga la app lista para usted.';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageDescription =>
      'Elija el idioma de la aplicación. Puede restablecer el idioma del dispositivo en cualquier momento.';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguagePortuguese => 'Portugués (Portugal)';

  @override
  String settingsLanguageFollowingDevice(String language) {
    return 'Siguiendo el idioma del dispositivo ($language).';
  }

  @override
  String settingsLanguageManual(String language) {
    return 'Idioma seleccionado manualmente: $language.';
  }

  @override
  String get settingsLanguageResetSnack =>
      'Idioma restablecido al del dispositivo.';

  @override
  String get settingsUseDeviceLanguage => 'Restablecer idioma del dispositivo';

  @override
  String get settingsDisplayCurrency => 'Moneda de visualización';

  @override
  String get settingsDisplayCurrencyDescription =>
      'Elija la moneda en la que desea ver los importes en toda la aplicación.';

  @override
  String get settingsCurrencyCve => 'Escudo caboverdiano (CVE)';

  @override
  String get settingsCurrencyEur => 'Euro (€)';

  @override
  String get settingsCurrencyUsd => 'Dólar estadounidense (USD)';

  @override
  String get settingsAccountSection => 'Cuenta';

  @override
  String get settingsChangePassword => 'Cambiar contraseña';

  @override
  String get settingsSignOutAction => 'Cerrar sesión';

  @override
  String get settingsSignOutLoading => 'Cerrando sesión...';

  @override
  String get settingsDeveloperSection => 'Herramientas de desarrollador';

  @override
  String get settingsDriverLocationSimulationTitle =>
      'Simulación de ubicación (demo)';

  @override
  String get settingsDriverLocationSimulationDescription =>
      'Disponible solo en compilaciones de desarrollo. En el dispositivo del conductor, publica movimiento simulado hacia la recogida en el viaje activo, sin marcar llegada automáticamente.';

  @override
  String get settingsDriverLocationSimulationSwitchLabel =>
      'Simular movimiento del conductor';

  @override
  String get settingsResetOnboarding => 'Restablecer onboarding';

  @override
  String get settingsResetDone => 'Onboarding restablecido.';

  @override
  String get settingsDeveloperDebugOnly =>
      'Sección visible solo en compilaciones de depuración.';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileDefaultUserName => 'Usuario';

  @override
  String get profileSessionNotFound =>
      'Sesión no encontrada. Inicie sesión de nuevo.';

  @override
  String get profileLoadFailed =>
      'No se pudo cargar el perfil. Inténtelo de nuevo.';

  @override
  String get profileRoleClient => 'Usuario';

  @override
  String get profileRoleDriver => 'Conductor';

  @override
  String get profileRoleAdmin => 'Administrador';

  @override
  String get profilePhone => 'Teléfono';

  @override
  String get profilePhoneNotSet => 'No definido';

  @override
  String get profileAccountType => 'Tipo de cuenta';

  @override
  String get profileStatus => 'Estado';

  @override
  String get profileStatusActive => 'Activa';

  @override
  String get profileStatusInactive => 'Inactiva';

  @override
  String get profileMenuSettings => 'Ajustes';

  @override
  String get profileSessionSection => 'Sesión';

  @override
  String get profileGoToLogin => 'Ir al inicio de sesión';

  @override
  String get profileChangePhoto => 'Cambiar foto de perfil';

  @override
  String get profilePhotoFromGallery => 'Elegir de la galería';

  @override
  String get profilePhotoTakePhoto => 'Tomar foto';

  @override
  String get profilePhotoUpdated => 'Foto de perfil actualizada';

  @override
  String get profilePhotoUpdateFailed =>
      'No se pudo actualizar la foto. Inténtelo de nuevo.';

  @override
  String get profilePhotoPermissionDenied =>
      'No tienes permiso para subir la foto. Contacta con soporte si el problema persiste.';

  @override
  String get profilePhotoUploading => 'Subiendo foto...';

  @override
  String get profileEditName => 'Editar nombre';

  @override
  String get profileNameHint => 'Su nombre';

  @override
  String get profileNameUpdated => 'Nombre actualizado';

  @override
  String get profileNameUpdateFailed =>
      'No se pudo actualizar el nombre. Inténtelo de nuevo.';

  @override
  String get profileNamePermissionDenied =>
      'No se pudo actualizar el nombre. Comprueba tu sesión o contacta con soporte.';

  @override
  String get profileNameEmpty => 'Introduzca su nombre.';

  @override
  String get homeAvailableBalance => 'Saldo disponible';

  @override
  String get homeTopUp => 'Ver saldo';

  @override
  String get homeActionRequest => 'Pedir';

  @override
  String get homeActionBook => 'Reservar';

  @override
  String get homeActionRent => 'Alquilar';

  @override
  String get homeActionHistory => 'Historial';

  @override
  String get homeActionBalance => 'Saldo';

  @override
  String get clientBalanceTitle => 'Saldo';

  @override
  String get clientBalanceSubtitle =>
      'Saldo de tu cuenta actualizado en tiempo real.';

  @override
  String get clientBalanceDebtLimit => 'Límite de deuda';

  @override
  String get clientBalanceLastUpdated => 'Última actualización';

  @override
  String get clientBalanceHistoryTitle => 'Ajustes recientes';

  @override
  String get clientBalanceHistoryEmpty => 'Sin ajustes todavía';

  @override
  String get clientBalanceHistoryEmptyBody =>
      'Los cambios de saldo del admin aparecerán aquí.';

  @override
  String get clientBalanceAdjustmentDefault => 'Ajuste de saldo';

  @override
  String get clientBalanceDebtWarningTitle => 'Límite de deuda alcanzado';

  @override
  String get clientBalanceDebtWarningBody =>
      'Contacta con soporte para recargar el saldo y seguir reservando viajes.';

  @override
  String get clientBalanceTopUpTitle => 'Cómo recargar';

  @override
  String get clientBalanceTopUpBody =>
      'La recarga del saldo la gestiona soporte. Llama para solicitar crédito — aparecerá aquí tras la aprobación del administrador.';

  @override
  String get clientBalanceContactSupport => 'Contactar soporte';

  @override
  String get clientBalanceSupportUnavailable =>
      'Teléfono de soporte no disponible. Contacta con el equipo de soporte.';

  @override
  String get clientBalanceSupportCallFailed =>
      'No se pudo abrir el marcador telefónico en este dispositivo.';

  @override
  String get tripConfirmLimitExceededCallSupport => 'Llamar a soporte';

  @override
  String get clientBalanceUnavailable => 'Saldo no disponible';

  @override
  String get homeWhereToday => '¿Adónde vamos hoy?';

  @override
  String get homeCurrentLocation => 'Ubicación actual';

  @override
  String get homeDestination => 'Destino';

  @override
  String get homeDestinationHint => '¿Adónde desea ir?';

  @override
  String get homeConfirmRoute => 'Confirmar trayecto';

  @override
  String get homeLocationLoading => 'Obteniendo su ubicación...';

  @override
  String get homeLocationUnavailable => 'No se pudo obtener la ubicación';

  @override
  String get homeRefreshLocation => 'Actualizar ubicación';

  @override
  String get homeSelectLocationOnMap => 'Seleccionar en el mapa';

  @override
  String get homeSelectLocationOnMapHint =>
      'Mueva el mapa o toque el botón de ubicación para usar su posición actual.';

  @override
  String get homeUseMapLocation => 'Usar esta ubicación';

  @override
  String get homeLocationPermissionTitle => 'Permitir ubicación';

  @override
  String get homeLocationPermissionMessage =>
      'Local Transport necesita su ubicación para establecer automáticamente el punto de recogida.';

  @override
  String get homeLocationPermissionAllow => 'Permitir';

  @override
  String get homeLocationPermissionDeny => 'Ahora no';

  @override
  String get homeLocationPermissionSettingsMessage =>
      'El permiso de ubicación está desactivado. Abra los ajustes para permitir el acceso.';

  @override
  String get homeLocationOpenSettings => 'Abrir ajustes';

  @override
  String get homeLocationServicesDisabled =>
      'Active los servicios de ubicación en el dispositivo para usar su dirección actual.';

  @override
  String get reservationsTitle => 'Reservas';

  @override
  String get reservationsSubtitle => 'Gestione sus próximos viajes';

  @override
  String get reservationsNew => 'Nueva reserva';

  @override
  String get reservationsPickup => 'Recogida';

  @override
  String get reservationsDestination => 'Destino';

  @override
  String get reservationsDetails => 'Detalles';

  @override
  String get reservationsCancel => 'Cancelar';

  @override
  String get reservationsStatusConfirmed => 'Confirmada';

  @override
  String get reservationsStatusPending => 'Pendiente';

  @override
  String get tripHistoryTitle => 'Historial de viajes';

  @override
  String get tripHistoryDetails => 'Detalles';

  @override
  String get tripDetailsSummary => 'Resumen del viaje';

  @override
  String get tripDetailsStatusCompleted => 'Completada';

  @override
  String get rentalTitle => 'Alquiler de vehículos';

  @override
  String get rentalSubtitle =>
      'Encuentre el socio perfecto para su próximo viaje.';

  @override
  String get rentalSearchAvailable => 'Buscar vehículos disponibles';

  @override
  String get driverSearchTitle => 'Buscando conductor disponible';

  @override
  String get driverFoundTitle => 'Conductor encontrado';

  @override
  String get driverEnRouteStatus => 'Conductor en camino';

  @override
  String get tripInProgressEndTrip => 'Finalizar viaje';

  @override
  String get tripInProgressSupport => 'Soporte';

  @override
  String get tripCompletedTitle => '¡Viaje completado!';

  @override
  String get tripCompletedBackHome => 'Volver al inicio';

  @override
  String get premiumHomeOrderNow => 'Pedir ahora';

  @override
  String get support => 'Soporte';

  @override
  String get destination => 'Destino';

  @override
  String get details => 'Detalles';

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
  String get quantity => 'Cantidad';

  @override
  String get distance => 'Distancia';

  @override
  String get duration => 'Duración';

  @override
  String get premium => 'Premium';

  @override
  String get newBadge => 'Nuevo';

  @override
  String get promotion => 'Promoción';

  @override
  String get free => 'Gratis';

  @override
  String get live => 'LIVE';

  @override
  String get verified => 'Verificado';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get splashSecureConnection => 'Conexión segura y cifrada';

  @override
  String get splashExecutiveBadge => 'EJECUTIVO';

  @override
  String get splashHeroTitle => 'Su tiempo,\nvalorado.';

  @override
  String get splashHeroSubtitle =>
      'Transporte personalizado con confort y puntualidad.';

  @override
  String get splashInstantBookingTitle => 'Reservas instantáneas';

  @override
  String get splashInstantBookingSubtitle =>
      'Planifique su viaje en segundos con nuestra red exclusiva.';

  @override
  String get splashDriverOfToday => 'CONDUCTOR DE HOY';

  @override
  String get adminAppBarTitle => 'Local Transport';

  @override
  String get adminFleetStatusTitle => 'Estado de la flota';

  @override
  String get adminFleetStatusUpdated => 'Actualizado: Ahora';

  @override
  String adminFleetStatusUpdatedAt(String time) {
    return 'Actualizado: $time';
  }

  @override
  String get adminActiveTripsLabel => 'Viajes activos';

  @override
  String get adminActiveTripsTrend => '+12% vs. ayer';

  @override
  String get adminAvailableDriversLabel => 'Conductores disponibles';

  @override
  String get adminAvailableDriversHint => 'Listo para despacho';

  @override
  String get adminCriticalOpsTitle => 'Operaciones críticas';

  @override
  String get adminPendingDebtorsTitle => 'Deudores pendientes';

  @override
  String get adminPendingDebtorsSubtitle => '3 facturas vencidas';

  @override
  String adminPendingDebtorsCount(int count) {
    return '$count facturas vencidas';
  }

  @override
  String adminActiveTripsTrendDynamic(String change) {
    return '$change vs. ayer';
  }

  @override
  String get adminNoFleetVehicles => 'Aún no hay vehículos en la flota';

  @override
  String get adminNoReportActivities => 'Aún no hay viajes completados';

  @override
  String adminBaseRateLive(String multiplier) {
    return 'Dinámica: Activa ($multiplier)';
  }

  @override
  String get adminMonthlyReportsTitle => 'Informes mensuales';

  @override
  String get adminMonthlyReportsSubtitle => 'Rendimiento de octubre';

  @override
  String get adminActivityMapTitle => 'Mapa de actividad';

  @override
  String get adminActivityMapWaiting =>
      'Esperando viajes y ubicaciones en vivo';

  @override
  String get adminRatesTitle => 'Tarifas y mercado';

  @override
  String get adminBaseRateLabel => 'Tarifa base';

  @override
  String get adminBaseRateDynamic => 'Dinámica: Activa (1.2x)';

  @override
  String get adminFuelCostLabel => 'Costo combustible';

  @override
  String get adminFuelCostHint => 'Media nacional';

  @override
  String get adminRecentFleetTitle => 'Flota reciente';

  @override
  String get adminFleetStatusOnTrip => 'En viaje';

  @override
  String get adminFleetStatusInactive => 'Inactivo';

  @override
  String adminFleetDriverPrefix(String name) {
    return 'Conductor: $name';
  }

  @override
  String get adminHubTitle => 'Área de administración';

  @override
  String get adminHubHeading => 'Área de administración';

  @override
  String get adminHubSubtitle =>
      'Gestionar operaciones, flota, tarifas y soporte.';

  @override
  String get adminUsersTitle => 'Usuarios';

  @override
  String get adminUsersDesc => 'Gestión de cuentas y permisos.';

  @override
  String get adminUsersHeading => 'Gestión de cuentas y permisos';

  @override
  String get adminUsersSubtitle =>
      'Gestionar perfiles, roles y accesos del equipo.';

  @override
  String get adminUsersSearchHint => 'Buscar por nombre, email, teléfono o ID';

  @override
  String get adminUsersEmpty => 'No se encontraron usuarios';

  @override
  String get adminUsersCreateTitle => 'Agregar usuario';

  @override
  String get adminUsersCreateSubtitle =>
      'Crear cuenta de cliente, conductor, gestor o admin.';

  @override
  String get adminUsersCreateAction => 'Crear usuario';

  @override
  String get adminUsersCreateSuccess => 'Usuario creado correctamente';

  @override
  String get adminUsersCreateFailed => 'No se pudo crear el usuario';

  @override
  String get adminUsersRoleLabel => 'Rol';

  @override
  String get adminUsersAddTooltip => 'Agregar usuario';

  @override
  String get adminStatusActive => 'Activo';

  @override
  String get adminStatusInactive => 'Inactivo';

  @override
  String get adminStatusOpen => 'Abierto';

  @override
  String get adminStatusResolved => 'Resuelto';

  @override
  String get adminStatusConfigured => 'Configurado';

  @override
  String get adminManagerPermissionsTitle => 'Permisos de gestor';

  @override
  String get adminManagerPermissionsDesc =>
      'Configurar permisos operativos por gestor.';

  @override
  String get adminManagerPermissionsHeading =>
      'Configuración de permisos operativos';

  @override
  String get adminManagerPermissionsSubtitle =>
      'Configure módulos y acciones permitidas por gestor.';

  @override
  String get adminManagersEmpty => 'No se encontraron gestores';

  @override
  String get adminStatusUnconfigured => 'No configurado';

  @override
  String get adminManagerPermissionsSaveAction => 'Guardar permisos';

  @override
  String get adminManagerPermissionsSaveSuccess =>
      'Permisos del gestor guardados';

  @override
  String get adminManagerPermissionsSaveError =>
      'No se pudieron guardar los permisos';

  @override
  String get managerPermissionViewTrips => 'Ver viajes';

  @override
  String get managerPermissionViewReports => 'Ver informes';

  @override
  String get managerPermissionViewAudit => 'Ver auditoría';

  @override
  String get managerPermissionViewDrivers => 'Ver conductores';

  @override
  String get managerPermissionViewClients => 'Ver clientes';

  @override
  String get managerPermissionViewSupportRequests =>
      'Ver solicitudes de soporte';

  @override
  String get managerPermissionManageClientChats =>
      'Gestionar chats de clientes';

  @override
  String get managerPermissionCancelTripBySupport =>
      'Cancelar viaje por soporte';

  @override
  String get managerPermissionUpdateTripSupport =>
      'Actualizar soporte del viaje';

  @override
  String get managerPermissionResolvePasswordHelpRequest =>
      'Resolver solicitudes de ayuda de contraseña';

  @override
  String get managerPermissionManageEvents => 'Gestionar eventos';

  @override
  String get managerPermissionAssignVehicleToDriver => 'Asignar vehículo';

  @override
  String get managerPermissionEditDriverStatus => 'Editar estado del conductor';

  @override
  String get managerPermissionManageTariffs => 'Gestionar tarifas';

  @override
  String get managerPermissionManageTripPackages =>
      'Gestionar paquetes de viaje';

  @override
  String get adminSupportRequestsTitle => 'Tickets de soporte';

  @override
  String get adminSupportRequestsDesc =>
      'Bandeja de soporte y ayuda de contraseña.';

  @override
  String get adminSupportEmpty => 'Sin solicitudes de soporte';

  @override
  String get adminIncidentsTitle => 'Incidentes operativos';

  @override
  String get adminIncidentsDesc => 'Incidentes de monitoreo y aprobaciones.';

  @override
  String get adminIncidentsEmpty => 'Sin incidentes operativos';

  @override
  String get adminIncidentDetailTitle => 'Detalles del incidente';

  @override
  String get adminIncidentCurrentState => 'Estado actual';

  @override
  String get adminIncidentTrip => 'Viaje';

  @override
  String get adminIncidentStarted => 'Iniciado';

  @override
  String get adminIncidentRouteSummary => 'Resumen de ruta';

  @override
  String get adminIncidentKmSummary => 'Resumen de km';

  @override
  String get adminMonitoringTitle => 'Ajustes de monitoreo';

  @override
  String get adminMonitoringDesc => 'Umbrales para monitoreo operativo.';

  @override
  String get adminMonitoringHeading => 'Monitoreo operativo';

  @override
  String get adminMonitoringSubtitle =>
      'Revisar los límites de monitorización operativa.';

  @override
  String get adminMonitoringConfig => 'Configuración actual';

  @override
  String get adminMonitoringLoading => 'Cargando configuración de monitoreo...';

  @override
  String get adminMonitoringEnabled => 'Monitoreo activo';

  @override
  String get adminMonitoringEnabledHint =>
      'El monitoreo operacional solo funciona cuando está activo.';

  @override
  String get adminMonitoringBaseGeofence => 'Geocerca base';

  @override
  String get adminMonitoringServiceGeofences => 'Geocercas de servicio';

  @override
  String adminMonitoringServiceGeofenceCount(int count) {
    return '$count configuradas';
  }

  @override
  String get adminMonitoringLastUpdated => 'Última actualización';

  @override
  String get adminMonitoringSaveSuccess =>
      'Configuración de monitoreo guardada';

  @override
  String get adminReservationsTitle => 'Reservas operativas';

  @override
  String get adminReservationsDesc => 'Programar viajes futuros para clientes.';

  @override
  String get adminReservationsEmpty => 'Sin reservas';

  @override
  String get adminSupportSettingsTitle => 'Contacto de soporte';

  @override
  String get adminSupportSettingsDesc =>
      'Teléfono oficial para recuperación de contraseña.';

  @override
  String get adminSupportSettingsHeading => 'Contacto de soporte';

  @override
  String get adminSupportSettingsSubtitle =>
      'Definir el número oficial de contacto.';

  @override
  String get adminSupportPhoneLabel => 'Teléfono de soporte';

  @override
  String get adminEventsTitle => 'Eventos y alertas';

  @override
  String get adminEventsDesc => 'Enviar recordatorios y avisos a conductores.';

  @override
  String get adminEventsEmpty => 'Sin eventos programados';

  @override
  String get adminFleetTitle => 'Flota';

  @override
  String get adminFleetDesc => 'Seguir vehículos, estado y disponibilidad.';

  @override
  String get adminFleetNoDriver => 'Sin conductor asignado';

  @override
  String get adminFleetDriver => 'Conductor';

  @override
  String get adminFleetAssignDriverTitle => 'Asignar conductor';

  @override
  String get adminFleetAssignDriverDesc =>
      'Seleccione un conductor para este vehículo.';

  @override
  String get adminFleetAssignDriverEmpty =>
      'No se encontraron conductores activos.';

  @override
  String get adminFleetAssignDriverSuccess =>
      'Conductor asignado correctamente.';

  @override
  String get adminTransportTypesTitle => 'Tipos de transporte';

  @override
  String get adminTransportTypesDesc => 'Crear y gestionar tipos disponibles.';

  @override
  String get adminTransportTypesEmpty => 'Sin tipos de transporte';

  @override
  String get adminTripPackagesTitle => 'Paquetes de viaje';

  @override
  String get adminTripPackagesDesc =>
      'Paquetes prepago con destino y precio fijos.';

  @override
  String get adminTripPackagesEmpty => 'Sin paquetes de viaje';

  @override
  String get adminTariffsTitle => 'Tarifas';

  @override
  String get adminTariffsDesc =>
      'Definir precios, reglas y ajustes estacionales.';

  @override
  String get adminTariffAdminDefault => 'Tarifa admin default';

  @override
  String get adminTariffPublicDefault => 'Tarifa public default';

  @override
  String get adminBalancesTitle => 'Gestionar saldos';

  @override
  String get adminBalancesDesc =>
      'Ver, añadir, quitar y definir saldos de clientes.';

  @override
  String get adminBalancesEmpty => 'No se encontraron clientes';

  @override
  String get adminBalancesNoResults =>
      'Ningún cliente coincide con la búsqueda.';

  @override
  String get adminBalancesNoBalanceDoc => 'Sin saldo';

  @override
  String get adminBalancesDebt => 'Deuda';

  @override
  String get adminBalancesCredit => 'Crédito';

  @override
  String get adminBalancesSearchHint => 'Buscar cliente...';

  @override
  String get adminBalanceCurrent => 'Saldo actual';

  @override
  String get adminBalanceDebtLimit => 'Límite de deuda';

  @override
  String get adminBalanceAdjustAction => 'Gestionar saldo';

  @override
  String get adminBalanceAdjustTitle => 'Gestionar saldo del cliente';

  @override
  String get adminBalanceModeAdd => 'Añadir';

  @override
  String get adminBalanceModeRemove => 'Quitar';

  @override
  String get adminBalanceModeSet => 'Definir';

  @override
  String get adminBalanceCredit => 'Crédito';

  @override
  String get adminBalanceDebt => 'Débito';

  @override
  String get adminBalanceAddAmountLabel => 'Importe a añadir (EUR)';

  @override
  String get adminBalanceRemoveAmountLabel => 'Importe a quitar (EUR)';

  @override
  String get adminBalanceSetAmountLabel => 'Nuevo saldo (EUR)';

  @override
  String get adminBalanceAmountLabel => 'Valor (EUR)';

  @override
  String get adminBalanceAmountRequired => 'Introduce un valor válido.';

  @override
  String get adminBalanceReasonLabel => 'Motivo';

  @override
  String get adminBalanceReasonRequired => 'Introduce un motivo.';

  @override
  String get adminBalanceConfirm => 'Confirmar';

  @override
  String get adminBalanceAdjustSuccess => 'Saldo actualizado';

  @override
  String get adminVehicleCreateTitle => 'Nuevo vehículo';

  @override
  String get adminVehicleEditTitle => 'Editar vehículo';

  @override
  String get adminVehicleCreateAction => 'Crear vehículo';

  @override
  String get adminVehicleCreateSuccess => 'Vehículo creado';

  @override
  String get adminVehicleAddPhoto => 'Añadir foto';

  @override
  String get adminVehiclePlateLabel => 'Matrícula';

  @override
  String get adminVehicleModelLabel => 'Modelo';

  @override
  String get adminVehicleCapacityLabel => 'Capacidad';

  @override
  String get adminVehicleTransportTypeLabel =>
      'Tipo de transporte predeterminado';

  @override
  String get adminVehicleNoPreference => 'Sin preferencia';

  @override
  String get adminVehicleNotesLabel => 'Notas';

  @override
  String get adminVehicleActiveLabel => 'Vehículo activo';

  @override
  String get adminVehicleRequiredFields => 'Completa matrícula y modelo.';

  @override
  String get adminTransportTypeCreateTitle => 'Nuevo tipo de transporte';

  @override
  String get adminTransportTypeEditTitle => 'Editar tipo de transporte';

  @override
  String get adminTransportTypeCreateAction => 'Crear tipo';

  @override
  String get adminTransportTypeCreateSuccess => 'Tipo de transporte creado';

  @override
  String get adminTransportTypeNameLabel => 'Nombre';

  @override
  String get adminTransportTypeNameRequired => 'Introduce un nombre.';

  @override
  String get adminTransportTypeBaseFareLabel => 'Tarifa base inicial';

  @override
  String get adminTransportTypeMultiplierLabel =>
      'Ajuste de precio del package';

  @override
  String get adminTransportTypeDescriptionLabel => 'Descripción';

  @override
  String get adminTripPackagesOpsTab => 'Operación';

  @override
  String get adminTripPackagesCatalogTab => 'Catálogo';

  @override
  String get adminTripPackagesOpsEmpty =>
      'No hay reservas en la cola de operación.';

  @override
  String get adminTripPackagesCatalogHeading => 'Catálogo de packages';

  @override
  String get adminTripPackagesCatalogSubtitle =>
      'Gestionar productos comerciales con destino fijo, precio fijo y tipos de transporte permitidos.';

  @override
  String get adminPackageCreateTitle => 'Crear package';

  @override
  String get adminPackageEditTitle => 'Editar package';

  @override
  String get adminPackageCreateAction => 'Crear package';

  @override
  String get adminPackageEditAction => 'Editar package';

  @override
  String get adminPackageCreateSuccess => 'Package guardado';

  @override
  String get adminPackageNameLabel => 'Nombre del package';

  @override
  String get adminPackageNameMin =>
      'Introduce un nombre con al menos 3 caracteres.';

  @override
  String get adminPackageDestinationLabel => 'Destino fijo';

  @override
  String get adminPackageDescriptionLabel => 'Descripción';

  @override
  String get adminPackageDescriptionMin =>
      'Introduce una descripción con al menos 10 caracteres.';

  @override
  String get adminPackagePriceLabel => 'Precio fijo (EUR)';

  @override
  String get adminPackagePriceInvalid => 'Introduce un precio válido.';

  @override
  String get adminPackageTransportRequired =>
      'Selecciona al menos un tipo de transporte.';

  @override
  String get adminPackageSalesActive => 'Ventas activas';

  @override
  String get adminPackageSalesActiveHint =>
      'Cuando está desactivado, el package ya no aparece para nuevas compras.';

  @override
  String get adminPackageAllowedTransport => 'Tipos de transporte permitidos';

  @override
  String get adminSupportReplyTitle => 'Responder al ticket';

  @override
  String get adminSupportReplyLabel => 'Mensaje';

  @override
  String get adminSupportReplyHint => 'Escribe tu respuesta al cliente...';

  @override
  String adminSupportRequestedAt(String date) {
    return 'solicitado el $date';
  }

  @override
  String get adminSupportReplyAction => 'Responder';

  @override
  String get adminSupportReplyRequired => 'Introduce un mensaje.';

  @override
  String get adminSupportReplySuccess => 'Respuesta enviada';

  @override
  String get adminSupportResolveAction => 'Marcar como resuelto';

  @override
  String get adminSupportResolveSuccess => 'Ticket resuelto';

  @override
  String get adminReportsTabOverview => 'Panorama operacional';

  @override
  String get adminReportsTabClient => 'Estado de cuenta del cliente';

  @override
  String get adminReportsTabDriver => 'Estado de cuenta del conductor';

  @override
  String get adminReportsTabComingSoon =>
      'Los informes de viajes y movimientos de saldo estarán disponibles pronto.';

  @override
  String get adminCurrencyTitle => 'Ajustes de moneda';

  @override
  String get adminCurrencyDesc => 'Tipos de cambio para CVE, EUR y USD.';

  @override
  String get adminCurrencyHeading => 'Ajustes de moneda';

  @override
  String get adminCurrencySubtitle =>
      'Definir tipos de cambio para la visualización en EUR, CVE y USD.';

  @override
  String get adminCurrencyCveToEur => 'CVE a EUR';

  @override
  String get adminCurrencyCveToUsd => 'CVE a USD';

  @override
  String get adminCurrencySaveSuccess => 'Ajustes de moneda guardados';

  @override
  String get adminCurrencyInvalidRate =>
      'Introduce tipos de cambio válidos mayores que cero';

  @override
  String get adminReportsDesc =>
      'Analizar métricas de operación y rendimiento.';

  @override
  String get adminAuditTitle => 'Auditoría';

  @override
  String get adminAuditDesc => 'Ver quién ajustó saldos y tarifas.';

  @override
  String get adminAuditEmpty => 'Sin entradas de auditoría';

  @override
  String get deliveryDeliverTo => 'Entregar en: Av. da Liberdade, Lisboa';

  @override
  String get deliverySearchHint => '¿Qué busca hoy?';

  @override
  String get deliveryExploreCategories => 'Explorar categorías';

  @override
  String get deliveryCategorySupermarket => 'Supermercado';

  @override
  String get deliveryCategorySupermarketSubtitle =>
      'Esenciales frescos a su puerta';

  @override
  String get deliveryCategoryPharmacy => 'Farmacia';

  @override
  String get deliveryCategoryBeverages => 'Bebidas';

  @override
  String get deliveryCategoryHealth => 'Salud y bienestar';

  @override
  String get deliveryPartnersTitle => 'Socios Premium';

  @override
  String get deliveryPartnersSubtitle =>
      'Calidad garantizada y entregas rápidas';

  @override
  String get deliveryHighlightsTitle => 'Destacados de la semana';

  @override
  String get discoverSummerHighlight => 'DESTACADO DE VERANO';

  @override
  String get discoverHeroTitle => 'La esencia del Mediterráneo';

  @override
  String get discoverHeroSubtitle =>
      'Descubra refugios secretos y experiencias de lujo diseñadas para el viajero exigente.';

  @override
  String get discoverSearchHint => 'Buscar restaurantes, fiestas o playas...';

  @override
  String get discoverFilters => 'Filtros';

  @override
  String get discoverExploreMap => 'Explorar mapa';

  @override
  String get discoverExperiencesTitle => 'Experiencias exclusivas';

  @override
  String get discoverCategoryGastronomy => 'Gastronomía';

  @override
  String get discoverExperienceRestaurants => 'Restaurantes de autor';

  @override
  String get discoverCategoryExploration => 'Exploración';

  @override
  String get discoverExperienceSecretSpots => 'Rincones secretos';

  @override
  String get discoverUpcomingEvents => 'Próximos eventos';

  @override
  String get discoverTickets => 'Entradas';

  @override
  String get discoverInteractiveMapTitle => 'Mapa interactivo';

  @override
  String get discoverInteractiveMapSubtitle =>
      'Explore puntos de interés cerca de usted.';

  @override
  String get discoverCurrentLocation => 'Ubicación actual';

  @override
  String get eventDateTimeLabel => 'Fecha y hora';

  @override
  String get eventLocationLabel => 'Ubicación';

  @override
  String get eventAboutTitle => 'Sobre el evento';

  @override
  String get eventDirectionsTitle => 'Cómo llegar';

  @override
  String get eventOpenGps => 'Abrir en GPS';

  @override
  String get eventStandardTicket => 'Entrada estándar';

  @override
  String get eventStandardTicketDesc => 'Acceso general + 1 bebida';

  @override
  String get eventServiceFee => 'Tasa de servicio';

  @override
  String get eventPayNow => 'Pagar ahora';

  @override
  String get eventVipExperience => 'Experiencia VIP';

  @override
  String get eventLimited => 'LIMITADO';

  @override
  String get eventVipDescription =>
      'Mesa reservada, botella incluida y acceso al backstage.';

  @override
  String get eventCheckAvailability => 'Ver disponibilidad →';

  @override
  String get jetskiAdventureTag => 'Aventura en el mar';

  @override
  String get jetskiHeroTitle => 'Domine las olas';

  @override
  String get jetskiHeroSubtitle =>
      'Alquiler premium de motos de agua de alto rendimiento.';

  @override
  String get jetskiDurationLabel => 'DURACIÓN';

  @override
  String get jetskiDurationValue => '1 hora — Paseo rápido';

  @override
  String get jetskiExploreFleet => 'Explorar flota';

  @override
  String get jetskiOurFleet => 'Nuestra flota';

  @override
  String get jetskiBookNow => 'Reservar ahora';

  @override
  String get jetskiSafetyTitle => 'Seguridad primero';

  @override
  String get jetskiSafetyLifeJacketTitle => 'Chaleco salvavidas incluido';

  @override
  String get jetskiSafetyLifeJacketSubtitle =>
      'Equipo homologado para todos los pesos.';

  @override
  String get jetskiSafetyBriefingTitle => 'Briefing de seguridad';

  @override
  String get jetskiSafetyBriefingSubtitle =>
      'Instrucción obligatoria de 15 min antes de la salida.';

  @override
  String get jetskiSafetyGpsTitle => 'Monitorización GPS';

  @override
  String get jetskiSafetyGpsSubtitle =>
      'Equipo de apoyo listo para intervenir 24/7.';

  @override
  String get jetskiOurBase => 'Nuestra base';

  @override
  String get jetskiOpenMap => 'Abrir mapa';

  @override
  String get premiumHomeSearchHint => 'Busque destino o servicio...';

  @override
  String get premiumHomeNoResults => 'No se encontraron resultados';

  @override
  String get premiumHomeFastDelivery => 'Entregas rápidas';

  @override
  String get premiumHomeGroceryPharmacy => 'Comestibles y farmacia';

  @override
  String get premiumHomeIslandGuide => 'Guía de islas';

  @override
  String get premiumHomeJetski => 'Moto de agua';

  @override
  String get premiumHomeTransportTitle => 'Transporte y movilidad';

  @override
  String get premiumHomeTransportTrip => 'Viaje';

  @override
  String get premiumHomeTransportMoto => 'Moto';

  @override
  String get premiumHomeTransportScooter => 'Patinete';

  @override
  String get premiumHomeTransportBike => 'Bicicleta';

  @override
  String get premiumHomeExperiencesTitle => 'Experiencias Premium';

  @override
  String get premiumHomeJetskiRentalTitle => 'Alquiler de motos de agua';

  @override
  String get premiumHomeJetskiRentalDesc =>
      'Explore aguas cristalinas con nuestro nuevo servicio de alquiler premium.';

  @override
  String premiumHomeFromPrice(String price) {
    return 'Desde $price';
  }

  @override
  String get premiumHomeIslandGuideTitle => 'Guía exclusivo de islas';

  @override
  String get premiumHomeIslandGuideDesc =>
      'Descubra los secretos de las islas con rutas personalizadas locales.';

  @override
  String get rentalPickupLocation => 'Lugar de recogida';

  @override
  String get rentalDropoffLocation => 'Lugar de entrega';

  @override
  String get rentalSamePickupHint => 'Mismo lugar de recogida';

  @override
  String get rentalDateSelection => 'Selección de fechas';

  @override
  String get rentalDriverAge => 'Edad del conductor';

  @override
  String get rentalDriverAgeNote =>
      'Pueden aplicarse tarifas adicionales para conductores fuera del rango estándar.';

  @override
  String get rentalPremiumOnly => 'Solo Premium';

  @override
  String get rentalLuxuryFleetOnly => 'Mostrar solo flota de lujo';

  @override
  String get rentalViewFleetOnMap => 'Ver flota en el mapa';

  @override
  String get rentalCarType => 'Tipo de coche';

  @override
  String get rentalMaxPrice => 'Precio máximo';

  @override
  String get rentalTransmission => 'Transmisión';

  @override
  String get rentalFilter => 'Filtrar';

  @override
  String get rentalPremiumHighlights => 'Destacados Premium';

  @override
  String rentalResultsFound(String count) {
    return '$count resultados encontrados';
  }

  @override
  String get rentalPremiumChoice => 'Elección Premium';

  @override
  String get rentalAllCars => 'Todos los coches';

  @override
  String get rentalLoadMore => 'Cargar más vehículos';

  @override
  String get rentalLoadError =>
      'No se pudieron cargar los vehículos. Inténtalo de nuevo.';

  @override
  String get rentalNoVehicles =>
      'No hay vehículos disponibles en este momento.';

  @override
  String get rentalVehicleDetails => 'Detalles del vehículo';

  @override
  String get rentalRating => 'Calificación';

  @override
  String get rentalPowertrain => 'Motorización';

  @override
  String get rentalCapacity => 'Capacidad';

  @override
  String get rentalAcceleration => 'Aceleración';

  @override
  String get rentalInsuranceIncluded => 'Seguro incluido';

  @override
  String get rentalFuelPolicy => 'Combustible';

  @override
  String get rentalCurrentBattery => 'Batería actual';

  @override
  String get rentalBookingSummary => 'Resumen de la reserva';

  @override
  String get rentalTotalCost => 'Costo total';

  @override
  String get rentalTechnicalSpecs => 'ESPECIFICACIONES TÉCNICAS';

  @override
  String get rentalReservationTotal => 'Total de la reserva';

  @override
  String get rentalContinueToPayment => 'Continuar al pago';

  @override
  String get rentalPerDay => '/día';

  @override
  String rentalSeats(String count) {
    return '$count plazas';
  }

  @override
  String get rentalBag => 'Maleta';

  @override
  String get rentalBags => 'Maletas';

  @override
  String get reservationReviewTitle => 'Revisión de la reserva';

  @override
  String get reservationItinerary => 'Itinerario';

  @override
  String get reservationPickupLabel => 'RECOGIDA';

  @override
  String get reservationReturnLabel => 'DEVOLUCIÓN';

  @override
  String get reservationSecurePayment => 'Pago 100% seguro';

  @override
  String get reservationSecurePaymentDesc =>
      'Usamos cifrado SSL de 256 bits para proteger sus datos.';

  @override
  String get reservationCostSummary => 'Resumen de costes';

  @override
  String get reservationNoHiddenFees => 'Sin costes ocultos';

  @override
  String get reservationPaymentMethod => 'Método de pago';

  @override
  String get reservationCreditCard => 'Tarjeta de crédito';

  @override
  String get reservationPayWithApplePay => 'Pagar con Apple Pay';

  @override
  String get reservationConfirmAndPay => 'Confirmar y pagar';

  @override
  String get reservationTermsPrefix =>
      'Al hacer clic en \"Confirmar y pagar\", acepta nuestros ';

  @override
  String get reservationTermsLink => 'Términos y condiciones';

  @override
  String get reservationFullInsurance => 'Seguro total incluido';

  @override
  String get reservationsEmptyTitle => 'Aún no tiene más reservas';

  @override
  String get reservationsEmptyBody =>
      'Planifique su próximo viaje con nuestra flota premium. Confort y puntualidad garantizados.';

  @override
  String get reservationsExploreDestinations => 'Explorar destinos';

  @override
  String get tripHistoryActivity => 'Mi actividad';

  @override
  String get tripHistoryTrips => 'Viajes';

  @override
  String get tripHistoryThisMonth => 'Este mes';

  @override
  String get tripHistoryFilterAll => 'Todos';

  @override
  String get tripHistoryFilterRecent => 'Viajes recientes';

  @override
  String get tripHistoryFilterCompleted => 'Completadas';

  @override
  String get tripHistoryFilterCancelled => 'Canceladas';

  @override
  String get tripHistoryFilterThisYear => 'Este año';

  @override
  String get tripHistoryStatusCancelled => 'Cancelada';

  @override
  String get tripHistoryStatusInProgress => 'En curso';

  @override
  String get tripHistoryStatusScheduled => 'Programada';

  @override
  String get tripHistoryEmpty => 'Sin viajes todavía';

  @override
  String get tripHistoryEmptyBody =>
      'Tus viajes aparecerán aquí después de solicitar un trayecto.';

  @override
  String get tripHistoryLoadError =>
      'No se pudieron cargar los viajes. Inténtalo de nuevo.';

  @override
  String get tripHistoryNoDetails => 'Sin detalles';

  @override
  String get tripDetailsRateExperience => 'Valore su experiencia';

  @override
  String get tripDetailsDigitalInvoice => 'Factura digital';

  @override
  String get tripDetailsTotalPaid => 'Total pagado';

  @override
  String get tripDetailsMethod => 'Método';

  @override
  String get tripDetailsDownloadPdf => 'Descargar PDF';

  @override
  String get tripDetailsFareBase => 'Tarifa base';

  @override
  String get tripDetailsFareDistance => 'Distancia (12.5 km)';

  @override
  String get tripDetailsFareTime => 'Tiempo (24 min)';

  @override
  String get tripDetailsFareDiscount => 'Descuento promocional';

  @override
  String get tripDetailsSupportTitle => '¿Algo salió mal?';

  @override
  String get tripDetailsSupportLostItem => 'Reportar objeto perdido';

  @override
  String get tripDetailsSupportSafety => 'Reclamación de seguridad';

  @override
  String get tripDetailsSupportCustomer => 'Atención al cliente';

  @override
  String get tripCompletedThanks => 'Gracias por viajar con nosotros.';

  @override
  String get tripCompletedFinalPrice => 'Precio final';

  @override
  String get tripCompletedOptimizedRoute => 'Trayecto optimizado';

  @override
  String get tripCompletedRateTrip => 'Valore el viaje';

  @override
  String get tripCompletedRateHint =>
      '¿Cómo fue su experiencia con el conductor y el vehículo?';

  @override
  String get tripCompletedCommentOptional => 'Comentario (opcional)';

  @override
  String get tripCompletedCommentHint => 'Comparta su opinión...';

  @override
  String get tripCompletedSubmitRating => 'Enviar valoración';

  @override
  String get tripCompletedRatingSent => 'Valoración enviada';

  @override
  String get tripCompletedReportIssue => 'Reportar problema';

  @override
  String get tripInProgressStatusLabel => 'Estado del viaje';

  @override
  String get tripInProgressStatusValue => 'En curso';

  @override
  String get tripInProgressArrivalLabel => 'Llegada prevista';

  @override
  String get tripInProgressCostLabel => 'Costo estimado';

  @override
  String get driverSearchSubtitle =>
      'Conectándole con los vehículos más cercanos en Lisboa Central.';

  @override
  String get driverSearchSubtitleFallback =>
      'Conectando con los vehículos disponibles más cercanos.';

  @override
  String driverSearchSubtitleArea(String area) {
    return 'Conectando con los vehículos más cercanos cerca de $area.';
  }

  @override
  String get driverSearchOrigin => 'ORIGEN';

  @override
  String get driverSearchEstimate => 'ESTIMACIÓN';

  @override
  String get driverSearchWaitEstimate => '3–5 min';

  @override
  String driverSearchWaitMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get driverSearchCancelTrip => 'Cancelar viaje';

  @override
  String get driverSearchCancelling => 'Cancelando...';

  @override
  String get driverSearchCancelFailed => 'No se pudo cancelar el viaje.';

  @override
  String get driverSearchNoDrivers =>
      'No hay conductores disponibles. Inténtelo de nuevo.';

  @override
  String get driverSearchNoDriversNearby =>
      'No hay conductores cerca de la recogida. El conductor debe estar disponible en un radio de 100 km.';

  @override
  String get driverSearchNoDriversMissingVehicle =>
      'Los conductores cercanos no tienen vehículo asignado. Pida al admin que asigne un vehículo.';

  @override
  String get homePickupOutsideServiceArea =>
      'La recogida está fuera del área de servicio. Use una ubicación en Cabo Verde.';

  @override
  String get driverSearchOptimizing => 'Optimizando ruta en tiempo real...';

  @override
  String get driverFoundWaiting => 'Esperando confirmación...';

  @override
  String get driverFoundEstimatedTime => 'Tiempo estimado';

  @override
  String get driverFoundFare => 'Tarifa';

  @override
  String get driverFoundCancelHint =>
      'Puede cancelar sin coste en los próximos 2 minutos mientras el conductor confirma la reserva.';

  @override
  String get driverEnRouteYourLocation => 'Su ubicación';

  @override
  String get driverEnRouteMessage => 'Mensaje';

  @override
  String get driverEnRouteCall => 'Llamar';

  @override
  String get tripDestinationSubtitle =>
      'Busque un destino o elija uno de sus lugares frecuentes.';

  @override
  String get tripDestinationSearchHint => 'Buscar dirección o punto de interés';

  @override
  String get tripDestinationRecentPlaces => 'Lugares recientes';

  @override
  String get tripDestinationSuggestions => 'Sugerencias y favoritos';

  @override
  String get tripDestinationExploreMap => 'Explorar mapa';

  @override
  String get tripDestinationTodaySuggestion => 'SUGERENCIA DE HOY';

  @override
  String get tripDestinationSuggestionTitle => 'Belém y Monumentos';

  @override
  String get tripDestinationViewFullMap => 'Ver mapa completo';

  @override
  String get tripConfirmTransportType => 'Tipo de transporte';

  @override
  String tripConfirmTotal(String amount) {
    return 'Total: $amount';
  }

  @override
  String get tripConfirmTrip => 'Confirmar viaje';

  @override
  String get tripConfirmSessionInvalid =>
      'Sesión no válida. Inicie sesión de nuevo.';

  @override
  String get tripConfirmRouteLoading => 'Espere a que se cargue la ruta.';

  @override
  String get tripConfirmCreateFailed =>
      'No se pudo crear el viaje. Inténtelo de nuevo.';

  @override
  String get tripConfirmPermissionDenied =>
      'No se pudo crear el viaje. Comprueba tu saldo y sesión, o contacta con soporte.';

  @override
  String get tripConfirmDestinationFailed =>
      'No se pudo localizar el destino. Compruebe la dirección o elija una sugerencia de la lista.';

  @override
  String get tripConfirmDirectionsFailed =>
      'No se pudo calcular la ruta. Compruebe la conexión y la configuración de la API de Google Maps.';

  @override
  String get tripConfirmTransportTypesFailed =>
      'Opciones de transporte no disponibles. Inténtelo de nuevo en un momento.';

  @override
  String get tripConfirmPriceUnavailable =>
      'Precio del viaje no disponible. Espere a que se cargue la ruta o elija otro destino.';

  @override
  String get tripConfirmLimitExceeded =>
      'Saldo insuficiente para solicitar este viaje. Recargue la cuenta e inténtelo de nuevo.';

  @override
  String get tripConfirmDirectionsApproximate =>
      'Ruta exacta no disponible. Distancia y precio son aproximados.';

  @override
  String get tripConfirmPickupPoint => 'PUNTO DE RECOGIDA';

  @override
  String get tripConfirmFinalDestination => 'DESTINO FINAL';

  @override
  String get tripConfirmTransportPremium => 'Premium';

  @override
  String get tripConfirmTransportEco => 'Eco-Eléctrico';

  @override
  String get tripConfirmTransportShared => 'Compartido';

  @override
  String get driverAvailable => 'Disponible';

  @override
  String get driverUnavailable => 'No disponible';

  @override
  String get driverFleetStatus => 'Estado de la flota';

  @override
  String get driverVerified => 'Verificado';

  @override
  String get driverInOperation => 'En operación';

  @override
  String get driverTodayEarnings => 'Ganancias de hoy';

  @override
  String driverEarningsVsYesterday(String change) {
    return '$change vs. ayer';
  }

  @override
  String get driverNoRecentTrips => 'Aún no hay viajes completados';

  @override
  String get driverNoVehicleAssigned => 'Ningún vehículo asignado';

  @override
  String get driverAvailabilityInactiveHint =>
      'Actívelo para recibir nuevos viajes.';

  @override
  String get driverAvailabilityActiveHint =>
      'La ubicación se compartirá con la central.';

  @override
  String get driverReadinessTitle => 'Requisitos para estar disponible';

  @override
  String get driverReadinessVehicleTitle => 'Vehículo asignado';

  @override
  String get driverReadinessVehicleReady => 'Vehículo activo y listo.';

  @override
  String get driverReadinessVehicleMissing =>
      'Solo un administrador puede vincular un vehículo.';

  @override
  String get driverReadinessVehicleDialogTitle => 'Sin vehículo asignado';

  @override
  String get driverReadinessVehicleDialogMessage =>
      'Solo un administrador puede vincular un vehículo a su cuenta.';

  @override
  String get driverReadinessVehicleDialogGotIt => 'Entendido';

  @override
  String get driverReadinessVehicleHelpAction => 'Más información';

  @override
  String get driverReadinessVehicleSnackMessage =>
      'Solo un administrador puede vincular un vehículo a su cuenta.';

  @override
  String get driverReadinessLocationTitle => 'Ubicación del dispositivo';

  @override
  String get driverReadinessLocationReady => 'Ubicación activa.';

  @override
  String get driverReadinessLocationMissing =>
      'Active la ubicación para recibir viajes.';

  @override
  String get driverReadinessLocationAction => 'Activar ubicación';

  @override
  String get driverLocationPermissionTitle => 'Permitir ubicación';

  @override
  String get driverLocationPermissionMessage =>
      'El conductor debe compartir la ubicación en tiempo real para recibir viajes y ser encontrado por los clientes.';

  @override
  String get driverLocationPermissionSettingsMessage =>
      'El permiso de ubicación está desactivado. Abra los ajustes de la app para permitir el acceso.';

  @override
  String get driverReadinessAllReady => 'Todo listo. Puede estar disponible.';

  @override
  String get driverTripsLabel => 'Viajes';

  @override
  String get driverDistanceLabel => 'Distancia';

  @override
  String get driverRecentTrips => 'Últimos viajes';

  @override
  String get driverLocationCity => 'Praia, CV';

  @override
  String get driverLocationLoading => 'Localizando...';

  @override
  String driverHoursAgo(int hours) {
    return 'hace ${hours}h';
  }

  @override
  String get driverNewRequest => 'Nueva solicitud';

  @override
  String get driverPremiumTrip => 'Viaje Premium';

  @override
  String get driverPickup => 'Recogida';

  @override
  String get driverDestination => 'Destino';

  @override
  String get driverDecline => 'RECHAZAR';

  @override
  String get driverAcceptTrip => 'ACEPTAR VIAJE';

  @override
  String get driverTripAcceptedTitle => '¡Viaje aceptado!';

  @override
  String get driverTripAcceptedSubtitle =>
      'Preparando la ruta de navegación...';

  @override
  String get driverPassenger => 'Pasajero';

  @override
  String get driverEstimatedArrival => 'Llegada estimada';

  @override
  String get driverStartNavigation => 'Iniciar navegación ahora';

  @override
  String get driverRequestExpiredTitle => 'Solicitud expirada';

  @override
  String get driverRequestExpiredMessage =>
      'El límite de 12 segundos para aceptar el viaje ha expirado.';

  @override
  String get driverUnavailableForRequests =>
      'Actualmente no disponible para nuevas solicitudes';

  @override
  String get driverBackToDashboard => 'Volver al panel';

  @override
  String get driverViewTripHistory => 'Ver historial de viajes';

  @override
  String driverDistanceToDestination(String distance) {
    return 'A $distance del destino';
  }

  @override
  String get driverVipPassenger => 'Pasajero VIP';

  @override
  String get driverEstimatedTimeLabel => 'TIEMPO ESTIMADO';

  @override
  String get driverDistanceStatLabel => 'DISTANCIA';

  @override
  String get driverOnTheWay => 'En camino';

  @override
  String get driverArrivedStatus => 'Llegó al punto de recogida';

  @override
  String get driverTripInProgressStatus => 'Viaje en curso';

  @override
  String get driverArrivedButton => 'He llegado';

  @override
  String get driverStartTripButton => 'Iniciar viaje';

  @override
  String get driverFinishTripButton => 'Finalizar viaje';

  @override
  String get adminReportsTitle => 'Informes detallados';

  @override
  String get adminReportsExport => 'Exportar';

  @override
  String get adminReportsDateRangeLabel => 'Rango de fechas';

  @override
  String get adminReportsVehicleFleetLabel => 'Vehículo / Flota';

  @override
  String get adminReportsAllVehicles => 'Todos los vehículos';

  @override
  String get adminReportsTotalTrips => 'Total de viajes';

  @override
  String get adminReportsTotalDistance => 'Distancia total';

  @override
  String get adminReportsTimeOnRoute => 'Tiempo en ruta';

  @override
  String get adminReportsTotalCost => 'Costo total';

  @override
  String get adminReportsPendingDebt => 'Deuda pendiente';

  @override
  String get adminReportsOverdueInvoices => 'FACTURAS VENCIDAS';

  @override
  String get adminReportsMonthlyPerformance =>
      'Análisis de rendimiento mensual';

  @override
  String get adminReportsChartHint =>
      'Visualización detallada de tendencias de costo y kilometraje del período seleccionado.';

  @override
  String get adminReportsLatestActivities => 'ÚLTIMAS ACTIVIDADES';

  @override
  String get adminReportsFleetEfficiency => 'EFICIENCIA DE FLOTA';

  @override
  String get adminReportsOptimizedStatus => 'OPTIMIZADO';

  @override
  String adminReportsOptimized(int percent) {
    return '$percent% OPTIMIZADO';
  }

  @override
  String get adminReportsEfficiencyFooter =>
      'Su flota opera un 15% por encima del promedio del sector este trimestre.';

  @override
  String get adminDrawerFleetManager => 'Gestor de flota';

  @override
  String get adminDrawerFleetSubtitle => 'Flota central de Lisboa';

  @override
  String get adminDrawerRoleBadge => 'Admin';

  @override
  String get adminTariffNoTransportTypes =>
      'Configura primero los tipos de transporte.';

  @override
  String get adminTariffInvalidAmounts => 'Introduce importes válidos.';

  @override
  String adminTariffInvalidBaseFare(String typeName) {
    return 'Tarifa base no válida para $typeName.';
  }

  @override
  String get rentalAc => 'AC';

  @override
  String get rentalElectric => 'Eléctrico';

  @override
  String get rentalAllTypes => 'Todos los tipos';

  @override
  String get rentalCarTypeSedan => 'Sedán';

  @override
  String get rentalCarTypeSuv => 'SUV';

  @override
  String get rentalCarTypeExecutive => 'Ejecutivo';

  @override
  String get rentalCarTypeElectric => 'Eléctrico';

  @override
  String get rentalTransmissionAll => 'Todas';

  @override
  String get rentalTransmissionAutomatic => 'Automático';

  @override
  String get rentalTransmissionManual => 'Manual';

  @override
  String get rentalAnyPrice => 'Cualquier precio';

  @override
  String rentalPriceUpTo(String price) {
    return 'Hasta $price';
  }

  @override
  String driverEnRouteEtaAt(String time) {
    return 'ETA • $time';
  }

  @override
  String get rentalWeekdaySun => 'DOM';

  @override
  String get rentalWeekdayMon => 'LUN';

  @override
  String get rentalWeekdayTue => 'MAR';

  @override
  String get rentalWeekdayWed => 'MIÉ';

  @override
  String get rentalWeekdayThu => 'JUE';

  @override
  String get rentalWeekdayFri => 'VIE';

  @override
  String get rentalWeekdaySat => 'SÁB';

  @override
  String get rentalDemoPickupLocation => 'Aeropuerto de Lisboa, PT';

  @override
  String get rentalDriverAgeYoung => '18 - 25 años';

  @override
  String get rentalDriverAgeStandard => '26 - 65 años';

  @override
  String get rentalDriverAgeSenior => '65+ años';

  @override
  String get rentalDemoSportPremium => 'DEPORTIVO PREMIUM';

  @override
  String get rentalDemoVehicleName => 'Porsche Taycan 4S';

  @override
  String get rentalInsuranceDescription =>
      'Protección total contra daños propios y asistencia en carretera 24/7 sin coste adicional.';

  @override
  String get rentalInsuranceFranchiseWaiver => 'Exención de franquicia';

  @override
  String get rentalInsuranceCdw => 'Daños por colisión (CDW)';

  @override
  String get rentalFuelPolicyElectric =>
      'Política lleno/lleno o devolución con más del 80% de carga para vehículos eléctricos.';

  @override
  String rentalBookingRentalDays(int days) {
    return 'Alquiler ($days días)';
  }

  @override
  String get rentalBookingPremiumInsurance => 'Seguro premium';

  @override
  String get rentalBookingIncluded => 'Incluido';

  @override
  String get rentalBookingAirportFees => 'Tasas de aeropuerto';

  @override
  String get rentalDemoAirportLocation => 'Aeropuerto de Lisboa, LIS';

  @override
  String get rentalSpecPower => 'Potencia';

  @override
  String get rentalSpecPowerValue => '530 CV';

  @override
  String get rentalSpecRange => 'Autonomía WLTP';

  @override
  String get rentalSpecRangeValue => '463 km';

  @override
  String get rentalSpecDrive => 'Tracción';

  @override
  String get rentalSpecDriveValue => 'Integral (AWD)';

  @override
  String rentalVehicleSummary(String price, String seats, String transmission) {
    return '$price · $seats · $transmission';
  }

  @override
  String get eventDemoGenre => 'MÚSICA ELECTRÓNICA';

  @override
  String get eventDemoTitle => 'Gala de Verano: Porto Sunset';

  @override
  String get eventDemoDescription =>
      'Prepárate para la noche más exclusiva del año. La Gala de Verano en Oporto combina la mejor música electrónica melódica con una vista impresionante sobre el río Duero. Catering premium, zonas VIP y una experiencia audiovisual inmersiva.';

  @override
  String get eventDemoVenue => 'Alfândega do Porto';

  @override
  String get eventPaymentMbway => 'MB WAY';

  @override
  String get discoverMapRestaurantLabel => 'Restaurante Maré';

  @override
  String get discoverMapBeachLabel => 'Playa Secreta';

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
  String get reservationDemoAirport => 'Aeropuerto de Lisboa (LIS)';

  @override
  String get reservationDemoPickupDateTime => '15 oct, 2023 a las 10:00';

  @override
  String get reservationDemoReturnDateTime => '20 oct, 2023 a las 18:00';

  @override
  String reservationRentalDaysLine(int days) {
    return 'Alquiler ($days días)';
  }

  @override
  String get reservationInsuranceLine => 'Seguro total';

  @override
  String get reservationDefaultVehicle => 'Vehículo';

  @override
  String get reservationDefaultCity => 'Lisboa';
}
