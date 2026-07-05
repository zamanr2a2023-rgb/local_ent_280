import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import {
  requireAuthenticatedUid,
  resolveCallerRole,
} from "../shared/auth/rbacRoleResolver";
import {
  CALLABLE_RUNTIME_OPTIONS,
  DEFAULT_DEBT_LIMIT_CENTS,
  OPERATION_CURRENCY_CODE,
} from "../shared/constants";

type MoneyPayload = {
  amountMinor: number;
  currency: string;
};

type BalanceDocument = {
  balance: MoneyPayload;
  debtLimit: MoneyPayload;
};

function buildMoneyPayload(amountMinor: number): MoneyPayload {
  return {
    amountMinor,
    currency: OPERATION_CURRENCY_CODE,
  };
}

function resolveMoneyPayload(value: unknown, fieldName: string): MoneyPayload {
  if (!value || typeof value !== "object") {
    throw new HttpsError(
      "failed-precondition",
      `${fieldName} em falta.`,
    );
  }
  const record = value as Record<string, unknown>;
  const amountMinor = record.amountMinor;
  const currency = record.currency;
  if (typeof amountMinor !== "number" || !Number.isFinite(amountMinor)) {
    throw new HttpsError(
      "failed-precondition",
      `${fieldName} inválido.`,
    );
  }
  if (typeof currency !== "string" || currency.trim().length === 0) {
    throw new HttpsError(
      "failed-precondition",
      `${fieldName}.currency em falta.`,
    );
  }
  return {
    amountMinor: Math.round(amountMinor),
    currency: currency.trim(),
  };
}

function parseBalanceDocument(
  data: FirebaseFirestore.DocumentData | undefined,
): BalanceDocument {
  if (!data) {
    return {
      balance: buildMoneyPayload(0),
      debtLimit: buildMoneyPayload(DEFAULT_DEBT_LIMIT_CENTS),
    };
  }
  const balance = resolveMoneyPayload(data.balance, "balance");
  const debtLimit = resolveMoneyPayload(data.debtLimit, "debtLimit");
  if (balance.currency !== debtLimit.currency) {
    throw new HttpsError(
      "failed-precondition",
      "Saldo e limite têm moedas diferentes.",
    );
  }
  return { balance, debtLimit };
}

function parseScheduledAt(value: unknown): admin.firestore.Timestamp {
  if (value instanceof admin.firestore.Timestamp) {
    return value;
  }
  if (typeof value === "string" && value.trim().length > 0) {
    const parsed = new Date(value);
    if (Number.isNaN(parsed.getTime())) {
      throw new HttpsError("invalid-argument", "Data de recolha inválida.");
    }
    return admin.firestore.Timestamp.fromDate(parsed);
  }
  throw new HttpsError("invalid-argument", "Data de recolha inválida.");
}

export function buildVehicleRentalFunctions(deps: {
  firestore: admin.firestore.Firestore;
}) {
  const { firestore } = deps;

  const bookVehicleRental = onCall(
    CALLABLE_RUNTIME_OPTIONS,
    async (request) => {
      const clientId = requireAuthenticatedUid(request.auth);
      const callerRole = await resolveCallerRole({
        firestore,
        auth: request.auth,
      });
      if (callerRole !== "client") {
        throw new HttpsError(
          "permission-denied",
          "Só clientes podem reservar veículos.",
        );
      }

      const payload = request.data as Record<string, unknown> | null;
      const vehicleId =
        typeof payload?.vehicleId === "string" ? payload.vehicleId.trim() : "";
      const vehicleLabel =
        typeof payload?.vehicleLabel === "string"
          ? payload.vehicleLabel.trim()
          : "";
      const pickupAddress =
        typeof payload?.pickupAddress === "string"
          ? payload.pickupAddress.trim()
          : "";
      const returnAddress =
        typeof payload?.returnAddress === "string"
          ? payload.returnAddress.trim()
          : "";
      const totalMinor =
        typeof payload?.totalMinor === "number"
          ? Math.round(payload.totalMinor)
          : 0;
      const fullInsurance = payload?.fullInsurance === true;
      const scheduledAt = parseScheduledAt(payload?.scheduledAt);

      if (
        !vehicleId ||
        !vehicleLabel ||
        !pickupAddress ||
        !returnAddress ||
        totalMinor <= 0
      ) {
        throw new HttpsError("invalid-argument", "Pedido de reserva inválido.");
      }

      const reservationRef = firestore.collection("reservations").doc();
      const balanceRef = firestore.doc(`balances/${clientId}`);
      const ledgerRef = firestore.doc(
        `balance_adjustments/vehicle_rental_${reservationRef.id}`,
      );

      await firestore.runTransaction(async (transaction) => {
        const [balanceSnapshot, ledgerSnapshot] = await Promise.all([
          transaction.get(balanceRef),
          transaction.get(ledgerRef),
        ]);
        if (ledgerSnapshot.exists) {
          return;
        }

        const balance = parseBalanceDocument(balanceSnapshot.data());
        const creditLimitMinor = Math.abs(balance.debtLimit.amountMinor);
        const balanceAfterMinor =
          balance.balance.amountMinor - totalMinor;

        if (balanceAfterMinor < -creditLimitMinor) {
          throw new HttpsError(
            "failed-precondition",
            "Saldo insuficiente para concluir a reserva.",
            {
              reason: "LIMIT_EXCEEDED",
              operation: "book_vehicle_rental",
              currency: balance.balance.currency,
              balanceBeforeMinor: balance.balance.amountMinor,
              debitAmountMinor: totalMinor,
              balanceAfterMinor,
              creditLimitMinor,
            },
          );
        }

        transaction.set(reservationRef, {
          source: "vehicle_rental",
          clientId,
          vehicleId,
          vehicleLabel,
          scheduledAt,
          status: "confirmed",
          pickup: { address: pickupAddress },
          destination: { address: returnAddress },
          transportType: { id: "vehicle_rental", name: "Vehicle rental" },
          estimatedTotalMinor: totalMinor,
          chargedAmountMinor: totalMinor,
          fullInsurance,
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });

        transaction.set(
          balanceRef,
          {
            balance: buildMoneyPayload(balanceAfterMinor),
            debtLimit: balance.debtLimit,
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );

        transaction.set(ledgerRef, {
          clientId,
          adminId: "system",
          delta: buildMoneyPayload(-totalMinor),
          reason: "Vehicle rental booking",
          reservationId: reservationRef.id,
          createdAt: FieldValue.serverTimestamp(),
        });
      });

      logger.info("Vehicle rental booked.", {
        clientId,
        reservationId: reservationRef.id,
        totalMinor,
      });

      return {
        ok: true,
        reservationId: reservationRef.id,
      };
    },
  );

  return { bookVehicleRental };
}
