import 'package:local_ent_280/features/auth/data/auth_exception.dart';
import 'package:local_ent_280/l10n/app_localizations.dart';

extension AuthExceptionLocalization on AuthException {
  String localizedMessage(AppLocalizations l10n) {
    return switch (code) {
      AuthFailureCode.invalidCredentials => _invalidCredentialsMessage(l10n),
      AuthFailureCode.profileNotFound => l10n.authErrorProfileNotFound,
      AuthFailureCode.accountInactive => l10n.authErrorAccountInactive,
      AuthFailureCode.roleMismatch => l10n.authErrorRoleMismatch,
      AuthFailureCode.emailAlreadyInUse => l10n.authErrorEmailInUse,
      AuthFailureCode.weakPassword => l10n.authErrorWeakPassword,
      AuthFailureCode.registrationFailed => l10n.authErrorRegistrationFailed,
      AuthFailureCode.unknown => l10n.authErrorUnexpected,
    };
  }

  String _invalidCredentialsMessage(AppLocalizations l10n) {
    if (message == 'E-mail inválido.') {
      return l10n.authErrorInvalidEmail;
    }
    if (message == 'Esta conta está desactivada.') {
      return l10n.authErrorUserDisabled;
    }
    if (message == 'Demasiadas tentativas. Tente mais tarde.') {
      return l10n.authErrorTooManyRequests;
    }
    if (message == 'Não foi possível iniciar sessão. Tente novamente.') {
      return l10n.authErrorSignInFailed;
    }
    return l10n.authErrorWrongCredentials;
  }
}
