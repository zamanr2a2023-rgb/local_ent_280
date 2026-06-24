# ADR 0031: Remove Minute Pricing from Trip Fare

## Status
Accepted

## Context
- O contrato ativo ainda cobrava tempo de deslocação normal através de campos monetários específicos para duração.
- O domínio já distinguia espera faturável (`perWaitMinute`) e extensão pós-cobrança (`postChargeExtension`), mas coexistia com uma semântica temporal ambígua.
- A app ainda não está em produção, a base de dados pode ser resetada e não existe requisito de compatibilidade legacy.

## Decision
- Remover do contrato ativo toda a componente monetária de tempo em deslocação normal, incluindo campos de tarifário, snapshot, receipt e descontos dedicados ao tempo de movimento.
- A viagem principal passa a usar apenas:
  - `baseFare`
  - `distanceCharge`
  - `waitCharge`
  - penalizações / sobretaxas já existentes
- O multiplicador incide apenas sobre `baseFare + distanceCharge + waitCharge`.
- `tripDuration`, `elapsedTime`, timestamps e métricas operacionais continuam a ser persistidos, reportados e exibidos, mas não influenciam o total monetário.
- A extensão pós-cobrança passa a ter semântica explícita de ocupação/espera após chegada e após a cobrança principal:
  - usa `pricingSnapshot.perWaitMinute`
  - persiste `waitRateApplied`, `billedMinutes` e `chargedAmount`
  - não recebe multiplicadores, descontos nem sobretaxas

## Consequences
- O contrato de pricing fica mais simples e inequívoco.
- Preview, receipt, reports, admin UI e validators deixam de expor preço por minuto.
- O backend mantém-se como fonte autoritativa do cálculo, com a mesma regra partilhada pelo preview informativo.
- Fixtures, seeds e documentação têm de ser mantidos sem referências ao modelo antigo para evitar drift.
