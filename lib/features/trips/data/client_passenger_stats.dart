import 'package:cloud_firestore/cloud_firestore.dart';

class ClientPassengerStats {
  const ClientPassengerStats({
    this.averageRating,
    this.isVip = false,
    this.ratedTripCount = 0,
  });

  final double? averageRating;
  final bool isVip;
  final int ratedTripCount;

  static Future<ClientPassengerStats> compute(
    FirebaseFirestore firestore,
    String clientId,
  ) async {
    final snapshot = await firestore
        .collection('trips')
        .where('clientId', isEqualTo: clientId)
        .where('status', isEqualTo: 'COMPLETED')
        .limit(50)
        .get();

    final stars = <int>[];
    for (final doc in snapshot.docs) {
      final rating = doc.data()['rating'];
      if (rating is Map<String, dynamic>) {
        final value = rating['stars'];
        if (value is int && value >= 1 && value <= 5) {
          stars.add(value);
        }
      }
    }

    if (stars.isEmpty) {
      return const ClientPassengerStats();
    }

    final average = stars.reduce((a, b) => a + b) / stars.length;
    return ClientPassengerStats(
      averageRating: average,
      isVip: average >= 4.8 && stars.length >= 3,
      ratedTripCount: stars.length,
    );
  }
}
