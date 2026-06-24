# ADR 0010: Callable Idempotency Policy

- Status: Accepted
- Date: 2026-02-16

## Context

As callables de transição de estado e de impacto financeiro podem ser invocadas em modo "at least once" (retry automático de cliente/rede/plataforma). Sem idempotência explícita, o sistema podia:
- duplicar registos de auditoria;
- repetir side effects operacionais;
- aumentar risco de regressões financeiras.

## Decision

Adotar política única de idempotência para callables críticas:
- Chave canónica: `${tripId}:${action}:${eventId}`.
- Se existir `idempotencyKey` no payload, essa chave tem prioridade.
- Sem `eventId`, fallback para `${tripId}:${action}:${requesterId}`.

Implementação:
- Guard de eventos processados em `trips/{tripId}/callableIdempotency/{idempotencyKey}`.
- Repetições retornam a resposta previamente persistida em vez de reaplicar side effects.
- Para `retry_payment`, manter `finalizeTripPayment` como proteção principal contra double charge e usar:
  - leitura/gravação da resposta por `idempotencyKey`;
  - registo de auditoria com docId determinístico (`trip_payment_retry_${tripId}_${idempotencyKey}`).

## Consequences

- Chamadas duplicadas convergem para o mesmo estado final.
- Redução de risco de duplicação de auditoria em endpoints críticos.
- Contrato operacional mais explícito para clientes (suporte a `idempotencyKey` e `eventId`).
