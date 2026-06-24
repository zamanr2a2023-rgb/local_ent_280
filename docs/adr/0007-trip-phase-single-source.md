# ADR 0007: TripPhase como Single Source para "Ativo vs Não Ativo"

- Data: 2026-02-16
- Estado: aceite

## Contexto
- O backend expõe `trips.isActive` e o cliente usava query ativa + validação adicional local.
- A validação local (`IsActiveTripState`) divergia dos estados aceites na query, gerando clears/re-subscribes e instabilidade visual.
- Cliente e motorista podiam interpretar o mesmo `TripState` de forma diferente para presença em ecrãs de "viagem ativa".

## Decisão
- Introduzir fase de domínio canónica (`TripPhase`) derivada de `TripState`/pagamento:
  - `pending`
  - `inProgress`
  - `postTripPendingPayment`
  - `finalized`
- Centralizar a regra em `DeriveTripPhase` e fazer `IsActiveTripState` delegar para esta regra.
- Aplicar a regra de fase em:
  - resolução de viagem ativa em `TripRepositoryImpl`;
  - controllers de cliente/motorista para clears de estado;
  - UI de motorista para decisão de mostrar ecrã de viagem ativa.

## Consequências
- Elimina drift funcional entre repository, controller e UI.
- Reduz thrash de listeners em transições adjacentes (ex.: `driverAssignedWaitingAcceptance` -> `driverAccepted`).
- Preserva o state machine e callables existentes; muda apenas interpretação no app.
