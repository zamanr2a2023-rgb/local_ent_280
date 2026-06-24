import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Reads support contact details from `config/support` (same as admin settings).
class SupportContactService {
  SupportContactService({FirebaseFirestore? firestore})
    : _firestore = firestore;

  final FirebaseFirestore? _firestore;

  static const _configId = 'support';

  Stream<String> watchSupportPhone() {
    final firestore = _firestore ?? FirebaseFirestore.instance;
    return firestore
        .collection('config')
        .doc(_configId)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          return (data?['supportPhone'] as String?)?.trim() ?? '';
        })
        .handleError((Object error, StackTrace stackTrace) {
          debugPrint('Support phone stream failed: $error');
        }, test: (_) => true);
  }

  Future<String> fetchSupportPhone() async {
    try {
      final firestore = _firestore ?? FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('config')
          .doc(_configId)
          .get();
      return (snapshot.data()?['supportPhone'] as String?)?.trim() ?? '';
    } on FirebaseException catch (error) {
      debugPrint('Support phone fetch failed: ${error.code} ${error.message}');
      return '';
    } catch (error) {
      debugPrint('Support phone fetch failed: $error');
      return '';
    }
  }
}
