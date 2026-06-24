import { setGlobalOptions } from "firebase-functions/v2";
import {
  ensureFirebaseAdminInitialized,
  getAuth,
  getFirestore,
  getMessaging,
  getRealtimeDb,
} from "./bootstrap/firebase";
import { buildAdminFunctions } from "./admin/buildAdminFunctions";
import { buildChatFunctions } from "./chat/buildChatFunctions";
import { buildDriversFunctions } from "./drivers/buildDriversFunctions";
import { buildNotificationsFunctions } from "./notifications/buildNotificationsFunctions";
// eslint-disable-next-line max-len
import { buildOperationalMonitoringFunctions } from "./operations/buildOperationalMonitoringFunctions";
import { buildReservationsJobs } from "./reservations/buildReservationsJobs";
import { buildSchedules } from "./schedules/buildSchedules";
import { buildTripPackageFunctions } from "./trip_packages/buildTripPackageFunctions";
import { buildTripsFunctions } from "./trips/buildTripsFunctions";

setGlobalOptions({ maxInstances: 10 });
ensureFirebaseAdminInitialized();

const firestore = getFirestore();
const realtimeDb = getRealtimeDb();
const messaging = getMessaging();
const auth = getAuth();

const tripsFunctions = buildTripsFunctions({
  firestore,
  realtimeDb,
  auth,
  messaging,
});

const adminFunctions = buildAdminFunctions({
  firestore,
  realtimeDb,
  auth,
  messaging,
});

const driversFunctions = buildDriversFunctions({
  tripsFunctions,
});

const chatFunctions = buildChatFunctions({
  firestore,
  messaging,
});

const notificationsFunctions = buildNotificationsFunctions({
  tripsFunctions,
});

const tripPackageFunctions = buildTripPackageFunctions({
  firestore,
  messaging,
  tripsFunctions,
});

const operationalMonitoringFunctions = buildOperationalMonitoringFunctions({
  firestore,
  realtimeDb,
  auth,
});

const reservationsJobs = buildReservationsJobs({
  tripsFunctions,
});

const schedules = buildSchedules({
  activateReservationsForDayJob: reservationsJobs.activateReservationsForDayJob,
  sendScheduledEventNotificationsJob:
    notificationsFunctions.sendScheduledEventNotificationsJob,
  monitorDriverHeartbeatJob: driversFunctions.monitorDriverHeartbeatJob,
  pruneStaleFcmTokensJob: notificationsFunctions.pruneStaleFcmTokensJob,
  activateDueTripPackageBookingsJob:
    tripPackageFunctions.activateDueTripPackageBookingsJob,
  sweepDriverAcceptanceTimeoutsJob:
    tripsFunctions.sweepDriverAcceptanceTimeoutsJob,
  sweepPostChargeTripExtensionsJob:
    tripsFunctions.sweepPostChargeTripExtensionsJob,
  evaluateOperationalMonitoringJob:
    operationalMonitoringFunctions.evaluateOperationalMonitoringJob,
  cleanupOperationalMonitoringRetentionJob:
    operationalMonitoringFunctions.cleanupOperationalMonitoringRetentionJob,
});

export const requestTrip = tripsFunctions.requestTrip;
export const processDriverAcceptanceTimeout =
  tripsFunctions.processDriverAcceptanceTimeout;
export const processPostChargeExtensionNextAction =
  tripsFunctions.processPostChargeExtensionNextAction;
export const saveTripPackageTemplate =
  tripPackageFunctions.saveTripPackageTemplate;
export const archiveTripPackageTemplate =
  tripPackageFunctions.archiveTripPackageTemplate;
export const deleteTripPackageTemplate =
  tripPackageFunctions.deleteTripPackageTemplate;
export const confirmTripPackageBooking =
  tripPackageFunctions.confirmTripPackageBooking;
export const approveTripPackageBooking =
  tripPackageFunctions.approveTripPackageBooking;
export const rejectTripPackageBooking =
  tripPackageFunctions.rejectTripPackageBooking;
export const cancelTripPackageBooking =
  tripPackageFunctions.cancelTripPackageBooking;
export const adminCancelTripPackageBooking =
  tripPackageFunctions.adminCancelTripPackageBooking;
export const syncTripPackageReservationLifecycle =
  tripPackageFunctions.syncTripPackageReservationLifecycle;
export const syncTripPackageTripLifecycle =
  tripPackageFunctions.syncTripPackageTripLifecycle;
export const adminDeleteUser = adminFunctions.adminDeleteUser;
export const adminUpdateUserPassword = adminFunctions.adminUpdateUserPassword;
export const setManagerPermissions = adminFunctions.setManagerPermissions;
export const createTransportType = adminFunctions.createTransportType;
export const updateTransportType = adminFunctions.updateTransportType;
export const saveAdminTariff = adminFunctions.saveAdminTariff;
export const resolveAuditAdminEmails = adminFunctions.resolveAuditAdminEmails;
export const resolveAuditSubjectIdentities =
  adminFunctions.resolveAuditSubjectIdentities;
export const requestPasswordHelp = adminFunctions.requestPasswordHelp;
export const requestSupportTicket = adminFunctions.requestSupportTicket;
export const resolvePasswordHelpRequest =
  adminFunctions.resolvePasswordHelpRequest;
export const sendSupportChatMessage = chatFunctions.sendSupportChatMessage;
export const sendSupportTicketMessage =
  chatFunctions.sendSupportTicketMessage;
export const sendTripChatMessage = chatFunctions.sendTripChatMessage;
export const syncPublicTariffFromAdmin =
  adminFunctions.syncPublicTariffFromAdmin;
export const assignDriverOnTripCreation =
  tripsFunctions.assignDriverOnTripCreation;
export const syncDriverVehicleAssignment =
  driversFunctions.syncDriverVehicleAssignment;
export const handleTripStatusUpdates = tripsFunctions.handleTripStatusUpdates;
export const finalizeTripOnCompletion = tripsFunctions.finalizeTripOnCompletion;
export const retryTripPayment = tripsFunctions.retryTripPayment;
export const transitionTripState = tripsFunctions.transitionTripState;
export const cancelTrip = tripsFunctions.cancelTrip;
export const requestTripExtension = tripsFunctions.requestTripExtension;
export const respondTripExtension = tripsFunctions.respondTripExtension;
export const closeTripExtensionFlow = tripsFunctions.closeTripExtensionFlow;
export const endTripExtensionEarly = tripsFunctions.endTripExtensionEarly;
export const handleTripFinancialAction =
  tripsFunctions.handleTripFinancialAction;
export const autoCompleteTripExtensionWindow =
  tripsFunctions.autoCompleteTripExtensionWindow;
export const activateReservationsForDay = schedules.activateReservationsForDay;
export const notifyDriverOnAdminEventCreation =
  notificationsFunctions.notifyDriverOnAdminEventCreation;
export const sendScheduledEventNotifications =
  schedules.sendScheduledEventNotifications;
export const activateDueTripPackageBookings =
  schedules.activateDueTripPackageBookings;
export const monitorDriverHeartbeat = schedules.monitorDriverHeartbeat;
export const pruneStaleFcmTokens = schedules.pruneStaleFcmTokens;
export const syncDriversPublicProfile =
  driversFunctions.syncDriversPublicProfile;
export const syncDriversPublicVehicle =
  driversFunctions.syncDriversPublicVehicle;
export const syncNotificationTargetToken =
  tripsFunctions.syncNotificationTargetToken;
export const syncOperationalTripContext =
  operationalMonitoringFunctions.syncOperationalTripContext;
export const syncOperationalLocationState =
  operationalMonitoringFunctions.syncOperationalLocationState;
export const reviewOperationalIncident =
  operationalMonitoringFunctions.reviewOperationalIncident;
export const approveOperationalReposition =
  operationalMonitoringFunctions.approveOperationalReposition;
export const sweepDriverAcceptanceTimeouts =
  schedules.sweepDriverAcceptanceTimeouts;
export const sweepPostChargeTripExtensions =
  schedules.sweepPostChargeTripExtensions;
export const evaluateOperationalMonitoring =
  schedules.evaluateOperationalMonitoring;
export const cleanupOperationalMonitoringRetention =
  schedules.cleanupOperationalMonitoringRetention;
export const closeTripChatOnTripUpdate =
  chatFunctions.closeTripChatOnTripUpdate;
