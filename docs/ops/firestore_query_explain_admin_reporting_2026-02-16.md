# Query Explain - Admin/Reporting (2026-02-16)

## Escopo aplicado
Top 3 queries de admin/reporting analisadas por frequência e custo percebido no código:
1. `reports.trips_by_started_at`
2. `reports.trips_by_completed_at`
3. `admin.audit_by_action_admin`

Fonte de execução: `scripts/ops/run_firestore_query_explain_admin_reporting.mjs`

## Resultados

| Query | Shape | Índice usado (Explain) | Scanned (index/docs) | Returned | Duration |
|---|---|---|---:|---:|---:|
| `reports.trips_by_started_at` | `trips` + `status in` + range em `startedAt` (`[from, to)`) + `orderBy startedAt, __name__` + `limit 20` | `(status ASC, startedAt ASC, __name__ ASC)` | `0 / 0` | `0` | `0.020828s` |
| `reports.trips_by_completed_at` | `trips` + `status in` + range em `completedAt` (`[from, to)`) + `orderBy completedAt, __name__` + `limit 20` | `(status ASC, completedAt ASC, __name__ ASC)` | `0 / 0` | `0` | `0.036094s` |
| `admin.audit_by_action_admin` | `audit` + range em `createdAt` + igualdade em `actionType` e `adminId` + `orderBy createdAt desc` + `limit 20` | `(actionType ASC, adminId ASC, createdAt DESC, __name__ DESC)` | `3 / 3` | `3` | `0.014722s` |

## Leitura técnica
- As 3 queries já resolvem para índices compostos corretos.
- Para relatórios operacionais de viagens concluídas, o campo de período recomendado é `completedAt` com janela temporal `[from, to)`.
- Não foi identificado padrão de `index_entries_scanned` desproporcional ao `resultsReturned`.
- Com os dados atuais, não há evidência de ganho material via novos índices.

## Ajustes de índice
- Nenhum índice novo foi necessário nesta execução.
- Índices existentes no `firestore.indexes.json` já cobrem os shapes avaliados.

## Impacto esperado
- Manutenção do custo de leitura previsível para estas queries.
- Evita-se churn de índices sem benefício demonstrável.

## Próxima ação operacional
- Reexecutar este playbook quando cardinalidade crescer (ex.: >10k documentos em `trips`/`audit`) e comparar baseline.
