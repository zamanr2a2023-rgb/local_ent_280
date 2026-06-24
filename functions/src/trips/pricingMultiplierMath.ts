type DecimalRatio = {
  numerator: number;
  denominator: number;
};

export function multiplyMinorAndCeil(params: {
  amountMinor: number;
  multiplier: number;
}): number {
  const ratio = parseDecimalRatio(params.multiplier);
  return divideCeil(params.amountMinor * ratio.numerator, ratio.denominator);
}

export function multiplyMinorAndRoundHalfUp(params: {
  amountMinor: number;
  multiplier: number;
}): number {
  const ratio = parseDecimalRatio(params.multiplier);
  return divideRoundHalfUp(
    params.amountMinor * ratio.numerator,
    ratio.denominator,
  );
}

function parseDecimalRatio(value: number): DecimalRatio {
  if (!Number.isFinite(value) || value <= 0) {
    throw new Error(`Invalid multiplier: ${value}`);
  }
  const normalized = value.toString().trim();
  if (!/^\d+(\.\d+)?$/.test(normalized)) {
    throw new Error(`Invalid decimal multiplier: ${normalized}`);
  }
  const [integerPart, fractionalPart = ""] = normalized.split(".");
  const digits = `${integerPart}${fractionalPart}`;
  const numerator = Number.parseInt(digits, 10);
  const denominator = Math.pow(10, fractionalPart.length);
  if (!Number.isSafeInteger(numerator) || !Number.isSafeInteger(denominator)) {
    throw new Error(`Unsafe multiplier precision: ${normalized}`);
  }
  const gcd = calculateGcd(numerator, denominator);
  return {
    numerator: numerator / gcd,
    denominator: denominator / gcd,
  };
}

function divideCeil(numerator: number, denominator: number): number {
  return Math.floor((numerator + denominator - 1) / denominator);
}

function divideRoundHalfUp(numerator: number, denominator: number): number {
  return Math.floor((numerator + denominator / 2) / denominator);
}

function calculateGcd(left: number, right: number): number {
  let a = Math.abs(left);
  let b = Math.abs(right);
  while (b !== 0) {
    const next = a % b;
    a = b;
    b = next;
  }
  return a === 0 ? 1 : a;
}
