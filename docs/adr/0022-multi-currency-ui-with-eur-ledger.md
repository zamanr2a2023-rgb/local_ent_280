# ADR 0022: Multi-moeda de UI com ledger EUR-only e FX administrado

- **Estado**: Aceite
- **Data**: 2026-03-05

## Contexto

O produto precisava permitir visualização e edição administrativa em `CVE`, `EUR` e `USD`, mantendo consistência financeira do MVP:

- regras de saldo e limite de dívida já assentam em EUR;
- payloads monetários persistidos usam `{ amountMinor, currency }`;
- usar `double` para FX e dinheiro introduz risco de precisão.

Também foi decidido não integrar provider externo de câmbio nesta fase.

## Decisão

1. Manter persistência monetária exclusivamente em EUR (`currency: "EUR"`).
2. Introduzir multi-moeda apenas na camada de apresentação/input:
   - `users/{uid}.uiCurrency` com valores permitidos `CVE|EUR|USD`;
   - default funcional `CVE`.
3. Definir FX administrado manualmente em `config/currency`:
   - `cveToEur`, `cveToUsd` (strings decimais);
   - `updatedAt`, `updatedBy`, `version?`.
4. Implementar motor de conversão fixed-point (racional com `BigInt`) e rounding half-up.
5. No admin, mostrar helpers inversos (`1 EUR ≈ ... CVE`, `1 USD ≈ ... CVE`) e metadados de atualização para reduzir erro de configuração.
6. Em falta/erro de FX para `CVE`/`USD`, fazer fallback de renderização para EUR com aviso não bloqueante no contexto admin.
7. Endurecer autorização:
   - self-update de `users/{uid}` limitado a `uiCurrency` + `updatedAt`;
   - escrita de `config/currency` apenas por `admin`.
8. Relatórios passam a tratar totais monetários em minor units inteiros no pipeline de dados.

## Consequências

### Positivas

- Consistência contabilística preservada (ledger único em EUR).
- UX multi-moeda sem impacto em contratos financeiros persistidos.
- Menor risco de drift/erro por precisão numérica.
- Guardrails explícitos para operação admin de FX.

### Trade-offs

- Dependência operacional de atualização manual de FX.
- Quando FX está inválido, `CVE`/`USD` não são efetivos até correção.
- Mais pontos de integração entre perfil do utilizador, formatação e regras.
