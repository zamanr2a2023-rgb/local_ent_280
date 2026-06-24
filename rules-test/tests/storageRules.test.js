import test from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';

import { seedDocument } from '../src/firestoreSeeder.js';
import { roleFixtures } from '../src/fixtures/roleFixtures.js';
import {
  createStorageTestEnvironment,
  defaultStorageBucketUrl,
  getAuthedStorage,
  getUnauthedStorage
} from '../src/storageTestEnvironment.js';

let testEnv;

test.before(async () => {
  testEnv = await createStorageTestEnvironment();
});

test.after(async () => {
  await testEnv.cleanup();
});

test.beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.clearStorage();
});

async function seedRole({ uid, role }) {
  await seedDocument(testEnv, ['users', uid], {
    role,
    name: `Utilizador ${uid}`,
    phone: '+351900000000',
    email: `${uid}@local.pt`,
    isActive: true
  });
}

async function seedStorageObject(path, contents) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context
      .storage(defaultStorageBucketUrl(testEnv.projectId))
      .ref(path)
      .putString(contents);
  });
}

test('utilizador autenticado consegue ler ficheiros em /users', async () => {
  await seedStorageObject('users/client-1/avatar.txt', 'avatar');

  const clientStorage = getAuthedStorage(testEnv, roleFixtures.client);
  const unauthedStorage = getUnauthedStorage(testEnv);

  await assertSucceeds(
    clientStorage.ref('users/client-1/avatar.txt').getDownloadURL(),
  );
  await assertFails(
    unauthedStorage.ref('users/client-1/avatar.txt').getDownloadURL(),
  );
});

test('utilizador autenticado só pode escrever no próprio diretório /users', async () => {
  const clientStorage = getAuthedStorage(testEnv, roleFixtures.client);
  const otherClientStorage = getAuthedStorage(testEnv, { uid: 'client-2' });

  await assertSucceeds(
    clientStorage.ref('users/client-1/avatar.txt').putString('avatar'),
  );
  await assertFails(
    otherClientStorage.ref('users/client-1/avatar.txt').putString('intruso'),
  );
});

test('admin pode escrever em /vehicles e utilizador comum não', async () => {
  await Promise.all([
    seedRole(roleFixtures.admin),
    seedRole(roleFixtures.client)
  ]);

  const adminStorage = getAuthedStorage(testEnv, roleFixtures.admin);
  const clientStorage = getAuthedStorage(testEnv, roleFixtures.client);

  await assertSucceeds(
    adminStorage.ref('vehicles/vehicle-1/photo.txt').putString('fleet'),
  );
  await assertFails(
    clientStorage.ref('vehicles/vehicle-1/photo.txt').putString('fleet'),
  );
});

test('admin e manager com claim tp podem escrever em /tripPackages', async () => {
  await Promise.all([
    seedRole(roleFixtures.admin),
    seedRole(roleFixtures.manager),
    seedRole(roleFixtures.client)
  ]);

  const adminStorage = getAuthedStorage(testEnv, roleFixtures.admin);
  const managerTripPackageStorage = getAuthedStorage(testEnv, {
    uid: roleFixtures.manager.uid,
    role: roleFixtures.manager.role,
    mp: { tp: true }
  });
  const managerWithoutTripPackagePermission = getAuthedStorage(testEnv, {
    uid: roleFixtures.manager.uid,
    role: roleFixtures.manager.role,
    mp: { tp: false }
  });
  const clientStorage = getAuthedStorage(testEnv, roleFixtures.client);

  await assertSucceeds(
    adminStorage.ref('tripPackages/package-1/photo.txt').putString('cover'),
  );
  await assertSucceeds(
    managerTripPackageStorage
      .ref('tripPackages/package-1/photo.txt')
      .putString('cover'),
  );
  await assertFails(
    managerWithoutTripPackagePermission
      .ref('tripPackages/package-1/photo.txt')
      .putString('cover'),
  );
  await assertFails(
    clientStorage.ref('tripPackages/package-1/photo.txt').putString('cover'),
  );
});
