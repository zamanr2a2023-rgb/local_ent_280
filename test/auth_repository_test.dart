import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_ent_280/features/auth/data/auth_exception.dart';
import 'package:local_ent_280/features/auth/data/auth_repository.dart';
import 'package:local_ent_280/features/auth/data/models/login_selected_role.dart';
import 'package:local_ent_280/features/auth/data/user_session.dart';

void main() {
  const uid = 'test-user-uid';
  const email = 'cliente2.qa@localtransport.test';
  const password = 'password123';

  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late AuthRepository repository;

  Future<void> seedUser({
    required String role,
    bool isActive = true,
  }) async {
    await firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': 'Cliente QA 2',
      'phone': '+351910000202',
      'role': role,
      'isActive': isActive,
    });
  }

  setUp(() {
    UserSession.instance.clear();
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(
      mockUser: MockUser(uid: uid, email: email),
    );
    repository = AuthRepository(firebaseAuth: auth, firestore: firestore);
  });

  tearDown(() {
    UserSession.instance.clear();
  });

  test('signIn succeeds when role matches client profile', () async {
    await seedUser(role: 'client');

    final profile = await repository.signIn(
      email: email,
      password: password,
      selectedRole: LoginSelectedRole.client,
    );

    expect(profile.role.name, 'client');
    expect(profile.email, email);
    expect(UserSession.instance.profile?.uid, uid);
  });

  test('signIn succeeds for admin profile on professional tab', () async {
    await seedUser(role: 'admin');

    final profile = await repository.signIn(
      email: email,
      password: password,
      selectedRole: LoginSelectedRole.professional,
    );

    expect(profile.role.name, 'admin');
  });

  test('signIn throws roleMismatch when client tab used for admin profile', () async {
    await seedUser(role: 'admin');

    expect(
      () => repository.signIn(
        email: email,
        password: password,
        selectedRole: LoginSelectedRole.client,
      ),
      throwsA(
        isA<AuthException>().having(
          (e) => e.code,
          'code',
          AuthFailureCode.roleMismatch,
        ),
      ),
    );
  });

  test('signIn throws roleMismatch when tab does not match profile', () async {
    await seedUser(role: 'client');

    expect(
      () => repository.signIn(
        email: email,
        password: password,
        selectedRole: LoginSelectedRole.professional,
      ),
      throwsA(
        isA<AuthException>().having(
          (e) => e.code,
          'code',
          AuthFailureCode.roleMismatch,
        ),
      ),
    );
  });

  test('signIn throws accountInactive when profile is disabled', () async {
    await seedUser(role: 'client', isActive: false);

    expect(
      () => repository.signIn(
        email: email,
        password: password,
        selectedRole: LoginSelectedRole.client,
      ),
      throwsA(
        isA<AuthException>().having(
          (e) => e.code,
          'code',
          AuthFailureCode.accountInactive,
        ),
      ),
    );
  });

  test('signIn throws profileNotFound when Firestore doc is missing', () async {
    expect(
      () => repository.signIn(
        email: email,
        password: password,
        selectedRole: LoginSelectedRole.client,
      ),
      throwsA(
        isA<AuthException>().having(
          (e) => e.code,
          'code',
          AuthFailureCode.profileNotFound,
        ),
      ),
    );
  });

  test('restoreSession returns profile for active user', () async {
    await seedUser(role: 'driver');
    auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: uid, email: email),
    );
    repository = AuthRepository(firebaseAuth: auth, firestore: firestore);

    final profile = await repository.restoreSession();

    expect(profile, isNotNull);
    expect(profile!.role.name, 'driver');
  });

  test('restoreSession signs out when profile is inactive', () async {
    await seedUser(role: 'client', isActive: false);
    auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: uid, email: email),
    );
    repository = AuthRepository(firebaseAuth: auth, firestore: firestore);

    final profile = await repository.restoreSession();

    expect(profile, isNull);
    expect(auth.currentUser, isNull);
  });

  test('signUp creates client profile in Firestore', () async {
    auth = MockFirebaseAuth();
    repository = AuthRepository(firebaseAuth: auth, firestore: firestore);

    final profile = await repository.signUp(
      name: 'New Client',
      email: 'new.client@test.com',
      password: password,
      phone: '+351910000001',
      selectedRole: LoginSelectedRole.client,
    );

    expect(profile.role.name, 'client');
    expect(profile.name, 'New Client');
    expect(profile.email, 'new.client@test.com');

    final doc = await firestore.collection('users').doc(profile.uid).get();
    expect(doc.exists, isTrue);
    expect(doc.data()?['role'], 'client');
  });

  test('signUp creates driver profile and driverStatus', () async {
    auth = MockFirebaseAuth();
    repository = AuthRepository(firebaseAuth: auth, firestore: firestore);

    final profile = await repository.signUp(
      name: 'New Driver',
      email: 'new.driver@test.com',
      password: password,
      phone: '',
      selectedRole: LoginSelectedRole.professional,
    );

    expect(profile.role.name, 'driver');

    final status =
        await firestore.collection('driverStatus').doc(profile.uid).get();
    expect(status.exists, isTrue);
    expect(status.data()?['isAvailable'], false);
  });
}
