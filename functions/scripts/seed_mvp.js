const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const {initializeFirebaseAdmin} = require('./firebase_admin_init');
const {
  seedOperationalMonitoringScenarios,
} = require('./seed_operational_monitoring_scenarios');

const DEFAULT_PROJECT_ID = 'local-transport-482015';
const GEOHASH_BASE32 = '0123456789bcdefghjkmnpqrstuvwxyz';
const GEOHASH_PRECISION = 9;

const users = {
  admin: {
    email: 'admin.qa@localtransport.test',
    password: 'Admin123!@#',
    role: 'admin',
    name: 'Admin QA',
    phone: '+351910000001',
    isActive: true,
  },
  manager: {
    email: 'manager.qa@localtransport.test',
    password: 'Manager123!@#',
    role: 'manager',
    name: 'Manager QA',
    phone: '+351910000031',
    isActive: true,
    managerPermissions: {
      vt: true,
      vd: true,
      vc: true,
      ts: true,
      mt: true,
    },
  },
  driverOne: {
    email: 'driver1.qa@localtransport.test',
    password: 'Driver123!@#',
    role: 'driver',
    name: 'Motorista QA 1',
    phone: '+351910000011',
    isActive: true,
  },
  driverTwo: {
    email: 'driver2.qa@localtransport.test',
    password: 'Driver123!@#',
    role: 'driver',
    name: 'Motorista QA 2',
    phone: '+351910000022',
    isActive: true,
  },
  clientOne: {
    email: 'cliente1.qa@localtransport.test',
    password: 'Cliente123!@#',
    role: 'client',
    name: 'Cliente QA 1',
    phone: '+351910000101',
    isActive: true,
  },
  clientTwo: {
    email: 'cliente2.qa@localtransport.test',
    password: 'Cliente123!@#',
    role: 'client',
    name: 'Cliente QA 2',
    phone: '+351910000202',
    isActive: true,
  },
};

const driverLocations = {
  driverOne: {
    lat: 38.7223,
    lng: -9.1393,
  },
  driverTwo: {
    lat: 38.7369,
    lng: -9.1427,
  },
};

const balances = {
  clientOne: {
    balanceMinor: 5000,
    debtLimitMinor: -2000,
  },
  clientTwo: {
    balanceMinor: -1900,
    debtLimitMinor: -2000,
  },
};

const vehicle = {
  id: 'vehicle_mvp_1',
  plate: 'AA-00-BB',
  make: 'Dacia',
  model: 'Sandero',
  color: 'Branco',
  isActive: true,
};

function encodeGeohash(latitude, longitude, precision) {
  let latMin = -90.0;
  let latMax = 90.0;
  let lonMin = -180.0;
  let lonMax = 180.0;
  let isEven = true;
  let bit = 0;
  let ch = 0;
  let hash = '';
  while (hash.length < precision) {
    if (isEven) {
      const mid = (lonMin + lonMax) / 2;
      if (longitude >= mid) {
        ch |= 1 << (4 - bit);
        lonMin = mid;
      } else {
        lonMax = mid;
      }
    } else {
      const mid = (latMin + latMax) / 2;
      if (latitude >= mid) {
        ch |= 1 << (4 - bit);
        latMin = mid;
      } else {
        latMax = mid;
      }
    }
    isEven = !isEven;
    if (bit < 4) {
      bit += 1;
    } else {
      hash += GEOHASH_BASE32[ch];
      bit = 0;
      ch = 0;
    }
  }
  return hash;
}

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
      console.warn('Seed MVP: FIREBASE_CONFIG inválido.', error);
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
      console.warn('Seed MVP: falha a ler .firebaserc.', error);
    }
  }

  return DEFAULT_PROJECT_ID;
}

function resolveDatabaseUrl(projectId) {
  if (process.env.FIREBASE_DATABASE_URL) {
    return process.env.FIREBASE_DATABASE_URL;
  }
  if (process.env.FIREBASE_DATABASE_EMULATOR_HOST) {
    return `http://${process.env.FIREBASE_DATABASE_EMULATOR_HOST}?ns=${projectId}`;
  }
  return undefined;
}

async function ensureUser(profile) {
  let userRecord;
  try {
    userRecord = await admin.auth().getUserByEmail(profile.email);
    console.log(`Seed MVP: utilizador encontrado ${profile.email}.`);
  } catch (error) {
    if (error.code !== 'auth/user-not-found') {
      throw error;
    }
  }

  if (!userRecord) {
    userRecord = await admin.auth().createUser({
      email: profile.email,
      password: profile.password,
      displayName: profile.name,
    });
    console.log(`Seed MVP: utilizador criado ${profile.email}.`);
  } else {
    await admin.auth().updateUser(userRecord.uid, {
      password: profile.password,
      displayName: profile.name,
    });
    console.log(`Seed MVP: utilizador atualizado ${profile.email}.`);
  }

  const claims = {
    role: profile.role,
    ...(profile.managerPermissions ? { mp: profile.managerPermissions } : {}),
  };
  await admin.auth().setCustomUserClaims(userRecord.uid, claims);

  return userRecord.uid;
}

async function upsertUserProfile(uid, profile) {
  const userRef = admin.firestore().doc(`users/${uid}`);
  const snapshot = await userRef.get();
  const existing = snapshot.data();
  const createdAt = existing?.createdAt || admin.firestore.FieldValue.serverTimestamp();

  const payload = {
    uid,
    role: profile.role,
    name: profile.name,
    phone: profile.phone,
    email: profile.email,
    isActive: profile.isActive,
    ...(profile.managerPermissions
      ? { managerPermissions: profile.managerPermissions }
      : {}),
    createdAt,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await userRef.set(payload, { merge: true });
  console.log(`Seed MVP: perfil gravado para ${uid}.`);
}

async function upsertBalance(clientId, balance) {
  const balanceRef = admin.firestore().doc(`balances/${clientId}`);
  const snapshot = await balanceRef.get();
  const existing = snapshot.data();
  const createdAt =
    existing?.createdAt || admin.firestore.FieldValue.serverTimestamp();

  await balanceRef.set(
    {
      balance: {
        amountMinor: balance.balanceMinor,
        currency: 'EUR',
      },
      debtLimit: {
        amountMinor: balance.debtLimitMinor,
        currency: 'EUR',
      },
      createdAt,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  console.log(`Seed MVP: saldo atualizado para ${clientId}.`);
}

async function upsertVehicle(driverId) {
  const vehicleRef = admin.firestore().doc(`vehicles/${vehicle.id}`);
  const snapshot = await vehicleRef.get();
  const existing = snapshot.data();
  const createdAt = existing?.createdAt || admin.firestore.FieldValue.serverTimestamp();

  await admin.firestore().doc(`vehicles/${vehicle.id}`).set(
    {
      driverId,
      plate: vehicle.plate,
      make: vehicle.make,
      model: vehicle.model,
      color: vehicle.color,
      capacity: existing?.capacity ?? 4,
      notes:
        typeof existing?.notes === 'string' ? existing.notes : '',
      isActive: vehicle.isActive,
      createdAt,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  console.log(`Seed MVP: veículo ${vehicle.id} gravado.`);
}

async function upsertDriverVehicleAssignment(driverId) {
  await admin.firestore().doc(`driverVehicleAssignments/${driverId}`).set(
    {
      vehicleId: vehicle.id,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  console.log(`Seed MVP: associação veículo-motorista gravada para ${driverId}.`);
}

async function upsertPricingDefaults() {
  const toMoney = (amountMinor) => ({ amountMinor, currency: 'EUR' });

  await admin.firestore().doc('transport_types/standard').set(
    {
      name: 'Standard',
      description: 'Viagens do dia a dia com conforto.',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  console.log('Seed MVP: tipo de transporte standard gravado.');

  const tariffDocIds = ['public_default', 'admin_default'];
  for (const tariffId of tariffDocIds) {
    const tariffRef = admin.firestore().doc(`tariffs/${tariffId}`);
    const snapshot = await tariffRef.get();
    const existing = snapshot.data();
    const createdAt =
      existing?.createdAt || admin.firestore.FieldValue.serverTimestamp();

    await tariffRef.set(
      {
        baseByTransportType: {
          standard: toMoney(250),
        },
        perKm: toMoney(120),
        perWaitMinute: toMoney(10),
        distanceTiers: [
          {
            startMetersInclusive: 0,
            perKm: toMoney(120),
          },
        ],
        penaltyFees: {
          lateCancellation: toMoney(0),
          noShow: toMoney(0),
        },
        multiplierRules: [],
        createdAt,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }
  console.log('Seed MVP: tarifas public/admin gravadas.');

  const policyDocIds = ['cancellation_policy_public', 'cancellation_policy_admin'];
  for (const policyId of policyDocIds) {
    const policyRef = admin.firestore().doc(`config/${policyId}`);
    await policyRef.set(
      {
        preArrivalFee: toMoney(0),
        postArrivalFee: toMoney(150),
        noShowFee: toMoney(300),
        noShowMinutes: 10,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }
  console.log('Seed MVP: políticas de cancelamento public/admin gravadas.');
}

async function upsertOperationalMonitoringConfig() {
  await admin.firestore().doc('config/operations_monitoring').set(
    {
      baseGeofence: {
        label: 'Base Lisboa',
        center: {
          latitude: 38.7223,
          longitude: -9.1393,
        },
        radiusMeters: 250,
      },
      serviceGeofences: [
        {
          label: 'Oficina Lisboa',
          center: {
            latitude: 38.7369,
            longitude: -9.1427,
          },
          radiusMeters: 180,
        },
      ],
      dropoffWaitingRadiusMeters: 250,
      postDropoffGracePeriodMinutes: 10,
      routeDeviationCorridorMeters: 300,
      sustainedDeviationThresholdSeconds: 180,
      activeTripVarianceToleranceKm: 1.5,
      activeTripVarianceTolerancePct: 20,
      postDropoffLocalMovementAllowanceKm: 0.8,
      postDropoffVarianceToleranceKm: 1.2,
      postDropoffVarianceTolerancePct: 35,
      noTripLocalMovementAllowanceKm: 0.8,
      noTripMovementGracePeriodMinutes: 10,
      nextAssignmentSuppressionLookaheadMinutes: 20,
      staleTelemetryThresholdSeconds: 300,
      incidentClearanceThresholdSeconds: 180,
      replaySampleMinDistanceMeters: 120,
      replaySampleMinIntervalSeconds: 60,
      approvalDestinationArrivalRadiusMeters: 300,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: 'seed_mvp',
    },
    { merge: true },
  );
  console.log('Seed MVP: config de monitorização operacional gravada.');
}

async function upsertDriverStatus({
  driverId,
  vehicleId = null,
  isAvailable,
}) {
  await admin.firestore().doc(`driverStatus/${driverId}`).set(
    {
      isActive: true,
      isAvailable,
      availabilityEnabled: true,
      isBusy: false,
      vehicleId,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastSeenAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  console.log(`Seed MVP: estado do motorista gravado para ${driverId}.`);
}

async function upsertDriverLocations(driverIds) {
  const databaseUrl = resolveDatabaseUrl(resolveProjectId());
  let realtimeDb;
  if (databaseUrl) {
    realtimeDb = admin.database();
  } else {
    console.warn(
      'Seed MVP: FIREBASE_DATABASE_URL não definido, a ignorar Realtime Database.',
    );
  }

  await Promise.all(
    Object.entries(driverIds).map(async ([key, driverId]) => {
      const location = driverLocations[key];
      if (!location) {
        console.warn(`Seed MVP: localização não definida para ${key}.`);
        return;
      }

      if (realtimeDb) {
        const geohash = encodeGeohash(
          location.lat,
          location.lng,
          GEOHASH_PRECISION,
        );
        await realtimeDb.ref(`driverLocations/${driverId}`).set({
          l: [location.lat, location.lng],
          g: geohash,
          ts: Date.now(),
        });
      }
      console.log(`Seed MVP: localização gravada para ${driverId}.`);
    }),
  );
}

function buildScheduledDayKey(date) {
  const year = String(date.getFullYear()).padStart(4, '0');
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

async function upsertOperationalReservation({
  reservationId,
  clientId,
  assignedDriverId,
  createdByUserId,
  createdByRole,
}) {
  const scheduledAt = new Date();
  scheduledAt.setDate(scheduledAt.getDate() + 1);
  scheduledAt.setHours(10, 0, 0, 0);

  await admin.firestore().doc(`reservations/${reservationId}`).set(
    {
      source: 'internal_staff',
      clientId,
      assignedDriverId,
      scheduledAt,
      scheduledDayKey: buildScheduledDayKey(scheduledAt),
      scheduledMinutesLocal: scheduledAt.getHours() * 60 + scheduledAt.getMinutes(),
      status: 'scheduled',
      pickup: {
        latitude: 38.7223,
        longitude: -9.1393,
        address: 'Praça do Comércio, Lisboa',
      },
      destination: {
        latitude: 38.7071,
        longitude: -9.1355,
        address: 'Cais do Sodré, Lisboa',
      },
      transportType: {
        id: 'standard',
        name: 'Standard',
      },
      createdByUserId,
      createdByRole,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  console.log(`Seed MVP: reserva operacional ${reservationId} gravada.`);
}

async function run() {
  const projectId = resolveProjectId();
  const databaseURL = resolveDatabaseUrl(projectId);

  initializeFirebaseAdmin({projectId, databaseURL});

  console.log(`Seed MVP: projeto ${projectId}.`);

  const adminId = await ensureUser(users.admin);
  const managerId = await ensureUser(users.manager);
  const driverOneId = await ensureUser(users.driverOne);
  const driverTwoId = await ensureUser(users.driverTwo);
  const clientOneId = await ensureUser(users.clientOne);
  const clientTwoId = await ensureUser(users.clientTwo);

  await upsertUserProfile(adminId, users.admin);
  await upsertUserProfile(managerId, users.manager);
  await upsertUserProfile(driverOneId, users.driverOne);
  await upsertUserProfile(driverTwoId, users.driverTwo);
  await upsertUserProfile(clientOneId, users.clientOne);
  await upsertUserProfile(clientTwoId, users.clientTwo);

  await upsertBalance(clientOneId, balances.clientOne);
  await upsertBalance(clientTwoId, balances.clientTwo);

  await upsertVehicle(driverOneId);
  await upsertDriverVehicleAssignment(driverOneId);
  await upsertPricingDefaults();
  await upsertOperationalMonitoringConfig();
  await upsertDriverStatus({
    driverId: driverOneId,
    vehicleId: vehicle.id,
    isAvailable: true,
  });
  await upsertDriverStatus({
    driverId: driverTwoId,
    isAvailable: false,
  });

  await upsertDriverLocations({
    driverOne: driverOneId,
    driverTwo: driverTwoId,
  });
  await upsertOperationalReservation({
    reservationId: 'reservation_internal_staff_mvp_1',
    clientId: clientOneId,
    assignedDriverId: driverOneId,
    createdByUserId: adminId,
    createdByRole: 'admin',
  });
  await seedOperationalMonitoringScenarios({
    firestore: admin.firestore(),
    driverIds: {
      driverOne: driverOneId,
      driverTwo: driverTwoId,
    },
    driverProfiles: {
      driverOne: users.driverOne,
      driverTwo: users.driverTwo,
    },
    managerId,
    adminId,
    vehicle,
  });

  console.log('Seed MVP: concluído com sucesso.');
}

run().catch((error) => {
  console.error('Seed MVP: falha na execução.', error);
  process.exitCode = 1;
});
