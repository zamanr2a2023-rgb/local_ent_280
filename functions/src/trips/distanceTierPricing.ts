export type DistanceTierMinor = {
  startMetersInclusive: number;
  endMetersExclusive?: number;
  perKmMinor: number;
};

export function toMetersFromKm(distanceKm: number): number {
  if (!Number.isFinite(distanceKm) || distanceKm <= 0) {
    return 0;
  }
  return Math.round(distanceKm * 1000);
}

export function roundHalfUp(params: {
  numerator: number;
  denominator: number;
}): number {
  const { numerator, denominator } = params;
  if (!Number.isFinite(numerator) || !Number.isFinite(denominator)) {
    return 0;
  }
  if (denominator <= 0) {
    return 0;
  }
  return Math.floor((numerator + Math.floor(denominator / 2)) / denominator);
}

export function calculateDistanceTierChargeMinor(params: {
  totalMeters: number;
  tiers: DistanceTierMinor[];
  fallbackPerKmMinor?: number;
}): number {
  const { fallbackPerKmMinor } = params;
  const totalMeters = params.totalMeters > 0 ? params.totalMeters : 0;
  if (totalMeters <= 0) {
    return 0;
  }
  const tiers = resolveUsableTiers({
    tiers: params.tiers,
    fallbackPerKmMinor,
  });
  if (tiers.length === 0) {
    return 0;
  }
  let chargeMinor = 0;
  for (const tier of tiers) {
    const tierStart = tier.startMetersInclusive;
    const tierEnd = tier.endMetersExclusive ?? totalMeters;
    const coveredMeters = resolveCoveredMeters({
      totalMeters,
      tierStart,
      tierEnd,
    });
    if (coveredMeters <= 0) {
      continue;
    }
    chargeMinor += roundHalfUp({
      numerator: coveredMeters * tier.perKmMinor,
      denominator: 1000,
    });
  }
  return chargeMinor;
}

function resolveUsableTiers(params: {
  tiers: DistanceTierMinor[];
  fallbackPerKmMinor?: number;
}): DistanceTierMinor[] {
  const { tiers, fallbackPerKmMinor } = params;
  if (tiers.length > 0) {
    return tiers;
  }
  if (fallbackPerKmMinor == null) {
    return [];
  }
  return [
    {
      startMetersInclusive: 0,
      endMetersExclusive: undefined,
      perKmMinor: fallbackPerKmMinor,
    },
  ];
}

function resolveCoveredMeters(params: {
  totalMeters: number;
  tierStart: number;
  tierEnd: number;
}): number {
  const { totalMeters, tierStart, tierEnd } = params;
  if (totalMeters <= tierStart || tierEnd <= tierStart) {
    return 0;
  }
  const effectiveEnd = Math.min(totalMeters, tierEnd);
  return effectiveEnd - tierStart;
}
