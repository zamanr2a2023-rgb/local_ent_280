import test from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { Timestamp, doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';
import {
  createFirestoreTestEnvironment,
  getAuthedFirestore,
} from '../src/firestoreTestEnvironment.js';
import { seedDocument } from '../src/firestoreSeeder.js';
import { roleFixtures } from '../src/fixtures/roleFixtures.js';

let testEnv;
const seededTimestamp = Timestamp.fromDate(new Date('2026-03-22T10:00:00Z'));

function managerAuthWithPermissions(permissions) {
  return {
    uid: roleFixtures.manager.uid,
    token: {
      role: 'manager',
      mp: permissions,
    },
  };
}

async function seedRole({
  uid,
  role,
  name = 'Utilizador',
  phone = '+351900000000',
  email = 'user@local.pt',
  isActive = true,
}) {
  await seedDocument(testEnv, ['users', uid], {
    role,
    name,
    phone,
    email,
    isActive,
    createdAt: seededTimestamp,
    updatedAt: seededTimestamp,
  });
}

async function seedOperationalMonitoringFixtures() {
  await Promise.all([
    seedDocument(testEnv, ['driverOperationalStates', roleFixtures.driver.uid], {
      driverId: roleFixtures.driver.uid,
      operationalWindowId: 'driver:driver-1:idle:1711111111111',
      operationalWindowType: 'no_trip_operational',
      currentState: 'operational_idle',
      updatedAt: seededTimestamp,
    }),
    seedDocument(testEnv, ['tripOperationalMetrics', 'trip_1'], {
      tripId: 'trip_1',
      driverId: roleFixtures.driver.uid,
      activeTripOperationalWindowId: 'trip:trip_1:active',
      expectedTripDistanceKm: 10.0,
      actualTripDistanceKm: 10.8,
      updatedAt: seededTimestamp,
    }),
    seedDocument(testEnv, ['operationalIncidents', 'incident_1'], {
      operationalWindowId: 'driver:driver-1:idle:1711111111111',
      operationalWindowType: 'no_trip_operational',
      driverId: roleFixtures.driver.uid,
      incidentType: 'post_dropoff_unauthorized_movement',
      status: 'open',
      currentState: 'operational_idle',
      startedAt: seededTimestamp,
      originCoordinates: {
        latitude: 38.7223,
        longitude: -9.1393,
        recordedAt: seededTimestamp,
      },
      latestCoordinates: {
        latitude: 38.7369,
        longitude: -9.1427,
        recordedAt: seededTimestamp,
      },
      actualPathSamples: [],
      updatedAt: seededTimestamp,
    }),
    seedDocument(
      testEnv,
      ['operationalIncidents', 'incident_1', 'events', 'event_1'],
      {
        action: 'created',
        actorId: 'system',
        actorRole: 'admin',
        createdAt: seededTimestamp,
      },
    ),
    seedDocument(testEnv, ['operationalMovementApprovals', 'approval_1'], {
      operationalWindowId: 'driver:driver-1:idle:1711111111111',
      operationalWindowType: 'no_trip_operational',
      driverId: roleFixtures.driver.uid,
      reason: 'Abastecimento operacional',
      expiresAt: seededTimestamp,
      approvedBy: roleFixtures.admin.uid,
      approvedByRole: 'admin',
      status: 'active',
      updatedAt: seededTimestamp,
    }),
    seedDocument(testEnv, ['config', 'operations_monitoring'], {
      baseGeofence: {
        center: {
          latitude: 38.7223,
          longitude: -9.1393,
        },
        radiusMeters: 250,
      },
      dropoffWaitingRadiusMeters: 250,
      updatedAt: seededTimestamp,
      updatedBy: 'seed',
    }),
  ]);
}

test.before(async () => {
  testEnv = await createFirestoreTestEnvironment();
});

test.after(async () => {
  await testEnv.cleanup();
});

test.beforeEach(async () => {
  await testEnv.clearFirestore();
});

test('admin and manager with vt+vd can read operational monitoring docs', async () => {
  await Promise.all([
    seedRole(roleFixtures.admin),
    seedRole(roleFixtures.manager),
    seedRole(roleFixtures.driver),
  ]);
  await seedOperationalMonitoringFixtures();

  const adminDb = getAuthedFirestore(testEnv, roleFixtures.admin);
  const managerDb = getAuthedFirestore(
    testEnv,
    managerAuthWithPermissions({ vt: true, vd: true }),
  );

  await assertSucceeds(
    getDoc(doc(adminDb, 'driverOperationalStates', roleFixtures.driver.uid)),
  );
  await assertSucceeds(
    getDoc(doc(managerDb, 'driverOperationalStates', roleFixtures.driver.uid)),
  );
  await assertSucceeds(getDoc(doc(adminDb, 'tripOperationalMetrics', 'trip_1')));
  await assertSucceeds(getDoc(doc(managerDb, 'tripOperationalMetrics', 'trip_1')));
  await assertSucceeds(getDoc(doc(adminDb, 'operationalIncidents', 'incident_1')));
  await assertSucceeds(getDoc(doc(managerDb, 'operationalIncidents', 'incident_1')));
  await assertSucceeds(
    getDoc(doc(adminDb, 'operationalIncidents', 'incident_1', 'events', 'event_1')),
  );
  await assertSucceeds(
    getDoc(doc(managerDb, 'operationalIncidents', 'incident_1', 'events', 'event_1')),
  );
  await assertSucceeds(
    getDoc(doc(adminDb, 'operationalMovementApprovals', 'approval_1')),
  );
  await assertSucceeds(
    getDoc(doc(managerDb, 'operationalMovementApprovals', 'approval_1')),
  );
});

test('driver and manager without full operational permissions cannot read incident docs', async () => {
  await Promise.all([
    seedRole(roleFixtures.manager),
    seedRole(roleFixtures.driver),
  ]);
  await seedOperationalMonitoringFixtures();

  const driverDb = getAuthedFirestore(testEnv, roleFixtures.driver);
  const managerMissingVdDb = getAuthedFirestore(
    testEnv,
    managerAuthWithPermissions({ vt: true }),
  );
  const managerMissingVtDb = getAuthedFirestore(
    testEnv,
    managerAuthWithPermissions({ vd: true }),
  );

  await assertFails(
    getDoc(doc(driverDb, 'operationalIncidents', 'incident_1')),
  );
  await assertFails(
    getDoc(doc(managerMissingVdDb, 'driverOperationalStates', roleFixtures.driver.uid)),
  );
  await assertFails(
    getDoc(doc(managerMissingVtDb, 'tripOperationalMetrics', 'trip_1')),
  );
  await assertFails(
    getDoc(doc(managerMissingVdDb, 'operationalMovementApprovals', 'approval_1')),
  );
});

test('client sdk cannot write server-authored monitoring docs', async () => {
  await Promise.all([
    seedRole(roleFixtures.admin),
    seedRole(roleFixtures.manager),
    seedRole(roleFixtures.driver),
  ]);
  await seedOperationalMonitoringFixtures();

  const adminDb = getAuthedFirestore(testEnv, roleFixtures.admin);
  const managerDb = getAuthedFirestore(
    testEnv,
    managerAuthWithPermissions({ vt: true, vd: true, ts: true }),
  );

  await assertFails(
    setDoc(doc(adminDb, 'driverOperationalStates', 'driver-2'), {
      driverId: 'driver-2',
      operationalWindowId: 'driver:driver-2:idle:1711111111111',
      operationalWindowType: 'no_trip_operational',
      currentState: 'operational_idle',
    }),
  );
  await assertFails(
    updateDoc(doc(managerDb, 'operationalIncidents', 'incident_1'), {
      status: 'dismissed',
    }),
  );
  await assertFails(
    setDoc(doc(adminDb, 'operationalMovementApprovals', 'approval_2'), {
      operationalWindowId: 'driver:driver-1:idle:1711111111111',
      operationalWindowType: 'no_trip_operational',
      driverId: roleFixtures.driver.uid,
      reason: 'Teste',
      expiresAt: seededTimestamp,
      approvedBy: roleFixtures.admin.uid,
      approvedByRole: 'admin',
      status: 'active',
    }),
  );
});

test('only admin can read and write operational monitoring config', async () => {
  await Promise.all([
    seedRole(roleFixtures.admin),
    seedRole(roleFixtures.manager),
  ]);
  await seedOperationalMonitoringFixtures();

  const adminDb = getAuthedFirestore(testEnv, roleFixtures.admin);
  const managerDb = getAuthedFirestore(
    testEnv,
    managerAuthWithPermissions({ vt: true, vd: true }),
  );

  await assertSucceeds(getDoc(doc(adminDb, 'config', 'operations_monitoring')));
  await assertSucceeds(
    updateDoc(doc(adminDb, 'config', 'operations_monitoring'), {
      updatedAt: seededTimestamp,
      updatedBy: 'admin_1',
      dropoffWaitingRadiusMeters: 300,
    }),
  );
  await assertFails(getDoc(doc(managerDb, 'config', 'operations_monitoring')));
  await assertFails(
    updateDoc(doc(managerDb, 'config', 'operations_monitoring'), {
      dropoffWaitingRadiusMeters: 999,
    }),
  );
});
