# ADR 0033: Workspace de relatórios export-first e roadmap para read model dedicado

## Estado
Aceite

## Contexto
- A versão anterior de `/admin/reports` misturava três conceitos diferentes:
  - resumo agregado;
  - explorador de viagens com export parcial dos resultados já carregados;
  - extrato de cliente também dependente da janela carregada.
- O objetivo operacional real evoluiu para um workspace onde o admin consegue:
  - explorar o dataset com filtros reproduzíveis;
  - alternar entre lentes `cliente`, `motorista`, `viatura` e `período`;
  - exportar um ficheiro defensável com metadados de proveniência.
- Continuamos sem read model dedicado externo; nesta fase o Firestore operacional mantém-se como fonte.

## Decisão
- Manter uma shell única `/admin/reports` com três workspaces:
  - `Panorama Operacional`
  - `Extrato do Cliente`
  - `Extrato do Motorista`
- `Panorama Operacional` passa a ser o ponto de entrada analítico e contém cinco modos first-class:
  - `Detalhe`
  - `Por Cliente`
  - `Por Motorista`
  - `Por Viatura`
  - `Por Período`
- O source of truth da exportação passa a ser `workspace/mode + filtros estruturados`, nunca a página carregada ou as colunas visíveis.
- O contrato de filtros distingue:
  - `source filters`, suportados pela query base desta fase e capazes de definir um universo exportável com confiança;
  - `materialized filters`, aplicados sobre o dataset já materializado localmente por snapshots/pós-filtragem.
- O workspace usa contratos ricos e estáveis:
  - `TripExplorerRecord` como dataset de evidência;
  - `OperationalReportSummary` e `OperationalReportGroupRow` para a camada agrupada;
  - `ClientStatementEntry` e `ClientStatementReconciliation` para o extrato do cliente;
  - `DriverStatementEntry` e `DriverStatementSummary` para o extrato do motorista.
- Exportação é format-agnostic:
  - builders de dataset por workspace/mode;
  - serializers `CSV` e `XLSX`;
  - serviço de ficheiro injetado para share/download.
- Cada export carrega metadados de proveniência (`reportId`, `schemaVersion`, `workspace`, `mode`, `selectedEntity`, `period`, `timezone`, `generatedAt`, `generatedBy`, `filtersApplied`, `rowCount`, `sourceState`, `exportScope`, `disclaimer`).
- O dataset exportável fica limitado a `5000` linhas/grupos por operação; acima disso, o UI bloqueia a exportação e pede refinamento de filtros.
- Quando existirem `materialized filters`, a UI assume explicitamente leitura exploratória sobre dataset materializado.
- A exportação principal só é permitida quando o dataset relevante estiver materializado por completo dentro do teto; a app não emite ficheiros parciais/ambíguos como se fossem universo completo.
- Drill-through:
  - qualquer linha agrupada em `Panorama Operacional` reabre `Detalhe` com o filtro exato da entidade e o mesmo período.
- Roadmap Fase 2 mantém:
  - Algolia para pesquisa textual/facetada global;
  - BigQuery/read models para analytics extensos, reconciliação histórica pesada e exports acima do teto atual.

## Consequências
- O reporting fica alinhado com o objetivo de exploração + export reproduzível sem depender de paginação visível.
- `Viatura` continua first-class dentro do workspace, sem exigir um quarto ecrã dedicado.
- O custo/latência de export continua bounded pelo teto de `5000` linhas.
- A app passa a distinguir melhor:
  - relatório operacional;
  - extrato de cliente;
  - extrato operacional bruto de motorista.
- A transição futura para Algolia/BigQuery/read models continua possível sem redesenhar a UI nem quebrar os contratos de apresentação.

## Read model mínimo da Fase 2
- Algolia:
  - índice `trip_explorer_index`
  - campos mínimos: `tripId`, `status`, `transportType`, `requestedAt`, `startedAt`, `completedAt`, `clientId`, `clientName`, `driverId`, `driverName`, `vehicleId`, `vehicleName`, `vehiclePlate`, `pickupAddress`, `destinationAddress`, `hasDebt`, `hasPostChargeExtension`
- BigQuery:
  - `fact_trips`
  - `fact_trip_extension_cycles`
  - `fact_client_ledger`
  - `dim_clients`
  - `dim_drivers`
  - `dim_vehicles`

## Alternativas rejeitadas
- Full-scan do histórico Firestore com pesquisa e relações calculadas integralmente em memória.
  - Rejeitado por custo, latência, limites de query e degradação previsível da UX.
- Manter exportação parcial baseada apenas em “resultados carregados”.
  - Rejeitado por produzir ficheiros não reproduzíveis e fracos para reconciliação/suporte.
- Criar desde já uma stack completa de reporting externo antes de entregar esta fase.
  - Rejeitado por aumentar demasiado o escopo e atrasar o ganho operacional imediato.
