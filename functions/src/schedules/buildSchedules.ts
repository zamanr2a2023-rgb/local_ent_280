import { onSchedule } from "firebase-functions/v2/scheduler";
import { RESERVATION_ACTIVATION_TIMEZONE } from "../shared/constants";

const SCHEDULER_REGION = "europe-west1";
const RECOVERY_SWEEP_SCHEDULE = "*/15 * * * *";

export type Schedules = {
  activateReservationsForDay: ReturnType<typeof onSchedule>;
  sendScheduledEventNotifications: ReturnType<typeof onSchedule>;
  activateDueTripPackageBookings: ReturnType<typeof onSchedule>;
  monitorDriverHeartbeat: ReturnType<typeof onSchedule>;
  pruneStaleFcmTokens: ReturnType<typeof onSchedule>;
  sweepDriverAcceptanceTimeouts: ReturnType<typeof onSchedule>;
  sweepPostChargeTripExtensions: ReturnType<typeof onSchedule>;
  evaluateOperationalMonitoring: ReturnType<typeof onSchedule>;
  cleanupOperationalMonitoringRetention: ReturnType<typeof onSchedule>;
};

export function buildSchedules(params: {
  activateReservationsForDayJob: () => Promise<void>;
  sendScheduledEventNotificationsJob: () => Promise<void>;
  activateDueTripPackageBookingsJob: () => Promise<void>;
  monitorDriverHeartbeatJob: () => Promise<void>;
  pruneStaleFcmTokensJob: () => Promise<void>;
  sweepDriverAcceptanceTimeoutsJob: () => Promise<void>;
  sweepPostChargeTripExtensionsJob: () => Promise<void>;
  evaluateOperationalMonitoringJob: () => Promise<void>;
  cleanupOperationalMonitoringRetentionJob: () => Promise<void>;
}): Schedules {
  const {
    activateReservationsForDayJob,
    sendScheduledEventNotificationsJob,
    activateDueTripPackageBookingsJob,
    monitorDriverHeartbeatJob,
    pruneStaleFcmTokensJob,
    sweepDriverAcceptanceTimeoutsJob,
    sweepPostChargeTripExtensionsJob,
    evaluateOperationalMonitoringJob,
    cleanupOperationalMonitoringRetentionJob,
  } = params;

  const activateReservationsForDay = onSchedule(
    {
      schedule: "0 5 * * *",
      timeZone: RESERVATION_ACTIVATION_TIMEZONE,
      region: SCHEDULER_REGION,
      maxInstances: 1,
    },
    activateReservationsForDayJob,
  );

  const sendScheduledEventNotifications = onSchedule(
    {
      schedule: RECOVERY_SWEEP_SCHEDULE,
      timeZone: RESERVATION_ACTIVATION_TIMEZONE,
      region: SCHEDULER_REGION,
    },
    sendScheduledEventNotificationsJob,
  );

  const activateDueTripPackageBookings = onSchedule(
    {
      schedule: RECOVERY_SWEEP_SCHEDULE,
      timeZone: RESERVATION_ACTIVATION_TIMEZONE,
      region: SCHEDULER_REGION,
      maxInstances: 1,
    },
    activateDueTripPackageBookingsJob,
  );

  const monitorDriverHeartbeat = onSchedule(
    {
      schedule: "* * * * *",
      timeZone: RESERVATION_ACTIVATION_TIMEZONE,
      region: SCHEDULER_REGION,
    },
    monitorDriverHeartbeatJob,
  );

  const pruneStaleFcmTokens = onSchedule(
    {
      schedule: "0 */6 * * *",
      timeZone: RESERVATION_ACTIVATION_TIMEZONE,
      region: SCHEDULER_REGION,
    },
    pruneStaleFcmTokensJob,
  );

  const sweepDriverAcceptanceTimeouts = onSchedule(
    {
      schedule: RECOVERY_SWEEP_SCHEDULE,
      timeZone: RESERVATION_ACTIVATION_TIMEZONE,
      region: SCHEDULER_REGION,
    },
    sweepDriverAcceptanceTimeoutsJob,
  );

  const sweepPostChargeTripExtensions = onSchedule(
    {
      schedule: RECOVERY_SWEEP_SCHEDULE,
      timeZone: RESERVATION_ACTIVATION_TIMEZONE,
      region: SCHEDULER_REGION,
      maxInstances: 2,
    },
    sweepPostChargeTripExtensionsJob,
  );

  const evaluateOperationalMonitoring = onSchedule(
    {
      schedule: RECOVERY_SWEEP_SCHEDULE,
      timeZone: RESERVATION_ACTIVATION_TIMEZONE,
      region: SCHEDULER_REGION,
      maxInstances: 1,
    },
    evaluateOperationalMonitoringJob,
  );

  const cleanupOperationalMonitoringRetention = onSchedule(
    {
      schedule: "0 3 * * *",
      timeZone: RESERVATION_ACTIVATION_TIMEZONE,
      region: SCHEDULER_REGION,
      maxInstances: 1,
    },
    cleanupOperationalMonitoringRetentionJob,
  );

  return {
    activateReservationsForDay,
    sendScheduledEventNotifications,
    activateDueTripPackageBookings,
    monitorDriverHeartbeat,
    pruneStaleFcmTokens,
    sweepDriverAcceptanceTimeouts,
    sweepPostChargeTripExtensions,
    evaluateOperationalMonitoring,
    cleanupOperationalMonitoringRetention,
  };
}
