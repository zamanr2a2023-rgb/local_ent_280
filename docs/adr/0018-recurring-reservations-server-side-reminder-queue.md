# ADR 0018: Reservas recorrentes server-side com reminder queue e claim transacional

- **Estado**: Aceite
- **Data**: 2026-02-20

## Contexto

O fluxo de reservas suportava apenas ocorrências isoladas e tinha riscos para produção ao escalar recorrência:

- recorrência sem contrato temporal explícito (timezone/hora local) introduz drift em DST;
- geração e gestão de múltiplas ocorrências no cliente aumenta risco de falhas parciais;
- reminders com varrimento amplo por janela temporal aumentam leituras e custo;
- retries/execuções paralelas exigem deduplicação forte para evitar envios duplicados.

## Decisão

1. Introduzir `reservationSeries/{seriesId}` como entidade canónica de recorrência.
2. Materializar ocorrências em `reservations/{reservationId}` com ID determinístico `${seriesId}_${YYYYMMDD}`.
3. Tornar create/update/cancel de séries backend-only via callables:
   - `createRecurringReservationSeries`
   - `updateRecurringReservationSeries`
   - `cancelRecurringReservationSeries`
4. Definir contrato temporal explícito da série:
   - `timeZone`, `localTime`, `startDateLocal`, `endDateLocal`, `daysOfWeek`.
5. Adotar política DST:
   - hora inválida avança para o próximo minuto válido;
   - hora ambígua usa a primeira ocorrência local.
6. Usar `BulkWriter` para criação/regeneração/cancelamento em volume.
7. Migrar reminders para fila por `nextReminderAt` com job minutely em janela curta `now-2m .. now+1m`.
8. Implementar dedupe por claim transacional com lease/reclaim:
   - `reminderClaim = { claimId, claimedAt, leaseExpiresAt }`, lease default `3m`.
9. Enviar push reminder com `notification + data` e contrato `type=client.reservation_reminder`.
10. Preservar ativação diária de reservas às `05:00` com timezone explícita `Europe/Lisbon`.

## Consequências

### Positivas

- Recorrência robusta em mudanças DST.
- Menor custo e melhor escalabilidade no job de reminders.
- Menor fragilidade operacional ao remover writes volumosos do cliente.
- Melhor idempotência perante retries e concorrência de schedulers/functions.
- Gestão future-only reduz risco de regressão no histórico.

### Trade-offs

- Complexidade adicional no backend (callables + geração + claim lifecycle).
- Contrato de dados das ocorrências fica mais rico e exige validação/regras mais estritas.
- Índices Firestore passam a ser parte crítica do throughput do reminder job.
