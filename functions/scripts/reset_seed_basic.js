const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const DEFAULT_PROJECT_ID = 'local-transport-482015';
const RESET_CONFIRMATION_VALUE = 'YES_DELETE_ALL';
const AUTH_PAGE_SIZE = 1000;
const DELETE_BATCH_SIZE = 200;

function assertDestructiveConfirmation() {
  const confirmation = process.env.RESET_CONFIRM;
  if (confirmation === RESET_CONFIRMATION_VALUE) {
    return;
  }
  throw new Error(
    `Operação destrutiva bloqueada. Defina RESET_CONFIRM=${RESET_CONFIRMATION_VALUE}.`,
  );
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
      console.warn('Reset seed: FIREBASE_CONFIG inválido.', error);
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
      console.warn('Reset seed: falha a ler .firebaserc.', error);
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
  const config = process.env.FIREBASE_CONFIG;
  if (config) {
    try {
      const parsed = JSON.parse(config);
      if (typeof parsed.databaseURL === 'string' && parsed.databaseURL.trim().length > 0) {
        return parsed.databaseURL.trim();
      }
    } catch (error) {
      console.warn('Reset seed: FIREBASE_CONFIG inválido para databaseURL.', error);
    }
  }

  const googleServicesPath = path.resolve(
    __dirname,
    '..',
    '..',
    'android',
    'app',
    'google-services.json',
  );
  if (fs.existsSync(googleServicesPath)) {
    try {
      const content = fs.readFileSync(googleServicesPath, 'utf8');
      const parsed = JSON.parse(content);
      const firebaseUrl = parsed?.project_info?.firebase_url;
      if (typeof firebaseUrl === 'string' && firebaseUrl.trim().length > 0) {
        return firebaseUrl.trim();
      }
    } catch (error) {
      console.warn('Reset seed: falha a ler google-services.json para databaseURL.', error);
    }
  }
  return undefined;
}

function resolveStorageBucket(projectId) {
  if (process.env.FIREBASE_STORAGE_BUCKET) {
    return process.env.FIREBASE_STORAGE_BUCKET;
  }
  const config = process.env.FIREBASE_CONFIG;
  if (config) {
    try {
      const parsed = JSON.parse(config);
      if (typeof parsed.storageBucket === 'string' && parsed.storageBucket.trim().length > 0) {
        return parsed.storageBucket.trim();
      }
    } catch (error) {
      console.warn('Reset seed: FIREBASE_CONFIG inválido para storageBucket.', error);
    }
  }

  const googleServicesPath = path.resolve(
    __dirname,
    '..',
    '..',
    'android',
    'app',
    'google-services.json',
  );
  if (fs.existsSync(googleServicesPath)) {
    try {
      const content = fs.readFileSync(googleServicesPath, 'utf8');
      const parsed = JSON.parse(content);
      const bucket = parsed?.project_info?.storage_bucket;
      if (typeof bucket === 'string' && bucket.trim().length > 0) {
        return bucket.trim();
      }
    } catch (error) {
      console.warn('Reset seed: falha a ler google-services.json para storageBucket.', error);
    }
  }

  return `${projectId}.appspot.com`;
}

async function deleteCollectionRecursively(collectionRef) {
  while (true) {
    const snapshot = await collectionRef.limit(DELETE_BATCH_SIZE).get();
    if (snapshot.empty) {
      return;
    }

    for (const doc of snapshot.docs) {
      const subCollections = await doc.ref.listCollections();
      for (const subCollection of subCollections) {
        await deleteCollectionRecursively(subCollection);
      }
      await doc.ref.delete();
    }
  }
}

async function wipeFirestore() {
  const firestore = admin.firestore();
  const collections = await firestore.listCollections();
  for (const collection of collections) {
    await deleteCollectionRecursively(collection);
    console.log(`Reset seed: coleção removida ${collection.id}.`);
  }
}

async function wipeRealtimeDatabase() {
  try {
    await admin.database().ref('/').set(null);
    console.log('Reset seed: Realtime Database removida.');
  } catch (error) {
    console.warn('Reset seed: falha ao limpar Realtime Database.', error);
  }
}

async function wipeStorage() {
  try {
    await admin.storage().bucket().deleteFiles({force: true});
    console.log('Reset seed: Storage removido.');
  } catch (error) {
    console.warn('Reset seed: falha ao limpar Storage.', error);
  }
}

async function wipeAuth() {
  const auth = admin.auth();
  let nextPageToken;

  do {
    const page = await auth.listUsers(AUTH_PAGE_SIZE, nextPageToken);
    const uids = page.users.map((user) => user.uid);
    if (uids.length > 0) {
      const result = await auth.deleteUsers(uids);
      if (result.failureCount > 0) {
        console.warn(
          `Reset seed: ${result.failureCount} falhas em deleteUsers, a tentar delete individual.`,
        );
        for (const error of result.errors) {
          try {
            await auth.deleteUser(error.index != null ? uids[error.index] : '');
          } catch (singleError) {
            console.warn('Reset seed: falha ao apagar utilizador individual.', singleError);
          }
        }
      }
      console.log(`Reset seed: utilizadores Auth removidos ${uids.length}.`);
    }
    nextPageToken = page.pageToken;
  } while (nextPageToken);
}

function nowTimestamp() {
  return admin.firestore.FieldValue.serverTimestamp();
}

function toMoney(amountMinor) {
  return {amountMinor, currency: 'EUR'};
}

async function seedAdminUser() {
  const auth = admin.auth();
  const firestore = admin.firestore();

  const user = await auth.createUser({
    email: 'admin@admin.com',
    password: 'asdasd',
    displayName: 'Administrador',
  });

  await auth.setCustomUserClaims(user.uid, {role: 'admin'});

  await firestore.doc(`users/${user.uid}`).set({
    uid: user.uid,
    role: 'admin',
    name: 'Administrador',
    phone: '+351900000000',
    email: 'admin@admin.com',
    isActive: true,
    createdAt: nowTimestamp(),
    updatedAt: nowTimestamp(),
  });

  console.log(`Reset seed: admin criado ${user.uid}.`);
}

async function seedBaseConfig() {
  const firestore = admin.firestore();

  await firestore.doc('transport_types/standard').set({
    name: 'Standard',
    description: 'Viagens do dia a dia com conforto.',
    createdAt: nowTimestamp(),
    updatedAt: nowTimestamp(),
  });

  for (const tariffId of ['public_default', 'admin_default']) {
    await firestore.doc(`tariffs/${tariffId}`).set({
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
      createdAt: nowTimestamp(),
      updatedAt: nowTimestamp(),
    });
  }

  for (const policyId of ['cancellation_policy_public', 'cancellation_policy_admin']) {
    await firestore.doc(`config/${policyId}`).set({
      preArrivalFee: toMoney(0),
      postArrivalFee: toMoney(150),
      noShowFee: toMoney(300),
      noShowMinutes: 10,
      updatedAt: nowTimestamp(),
    });
  }

  console.log('Reset seed: configuração base criada.');
}

async function run() {
  assertDestructiveConfirmation();

  const projectId = resolveProjectId();
  const databaseURL = resolveDatabaseUrl(projectId);
  const storageBucket = resolveStorageBucket(projectId);

  if (!databaseURL) {
    console.warn(
      'Reset seed: databaseURL não resolvida. Realtime Database pode não ser limpa.',
    );
  }
  if (!storageBucket) {
    console.warn('Reset seed: storageBucket não resolvido. Storage pode não ser limpo.');
  }

  if (admin.apps.length === 0) {
    admin.initializeApp({
      projectId,
      databaseURL,
      storageBucket,
    });
  }

  console.log(`Reset seed: projeto alvo ${projectId}.`);
  console.log(`Reset seed: databaseURL ${databaseURL ?? 'N/A'}.`);
  console.log(`Reset seed: storageBucket ${storageBucket ?? 'N/A'}.`);
  console.log('Reset seed: a limpar Firestore, Realtime Database, Storage e Auth...');

  await wipeFirestore();
  await wipeRealtimeDatabase();
  await wipeStorage();
  await wipeAuth();

  console.log('Reset seed: a semear base mínima...');

  await seedAdminUser();
  await seedBaseConfig();

  console.log('Reset seed: concluído com sucesso.');
}

run().catch((error) => {
  console.error('Reset seed: falha na execução.', error);
  process.exitCode = 1;
});
