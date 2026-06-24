# ADR 0024: Consistent List Filtering Pattern

## Estado
Aceite

## Data
2026-03-05

## Contexto
As listas críticas (cliente, motorista, manager, relatórios e auditoria) tinham padrões diferentes de filtros e ordenação, causando:
- UX inconsistente em mobile;
- maior custo de manutenção de lógica de filtros;
- risco de queries pesadas ao filtrar tudo localmente.

A aplicação ainda está em pré-release, permitindo simplificar e padronizar sem carga de compatibilidade legado em UI.

## Decisão
Adotar um padrão único de filtros em listas:
- barra superior com:
  - pesquisa textual (quando aplicável);
  - chips rápidos;
  - menu de ordenação;
- filtros avançados em bottom sheet com ações `Limpar` e `Aplicar`.

Estratégia de dados híbrida:
- Firestore para filtros indexáveis e ordenação (`where`, `orderBy`, `limit`, cursor).
- Pesquisa textual `contains` aplicada localmente sobre os resultados carregados.

Estratégia de scroll/layout para listas filtráveis:
- `AppBar` fixa;
- cabeçalho, filtros e resultados no mesmo scroll vertical do ecrã;
- evitar nested scrolling vertical (`Column + Expanded + ListView`) em ecrãs compactos;
- quando existirem tabelas largas, o scroll horizontal fica local ao bloco da tabela e o scroll vertical mantém-se no ecrã inteiro.

Persistência de filtros por ecrã (SharedPreferences):
- ativa para:
  - `clientTrips`, `driverTrips`, `clientReservations`, `adminReports`, `adminAudit` (Fase 1);
  - `adminUsers`, `adminFleet`, `adminBalances` (Fase 2).
- `managerTrips` e `placeSelection` ficam sessão-only.

## Consequências
### Positivas
- UX consistente entre papéis e ecrãs.
- Menor carga cognitiva e descoberta mais rápida de dados.
- Melhor usabilidade em mobile compacto, sem sub-áreas de scroll difíceis de descobrir.
- Contratos de query explícitos e previsíveis para QA/ops.
- Redução de risco de regressões por lógica duplicada de filtros.

### Custos / trade-offs
- Necessidade de novos índices compostos Firestore para suportar `ASC|DESC` com filtros por estado.
- Pesquisa textual local pode não cobrir datasets muito grandes sem paginação adequada.
- Persistência local exige gestão de versão/limpeza de estado em futuras mudanças de contrato.

## Implementação
- Componentes reutilizáveis:
  - `lib/app/ui/components/list_filters/filter_bar.dart`
  - `lib/app/ui/components/list_filters/filters_bottom_sheet.dart`
- Persistência local:
  - `lib/core/services/preferences/list_filters_preferences_service.dart`
- Fase 2 (extensão do padrão):
  - `lib/features/admin/presentation/providers/admin_users_filters_provider.dart`
  - `lib/features/admin/presentation/providers/admin_fleet_filters_provider.dart`
  - `lib/features/admin/presentation/providers/admin_balances_filters_provider.dart`
  - `lib/features/client/presentation/widgets/place_selection_view.dart` (filtro leve `Recentes/Favoritos`)
- Matriz operacional/QA:
  - `docs/ops/list_filters_matrix.md`

## Fora de escopo
- Full-text search server-side (Algolia/Elastic ou equivalente).
