import * as fs from "node:fs";
import * as path from "node:path";

import { calculateDistanceTierChargeMinor, type DistanceTierMinor } from "./distanceTierPricing";
import {
  multiplyMinorAndCeil,
  multiplyMinorAndRoundHalfUp,
} from "./pricingMultiplierMath";

type DistanceTierCase = {
  name: string;
  totalMeters: number;
  durationMinutes: number;
  baseMinor: number;
  perWaitMinuteMinor: number;
  fallbackPerKmMinor: number;
  tiers: Array<{
    startMetersInclusive: number;
    endMetersExclusive?: number;
    perKmMinor: number;
  }>;
  multiplier: number;
  expectedDistanceChargeMinor: number;
  expectedEstimateMinor: number;
};

type DistanceTierDataset = {
  cases: DistanceTierCase[];
};

type PricingInput = {
  baseMinor: number;
  perKmMinor: number;
  distanceTiers: DistanceTierMinor[];
  multiplier: number;
};

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function loadCases(): DistanceTierCase[] {
  const datasetPath = path.resolve(
    __dirname,
    "../../../contracts/pricing/distance_tiers_cases.json",
  );
  const raw = fs.readFileSync(datasetPath, "utf8");
  const dataset = JSON.parse(raw) as DistanceTierDataset;
  return dataset.cases;
}

function estimateTripTotalMinor(params: {
  pricing: PricingInput;
  totalMeters: number;
  durationMinutes: number;
}): number {
  const { pricing, totalMeters } = params;
  const distanceMinor = calculateDistanceTierChargeMinor({
    totalMeters,
    tiers: pricing.distanceTiers,
    fallbackPerKmMinor: pricing.perKmMinor,
  });
  const subtotalMinor = pricing.baseMinor + distanceMinor;
  return multiplyMinorAndCeil({
    amountMinor: subtotalMinor,
    multiplier: pricing.multiplier,
  });
}

function buildChargeBreakdown(params: {
  pricing: PricingInput;
  totalMeters: number;
  durationMinutes: number;
}): { distanceMinor: number; totalMinor: number } {
  const { pricing, totalMeters } = params;
  const distanceMinor = calculateDistanceTierChargeMinor({
    totalMeters,
    tiers: pricing.distanceTiers,
    fallbackPerKmMinor: pricing.perKmMinor,
  });
  const baseSubtotalMinor = pricing.baseMinor + distanceMinor;
  return {
    distanceMinor,
    totalMinor: multiplyMinorAndRoundHalfUp({
      amountMinor: baseSubtotalMinor,
      multiplier: pricing.multiplier,
    }),
  };
}

function runScenario(testCase: DistanceTierCase): void {
  const tiers: DistanceTierMinor[] = testCase.tiers.map((tier) => {
    return {
      startMetersInclusive: tier.startMetersInclusive,
      endMetersExclusive: tier.endMetersExclusive,
      perKmMinor: tier.perKmMinor,
    };
  });

  const distanceChargeMinor = calculateDistanceTierChargeMinor({
    totalMeters: testCase.totalMeters,
    tiers,
    fallbackPerKmMinor: testCase.fallbackPerKmMinor,
  });
  assert(
    distanceChargeMinor === testCase.expectedDistanceChargeMinor,
    `Unexpected distance charge for ${testCase.name}. ` +
      `Expected ${testCase.expectedDistanceChargeMinor}, got ${distanceChargeMinor}.`,
  );

  const pricing: PricingInput = {
    baseMinor: testCase.baseMinor,
    perKmMinor: testCase.fallbackPerKmMinor,
    distanceTiers: tiers,
    multiplier: testCase.multiplier,
  };

  const estimatedTotalMinor = estimateTripTotalMinor({
    pricing,
    totalMeters: testCase.totalMeters,
    durationMinutes: testCase.durationMinutes,
  });
  assert(
    estimatedTotalMinor === testCase.expectedEstimateMinor,
    `Unexpected estimate for ${testCase.name}. ` +
      `Expected ${testCase.expectedEstimateMinor}, got ${estimatedTotalMinor}.`,
  );

  const breakdown = buildChargeBreakdown({
    pricing,
    totalMeters: testCase.totalMeters,
    durationMinutes: testCase.durationMinutes,
  });

  assert(
    breakdown.distanceMinor === testCase.expectedDistanceChargeMinor,
    `Unexpected breakdown distance for ${testCase.name}. ` +
      `Expected ${testCase.expectedDistanceChargeMinor}, got ${breakdown.distanceMinor}.`,
  );

  const expectedBreakdownTotalMinor = multiplyMinorAndRoundHalfUp({
    amountMinor: testCase.baseMinor + testCase.expectedDistanceChargeMinor,
    multiplier: testCase.multiplier,
  });
  assert(
    breakdown.totalMinor === expectedBreakdownTotalMinor,
    `Unexpected breakdown total for ${testCase.name}. ` +
      `Expected ${expectedBreakdownTotalMinor}, got ${breakdown.totalMinor}.`,
  );
}

function main(): void {
  const cases = loadCases();
  for (const testCase of cases) {
    runScenario(testCase);
  }
  assert(
    multiplyMinorAndCeil({amountMinor: 100, multiplier: 1.98}) === 198,
    "Combined multiplier ceil math should preserve exact decimal products.",
  );
  assert(
    multiplyMinorAndRoundHalfUp({amountMinor: 101, multiplier: 1.65}) === 167,
    "Combined multiplier round-half-up math should be deterministic.",
  );
  // eslint-disable-next-line no-console
  console.log("distanceTierPricing parity tests passed.");
}

main();
