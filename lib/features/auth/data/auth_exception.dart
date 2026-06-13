enum AuthFailureCode {
  invalidCredentials,
  profileNotFound,
  accountInactive,
  roleMismatch,
  emailAlreadyInUse,
  weakPassword,
  registrationFailed,
  unknown,
}

class AuthException implements Exception {
  const AuthException({
    required this.code,
    required this.message,
  });

  final AuthFailureCode code;
  final String message;

  factory AuthException.unknown() => const AuthException(
        code: AuthFailureCode.unknown,
        message: 'Ocorreu um erro inesperado. Tente novamente.',
      );

  @override
  String toString() => message;
}