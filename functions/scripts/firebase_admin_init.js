const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const DEFAULT_SECRETS_PATH = path.resolve(
  __dirname,
  '..',
  'secrets',
  'firebase-service-account.json',
);

function resolveServiceAccountPath() {
  const explicitPath =
    process.env.GOOGLE_APPLICATION_CREDENTIALS ||
    process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
  if (explicitPath && fs.existsSync(explicitPath)) {
    return explicitPath;
  }
  if (fs.existsSync(DEFAULT_SECRETS_PATH)) {
    return DEFAULT_SECRETS_PATH;
  }
  return null;
}

function initializeFirebaseAdmin({ projectId, databaseURL }) {
  if (admin.apps.length > 0) {
    return admin;
  }

  const serviceAccountPath = resolveServiceAccountPath();
  const isEmulator =
    Boolean(process.env.FIREBASE_AUTH_EMULATOR_HOST) ||
    Boolean(process.env.FIRESTORE_EMULATOR_HOST);

  if (serviceAccountPath) {
    const serviceAccount = JSON.parse(
      fs.readFileSync(serviceAccountPath, 'utf8'),
    );
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: projectId || serviceAccount.project_id,
      databaseURL,
    });
    return admin;
  }

  if (isEmulator) {
    admin.initializeApp({
      projectId,
      databaseURL,
    });
    return admin;
  }

  throw new Error(
    'Firebase Admin credentials missing. Download a service account JSON from '
      + 'Firebase Console > Project settings > Service accounts > Generate new '
      + 'private key, save it as functions/secrets/firebase-service-account.json '
      + '(gitignored), or set GOOGLE_APPLICATION_CREDENTIALS to that file path. '
      + 'Alternatively run seeding through emulators: '
      + 'firebase emulators:exec --only auth,firestore,database '
      + '--project demo-local-transport "npm --prefix functions run seed:mvp".',
  );
}

module.exports = {
  DEFAULT_SECRETS_PATH,
  initializeFirebaseAdmin,
  resolveServiceAccountPath,
};
