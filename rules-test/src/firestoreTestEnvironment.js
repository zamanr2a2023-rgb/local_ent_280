import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';

import { parseEmulatorHostAndPort } from './emulatorHostParser.js';

const DEFAULT_PROJECT_ID = 'demo-local-transport';
const DEFAULT_FIRESTORE_PORT = 8080;

const currentDir = dirname(fileURLToPath(import.meta.url));
const firestoreRulesPath = resolve(currentDir, '../../firestore.rules');

export async function createFirestoreTestEnvironment() {
  const projectId = process.env.FIREBASE_PROJECT_ID ?? process.env.GCLOUD_PROJECT ?? DEFAULT_PROJECT_ID;
  const { host, port } = parseEmulatorHostAndPort({
    emulatorHost: process.env.FIRESTORE_EMULATOR_HOST,
    explicitPort: process.env.FIRESTORE_EMULATOR_PORT,
    defaultPort: DEFAULT_FIRESTORE_PORT,
    emulatorName: 'firestore'
  });

  console.info('[rules-test] Initializing Firestore emulator test environment.', {
    projectId,
    host,
    port,
    rulesPath: firestoreRulesPath
  });

  return initializeTestEnvironment({
    projectId,
    firestore: {
      host,
      port,
      rules: readFileSync(firestoreRulesPath, 'utf8')
    }
  });
}

export function getAuthedFirestore(testEnv, authContext) {
  const { uid, token, ...claims } = authContext;
  const resolvedToken =
    token && typeof token === 'object' ? token : claims;
  return testEnv.authenticatedContext(uid, resolvedToken).firestore();
}

export function getUnauthedFirestore(testEnv) {
  return testEnv.unauthenticatedContext().firestore();
}
