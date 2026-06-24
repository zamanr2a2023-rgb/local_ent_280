import test from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';

import {
  createRealtimeDatabaseTestEnvironment,
  getAuthedRealtimeDatabase,
  getUnauthedRealtimeDatabase
} from '../src/realtimeDatabaseTestEnvironment.js';
import { roleFixtures } from '../src/fixtures/roleFixtures.js';

let testEnv;

test.before(async () => {
  testEnv = await createRealtimeDatabaseTestEnvironment();
});

test.after(async () => {
  await testEnv.cleanup();
});


test('bloqueia acesso não autenticado ao RTDB', async () => {
  const db = getUnauthedRealtimeDatabase(testEnv);

  await assertFails(db.ref('driverLocations/driver-1').once('value'));
  await assertFails(db.ref('driverPresence/driver-1').set({ isOnline: true }));
});

test('permite apenas escrita do próprio condutor em driverLocations', async () => {
  const driverDb = getAuthedRealtimeDatabase(testEnv, roleFixtures.driver);
  const otherDriverDb = getAuthedRealtimeDatabase(testEnv, { uid: 'driver-2' });

  await assertSucceeds(
    driverDb.ref(`driverLocations/${roleFixtures.driver.uid}`).set({
      g: 'ezs42e44x',
      ts: 1704153600,
      l: [38.7223, -9.1393],
      heading: 120,
      speed: 35
    })
  );

  await assertFails(
    otherDriverDb.ref(`driverLocations/${roleFixtures.driver.uid}`).set({
      g: 'ezs42e44x',
      ts: 1704153600,
      l: [38.7223, -9.1393]
    })
  );
});

test('aplica validação estrutural em driverLocations', async () => {
  const driverDb = getAuthedRealtimeDatabase(testEnv, roleFixtures.driver);

  await assertFails(
    driverDb.ref(`driverLocations/${roleFixtures.driver.uid}`).set({
      g: 'inv',
      ts: 1704153600,
      l: [100, -9.1393]
    })
  );

  await assertFails(
    driverDb.ref(`driverLocations/${roleFixtures.driver.uid}`).set({
      g: 'ezs42e44x',
      ts: '1704153600',
      l: [38.7223, -9.1393]
    })
  );
});

test('permite leitura autenticada e protege escrita em driverPresence', async () => {
  const driverDb = getAuthedRealtimeDatabase(testEnv, roleFixtures.driver);
  const clientDb = getAuthedRealtimeDatabase(testEnv, roleFixtures.client);

  await assertSucceeds(
    driverDb.ref(`driverPresence/${roleFixtures.driver.uid}`).set({
      isOnline: true,
      lastSeenAt: 1704153600
    })
  );

  await assertSucceeds(clientDb.ref(`driverPresence/${roleFixtures.driver.uid}`).once('value'));

  await assertFails(
    clientDb.ref(`driverPresence/${roleFixtures.driver.uid}`).set({
      isOnline: false
    })
  );
});
