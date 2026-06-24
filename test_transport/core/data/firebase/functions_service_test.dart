import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/app/config/app_config.dart';
import 'package:local_transport/core/data/firebase/functions_service.dart';

void main() {
  group('FunctionsService', () {
    test(
      'repete a callable após sincronizar token em erro unauthenticated',
      () async {
        var authSyncCount = 0;
        var callableCount = 0;

        final service = FunctionsService(
          null,
          appConfig: AppConfig.mockedTest(),
          authSessionSynchronizer: ({required forceRefresh}) async {
            authSyncCount += 1;
            if (!forceRefresh) {
              return const FunctionsAuthSession(
                uid: 'manager-1',
                hasToken: true,
              );
            }
            return const FunctionsAuthSession(uid: 'manager-1', hasToken: true);
          },
          callableInvoker:
              <T>({
                required String name,
                String? region,
                Map<String, dynamic>? parameters,
              }) async {
                callableCount += 1;
                if (callableCount == 1) {
                  throw _TestFirebaseFunctionsException(
                    code: 'unauthenticated',
                    message: 'Auth required',
                  );
                }
                return <String, dynamic>{'packageId': 'package-1'} as T;
              },
        );

        final result = await service.call<Map<String, dynamic>>(
          name: 'saveTripPackageTemplate',
        );

        expect(result, <String, dynamic>{'packageId': 'package-1'});
        expect(authSyncCount, 2);
        expect(callableCount, 2);
      },
    );

    test(
      'propaga unauthenticated quando a sessão continua inválida após refresh',
      () async {
        var authSyncCount = 0;
        var callableCount = 0;

        final service = FunctionsService(
          null,
          appConfig: AppConfig.mockedTest(),
          authSessionSynchronizer: ({required forceRefresh}) async {
            authSyncCount += 1;
            return const FunctionsAuthSession.unauthenticated();
          },
          callableInvoker:
              <T>({
                required String name,
                String? region,
                Map<String, dynamic>? parameters,
              }) async {
                callableCount += 1;
                throw _TestFirebaseFunctionsException(
                  code: 'unauthenticated',
                  message: 'Auth required',
                );
              },
        );

        await expectLater(
          service.call<void>(name: 'saveTripPackageTemplate'),
          throwsA(isA<FirebaseFunctionsException>()),
        );
        expect(authSyncCount, 2);
        expect(callableCount, 1);
      },
    );

    test(
      'termina sessão quando o refresh confirma sessão local inválida',
      () async {
        var logoutCount = 0;

        final service = FunctionsService(
          null,
          appConfig: AppConfig.mockedTest(),
          authSessionSynchronizer: ({required forceRefresh}) async {
            if (!forceRefresh) {
              return const FunctionsAuthSession(
                uid: 'client-1',
                hasToken: true,
              );
            }
            return const FunctionsAuthSession.unauthenticated();
          },
          onAuthenticationFailure: () async {
            logoutCount += 1;
          },
          callableInvoker:
              <T>({
                required String name,
                String? region,
                Map<String, dynamic>? parameters,
              }) async {
                throw _TestFirebaseFunctionsException(
                  code: 'unauthenticated',
                  message: 'Auth required',
                );
              },
        );

        await expectLater(
          service.call<void>(name: 'requestSupportTicket'),
          throwsA(isA<FirebaseFunctionsException>()),
        );
        expect(logoutCount, 1);
      },
    );

    test(
      'preserva sessão quando a callable continua unauthenticated mas o refresh mantém auth válida',
      () async {
        var logoutCount = 0;

        final service = FunctionsService(
          null,
          appConfig: AppConfig.mockedTest(),
          authSessionSynchronizer: ({required forceRefresh}) async {
            if (!forceRefresh) {
              return const FunctionsAuthSession(
                uid: 'client-1',
                hasToken: true,
              );
            }
            return const FunctionsAuthSession(
              uid: 'client-1',
              hasToken: true,
            );
          },
          onAuthenticationFailure: () async {
            logoutCount += 1;
          },
          callableInvoker:
              <T>({
                required String name,
                String? region,
                Map<String, dynamic>? parameters,
              }) async {
                throw _TestFirebaseFunctionsException(
                  code: 'unauthenticated',
                  message: 'Auth required',
                );
              },
        );

        await expectLater(
          service.call<void>(name: 'requestSupportTicket'),
          throwsA(isA<FirebaseFunctionsException>()),
        );
        expect(logoutCount, 0);
      },
    );
  });
}

class _TestFirebaseFunctionsException extends FirebaseFunctionsException {
  _TestFirebaseFunctionsException({
    required super.code,
    required super.message,
  });
}
