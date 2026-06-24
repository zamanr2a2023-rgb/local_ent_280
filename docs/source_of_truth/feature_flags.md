# Source of Truth: Feature Flags

## Objetivo do domínio
- Garantir uma única origem para ativação/desativação de capacidades de produto.
- Evitar drift de UX entre fluxos de cliente, motorista e administração.

## Origem canónica no código
- Config: `lib/app/config/app_feature_flags.dart`
- Injeção/consumo: `lib/app/application/providers/app_feature_flags_provider.dart`

## Catálogo atual
| chave | default | owner | propósito |
| --- | --- | --- | --- |
| `ENABLE_GOOGLE_MAPS` | `true` (mobile) / `false` (web) | Mobile Platform | Controlar ativação de funcionalidades dependentes de Google Maps. |
| `ENABLE_TRIP_EXTENSION_WINDOW_PHASE` | `false` | Trips Product | Controlar exposição de ações de janela de extensão em fluxos ativos de viagem. |

## Regras de uso
- Flags só podem ser lidas via `appFeatureFlagsProvider`.
- É proibido declarar flags locais por ecrã (`const bool` local).
- Quando uma flag afeta múltiplos papéis, a decisão deve ser partilhada entre os fluxos para garantir UX consistente.
