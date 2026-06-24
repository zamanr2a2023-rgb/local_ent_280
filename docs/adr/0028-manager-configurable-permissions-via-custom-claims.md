# ADR 0028: Manager Configurable Permissions via Custom Claims

## Status
- Accepted

## Contexto
- O papel `manager` precisava de permissões configuráveis por utilizador, definidas por `admin`, com enforcement consistente em UI, Firestore Rules e callables.
- Requisito de segurança: evitar depender de dados mutáveis em Firestore como autoridade de autorização.
- Requisito operacional: reduzir regressões de query no Firestore (“rules are not filters”).

## Decisão
- Autoridade de segurança:
  - usar custom claims Firebase Auth com mapa compacto `mp`.
  - formato canónico: `{ role: "manager", mp: { vt: bool, ... } }`.
- Espelho de UI/admin:
  - persistir `users/{uid}.managerPermissions` apenas para inspeção/admin UX (`updatedAt`, `updatedBy`).
  - autorização nunca depende desse espelho.
- Atualização de permissões:
  - callable admin-only `setManagerPermissions`.
  - merge explícito de claims existentes.
  - validação de tamanho do payload final (`<= 1000 bytes`).
  - normalização de dependências:
    - `cs=>vt`, `ts=>vt`, `rp=>vs`, `av=>vd`, `me=>vd`.
- Manager sem `mp`:
  - default deny (bloqueado até configuração).
- Refresh runtime:
  - manual (`getIdToken(true)`) + foreground debounced (10 min).
  - quando hash de permissões muda, invalidar providers/listeners operacionais.
- Query safety:
  - no modo manager, evitar query mista para utilizadores.
  - `vc=false`: apenas drivers.
  - `vc=true`: duas queries (`driver` + `client`) com merge local.
  - ecrãs com escopo de produto específico continuam a filtrar localmente o resultado seguro; `Motoristas` mostra apenas perfis `driver`.

## Consequências
- Positivas:
  - enforcement coerente nas 3 camadas (UI, Rules, Callables).
  - menor risco de bypass por rota/chamada direta.
  - menor risco de `permission-denied` por query broad em manager.
- Trade-offs:
  - onboarding operacional exige configuração explícita de cada manager.
  - refresh de token é necessário para refletir alterações em runtime.

## Implementação associada
- App:
  - `manager_permissions_controller` + lifecycle binder + route guard.
  - ecrã admin `Permissões de managers`.
  - provider query-safe para utilizadores visíveis por manager.
- Functions:
  - helper `managerPermissionClaims`.
  - callable `setManagerPermissions`.
  - enforcement `cs` em `cancelTrip` e `rp` em `resolvePasswordHelpRequest`.
- Rules:
  - helpers `managerCan*` explícitos por permission code.
  - gates por coleção/ação com default deny para manager sem claims.
