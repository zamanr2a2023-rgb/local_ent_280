# ADR 0023: Centralized Input Validation UX

## Status
Accepted — 2026-03-05

## Context
- As validações de input estavam distribuídas por ecrãs e controladores com comportamento inconsistente.
- Existiam campos com validação apenas via `SnackBar` ou apenas no submit, sem erro inline.
- Campos sensíveis de parsing (dinheiro/decimais/horas) tinham risco de fricção UX e inconsistências locale (`pt-PT`).
- Regras server-side já existem (use cases, validators de dados, Firestore Rules) e devem manter-se como fonte de autoridade.

## Decision
- Introduzir módulo central em `lib/core/presentation/validators/` com responsabilidades separadas:
  - `app_validators.dart`: validações reutilizáveis de campos e parsing decimal/money;
  - `app_input_formatters.dart`: formatters para inteiro, decimal locale-aware e slug;
  - `time_range_validators.dart`: normalização/validação de faixas horárias (incluindo overnight);
  - `form_focus_helper.dart`: foco/scroll para primeiro erro no submit;
  - `validation_limits.dart`: limites numéricos configuráveis.
- Padronizar formulários transacionais/operacionais com:
  - erro inline por campo;
  - submit desativado quando inválido;
  - foco no primeiro erro apenas no submit;
  - `AutovalidateMode.onUserInteraction` por default;
  - `AutovalidateMode.onUserInteractionIfError` em campos de parsing sensível.
- Aceitar `,` e `.` em inputs decimais e normalizar internamente.
- Manter validação server-side existente sem mover regras de negócio para UI.

## Consequences
- UX de formulários fica consistente entre Admin/Client/Driver/Manager.
- Reduz-se repetição de lógica inline e risco de divergência por ecrã.
- Parsing numérico locale-aware passa a ser previsível para utilizadores pt-PT.
- Regras críticas continuam protegidas no backend, com UI a atuar como guardrail de usabilidade.
