import * as logger from "firebase-functions/logger";
import { Timestamp } from "firebase-admin/firestore";
import {
  DEFAULT_EVENT_REMINDER_OFFSET_MINUTES,
  MAX_REMINDER_OFFSET_LEGACY_READ_MINUTES,
  MAX_REMINDER_OFFSET_WRITE_MINUTES,
  MAX_REMINDER_OFFSETS_PER_ENTITY,
  MIN_REMINDER_OFFSET_MINUTES,
} from "../shared/constants";

export const EVENT_REMINDER_WINDOW_MINUTES =
  MAX_REMINDER_OFFSET_LEGACY_READ_MINUTES;
export const EVENT_REMINDER_MAX_WRITE_MINUTES = MAX_REMINDER_OFFSET_WRITE_MINUTES;

export type ScheduledEventSnapshot = {
  targetType?: string;
  targetIds?: string[];
  title?: string;
  message?: string;
  scheduledAt?: Timestamp;
  status?: string;
  reminderOffsetsMinutes?: unknown[];
  reminderSentAtByOffsetMinutes?: Record<
    string,
    Timestamp | undefined
  >;
  createdByAdminId?: string;
};

export type EventReminderEvaluation = {
  scheduledAt: Date | null;
  diffMinutes: number | null;
  dueOffsetMinutes: number | null;
  normalizedOffsetsMinutes: number[];
  title: string;
  body: string;
};

export function evaluateEventReminder(params: {
  event: ScheduledEventSnapshot;
  now: Date;
  context: { eventId: string };
}): EventReminderEvaluation {
  const { event, now, context } = params;
  const scheduledAt = event.scheduledAt?.toDate?.() ?? null;
  const normalizedOffsetsMinutes = normalizeReminderOffsets(
    event.reminderOffsetsMinutes,
  );
  const title = event.title ?? "Evento agendado";
  const body = event.message ?? "Tens um evento agendado em breve.";

  if (!scheduledAt) {
    logger.debug("Scheduled event evaluation skipped (missing date).", {
      ...context,
    });
    return {
      scheduledAt: null,
      diffMinutes: null,
      dueOffsetMinutes: null,
      normalizedOffsetsMinutes,
      title,
      body,
    };
  }

  const diffMinutes = (scheduledAt.getTime() - now.getTime()) / (1000 * 60);
  if (diffMinutes <= 0) {
    logger.debug("Scheduled event evaluation skipped (already due).", {
      ...context,
      diffMinutes,
    });
    return {
      scheduledAt,
      diffMinutes,
      dueOffsetMinutes: null,
      normalizedOffsetsMinutes,
      title,
      body,
    };
  }

  let dueOffsetMinutes: number | null = null;
  for (let index = 0; index < normalizedOffsetsMinutes.length; index++) {
    const offset = normalizedOffsetsMinutes[index];
    const nextOffset =
      index + 1 < normalizedOffsetsMinutes.length
        ? normalizedOffsetsMinutes[index + 1]
        : 0;
    if (diffMinutes <= offset && diffMinutes > nextOffset) {
      dueOffsetMinutes = offset;
      break;
    }
  }

  if (dueOffsetMinutes !== null) {
    const sentByOffset = event.reminderSentAtByOffsetMinutes ?? {};
    if (sentByOffset[dueOffsetMinutes.toString()]) {
      dueOffsetMinutes = null;
    }
  }

  logger.debug("Scheduled event reminder evaluation complete.", {
    ...context,
    diffMinutes,
    dueOffsetMinutes,
    normalizedOffsetsMinutes,
  });

  return {
    scheduledAt,
    diffMinutes,
    dueOffsetMinutes,
    normalizedOffsetsMinutes,
    title,
    body,
  };
}

function normalizeReminderOffsets(rawOffsets: unknown[] | undefined): number[] {
  if (!Array.isArray(rawOffsets)) {
    return [DEFAULT_EVENT_REMINDER_OFFSET_MINUTES];
  }

  const normalizedOffsets = [...new Set(
    rawOffsets
      .map((value) => {
        if (typeof value === "number") {
          return Math.trunc(value);
        }
        if (typeof value === "string") {
          const parsed = Number.parseInt(value, 10);
          return Number.isNaN(parsed) ? null : parsed;
        }
        return null;
      })
      .filter(
        (value): value is number =>
          value !== null &&
          value >= MIN_REMINDER_OFFSET_MINUTES &&
          value <= EVENT_REMINDER_WINDOW_MINUTES,
      ),
  )].sort((a, b) => b - a);

  const limitedOffsets = normalizedOffsets.slice(
    0,
    MAX_REMINDER_OFFSETS_PER_ENTITY,
  );

  if (limitedOffsets.length === 0) {
    return [DEFAULT_EVENT_REMINDER_OFFSET_MINUTES];
  }

  return limitedOffsets;
}
