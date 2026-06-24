const admin = require('firebase-admin');

function parseArgs(argv) {
  const args = new Set(argv);
  return {
    apply: args.has('--apply'),
  };
}

function resolveProjectId() {
  return (
    process.env.GCLOUD_PROJECT ||
    process.env.FIREBASE_PROJECT_ID ||
    process.env.PROJECT_ID ||
    undefined
  );
}

function toMoney(amountMinor) {
  return {
    amountMinor,
    currency: 'EUR',
  };
}

function parseMoney(value, fieldName) {
  if (!value || typeof value !== 'object') {
    throw new Error(`${fieldName} inválido ou ausente.`);
  }
  const amountMinor = value.amountMinor;
  const currency = value.currency;
  if (!Number.isInteger(amountMinor)) {
    throw new Error(`${fieldName}.amountMinor inválido.`);
  }
  if (currency !== 'EUR') {
    throw new Error(`${fieldName}.currency inválido.`);
  }
  return {
    amountMinor,
    currency,
  };
}

function formatMinor(amountMinor) {
  return `${(amountMinor / 100).toFixed(2)} EUR`;
}

async function run() {
  const { apply } = parseArgs(process.argv.slice(2));
  const projectId = resolveProjectId();

  if (admin.apps.length === 0) {
    admin.initializeApp({
      ...(projectId == null ? {} : { projectId }),
    });
  }

  const firestore = admin.firestore();
  const adminTariffRef = firestore.doc('tariffs/admin_default');
  const transportTypesSnapshot = await firestore.collection('transport_types').get();
  const adminTariffSnapshot = await adminTariffRef.get();

  if (!adminTariffSnapshot.exists) {
    throw new Error('Documento tariffs/admin_default não existe.');
  }
  if (transportTypesSnapshot.empty) {
    throw new Error('Não existem transport_types para migrar.');
  }

  const adminTariffData = adminTariffSnapshot.data() ?? {};
  const legacyBase = parseMoney(adminTariffData.base, 'tariffs/admin_default.base');
  const transportTypes = transportTypesSnapshot.docs
    .map((doc) => {
      const data = doc.data() ?? {};
      const rawMultiplier = data.multiplier;
      const normalizedMultiplier =
        typeof rawMultiplier === 'number' && Number.isFinite(rawMultiplier) && rawMultiplier > 0
          ? rawMultiplier
          : 1;
      return {
        id: doc.id,
        name: typeof data.name === 'string' && data.name.trim().length > 0 ? data.name.trim() : doc.id,
        legacyMultiplier: normalizedMultiplier,
        multiplierMissing: rawMultiplier == null,
      };
    })
    .sort((left, right) => left.id.localeCompare(right.id));

  const baseByTransportType = {};
  const reportRows = [];
  for (const transportType of transportTypes) {
    const migratedBaseMinor = Math.round(
      legacyBase.amountMinor * transportType.legacyMultiplier,
    );
    baseByTransportType[transportType.id] = toMoney(migratedBaseMinor);
    reportRows.push({
      id: transportType.id,
      name: transportType.name,
      legacyMultiplier: transportType.legacyMultiplier.toFixed(4),
      migratedBaseMinor,
      multiplierSource: transportType.multiplierMissing ? 'defaulted_to_1' : 'transport_type.multiplier',
    });
  }

  console.log('Tariff base-by-transport-type migration');
  console.log(`Mode: ${apply ? 'APPLY' : 'DRY_RUN'}`);
  console.log(`Project: ${projectId ?? 'default-app-project'}`);
  console.log(`Legacy admin_default.base: ${formatMinor(legacyBase.amountMinor)}`);
  console.log('');
  console.log(
    'Policy note: this migration is not economics-preserving for the full fare. ' +
      'It converts transport differentiation from a fare-wide multiplier into a base-fare-only selector.',
  );
  console.log('');
  console.table(
    reportRows.map((row) => ({
      transportTypeId: row.id,
      transportTypeName: row.name,
      legacyMultiplier: row.legacyMultiplier,
      migratedBaseFare: formatMinor(row.migratedBaseMinor),
      multiplierSource: row.multiplierSource,
    })),
  );
  console.log('Next admin_default.baseByTransportType payload:');
  console.log(JSON.stringify(baseByTransportType, null, 2));

  if (!apply) {
    console.log('');
    console.log(
      'Dry run only. Re-run with --apply to write admin_default.baseByTransportType and remove legacy transport multipliers.',
    );
    return;
  }

  const batch = firestore.batch();
  batch.set(
    adminTariffRef,
    {
      baseByTransportType,
      base: admin.firestore.FieldValue.delete(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  for (const transportType of transportTypesSnapshot.docs) {
    batch.set(
      transportType.ref,
      {
        multiplier: admin.firestore.FieldValue.delete(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }

  await batch.commit();

  console.log('');
  console.log(
    'Migration applied to tariffs/admin_default and transport_types/*.',
  );
  console.log(
    'Expected follow-up: deployed syncPublicTariffFromAdmin will mirror the full deterministic projection to tariffs/public_default.',
  );
}

run().catch((error) => {
  console.error('Tariff migration failed.', error);
  process.exitCode = 1;
});
