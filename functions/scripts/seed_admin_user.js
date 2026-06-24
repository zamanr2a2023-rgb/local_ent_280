const admin = require('firebase-admin');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const {initializeFirebaseAdmin} = require('./firebase_admin_init');

const DEFAULT_PROJECT_ID = 'local-transport-482015';
const DEFAULT_ADMIN_EMAIL = 'admin@admin.com';
const DEFAULT_ADMIN_NAME = 'Administrador';
const DEFAULT_ADMIN_PHONE = '+351900000000';

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
      console.warn('Seed admin: FIREBASE_CONFIG inválido.', error);
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
      console.warn('Seed admin: falha a ler .firebaserc.', error);
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

function nowTimestamp() {
  return admin.firestore.FieldValue.serverTimestamp();
}

function generatePassword() {
  return crypto.randomBytes(18).toString('base64url');
}

function resolveAdminProfile() {
  const email = (process.env.ADMIN_EMAIL || DEFAULT_ADMIN_EMAIL).trim().toLowerCase();
  if (!email) {
    throw new Error('Seed admin: ADMIN_EMAIL não pode estar vazio.');
  }

  const providedPassword = process.env.ADMIN_PASSWORD?.trim() || '';
  return {
    email,
    password: providedPassword || generatePassword(),
    passwordProvided: providedPassword.length > 0,
    name: (process.env.ADMIN_NAME || DEFAULT_ADMIN_NAME).trim() || DEFAULT_ADMIN_NAME,
    phone: (process.env.ADMIN_PHONE || DEFAULT_ADMIN_PHONE).trim() || DEFAULT_ADMIN_PHONE,
    isActive: true,
  };
}

async function ensureAdminUser(profile) {
  const auth = admin.auth();
  const firestore = admin.firestore();

  let userRecord;
  let created = false;
  try {
    userRecord = await auth.getUserByEmail(profile.email);
    console.log(`Seed admin: utilizador encontrado ${profile.email}.`);
  } catch (error) {
    if (error.code !== 'auth/user-not-found') {
      throw error;
    }
  }

  if (!userRecord) {
    created = true;
    userRecord = await auth.createUser({
      email: profile.email,
      password: profile.password,
      displayName: profile.name,
    });
    console.log(`Seed admin: utilizador criado ${profile.email}.`);
  } else {
    const updatePayload = {
      displayName: profile.name,
      ...(profile.passwordProvided ? {password: profile.password} : {}),
    };
    await auth.updateUser(userRecord.uid, updatePayload);
    console.log(`Seed admin: utilizador atualizado ${profile.email}.`);
  }

  const mergedClaims = {
    ...(userRecord.customClaims || {}),
    role: 'admin',
  };
  await auth.setCustomUserClaims(userRecord.uid, mergedClaims);

  const userRef = firestore.doc(`users/${userRecord.uid}`);
  const snapshot = await userRef.get();
  const existing = snapshot.data();
  const createdAt = existing?.createdAt || nowTimestamp();

  await userRef.set(
    {
      uid: userRecord.uid,
      role: 'admin',
      name: profile.name,
      phone: profile.phone,
      email: profile.email,
      isActive: profile.isActive,
      createdAt,
      updatedAt: nowTimestamp(),
    },
    {merge: true},
  );

  console.log(`Seed admin: perfil admin gravado para ${userRecord.uid}.`);
  if (created && !profile.passwordProvided) {
    console.log(`Seed admin: password bootstrap gerada ${profile.password}`);
  } else if (profile.passwordProvided) {
    console.log('Seed admin: password definida a partir de ADMIN_PASSWORD.');
  } else {
    console.log('Seed admin: password existente preservada.');
  }
}

async function run() {
  const projectId = resolveProjectId();
  const databaseURL = resolveDatabaseUrl(projectId);

  initializeFirebaseAdmin({projectId, databaseURL});

  const profile = resolveAdminProfile();
  console.log(`Seed admin: projeto ${projectId}.`);
  console.log(`Seed admin: email alvo ${profile.email}.`);

  await ensureAdminUser(profile);

  console.log('Seed admin: concluído com sucesso.');
}

run().catch((error) => {
  console.error('Seed admin: falha na execução.', error);
  process.exitCode = 1;
});
