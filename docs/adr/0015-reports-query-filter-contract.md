# ADR 0015: Contrato de filtros e queries de relatórios no domínio

- **Estado**: Aceite
- **Data**: 2026-02-17

## Contexto

Os relatórios administrativos deixaram de ser um único `Resumo` agregado.
Agora coexistem:
- `Panorama Operacional` com vistas `Detalhe`, `Cliente`, `Motorista`, `Viatura`, `Período`;
- `Extrato do Cliente`;
- `Extrato do Motorista`.

Os novos requisitos exigem consistência entre:
- visualização;
- drill-through;
- exportação `CSV`/`XLSX`.

Sem um contrato de domínio explícito, os filtros poderiam ficar implícitos no UI ou duplicados entre componentes.

## Decisão

1. Manter `ReportQuery` como contrato agregado para as vistas agrupadas do `Panorama Operacional`.
2. Incluir no domínio:
   - `debtFilter` com enum `ReportDebtFilter` (`all`, `withDebt`, `withoutDebt`);
   - `driverSearchText`;
   - `vehicleSearchText`.
3. Introduzir contratos específicos para datasets especializados:
   - `TripExplorerQuery` para o dataset de detalhe/evidência;
   - `ClientStatementQuery` para o ledger do cliente, com `clientId` opcional para suportar âmbito global ou cliente exato;
   - `DriverStatementQuery` para o extrato operacional bruto do motorista, com `driverId` opcional para suportar âmbito global ou motorista exato.
4. `TripExplorerQuery` passa a suportar filtros exatos de drill-through:
   - `exactClientId`
   - `exactDriverId`
   - `exactVehicleId`
5. Aplicar filtros no repositório (`Data`) antes da agregação/exportação.
6. O mesmo estado estruturado de filtros alimenta tabela, KPIs, drill-through e export.

## Consequências

### Positivas

- Regras de filtragem centralizadas e auditáveis.
- Consistência entre resultado apresentado e exportado.
- Separação clara por camada (UI captura, domínio define contrato, data executa).
- O `Panorama Operacional` consegue alternar entre vistas agrupadas e detalhe sem criar contratos ad-hoc no Presentation.

### Trade-offs

- Continua a existir um teto operacional de `5000` linhas antes de exportar.
- Filtros textuais contextuais ainda dependem dos snapshots legíveis disponíveis no dataset operacional atual.
- Regras contextuais de drill-through e visibilidade exigem mapeamento explícito para evitar drift de estado.
