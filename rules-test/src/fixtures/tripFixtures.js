import { Timestamp } from 'firebase/firestore';

const toMoney = (amountMinor) => ({
  amountMinor,
  currency: 'EUR'
});

export function buildTripFixture({
  clientId,
  assignedDriverId,
  status
}) {
  const createdAt = Timestamp.fromDate(new Date('2024-01-01T00:00:00Z'));
  return {
    clientId,
    assignedDriverId,
    vehicleId: 'vehicle-1',
    status,
    isActive: true,
    pickup: {
      latitude: 38.7223,
      longitude: -9.1393,
      address: 'Praça do Comércio'
    },
    destination: {
      latitude: 38.7071,
      longitude: -9.1355,
      address: 'Cais do Sodré'
    },
    transportType: {
      id: 'transport-1',
      name: 'Táxi'
    },
    pricingSnapshot: {
      base: toMoney(350),
      perKm: toMoney(120),
      perWaitMinute: toMoney(15),
      distanceTiers: [
        {
          startMetersInclusive: 0,
          perKm: toMoney(120)
        }
      ],
      lateCancellationFee: toMoney(0),
      noShowFee: toMoney(0)
    },
    createdAt,
    requestedAt: createdAt,
    updatedAt: createdAt
  };
}
