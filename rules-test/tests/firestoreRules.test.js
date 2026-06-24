import test from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  Timestamp,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';
import { createFirestoreTestEnvironment, getAuthedFirestore, getUnauthedFirestore } from '../src/firestoreTestEnvironment.js';
import { seedDocument } from '../src/firestoreSeeder.js';
import {
  adminTariffFixture,
  cancellationPolicyAdminFixture,
  cancellationPolicyPublicFixture,
  publicTariffFixture
} from '../src/fixtures/configFixtures.js';
import { roleFixtures } from '../src/fixtures/roleFixtures.js';
import { balanceWriteFixtures } from '../src/fixtures/roleWriteFixtures.js';
import { buildTripFixture } from '../src/fixtures/tripFixtures.js';
import { tripCreateFixtures } from '../src/fixtures/tripCreateFixtures.js';

let testEnv;
const seededTimestamp = Timestamp.fromDate(new Date('2024-01-01T00:00:00Z'));
const scheduledTimestamp = Timestamp.fromDate(new Date('2026-04-01T10:00:00Z'));

function buildInternalStaffReservationFixture({
  clientId,
  assignedDriverId,
  createdByUserId,
  createdByRole,
  status = 'scheduled',
  scheduledAt = scheduledTimestamp,
} = {}) {
  return {
    source: 'internal_staff',
    clientId,
    assignedDriverId,
    scheduledAt,
    scheduledDayKey: '2026-04-01',
    scheduledMinutesLocal: 600,
    status,
    pickup: {
      latitude: 38.7223,
      longitude: -9.1393,
      address: 'Praça do Comércio',
    },
    destination: {
      latitude: 38.7071,
      longitude: -9.1355,
      address: 'Cais do Sodré',
    },
    transportType: {
      id: 'standard',
      name: 'Standard',
    },
    createdByUserId,
    createdByRole,
    createdAt: seededTimestamp,
    updatedAt: seededTimestamp,
  };
}

function buildPackageReservationFixture({
  clientId,
  assignedDriverId,
  status = 'scheduled',
  scheduledAt = scheduledTimestamp,
} = {}) {
  return {
    source: 'package',
    clientId,
    assignedDriverId,
    scheduledAt,
    scheduledDayKey: '2026-04-01',
    scheduledMinutesLocal: 600,
    status,
    pickup: {
      latitude: 38.7223,
      longitude: -9.1393,
      address: 'Praça do Comércio',
    },
    destination: {
      latitude: 38.7071,
      longitude: -9.1355,
      address: 'Cais do Sodré',
    },
    transportType: {
      id: 'standard',
      name: 'Standard',
    },
    vehicleId: 'vehicle-1',
    packageId: 'package-1',
    packageBookingId: 'booking-1',
    packageLegType: 'outbound',
    createdAt: seededTimestamp,
    updatedAt: seededTimestamp,
  };
}

function managerAuthWithPermissions(permissions) {
  return {
    uid: roleFixtures.manager.uid,
    token: {
      role: 'manager',
      mp: permissions
    }
  };
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

async function seedRole({
  uid,
  role,
  name = 'Utilizador',
  phone = '+351900000000',
  email = 'user@local.pt',
  isActive = true
}) {
  await seedDocument(testEnv, ['users', uid], {
    role,
    name,
    phone,
    email,
    isActive,
    createdAt: seededTimestamp,
    updatedAt: seededTimestamp
  });
}

test('permite leitura de viagens para cliente, condutor, manager e admin', async () => {
  const otherClient = { uid: 'client-2', role: 'client' };

  await Promise.all([
    seedRole(roleFixtures.client),
    seedRole(roleFixtures.driver),
    seedRole(roleFixtures.manager),
    seedRole(roleFixtures.admin),
    seedRole(otherClient)
  ]);

  await seedDocument(
    testEnv,
    ['trips', 'trip-1'],
    buildTripFixture({
      clientId: roleFixtures.client.uid,
      assignedDriverId: roleFixtures.driver.uid,
      status: 'REQUESTED'
    })
  );

  const clientDb = getAuthedFirestore(testEnv, roleFixtures.client);
  const driverDb = getAuthedFirestore(testEnv, roleFixtures.driver);
  const managerDb = getAuthedFirestore(
    testEnv,
    managerAuthWithPermissions({ vt: true }),
  );
  const adminDb = getAuthedFirestore(testEnv, roleFixtures.admin);
  const otherDb = getAuthedFirestore(testEnv, otherClient);

  await assertSucceeds(getDoc(doc(clientDb, 'trips', 'trip-1')));
  await assertSucceeds(getDoc(doc(driverDb, 'trips', 'trip-1')));
  await assertSucceeds(getDoc(doc(managerDb, 'trips', 'trip-1')));
  await assertSucceeds(getDoc(doc(adminDb, 'trips', 'trip-1')));
  await assertFails(getDoc(doc(otherDb, 'trips', 'trip-1')));
});

test('cliente não consegue ler nem gerir reservas', async () => {
  await Promise.all([
    seedRole(roleFixtures.client),
    seedRole(roleFixtures.driver),
    seedRole(roleFixtures.admin),
  ]);

  await seedDocument(
    testEnv,
    ['reservations', 'reservation-1'],
    buildInternalStaffReservationFixture({
      clientId: roleFixtures.client.uid,
      assignedDriverId: roleFixtures.driver.uid,
      createdByUserId: roleFixtures.admin.uid,
      createdByRole: 'admin',
    }),
  );

  const clientDb = getAuthedFirestore(testEnv, roleFixtures.client);

  await assertFails(getDoc(doc(clientDb, 'reservations', 'reservation-1')));
  await assertFails(
    setDoc(
      doc(clientDb, 'reservations', 'reservation-client-create'),
      buildInternalStaffReservationFixture({
        clientId: roleFixtures.client.uid,
        assignedDriverId: roleFixtures.driver.uid,
        createdByUserId: roleFixtures.client.uid,
        createdByRole: 'client',
      }),
    ),
  );
  await assertFails(
    updateDoc(doc(clientDb, 'reservations', 'reservation-1'), {
      status: 'cancelled',
      updatedAt: serverTimestamp(),
    }),
  );
  await assertFails(deleteDoc(doc(clientDb, 'reservations', 'reservation-1')));
});

test('cliente consegue abrir thread de suporte vazia antes da primeira mensagem', async () => {
  await seedRole(roleFixtures.client);

  const clientDb = getAuthedFirestore(testEnv, roleFixtures.client);

  await assertSucceeds(
    getDoc(doc(clientDb, 'chatThreads', 'support_client_client-1')),
  );
  await assertSucceeds(
    getDocs(
      query(
        collection(
          clientDb,
          'chatThreads',
          'support_client_client-1',
          'chatMessages',
        ),
        orderBy('createdAt'),
      ),
    ),
  );
});

test('cliente não consegue abrir thread de suporte de outro cliente', async () => {
  await Promise.all([
    seedRole(roleFixtures.client),
    seedRole({ uid: 'client-2', role: 'client' }),
  ]);

  const clientDb = getAuthedFirestore(testEnv, roleFixtures.client);

  await assertFails(
    getDoc(doc(clientDb, 'chatThreads', 'support_client_client-2')),
  );
  await assertFails(
    getDocs(
      query(
        collection(
          clientDb,
          'chatThreads',
          'support_client_client-2',
          'chatMessages',
        ),
        orderBy('createdAt'),
      ),
    ),
  );
});

test('admin consegue criar, cancelar e apagar reservas operacionais', async () => {
  await Promise.all([
    seedRole(roleFixtures.client),
    seedRole(roleFixtures.driver),
    seedRole(roleFixtures.admin),
  ]);

  const adminDb = getAuthedFirestore(testEnv, roleFixtures.admin);

  await assertSucceeds(
    setDoc(
      doc(adminDb, 'reservations', 'reservation-admin-create'),
      buildInternalStaffReservationFixture({
        clientId: roleFixtures.client.uid,
        assignedDriverId: roleFixtures.driver.uid,
        createdByUserId: roleFixtures.admin.uid,
        createdByRole: 'admin',
      }),
    ),
  );

  await assertSucceeds(
    updateDoc(doc(adminDb, 'reservations', 'reservation-admin-create'), {
      status: 'cancelled',
      updatedAt: serverTimestamp(),
    }),
  );
  await assertSucceeds(
    deleteDoc(doc(adminDb, 'reservations', 'reservation-admin-create')),
  );
});

test('manager com vt, vd e vc consegue ler, criar e cancelar reservas operacionais', async () => {
  await Promise.all([
    seedRole(roleFixtures.client),
    seedRole(roleFixtures.driver),
    seedRole(roleFixtures.manager),
  ]);

  await seedDocument(
    testEnv,
    ['reservations', 'reservation-1'],
    buildInternalStaffReservationFixture({
      clientId: roleFixtures.client.uid,
      assignedDriverId: roleFixtures.driver.uid,
      createdByUserId: roleFixtures.manager.uid,
      createdByRole: 'manager',
    }),
  );

  const managerDb = getAuthedFirestore(
    testEnv,
    managerAuthWithPermissions({vt: true, vd: true, vc: true}),
  );

  await assertSucceeds(getDoc(doc(managerDb, 'reservations', 'reservation-1')));
  await assertSucceeds(
    setDoc(
      doc(managerDb, 'reservations', 'reservation-manager-create'),
      buildInternalStaffReservationFixture({
        clientId: roleFixtures.client.uid,
        assignedDriverId: roleFixtures.driver.uid,
        createdByUserId: roleFixtures.manager.uid,
        createdByRole: 'manager',
      }),
    ),
  );
  await assertSucceeds(
    updateDoc(doc(managerDb, 'reservations', 'reservation-manager-create'), {
      status: 'cancelled',
      updatedAt: serverTimestamp(),
    }),
  );
});

test('manager sem vt, vd e vc não consegue aceder a reservas operacionais', async () => {
  await Promise.all([
    seedRole(roleFixtures.client),
    seedRole(roleFixtures.driver),
    seedRole(roleFixtures.manager),
  ]);

  await seedDocument(
    testEnv,
    ['reservations', 'reservation-1'],
    buildInternalStaffReservationFixture({
      clientId: roleFixtures.client.uid,
      assignedDriverId: roleFixtures.driver.uid,
      createdByUserId: roleFixtures.admin.uid,
      createdByRole: 'admin',
    }),
  );

  const managerDb = getAuthedFirestore(
    testEnv,
    managerAuthWithPermissions({vt: true, vd: true}),
  );

  await assertFails(getDoc(doc(managerDb, 'reservations', 'reservation-1')));
  await assertFails(
    setDoc(
      doc(managerDb, 'reservations', 'reservation-manager-denied'),
      buildInternalStaffReservationFixture({
        clientId: roleFixtures.client.uid,
        assignedDriverId: roleFixtures.driver.uid,
        createdByUserId: roleFixtures.manager.uid,
        createdByRole: 'manager',
      }),
    ),
  );
});

test('motorista consegue ler a reserva que lhe foi atribuída', async () => {
  await Promise.all([
    seedRole(roleFixtures.client),
    seedRole(roleFixtures.driver),
    seedRole(roleFixtures.admin),
  ]);

  await seedDocument(
    testEnv,
    ['reservations', 'reservation-1'],
    buildInternalStaffReservationFixture({
      clientId: roleFixtures.client.uid,
      assignedDriverId: roleFixtures.driver.uid,
      createdByUserId: roleFixtures.admin.uid,
      createdByRole: 'admin',
    }),
  );

  const driverDb = getAuthedFirestore(testEnv, roleFixtures.driver);

  await assertSucceeds(getDoc(doc(driverDb, 'reservations', 'reservation-1')));
});

test('motorista consegue consultar eventos diários que lhe pertencem', async () => {
  await Promise.all([
    seedRole(roleFixtures.driver),
    seedRole(roleFixtures.admin),
  ]);

  await Promise.all([
    seedDocument(testEnv, ['events', 'event-driver-1'], {
      targetType: 'driver',
      targetIds: [roleFixtures.driver.uid],
      title: 'Motorista alvo',
      message: 'Mensagem',
      scheduledAt: Timestamp.fromDate(new Date('2026-04-01T08:00:00Z')),
      reminderOffsetsMinutes: [15],
      createdByAdminId: roleFixtures.admin.uid,
      status: 'scheduled',
      createdAt: seededTimestamp,
      updatedAt: seededTimestamp,
    }),
    seedDocument(testEnv, ['events', 'event-driver-other'], {
      targetType: 'driver',
      targetIds: ['driver-2'],
      title: 'Outro motorista',
      message: 'Mensagem',
      scheduledAt: Timestamp.fromDate(new Date('2026-04-01T09:00:00Z')),
      reminderOffsetsMinutes: [15],
      createdByAdminId: roleFixtures.admin.uid,
      status: 'scheduled',
      createdAt: seededTimestamp,
      updatedAt: seededTimestamp,
    }),
  ]);

  const driverDb = getAuthedFirestore(testEnv, roleFixtures.driver);
  const driverDailyEventsQuery = query(
    collection(driverDb, 'events'),
    where('targetType', '==', 'driver'),
    where('targetIds', 'array-contains', roleFixtures.driver.uid),
    where('status', '==', 'scheduled'),
    where('scheduledAt', '>=', Timestamp.fromDate(new Date('2026-04-01T00:00:00Z'))),
    where('scheduledAt', '<=', Timestamp.fromDate(new Date('2026-04-01T23:59:59Z'))),
    orderBy('scheduledAt'),
  );

  await assertSucceeds(getDocs(driverDailyEventsQuery));
});

test('motorista não consegue consultar eventos diários de outro motorista', async () => {
  await Promise.all([
    seedRole(roleFixtures.driver),
    seedRole({ uid: 'driver-2', role: 'driver' }),
    seedRole(roleFixtures.admin),
  ]);

  await seedDocument(testEnv, ['events', 'event-driver-other'], {
    targetType: 'driver',
    targetIds: ['driver-2'],
    title: 'Outro motorista',
    message: 'Mensagem',
    scheduledAt: Timestamp.fromDate(new Date('2026-04-01T09:00:00Z')),
    reminderOffsetsMinutes: [15],
    createdByAdminId: roleFixtures.admin.uid,
    status: 'scheduled',
    createdAt: seededTimestamp,
    updatedAt: seededTimestamp,
  });

  const driverDb = getAuthedFirestore(testEnv, roleFixtures.driver);
  const otherDriverEventsQuery = query(
    collection(driverDb, 'events'),
    where('targetType', '==', 'driver'),
    where('targetIds', 'array-contains', 'driver-2'),
    where('status', '==', 'scheduled'),
    where('scheduledAt', '>=', Timestamp.fromDate(new Date('2026-04-01T00:00:00Z'))),
    where('scheduledAt', '<=', Timestamp.fromDate(new Date('2026-04-01T23:59:59Z'))),
    orderBy('scheduledAt'),
  );

  await assertFails(getDocs(otherDriverEventsQuery));
});

test('reserva package mantém contrato source-aware sem createdBy e não fica visível para manager', async () => {
  await Promise.all([
    seedRole(roleFixtures.client),
    seedRole(roleFixtures.driver),
    seedRole(roleFixtures.admin),
    seedRole(roleFixtures.manager),
  ]);

  await seedDocument(
    testEnv,
    ['reservations', 'reservation-package-1'],
    buildPackageReservationFixture({
      clientId: roleFixtures.client.uid,
      assignedDriverId: roleFixtures.driver.uid,
    }),
  );

  const adminDb = getAuthedFirestore(testEnv, roleFixtures.admin);
  const managerDb = getAuthedFirestore(
    testEnv,
    managerAuthWithPermissions({vt: true, vd: true, vc: true}),
  );

  await assertSucceeds(getDoc(doc(adminDb, 'reservations', 'reservation-package-1')));
  await assertFails(getDoc(doc(managerDb, 'reservations', 'reservation-package-1')));
});

test('usa precedência de claims: token manager vence user doc client', async () => {
  const tokenManagerUser = { uid: 'token-manager-user', role: 'client' };

  await Promise.all([
    seedRole(roleFixtures.client),
    seedRole(roleFixtures.driver),
    seedRole(tokenManagerUser)
  ]);

  await seedDocument(
    testEnv,
    ['trips', 'trip-claims-precedence'],
    {
      ...buildTripFixture({
        clientId: roleFixtures.client.uid,
        assignedDriverId: roleFixtures.driver.uid,
        status: 'REQUESTED'
      }),
      clientSupport: {
        displayName: 'Cliente Um',
        phone: '+351910000001'
      }
    }
  );

  const managerFromTokenDb = getAuthedFirestore(testEnv, {
    uid: tokenManagerUser.uid,
    token: { role: 'manager', mp: { vt: true, ts: true } }
  });

  await assertSucceeds(getDoc(doc(managerFromTokenDb, 'trips', 'trip-claims-precedence')));
  await assertSucceeds(
    updateDoc(doc(managerFromTokenDb, 'trips', 'trip-claims-precedence'), {
      supportNote: 'Apoio contactou cliente',
      supportStatus: 'IN_REVIEW',
      supportUpdatedBy: tokenManagerUser.uid,
      supportUpdatedAt: serverTimestamp(),
      updatedAt: serverTimestamp()
    })
  );
});

test('usa fallback para users/{uid}.role quando token role não existe e mp está presente', async () => {
  await Promise.all([
    seedRole(roleFixtures.client),
    seedRole(roleFixtures.driver),
    seedRole(roleFixtures.manager)
  ]);

  await seedDocument(
    testEnv,
    ['trips', 'trip-doc-fallback'],
    {
      ...buildTripFixture({
        clientId: roleFixtures.client.uid,
        assignedDriverId: roleFixtures.driver.uid,
        status: 'REQUESTED'
      }),
      clientSupport: {
        displayName: 'Cliente Um',
        phone: '+351910000001'
      }
    }
  );

  const managerDb = getAuthedFirestore(testEnv, {
    uid: roleFixtures.manager.uid,
    token: {
      mp: { vt: true, ts: true }
    }
  });

  await assertSucceeds(getDoc(doc(managerDb, 'trips', 'trip-doc-fallback')));
  await assertSucceeds(
    updateDoc(doc(managerDb, 'trips', 'trip-doc-fallback'), {
      supportNote: 'Fallback por user doc',
      supportStatus: 'OPEN',
      supportUpdatedBy: roleFixtures.manager.uid,
      supportUpdatedAt: serverTimestamp(),
      updatedAt: serverTimestamp()
    })
  );
});

test('manager pode atualizar apenas campos support* em trips', async () => {
  await Promise.all([
    seedRole(roleFixtures.client),
    seedRole(roleFixtures.driver),
    seedRole(roleFixtures.manager)
  ]);

  await seedDocument(
    testEnv,
    ['trips', 'trip-support-only'],
    {
      ...buildTripFixture({
        clientId: roleFixtures.client.uid,
        assignedDriverId: roleFixtures.driver.uid,
        status: 'REQUESTED'
      }),
      clientSupport: {
        displayName: 'Cliente Um',
        phone: '+351910000001'
      }
    }
  );

  const managerDb = getAuthedFirestore(
    testEnv,
    managerAuthWithPermissions({ ts: true }),
  );

  await assertSucceeds(
    updateDoc(doc(managerDb, 'trips', 'trip-support-only'), {
      supportNote: 'Nota operacional',
      supportStatus: 'ESCALATED',
      supportUpdatedBy: roleFixtures.manager.uid,
      supportUpdatedAt: serverTimestamp(),
      updatedAt: serverTimestamp()
    })
  );

  await assertFails(
    updateDoc(doc(managerDb, 'trips', 'trip-support-only'), {
      status: 'CANCELLED_BY_CLIENT',
      supportUpdatedBy: roleFixtures.manager.uid,
      supportUpdatedAt: serverTimestamp(),
      updatedAt: serverTimestamp()
    })
  );

  await assertFails(
    updateDoc(doc(managerDb, 'trips', 'trip-support-only'), {
      pricingSnapshot: {
        baseCents: 999
      },
      supportUpdatedBy: roleFixtures.manager.uid,
      supportUpdatedAt: serverTimestamp(),
      updatedAt: serverTimestamp()
    })
  );

  await assertFails(
    updateDoc(doc(managerDb, 'trips', 'trip-support-only'), {
      paymentStatus: 'REFUNDED',
      supportUpdatedBy: roleFixtures.manager.uid,
      supportUpdatedAt: serverTimestamp(),
      updatedAt: serverTimestamp()
    })
  );

  await assertFails(
    updateDoc(doc(managerDb, 'trips', 'trip-support-only'), {
      clientSupport: {
        displayName: 'Alterado',
        phone: '+351910000099'
      },
      supportUpdatedBy: roleFixtures.manager.uid,
      supportUpdatedAt: serverTimestamp(),
      updatedAt: serverTimestamp()
    })
  );
});

test('enforce invariantes anti-spoofing em updates support do manager', async () => {
  await Promise.all([
    seedRole(roleFixtures.client),
    seedRole(roleFixtures.driver),
    seedRole(roleFixtures.manager)
  ]);

  await seedDocument(
    testEnv,
    ['trips', 'trip-support-invariants'],
    {
      ...buildTripFixture({
        clientId: roleFixtures.client.uid,
        assignedDriverId: roleFixtures.driver.uid,
        status: 'REQUESTED'
      }),
      clientSupport: {
        displayName: 'Cliente Um',
        phone: '+351910000001'
      }
    }
  );

  const managerDb = getAuthedFirestore(
    testEnv,
    managerAuthWithPermissions({ ts: true }),
  );

  await assertFails(
    updateDoc(doc(managerDb, 'trips', 'trip-support-invariants'), {
      supportNote: 'Tentativa spoof uid',
      supportStatus: 'OPEN',
      supportUpdatedBy: roleFixtures.admin.uid,
      supportUpdatedAt: serverTimestamp(),
      updatedAt: serverTimestamp()
    })
  );

  await assertFails(
    updateDoc(doc(managerDb, 'trips', 'trip-support-invariants'), {
      supportNote: 'Tentativa spoof tempo suporte',
      supportStatus: 'OPEN',
      supportUpdatedBy: roleFixtures.manager.uid,
      supportUpdatedAt: Timestamp.fromDate(new Date('2024-01-02T00:00:00Z')),
      updatedAt: serverTimestamp()
    })
  );

  await assertFails(
    updateDoc(doc(managerDb, 'trips', 'trip-support-invariants'), {
      supportNote: 'Tentativa spoof tempo update',
      supportStatus: 'OPEN',
      supportUpdatedBy: roleFixtures.manager.uid,
      supportUpdatedAt: serverTimestamp(),
      updatedAt: Timestamp.fromDate(new Date('2024-01-02T00:00:00Z'))
    })
  );
});

test('valida criação de viagens por função', async () => {
  await Promise.all(tripCreateFixtures.map((fixture) => seedRole(fixture)));

  await Promise.all(
    tripCreateFixtures.map(async (fixture) => {
      const db = getAuthedFirestore(testEnv, fixture);
      const tripData = buildTripFixture({
        clientId: fixture.uid,
        assignedDriverId: roleFixtures.driver.uid,
        status: 'REQUESTED'
      });
      const action = setDoc(doc(db, 'trips', `trip-create-${fixture.uid}`), tripData);

      if (fixture.shouldAllow) {
        await assertSucceeds(action);
      } else {
        await assertFails(action);
      }
    })
  );
});

test('bloqueia updates diretos de condutor em trips e mantém admin autorizado', async () => {
  await Promise.all([
    seedRole(roleFixtures.client),
    seedRole(roleFixtures.driver),
    seedRole(roleFixtures.admin)
  ]);

  await seedDocument(
    testEnv,
    ['trips', 'trip-3'],
    buildTripFixture({
      clientId: roleFixtures.client.uid,
      assignedDriverId: roleFixtures.driver.uid,
      status: 'DRIVER_ASSIGNED_WAITING_ACCEPTANCE'
    })
  );

  const driverDb = getAuthedFirestore(testEnv, roleFixtures.driver);
  const adminDb = getAuthedFirestore(testEnv, roleFixtures.admin);

  await assertFails(
    updateDoc(doc(driverDb, 'trips', 'trip-3'), {
      status: 'DRIVER_ACCEPTED',
      driverAcceptedAt: Timestamp.fromDate(new Date('2024-01-02T00:00:00Z')),
      updatedAt: Timestamp.fromDate(new Date('2024-01-02T00:00:00Z'))
    })
  );

  await assertSucceeds(
    updateDoc(doc(adminDb, 'trips', 'trip-3'), {
      status: 'DRIVER_ACCEPTED',
      driverAcceptedAt: Timestamp.fromDate(new Date('2024-01-02T00:00:00Z')),
      updatedAt: Timestamp.fromDate(new Date('2024-01-02T00:00:00Z'))
    })
  );
});

test('permite update de meteringSnapshot apenas ao condutor atribuído e em estados permitidos', async () => {
  const otherDriver = { uid: 'driver-2', role: 'driver' };

  await Promise.all([
    seedRole(roleFixtures.client),
    seedRole(roleFixtures.driver),
    seedRole(otherDriver)
  ]);

  await seedDocument(
    testEnv,
    ['trips', 'trip-metering-allowed'],
    buildTripFixture({
      clientId: roleFixtures.client.uid,
      assignedDriverId: roleFixtures.driver.uid,
      status: 'DRIVER_ARRIVED'
    })
  );

  await seedDocument(
    testEnv,
    ['trips', 'trip-metering-blocked-state'],
    buildTripFixture({
      clientId: roleFixtures.client.uid,
      assignedDriverId: roleFixtures.driver.uid,
      status: 'DRIVER_EN_ROUTE'
    })
  );

  const driverDb = getAuthedFirestore(testEnv, roleFixtures.driver);
  const otherDriverDb = getAuthedFirestore(testEnv, otherDriver);

  await assertSucceeds(
    updateDoc(doc(driverDb, 'trips', 'trip-metering-allowed'), {
      meteringSnapshot: {
        totalMinutes: 3,
        totalWaitMinutes: 1,
        totalDistanceKm: 0.8,
        estimatedCostMinor: 540,
        lastUpdatedAt: serverTimestamp()
      }
    })
  );

  await assertFails(
    updateDoc(doc(driverDb, 'trips', 'trip-metering-allowed'), {
      meteringSnapshot: {
        totalMinutes: 4,
        totalWaitMinutes: 1,
        totalDistanceKm: 1.1,
        estimatedCostMinor: 620,
        lastUpdatedAt: serverTimestamp()
      },
      updatedAt: serverTimestamp()
    })
  );

  await assertFails(
    updateDoc(doc(driverDb, 'trips', 'trip-metering-blocked-state'), {
      meteringSnapshot: {
        totalMinutes: 1,
        totalWaitMinutes: 0,
        totalDistanceKm: 0.2,
        estimatedCostMinor: 120,
        lastUpdatedAt: serverTimestamp()
      }
    })
  );

  await assertFails(
    updateDoc(doc(otherDriverDb, 'trips', 'trip-metering-allowed'), {
      meteringSnapshot: {
        totalMinutes: 2,
        totalWaitMinutes: 0,
        totalDistanceKm: 0.5,
        estimatedCostMinor: 300,
        lastUpdatedAt: serverTimestamp()
      }
    })
  );
});

test('manager pode gerir estado operacional de condutor e viatura sem alterar roles', async () => {
  await Promise.all([
    seedRole(roleFixtures.manager),
    seedRole(roleFixtures.driver)
  ]);

  await seedDocument(testEnv, ['driverStatus', roleFixtures.driver.uid], {
    isActive: true,
    isAvailable: true,
    availabilityEnabled: true,
    currentTripId: null,
    updatedAt: seededTimestamp
  });

  await seedDocument(testEnv, ['driverVehicleAssignments', roleFixtures.driver.uid], {
    vehicleId: 'vehicle-1',
    updatedAt: seededTimestamp
  });

  await seedDocument(testEnv, ['vehicles', 'vehicle-1'], {
    ownerDriverId: roleFixtures.driver.uid,
    plate: '00-AA-00',
    isActive: true,
    updatedAt: seededTimestamp
  });

  const managerDb = getAuthedFirestore(
    testEnv,
    managerAuthWithPermissions({ ed: true, av: true }),
  );

  await assertSucceeds(
    updateDoc(doc(managerDb, 'users', roleFixtures.driver.uid), {
      name: 'Condutor Operacional',
      isActive: false,
      updatedAt: serverTimestamp()
    })
  );

  await assertSucceeds(
    updateDoc(doc(managerDb, 'driverStatus', roleFixtures.driver.uid), {
      isActive: false,
      isAvailable: false,
      availabilityEnabled: false,
      updatedAt: serverTimestamp()
    })
  );

  await assertSucceeds(
    updateDoc(doc(managerDb, 'driverVehicleAssignments', roleFixtures.driver.uid), {
      vehicleId: 'vehicle-2',
      updatedAt: serverTimestamp()
    })
  );

  await assertSucceeds(
    deleteDoc(doc(managerDb, 'driverVehicleAssignments', roleFixtures.driver.uid))
  );

  await assertSucceeds(
    updateDoc(doc(managerDb, 'vehicles', 'vehicle-1'), {
      isActive: false,
      updatedAt: serverTimestamp()
    })
  );

  await assertFails(
    updateDoc(doc(managerDb, 'users', roleFixtures.driver.uid), {
      role: 'manager',
      updatedAt: serverTimestamp()
    })
  );

  await assertFails(
    setDoc(doc(managerDb, 'users', 'new-user-created-by-manager'), {
      role: 'client',
      name: 'Novo',
      phone: '+351900000010',
      email: 'novo@local.pt',
      isActive: true,
      createdAt: seededTimestamp,
      updatedAt: seededTimestamp
    })
  );

  await assertFails(deleteDoc(doc(managerDb, 'users', roleFixtures.driver.uid)));
});

test('restringe ajustes de saldo apenas a admin', async () => {
  await Promise.all(balanceWriteFixtures.map((fixture) => seedRole(fixture)));

  await Promise.all(
    balanceWriteFixtures.map(async (fixture) => {
      const db = getAuthedFirestore(testEnv, fixture);
      const action = setDoc(doc(db, 'balances', fixture.uid), {
        balanceCents: 2500,
        debtLimitCents: -2000,
        createdAt: Timestamp.fromDate(new Date('2024-01-02T00:00:00Z')),
        updatedAt: Timestamp.fromDate(new Date('2024-01-02T00:00:00Z'))
      });

      if (fixture.shouldAllow) {
        await assertSucceeds(action);
      } else {
        await assertFails(action);
      }
    })
  );
});

test('manager pode ler config de moeda mas não editar', async () => {
  await seedRole(roleFixtures.manager);

  await seedDocument(testEnv, ['config', 'currency'], {
    cveToEur: '0.009069',
    cveToUsd: '0.0099',
    updatedAt: seededTimestamp,
    updatedBy: roleFixtures.admin.uid,
  });

  const managerDb = getAuthedFirestore(
    testEnv,
    managerAuthWithPermissions({ vr: true, mt: true }),
  );

  await assertSucceeds(getDoc(doc(managerDb, 'config', 'currency')));
  await assertFails(
    setDoc(doc(managerDb, 'config', 'currency'), {
      cveToEur: '0.0091',
      cveToUsd: '0.01',
      updatedAt: serverTimestamp(),
      updatedBy: roleFixtures.manager.uid,
    })
  );
});

test('manager não pode aceder coleções de auditoria e finanças administrativas', async () => {
  await Promise.all([
    seedRole(roleFixtures.manager),
    seedRole(roleFixtures.admin),
  ]);

  await seedDocument(testEnv, ['audit', 'audit-1'], {
    actionType: 'trip_state_transition',
    adminId: roleFixtures.admin.uid,
    createdAt: seededTimestamp,
  });

  await seedDocument(testEnv, ['balance_adjustments', 'adj-1'], {
    clientId: roleFixtures.client.uid,
    reason: 'manual_adjustment',
    createdAt: seededTimestamp,
  });

  const managerDb = getAuthedFirestore(testEnv, roleFixtures.manager);

  await assertFails(getDoc(doc(managerDb, 'audit', 'audit-1')));
  await assertFails(
    setDoc(doc(managerDb, 'audit', 'audit-created-by-manager'), {
      actionType: 'trip_cancelled',
      adminId: roleFixtures.manager.uid,
      createdAt: seededTimestamp,
    }),
  );

  await assertFails(getDoc(doc(managerDb, 'balance_adjustments', 'adj-1')));
  await assertFails(
    setDoc(doc(managerDb, 'balance_adjustments', 'adj-created-by-manager'), {
      clientId: roleFixtures.client.uid,
      reason: 'manual_adjustment',
      createdAt: seededTimestamp,
    }),
  );
});

test('aplica split de docs públicos/admin para tarifas e config de cancelamento', async () => {
  await Promise.all([
    seedRole(roleFixtures.client),
    seedRole(roleFixtures.driver),
    seedRole(roleFixtures.manager),
    seedRole(roleFixtures.admin)
  ]);

  await seedDocument(
    testEnv,
    ['config', 'cancellation_policy_public'],
    cancellationPolicyPublicFixture
  );

  await seedDocument(
    testEnv,
    ['config', 'cancellation_policy_admin'],
    cancellationPolicyAdminFixture
  );

  await seedDocument(
    testEnv,
    ['tariffs', 'public_default'],
    publicTariffFixture
  );

  await seedDocument(
    testEnv,
    ['tariffs', 'admin_default'],
    adminTariffFixture
  );

  await seedDocument(
    testEnv,
    ['transport_types', 'standard'],
    {
      name: 'Standard',
      description: 'Viagens do dia a dia com conforto.',
      createdAt: seededTimestamp,
      updatedAt: seededTimestamp,
    }
  );

  const clientDb = getAuthedFirestore(testEnv, roleFixtures.client);
  const driverDb = getAuthedFirestore(testEnv, roleFixtures.driver);
  const managerDb = getAuthedFirestore(testEnv, roleFixtures.manager);
  const managerTariffsDb = getAuthedFirestore(
    testEnv,
    managerAuthWithPermissions({ mt: true }),
  );
  const adminDb = getAuthedFirestore(testEnv, roleFixtures.admin);
  const unauthedDb = getUnauthedFirestore(testEnv);

  await assertSucceeds(getDoc(doc(clientDb, 'config', 'cancellation_policy_public')));
  await assertSucceeds(getDoc(doc(driverDb, 'config', 'cancellation_policy_public')));
  await assertSucceeds(getDoc(doc(adminDb, 'config', 'cancellation_policy_public')));
  await assertFails(getDoc(doc(managerDb, 'config', 'cancellation_policy_public')));
  await assertFails(getDoc(doc(unauthedDb, 'config', 'cancellation_policy_public')));

  await assertSucceeds(getDoc(doc(adminDb, 'config', 'cancellation_policy_admin')));
  await assertFails(getDoc(doc(clientDb, 'config', 'cancellation_policy_admin')));
  await assertFails(getDoc(doc(managerDb, 'config', 'cancellation_policy_admin')));

  await assertSucceeds(getDoc(doc(clientDb, 'tariffs', 'public_default')));
  await assertSucceeds(getDoc(doc(driverDb, 'tariffs', 'public_default')));
  await assertSucceeds(getDoc(doc(adminDb, 'tariffs', 'public_default')));
  await assertFails(getDoc(doc(managerDb, 'tariffs', 'public_default')));
  await assertFails(getDoc(doc(managerTariffsDb, 'tariffs', 'public_default')));

  await assertSucceeds(getDoc(doc(adminDb, 'tariffs', 'admin_default')));
  await assertFails(getDoc(doc(clientDb, 'tariffs', 'admin_default')));
  await assertFails(getDoc(doc(managerDb, 'tariffs', 'admin_default')));
  await assertSucceeds(getDoc(doc(managerTariffsDb, 'tariffs', 'admin_default')));

  await assertFails(
    updateDoc(doc(adminDb, 'tariffs', 'admin_default'), {
      updatedAt: serverTimestamp(),
    }),
  );
  await assertFails(
    updateDoc(doc(adminDb, 'transport_types', 'standard'), {
      updatedAt: serverTimestamp(),
    }),
  );
});

test('bloqueia self-promotion de role no perfil do cliente', async () => {
  await seedRole(roleFixtures.client);

  const clientDb = getAuthedFirestore(testEnv, roleFixtures.client);

  await assertSucceeds(
    updateDoc(doc(clientDb, 'users', roleFixtures.client.uid), {
      uiCurrency: 'EUR',
      updatedAt: serverTimestamp()
    })
  );

  await assertFails(
    updateDoc(doc(clientDb, 'users', roleFixtures.client.uid), {
      role: 'manager',
      updatedAt: serverTimestamp()
    })
  );
});

test('protege users de condutor e expõe apenas driversPublic com leitura operacional do manager', async () => {
  const otherClient = { uid: 'client-2', role: 'client' };

  await Promise.all([
    seedRole(roleFixtures.driver),
    seedRole(roleFixtures.client),
    seedRole(roleFixtures.manager),
    seedRole(otherClient),
    seedRole(roleFixtures.admin)
  ]);

  await seedDocument(testEnv, ['users', roleFixtures.driver.uid], {
    role: 'driver',
    name: 'Condutor Privado',
    phone: '+351900000000',
    email: 'driver@local.pt',
    isActive: true,
    createdAt: seededTimestamp,
    updatedAt: seededTimestamp
  });

  await seedDocument(testEnv, ['driversPublic', roleFixtures.driver.uid], {
    initials: 'CP',
    displayName: 'CP',
    rating: 4.9,
    updatedAt: seededTimestamp
  });

  const clientDb = getAuthedFirestore(testEnv, roleFixtures.client);
  const managerDb = getAuthedFirestore(
    testEnv,
    managerAuthWithPermissions({ vd: true }),
  );
  const otherDb = getAuthedFirestore(testEnv, otherClient);
  const adminDb = getAuthedFirestore(testEnv, roleFixtures.admin);

  await assertFails(getDoc(doc(clientDb, 'users', roleFixtures.driver.uid)));
  await assertSucceeds(getDoc(doc(managerDb, 'users', roleFixtures.driver.uid)));
  await assertFails(getDoc(doc(otherDb, 'users', roleFixtures.driver.uid)));
  await assertSucceeds(getDoc(doc(adminDb, 'users', roleFixtures.driver.uid)));

  await assertSucceeds(getDoc(doc(clientDb, 'driversPublic', roleFixtures.driver.uid)));
  await assertSucceeds(getDoc(doc(otherDb, 'driversPublic', roleFixtures.driver.uid)));
});

test('expõe config de suporte, mercado e ajustes de saldo com permissões corretas', async () => {
  await Promise.all([
    seedRole(roleFixtures.client),
    seedRole(roleFixtures.driver),
    seedRole(roleFixtures.manager),
    seedRole(roleFixtures.admin),
  ]);

  await seedDocument(testEnv, ['config', 'support'], {
    supportPhone: '+351900000000',
    updatedAt: seededTimestamp,
  });

  await seedDocument(testEnv, ['config', 'market'], {
    activityMapLabel: 'Lisboa',
    fuelCostPerLiter: { amountMinor: 180, currency: 'EUR' },
    updatedAt: seededTimestamp,
  });

  await seedDocument(testEnv, ['balance_adjustments', 'adj-client'], {
    clientId: roleFixtures.client.uid,
    reason: 'manual_adjustment',
    createdAt: seededTimestamp,
  });

  const clientDb = getAuthedFirestore(testEnv, roleFixtures.client);
  const driverDb = getAuthedFirestore(testEnv, roleFixtures.driver);
  const managerDb = getAuthedFirestore(testEnv, roleFixtures.manager);
  const adminDb = getAuthedFirestore(testEnv, roleFixtures.admin);

  await assertSucceeds(getDoc(doc(clientDb, 'config', 'support')));
  await assertSucceeds(getDoc(doc(driverDb, 'config', 'support')));
  await assertFails(getDoc(doc(managerDb, 'config', 'support')));

  await assertSucceeds(getDoc(doc(adminDb, 'config', 'market')));
  await assertFails(getDoc(doc(clientDb, 'config', 'market')));
  await assertFails(getDoc(doc(driverDb, 'config', 'market')));

  await assertSucceeds(getDoc(doc(clientDb, 'balance_adjustments', 'adj-client')));
  await assertFails(getDoc(doc(managerDb, 'balance_adjustments', 'adj-client')));
  await assertSucceeds(getDoc(doc(adminDb, 'balance_adjustments', 'adj-client')));
});
