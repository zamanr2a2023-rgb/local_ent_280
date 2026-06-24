import { TripsFunctions } from "../trips/buildTripsFunctions";

export type ReservationsJobs = Pick<TripsFunctions, "activateReservationsForDayJob">;

export function buildReservationsJobs(params: {
  tripsFunctions: TripsFunctions;
}): ReservationsJobs {
  const {tripsFunctions} = params;
  return {
    activateReservationsForDayJob: tripsFunctions.activateReservationsForDayJob,
  };
}
