# Firestore Query Explain Playbook

## Objetivo
- Medir custo real das queries antes de alterar índices.
- Evitar mudanças de índice sem evidência (`scanned >> returned`).

## Pré-requisitos
- `gcloud` autenticado no projeto alvo.
- Permissão de leitura Firestore no ambiente alvo.
- Projeto definido por `FIRESTORE_PROJECT_ID` (default: `local-transport-482015`).

## Processo
1. Selecionar queries candidatas:
   - alta frequência (streams/listas de admin/reporting);
   - perceção de lentidão;
   - docs retornados potencialmente altos.
2. Capturar baseline com Query Explain (`analyze=true`):
   - índice usado;
   - `index_entries_scanned`;
   - `documents_scanned`;
   - `resultsReturned`;
   - `executionDuration`.
3. Diagnosticar:
   - saudável: `index_entries_scanned` próximo de `resultsReturned`.
   - suspeito: `index_entries_scanned` muito acima de `resultsReturned`.
4. Ajustar apenas o necessário:
   - confirmar shape da query;
   - adicionar/ajustar índice composto mínimo.
5. Re-executar Query Explain e comparar baseline vs after.
6. Registar resultado em `docs/ops/` com query shape, índice e impacto.

## Script padrão (admin/reporting)
- Executar:

```bash
node scripts/ops/run_firestore_query_explain_admin_reporting.mjs
```

- Saída:
  - JSON com `generatedAt` e resumo por query (`index`, `scanned`, `returned`, `duration`).

## Guardrails
- Não introduzir mudanças de schema para otimização de índice.
- Limitar alterações a índices e shape de query estritamente necessários.
- Validar sempre no mesmo ambiente (ex.: staging) para comparação coerente.
