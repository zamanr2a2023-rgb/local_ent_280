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
  String get profileMenuPaymentMethods => 'Métodos de pago';

  @override
  String get profileMenuHelpCenter => 'Centro de ayuda';

  @override
  String get profileMenuPrivacySecurity => 'Privacidad y seguridad';

  @override
  String get profileSessionSection => 'Sesión';

  @override
  String get profileGoToLogin => 'Ir al inicio de sesión';

  @override
  String get homeAvailableBalance => 'Saldo disponible';

  @override
  String get homeTopUp => 'Recargar';

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
  String get premiumMobility => 'Movilidad Premium';

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
  String get adminAppBarTitle => 'Movilidad Premium';

  @override
  String get adminFleetStatusTitle => 'Estado de la flota';

  @override
  String get adminFleetStatusUpdated => 'Actualizado: Ahora';

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
  String get adminMonthlyReportsTitle => 'Informes mensuales';

  @override
  String get adminMonthlyReportsSubtitle => 'Rendimiento de octubre';

  @override
  String get adminActivityMapTitle => 'Mapa de actividad';

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
  String get premiumHomeFromPrice => 'Desde 45€';

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
  String get driverSearchOrigin => 'ORIGEN';

  @override
  String get driverSearchEstimate => 'ESTIMACIÓN';

  @override
  String get driverSearchCancelTrip => 'Cancelar viaje';

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
  String get driverEarningsChange => '+12% vs. ayer';

  @override
  String get driverTripsLabel => 'Viajes';

  @override
  String get driverDistanceLabel => 'Distancia';

  @override
  String get driverRecentTrips => 'Últimos viajes';

  @override
  String get driverLocationCity => 'Lisboa, PT';

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
}
