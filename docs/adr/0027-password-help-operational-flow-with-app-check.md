# ADR 0027: Password Help Operacional com App Check

## Estado
Aceite

## Contexto
- O produto decidiu não usar reset por email no MVP.
- O fluxo precisava de anti-enumeração e visibilidade operacional para `admin|manager`.
- `manager` não deve ganhar leitura global de `users`.

## Decisão
- Implementar `Mudar palavra-passe` para utilizador autenticado com reautenticação obrigatória.
- Substituir o fluxo "Esqueci-me da palavra-passe" por callable público `requestPasswordHelp`.
- Aplicar `enforceAppCheck: true` em `requestPasswordHelp`.
- Em dev/debug, testar o fluxo com App Check debug provider + token registado na Firebase Console, sem relaxar enforcement no backend partilhado.
- Callable retorna sempre `{ ok: true, supportPhone? }` para evitar enumeração de contas.
- Persistir pedido em `supportRequests/{id}` (visível para `admin|manager`) e espelhar em `users/{uid}.support.passwordHelp` quando o documento do utilizador existir.
- Implementar callable autenticado `resolvePasswordHelpRequest` para resolver pedidos e sincronizar o espelho em `users/{uid}`.
- `config/support` contém o número operacional `supportPhone`, editável apenas por `admin`.

## Consequências
- Fluxo operacional mais previsível para suporte sem expor existência de contas.
- `manager` passa a resolver pedidos sem alargar permissões de leitura global de `users`.
- Dependência explícita de App Check para proteger callable público contra abuso automatizado.
- QA/dev continua a conseguir testar o fluxo sem bypass do callable, desde que o debug token App Check esteja registado.
- Sem alteração de regras de pricing/ledger ou contratos financeiros.

## Implementação de referência
- `functions/src/admin/buildAdminFunctions.ts`
- `functions/src/shared/notifications/fcmFanout.ts`
- `lib/features/auth/presentation/screens/change_password_screen.dart`
- `lib/features/auth/presentation/screens/forgot_password_screen.dart`
- `lib/features/admin/presentation/screens/admin_support_settings_screen.dart`
- `lib/features/admin/presentation/screens/support_requests_screen.dart`
- `firestore.rules`
