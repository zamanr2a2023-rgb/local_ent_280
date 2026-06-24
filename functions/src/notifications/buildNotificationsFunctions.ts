import { TripsFunctions } from "../trips/buildTripsFunctions";

export type NotificationsFunctions = Pick<
  TripsFunctions,
  "notifyDriverOnAdminEventCreation" |
  "sendScheduledEventNotificationsJob" |
  "pruneStaleFcmTokensJob"
>;

export function buildNotificationsFunctions(params: {
  tripsFunctions: TripsFunctions;
}): NotificationsFunctions {
  const {tripsFunctions} = params;
  return {
    notifyDriverOnAdminEventCreation: tripsFunctions.notifyDriverOnAdminEventCreation,
    sendScheduledEventNotificationsJob: tripsFunctions.sendScheduledEventNotificationsJob,
    pruneStaleFcmTokensJob: tripsFunctions.pruneStaleFcmTokensJob,
  };
}
