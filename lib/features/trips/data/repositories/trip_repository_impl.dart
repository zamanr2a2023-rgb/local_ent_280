import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_ent_280/core/services/client_functions_service.dart';
import 'package:local_ent_280/core/services/client_tariff_service.dart';
import 'package:local_ent_280/features/trips/data/client_trip_flow.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';
import 'package:local_ent_280/features/trips/data/trip_request_payload_builder.dart';
import 'package:local_ent_280/features/trips/domain/entities/create_trip_input.dart';
import 'package:local_ent_280/features/trips/domain/repositories/trip_repository.dart';

typedef TripRecordStreamFactory = Stream<TripRecord?> Function(String tripId);
typedef ClientTripsStreamFactory = Stream<List<TripRecord>> Function(
  String clientId,
);
typedef CreateTripOverride = Future<String> Function(CreateTripInput input);

class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl({
    FirebaseFirestore? firestore,
    ClientFunctionsService? functionsService,
    ClientTariffService? tariffService,
    TripRequestPayloadBuilder? payloadBuilder,
    this.disabled = false,
    TripRecordStreamFactory? watchTripOverride,
    ClientTripsStreamFactory? watchClientTripsOverride,
    CreateTripOverride? createTripOverride,
  })  : _firestore = firestore,
        _functionsService = functionsService ?? ClientFunctionsService(),
        _tariffService = tariffService ?? ClientTariffService(firestore: firestore),
        _payloadBuilder = payloadBuilder ?? const TripRequestPayloadBuilder(),
        _watchTripOverride = watchTripOverride,
        _watchClientTripsOverride = watchClientTripsOverride,
        _createTripOverride = createTripOverride;

  final FirebaseFirestore? _firestore;
  final ClientFunctionsService _functionsService;
  final ClientTariffService _tariffService;
  final TripRequestPayloadBuilder _payloadBuilder;
  final bool disabled;
  final TripRecordStreamFactory? _watchTripOverride;
  final ClientTripsStreamFactory? _watchClientTripsOverride;
  final CreateTripOverride? _createTripOverride;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _trips =>
      _db.collection('trips');

  @override
  Future<String> createTrip(CreateTripInput input) async {
    if (_createTripOverride != null) {
      return _createTripOverride(input);
    }
    if (disabled) {
      throw StateError('TripRepository is disabled.');
    }

    final tripId = _trips.doc().id;
    final tariff = await _tariffService.fetchCurrentTariff();
    final tripData = _payloadBuilder.build(
      clientId: input.clientId,
      pickup: input.pickup,
      destination: input.destination,
      transportType: input.transportType,
      tariff: tariff,
      distanceKm: input.distanceKm,
      durationMinutes: input.durationMinutes,
      estimatedTotalMinor: input.estimatedTotalMinor,
    );

    await _functionsService.requestTrip(tripId: tripId, tripData: tripData);
    return tripId;
  }

  @override
  Stream<TripRecord?> watchTrip(String tripId) {
    if (_watchTripOverride != null) return _watchTripOverride(tripId);
    if (disabled) return Stream<TripRecord?>.value(null);
    return _trips.doc(tripId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return TripRecord.fromFirestore(doc);
    });
  }

  @override
  Future<TripRecord?> getTrip(String tripId) async {
    final doc = await _trips.doc(tripId).get();
    if (!doc.exists) return null;
    return TripRecord.fromFirestore(doc);
  }

  @override
  Stream<List<TripRecord>> watchClientTrips(String clientId) {
    if (_watchClientTripsOverride != null) {
      return _watchClientTripsOverride(clientId);
    }
    if (disabled) return Stream<List<TripRecord>>.value(const []);
    return _trips.where('clientId', isEqualTo: clientId).limit(50).snapshots().map(
      (snapshot) {
        final trips = snapshot.docs.map(TripRecord.fromFirestore).toList();
        trips.sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
        return trips;
      },
    );
  }

  @override
  Future<void> cancelTripByClient(
    String tripId, {
    required String reason,
  }) async {
    if (disabled) return;
    await _functionsService.cancelTrip(tripId: tripId, reason: reason);
    await _waitForCancelledTrip(tripId);
  }

  Future<void> _waitForCancelledTrip(String tripId) async {
    for (var attempt = 0; attempt < 12; attempt++) {
      final trip = await getTrip(tripId);
      if (trip != null && ClientTripFlow.isCancelled(trip.status)) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    throw const ClientFunctionsException(
      'Trip cancellation could not be confirmed. Please try again.',
    );
  }

  @override
  Future<void> submitTripRating({
    required String tripId,
    required String clientId,
    required int stars,
    String? feedback,
  }) async {
    if (disabled) return;
    await _trips.doc(tripId).update({
      'rating': {
        'stars': stars.clamp(1, 5),
        'feedback': (feedback ?? '').trim(),
        'clientId': clientId,
        'createdAt': FieldValue.serverTimestamp(),
      },
    });
  }
}
