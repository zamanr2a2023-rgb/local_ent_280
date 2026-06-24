# DEPRECATED — do not use

Documento arquivado para histórico.
Fonte oficial atual: docs/README.md.

# Plano de migração para Money `{amountMinor, currency}`

1. **Preparação**
   - Definir `settings/global.operationCurrency` (ex.: `EUR`).
   - Deploy de backend com validações que exigem `currency` explícita.

2. **Migração idempotente**
   - Executar `scripts/migrate_money_fields.ts`.
   - O script só escreve campos novos quando ainda não existem.
   - O script não remove campos legados `*Cents`, permitindo rollback controlado.

3. **Auditoria**
   - Qualquer alteração a `settings/global.operationCurrency` gera entrada em `audit` com `actionType=operation_currency_update`.
   - O script grava `before/after` para rastreabilidade.

4. **Validação pós-migração**
   - Confirmar que documentos críticos (`balances`, `tariffs`, `trips`) têm objetos `money` com moeda explícita.
   - Confirmar ausência de novos writes com payload sem `currency`.

5. **Limpeza**
   - Remover leitura de `*Cents` após janela de estabilização.
   - Executar backfill final e eliminar campos legados.
