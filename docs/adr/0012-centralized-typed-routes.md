# ADR 0012: Rotas centralizadas e tipadas no Flutter

- **Estado**: Aceite
- **Data**: 2026-02-16

## Contexto

A navegação usava múltiplas strings literais (`'/...'`) espalhadas por ecrãs, guards e shells.
Esse padrão criava regressões silenciosas (typos, divergência entre `routes` e `pushNamed`) e dificultava refactors, especialmente no fluxo de viagens.

## Decisão

1. Introduzir um único catálogo de rotas em `AppRoutes`.
2. Substituir strings literais de navegação por constantes/métodos de `AppRoutes`.
3. Encapsular rotas dinâmicas de detalhe de viagem com builders e parsers tipados:
   - `clientTripDetail(tripId)` / `parseClientTripDetail(...)`
   - `driverTripDetail(tripId)` / `parseDriverTripDetail(...)`
   - `managerTripDetail(tripId)` / `parseManagerTripDetail(...)`
4. Adicionar verificação estática via script `scripts/check_no_literal_app_routes.dart` para bloquear a introdução de novas rotas literais fora do catálogo.

## Consequências

### Positivas

- Menos bugs de navegação por erro humano.
- Deep links do detalhe de viagem mantêm o comportamento atual, com parsing centralizado.
- Refactor de rotas passa a ser local e previsível.

### Trade-offs

- Nova obrigação de manter o catálogo `AppRoutes` atualizado.
- Check adicional no pipeline local/CI.

## Implementação inicial

- Migração completa de chamadas de navegação para `AppRoutes`.
- `MaterialApp.routes`, `initialRoute`, guards e redirecionamentos passam a consumir `AppRoutes`.
- Fluxos de viagem com detalhe dinâmico migrados para helpers tipados.
