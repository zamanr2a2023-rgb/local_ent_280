# ADR 0013: Origem única para feature flags da app

- **Estado**: Aceite
- **Data**: 2026-02-17

## Contexto

Existiam flags de produto declaradas localmente em ecrãs (`const bool`), o que criava ramos mortos e risco de divergência entre fluxos de cliente e motorista.
Também existia configuração legada (`BuildConfig`) sem consumo ativo.

## Decisão

1. Introduzir uma origem única de flags em `lib/app/config/app_feature_flags.dart`.
2. Expor o consumo por DI com `appFeatureFlagsProvider` em `lib/app/application/providers/app_feature_flags_provider.dart`.
3. Proibir flags por ecrã para decisões de produto.
4. Remover configuração legada sem uso (`lib/app/config/build_config.dart`).

## Consequências

### Positivas

- Consistência de UX entre papéis para flags partilhadas.
- Redução de ramos mortos locais e de dívida de manutenção.
- Ponto único para futura integração com Remote Config.

### Trade-offs

- Maior disciplina: qualquer nova flag deve entrar no catálogo central.
- Possível necessidade de refator quando flags passarem a runtime remoto.

## Implementação inicial

- Fluxos de viagem ativa (cliente e motorista) passam a ler `enableTripExtensionWindowPhase` pela origem central.
- Catálogo canónico documentado em `docs/source_of_truth/feature_flags.md`.
