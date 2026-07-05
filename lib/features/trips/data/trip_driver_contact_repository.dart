import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TripDriverContactSnapshot {
  const TripDriverContactSnapshot({
    required this.driverId,
    required this.name,
    required this.phone,
    this.photoUrl,
  });

  final String driverId;
  final String name;
  final String phone;
  final String? photoUrl;
}

/// Reads driver contact details from `trips/{tripId}/driverContactSnapshots/{tripId}`.
class TripDriverContactRepository {
  TripDriverContactRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<TripDriverContactSnapshot?> fetchContact(String tripId) async {
    if (tripId.trim().isEmpty) return null;

    try {
      final snapshot = await _firestore
          .collection('trips')
          .doc(tripId)
          .collection('driverContactSnapshots')
          .doc(tripId)
          .get();
      if (!snapshot.exists) return null;

      final data = snapshot.data() ?? {};
      final phone = (data['phone'] as String?)?.trim() ?? '';
      if (phone.isEmpty) return null;

      return TripDriverContactSnapshot(
        driverId: data['driverId'] as String? ?? '',
        name: data['name'] as String? ?? '',
        phone: phone,
        photoUrl: data['photoUrl'] as String?,
      );
    } on FirebaseException catch (error) {
      debugPrint(
        'Driver contact fetch failed: ${error.code} ${error.message}',
      );
      return null;
    } catch (error) {
      debugPrint('Driver contact fetch failed: $error');
      return null;
    }
  }
}
