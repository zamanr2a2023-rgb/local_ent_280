const toMoney = (amountMinor) => ({
  amountMinor,
  currency: 'EUR'
});

export const cancellationPolicyPublicFixture = {
  gracePeriodMinutes: 2,
  cancellationFee: 1.5,
  currency: 'EUR'
};

export const cancellationPolicyAdminFixture = {
  gracePeriodMinutes: 2,
  lateWindowMinutes: 10,
  noShowWindowMinutes: 5,
  cancellationFee: 1.5,
  currency: 'EUR'
};

export const publicTariffFixture = {
  id: 'public_default',
  baseByTransportType: {
    standard: toMoney(350),
  },
  perKm: toMoney(120),
  perWaitMinute: toMoney(15),
  distanceTiers: [
    {
      startMetersInclusive: 0,
      perKm: toMoney(120)
    }
  ]
};

export const adminTariffFixture = {
  id: 'admin_default',
  baseByTransportType: {
    standard: toMoney(350),
  },
  perKm: toMoney(120),
  perWaitMinute: toMoney(15),
  distanceTiers: [
    {
      startMetersInclusive: 0,
      perKm: toMoney(120)
    }
  ],
  debtLimitCents: -2000
};
