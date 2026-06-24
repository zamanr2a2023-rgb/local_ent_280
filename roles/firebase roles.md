rules_version='2'

service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() {
      return request.auth != null;
    }

    function userDoc(uid) {
      return get(/databases/$(database)/documents/users/$(uid));
    }

    // Prefer Firestore users/{uid}.role (this app stores role in Firestore, not auth claims).
    function role() {
      return !isSignedIn()
        ? null
        : (roleFromUserDoc() != null
            ? roleFromUserDoc()
            : (request.auth.token.keys().hasAny(['role'])
                ? request.auth.token.role
                : null));
    }

    function roleFromUserDoc() {
      let userData = userDoc(request.auth.uid).data;
      return userData != null && userData.keys().hasAny(['role'])
        ? userData.role
        : null;
    }

    function isAdmin() {
      return role() == 'admin';
    }

    function isManager() {
      return role() == 'manager';
    }

    function hasManagerClaimsMap() {
      return isManager()
        && request.auth.token.keys().hasAny(['mp'])
        && request.auth.token.mp is map;
    }

    function managerCanVt() {
      return hasManagerClaimsMap()
        && request.auth.token.mp.keys().hasAny(['vt'])
        && request.auth.token.mp.vt == true;
    }

    function managerCanVr() {
      return hasManagerClaimsMap()
        && request.auth.token.mp.keys().hasAny(['vr'])
        && request.auth.token.mp.vr == true;
    }

    function managerCanVa() {
      return hasManagerClaimsMap()
        && request.auth.token.mp.keys().hasAny(['va'])
        && request.auth.token.mp.va == true;
    }

    function managerCanVd() {
      return hasManagerClaimsMap()
        && request.auth.token.mp.keys().hasAny(['vd'])
        && request.auth.token.mp.vd == true;
    }

    function managerCanVc() {
      return hasManagerClaimsMap()
        && request.auth.token.mp.keys().hasAny(['vc'])
        && request.auth.token.mp.vc == true;
    }

    function managerCanVs() {
      return hasManagerClaimsMap()
        && request.auth.token.mp.keys().hasAny(['vs'])
        && request.auth.token.mp.vs == true;
    }

    function managerCanCh() {
      return hasManagerClaimsMap()
        && request.auth.token.mp.keys().hasAny(['ch'])
        && request.auth.token.mp.ch == true;
    }

    function managerCanTs() {
      return hasManagerClaimsMap()
        && request.auth.token.mp.keys().hasAny(['ts'])
        && request.auth.token.mp.ts == true;
    }

    function managerCanMe() {
      return hasManagerClaimsMap()
        && request.auth.token.mp.keys().hasAny(['me'])
        && request.auth.token.mp.me == true;
    }

    function managerCanAv() {
      return hasManagerClaimsMap()
        && request.auth.token.mp.keys().hasAny(['av'])
        && request.auth.token.mp.av == true;
    }

    function managerCanEd() {
      return hasManagerClaimsMap()
        && request.auth.token.mp.keys().hasAny(['ed'])
        && request.auth.token.mp.ed == true;
    }

    function managerCanMt() {
      return hasManagerClaimsMap()
        && request.auth.token.mp.keys().hasAny(['mt'])
        && request.auth.token.mp.mt == true;
    }

    function managerCanTp() {
      return hasManagerClaimsMap()
        && request.auth.token.mp.keys().hasAny(['tp'])
        && request.auth.token.mp.tp == true;
    }

    function isOps() {
      return isAdmin() || isManager();
    }

    function isClient() {
      return role() == 'client';
    }

    function isDriver() {
      return role() == 'driver';
    }

    function isAllowedUiCurrency(value) {
      return value in ['CVE', 'EUR', 'USD'];
    }

    function isReminderOffsetInWriteRange(value) {
      return value is int && value >= 1 && value <= 60;
    }

    function hasValidReminderOffsetsForWrite(offsets) {
      return offsets is list
        && offsets.size() >= 1
        && offsets.size() <= 5
        && (offsets.size() < 1 || isReminderOffsetInWriteRange(offsets[0]))
        && (offsets.size() < 2 || isReminderOffsetInWriteRange(offsets[1]))
        && (offsets.size() < 3 || isReminderOffsetInWriteRange(offsets[2]))
        && (offsets.size() < 4 || isReminderOffsetInWriteRange(offsets[3]))
        && (offsets.size() < 5 || isReminderOffsetInWriteRange(offsets[4]));
    }

    function canReadScheduledEvent(data) {
      return isAdmin()
        || (isManager() && managerCanMe())
        || (isSignedIn()
          && !isManager()
          && (data.targetType == 'broadcast'
            || data.targetIds.hasAny([request.auth.uid])));
    }

    function tripClientId(data) {
      return data.clientId;
    }

    function tripDriverId(data) {
      return data.assignedDriverId;
    }

    function isTripClient() {
      return isSignedIn() && tripClientId(resource.data) == request.auth.uid;
    }

    function isTripDriver() {
      return isSignedIn() && tripDriverId(resource.data) == request.auth.uid;
    }

    function isTripParticipant(tripId) {
      return isSignedIn()
        && (tripClientId(get(/databases/$(database)/documents/trips/$(tripId)).data)
            == request.auth.uid
          || tripDriverId(get(/databases/$(database)/documents/trips/$(tripId)).data)
            == request.auth.uid);
    }

    function normalizeTripStatus(status) {
      return status == null
        ? null
        : status == 'requested'
          ? 'REQUESTED'
          : status == 'driver_assigned_waiting_acceptance'
            ? 'DRIVER_ASSIGNED_WAITING_ACCEPTANCE'
            : status == 'driver_accepted'
              ? 'DRIVER_ACCEPTED'
              : status == 'driver_declined'
                ? 'DRIVER_DECLINED'
                : status == 'no_drivers_available'
                  ? 'NO_DRIVERS_AVAILABLE'
                  : status == 'driver_en_route'
                    ? 'DRIVER_EN_ROUTE'
                    : status == 'driver_arrived'
                      ? 'DRIVER_ARRIVED'
                      : status == 'in_trip'
                        ? 'IN_TRIP'
                        : status == 'arrived_destination'
                          ? 'ARRIVED_DESTINATION'
                          : status == 'extension_window'
                            ? 'EXTENSION_WINDOW'
                            : status == 'completed'
                              ? 'COMPLETED'
                              : status == 'charge_applied'
                                ? 'CHARGE_APPLIED'
                                : status == 'cancelled_by_client'
                                  ? 'CANCELLED_BY_CLIENT'
                                  : status == 'cancelled_by_driver'
                                    ? 'CANCELLED_BY_DRIVER'
                                    : status == 'no_show'
                                      ? 'NO_SHOW'
                                      : status;
    }

    function isTripStatusActiveForClient(trip) {
      let status = normalizeTripStatus(trip.status);
      return status in [
        'DRIVER_ASSIGNED_WAITING_ACCEPTANCE',
        'DRIVER_ACCEPTED',
        'DRIVER_EN_ROUTE',
        'DRIVER_ARRIVED',
        'IN_TRIP',
        'ARRIVED_DESTINATION',
        'EXTENSION_WINDOW',
        'COMPLETED',
        'CHARGE_APPLIED'
      ];
    }

    function isTripAssignedToClientDriver(trip, driverId) {
      return trip != null
        && tripClientId(trip) == request.auth.uid
        && tripDriverId(trip) == driverId
        && isTripStatusActiveForClient(trip);
    }

    function canClientAccessDriverData(driverId, currentTripId) {
      return isSignedIn()
        && currentTripId != null
        && isTripAssignedToClientDriver(
          get(/databases/$(database)/documents/trips/$(currentTripId)).data,
          driverId
        );
    }

    function isSelfUserUpdateAllowed() {
      let changed = request.resource.data.diff(resource.data).affectedKeys();
      return request.resource.data.role == resource.data.role
        && changed.hasOnly([
          'uiCurrency',
          'updatedAt'
        ])
        && request.resource.data.uiCurrency is string
        && isAllowedUiCurrency(request.resource.data.uiCurrency)
        && request.resource.data.updatedAt == request.time;
    }

    // Client, driver, and admin can update their own profile name and photo.
    function isSelfProfileUpdateAllowed() {
      let changed = request.resource.data.diff(resource.data).affectedKeys();
      return request.resource.data.role == resource.data.role
        && changed.hasOnly([
          'name',
          'photoUrl',
          'updatedAt'
        ])
        && (!changed.hasAny(['name'])
          || (request.resource.data.name is string
            && request.resource.data.name.size() > 0
            && request.resource.data.name.size() <= 120))
        && (!changed.hasAny(['photoUrl'])
          || (request.resource.data.photoUrl is string
            && request.resource.data.photoUrl.size() > 0
            && request.resource.data.photoUrl.size() <= 4096))
        && (!changed.hasAny(['updatedAt'])
          || (request.resource.data.updatedAt == request.time
            || request.resource.data.updatedAt is timestamp));
    }

    function isSelfRegistrationAllowed() {
      let data = request.resource.data;
      return isSignedIn()
        && request.auth.uid == uid
        && data.role in ['client', 'driver']
        && data.keys().hasOnly([
          'role',
          'name',
          'phone',
          'email',
          'photoUrl',
          'isActive',
          'uiCurrency',
          'createdAt',
          'updatedAt'
        ])
        && data.name is string
        && data.name.size() > 0
        && data.name.size() <= 120
        && data.email is string
        && data.email.size() > 0
        && data.isActive == true
        && (!data.keys().hasAny(['phone']) || data.phone is string)
        && (!data.keys().hasAny(['photoUrl']) || data.photoUrl is string)
        && (
          !data.keys().hasAny(['uiCurrency'])
          || (data.uiCurrency is string
            && isAllowedUiCurrency(data.uiCurrency))
        )
        && (!data.keys().hasAny(['createdAt'])
          || data.createdAt == request.time
          || data.createdAt is timestamp)
        && (!data.keys().hasAny(['updatedAt'])
          || data.updatedAt == request.time
          || data.updatedAt is timestamp);
    }

    function isManagerDriverUserUpdateAllowed() {
      let changed = request.resource.data.diff(resource.data).affectedKeys();
      return resource.data.role == 'driver'
        && request.resource.data.role == resource.data.role
        && changed.hasOnly([
          'name',
          'phone',
          'photoUrl',
          'email',
          'isActive',
          'updatedAt'
        ])
        && request.resource.data.updatedAt == request.time;
    }

    function isManagerDriverStatusCreateAllowed() {
      return request.resource.data.keys().hasOnly([
          'isActive',
          'isAvailable',
          'availabilityEnabled',
          'updatedAt'
        ])
        && request.resource.data.updatedAt == request.time;
    }

    function isManagerDriverStatusUpdateAllowed() {
      let changed = request.resource.data.diff(resource.data).affectedKeys();
      return changed.hasOnly([
          'isActive',
          'isAvailable',
          'availabilityEnabled',
          'updatedAt'
        ])
        && request.resource.data.updatedAt == request.time;
    }

    function isDriverAssignmentCreateAllowed() {
      return request.resource.data.keys().hasOnly([
          'vehicleId',
          'updatedAt'
        ])
        && request.resource.data.updatedAt == request.time;
    }

    function isDriverAssignmentUpdateAllowed() {
      let changed = request.resource.data.diff(resource.data).affectedKeys();
      return changed.hasOnly([
          'vehicleId',
          'updatedAt'
        ])
        && request.resource.data.updatedAt == request.time;
    }

    function isManagerVehicleUpdateAllowed() {
      let changed = request.resource.data.diff(resource.data).affectedKeys();
      return changed.hasOnly([
          'isActive',
          'updatedAt'
        ])
        && request.resource.data.updatedAt == request.time;
    }

    function isManagerTripSupportUpdateAllowed() {
      let changed = request.resource.data.diff(resource.data).affectedKeys();
      return changed.hasOnly([
          'supportNote',
          'supportStatus',
          'supportUpdatedAt',
          'supportUpdatedBy',
          'updatedAt'
        ])
        && request.resource.data.supportUpdatedBy == request.auth.uid
        && request.resource.data.supportUpdatedAt == request.time
        && request.resource.data.updatedAt == request.time
        && request.resource.data.clientSupport == resource.data.clientSupport;
    }

    function isClientTripCreateAllowed() {
      let data = request.resource.data;
      return isSignedIn()
        && roleFromUserDoc() == 'client'
        && data.clientId == request.auth.uid
        && data.status == 'REQUESTED'
        && data.isActive == true
        && (!data.keys().hasAny(['assignedDriverId']) || data.assignedDriverId == null)
        && data.pickup is map
        && data.pickup.address is string
        && data.pickup.latitude is number
        && data.pickup.longitude is number
        && data.destination is map
        && data.destination.address is string
        && data.destination.latitude is number
        && data.destination.longitude is number
        && data.transportType is map
        && data.transportType.id is string
        && data.transportType.name is string
        && data.meteringSnapshot is map
        && data.clientSupport is map
        && data.clientSupport.displayName is string
        && (!data.clientSupport.keys().hasAny(['phone']) || data.clientSupport.phone is string)
        && data.createdAt == request.time
        && data.requestedAt == request.time
        && data.updatedAt == request.time;
    }

    function isClientTripCancelUpdateAllowed() {
      let changed = request.resource.data.diff(resource.data).affectedKeys();
      let status = normalizeTripStatus(resource.data.status);
      return isTripClient()
        && changed.hasOnly([
          'status',
          'isActive',
          'updatedAt'
        ])
        && request.resource.data.status == 'CANCELLED_BY_CLIENT'
        && request.resource.data.isActive == false
        && request.resource.data.updatedAt == request.time
        && status in [
          'REQUESTED',
          'DRIVER_ASSIGNED_WAITING_ACCEPTANCE'
        ];
    }

    function isClientTripRatingUpdateAllowed() {
      let changed = request.resource.data.diff(resource.data).affectedKeys();
      let status = normalizeTripStatus(resource.data.status);
      let rating = request.resource.data.rating;
      return changed.hasOnly([
          'rating'
        ])
        && status in [
          'COMPLETED',
          'CHARGE_APPLIED'
        ]
        && !resource.data.keys().hasAny(['rating'])
        && rating is map
        && rating.keys().hasOnly([
          'stars',
          'feedback',
          'clientId',
          'createdAt'
        ])
        && rating.stars is int
        && rating.stars >= 1
        && rating.stars <= 5
        && (!rating.keys().hasAny(['feedback']) || rating.feedback is string)
        && rating.clientId == request.auth.uid
        && rating.createdAt == request.time;
    }

    function isDriverTripMeteringUpdateAllowed() {
      let changed = request.resource.data.diff(resource.data).affectedKeys();
      let status = normalizeTripStatus(resource.data.status);
      return isTripDriver()
        && status in [
          'DRIVER_ARRIVED',
          'IN_TRIP',
          'ARRIVED_DESTINATION',
          'EXTENSION_WINDOW',
          'COMPLETED',
          'CHARGE_APPLIED'
        ]
        && changed.hasOnly([
          'meteringSnapshot'
        ]);
    }

    function canReadPublicTariff(tariffId) {
      return tariffId == 'public_default'
        && (isAdmin() || isClient() || isDriver());
    }

    function canReadAdminTariff(tariffId) {
      return tariffId == 'admin_default'
        && (isAdmin() || managerCanMt());
    }

    function canReadCancellationPolicy(docId) {
      return ((isAdmin() || isClient() || isDriver())
          && docId == 'cancellation_policy_public')
        || (isAdmin() && docId == 'cancellation_policy_admin');
    }

    function canWriteCancellationPolicy(docId) {
      return isAdmin() && docId == 'cancellation_policy_admin';
    }

    function canReadPricingCollections() {
      return isAdmin() || isClient() || isDriver();
    }

    function canReadCurrencyConfig(docId) {
      return (isAdmin() || isManager() || isClient() || isDriver())
        && docId == 'currency';
    }

    function canWriteCurrencyConfig(docId) {
      return isAdmin() && docId == 'currency';
    }

    function canReadSupportConfig(docId) {
      return isAdmin() && docId == 'support';
    }

    function canWriteSupportConfig(docId) {
      return isAdmin() && docId == 'support';
    }

    function canReadOperationalMonitoringConfig(docId) {
      return docId == 'operations_monitoring'
        && (isAdmin() || managerCanTs());
    }

    function canReadChatThread(data) {
      return isSignedIn()
        && (
          (isClient() && data.clientId == request.auth.uid)
          || (isDriver() && data.driverId == request.auth.uid)
          || isAdmin()
          || (isManager()
            && (
              (data.type == 'support_client_ops' && managerCanVs())
              || (data.type == 'trip_client_driver' && managerCanCh())
            ))
        );
    }

    function canReadClientSupportThreadBeforeCreation(threadId) {
      return isClient()
        && threadId == ('support_client_' + request.auth.uid);
    }

    function canReadChatThreadById(threadId) {
      return canReadClientSupportThreadBeforeCreation(threadId)
        || canReadChatThread(
          get(/databases/$(database)/documents/chatThreads/$(threadId)).data
        );
    }

    function canWriteOperationalMonitoringConfig(docId) {
      return docId == 'operations_monitoring'
        && (isAdmin() || managerCanTs());
    }

    function canManageOperationalReservations() {
      return isAdmin() || (isManager()
        && managerCanVt()
        && managerCanVd()
        && managerCanVc());
    }

    function isInternalStaffReservation(data) {
      return data.source == 'internal_staff';
    }

    function isPackageReservation(data) {
      return data.source == 'package';
    }

    function isClientVehicleRentalReservationCreateAllowed() {
      return isClient()
        && request.resource.data.source == 'vehicle_rental'
        && request.resource.data.clientId == request.auth.uid
        && request.resource.data.status == 'pending'
        && request.resource.data.vehicleId is string
        && request.resource.data.vehicleLabel is string
        && request.resource.data.scheduledAt is timestamp
        && request.resource.data.pickup is map
        && request.resource.data.destination is map
        && request.resource.data.estimatedTotalMinor is int
        && request.resource.data.createdAt == request.time
        && request.resource.data.updatedAt == request.time;
    }

    function isInternalStaffReservationCreateAllowed() {
      return request.resource.data.source == 'internal_staff'
        && request.resource.data.clientId is string
        && request.resource.data.assignedDriverId is string
        && request.resource.data.scheduledDayKey is string
        && request.resource.data.scheduledMinutesLocal is int
        && request.resource.data.createdByUserId == request.auth.uid
        && request.resource.data.createdByRole == role()
        && request.resource.data.keys().hasOnly([
          'source',
          'clientId',
          'assignedDriverId',
          'scheduledAt',
          'scheduledDayKey',
          'scheduledMinutesLocal',
          'status',
          'pickup',
          'destination',
          'transportType',
          'createdByUserId',
          'createdByRole',
          'createdAt',
          'updatedAt'
        ])
        && request.resource.data.status == 'scheduled';
    }

    function isInternalStaffReservationUpdateAllowed() {
      let changed = request.resource.data.diff(resource.data).affectedKeys();
      return isInternalStaffReservation(resource.data)
        && resource.data.keys().hasAll([
          'source',
          'clientId',
          'createdByUserId',
          'createdByRole'
        ])
        && request.resource.data.keys().hasAll([
          'source',
          'clientId',
          'createdByUserId',
          'createdByRole',
          'scheduledDayKey',
          'scheduledMinutesLocal'
        ])
        && request.resource.data.source == resource.data.source
        && request.resource.data.clientId == resource.data.clientId
        && request.resource.data.scheduledDayKey is string
        && request.resource.data.scheduledMinutesLocal is int
        && request.resource.data.createdByUserId == resource.data.createdByUserId
        && request.resource.data.createdByRole == resource.data.createdByRole
        && changed.hasOnly([
          'assignedDriverId',
          'scheduledAt',
          'scheduledDayKey',
          'scheduledMinutesLocal',
          'status',
          'pickup',
          'destination',
          'transportType',
          'updatedAt'
        ])
        && (
          !changed.hasAny(['status']) ||
          request.resource.data.status in ['scheduled', 'cancelled']
        );
    }

    match /users/{uid} {
      allow read: if (isSignedIn() && request.auth.uid == uid)
        || isAdmin()
        || (managerCanVd() && resource.data.role == 'driver')
        || (managerCanVc() && resource.data.role == 'client');
      allow create: if (isSignedIn()
          && request.auth.uid == uid
          && isSelfRegistrationAllowed())
        || isAdmin();
      allow update: if isAdmin()
        || (isSignedIn()
          && request.auth.uid == uid
          && (isSelfUserUpdateAllowed()
            || isSelfProfileUpdateAllowed()))
        || (managerCanEd() && isManagerDriverUserUpdateAllowed());
      allow delete: if isAdmin();
    }

    match /driversPublic/{driverId} {
      allow read: if isSignedIn();
      allow create, update, delete: if isAdmin()
        || (isSignedIn() && request.auth.uid == driverId);
    }

    match /users/{uid}/fcmTokens/{tokenId} {
      allow read: if (isSignedIn() && request.auth.uid == uid)
        || isAdmin();
      allow create, update: if isSignedIn() && request.auth.uid == uid;
      allow delete: if (isSignedIn() && request.auth.uid == uid)
        || isAdmin();
    }

    match /driverStatus/{driverId} {
      allow read: if (isSignedIn() && request.auth.uid == driverId)
        || isAdmin()
        || managerCanVd()
        || canClientAccessDriverData(driverId, resource.data.currentTripId);
      allow create: if isAdmin()
        || (isSignedIn() && request.auth.uid == driverId)
        || (managerCanEd() && isManagerDriverStatusCreateAllowed());
      allow update: if isAdmin()
        || (isSignedIn() && request.auth.uid == driverId)
        || (managerCanEd() && isManagerDriverStatusUpdateAllowed());
      allow delete: if isAdmin();
    }

    match /driverOperationalStates/{driverId} {
      allow read: if isAdmin() || (managerCanVt() && managerCanVd());
      allow create, update, delete: if false;
    }

    match /userRuntime/{uid} {
      allow read: if (isSignedIn() && request.auth.uid == uid)
        || isAdmin()
        || managerCanVt()
        || managerCanCh();
      allow create, update, delete: if false;
    }

    match /notificationTargets/{uid} {
      allow read, write: if false;
    }

    match /notificationTargets/{uid}/tokens/{tokenId} {
      allow read, write: if false;
    }

    match /driverVehicleAssignments/{driverId} {
      allow read: if (isManager() && managerCanVd())
        || (!isManager() && isSignedIn());
      allow create: if isAdmin()
        || (managerCanAv() && isDriverAssignmentCreateAllowed())
        || (isSignedIn()
          && request.auth.uid == driverId
          && isDriverAssignmentCreateAllowed());
      allow update: if isAdmin()
        || (managerCanAv() && isDriverAssignmentUpdateAllowed())
        || (isSignedIn()
          && request.auth.uid == driverId
          && isDriverAssignmentUpdateAllowed());
      allow delete: if isAdmin()
        || (managerCanAv() && resource.data.vehicleId is string);
    }

    match /trips/{tripId} {
      allow read: if isAdmin()
        || managerCanVt()
        || managerCanVr()
        || isTripClient()
        || isTripDriver();
      allow create: if isAdmin()
        || (isSignedIn() && isClientTripCreateAllowed());
      allow update: if isAdmin()
        || (managerCanTs() && isManagerTripSupportUpdateAllowed())
        || isDriverTripMeteringUpdateAllowed()
        || (isTripClient() && isClientTripCancelUpdateAllowed())
        || (isTripClient() && isClientTripRatingUpdateAllowed());
      allow delete: if false;
    }

    match /trips/{tripId}/driverContactSnapshots/{snapshotId} {
      allow read: if isAdmin() || managerCanVt() || isTripParticipant(tripId);
      allow write: if isAdmin();
    }

    match /trips/{tripId}/pathPoints/{pointId} {
      allow read: if isAdmin() || managerCanVt() || isTripParticipant(tripId);
      allow write: if isAdmin()
        || (isSignedIn()
          && tripDriverId(get(/databases/$(database)/documents/trips/$(tripId)).data)
            == request.auth.uid);
    }

    match /trips/{tripId}/metering/{meteringId} {
      allow read: if meteringId == 'current'
        && (isAdmin() || managerCanVt() || isTripParticipant(tripId));
      allow create, update: if meteringId == 'current'
        && isSignedIn()
        && tripDriverId(get(/databases/$(database)/documents/trips/$(tripId)).data)
          == request.auth.uid;
      allow delete: if false;
    }

    match /tripOperationalMetrics/{tripId} {
      allow read: if isAdmin() || (managerCanVt() && managerCanVd());
      allow create, update, delete: if false;
    }

    match /tariffs/{tariffId} {
      allow read: if canReadPublicTariff(tariffId)
        || canReadAdminTariff(tariffId);
      allow write: if false;
    }

    match /vehicles/{vehicleId} {
      allow read: if (isManager() && managerCanVd())
        || (!isManager() && isSignedIn());
      allow create, delete: if isAdmin();
      allow update: if isAdmin()
        || (managerCanAv() && isManagerVehicleUpdateAllowed());
    }

    match /transport_types/{transportTypeId} {
      allow read: if isSignedIn();
      allow write: if false;
    }

    match /tripPackages/{packageId} {
      allow read: if isAdmin()
        || managerCanTp()
        || (isSignedIn()
          && resource.data.isActive == true
          && resource.data.archivedAt == null);
      allow create, update, delete: if false;
    }

    match /tripPackageBookings/{bookingId} {
      allow read: if isAdmin()
        || managerCanTp()
        || (isSignedIn() && resource.data.clientId == request.auth.uid);
      allow create, update, delete: if false;
    }

    match /tripPackageBookingOperations/{operationId} {
      allow read: if isAdmin()
        || managerCanTp();
      allow create, update, delete: if false;
    }

    match /pricingSchedules/{scheduleId} {
      allow read: if canReadPricingCollections();
      allow write: if isAdmin();
    }

    match /specialDays/{specialDayId} {
      allow read: if canReadPricingCollections();
      allow write: if isAdmin();
    }

    match /balances/{clientId} {
      allow read: if isAdmin()
        || (isSignedIn() && request.auth.uid == clientId);
      allow write: if isAdmin();
    }

    match /balance_adjustments/{adjustmentId} {
      allow read: if isAdmin()
        || (isSignedIn() && resource.data.clientId == request.auth.uid);
      allow create, update, delete: if isAdmin();
    }

    match /audit/{entryId} {
      allow read: if isAdmin() || managerCanVa();
      allow create, update, delete: if isAdmin();
    }

    match /operationalIncidents/{incidentId} {
      allow read: if isAdmin() || (managerCanVt() && managerCanVd());
      allow create, update, delete: if false;

      match /events/{eventId} {
        allow read: if isAdmin() || (managerCanVt() && managerCanVd());
        allow create, update, delete: if false;
      }
    }

    match /operationalMovementApprovals/{approvalId} {
      allow read: if isAdmin() || (managerCanVt() && managerCanVd());
      allow create, update, delete: if false;
    }

    match /reservations/{reservationId} {
      allow read: if isAdmin()
        || (canManageOperationalReservations()
          && isInternalStaffReservation(resource.data))
        || (isSignedIn()
          && resource.data.clientId == request.auth.uid)
        || (isSignedIn()
          && resource.data.assignedDriverId == request.auth.uid);
      allow create: if (canManageOperationalReservations()
          && isInternalStaffReservationCreateAllowed())
        || (isSignedIn() && isClientVehicleRentalReservationCreateAllowed());
      allow update: if canManageOperationalReservations()
        && isInternalStaffReservationUpdateAllowed();
      allow delete: if isAdmin();
    }

    match /reservationSeries/{seriesId} {
      allow read, create, update, delete: if false;
    }

    match /tripEvents/{tripId}/events/{eventId} {
      allow read: if isAdmin() || managerCanVt() || isTripParticipant(tripId);
      allow create: if isAdmin() || isTripParticipant(tripId);
      allow update, delete: if false;
    }

    match /events/{eventId} {
      allow read: if canReadScheduledEvent(resource.data);
      allow create: if (isAdmin() || managerCanMe())
        && hasValidReminderOffsetsForWrite(
          request.resource.data.reminderOffsetsMinutes
        );
      allow update: if (isAdmin() || managerCanMe())
        && (
          !request.resource.data.diff(resource.data)
            .affectedKeys()
            .hasAny(['reminderOffsetsMinutes'])
          || hasValidReminderOffsetsForWrite(
            request.resource.data.reminderOffsetsMinutes
          )
        );
      allow delete: if isAdmin() || managerCanMe();
    }

    match /config/{docId} {
      allow read: if canReadCancellationPolicy(docId)
        || canReadCurrencyConfig(docId)
        || canReadSupportConfig(docId)
        || canReadOperationalMonitoringConfig(docId);
      allow write: if canWriteCancellationPolicy(docId)
        || canWriteCurrencyConfig(docId)
        || canWriteSupportConfig(docId)
        || canWriteOperationalMonitoringConfig(docId);
    }

    match /supportRequests/{requestId} {
      allow read: if isAdmin()
        || managerCanVs()
        || (isClient() && resource.data.userId == request.auth.uid);
      allow write: if false;
    }

    match /chatThreads/{threadId} {
      allow read: if canReadClientSupportThreadBeforeCreation(threadId)
        || canReadChatThread(resource.data);
      allow write: if false;
    }

    match /chatThreads/{threadId}/chatMessages/{messageId} {
      allow read: if canReadChatThreadById(threadId);
      allow write: if false;
    }

    match /{document=**} {
      allow read, write: if false;
    }
  }
}
