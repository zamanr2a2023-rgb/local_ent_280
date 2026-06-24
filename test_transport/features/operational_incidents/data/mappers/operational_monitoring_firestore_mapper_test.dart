import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/operational_incidents/data/mappers/operational_monitoring_firestore_mapper.dart';
import 'package:local_transport/features/operational_incidents/domain/entities/operational_approval_draft.dart';
import 'package:local_transport/features/operational_incidents/domain/entities/operational_coordinate.dart';
import 'package:local_transport/features/operational_incidents/domain/entities/operational_incident_review_request.dart';
import 'package:local_transport/features/operational_incidents/domain/entities/operational_monitoring_enums.dart';

void main() {
  const mapper = OperationalMonitoringFirestoreMapper();

  group('OperationalMonitoringFirestoreMapper', () {
    test('maps incident json with km evidence and replay samples', () {
      final startedAt = DateTime.utc(2026, 3, 22, 10, 0);
      final resolvedAt = DateTime.utc(2026, 3, 22, 10, 15);
      final updatedAt = DateTime.utc(2026, 3, 22, 10, 20);

      final incident = mapper.fromIncidentJson({
        'operationalWindowId': 'trip:trip_1:postdropoff:1711111111111',
        'operationalWindowType': 'post_dropoff',
        'driverId': 'driver_1',
        'driverName': 'Motorista QA',
        'vehicleId': 'vehicle_1',
        'vehiclePlate': 'AA-00-BB',
        'tripId': 'trip_1',
        'incidentType': 'post_dropoff_unauthorized_movement',
        'subreason': 'abandoned_return_to_base',
        'status': 'acknowledged',
        'startedAt': Timestamp.fromDate(startedAt),
        'resolvedAt': Timestamp.fromDate(resolvedAt),
        'resolutionSource': 'system',
        'resolutionReason': 'entered_base',
        'currentState': 'returning_to_base',
        'originCoordinates': {
          'latitude': 38.7223,
          'longitude': -9.1393,
          'recordedAt': Timestamp.fromDate(startedAt),
        },
        'latestCoordinates': {
          'latitude': 38.7369,
          'longitude': -9.1427,
          'recordedAt': Timestamp.fromDate(updatedAt),
          'heading': 120.0,
          'speed': 35.0,
        },
        'expectedPolyline': 'encoded-polyline',
        'actualPathSamples': [
          {
            'latitude': 38.7223,
            'longitude': -9.1393,
            'recordedAt': Timestamp.fromDate(startedAt),
          },
          {
            'latitude': 38.7300,
            'longitude': -9.1500,
          },
          {
            'latitude': 38.7369,
            'longitude': -9.1427,
            'recordedAt': Timestamp.fromDate(updatedAt),
          },
        ],
        'expectedTripDistanceKm': 12.4,
        'actualTripDistanceKm': 14.2,
        'tripDistanceVarianceKm': 1.8,
        'tripDistanceVariancePct': 14.5,
        'expectedPostDropoffDistanceKm': 5.0,
        'actualPostDropoffDistanceKm': 7.3,
        'postDropoffVarianceKm': 2.3,
        'postDropoffVariancePct': 46.0,
        'expectedNoTripDistanceKm': 0.8,
        'actualNoTripDistanceKm': 1.5,
        'noTripVarianceKm': 0.7,
        'noTripVariancePct': 87.5,
        'totalExpectedDistanceKm': 18.2,
        'totalActualDistanceKm': 23.0,
        'totalVarianceKm': 4.8,
        'totalVariancePct': 26.4,
        'dropoffAt': Timestamp.fromDate(startedAt),
        'baseArrivedAt': Timestamp.fromDate(resolvedAt),
        'reviewNote': 'Verificado pela operação.',
        'updatedAt': Timestamp.fromDate(updatedAt),
      }, 'incident_1');

      expect(incident.id, 'incident_1');
      expect(incident.operationalWindowType, OperationalWindowType.postDropoff);
      expect(
        incident.incidentType,
        OperationalIncidentType.postDropoffUnauthorizedMovement,
      );
      expect(incident.status, OperationalIncidentStatus.acknowledged);
      expect(incident.currentState, OperationalState.returningToBase);
      expect(incident.actualPathSamples, hasLength(2));
      expect(incident.tripEvidence.expectedKm, 12.4);
      expect(incident.postDropoffEvidence.varianceKm, 2.3);
      expect(incident.noTripEvidence.variancePct, 87.5);
      expect(incident.totalEvidence.actualKm, 23.0);
      expect(incident.reviewNote, 'Verificado pela operação.');
      expect(incident.isResolved, isTrue);
    });

    test('maps approval and reposition candidate json', () {
      final expiresAt = DateTime.utc(2026, 3, 22, 12, 0);
      final createdAt = DateTime.utc(2026, 3, 22, 11, 0);

      final approval = mapper.fromApprovalJson({
        'operationalWindowId': 'driver:driver_1:idle:1711111111111',
        'operationalWindowType': 'no_trip_operational',
        'driverId': 'driver_1',
        'driverName': 'Motorista QA',
        'vehicleId': 'vehicle_1',
        'vehiclePlate': 'AA-00-BB',
        'reason': 'Abastecimento operacional',
        'expiresAt': Timestamp.fromDate(expiresAt),
        'allowedArea': {
          'label': 'Bomba',
          'center': {'latitude': 38.73, 'longitude': -9.14},
          'radiusMeters': 180.0,
        },
        'approvedBy': 'manager_1',
        'approvedByRole': 'manager',
        'status': 'active',
        'incidentId': 'incident_1',
        'createdAt': Timestamp.fromDate(createdAt),
      }, 'approval_1');

      final candidate = mapper.fromStateJson({
        'driverName': 'Motorista QA',
        'vehicleId': 'vehicle_1',
        'vehiclePlate': 'AA-00-BB',
        'tripId': 'trip_1',
        'linkedTripId': 'trip_1',
        'operationalWindowId': 'trip:trip_1:postdropoff:1711111111111',
        'operationalWindowType': 'post_dropoff',
        'currentState': 'post_dropoff_waiting',
        'latestLocation': {
          'latitude': 38.72,
          'longitude': -9.13,
          'recordedAt': Timestamp.fromDate(createdAt),
        },
        'lastProcessedRtdbTimestamp': Timestamp.fromDate(createdAt),
      }, 'driver_1');

      expect(approval.allowedArea?.label, 'Bomba');
      expect(approval.status, OperationalApprovalStatus.active);
      expect(candidate.driverId, 'driver_1');
      expect(
        candidate.operationalWindowType,
        OperationalWindowType.postDropoff,
      );
      expect(candidate.currentState, OperationalState.postDropoffWaiting);
      expect(candidate.latestLocation?.latitude, 38.72);
    });

    test('builds review and approval payloads with trimmed inputs', () {
      final expiresAt = DateTime.utc(2026, 3, 22, 14, 30);
      final draft = OperationalApprovalDraft(
        driverId: 'driver_1',
        reason: '  Reposição autorizada  ',
        expiresAt: expiresAt,
        allowedAreaCenter: const OperationalCoordinate(
          latitude: 38.74,
          longitude: -9.15,
        ),
        allowedAreaRadiusMeters: 220,
      );

      final reviewPayload = mapper.toReviewPayload(
        OperationalIncidentReviewRequest(
          incidentId: 'incident_2',
          action: OperationalIncidentReviewAction.approveException,
          note: '  Confirmado pelo gestor  ',
          approvalDraft: draft,
        ),
      );
      final approvalPayload = mapper.toApprovalPayload(draft);

      expect(reviewPayload['incidentId'], 'incident_2');
      expect(reviewPayload['action'], 'approve_exception');
      expect(reviewPayload['note'], 'Confirmado pelo gestor');
      expect(reviewPayload['reason'], 'Reposição autorizada');
      expect(reviewPayload['expiresAt'], expiresAt.toUtc().toIso8601String());
      expect(
        (reviewPayload['allowedArea'] as Map<String, dynamic>)['radiusMeters'],
        220.0,
      );
      expect(approvalPayload['driverId'], 'driver_1');
      expect(approvalPayload['reason'], 'Reposição autorizada');
      expect(approvalPayload['expiresAt'], expiresAt.toUtc().toIso8601String());
    });
  });
}
