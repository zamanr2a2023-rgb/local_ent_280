# ADR 0019: Extensão Pós-Cobrança como Sub-workflow em `Trip`

## Estado
Aceite

## Contexto
- O produto passou a exigir extensões repetíveis após a cobrança principal da viagem.
- O `TripState` canónico já termina em `CHARGE_APPLIED`, e é usado em queries, listeners e regras de negócio amplamente distribuídas.
- Alterar o state machine canónico para suportar ciclos repetidos de extensão aumentaria risco de regressão e drift entre app/backend.

## Decisão
- Modelar extensões pós-cobrança em `trips/{tripId}.postChargeExtension` como sub-workflow separado.
- Manter `TripState` canónico inalterado (`CHARGE_APPLIED` continua estado final da viagem).
- Persistir `schemaVersion` e `nextActionAt` no sub-workflow para:
  - evolução de contrato;
  - sweep eficiente por índices compostos (`status + nextActionAt`).
- Usar cobrança por ciclo com ledger determinístico (`trip_{tripId}_extension_{cycleIndex}`) e transações Firestore multi-doc com `driverStatus`.

## Consequências
### Positivas
- Minimiza regressões no state machine canónico e nos listeners existentes.
- Mantém a nova funcionalidade isolada e evolutiva.
- Facilita idempotência e processamento por scheduler (`at least once`).

### Negativas
- Coexistência temporária com `extensionWindow` legado aumenta complexidade documental e de UI.
- Documento `trips/{tripId}` passa a agregar mais estado; exige disciplina para evitar crescimento excessivo.

## Implementação de referência
- `functions/src/trips/buildTripsFunctions.ts`
- `firestore.rules`
- `lib/features/trips/domain/entities/trip_post_charge_extension_*.dart`
- `lib/features/trips/data/mappers/trip_firestore_mapper.dart`
