import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';

import { parseEmulatorHostAndPort } from './emulatorHostParser.js';

const DEFAULT_PROJECT_ID = 'demo-local-transport';
const DEFAULT_DATABASE_PORT = 9000;

const currentDir = dirname(fileURLToPath(import.meta.url));
const databaseRulesPath = resolve(currentDir, '../../database.rules.json');

function resolveProjectId() {
  return process.env.FIREBASE_PROJECT_ID ?? process.env.GCLOUD_PROJECT ?? DEFAULT_PROJECT_ID;
}

function resolveDatabaseName(projectId) {
  return process.env.FIREBASE_DATABASE_EMULATOR_NAMESPACE ?? `${projectId}-default-rtdb`;
}

function resolveDatabaseConnection() {
  const projectId = resolveProjectId();
  const { host, port } = parseEmulatorHostAndPort({
    emulatorHost: process.env.FIREBASE_DATABASE_EMULATOR_HOST,
    explicitPort: process.env.FIREBASE_DATABASE_EMULATOR_PORT,
    defaultPort: DEFAULT_DATABASE_PORT,
    emulatorName: 'realtime-database'
  });
  const databaseName = resolveDatabaseName(projectId);
  const databaseUrl = `http://${host}:${port}/?ns=${databaseName}`;

  return { projectId, host, port, databaseName, databaseUrl };
}

export async function createRealtimeDatabaseTestEnvironment() {
  const connection = resolveDatabaseConnection();

  console.info('[rules-test] Initializing Realtime Database emulator test environment.', {
    projectId: connection.projectId,
    databaseName: connection.databaseName,
    host: connection.host,
    port: connection.port,
    rulesPath: databaseRulesPath
  });

  return initializeTestEnvironment({
    projectId: connection.projectId,
    database: {
      host: connection.host,
      port: connection.port,
      databaseName: connection.databaseName,
      rules: readFileSync(databaseRulesPath, 'utf8')
    }
  });
}

export function getAuthedRealtimeDatabase(testEnv, { uid }) {
  const { databaseUrl } = resolveDatabaseConnection();
  return testEnv.authenticatedContext(uid).database(databaseUrl);
}

export function getUnauthedRealtimeDatabase(testEnv) {
  const { databaseUrl } = resolveDatabaseConnection();
  return testEnv.unauthenticatedContext().database(databaseUrl);
}
