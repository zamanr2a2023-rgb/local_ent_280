import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/data/firebase/realtime_db_service.dart';

void main() {
  group('runRealtimeDbWriteWithRecovery', () {
    test('executa recuperação e repete a operação uma vez', () async {
      var operationCalls = 0;
      var recoveryCalls = 0;

      await runRealtimeDbWriteWithRecovery(
        action: 'set',
        path: '/driverLocations/d1',
        operation: () async {
          operationCalls += 1;
          if (operationCalls == 1) {
            throw _TestFirebaseException(code: 'permission-denied');
          }
        },
        recoverAuthentication: () async {
          recoveryCalls += 1;
          return true;
        },
        isPermissionDenied: _isPermissionDenied,
      );

      expect(operationCalls, 2);
      expect(recoveryCalls, 1);
    });

    test('não repete quando o erro não é permission-denied', () async {
      var operationCalls = 0;
      var recoveryCalls = 0;

      await expectLater(
        runRealtimeDbWriteWithRecovery(
          action: 'update',
          path: '/driverLocations/d1',
          operation: () async {
            operationCalls += 1;
            throw _TestFirebaseException(code: 'network-error');
          },
          recoverAuthentication: () async {
            recoveryCalls += 1;
            return true;
          },
          isPermissionDenied: _isPermissionDenied,
        ),
        throwsA(isA<FirebaseException>()),
      );

      expect(operationCalls, 1);
      expect(recoveryCalls, 0);
    });

    test('repropaga erro quando recoverAuthentication falha', () async {
      var operationCalls = 0;
      var recoveryCalls = 0;

      await expectLater(
        runRealtimeDbWriteWithRecovery(
          action: 'remove',
          path: '/driverLocations/d1',
          operation: () async {
            operationCalls += 1;
            throw _TestFirebaseException(code: 'permission-denied');
          },
          recoverAuthentication: () async {
            recoveryCalls += 1;
            throw StateError('auth refresh failed');
          },
          isPermissionDenied: _isPermissionDenied,
        ),
        throwsA(isA<StateError>()),
      );

      expect(operationCalls, 1);
      expect(recoveryCalls, 1);
    });

    test(
      'termina sessão quando permission-denied persiste após refresh',
      () async {
        var operationCalls = 0;
        var recoveryCalls = 0;
        var terminalFailureCalls = 0;

        await expectLater(
          runRealtimeDbWriteWithRecovery(
            action: 'update',
            path: '/driverLocations/d1',
            operation: () async {
              operationCalls += 1;
              throw _TestFirebaseException(code: 'permission-denied');
            },
            recoverAuthentication: () async {
              recoveryCalls += 1;
              return true;
            },
            isPermissionDenied: _isPermissionDenied,
            handlePersistentPermissionDenied: () async {
              terminalFailureCalls += 1;
            },
          ),
          throwsA(isA<FirebaseException>()),
        );

        expect(operationCalls, 2);
        expect(recoveryCalls, 1);
        expect(terminalFailureCalls, 1);
      },
    );
  });
}

bool _isPermissionDenied(FirebaseException error) {
  return error.plugin == 'firebase_database' &&
      error.code == 'permission-denied';
}

class _TestFirebaseException extends FirebaseException {
  _TestFirebaseException({required super.code})
    : super(plugin: 'firebase_database');
}
