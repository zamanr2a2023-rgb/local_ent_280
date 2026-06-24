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
  String get save => 'Save';

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
  String get navBalance => 'Balance';

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
  String get authErrorEmailInUse => 'This email is already registered.';

  @override
  String get authErrorWeakPassword =>
      'Password is too weak. Use at least 6 characters.';

  @override
  String get authErrorRegistrationFailed =>
      'Could not create account. Please try again.';

  @override
  String get registerSubtitle =>
      'Create your account as a client or professional driver.';

  @override
  String get registerNameLabel => 'Full name';

  @override
  String get registerNameHint => 'e.g. John Smith';

  @override
  String get registerPhoneLabel => 'Phone (optional)';

  @override
  String get registerPhoneHint => 'e.g. +351910000000';

  @override
  String get registerConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerFillRequiredFields => 'Fill in name, email, and password.';

  @override
  String get registerPasswordTooShort =>
      'Password must be at least 6 characters.';

  @override
  String get registerPasswordMismatch => 'Passwords do not match.';

  @override
  String get registerAlreadyHaveAccount => 'Already have an account? ';

  @override
  String get registerSignInNow => 'Sign in now';

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
  String get profileRoleClient => 'Client';

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
  String get profileChangePhoto => 'Change profile photo';

  @override
  String get profilePhotoFromGallery => 'Choose from gallery';

  @override
  String get profilePhotoTakePhoto => 'Take photo';

  @override
  String get profilePhotoUpdated => 'Profile photo updated';

  @override
  String get profilePhotoUpdateFailed =>
      'Could not update profile photo. Try again.';

  @override
  String get profilePhotoPermissionDenied =>
      'Photo upload is not allowed. Contact support if the problem persists.';

  @override
  String get profilePhotoUploading => 'Uploading photo...';

  @override
  String get profileEditName => 'Edit name';

  @override
  String get profileNameHint => 'Your name';

  @override
  String get profileNameUpdated => 'Name updated';

  @override
  String get profileNameUpdateFailed => 'Could not update name. Try again.';

  @override
  String get profileNamePermissionDenied =>
      'Could not update your name. Check your session or contact support.';

  @override
  String get profileNameEmpty => 'Please enter your name.';

  @override
  String get homeAvailableBalance => 'Available balance';

  @override
  String get homeTopUp => 'View balance';

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
  String get clientBalanceTitle => 'Balance';

  @override
  String get clientBalanceSubtitle =>
      'Your account balance, updated in real time.';

  @override
  String get clientBalanceDebtLimit => 'Debt limit';

  @override
  String get clientBalanceLastUpdated => 'Last updated';

  @override
  String get clientBalanceHistoryTitle => 'Recent adjustments';

  @override
  String get clientBalanceHistoryEmpty => 'No adjustments yet';

  @override
  String get clientBalanceHistoryEmptyBody =>
      'Admin balance changes will appear here.';

  @override
  String get clientBalanceAdjustmentDefault => 'Balance adjustment';

  @override
  String get clientBalanceDebtWarningTitle => 'Debt limit reached';

  @override
  String get clientBalanceDebtWarningBody =>
      'Contact support to top up your balance and continue booking trips.';

  @override
  String get clientBalanceTopUpTitle => 'How to top up';

  @override
  String get clientBalanceTopUpBody =>
      'Balance top-ups are managed by support. Call support to request a credit — it will appear here after admin approval.';

  @override
  String get clientBalanceContactSupport => 'Contact support';

  @override
  String get clientBalanceSupportUnavailable =>
      'Support phone number unavailable. Contact the support team.';

  @override
  String get clientBalanceSupportCallFailed =>
      'Could not open the phone dialer on this device.';

  @override
  String get tripConfirmLimitExceededCallSupport => 'Call support';

  @override
  String get clientBalanceUnavailable => 'Balance unavailable';

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
  String get homeLocationLoading => 'Getting your location...';

  @override
  String get homeLocationUnavailable => 'Unable to get your location';

  @override
  String get homeRefreshLocation => 'Refresh location';

  @override
  String get homeSelectLocationOnMap => 'Select on map';

  @override
  String get homeSelectLocationOnMapHint =>
      'Move the map or tap the location button to use your current position.';

  @override
  String get homeUseMapLocation => 'Use this location';

  @override
  String get homeLocationPermissionTitle => 'Allow location access';

  @override
  String get homeLocationPermissionMessage =>
      'Local Transport needs your location to set your pickup point automatically.';

  @override
  String get homeLocationPermissionAllow => 'Allow';

  @override
  String get homeLocationPermissionDeny => 'Not now';

  @override
  String get homeLocationPermissionSettingsMessage =>
      'Location permission is disabled. Open settings to allow access.';

  @override
  String get homeLocationOpenSettings => 'Open settings';

  @override
  String get homeLocationServicesDisabled =>
      'Turn on location services on your device to use your current address.';

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
  String get premiumMobility => 'Local Transport';

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
  String get adminAppBarTitle => 'Local Transport';

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
  String adminPendingDebtorsCount(int count) {
    return '$count overdue invoices';
  }

  @override
  String adminActiveTripsTrendDynamic(String change) {
    return '$change vs. yesterday';
  }

  @override
  String get adminNoFleetVehicles => 'No vehicles in fleet yet';

  @override
  String get adminNoReportActivities => 'No completed trips yet';

  @override
  String adminBaseRateLive(String multiplier) {
    return 'Dynamic: Active ($multiplier)';
  }

  @override
  String get adminMonthlyReportsTitle => 'Monthly Reports';

  @override
  String get adminMonthlyReportsSubtitle => 'October performance';

  @override
  String get adminActivityMapTitle => 'Activity Map';

  @override
  String get adminActivityMapWaiting =>
      'Waiting for live trips and driver locations';

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
  String get adminHubTitle => 'Administration area';

  @override
  String get adminHubHeading => 'Administration area';

  @override
  String get adminHubSubtitle =>
      'Manage operations, fleet, pricing and support.';

  @override
  String get adminUsersTitle => 'Users';

  @override
  String get adminUsersDesc => 'Account and permissions management.';

  @override
  String get adminUsersHeading => 'Account and permissions management';

  @override
  String get adminUsersSubtitle => 'Manage team profiles, roles and access.';

  @override
  String get adminUsersSearchHint => 'Search by name, email, phone, or ID';

  @override
  String get adminUsersEmpty => 'No users found';

  @override
  String get adminUsersCreateTitle => 'Add user';

  @override
  String get adminUsersCreateSubtitle =>
      'Create a client, driver, manager, or admin account.';

  @override
  String get adminUsersCreateAction => 'Create user';

  @override
  String get adminUsersCreateSuccess => 'User created successfully';

  @override
  String get adminUsersCreateFailed => 'Could not create user';

  @override
  String get adminUsersRoleLabel => 'Role';

  @override
  String get adminUsersAddTooltip => 'Add user';

  @override
  String get adminStatusActive => 'Active';

  @override
  String get adminStatusInactive => 'Inactive';

  @override
  String get adminStatusOpen => 'Open';

  @override
  String get adminStatusResolved => 'Resolved';

  @override
  String get adminStatusConfigured => 'Configured';

  @override
  String get adminManagerPermissionsTitle => 'Manager permissions';

  @override
  String get adminManagerPermissionsDesc =>
      'Configure operational permission flags per manager.';

  @override
  String get adminManagerPermissionsHeading =>
      'Operational permission configuration';

  @override
  String get adminManagerPermissionsSubtitle =>
      'Configure, per manager, the allowed modules and operational actions.';

  @override
  String get adminManagersEmpty => 'No manager accounts found';

  @override
  String get adminStatusUnconfigured => 'Not configured';

  @override
  String get adminManagerPermissionsSaveAction => 'Save permissions';

  @override
  String get adminManagerPermissionsSaveSuccess => 'Manager permissions saved';

  @override
  String get adminManagerPermissionsSaveError =>
      'Could not save manager permissions';

  @override
  String get managerPermissionViewTrips => 'View trips';

  @override
  String get managerPermissionViewReports => 'View reports';

  @override
  String get managerPermissionViewAudit => 'View audit';

  @override
  String get managerPermissionViewDrivers => 'View drivers';

  @override
  String get managerPermissionViewClients => 'View clients';

  @override
  String get managerPermissionViewSupportRequests => 'View support requests';

  @override
  String get managerPermissionManageClientChats => 'Manage client chats';

  @override
  String get managerPermissionCancelTripBySupport => 'Cancel trip by support';

  @override
  String get managerPermissionUpdateTripSupport => 'Update trip support';

  @override
  String get managerPermissionResolvePasswordHelpRequest =>
      'Resolve password help requests';

  @override
  String get managerPermissionManageEvents => 'Manage events';

  @override
  String get managerPermissionAssignVehicleToDriver => 'Assign vehicle';

  @override
  String get managerPermissionEditDriverStatus => 'Edit driver status';

  @override
  String get managerPermissionManageTariffs => 'Manage tariffs';

  @override
  String get managerPermissionManageTripPackages => 'Manage trip packages';

  @override
  String get adminSupportRequestsTitle => 'Support tickets';

  @override
  String get adminSupportRequestsDesc =>
      'Password-help and support ticket inbox.';

  @override
  String get adminSupportEmpty => 'No support requests';

  @override
  String get adminIncidentsTitle => 'Operational incidents';

  @override
  String get adminIncidentsDesc => 'Driver monitoring incidents and approvals.';

  @override
  String get adminIncidentsEmpty => 'No operational incidents';

  @override
  String get adminIncidentDetailTitle => 'Incident details';

  @override
  String get adminIncidentCurrentState => 'Current state';

  @override
  String get adminIncidentTrip => 'Trip';

  @override
  String get adminIncidentStarted => 'Started';

  @override
  String get adminIncidentRouteSummary => 'Route summary';

  @override
  String get adminIncidentKmSummary => 'Km summary';

  @override
  String get adminMonitoringTitle => 'Monitoring settings';

  @override
  String get adminMonitoringDesc => 'Thresholds for operational monitoring.';

  @override
  String get adminMonitoringHeading => 'Operational monitoring';

  @override
  String get adminMonitoringSubtitle =>
      'Review operational monitoring thresholds.';

  @override
  String get adminMonitoringConfig => 'Current configuration';

  @override
  String get adminMonitoringLoading => 'Loading monitoring configuration...';

  @override
  String get adminMonitoringEnabled => 'Monitoring enabled';

  @override
  String get adminMonitoringEnabledHint =>
      'Operational monitoring runs only when enabled.';

  @override
  String get adminMonitoringBaseGeofence => 'Base geofence';

  @override
  String get adminMonitoringServiceGeofences => 'Service geofences';

  @override
  String adminMonitoringServiceGeofenceCount(int count) {
    return '$count configured';
  }

  @override
  String get adminMonitoringLastUpdated => 'Last updated';

  @override
  String get adminMonitoringSaveSuccess => 'Monitoring settings saved';

  @override
  String get adminReservationsTitle => 'Operational reservations';

  @override
  String get adminReservationsDesc => 'Schedule future rides for clients.';

  @override
  String get adminReservationsEmpty => 'No reservations';

  @override
  String get adminSupportSettingsTitle => 'Support contact';

  @override
  String get adminSupportSettingsDesc =>
      'Official support phone for password recovery.';

  @override
  String get adminSupportSettingsHeading => 'Support contact';

  @override
  String get adminSupportSettingsSubtitle =>
      'Define the official contact number.';

  @override
  String get adminSupportPhoneLabel => 'Support phone';

  @override
  String get adminEventsTitle => 'Events and alerts';

  @override
  String get adminEventsDesc => 'Send reminders and warnings to drivers.';

  @override
  String get adminEventsEmpty => 'No scheduled events';

  @override
  String get adminFleetTitle => 'Fleet';

  @override
  String get adminFleetDesc => 'Track vehicles, status and availability.';

  @override
  String get adminFleetNoDriver => 'No driver assigned';

  @override
  String get adminFleetDriver => 'Driver';

  @override
  String get adminFleetAssignDriverTitle => 'Assign driver';

  @override
  String get adminFleetAssignDriverDesc => 'Select a driver for this vehicle.';

  @override
  String get adminFleetAssignDriverEmpty => 'No active drivers found.';

  @override
  String get adminFleetAssignDriverSuccess => 'Driver assigned successfully.';

  @override
  String get adminTransportTypesTitle => 'Types of transport';

  @override
  String get adminTransportTypesDesc => 'Create and manage available types.';

  @override
  String get adminTransportTypesEmpty => 'No transport types';

  @override
  String get adminTripPackagesTitle => 'Trip packages';

  @override
  String get adminTripPackagesDesc =>
      'Prepaid packages with fixed destination and price.';

  @override
  String get adminTripPackagesEmpty => 'No trip packages';

  @override
  String get adminTariffsTitle => 'Tariffs';

  @override
  String get adminTariffsDesc => 'Set prices, rules and seasonal adjustments.';

  @override
  String get adminTariffAdminDefault => 'Admin default tariff';

  @override
  String get adminTariffPublicDefault => 'Public default tariff';

  @override
  String get adminBalancesTitle => 'Sales';

  @override
  String get adminBalancesDesc =>
      'Control balances, limits and pending operations.';

  @override
  String get adminBalancesEmpty => 'No balances';

  @override
  String get adminBalancesDebt => 'Debt';

  @override
  String get adminBalancesCredit => 'Credit';

  @override
  String get adminBalanceCurrent => 'Current balance';

  @override
  String get adminBalanceDebtLimit => 'Debt limit';

  @override
  String get adminBalanceAdjustAction => 'Adjust balance';

  @override
  String get adminBalanceAdjustTitle => 'Manual balance adjustment';

  @override
  String get adminBalanceCredit => 'Credit';

  @override
  String get adminBalanceDebt => 'Debt';

  @override
  String get adminBalanceAmountLabel => 'Value (EUR)';

  @override
  String get adminBalanceAmountRequired => 'Enter a valid amount.';

  @override
  String get adminBalanceReasonLabel => 'Reason';

  @override
  String get adminBalanceReasonRequired => 'Enter a reason.';

  @override
  String get adminBalanceConfirm => 'Confirm adjustment';

  @override
  String get adminBalanceAdjustSuccess => 'Balance updated';

  @override
  String get adminVehicleCreateTitle => 'New vehicle';

  @override
  String get adminVehicleEditTitle => 'Edit vehicle';

  @override
  String get adminVehicleCreateAction => 'Create vehicle';

  @override
  String get adminVehicleCreateSuccess => 'Vehicle created';

  @override
  String get adminVehicleAddPhoto => 'Add photo';

  @override
  String get adminVehiclePlateLabel => 'Registration';

  @override
  String get adminVehicleModelLabel => 'Model';

  @override
  String get adminVehicleCapacityLabel => 'Capacity';

  @override
  String get adminVehicleTransportTypeLabel => 'Default transport type';

  @override
  String get adminVehicleNoPreference => 'No preference';

  @override
  String get adminVehicleNotesLabel => 'Notes';

  @override
  String get adminVehicleActiveLabel => 'Active vehicle';

  @override
  String get adminVehicleRequiredFields => 'Fill registration and model.';

  @override
  String get adminTransportTypeCreateTitle => 'New type of transport';

  @override
  String get adminTransportTypeEditTitle => 'Edit transport type';

  @override
  String get adminTransportTypeCreateAction => 'Create type';

  @override
  String get adminTransportTypeCreateSuccess => 'Transport type created';

  @override
  String get adminTransportTypeNameLabel => 'Name';

  @override
  String get adminTransportTypeNameRequired => 'Enter a name.';

  @override
  String get adminTransportTypeBaseFareLabel => 'Initial base rate';

  @override
  String get adminTransportTypeMultiplierLabel => 'Package price adjustment';

  @override
  String get adminTransportTypeDescriptionLabel => 'Description';

  @override
  String get adminTripPackagesOpsTab => 'Operation';

  @override
  String get adminTripPackagesCatalogTab => 'Catalog';

  @override
  String get adminTripPackagesOpsEmpty =>
      'No bookings in the operations queue.';

  @override
  String get adminTripPackagesCatalogHeading => 'Package catalog';

  @override
  String get adminTripPackagesCatalogSubtitle =>
      'Manage commercial products with fixed destination, fixed price, and allowed transport types.';

  @override
  String get adminPackageCreateTitle => 'Create package';

  @override
  String get adminPackageEditTitle => 'Edit package';

  @override
  String get adminPackageCreateAction => 'Create package';

  @override
  String get adminPackageEditAction => 'Edit package';

  @override
  String get adminPackageCreateSuccess => 'Package saved';

  @override
  String get adminPackageNameLabel => 'Package name';

  @override
  String get adminPackageNameMin => 'Enter a name with at least 3 characters.';

  @override
  String get adminPackageDestinationLabel => 'Fixed destination';

  @override
  String get adminPackageDescriptionLabel => 'Description';

  @override
  String get adminPackageDescriptionMin =>
      'Enter a description with at least 10 characters.';

  @override
  String get adminPackagePriceLabel => 'Fixed price (EUR)';

  @override
  String get adminPackagePriceInvalid => 'Enter a valid price.';

  @override
  String get adminPackageTransportRequired =>
      'Select at least one transport type.';

  @override
  String get adminPackageSalesActive => 'Sales active';

  @override
  String get adminPackageSalesActiveHint =>
      'When disabled, the package no longer appears for new purchases.';

  @override
  String get adminPackageAllowedTransport => 'Allowed transport types';

  @override
  String get adminSupportReplyTitle => 'Reply to ticket';

  @override
  String get adminSupportReplyLabel => 'Message';

  @override
  String get adminSupportReplyHint => 'Write your reply to the client...';

  @override
  String adminSupportRequestedAt(String date) {
    return 'requested at $date';
  }

  @override
  String get adminSupportReplyAction => 'Reply';

  @override
  String get adminSupportReplyRequired => 'Enter a message.';

  @override
  String get adminSupportReplySuccess => 'Reply sent';

  @override
  String get adminSupportResolveAction => 'Mark as resolved';

  @override
  String get adminSupportResolveSuccess => 'Ticket resolved';

  @override
  String get adminReportsTabOverview => 'Operational Overview';

  @override
  String get adminReportsTabClient => 'Customer Statement';

  @override
  String get adminReportsTabDriver => 'Driver\'s Statement';

  @override
  String get adminReportsTabComingSoon =>
      'Trip and balance statement reports will be available soon.';

  @override
  String get adminCurrencyTitle => 'Currency settings';

  @override
  String get adminCurrencyDesc => 'FX rates used for CVE, EUR and USD.';

  @override
  String get adminCurrencyHeading => 'Currency settings';

  @override
  String get adminCurrencySubtitle =>
      'Set exchange rates for EUR, CVE and USD display.';

  @override
  String get adminCurrencyCveToEur => 'CVE to EUR';

  @override
  String get adminCurrencyCveToUsd => 'CVE to USD';

  @override
  String get adminCurrencySaveSuccess => 'Currency settings saved';

  @override
  String get adminCurrencyInvalidRate =>
      'Enter valid exchange rates greater than zero';

  @override
  String get adminReportsDesc => 'Analyze operation and performance metrics.';

  @override
  String get adminAuditTitle => 'Audit';

  @override
  String get adminAuditDesc => 'See who adjusted balances and rates.';

  @override
  String get adminAuditEmpty => 'No audit entries';

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
  String premiumHomeFromPrice(String price) {
    return 'From $price';
  }

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
  String get rentalLoadError => 'Could not load vehicles. Please try again.';

  @override
  String get rentalNoVehicles => 'No vehicles available at the moment.';

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
  String get tripHistoryStatusInProgress => 'In progress';

  @override
  String get tripHistoryStatusScheduled => 'Scheduled';

  @override
  String get tripHistoryEmpty => 'No trips yet';

  @override
  String get tripHistoryEmptyBody =>
      'Your trips will appear here after you request a ride.';

  @override
  String get tripHistoryLoadError => 'Could not load trips. Please try again.';

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
  String get driverSearchSubtitleFallback =>
      'Connecting you to the nearest available vehicles.';

  @override
  String driverSearchSubtitleArea(String area) {
    return 'Connecting you to the nearest vehicles near $area.';
  }

  @override
  String get driverSearchOrigin => 'ORIGIN';

  @override
  String get driverSearchEstimate => 'ESTIMATE';

  @override
  String get driverSearchWaitEstimate => '3–5 min';

  @override
  String driverSearchWaitMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get driverSearchCancelTrip => 'Cancel Trip';

  @override
  String get driverSearchCancelling => 'Cancelling...';

  @override
  String get driverSearchCancelFailed => 'Unable to cancel the trip.';

  @override
  String get driverSearchNoDrivers => 'No drivers available. Please try again.';

  @override
  String get driverSearchNoDriversNearby =>
      'No drivers found near your pickup. The driver must be available within 100 km.';

  @override
  String get driverSearchNoDriversMissingVehicle =>
      'Nearby drivers have no vehicle assigned. Ask admin to assign a vehicle.';

  @override
  String get homePickupOutsideServiceArea =>
      'Pickup is outside the service area. Use a location in Cabo Verde (or Portugal for dev testing).';

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
  String get tripDestinationSuggestionTitle => 'Belém & Monuments';

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
  String get tripConfirmSessionInvalid =>
      'Invalid session. Please sign in again.';

  @override
  String get tripConfirmRouteLoading =>
      'Please wait for the route to finish loading.';

  @override
  String get tripConfirmCreateFailed =>
      'Unable to create the trip. Please try again.';

  @override
  String get tripConfirmPermissionDenied =>
      'Could not create the trip. Check your balance and session, or contact support.';

  @override
  String get tripConfirmDestinationFailed =>
      'Could not locate the destination. Check the address or pick a suggestion from the list.';

  @override
  String get tripConfirmDirectionsFailed =>
      'Could not calculate the route. Check your connection and Google Maps API settings.';

  @override
  String get tripConfirmTransportTypesFailed =>
      'Transport options are unavailable. Try again in a moment.';

  @override
  String get tripConfirmPriceUnavailable =>
      'Trip price is unavailable. Wait for the route to load or choose another destination.';

  @override
  String get tripConfirmLimitExceeded =>
      'Insufficient balance to request this trip. Top up your account and try again.';

  @override
  String get tripConfirmDirectionsApproximate =>
      'Exact route unavailable. Distance and price are approximate.';

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
  String driverEarningsVsYesterday(String change) {
    return '$change vs. yesterday';
  }

  @override
  String get driverNoRecentTrips => 'No completed trips yet';

  @override
  String get driverNoVehicleAssigned => 'No vehicle assigned';

  @override
  String get driverTripsLabel => 'Trips';

  @override
  String get driverDistanceLabel => 'Distance';

  @override
  String get driverRecentTrips => 'Recent Trips';

  @override
  String get driverLocationCity => 'Praia, CV';

  @override
  String get driverLocationLoading => 'Locating...';

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

  @override
  String get adminTariffNoTransportTypes => 'Configure transport types first.';

  @override
  String get adminTariffInvalidAmounts => 'Enter valid amounts.';

  @override
  String adminTariffInvalidBaseFare(String typeName) {
    return 'Invalid base fare for $typeName.';
  }

  @override
  String get rentalAc => 'AC';

  @override
  String get rentalElectric => 'Electric';

  @override
  String get rentalAllTypes => 'All types';

  @override
  String get rentalCarTypeSedan => 'Sedan';

  @override
  String get rentalCarTypeSuv => 'SUV';

  @override
  String get rentalCarTypeExecutive => 'Executive';

  @override
  String get rentalCarTypeElectric => 'Electric';

  @override
  String get rentalTransmissionAll => 'All';

  @override
  String get rentalTransmissionAutomatic => 'Automatic';

  @override
  String get rentalTransmissionManual => 'Manual';

  @override
  String get rentalAnyPrice => 'Any price';

  @override
  String rentalPriceUpTo(String price) {
    return 'Up to $price';
  }

  @override
  String driverEnRouteEtaAt(String time) {
    return 'ETA • $time';
  }

  @override
  String get rentalWeekdaySun => 'SUN';

  @override
  String get rentalWeekdayMon => 'MON';

  @override
  String get rentalWeekdayTue => 'TUE';

  @override
  String get rentalWeekdayWed => 'WED';

  @override
  String get rentalWeekdayThu => 'THU';

  @override
  String get rentalWeekdayFri => 'FRI';

  @override
  String get rentalWeekdaySat => 'SAT';

  @override
  String get rentalDemoPickupLocation => 'Lisbon Airport, PT';

  @override
  String get rentalDriverAgeYoung => '18 - 25 years';

  @override
  String get rentalDriverAgeStandard => '26 - 65 years';

  @override
  String get rentalDriverAgeSenior => '65+ years';

  @override
  String get rentalDemoSportPremium => 'SPORT PREMIUM';

  @override
  String get rentalDemoVehicleName => 'Porsche Taycan 4S';

  @override
  String get rentalInsuranceDescription =>
      'Full protection against own damage and 24/7 roadside assistance at no extra cost.';

  @override
  String get rentalInsuranceFranchiseWaiver => 'Excess waiver';

  @override
  String get rentalInsuranceCdw => 'Collision damage (CDW)';

  @override
  String get rentalFuelPolicyElectric =>
      'Full-to-full policy or return with more than 80% charge for electric vehicles.';

  @override
  String rentalBookingRentalDays(int days) {
    return 'Rental ($days days)';
  }

  @override
  String get rentalBookingPremiumInsurance => 'Premium insurance';

  @override
  String get rentalBookingIncluded => 'Included';

  @override
  String get rentalBookingAirportFees => 'Airport fees';

  @override
  String get rentalDemoAirportLocation => 'Lisbon Airport, LIS';

  @override
  String get rentalSpecPower => 'Power';

  @override
  String get rentalSpecPowerValue => '530 hp';

  @override
  String get rentalSpecRange => 'WLTP range';

  @override
  String get rentalSpecRangeValue => '463 km';

  @override
  String get rentalSpecDrive => 'Drive';

  @override
  String get rentalSpecDriveValue => 'All-wheel (AWD)';

  @override
  String rentalVehicleSummary(String price, String seats, String transmission) {
    return '$price · $seats · $transmission';
  }

  @override
  String get eventDemoGenre => 'ELECTRONIC MUSIC';

  @override
  String get eventDemoTitle => 'Summer Gala: Porto Sunset';

  @override
  String get eventDemoDescription =>
      'Get ready for the most exclusive night of the year. The Summer Gala in Porto combines melodic electronic music with stunning views over the Douro River. Premium catering, VIP lounge areas and an immersive audiovisual experience await.';

  @override
  String get eventDemoVenue => 'Alfândega do Porto';

  @override
  String get eventPaymentMbway => 'MB WAY';

  @override
  String get discoverMapRestaurantLabel => 'Maré Restaurant';

  @override
  String get discoverMapBeachLabel => 'Secret Beach';

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
  String get reservationDemoAirport => 'Lisbon Airport (LIS)';

  @override
  String get reservationDemoPickupDateTime => '15 Oct, 2023 at 10:00';

  @override
  String get reservationDemoReturnDateTime => '20 Oct, 2023 at 18:00';

  @override
  String reservationRentalDaysLine(int days) {
    return 'Rental ($days days)';
  }

  @override
  String get reservationInsuranceLine => 'Full insurance';

  @override
  String get reservationDefaultVehicle => 'Vehicle';

  @override
  String get reservationDefaultCity => 'Lisbon';
}
