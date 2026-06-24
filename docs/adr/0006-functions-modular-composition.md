# ADR 0006: Modularização de Firebase Functions com Composition Root

- Data: 2026-02-16
- Estado: aceite

## Contexto
- `functions/src/index.ts` acumulava inicialização, utilitários, regras de negócio e wiring de triggers/callables.
- Em ESM, imports estáticos são avaliados antes do corpo do módulo. Isso cria risco de `setGlobalOptions(...)` não ser aplicado como esperado quando handlers são construídos no import-time.
- O módulo monolítico aumentava acoplamento acidental e custo de manutenção.

## Decisão
- Definir `functions/src/index.ts` como único composition root.
- Aplicar `setGlobalOptions(...)` antes de construir qualquer handler.
- Adotar padrão obrigatório de factories (`buildX(...)`) para módulos de domínio e schedules.
- Centralizar inicialização Admin SDK em `functions/src/bootstrap/firebase.ts`.
- Centralizar wrappers `onSchedule(...)` em `functions/src/schedules/buildSchedules.ts`.
- Impor regra explícita de runtime:
  - sem construção de handlers no import-time;
  - sem IO/queries no import-time;
  - escopo global limitado a constantes, tipos e funções puras.

## Consequências
- Redução do risco de footgun de ordem de inicialização (`setGlobalOptions` + import estático).
- Entry point fica legível e previsível.
- Funções passam a ser compostas de forma explícita no root, facilitando evolução por domínio.
- Cold start melhora por evitar trabalho pesado no carregamento de módulo.
