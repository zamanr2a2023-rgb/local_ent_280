import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_ent_280/features/auth/data/models/app_user_profile.dart';
import 'package:local_ent_280/features/trips/data/client_passenger_stats.dart';
import 'package:local_ent_280/features/trips/data/models/trip_location.dart';
import 'package:local_ent_280/features/trips/data/models/trip_record.dart';

class CreateTripInput {
  const CreateTripInput({
    required this.clientId,
    required this.clientProfile,
    required this.pickup,
    required this.destination,
    required this.transportType,
    required this.distanceKm,
    required this.durationMinutes,
    required this.estimatedPriceEur,
  });

  final String clientId;
  final AppUserProfile clientProfile;
  final TripLocation pickup;
  final TripLocation destination;
  final TripTransportType transportType;
  final double distanceKm;
  final int durationMinutes;
  final double estimatedPriceEur;
}

typedef TripRecordStreamFactory = Stream<TripRecord?> Function(String tripId);
typedef ClientTripsStreamFactory = Stream<List<TripRecord>> Function(
  String clientId,
);
typedef CreateTripOverride = Future<String> Function(CreateTripInput input);

class TripRepository {
  TripRepository({
    FirebaseFirestore? firestore,
    this.disabled = false,
    TripRecordStreamFactory? watchTripOverride,
    ClientTripsStreamFactory? watchClientTripsOverride,
    CreateTripOverride? createTripOverride,
  })  : _firestore = firestore,
        _watchTripOverride = watchTripOverride,
        _watchClientTripsOverride = watchClientTripsOverride,
        _createTripOverride = createTripOverride;

  final FirebaseFirestore? _firestore;
  final bool disabled;
  final TripRecordStreamFactory? _watchTripOverride;
  final ClientTripsStreamFactory? _watchClientTripsOverride;
  final CreateTripOverride? _createTripOverride;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _trips =>
      _db.collection('trips');

  Future<String> createTrip(CreateTripInput input) async {
    if (_createTripOverride != null) {
      return _createTripOverride!(input);
    }
    if (disabled) {
      throw StateError('TripRepository is disabled.');
    }
    final docRef = _trips.doc();
    final estimatedCostMinor = (input.estimatedPriceEur * 100).round();
    final passengerStats =
        await ClientPassengerStats.compute(_db, input.clientId);

    await docRef.set({
      'clientId': input.clientId,
      'pickup': input.pickup.toFirestore(),
      'destination': input.destination.toFirestore(),
      'transportType': input.transportType.toFirestore(),
      'status': 'REQUESTED',
      'isActive': true,
      'meteringSnapshot': TripMeteringSnapshot(
        totalDistanceKm: input.distanceKm,
        totalMinutes: input.durationMinutes,
        totalWaitMinutes: 0,
        estimatedCostMinor: estimatedCostMinor,
      ).toFirestore(),
      'clientSupport': TripClientSupport(
        displayName: input.clientProfile.name.trim().isNotEmpty
            ? input.clientProfile.name.trim()
            : input.clientProfile.email,
        phone: input.clientProfile.phone,
        averageRating: passengerStats.averageRating,
        isVip: passengerStats.isVip,
        photoUrl: input.clientProfile.photoUrl,
      ).toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'requestedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Stream<TripRecord?> watchTrip(String tripId) {
    if (_watchTripOverride != null) return _watchTripOverride!(tripId);
    if (disabled) return Stream<TripRecord?>.value(null);
    return _trips.doc(tripId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return TripRecord.fromFirestore(doc);
    });
  }

  Future<TripRecord?> getTrip(String tripId) async {
    final doc = await _trips.doc(tripId).get();
    if (!doc.exists) return null;
    return TripRecord.fromFirestore(doc);
  }

  Stream<List<TripRecord>> watchClientTrips(String clientId) {
    if (_watchClientTripsOverride != null) {
      return _watchClientTripsOverride!(clientId);
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

  Future<void> cancelTripByClient(String tripId) async {
    if (disabled) return;
    await _trips.doc(tripId).update({
      'status': 'CANCELLED_BY_CLIENT',
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

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
        if (feedback != null && feedback.trim().isNotEmpty)
          'feedback': feedback.trim(),
        'clientId': clientId,
        'createdAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
