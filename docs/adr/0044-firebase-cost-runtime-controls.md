# ADR 0044: Firebase Cost Runtime Controls

- Data: 2026-04-26
- Estado: aceite

## Contexto
- Workflows operacionais estavam dependentes de polling frequente, triggers amplos em `trips/{tripId}` e writes vivos no documento principal da viagem.
- Estes padrões aumentam invocações de Functions e reads faturados em listeners Firestore.

## Decisão
- Timeouts de aceitação de motorista e extensão pós-cobrança passam a usar Cloud Tasks com IDs hash e payload idempotente.
- Schedulers de fallback correm a cada 15 minutos e apenas recuperam itens vencidos por campos de due queue.
- `userRuntime/{uid}` passa a ser o read model backend-owned para descoberta barata de viagem ativa.
- Metering vivo passa para `trips/{tripId}/metering/current`; o documento principal recebe apenas snapshots finais.
- Fanout FCM passa a preferir `notificationTargets/{uid}/tokens/{tokenHash}` com fallback legado temporário.
- Monitorização operacional full fica `enabled=false` por default e só carrega config após confirmar janela operacional ativa.

## Consequências
- Menos polling recorrente e menos churn no documento principal de viagem.
- Regras e docs precisam manter contratos explícitos para subcoleções, porque acesso não é herdado implicitamente.
- Fallbacks legados permanecem durante rollout e devem ser removidos após validação em dev/emulator.

## Implementação de referência
- `functions/src/trips/buildTripsFunctions.ts`
- `functions/src/schedules/buildSchedules.ts`
- `functions/src/operations/buildOperationalMonitoringFunctions.ts`
- `functions/src/shared/notifications/fcmFanout.ts`
- `firestore.rules`
- `lib/features/trips/data/repositories/trip_repository_impl.dart`
