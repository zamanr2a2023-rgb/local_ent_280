# TTL Hardening - Functions/Triggers (2026-02-16)

## Inventário de coleções com TTL
Fonte: `firestore.indexes.json` (`fieldOverrides.ttl=true`)

- `jobs.expiresAt`
- `events.tripEventExpiresAt` (collectionGroup `events`)
- `pathPoints.pathPointExpiresAt`
- `users/{uid}/fcmTokens.tokenExpiresAt` (collectionGroup `fcmTokens`)

## Triggers potencialmente afetados
- Trigger encontrado sobre `events/{eventId}`:
  - `notifyDriverOnAdminEventCreation` em `functions/src/trips/buildTripsFunctions.ts`
- Não foram encontrados triggers `onDelete/onWrite` diretos para:
  - `pathPoints`
  - `fcmTokens`
  - `jobs`

## Endurecimentos aplicados

### 1) Trigger `events/{eventId}` resiliente a remoção TTL/manual
- Antes de avaliar e enviar lembrete, o trigger recarrega snapshot fresco do documento.
- Se o documento já não existir, sai com `info` (sem erro/retry em cascata).
- Ao atualizar `reminderSentAtByOffsetMinutes.<offset>`, trata `not-found` explicitamente.

### 2) Job de lembretes (`sendScheduledEventNotificationsJob`)
- Para cada evento candidatado, recarrega snapshot fresco antes do envio.
- Se o documento desaparecer entre query e envio/update, trata como cenário esperado (TTL/manual delete) e continua.
- Update de estado pós-envio também trata `not-found` explicitamente.

## Objetivo operacional atingido
- Evita cascatas de erro quando docs são removidos por TTL.
- Reduz risco de trabalho duplicado por retries com snapshot stale.
- Mantém retenção TTL existente (sem alterar política de expiração).
