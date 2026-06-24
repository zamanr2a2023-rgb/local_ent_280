# ADR 0004: State Machine de Viagem com Single Source

- Data: 2026-02-16
- Estado: aceite

## Contexto
- Regras de transição de viagem existiam em Dart e TypeScript, com risco de drift.
- Divergência de transições causa inconsistência entre UX e backend crítico.

## Decisão
- Definir matriz canónica em:
  - `contracts/trip_state_machine/transitions.json`
- Manter implementações específicas em:
  - `lib/features/trips/domain/services/trip_state_machine.dart`
  - `functions/src/trips/tripStateMachineCallables.ts`
- Adicionar verificação de paridade:
  - `scripts/check_trip_state_parity.dart`
  - comparando Dart vs TS vs JSON canónico.
- Paridade passa a ser quality gate obrigatório em CI.

## Consequências
- Qualquer drift entre app e backend falha cedo no pipeline.
- Transições críticas ficam auditáveis num único contrato legível.
- Mudanças de workflow ficam mais seguras e rastreáveis.
