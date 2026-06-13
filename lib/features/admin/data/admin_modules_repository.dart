import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_ent_280/features/support/data/models/chat_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:local_ent_280/features/admin/data/admin_functions_service.dart';
import 'package:local_ent_280/features/admin/data/admin_user_auth_service.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';
import 'package:local_ent_280/features/auth/data/models/manager_permission.dart';

/// Firebase access for admin module screens (users, fleet, config, etc.).
class AdminModulesRepository {
  AdminModulesRepository({
    FirebaseFirestore? firestore,
    AdminUserAuthService? authService,
    AdminFunctionsService? functionsService,
    this.disabled = false,
  })  : _firestore = firestore,
        _authService = authService ?? AdminUserAuthService(),
        _functionsService = functionsService ?? AdminFunctionsService();

  final FirebaseFirestore? _firestore;
  final AdminUserAuthService _authService;
  final AdminFunctionsService _functionsService;
  final bool disabled;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  Stream<List<AdminUserRecord>> watchUsers() {
    if (disabled) return Stream.value(const []);
    return _db.collection('users').limit(200).snapshots().map((snap) {
      final users = snap.docs.map(AdminUserRecord.fromFirestore).toList();
      users.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return users;
    });
  }

  Stream<List<AdminUserRecord>> watchManagers() {
    return watchUsers().map(
      (users) => users.where((u) => u.role == 'manager').toList(),
    );
  }

  Future<void> setUserActive(String uid, bool isActive) async {
    if (disabled) return;
    await _db.collection('users').doc(uid).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserFields(
    String uid, {
    required String name,
    required String phone,
    required String role,
    required bool isActive,
  }) async {
    if (disabled) return;
    await _db.collection('users').doc(uid).update({
      'name': name.trim(),
      'phone': phone.trim(),
      'role': role,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> createUser(AdminCreateUserDraft draft) async {
    if (disabled) {
      throw const AdminCreateUserException('Firebase is disabled.');
    }

    final email = draft.email.trim();
    final name = draft.name.trim();
    final phone = draft.phone.trim();
    final role = draft.role.trim().toLowerCase();

    if (name.isEmpty || email.isEmpty || draft.password.length < 6) {
      throw const AdminCreateUserException('Missing required fields.');
    }
    if (!AdminCreateUserDraft.roles.contains(role)) {
      throw const AdminCreateUserException('Invalid role.');
    }

    try {
      final credential = await _authService.createUser(
        email: email,
        password: draft.password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        throw const AdminCreateUserException('Auth user was not created.');
      }

      final batch = _db.batch();
      final userRef = _db.collection('users').doc(uid);
      batch.set(userRef, {
        'name': name,
        'phone': phone,
        'email': email,
        'role': role,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (role == 'client') {
        batch.set(_db.collection('balances').doc(uid), {
          'balance': {'amountMinor': 0, 'currency': 'EUR'},
          'debtLimit': {'amountMinor': -2000, 'currency': 'EUR'},
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (role == 'driver') {
        batch.set(_db.collection('driverStatus').doc(uid), {
          'isAvailable': false,
          'isActive': true,
          'availabilityEnabled': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      return uid;
    } on FirebaseAuthException catch (e) {
      throw AdminCreateUserException(_mapAuthError(e));
    } on FirebaseException catch (e) {
      throw AdminCreateUserException(e.message ?? 'Firestore write failed.');
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    return switch (e.code) {
      'email-already-in-use' => 'This email is already registered.',
      'weak-password' => 'Password must be at least 6 characters.',
      'invalid-email' => 'Invalid email address.',
      _ => 'Could not create user account.',
    };
  }

  Stream<List<AdminVehicleRecord>> watchFleet() {
    if (disabled) return Stream.value(const []);
    return _db.collection('vehicles').limit(100).snapshots().asyncMap(
      (vehiclesSnap) async {
        final assignments = await _db.collection('driverVehicleAssignments').get();
        final vehicleToDriver = <String, String>{};
        for (final doc in assignments.docs) {
          final vehicleId = doc.data()['vehicleId'] as String?;
          if (vehicleId != null) vehicleToDriver[vehicleId] = doc.id;
        }

        final rows = <AdminVehicleRecord>[];
        for (final doc in vehiclesSnap.docs) {
          final driverId = vehicleToDriver[doc.id];
          var driverName = '—';
          if (driverId != null) {
            final userDoc = await _db.collection('users').doc(driverId).get();
            driverName = userDoc.data()?['name'] as String? ?? driverId;
          }
          rows.add(
            AdminVehicleRecord.fromFirestore(
              doc,
              assignedDriverId: driverId,
              assignedDriverName: driverName,
            ),
          );
        }
        rows.sort((a, b) => a.label.compareTo(b.label));
        return rows;
      },
    );
  }

  Future<void> setVehicleActive(String vehicleId, bool isActive) async {
    if (disabled) return;
    await _db.collection('vehicles').doc(vehicleId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AdminSupportRequestRecord>> watchSupportRequests() {
    if (disabled) return Stream.value(const []);
    return _db
        .collection('supportRequests')
        .orderBy('requestedAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map(AdminSupportRequestRecord.fromFirestore).toList(),
        );
  }

  Stream<List<AdminIncidentRecord>> watchIncidents() {
    if (disabled) return Stream.value(const []);
    return _db
        .collection('operationalIncidents')
        .orderBy('startedAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map(AdminIncidentRecord.fromFirestore).toList());
  }

  Stream<AdminIncidentRecord?> watchIncident(String id) {
    if (disabled) return Stream.value(null);
    return _db.collection('operationalIncidents').doc(id).snapshots().map(
      (doc) => doc.exists ? AdminIncidentRecord.fromFirestore(doc) : null,
    );
  }

  Stream<List<AdminBalanceRecord>> watchBalances() {
    if (disabled) return Stream.value(const []);
    return _db.collection('balances').limit(200).snapshots().asyncMap(
      (snap) async {
        final rows = <AdminBalanceRecord>[];
        for (final doc in snap.docs) {
          final userDoc = await _db.collection('users').doc(doc.id).get();
          final userData = userDoc.data() ?? {};
          if ((userData['role'] as String? ?? '') != 'client') continue;
          final name = userData['name'] as String? ?? doc.id;
          rows.add(
            AdminBalanceRecord.fromFirestoreData(
              userId: doc.id,
              userName: name,
              data: doc.data(),
            ),
          );
        }
        rows.sort((a, b) => a.userName.compareTo(b.userName));
        return rows;
      },
    );
  }

  Future<void> applyBalanceAdjustment({
    required String clientId,
    required String clientName,
    required String clientEmail,
    required double amountEur,
    required bool isCredit,
    required String reason,
  }) async {
    if (disabled) return;
    final admin = FirebaseAuth.instance.currentUser;
    if (admin == null) {
      throw const AdminFunctionsException('Not signed in.');
    }
    final deltaMinor = ((isCredit ? amountEur : -amountEur) * 100).round();
    if (deltaMinor == 0) {
      throw const AdminFunctionsException('Enter a valid amount.');
    }

    final balanceRef = _db.collection('balances').doc(clientId);
    final balanceSnap = await balanceRef.get();
    final previousMinor = balanceSnap.exists
        ? adminMoneyMinor(balanceSnap.data()?['balance'])
        : 0;
    final previousDebtLimit = balanceSnap.exists
        ? adminMoneyMinor(balanceSnap.data()?['debtLimit'])
        : -2000;

    if (!balanceSnap.exists) {
      await balanceRef.set({
        'balance': {'amountMinor': deltaMinor, 'currency': 'EUR'},
        'debtLimit': {'amountMinor': -2000, 'currency': 'EUR'},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await balanceRef.update({
        'balance.amountMinor': FieldValue.increment(deltaMinor),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    final adjustmentRef = _db.collection('balance_adjustments').doc();
    await adjustmentRef.set({
      'clientId': clientId,
      'clientDisplayName': clientName,
      'clientEmail': clientEmail,
      'delta': {'amountMinor': deltaMinor, 'currency': 'EUR'},
      'reason': reason.trim(),
      'adminId': admin.uid,
      'adminEmail': admin.email ?? admin.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('audit').doc().set({
      'action': 'balance_adjustment',
      'subjectType': 'client',
      'subjectId': clientId,
      'actorEmail': admin.email ?? admin.uid,
      'summary': reason.trim(),
      'beforeValues': {
        'balance': {'amountMinor': previousMinor, 'currency': 'EUR'},
        'debtLimit': {'amountMinor': previousDebtLimit, 'currency': 'EUR'},
      },
      'afterValues': {
        'balance': {
          'amountMinor': previousMinor + deltaMinor,
          'currency': 'EUR',
        },
        'debtLimit': {'amountMinor': previousDebtLimit, 'currency': 'EUR'},
      },
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> createVehicle({
    required String plate,
    required String model,
    required int capacity,
    required bool isActive,
    required String notes,
    double rentalPricePerDayEur = 90,
    bool isRentalPremium = false,
    String vehicleCategory = 'Sedan',
    String transmission = 'Automático',
    int bags = 2,
    bool hasAc = true,
    String? defaultTransportTypeId,
    String? defaultTransportTypeName,
  }) async {
    if (disabled) return '';
    final ref = _db.collection('vehicles').doc();
    await ref.set({
      'plate': plate.trim(),
      'model': model.trim(),
      'capacity': capacity,
      'isActive': isActive,
      'notes': notes.trim(),
      'rentalPricePerDayMinor': (rentalPricePerDayEur * 100).round(),
      'isRentalPremium': isRentalPremium,
      'vehicleCategory': vehicleCategory.trim(),
      'transmission': transmission.trim(),
      'bags': bags,
      'hasAc': hasAc,
      if (defaultTransportTypeId != null)
        'defaultTransportType': {
          'id': defaultTransportTypeId,
          'name': defaultTransportTypeName ?? defaultTransportTypeId,
        },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> updateVehicle({
    required String vehicleId,
    required String plate,
    required String model,
    required int capacity,
    required bool isActive,
    required String notes,
    double? rentalPricePerDayEur,
    bool? isRentalPremium,
    String? vehicleCategory,
    String? transmission,
    int? bags,
    bool? hasAc,
    String? photoUrl,
    String? defaultTransportTypeId,
    String? defaultTransportTypeName,
  }) async {
    if (disabled) return;
    await _db.collection('vehicles').doc(vehicleId).update({
      'plate': plate.trim(),
      'model': model.trim(),
      'capacity': capacity,
      'isActive': isActive,
      'notes': notes.trim(),
      if (rentalPricePerDayEur != null)
        'rentalPricePerDayMinor': (rentalPricePerDayEur * 100).round(),
      if (isRentalPremium != null) 'isRentalPremium': isRentalPremium,
      if (vehicleCategory != null) 'vehicleCategory': vehicleCategory.trim(),
      if (transmission != null) 'transmission': transmission.trim(),
      if (bags != null) 'bags': bags,
      if (hasAc != null) 'hasAc': hasAc,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (defaultTransportTypeId != null)
        'defaultTransportType': {
          'id': defaultTransportTypeId,
          'name': defaultTransportTypeName ?? defaultTransportTypeId,
        },
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> uploadVehiclePhoto({
    required String vehicleId,
    required Uint8List bytes,
  }) async {
    final ref = FirebaseStorage.instance.ref('vehicles/$vehicleId/photo.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<void> createTransportType({
    required String name,
    required String description,
    required double baseFareEur,
    double packageMultiplier = 1,
  }) async {
    await _functionsService.createTransportType(
      name: name,
      description: description,
      baseFareMinor: (baseFareEur * 100).round(),
      packageMultiplierBasisPoints: (packageMultiplier * 10000).round(),
    );
  }

  Future<void> updateTransportType({
    required String id,
    required String name,
    required String description,
    required double baseFareEur,
    double packageMultiplier = 1,
  }) async {
    await _functionsService.updateTransportType(
      id: id,
      name: name,
      description: description,
      baseFareMinor: (baseFareEur * 100).round(),
      packageMultiplierBasisPoints: (packageMultiplier * 10000).round(),
    );
  }

  Future<void> saveTripPackage({
    String? id,
    required String name,
    required String description,
    required String destinationAddress,
    required double priceEur,
    required bool isActive,
    required List<AdminTransportTypeRecord> allowedTypes,
    String? photoUrl,
  }) async {
    if (allowedTypes.isEmpty) {
      throw const AdminFunctionsException('Select at least one transport type.');
    }
    await _functionsService.saveTripPackageTemplate({
      if (id != null) 'id': id,
      'name': name.trim(),
      'description': description.trim(),
      'photoUrl': photoUrl ?? 'https://placehold.co/600x400/png',
      'destination': {
        'address': destinationAddress.trim(),
        'latitude': 14.9331,
        'longitude': -23.5133,
      },
      'price': {'amountMinor': (priceEur * 100).round(), 'currency': 'EUR'},
      'allowedTransportTypes': allowedTypes
          .map(
            (type) => {
              'id': type.id,
              'name': type.name,
              'packagePriceMultiplierBasisPoints':
                  type.packageMultiplierBasisPoints,
            },
          )
          .toList(),
      'isActive': isActive,
    });
  }

  Future<void> resolveSupportRequest(String requestId) async {
    await _functionsService.resolveSupportRequest(requestId);
  }

  Future<void> sendSupportReply({
    required String requestId,
    required String message,
    String? chatThreadId,
  }) async {
    final threadId = chatThreadId ?? supportRequestThreadId(requestId);
    await _functionsService.sendSupportTicketMessage(
      requestId: requestId,
      body: message,
      clientMessageId: _db
          .collection('chatThreads')
          .doc(threadId)
          .collection('chatMessages')
          .doc()
          .id,
    );
  }

  Future<void> saveAdminTariff(Map<String, dynamic> tariff) async {
    await _functionsService.saveAdminTariff(tariff);
  }

  Stream<List<AdminAuditRecord>> watchAudit() {
    if (disabled) return Stream.value(const []);
    return _db
        .collection('audit')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map(AdminAuditRecord.fromFirestore).toList());
  }

  Stream<List<AdminEventRecord>> watchEvents() {
    if (disabled) return Stream.value(const []);
    return _db
        .collection('events')
        .orderBy('scheduledAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map(AdminEventRecord.fromFirestore).toList());
  }

  Stream<List<AdminReservationRecord>> watchReservations() {
    if (disabled) return Stream.value(const []);
    return _db
        .collection('reservations')
        .orderBy('scheduledAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map(AdminReservationRecord.fromFirestore).toList(),
        );
  }

  Stream<List<AdminTransportTypeRecord>> watchTransportTypes() {
    if (disabled) return Stream.value(const []);
    return _db.collection('transport_types').limit(50).snapshots().map(
      (snap) =>
          snap.docs.map(AdminTransportTypeRecord.fromFirestore).toList(),
    );
  }

  Stream<List<AdminTripPackageRecord>> watchTripPackages() {
    if (disabled) return Stream.value(const []);
    return _db.collection('tripPackages').limit(50).snapshots().map(
      (snap) => snap.docs.map(AdminTripPackageRecord.fromFirestore).toList(),
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchTariff(String id) {
    if (disabled) {
      return const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty();
    }
    return _db.collection('tariffs').doc(id).snapshots();
  }

  Stream<AdminConfigSnapshot> watchConfig(String docId) {
    if (disabled) {
      return Stream.value(AdminConfigSnapshot(docId: docId, data: const {}, exists: false));
    }
    return _db.collection('config').doc(docId).snapshots().map(
      (doc) => AdminConfigSnapshot(
        docId: docId,
        data: doc.data() ?? {},
        exists: doc.exists,
      ),
    );
  }

  Future<void> saveConfig(String docId, Map<String, dynamic> fields) async {
    if (disabled) return;
    await _db.collection('config').doc(docId).set(
      {
        ...fields,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> setManagerPermissions({
    required String userId,
    required Map<ManagerPermission, bool> permissions,
  }) async {
    if (disabled) {
      throw const AdminFunctionsException('Firebase is disabled.');
    }
    try {
      await _functionsService.setManagerPermissions(
        userId: userId,
        permissions: {
          for (final entry in permissions.entries) entry.key.code: entry.value,
        },
      );
    } on AdminFunctionsException {
      rethrow;
    } catch (error) {
      throw AdminFunctionsException(error.toString());
    }
  }
}
