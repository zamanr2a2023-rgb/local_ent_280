# ADR 0032: Remove Weekday Tariff Multiplier

## Status
Accepted

## Context
- O contrato de tarifário ainda suportava três tipos de multiplicador: semanal, `time_range` e `holiday`.
- O produto já não precisa de multiplicador semanal e pretende simplificar o contrato ativo sem compatibilidade legacy.

## Decision
- Remover o multiplicador semanal do domínio de pricing, do contrato Firestore e da UI administrativa de tarifário.
- Manter apenas:
  - `time_range`
  - `holiday`
- A composição de resolução do multiplicador passa a ser:
  - `combinedMultiplier = transport × time_range × holiday`
  - fatores ausentes usam `1.0`
  - o pricing lock persiste a proveniência de `time_range` e `holiday` no snapshot.

## Consequences
- `TariffMultiplierRule` deixa de transportar o campo semanal legado.
- `TariffValidator` passa a rejeitar o tipo semanal legado e o respetivo campo de dias no contrato ativo de tarifário.
- O ecrã de tarifário deixa de renderizar controlos semanais e a auditoria deixa de persistir payload semanal.
