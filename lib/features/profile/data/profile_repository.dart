import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:local_ent_280/features/auth/data/models/app_user_profile.dart';

/// Uploads profile photos and name updates to Firebase Storage / Firestore `users/{uid}`.
class ProfileRepository {
  ProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Future<AppUserProfile> updateProfilePhoto({
    required String uid,
    required File imageFile,
  }) async {
    final ref = _storage.ref().child('users').child(uid).child('profile.jpg');
    try {
      await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
    } on FirebaseException catch (e) {
      debugPrint('Profile photo storage upload failed: ${e.code} ${e.message}');
      rethrow;
    }

    final photoUrl = await ref.getDownloadURL();
    debugPrint('Profile photo URL length: ${photoUrl.length}');

    try {
      await _firestore.collection('users').doc(uid).update({
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      debugPrint('Profile photo Firestore update failed: ${e.code} ${e.message}');
      rethrow;
    }

    return _fetchProfile(uid);
  }

  Future<AppUserProfile> updateProfileName({
    required String uid,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Name cannot be empty.');
    }

    try {
      await _firestore.collection('users').doc(uid).update({
        'name': trimmed,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      debugPrint('Profile name Firestore update failed: ${e.code} ${e.message}');
      rethrow;
    }

    return _fetchProfile(uid);
  }

  Future<AppUserProfile> _fetchProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw StateError('User profile not found after profile update.');
    }
    return AppUserProfile.fromFirestore(doc);
  }
}
