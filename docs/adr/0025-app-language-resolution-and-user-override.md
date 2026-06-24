# ADR 0025: App Language Resolution and User Override

## Estado
Atualizado

## Data
2026-03-05

## Atualização
2026-04-28

## Contexto
A app estava funcionalmente limitada a português, com locais hardcoded (`pt_PT`/`pt-PT`) em partes da UI e integrações de mapas.
Isso impedia:
- seleção de idioma em runtime;
- comportamento consistente de fallback;
- alinhamento entre locale da app e `language` usado nas chamadas Places/Directions.

Como o produto está em pré-release, a estratégia adotada prioriza simplicidade operacional sem migrações de perfil cross-device nesta fase.

## Decisão
Adotar um modelo de idioma com três locales suportados:
- `en`
- `pt_PT`
- `es`

Regras de resolução:
- sem preferência guardada: usar `pt_PT` como locale primário do produto;
- `pt-*` resolve para `pt_PT`;
- locale não suportado resolve para fallback `pt_PT`.

Preferência do utilizador:
- override manual persistido apenas localmente (SharedPreferences);
- ação explícita para repor o idioma predefinido da app (limpa override);
- sem persistência em `users/{uid}` nesta fase.

Contratos de apresentação:
- copy owned pela app é resolvida em `AppLocalizations` dentro de widgets/presenters de Presentation;
- providers/controllers não guardam mensagens localizadas em estado, apenas códigos/estados tipados;
- conteúdo authored e persistido (por utilizador/admin/backend) é mostrado como foi guardado e não é traduzido pela troca de idioma.

Integrações externas:
- centralizar mapeamento BCP-47 para APIs com output estrito:
  - `en`
  - `pt-PT`
  - `es`

## Consequências
### Positivas
- Troca de idioma em runtime sem reinício.
- Fallback determinístico e previsível para `pt_PT`.
- O primeiro arranque fica alinhado com o requisito atual de copy pt-PT, independentemente do idioma do dispositivo.
- Alinhamento entre UI locale e idioma enviado para serviços de mapas.
- Redução de drift por remoção de hardcodes de locale.
- Locale reativo em erro/loading/empty states sem precisar de reload de providers.

### Custos / trade-offs
- Preferência de idioma não sincroniza entre dispositivos (decisão intencional desta release).
- `app_pt.arb` é mantido como alias temporário para segurança de transição.
- Introduz gate adicional de CI para garantir paridade de chaves/placeholders nos ARBs.
- Introduz guard rails adicionais para superfícies auditadas:
  - deteção de copy hardcoded em Presentation;
  - deteção de valores `en`/`es` ainda iguais ao `pt_PT` nas keys auditadas.

## Implementação
- Controller e persistência local:
  - `lib/app/presentation/providers/language_controller.dart`
  - `lib/core/services/preferences/language_preferences_service.dart`
- Resolução e runtime locale:
  - `lib/core/localization/supported_app_locales.dart`
  - `lib/core/localization/app_locale_resolution.dart`
  - `lib/core/localization/app_locale_runtime.dart`
  - `lib/core/localization/api_language_tag_mapper.dart`
- Wiring da app:
  - `lib/app/app.dart`
  - `lib/app/presentation/screens/settings_screen.dart`
- Gate de paridade l10n:
  - `scripts/check_l10n_parity.dart`
  - `scripts/check_presentation_copy_guard.dart`
  - `scripts/check_untranslated_l10n_values.dart`
  - `.github/workflows/quality-gates.yml`

## Fora de escopo
- Persistência de idioma em perfil Firestore.
- Tradução semântica completa de conteúdo editorial além do escopo operacional desta alteração.
