export type LocalDateParts = {
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
  second: number;
};

export function getLocalDateParts(
  date: Date,
  timeZone: string,
): LocalDateParts {
  const formatter = new Intl.DateTimeFormat("en-CA", {
    timeZone,
    hour12: false,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  });
  const parts = formatter.formatToParts(date);
  const values = parts.reduce<Record<string, number>>((acc, part) => {
    if (part.type === "literal") {
      return acc;
    }
    acc[part.type] = Number.parseInt(part.value, 10);
    return acc;
  }, {});

  return {
    year: values.year ?? date.getUTCFullYear(),
    month: values.month ?? date.getUTCMonth() + 1,
    day: values.day ?? date.getUTCDate(),
    hour: values.hour ?? date.getUTCHours(),
    minute: values.minute ?? date.getUTCMinutes(),
    second: values.second ?? date.getUTCSeconds(),
  };
}

export function buildLocalDayKey(date: Date, timeZone: string): string {
  const parts = getLocalDateParts(date, timeZone);
  return buildLocalDayKeyFromParts({
    year: parts.year,
    month: parts.month,
    day: parts.day,
  });
}

export function buildLocalDayKeyFromParts(params: {
  year: number;
  month: number;
  day: number;
}): string {
  const { year, month, day } = params;
  return `${year.toString().padStart(4, "0")}-${month
    .toString()
    .padStart(2, "0")}-${day.toString().padStart(2, "0")}`;
}

export function getTimeZoneOffsetMinutes(date: Date, timeZone: string): number {
  const formatter = new Intl.DateTimeFormat("en-US", {
    timeZone,
    hour12: false,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  });
  const parts = formatter.formatToParts(date);
  const values = parts.reduce<Record<string, string>>((acc, part) => {
    if (part.type !== "literal") {
      acc[part.type] = part.value;
    }
    return acc;
  }, {});
  const utcTime = Date.UTC(
    Number.parseInt(values.year ?? "0", 10),
    Number.parseInt(values.month ?? "1", 10) - 1,
    Number.parseInt(values.day ?? "1", 10),
    Number.parseInt(values.hour ?? "0", 10),
    Number.parseInt(values.minute ?? "0", 10),
    Number.parseInt(values.second ?? "0", 10),
  );
  return (utcTime - date.getTime()) / 60000;
}

export function resolveLocalDateTime(params: {
  localDayKey: string;
  minutesLocal: number;
  timeZone: string;
}): Date {
  const { localDayKey, minutesLocal, timeZone } = params;
  const dayParts = parseLocalDayKey(localDayKey);
  const hours = Math.floor(minutesLocal / 60);
  const minutes = minutesLocal % 60;
  const targetUtc = Date.UTC(
    dayParts.year,
    dayParts.month - 1,
    dayParts.day,
    hours,
    minutes,
    0,
    0,
  );

  let candidate = new Date(targetUtc);
  for (let index = 0; index < 6; index += 1) {
    const offsetMinutes = getTimeZoneOffsetMinutes(candidate, timeZone);
    const adjusted = new Date(targetUtc - offsetMinutes * 60 * 1000);
    if (adjusted.getTime() === candidate.getTime()) {
      break;
    }
    candidate = adjusted;
  }

  if (matchesLocalDateTime(candidate, dayParts, hours, minutes, timeZone)) {
    let earliest = candidate;
    for (let offset = 1; offset <= 360; offset += 1) {
      const previous = new Date(candidate.getTime() - offset * 60 * 1000);
      if (matchesLocalDateTime(previous, dayParts, hours, minutes, timeZone)) {
        earliest = previous;
      }
    }
    return earliest;
  }

  let probe = new Date(candidate.getTime() - 180 * 60 * 1000);
  for (let index = 0; index < 540; index += 1) {
    const parts = getLocalDateParts(probe, timeZone);
    const isSameDay =
      parts.year === dayParts.year &&
      parts.month === dayParts.month &&
      parts.day === dayParts.day;
    const localMinutes = parts.hour * 60 + parts.minute;
    if (isSameDay && localMinutes >= minutesLocal) {
      return new Date(
        probe.getTime() - (probe.getSeconds() * 1000) - probe.getMilliseconds(),
      );
    }
    probe = new Date(probe.getTime() + 60 * 1000);
  }

  return candidate;
}

export function addDaysToLocalDayKey(
  localDayKey: string,
  dayCount: number,
): string {
  const { year, month, day } = parseLocalDayKey(localDayKey);
  const base = new Date(Date.UTC(year, month - 1, day + dayCount));
  return buildLocalDayKeyFromParts({
    year: base.getUTCFullYear(),
    month: base.getUTCMonth() + 1,
    day: base.getUTCDate(),
  });
}

export function parseLocalDayKey(localDayKey: string): {
  year: number;
  month: number;
  day: number;
} {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(localDayKey.trim());
  if (!match) {
    throw new Error(`Local day key inválido: ${localDayKey}`);
  }
  return {
    year: Number.parseInt(match[1], 10),
    month: Number.parseInt(match[2], 10),
    day: Number.parseInt(match[3], 10),
  };
}

function matchesLocalDateTime(
  value: Date,
  dayParts: { year: number; month: number; day: number },
  hours: number,
  minutes: number,
  timeZone: string,
): boolean {
  const parts = getLocalDateParts(value, timeZone);
  return (
    parts.year === dayParts.year &&
    parts.month === dayParts.month &&
    parts.day === dayParts.day &&
    parts.hour === hours &&
    parts.minute === minutes
  );
}
