import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';

import { parseEmulatorHostAndPort } from './emulatorHostParser.js';

const DEFAULT_PROJECT_ID = 'demo-local-transport';
const DEFAULT_FIRESTORE_PORT = 8080;
const DEFAULT_STORAGE_PORT = 9199;

const currentDir = dirname(fileURLToPath(import.meta.url));
const firestoreRulesPath = resolve(currentDir, '../../firestore.rules');
const storageRulesPath = resolve(currentDir, '../../storage.rules');

function resolveProjectId() {
  return process.env.FIREBASE_PROJECT_ID ?? process.env.GCLOUD_PROJECT ?? DEFAULT_PROJECT_ID;
}

function resolveFirestoreConnection() {
  return parseEmulatorHostAndPort({
    emulatorHost: process.env.FIRESTORE_EMULATOR_HOST,
    explicitPort: process.env.FIRESTORE_EMULATOR_PORT,
    defaultPort: DEFAULT_FIRESTORE_PORT,
    emulatorName: 'firestore'
  });
}

function resolveStorageConnection() {
  return parseEmulatorHostAndPort({
    emulatorHost: process.env.FIREBASE_STORAGE_EMULATOR_HOST,
    explicitPort: process.env.FIREBASE_STORAGE_EMULATOR_PORT,
    defaultPort: DEFAULT_STORAGE_PORT,
    emulatorName: 'storage'
  });
}

export async function createStorageTestEnvironment() {
  const projectId = resolveProjectId();
  const firestore = resolveFirestoreConnection();
  const storage = resolveStorageConnection();

  console.info('[rules-test] Initializing Storage emulator test environment.', {
    projectId,
    firestore,
    storage,
    firestoreRulesPath,
    storageRulesPath
  });

  return initializeTestEnvironment({
    projectId,
    firestore: {
      host: firestore.host,
      port: firestore.port,
      rules: readFileSync(firestoreRulesPath, 'utf8')
    },
    storage: {
      host: storage.host,
      port: storage.port,
      rules: readFileSync(storageRulesPath, 'utf8')
    }
  });
}

export function defaultStorageBucketUrl(projectId = resolveProjectId()) {
  return `gs://${projectId}.firebasestorage.app`;
}

export function getAuthedStorage(testEnv, authContext) {
  const { uid, token, ...claims } = authContext;
  const resolvedToken =
    token && typeof token === 'object' ? token : claims;
  return testEnv
    .authenticatedContext(uid, resolvedToken)
    .storage(defaultStorageBucketUrl(testEnv.projectId));
}

export function getUnauthedStorage(testEnv) {
  return testEnv
    .unauthenticatedContext()
    .storage(defaultStorageBucketUrl(testEnv.projectId));
}
