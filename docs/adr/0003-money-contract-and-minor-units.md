# ADR 0003: Contrato Monetário e Minor Units por Moeda

- Data: 2026-02-16
- Estado: aceite

## Contexto
- Havia coexistência de campos legados `*Cents` e payloads monetários novos.
- O MVP exige contrato financeiro consistente entre app e backend.
- Moedas têm expoentes de minor unit diferentes (0, 2, 3), o que invalida suposições fixas de `/100`.

## Decisão
- Canonicalizar payload monetário como:
  - `{ amountMinor: int, currency: string }`
- Definir catálogo explícito de metadados monetários no domínio:
  - `EUR` expoente `2`
  - `JPY` expoente `0`
  - `BHD` expoente `3`
  - (incluídas também `USD` e `GBP` com expoente `2`)
- Regras obrigatórias:
  - `currency` é sempre obrigatório.
  - Operações aritméticas só entre valores da mesma moeda.
  - Formatação é feita apenas no edge (UI/serviços de apresentação), nunca no value object.
  - Runtime ativo não usa compat mode para campos legados monetários.
  - Payloads legados (`*Cents`) são rejeitados em callables e paths críticos.

## Consequências
- Evita erros de arredondamento e inconsistência multi-moeda.
- Torna validações de backend e frontend equivalentes.
- Facilita expansão futura para outras moedas sem quebrar contrato.
- Reduz ambiguidade operacional ao manter um único contrato monetário ativo.
