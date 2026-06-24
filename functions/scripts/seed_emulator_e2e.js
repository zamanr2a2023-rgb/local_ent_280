const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const DEFAULT_PROJECT_ID = 'demo-local-transport';
const CLIENT_EMAIL = 'cliente.e2e@localtransport.test';
const CLIENT_PASSWORD = 'ClienteE2E123!';
const CLIENT_NAME = 'Cliente E2E';
const CLIENT_PHONE = '+351910000501';
const DRIVER_ID = 'driver-e2e-1';
const TRIP_ID = 'trip-e2e-client-1';
const FIXED_NOW = new Date('2026-03-29T10:00:00.000Z');

function resolveProjectId() {
  const envProjectId =
    process.env.FIREBASE_PROJECT_ID ||
    process.env.GCLOUD_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT;
  if (envProjectId) {
    return envProjectId;
  }

  const config = process.env.FIREBASE_CONFIG;
  if (config) {
    try {
      const parsed = JSON.parse(config);
      if (parsed.projectId) {
        return parsed.projectId;
      }
    } catch (error) {
      console.warn('Seed emulator E2E: FIREBASE_CONFIG inválido.', error);
    }
  }

  const firebasercPath = path.resolve(__dirname, '..', '..', '.firebaserc');
  if (fs.existsSync(firebasercPath)) {
    try {
      const content = fs.readFileSync(firebasercPath, 'utf8');
      const parsed = JSON.parse(content);
      const defaultProject = parsed?.projects?.default;
      if (defaultProject) {
        return defaultProject;
      }
    } catch (error) {
      console.warn('Seed emulator E2E: falha a ler .firebaserc.', error);
    }
  }

  return DEFAULT_PROJECT_ID;
}

function resolveDatabaseUrl(projectId) {
  if (process.env.FIREBASE_DATABASE_URL) {
    return process.env.FIREBASE_DATABASE_URL;
  }
  if (process.env.FIREBASE_DATABASE_EMULATOR_HOST) {
    return `http://${process.env.FIREBASE_DATABASE_EMULATOR_HOST}?ns=${projectId}-default-rtdb`;
  }
  return undefined;
}

function firestoreTimestamp() {
  return admin.firestore.Timestamp.fromDate(FIXED_NOW);
}

function money(amountMinor) {
  return {amountMinor, currency: 'EUR'};
}

async function ensureClientUser() {
  const auth = admin.auth();
  let userRecord;
  try {
    userRecord = await auth.getUserByEmail(CLIENT_EMAIL);
    console.log(`Seed emulator E2E: utilizador encontrado ${CLIENT_EMAIL}.`);
  } catch (error) {
    if (error.code !== 'auth/user-not-found') {
      throw error;
    }
  }

  if (!userRecord) {
    userRecord = await auth.createUser({
      email: CLIENT_EMAIL,
      password: CLIENT_PASSWORD,
      displayName: CLIENT_NAME,
    });
    console.log(`Seed emulator E2E: utilizador criado ${CLIENT_EMAIL}.`);
  } else {
    await auth.updateUser(userRecord.uid, {
      password: CLIENT_PASSWORD,
      displayName: CLIENT_NAME,
    });
    console.log(`Seed emulator E2E: utilizador atualizado ${CLIENT_EMAIL}.`);
  }

  await auth.setCustomUserClaims(userRecord.uid, {role: 'client'});
  return userRecord;
}

async function seedClientProfile(uid) {
  const timestamp = firestoreTimestamp();
  await admin.firestore().doc(`users/${uid}`).set({
    uid,
    role: 'client',
    name: CLIENT_NAME,
    phone: CLIENT_PHONE,
    email: CLIENT_EMAIL,
    isActive: true,
    uiCurrency: 'EUR',
    createdAt: timestamp,
    updatedAt: timestamp,
  });
  console.log(`Seed emulator E2E: perfil gravado users/${uid}.`);
}

async function seedClientTrip(clientId) {
  const timestamp = firestoreTimestamp();
  await admin.firestore().doc(`trips/${TRIP_ID}`).set({
    clientId,
    assignedDriverId: DRIVER_ID,
    clientSummary: {
      displayName: CLIENT_NAME,
    },
    driverSummary: {
      displayName: 'Motorista E2E',
    },
    pickup: {
      latitude: 38.7742,
      longitude: -9.1342,
      address: 'Aeroporto Humberto Delgado',
    },
    destination: {
      latitude: 38.7267,
      longitude: -9.1491,
      address: 'Marquês de Pombal',
    },
    transportType: {
      id: 'standard',
      name: 'Standard',
    },
    status: 'REQUESTED',
    isActive: true,
    pricingSnapshot: {
      base: money(500),
      perKm: money(120),
      perWaitMinute: money(35),
      lateCancellationFee: money(0),
      noShowFee: money(0),
      appliedMultiplier: 1,
      multipliers: {default: 1},
      estimatedTotal: money(1250),
    },
    extensionRequestStatus: 'NONE',
    paymentStatus: 'NONE',
    createdAt: timestamp,
    requestedAt: timestamp,
    statusEnteredAt: timestamp,
    updatedAt: timestamp,
  });
  console.log(`Seed emulator E2E: viagem gravada trips/${TRIP_ID}.`);
}

async function seedDriverPresence() {
  const nowMs = FIXED_NOW.getTime();
  await admin.database().ref(`driverPresence/${DRIVER_ID}`).set({
    state: 'online',
    isConnected: true,
    operationalAvailability: true,
    availabilitySource: 'emulator_seed',
    lastConnectedAt: nowMs,
    lastSeenAt: nowMs,
    updatedAt: nowMs,
  });
  console.log(`Seed emulator E2E: presença RTDB gravada driverPresence/${DRIVER_ID}.`);
}

async function run() {
  const projectId = resolveProjectId();
  const databaseURL = resolveDatabaseUrl(projectId);

  if (admin.apps.length === 0) {
    admin.initializeApp({
      projectId,
      databaseURL,
      storageBucket: `${projectId}.firebasestorage.app`,
    });
  }

  console.log(`Seed emulator E2E: projeto ${projectId}.`);

  const clientUser = await ensureClientUser();
  await seedClientProfile(clientUser.uid);
  await seedClientTrip(clientUser.uid);
  await seedDriverPresence();

  console.log('Seed emulator E2E: concluído com sucesso.');
  console.log(`Seed emulator E2E: credenciais ${CLIENT_EMAIL} / ${CLIENT_PASSWORD}`);
}

async function disposeAdminApps() {
  await Promise.all(admin.apps.map((app) => app.delete()));
}

run()
  .then(async () => {
    await disposeAdminApps();
  })
  .catch(async (error) => {
    console.error('Seed emulator E2E: falha na execução.', error);
    await disposeAdminApps();
    process.exitCode = 1;
  });
