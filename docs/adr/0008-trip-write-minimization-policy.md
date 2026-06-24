# ADR 0008: Política de Minimização de Writes em `trips/{tripId}`

- Data: 2026-02-16
- Estado: aceite

## Contexto
- O documento principal de viagem (`trips/{tripId}`) é observado por listeners ativos de cliente/motorista.
- Atualizações frequentes de campos operacionais (`meteringSnapshot`) aumentavam reads faturados e causavam churn de listeners.
- `updatedAt` era atualizado em writes operacionais que não impactam ordering/UX imediata.

## Decisão
- Introduzir política explícita de minimização para writes de metering:
  - throttling temporal e por mudança relevante;
  - manutenção de write imediato para snapshot final;
  - remoção de `updatedAt` em updates de `meteringSnapshot`.
- Manter sem alterações os writes de estado canónico e transições (state machine/callables).

## Consequências
- Redução de frequência de updates no doc principal durante viagem ativa.
- Menor churn de snapshots em listeners de `trips/{tripId}`.
- Sem alteração de transições de estado nem do workflow MVP.
