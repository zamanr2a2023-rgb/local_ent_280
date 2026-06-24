function minutesAgo(baseDate, minutes) {
  return new Date(baseDate.getTime() - minutes * 60 * 1000);
}

function minutesFromNow(baseDate, minutes) {
  return new Date(baseDate.getTime() + minutes * 60 * 1000);
}

function buildLocationSample({
  latitude,
  longitude,
  recordedAt,
  heading,
  speed,
}) {
  return {
    latitude,
    longitude,
    recordedAt,
    ...(heading != null ? {heading} : {}),
    ...(speed != null ? {speed} : {}),
  };
}

function buildIncidentEvent({
  id,
  action,
  actorId,
  actorRole,
  createdAt,
  note,
  metadata,
}) {
  return {
    id,
    data: {
      action,
      actorId,
      actorRole,
      createdAt,
      ...(note ? {note} : {}),
      ...(metadata ? {metadata} : {}),
    },
  };
}

async function upsertIncidentScenario(firestore, incident) {
  const incidentRef = firestore.doc(`operationalIncidents/${incident.id}`);
  await incidentRef.set(incident.data, {merge: true});

  for (const event of incident.events) {
    await incidentRef.collection('events').doc(event.id).set(event.data, {merge: true});
  }

  console.log(`Seed MVP: incidente operacional ${incident.id} gravado.`);
}

async function upsertApprovalScenario(firestore, approval) {
  await firestore
    .doc(`operationalMovementApprovals/${approval.id}`)
    .set(approval.data, {merge: true});
  console.log(`Seed MVP: aprovação operacional ${approval.id} gravada.`);
}

async function upsertDriverOperationalState(firestore, state) {
  await firestore
    .doc(`driverOperationalStates/${state.driverId}`)
    .set(state.data, {merge: true});
  console.log(`Seed MVP: estado operacional ${state.driverId} gravado.`);
}

function buildOperationalMonitoringScenarios({
  driverIds,
  driverProfiles,
  managerId,
  adminId,
  vehicle,
  now = new Date(),
}) {
  const driverOneId = driverIds.driverOne;
  const driverTwoId = driverIds.driverTwo;
  const driverOneName = driverProfiles.driverOne.name;
  const driverTwoName = driverProfiles.driverTwo.name;

  const incidentRouteDeviationStartedAt = minutesAgo(now, 48);
  const incidentRouteDeviationUpdatedAt = minutesAgo(now, 8);
  const incidentPostDropoffStartedAt = minutesAgo(now, 124);
  const incidentPostDropoffDropoffAt = minutesAgo(now, 132);
  const incidentPostDropoffAcknowledgedAt = minutesAgo(now, 105);
  const incidentApprovedStartedAt = minutesAgo(now, 210);
  const incidentApprovedResolvedAt = minutesAgo(now, 165);
  const incidentDismissedStartedAt = minutesAgo(now, 390);
  const incidentDismissedResolvedAt = minutesAgo(now, 352);
  const incidentConfirmedStartedAt = minutesAgo(now, 560);
  const incidentConfirmedResolvedAt = minutesAgo(now, 511);

  const incidents = [
    {
      id: 'incident_ops_active_trip_open',
      data: {
        operationalWindowId: 'trip:trip_ops_route_deviation:active:20260330',
        operationalWindowType: 'active_trip',
        driverId: driverOneId,
        driverName: driverOneName,
        vehicleId: vehicle.id,
        vehiclePlate: vehicle.plate,
        tripId: 'trip_ops_route_deviation',
        incidentType: 'active_trip_route_deviation',
        status: 'open',
        currentState: 'on_active_trip',
        startedAt: incidentRouteDeviationStartedAt,
        originCoordinates: buildLocationSample({
          latitude: 38.7223,
          longitude: -9.1393,
          recordedAt: incidentRouteDeviationStartedAt,
        }),
        latestCoordinates: buildLocationSample({
          latitude: 38.7486,
          longitude: -9.1542,
          recordedAt: incidentRouteDeviationUpdatedAt,
          heading: 52,
          speed: 38,
        }),
        expectedPolyline: 'k}ikFr_xv@sv@b`@sv@n_@ct@nZ',
        actualPathSamples: [
          buildLocationSample({
            latitude: 38.7223,
            longitude: -9.1393,
            recordedAt: incidentRouteDeviationStartedAt,
          }),
          buildLocationSample({
            latitude: 38.7342,
            longitude: -9.1454,
            recordedAt: minutesAgo(now, 28),
            heading: 40,
            speed: 31,
          }),
          buildLocationSample({
            latitude: 38.7486,
            longitude: -9.1542,
            recordedAt: incidentRouteDeviationUpdatedAt,
            heading: 52,
            speed: 38,
          }),
        ],
        expectedTripDistanceKm: 7.8,
        actualTripDistanceKm: 11.1,
        tripDistanceVarianceKm: 3.3,
        tripDistanceVariancePct: 42.3,
        totalExpectedDistanceKm: 7.8,
        totalActualDistanceKm: 11.1,
        totalVarianceKm: 3.3,
        totalVariancePct: 42.3,
        tripStartedAt: minutesAgo(now, 54),
        createdAt: incidentRouteDeviationStartedAt,
        updatedAt: incidentRouteDeviationUpdatedAt,
      },
      events: [
        buildIncidentEvent({
          id: 'event_opened',
          action: 'incident_opened',
          actorId: 'system',
          actorRole: 'system',
          createdAt: incidentRouteDeviationStartedAt,
          note: 'Desvio sustentado acima da tolerância configurada.',
          metadata: {
            retentionExpiresAt: minutesFromNow(now, 60 * 24 * 90),
          },
        }),
        buildIncidentEvent({
          id: 'event_latest_sample',
          action: 'telemetry_evidence_updated',
          actorId: 'system',
          actorRole: 'system',
          createdAt: incidentRouteDeviationUpdatedAt,
          metadata: {
            varianceKm: 3.3,
            variancePct: 42.3,
            retentionExpiresAt: minutesFromNow(now, 60 * 24 * 90),
          },
        }),
      ],
    },
    {
      id: 'incident_ops_post_dropoff_acknowledged',
      data: {
        operationalWindowId: 'trip:trip_ops_post_dropoff:postdropoff:20260330',
        operationalWindowType: 'post_dropoff',
        driverId: driverOneId,
        driverName: driverOneName,
        vehicleId: vehicle.id,
        vehiclePlate: vehicle.plate,
        tripId: 'trip_ops_post_dropoff',
        incidentType: 'post_dropoff_unauthorized_movement',
        subreason: 'abandoned_return_to_base',
        status: 'acknowledged',
        currentState: 'returning_to_base',
        startedAt: incidentPostDropoffStartedAt,
        originCoordinates: buildLocationSample({
          latitude: 38.7071,
          longitude: -9.1355,
          recordedAt: incidentPostDropoffStartedAt,
        }),
        latestCoordinates: buildLocationSample({
          latitude: 38.7274,
          longitude: -9.1480,
          recordedAt: minutesAgo(now, 96),
          heading: 335,
          speed: 24,
        }),
        expectedPolyline: 'k~fkFzgwv@ce@v[_l@~Wwj@jW',
        actualPathSamples: [
          buildLocationSample({
            latitude: 38.7071,
            longitude: -9.1355,
            recordedAt: incidentPostDropoffStartedAt,
          }),
          buildLocationSample({
            latitude: 38.7148,
            longitude: -9.1440,
            recordedAt: minutesAgo(now, 113),
            heading: 320,
            speed: 20,
          }),
          buildLocationSample({
            latitude: 38.7274,
            longitude: -9.1480,
            recordedAt: minutesAgo(now, 96),
            heading: 335,
            speed: 24,
          }),
        ],
        expectedPostDropoffDistanceKm: 4.5,
        actualPostDropoffDistanceKm: 7.2,
        postDropoffVarianceKm: 2.7,
        postDropoffVariancePct: 60,
        totalExpectedDistanceKm: 14.1,
        totalActualDistanceKm: 16.8,
        totalVarianceKm: 2.7,
        totalVariancePct: 19.1,
        tripStartedAt: minutesAgo(now, 158),
        dropoffAt: incidentPostDropoffDropoffAt,
        postDropoffWindowStartedAt: incidentPostDropoffStartedAt,
        reviewNote: 'Operação contactou o motorista; regresso à base em curso.',
        createdAt: incidentPostDropoffStartedAt,
        updatedAt: incidentPostDropoffAcknowledgedAt,
      },
      events: [
        buildIncidentEvent({
          id: 'event_opened',
          action: 'incident_opened',
          actorId: 'system',
          actorRole: 'system',
          createdAt: incidentPostDropoffStartedAt,
          note: 'Movimento pós-serviço excedeu o corredor local permitido.',
          metadata: {
            retentionExpiresAt: minutesFromNow(now, 60 * 24 * 90),
          },
        }),
        buildIncidentEvent({
          id: 'event_acknowledged',
          action: 'acknowledge',
          actorId: managerId,
          actorRole: 'manager',
          createdAt: incidentPostDropoffAcknowledgedAt,
          note: 'Motorista confirmou desvio para abastecimento antes de regressar.',
          metadata: {
            retentionExpiresAt: minutesFromNow(now, 60 * 24 * 90),
          },
        }),
      ],
    },
    {
      id: 'incident_ops_no_trip_approved',
      data: {
        operationalWindowId: 'driver:driver_two:no_trip:20260330',
        operationalWindowType: 'no_trip_operational',
        driverId: driverTwoId,
        driverName: driverTwoName,
        incidentType: 'post_dropoff_unauthorized_movement',
        subreason: 'no_trip_unauthorized_operational_movement',
        status: 'approved',
        currentState: 'approved_reposition',
        startedAt: incidentApprovedStartedAt,
        resolvedAt: incidentApprovedResolvedAt,
        resolutionSource: 'manager',
        resolutionReason: 'approved_exception',
        originCoordinates: buildLocationSample({
          latitude: 38.7369,
          longitude: -9.1427,
          recordedAt: incidentApprovedStartedAt,
        }),
        latestCoordinates: buildLocationSample({
          latitude: 38.7412,
          longitude: -9.1516,
          recordedAt: incidentApprovedResolvedAt,
          heading: 270,
          speed: 12,
        }),
        actualPathSamples: [
          buildLocationSample({
            latitude: 38.7369,
            longitude: -9.1427,
            recordedAt: incidentApprovedStartedAt,
          }),
          buildLocationSample({
            latitude: 38.7398,
            longitude: -9.1464,
            recordedAt: minutesAgo(now, 188),
            heading: 275,
            speed: 16,
          }),
          buildLocationSample({
            latitude: 38.7412,
            longitude: -9.1516,
            recordedAt: incidentApprovedResolvedAt,
            heading: 270,
            speed: 12,
          }),
        ],
        expectedNoTripDistanceKm: 0.8,
        actualNoTripDistanceKm: 2.1,
        noTripVarianceKm: 1.3,
        noTripVariancePct: 162.5,
        totalExpectedDistanceKm: 0.8,
        totalActualDistanceKm: 2.1,
        totalVarianceKm: 1.3,
        totalVariancePct: 162.5,
        reviewNote: 'Reposicionamento temporário aprovado para apoio logístico.',
        createdAt: incidentApprovedStartedAt,
        updatedAt: incidentApprovedResolvedAt,
      },
      events: [
        buildIncidentEvent({
          id: 'event_opened',
          action: 'incident_opened',
          actorId: 'system',
          actorRole: 'system',
          createdAt: incidentApprovedStartedAt,
          note: 'Viatura em deslocação operacional sem viagem ativa.',
          metadata: {
            retentionExpiresAt: minutesFromNow(now, 60 * 24 * 90),
          },
        }),
        buildIncidentEvent({
          id: 'event_approved',
          action: 'approve_exception',
          actorId: managerId,
          actorRole: 'manager',
          createdAt: incidentApprovedResolvedAt,
          note: 'Autorizado reposicionamento até recolha de material na oficina.',
          metadata: {
            retentionExpiresAt: minutesFromNow(now, 60 * 24 * 90),
          },
        }),
      ],
    },
    {
      id: 'incident_ops_post_dropoff_dismissed',
      data: {
        operationalWindowId: 'trip:trip_ops_false_positive:postdropoff:20260329',
        operationalWindowType: 'post_dropoff',
        driverId: driverOneId,
        driverName: driverOneName,
        vehicleId: vehicle.id,
        vehiclePlate: vehicle.plate,
        tripId: 'trip_ops_false_positive',
        incidentType: 'post_dropoff_unauthorized_movement',
        status: 'dismissed',
        currentState: 'at_base',
        startedAt: incidentDismissedStartedAt,
        resolvedAt: incidentDismissedResolvedAt,
        resolutionSource: 'manager',
        resolutionReason: 'false_positive',
        originCoordinates: buildLocationSample({
          latitude: 38.7098,
          longitude: -9.1366,
          recordedAt: incidentDismissedStartedAt,
        }),
        latestCoordinates: buildLocationSample({
          latitude: 38.7223,
          longitude: -9.1393,
          recordedAt: incidentDismissedResolvedAt,
          heading: 18,
          speed: 0,
        }),
        expectedPolyline: 'gogkFvnwv@w`@fEkk@rI',
        actualPathSamples: [
          buildLocationSample({
            latitude: 38.7098,
            longitude: -9.1366,
            recordedAt: incidentDismissedStartedAt,
          }),
          buildLocationSample({
            latitude: 38.7168,
            longitude: -9.1384,
            recordedAt: minutesAgo(now, 370),
            heading: 10,
            speed: 18,
          }),
          buildLocationSample({
            latitude: 38.7223,
            longitude: -9.1393,
            recordedAt: incidentDismissedResolvedAt,
            heading: 18,
            speed: 0,
          }),
        ],
        expectedPostDropoffDistanceKm: 2.1,
        actualPostDropoffDistanceKm: 2.0,
        postDropoffVarianceKm: -0.1,
        postDropoffVariancePct: -4.8,
        totalExpectedDistanceKm: 10.4,
        totalActualDistanceKm: 10.3,
        totalVarianceKm: -0.1,
        totalVariancePct: -1,
        dropoffAt: minutesAgo(now, 401),
        postDropoffWindowStartedAt: incidentDismissedStartedAt,
        baseArrivedAt: incidentDismissedResolvedAt,
        reviewNote: 'Falso positivo validado: telemetria perdeu uma amostra intermédia.',
        createdAt: incidentDismissedStartedAt,
        updatedAt: incidentDismissedResolvedAt,
      },
      events: [
        buildIncidentEvent({
          id: 'event_opened',
          action: 'incident_opened',
          actorId: 'system',
          actorRole: 'system',
          createdAt: incidentDismissedStartedAt,
          note: 'Trajeto temporariamente fora do corredor previsto.',
          metadata: {
            retentionExpiresAt: minutesFromNow(now, 60 * 24 * 90),
          },
        }),
        buildIncidentEvent({
          id: 'event_dismissed',
          action: 'dismiss',
          actorId: managerId,
          actorRole: 'manager',
          createdAt: incidentDismissedResolvedAt,
          note: 'Encerrado como falso positivo após revisão do replay.',
          metadata: {
            retentionExpiresAt: minutesFromNow(now, 60 * 24 * 90),
          },
        }),
      ],
    },
    {
      id: 'incident_ops_active_trip_confirmed',
      data: {
        operationalWindowId: 'trip:trip_ops_confirmed:active:20260329',
        operationalWindowType: 'active_trip',
        driverId: driverTwoId,
        driverName: driverTwoName,
        tripId: 'trip_ops_confirmed',
        incidentType: 'active_trip_route_deviation',
        status: 'confirmed',
        currentState: 'off_duty',
        startedAt: incidentConfirmedStartedAt,
        resolvedAt: incidentConfirmedResolvedAt,
        resolutionSource: 'admin',
        resolutionReason: 'confirmed_after_review',
        originCoordinates: buildLocationSample({
          latitude: 38.7223,
          longitude: -9.1393,
          recordedAt: incidentConfirmedStartedAt,
        }),
        latestCoordinates: buildLocationSample({
          latitude: 38.6935,
          longitude: -9.2057,
          recordedAt: incidentConfirmedResolvedAt,
          heading: 220,
          speed: 0,
        }),
        expectedPolyline: 'k}ikFr_xv@vVzzAbo@vzBrv@neBns@z_B',
        actualPathSamples: [
          buildLocationSample({
            latitude: 38.7223,
            longitude: -9.1393,
            recordedAt: incidentConfirmedStartedAt,
          }),
          buildLocationSample({
            latitude: 38.7078,
            longitude: -9.1721,
            recordedAt: minutesAgo(now, 538),
            heading: 228,
            speed: 44,
          }),
          buildLocationSample({
            latitude: 38.6935,
            longitude: -9.2057,
            recordedAt: incidentConfirmedResolvedAt,
            heading: 220,
            speed: 0,
          }),
        ],
        expectedTripDistanceKm: 6.4,
        actualTripDistanceKm: 14.9,
        tripDistanceVarianceKm: 8.5,
        tripDistanceVariancePct: 132.8,
        totalExpectedDistanceKm: 6.4,
        totalActualDistanceKm: 14.9,
        totalVarianceKm: 8.5,
        totalVariancePct: 132.8,
        tripStartedAt: minutesAgo(now, 571),
        offDutyAt: incidentConfirmedResolvedAt,
        reviewNote: 'Desvio confirmado e encaminhado para follow-up operacional.',
        createdAt: incidentConfirmedStartedAt,
        updatedAt: incidentConfirmedResolvedAt,
      },
      events: [
        buildIncidentEvent({
          id: 'event_opened',
          action: 'incident_opened',
          actorId: 'system',
          actorRole: 'system',
          createdAt: incidentConfirmedStartedAt,
          note: 'Viatura abandonou a rota prevista durante serviço ativo.',
          metadata: {
            retentionExpiresAt: minutesFromNow(now, 60 * 24 * 90),
          },
        }),
        buildIncidentEvent({
          id: 'event_confirmed',
          action: 'confirm',
          actorId: adminId,
          actorRole: 'admin',
          createdAt: incidentConfirmedResolvedAt,
          note: 'Incidente confirmado após revisão operacional e contacto com a equipa.',
          metadata: {
            retentionExpiresAt: minutesFromNow(now, 60 * 24 * 90),
          },
        }),
      ],
    },
  ];

  const approvals = [
    {
      id: 'approval_ops_no_trip_active',
      data: {
        operationalWindowId: 'driver:driver_two:no_trip:20260330',
        operationalWindowType: 'no_trip_operational',
        driverId: driverTwoId,
        driverName: driverTwoName,
        reason: 'Deslocação aprovada para recolha de material operacional',
        expiresAt: minutesFromNow(now, 180),
        approvedBy: managerId,
        approvedByRole: 'manager',
        status: 'active',
        incidentId: 'incident_ops_no_trip_approved',
        allowedArea: {
          label: 'Oficina Lisboa',
          center: {
            latitude: 38.7369,
            longitude: -9.1427,
          },
          radiusMeters: 180,
        },
        createdAt: incidentApprovedResolvedAt,
        updatedAt: incidentApprovedResolvedAt,
      },
    },
  ];

  const states = [
    {
      driverId: driverOneId,
      data: {
        driverId: driverOneId,
        driverName: driverOneName,
        vehicleId: vehicle.id,
        vehiclePlate: vehicle.plate,
        tripId: 'trip_ops_post_dropoff',
        linkedTripId: 'trip_ops_post_dropoff',
        operationalWindowId: 'trip:trip_ops_post_dropoff:postdropoff:20260330',
        operationalWindowType: 'post_dropoff',
        currentState: 'post_dropoff_waiting',
        latestLocation: buildLocationSample({
          latitude: 38.7274,
          longitude: -9.1480,
          recordedAt: minutesAgo(now, 6),
          heading: 355,
          speed: 0,
        }),
        lastProcessedRtdbTimestamp: minutesAgo(now, 6),
        updatedAt: minutesAgo(now, 6),
      },
    },
    {
      driverId: driverTwoId,
      data: {
        driverId: driverTwoId,
        driverName: driverTwoName,
        operationalWindowId: 'driver:driver_two:no_trip:20260330',
        operationalWindowType: 'no_trip_operational',
        currentState: 'operational_idle',
        latestLocation: buildLocationSample({
          latitude: 38.7412,
          longitude: -9.1516,
          recordedAt: minutesAgo(now, 12),
          heading: 270,
          speed: 0,
        }),
        lastProcessedRtdbTimestamp: minutesAgo(now, 12),
        updatedAt: minutesAgo(now, 12),
      },
    },
  ];

  return {incidents, approvals, states};
}

async function seedOperationalMonitoringScenarios({
  firestore,
  driverIds,
  driverProfiles,
  managerId,
  adminId,
  vehicle,
  now,
}) {
  const scenarios = buildOperationalMonitoringScenarios({
    driverIds,
    driverProfiles,
    managerId,
    adminId,
    vehicle,
    now,
  });

  for (const incident of scenarios.incidents) {
    await upsertIncidentScenario(firestore, incident);
  }

  for (const approval of scenarios.approvals) {
    await upsertApprovalScenario(firestore, approval);
  }

  for (const state of scenarios.states) {
    await upsertDriverOperationalState(firestore, state);
  }
}

module.exports = {
  seedOperationalMonitoringScenarios,
};
