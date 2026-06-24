# ADR 0009: Tiering de Runtime para Callables de Trips

- Data: 2026-02-16
- Estado: aceite

## Contexto
- `minInstances: 1` aplicado de forma ampla aumenta custo base 24/7 sem benefício uniforme.
- Nem todos os callables têm a mesma sensibilidade a cold start.

## Decisão
- Definir dois perfis de runtime para callables:
  - `CRITICAL_CALLABLE_RUNTIME_OPTIONS`: `minInstances: 0`, `concurrency: 40`.
  - `STANDARD_CALLABLE_RUNTIME_OPTIONS`: `minInstances: 0`, `concurrency: 40`.
- Manter tiering por organização/configuração, mas sem reserva mínima ativa.
- Endpoints críticos de conversão/segurança:
  - `requestTrip`, `transitionTripState`, `cancelTrip`.
- Aplicar perfil standard nos restantes callables de trips:
  - `retryTripPayment`, `requestTripExtension`, `respondTripExtension`, `handleTripFinancialAction`.

## Consequências
- Redução do custo baseline por remoção de instâncias reservadas.
- Potencial aumento de cold starts nos endpoints críticos.
- Necessidade de monitorizar p95 pós-rollout em todos os callables.
