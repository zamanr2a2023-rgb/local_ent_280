# ADR 0011: Unified App Logging Layer

- Status: Accepted
- Date: 2026-02-16

## Context

A app tinha logging disperso com `debugPrint` e `developer.log`, incluindo pontos de alta frequência (tracking/presença/map updates), o que aumenta volume de ingestão sem melhorar observabilidade crítica.

## Decision

Introduzir um wrapper único em `lib/core/logging/app_logger.dart` com:
- níveis: `debug`, `info`, `warn`, `error`;
- filtro por ambiente:
  - em `release`, `debug` desativado por omissão;
  - override opcional com `APP_LOG_LEVEL`;
  - flag explícita `APP_LOG_RELEASE_DEBUG` para permitir `debug` em release quando necessário;
- sampling temporal para fluxos ruidosos (`debugSampled`);
- campos de correlação padronizados em mensagem:
  - `tripId`, `driverId`, `requestId`.

Aplicação inicial em fluxos de maior cadência:
- `DriverLocationStreamer`;
- `DriverPresenceStoreImpl`;
- `DriverLocationRepositoryImpl`;
- `DriverHeartbeatStoreImpl`;
- `DriverLocationSharingCoordinator`.

## Consequences

- Menor volume de logs de alta frequência em runtime.
- Logs críticos (`warn`/`error`) continuam sempre visíveis.
- Debugging em ambiente de desenvolvimento mantém verbosidade útil.
