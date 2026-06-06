// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appNameLocalTransport => 'Local Transport';

  @override
  String get signIn => 'Sign in';

  @override
  String get cancel => 'Cancel';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutTitle => 'End session';

  @override
  String get signOutConfirmMessage =>
      'Are you sure you want to sign out of your account?';

  @override
  String get signOutFailed => 'Could not sign out. Please try again.';

  @override
  String get tryAgain => 'Try again';

  @override
  String featureComingSoon(String feature) {
    return '$feature will be available soon.';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navTrips => 'Trips';

  @override
  String get navReservations => 'Reservations';

  @override
  String get navProfile => 'Profile';

  @override
  String get loginSubtitle => 'Sign in to manage your trips.';

  @override
  String get loginSettingsTooltip => 'Settings';

  @override
  String get loginEmailOrMobileLabel => 'Email or mobile';

  @override
  String get loginEmailHint => 'e.g. joao@email.com';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginForgotPassword => 'Forgot?';

  @override
  String get loginFillEmailPassword => 'Enter email and password.';

  @override
  String get loginNoAccountPrompt => 'Don\'t have an account yet? ';

  @override
  String get loginRegisterNow => 'Register now';

  @override
  String get loginPrivacy => 'Privacy';

  @override
  String get loginTermsOfUse => 'Terms of use';

  @override
  String get loginSupport => 'Support';

  @override
  String get loginRoleClient => 'Client';

  @override
  String get loginRoleProfessional => 'Professional';

  @override
  String get secureConnectionE2E => 'Secure end-to-end encrypted connection.';

  @override
  String get authErrorUnexpected =>
      'An unexpected error occurred. Please try again.';

  @override
  String get authErrorProfileNotFound => 'User profile not found.';

  @override
  String get authErrorAccountInactive =>
      'This account is inactive. Contact support.';

  @override
  String get authErrorRoleMismatch =>
      'Profile does not match the selected type.';

  @override
  String get authErrorInvalidEmail => 'Invalid email.';

  @override
  String get authErrorUserDisabled => 'This account is disabled.';

  @override
  String get authErrorWrongCredentials => 'Incorrect email or password.';

  @override
  String get authErrorTooManyRequests => 'Too many attempts. Try again later.';

  @override
  String get authErrorSignInFailed => 'Could not sign in. Please try again.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle =>
      'Adjust preferences and keep the app ready for you.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageDescription =>
      'Choose the app language. You can reset to the device language at any time.';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String get settingsLanguagePortuguese => 'Portuguese (Portugal)';

  @override
  String settingsLanguageFollowingDevice(String language) {
    return 'Following device language ($language).';
  }

  @override
  String settingsLanguageManual(String language) {
    return 'Language selected manually: $language.';
  }

  @override
  String get settingsLanguageResetSnack => 'Language reset to device default.';

  @override
  String get settingsUseDeviceLanguage => 'Reset to device language';

  @override
  String get settingsDisplayCurrency => 'Display currency';

  @override
  String get settingsDisplayCurrencyDescription =>
      'Choose which currency you want to see values in throughout the app.';

  @override
  String get settingsCurrencyCve => 'Cape Verdean escudo (CVE)';

  @override
  String get settingsCurrencyEur => 'Euro (€)';

  @override
  String get settingsCurrencyUsd => 'US dollar (USD)';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsSignOutAction => 'Sign out';

  @override
  String get settingsSignOutLoading => 'Signing out...';

  @override
  String get settingsDeveloperSection => 'Developer tools';

  @override
  String get settingsDriverLocationSimulationTitle =>
      'Location simulation (demo)';

  @override
  String get settingsDriverLocationSimulationDescription =>
      'Available only in development builds. On the driver device, publishes simulated movement toward pickup on the active trip, without marking arrival automatically.';

  @override
  String get settingsDriverLocationSimulationSwitchLabel =>
      'Simulate driver movement';

  @override
  String get settingsResetOnboarding => 'Reset onboarding';

  @override
  String get settingsResetDone => 'Onboarding reset.';

  @override
  String get settingsDeveloperDebugOnly =>
      'Section visible only in debug builds.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileDefaultUserName => 'User';

  @override
  String get profileSessionNotFound =>
      'Session not found. Please sign in again.';

  @override
  String get profileLoadFailed => 'Could not load profile. Please try again.';

  @override
  String get profileRoleClient => 'User';

  @override
  String get profileRoleDriver => 'Driver';

  @override
  String get profileRoleAdmin => 'Administrator';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profilePhoneNotSet => 'Not set';

  @override
  String get profileAccountType => 'Account type';

  @override
  String get profileStatus => 'Status';

  @override
  String get profileStatusActive => 'Active';

  @override
  String get profileStatusInactive => 'Inactive';

  @override
  String get profileMenuSettings => 'Settings';

  @override
  String get profileMenuPaymentMethods => 'Payment methods';

  @override
  String get profileMenuHelpCenter => 'Help center';

  @override
  String get profileMenuPrivacySecurity => 'Privacy and security';

  @override
  String get profileSessionSection => 'Session';

  @override
  String get profileGoToLogin => 'Go to login';

  @override
  String get homeAvailableBalance => 'Available balance';

  @override
  String get homeTopUp => 'Top up';

  @override
  String get homeActionRequest => 'Request';

  @override
  String get homeActionBook => 'Book';

  @override
  String get homeActionRent => 'Rent';

  @override
  String get homeActionHistory => 'History';

  @override
  String get homeActionBalance => 'Balance';

  @override
  String get homeWhereToday => 'Where are we going today?';

  @override
  String get homeCurrentLocation => 'Current location';

  @override
  String get homeDestination => 'Destination';

  @override
  String get homeDestinationHint => 'Where do you want to go?';

  @override
  String get homeConfirmRoute => 'Confirm route';

  @override
  String get reservationsTitle => 'Reservations';

  @override
  String get reservationsSubtitle => 'Manage your upcoming trips';

  @override
  String get reservationsNew => 'New reservation';

  @override
  String get reservationsPickup => 'Pickup';

  @override
  String get reservationsDestination => 'Destination';

  @override
  String get reservationsDetails => 'Details';

  @override
  String get reservationsCancel => 'Cancel';

  @override
  String get reservationsStatusConfirmed => 'Confirmed';

  @override
  String get reservationsStatusPending => 'Pending';

  @override
  String get tripHistoryTitle => 'Trip history';

  @override
  String get tripHistoryDetails => 'Details';

  @override
  String get tripDetailsSummary => 'Trip summary';

  @override
  String get tripDetailsStatusCompleted => 'Completed';

  @override
  String get rentalTitle => 'Vehicle rental';

  @override
  String get rentalSubtitle => 'Find the perfect partner for your next trip.';

  @override
  String get rentalSearchAvailable => 'Search available vehicles';

  @override
  String get driverSearchTitle => 'Looking for an available driver';

  @override
  String get driverFoundTitle => 'Driver found';

  @override
  String get driverEnRouteStatus => 'Driver on the way';

  @override
  String get tripInProgressEndTrip => 'End trip';

  @override
  String get tripInProgressSupport => 'Support';

  @override
  String get tripCompletedTitle => 'Trip completed!';

  @override
  String get tripCompletedBackHome => 'Back to home';

  @override
  String get premiumHomeOrderNow => 'Order now';

  @override
  String get support => 'Support';

  @override
  String get destination => 'Destination';

  @override
  String get details => 'Details';

  @override
  String get premiumMobility => 'Premium Mobility';

  @override
  String get seeAll => 'See all';

  @override
  String get edit => 'Edit';

  @override
  String get total => 'Total';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get quantity => 'Quantity';

  @override
  String get distance => 'Distance';

  @override
  String get duration => 'Duration';

  @override
  String get premium => 'Premium';

  @override
  String get newBadge => 'New';

  @override
  String get promotion => 'Promotion';

  @override
  String get free => 'Free';

  @override
  String get live => 'LIVE';

  @override
  String get verified => 'Verified';

  @override
  String get createAccount => 'Create account';

  @override
  String get splashSecureConnection => 'Secure & Encrypted Connection';

  @override
  String get splashExecutiveBadge => 'EXECUTIVE';

  @override
  String get splashHeroTitle => 'Your time,\nvalued.';

  @override
  String get splashHeroSubtitle =>
      'Personalized transport with comfort and punctuality.';

  @override
  String get splashInstantBookingTitle => 'Instant Bookings';

  @override
  String get splashInstantBookingSubtitle =>
      'Plan your trip in seconds with our exclusive network.';

  @override
  String get splashDriverOfToday => 'TODAY\'S DRIVER';

  @override
  String get adminAppBarTitle => 'Premium Mobility';

  @override
  String get adminFleetStatusTitle => 'Fleet Status';

  @override
  String get adminFleetStatusUpdated => 'Updated: Now';

  @override
  String get adminActiveTripsLabel => 'Active Trips';

  @override
  String get adminActiveTripsTrend => '+12% vs. yesterday';

  @override
  String get adminAvailableDriversLabel => 'Available Drivers';

  @override
  String get adminAvailableDriversHint => 'Ready for dispatch';

  @override
  String get adminCriticalOpsTitle => 'Critical Operations';

  @override
  String get adminPendingDebtorsTitle => 'Pending Debtors';

  @override
  String get adminPendingDebtorsSubtitle => '3 overdue invoices';

  @override
  String get adminMonthlyReportsTitle => 'Monthly Reports';

  @override
  String get adminMonthlyReportsSubtitle => 'October performance';

  @override
  String get adminActivityMapTitle => 'Activity Map';

  @override
  String get adminRatesTitle => 'Rates & Market';

  @override
  String get adminBaseRateLabel => 'Base Rate';

  @override
  String get adminBaseRateDynamic => 'Dynamic: Active (1.2x)';

  @override
  String get adminFuelCostLabel => 'Fuel Cost';

  @override
  String get adminFuelCostHint => 'National Average';

  @override
  String get adminRecentFleetTitle => 'Recent Fleet';

  @override
  String get adminFleetStatusOnTrip => 'On Trip';

  @override
  String get adminFleetStatusInactive => 'Inactive';

  @override
  String adminFleetDriverPrefix(String name) {
    return 'Driver: $name';
  }

  @override
  String get deliveryDeliverTo => 'Deliver to: Av. da Liberdade, Lisbon';

  @override
  String get deliverySearchHint => 'What are you looking for today?';

  @override
  String get deliveryExploreCategories => 'Explore Categories';

  @override
  String get deliveryCategorySupermarket => 'Supermarket';

  @override
  String get deliveryCategorySupermarketSubtitle =>
      'Fresh essentials at your door';

  @override
  String get deliveryCategoryPharmacy => 'Pharmacy';

  @override
  String get deliveryCategoryBeverages => 'Beverages';

  @override
  String get deliveryCategoryHealth => 'Health & Wellness';

  @override
  String get deliveryPartnersTitle => 'Premium Partners';

  @override
  String get deliveryPartnersSubtitle => 'Guaranteed quality and fast delivery';

  @override
  String get deliveryHighlightsTitle => 'Weekly Highlights';

  @override
  String get discoverSummerHighlight => 'SUMMER HIGHLIGHT';

  @override
  String get discoverHeroTitle => 'The Essence of the Mediterranean';

  @override
  String get discoverHeroSubtitle =>
      'Discover secret retreats and luxury experiences designed for the discerning traveler.';

  @override
  String get discoverSearchHint => 'Search restaurants, parties or beaches...';

  @override
  String get discoverFilters => 'Filters';

  @override
  String get discoverExploreMap => 'Explore Map';

  @override
  String get discoverExperiencesTitle => 'Exclusive Experiences';

  @override
  String get discoverCategoryGastronomy => 'Gastronomy';

  @override
  String get discoverExperienceRestaurants => 'Signature Restaurants';

  @override
  String get discoverCategoryExploration => 'Exploration';

  @override
  String get discoverExperienceSecretSpots => 'Secret Spots';

  @override
  String get discoverUpcomingEvents => 'Upcoming Events';

  @override
  String get discoverTickets => 'Tickets';

  @override
  String get discoverInteractiveMapTitle => 'Interactive Map';

  @override
  String get discoverInteractiveMapSubtitle =>
      'Explore points of interest near you.';

  @override
  String get discoverCurrentLocation => 'Current Location';

  @override
  String get eventDateTimeLabel => 'Date & Time';

  @override
  String get eventLocationLabel => 'Location';

  @override
  String get eventAboutTitle => 'About the Event';

  @override
  String get eventDirectionsTitle => 'How to get there';

  @override
  String get eventOpenGps => 'Open in GPS';

  @override
  String get eventStandardTicket => 'Standard Ticket';

  @override
  String get eventStandardTicketDesc => 'General access + 1 drink';

  @override
  String get eventServiceFee => 'Service Fee';

  @override
  String get eventPayNow => 'Pay Now';

  @override
  String get eventVipExperience => 'VIP Experience';

  @override
  String get eventLimited => 'LIMITED';

  @override
  String get eventVipDescription =>
      'Reserved table, bottle included and backstage access.';

  @override
  String get eventCheckAvailability => 'Check availability →';

  @override
  String get jetskiAdventureTag => 'Sea Adventure';

  @override
  String get jetskiHeroTitle => 'Master the Waves';

  @override
  String get jetskiHeroSubtitle => 'Premium high-performance jet ski rental.';

  @override
  String get jetskiDurationLabel => 'DURATION';

  @override
  String get jetskiDurationValue => '1 Hour — Quick Ride';

  @override
  String get jetskiExploreFleet => 'Explore Fleet';

  @override
  String get jetskiOurFleet => 'Our Fleet';

  @override
  String get jetskiBookNow => 'Book Now';

  @override
  String get jetskiSafetyTitle => 'Safety First';

  @override
  String get jetskiSafetyLifeJacketTitle => 'Life Jacket Included';

  @override
  String get jetskiSafetyLifeJacketSubtitle =>
      'Approved equipment for all weights.';

  @override
  String get jetskiSafetyBriefingTitle => 'Safety Briefing';

  @override
  String get jetskiSafetyBriefingSubtitle =>
      'Mandatory 15-min instruction before departure.';

  @override
  String get jetskiSafetyGpsTitle => 'GPS Monitoring';

  @override
  String get jetskiSafetyGpsSubtitle => 'Support team ready to intervene 24/7.';

  @override
  String get jetskiOurBase => 'Our Base';

  @override
  String get jetskiOpenMap => 'Open Map';

  @override
  String get premiumHomeSearchHint => 'Search destination or service...';

  @override
  String get premiumHomeNoResults => 'No results found';

  @override
  String get premiumHomeFastDelivery => 'Fast Delivery';

  @override
  String get premiumHomeGroceryPharmacy => 'Grocery & Pharmacy';

  @override
  String get premiumHomeIslandGuide => 'Island Guide';

  @override
  String get premiumHomeJetski => 'Jet Ski';

  @override
  String get premiumHomeTransportTitle => 'Transport & Mobility';

  @override
  String get premiumHomeTransportTrip => 'Trip';

  @override
  String get premiumHomeTransportMoto => 'Motorcycle';

  @override
  String get premiumHomeTransportScooter => 'Scooter';

  @override
  String get premiumHomeTransportBike => 'Bicycle';

  @override
  String get premiumHomeExperiencesTitle => 'Premium Experiences';

  @override
  String get premiumHomeJetskiRentalTitle => 'Jet Ski Rental';

  @override
  String get premiumHomeJetskiRentalDesc =>
      'Explore crystal-clear waters with our new premium rental service.';

  @override
  String get premiumHomeFromPrice => 'From €45';

  @override
  String get premiumHomeIslandGuideTitle => 'Exclusive Island Guide';

  @override
  String get premiumHomeIslandGuideDesc =>
      'Discover island secrets with personalized local itineraries.';

  @override
  String get rentalPickupLocation => 'Pickup Location';

  @override
  String get rentalDropoffLocation => 'Drop-off Location';

  @override
  String get rentalSamePickupHint => 'Same pickup location';

  @override
  String get rentalDateSelection => 'Date Selection';

  @override
  String get rentalDriverAge => 'Driver Age';

  @override
  String get rentalDriverAgeNote =>
      'Additional fees may apply for drivers outside the standard range.';

  @override
  String get rentalPremiumOnly => 'Premium Only';

  @override
  String get rentalLuxuryFleetOnly => 'Show luxury fleet only';

  @override
  String get rentalViewFleetOnMap => 'View fleet on map';

  @override
  String get rentalCarType => 'Car Type';

  @override
  String get rentalMaxPrice => 'Max Price';

  @override
  String get rentalTransmission => 'Transmission';

  @override
  String get rentalFilter => 'Filter';

  @override
  String get rentalPremiumHighlights => 'Premium Highlights';

  @override
  String rentalResultsFound(String count) {
    return '$count results found';
  }

  @override
  String get rentalPremiumChoice => 'Premium Choice';

  @override
  String get rentalAllCars => 'All Cars';

  @override
  String get rentalLoadMore => 'Load more vehicles';

  @override
  String get rentalVehicleDetails => 'Vehicle Details';

  @override
  String get rentalRating => 'Rating';

  @override
  String get rentalPowertrain => 'Powertrain';

  @override
  String get rentalCapacity => 'Capacity';

  @override
  String get rentalAcceleration => 'Acceleration';

  @override
  String get rentalInsuranceIncluded => 'Insurance Included';

  @override
  String get rentalFuelPolicy => 'Fuel';

  @override
  String get rentalCurrentBattery => 'Current Battery';

  @override
  String get rentalBookingSummary => 'Booking Summary';

  @override
  String get rentalTotalCost => 'Total Cost';

  @override
  String get rentalTechnicalSpecs => 'TECHNICAL SPECIFICATIONS';

  @override
  String get rentalReservationTotal => 'Reservation total';

  @override
  String get rentalContinueToPayment => 'Continue to Payment';

  @override
  String get rentalPerDay => '/day';

  @override
  String rentalSeats(String count) {
    return '$count Seats';
  }

  @override
  String get rentalBag => 'Bag';

  @override
  String get rentalBags => 'Bags';

  @override
  String get reservationReviewTitle => 'Reservation Review';

  @override
  String get reservationItinerary => 'Itinerary';

  @override
  String get reservationPickupLabel => 'PICKUP';

  @override
  String get reservationReturnLabel => 'RETURN';

  @override
  String get reservationSecurePayment => '100% Secure Payment';

  @override
  String get reservationSecurePaymentDesc =>
      'We use 256-bit SSL encryption to protect your data.';

  @override
  String get reservationCostSummary => 'Cost Summary';

  @override
  String get reservationNoHiddenFees => 'No hidden fees';

  @override
  String get reservationPaymentMethod => 'Payment Method';

  @override
  String get reservationCreditCard => 'Credit Card';

  @override
  String get reservationPayWithApplePay => 'Pay with Apple Pay';

  @override
  String get reservationConfirmAndPay => 'Confirm and Pay';

  @override
  String get reservationTermsPrefix =>
      'By clicking \"Confirm and Pay\", you accept our ';

  @override
  String get reservationTermsLink => 'Terms and Conditions';

  @override
  String get reservationFullInsurance => 'Full Insurance Included';

  @override
  String get reservationsEmptyTitle => 'You have no more reservations yet';

  @override
  String get reservationsEmptyBody =>
      'Plan your next trip with our premium fleet. Comfort and punctuality guaranteed.';

  @override
  String get reservationsExploreDestinations => 'Explore destinations';

  @override
  String get tripHistoryActivity => 'My Activity';

  @override
  String get tripHistoryTrips => 'Trips';

  @override
  String get tripHistoryThisMonth => 'This Month';

  @override
  String get tripHistoryFilterAll => 'All';

  @override
  String get tripHistoryFilterRecent => 'Recent Trips';

  @override
  String get tripHistoryFilterCompleted => 'Completed';

  @override
  String get tripHistoryFilterCancelled => 'Cancelled';

  @override
  String get tripHistoryFilterThisYear => 'This Year';

  @override
  String get tripHistoryStatusCancelled => 'Cancelled';

  @override
  String get tripHistoryNoDetails => 'No details';

  @override
  String get tripDetailsRateExperience => 'Rate your experience';

  @override
  String get tripDetailsDigitalInvoice => 'Digital Invoice';

  @override
  String get tripDetailsTotalPaid => 'Total Paid';

  @override
  String get tripDetailsMethod => 'Method';

  @override
  String get tripDetailsDownloadPdf => 'Download PDF';

  @override
  String get tripDetailsFareBase => 'Base Fare';

  @override
  String get tripDetailsFareDistance => 'Distance (12.5 km)';

  @override
  String get tripDetailsFareTime => 'Time (24 min)';

  @override
  String get tripDetailsFareDiscount => 'Promotional Discount';

  @override
  String get tripDetailsSupportTitle => 'Something went wrong?';

  @override
  String get tripDetailsSupportLostItem => 'Report lost item';

  @override
  String get tripDetailsSupportSafety => 'Safety complaint';

  @override
  String get tripDetailsSupportCustomer => 'Customer support';

  @override
  String get tripCompletedThanks => 'Thank you for riding with us.';

  @override
  String get tripCompletedFinalPrice => 'Final Price';

  @override
  String get tripCompletedOptimizedRoute => 'Optimized route';

  @override
  String get tripCompletedRateTrip => 'Rate the Trip';

  @override
  String get tripCompletedRateHint =>
      'How was your experience with the driver and vehicle?';

  @override
  String get tripCompletedCommentOptional => 'Comment (optional)';

  @override
  String get tripCompletedCommentHint => 'Share your opinion...';

  @override
  String get tripCompletedSubmitRating => 'Submit rating';

  @override
  String get tripCompletedRatingSent => 'Rating submitted';

  @override
  String get tripCompletedReportIssue => 'Report issue';

  @override
  String get tripInProgressStatusLabel => 'Trip Status';

  @override
  String get tripInProgressStatusValue => 'In progress';

  @override
  String get tripInProgressArrivalLabel => 'Estimated arrival';

  @override
  String get tripInProgressCostLabel => 'Estimated Cost';

  @override
  String get driverSearchSubtitle =>
      'Connecting you to the nearest vehicles in Central Lisbon.';

  @override
  String get driverSearchOrigin => 'ORIGIN';

  @override
  String get driverSearchEstimate => 'ESTIMATE';

  @override
  String get driverSearchCancelTrip => 'Cancel Trip';

  @override
  String get driverSearchOptimizing => 'Optimizing route in real time...';

  @override
  String get driverFoundWaiting => 'Awaiting confirmation...';

  @override
  String get driverFoundEstimatedTime => 'Estimated time';

  @override
  String get driverFoundFare => 'Fare';

  @override
  String get driverFoundCancelHint =>
      'You can cancel free of charge within the next 2 minutes while the driver confirms the booking.';

  @override
  String get driverEnRouteYourLocation => 'Your location';

  @override
  String get driverEnRouteMessage => 'Message';

  @override
  String get driverEnRouteCall => 'Call';

  @override
  String get tripDestinationSubtitle =>
      'Search for a destination or choose one of your frequent places.';

  @override
  String get tripDestinationSearchHint => 'Search address or point of interest';

  @override
  String get tripDestinationRecentPlaces => 'Recent Places';

  @override
  String get tripDestinationSuggestions => 'Suggestions & Favorites';

  @override
  String get tripDestinationExploreMap => 'Explore Map';

  @override
  String get tripDestinationTodaySuggestion => 'TODAY\'S SUGGESTION';

  @override
  String get tripDestinationViewFullMap => 'View Full Map';

  @override
  String get tripConfirmTransportType => 'Transport Type';

  @override
  String tripConfirmTotal(String amount) {
    return 'Total: $amount';
  }

  @override
  String get tripConfirmTrip => 'Confirm trip';

  @override
  String get tripConfirmPickupPoint => 'PICKUP POINT';

  @override
  String get tripConfirmFinalDestination => 'FINAL DESTINATION';

  @override
  String get tripConfirmTransportPremium => 'Premium';

  @override
  String get tripConfirmTransportEco => 'Eco-Electric';

  @override
  String get tripConfirmTransportShared => 'Shared';

  @override
  String get driverAvailable => 'Available';

  @override
  String get driverUnavailable => 'Unavailable';

  @override
  String get driverFleetStatus => 'Fleet Status';

  @override
  String get driverVerified => 'Verified';

  @override
  String get driverInOperation => 'In Operation';

  @override
  String get driverTodayEarnings => 'Today\'s Earnings';

  @override
  String get driverEarningsChange => '+12% vs. yesterday';

  @override
  String get driverTripsLabel => 'Trips';

  @override
  String get driverDistanceLabel => 'Distance';

  @override
  String get driverRecentTrips => 'Recent Trips';

  @override
  String get driverLocationCity => 'Lisbon, PT';

  @override
  String driverHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get driverNewRequest => 'New Request';

  @override
  String get driverPremiumTrip => 'Premium Trip';

  @override
  String get driverPickup => 'Pickup';

  @override
  String get driverDestination => 'Destination';

  @override
  String get driverDecline => 'DECLINE';

  @override
  String get driverAcceptTrip => 'ACCEPT TRIP';

  @override
  String get driverTripAcceptedTitle => 'Trip Accepted!';

  @override
  String get driverTripAcceptedSubtitle => 'Preparing navigation route...';

  @override
  String get driverPassenger => 'Passenger';

  @override
  String get driverEstimatedArrival => 'Estimated arrival';

  @override
  String get driverStartNavigation => 'Start Navigation Now';

  @override
  String get driverRequestExpiredTitle => 'Request Expired';

  @override
  String get driverRequestExpiredMessage =>
      'The 12-second time limit to accept the trip has expired.';

  @override
  String get driverUnavailableForRequests =>
      'Currently unavailable for new requests';

  @override
  String get driverBackToDashboard => 'Back to Dashboard';

  @override
  String get driverViewTripHistory => 'View Trip History';

  @override
  String driverDistanceToDestination(String distance) {
    return '$distance to destination';
  }

  @override
  String get driverVipPassenger => 'VIP Passenger';

  @override
  String get driverEstimatedTimeLabel => 'ESTIMATED TIME';

  @override
  String get driverDistanceStatLabel => 'DISTANCE';

  @override
  String get driverOnTheWay => 'On the way';

  @override
  String get driverArrivedStatus => 'Arrived at pickup';

  @override
  String get driverTripInProgressStatus => 'Trip in progress';

  @override
  String get driverArrivedButton => 'I\'ve arrived';

  @override
  String get driverStartTripButton => 'Start trip';

  @override
  String get driverFinishTripButton => 'Finish trip';

  @override
  String get adminReportsTitle => 'Detailed Reports';

  @override
  String get adminReportsExport => 'Export';

  @override
  String get adminReportsDateRangeLabel => 'Date Range';

  @override
  String get adminReportsVehicleFleetLabel => 'Vehicle / Fleet';

  @override
  String get adminReportsAllVehicles => 'All Vehicles';

  @override
  String get adminReportsTotalTrips => 'Total Trips';

  @override
  String get adminReportsTotalDistance => 'Total Distance';

  @override
  String get adminReportsTimeOnRoute => 'Time on Route';

  @override
  String get adminReportsTotalCost => 'Total Cost';

  @override
  String get adminReportsPendingDebt => 'Pending Debt';

  @override
  String get adminReportsOverdueInvoices => 'OVERDUE INVOICES';

  @override
  String get adminReportsMonthlyPerformance => 'Monthly Performance Analysis';

  @override
  String get adminReportsChartHint =>
      'Detailed visualization of cost trends and mileage processed for the selected period.';

  @override
  String get adminReportsLatestActivities => 'LATEST ACTIVITIES';

  @override
  String get adminReportsFleetEfficiency => 'FLEET EFFICIENCY';

  @override
  String get adminReportsOptimizedStatus => 'OPTIMIZED';

  @override
  String adminReportsOptimized(int percent) {
    return '$percent% OPTIMIZED';
  }

  @override
  String get adminReportsEfficiencyFooter =>
      'Your fleet is operating 15% above the industry average this quarter.';

  @override
  String get adminDrawerFleetManager => 'Fleet Manager';

  @override
  String get adminDrawerFleetSubtitle => 'Central Lisbon Fleet';

  @override
  String get adminDrawerRoleBadge => 'Admin';
}
