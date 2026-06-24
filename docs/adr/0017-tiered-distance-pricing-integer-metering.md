# ADR 0017: Tarifário por faixas de distância com cálculo inteiro em metros

- **Estado**: Aceite
- **Data**: 2026-02-20

## Contexto

O pricing de distância era baseado num único `perKm` e cálculo com `double/Number`.
Isto aumentava risco de drift entre app (Dart) e backend (TypeScript), sobretudo em valores fracionários.
Também existia risco operacional de divergência entre a tarifa editada no admin e a tarifa pública consumida na estimativa/cobrança.
Além disso, a configuração administrativa de multiplicadores temporais precisava suportar múltiplos períodos sem ambiguidade operacional e acumulação determinística com feriados.

## Decisão

1. Introduzir `distanceTiers` em `Tariff` e `TripPricingSnapshot`.
2. Definir semântica canónica das faixas:
   - `startMetersInclusive` (inclusivo)
   - `endMetersExclusive` (exclusivo)
   - última faixa aberta (sem `endMetersExclusive`)
3. Calcular custo de distância com inteiros (`totalMeters`) e `round half up` por faixa:
   - `roundHalfUp(metersInTier * perKmMinor / 1000)`
4. Cobrança final usa sempre `trips.pricingSnapshot` persistido na criação da viagem.
5. `tariffs/admin_default` é a única fonte editável; `tariffs/public_default` é espelhado por trigger idempotente.
6. `perKm` mantém-se temporariamente por compatibilidade de leitura/escrita durante transição.
7. `Tariff.multiplierRules` para `time_range` adota contrato canónico:
   - `1..5` períodos configuráveis por admin;
   - sem sobreposição, incluindo períodos overnight;
   - semântica temporal `start` inclusivo / `end` exclusivo;
   - IDs de regra existentes preservados em edições;
   - novos IDs determinísticos para novos períodos (`time_range_HHMM_HHMM` + sufixo quando necessário);
   - multiplicador validado no intervalo `0.50..3.00`.
8. O pricing lock passa a persistir composição canónica de multiplicadores:
   - `combinedMultiplier = transport × time_range × holiday`;
   - reservas avaliam `scheduledAt` como instante absoluto projetado para `Europe/Lisbon`;
   - a composição fica congelada no `TripPricingSnapshot`.
9. A aritmética de multiplicadores usa fixed-point determinístico em Dart e TypeScript, sem `double/Number` como fonte canónica do cálculo monetário.

## Consequências

### Positivas

- Redução de drift financeiro entre app e backend.
- Maior previsibilidade em limites de faixa e arredondamentos.
- Menor risco de divergência entre tarifário administrativo e tarifário público.
- Melhor auditabilidade com `distanceTiers`, `tariffId` e `tariffUpdatedAt` no snapshot.
- Configuração horária de multiplicadores previsível, sem ambiguidades de overlap e com estabilidade de IDs para auditoria.
- Menor drift entre preview, ativação de reservas, receipt e reporting em cenários com `time_range + holiday`.

### Trade-offs

- Contrato de pricing fica mais rico e exige validação adicional em UI, app e backend.
- Há duplicação controlada da lógica de cálculo em Dart e TS, mitigada por dataset comum de paridade.
