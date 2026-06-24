import { TripsFunctions } from "../trips/buildTripsFunctions";

export type DriversFunctions = Pick<
  TripsFunctions,
  "syncDriverVehicleAssignment" |
  "syncDriversPublicProfile" |
  "syncDriversPublicVehicle" |
  "monitorDriverHeartbeatJob"
>;

export function buildDriversFunctions(params: {
  tripsFunctions: TripsFunctions;
}): DriversFunctions {
  const {tripsFunctions} = params;
  return {
    syncDriverVehicleAssignment: tripsFunctions.syncDriverVehicleAssignment,
    syncDriversPublicProfile: tripsFunctions.syncDriversPublicProfile,
    syncDriversPublicVehicle: tripsFunctions.syncDriversPublicVehicle,
    monitorDriverHeartbeatJob: tripsFunctions.monitorDriverHeartbeatJob,
  };
}
