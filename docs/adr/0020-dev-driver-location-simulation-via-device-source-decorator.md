# ADR 0020: Simulação de Localização do Motorista (Demo) via Decorator da Fonte de Dispositivo

## Estado
Aceite

## Contexto
- É necessário demonstrar o fluxo de acompanhamento de recolha no cliente com movimento do motorista visível em tempo real.
- A demo deve usar o pipeline real de tracking (RTDB + listeners do cliente) sem introduzir writes paralelos ou atalhos na UI.
- O projeto usa Clean Architecture e o pipeline canónico de publicação de localização já aplica throttling/heartbeat/keepalive em `DriverLocationStreamer`.
- Há risco de bugs de concorrência se a simulação criar timers/streams paralelos sem coordenação explícita.

## Decisão
- Implementar a simulação como **decorator** de `DriverDeviceLocationRepository` no app do motorista, ativado apenas em builds `debug` ou em ambiente `dev` por toggle runtime em definições de programador.
- Manter `DriverLocationStreamer` como único writer para RTDB/presença/heartbeat.
- A simulação gera posições "device-like" rumo à recolha apenas em estados `driverAccepted` e `driverEnRoute`.
- A simulação pára junto à recolha e **não** dispara transições de estado (sem auto `mark arrived`).
- Controlar a cadência explicitamente no simulador (tick + filtro de distância) e manter as regras de keepalive do pipeline canónico.
- Garantir troca segura de fontes com uma única fonte ativa por vez (`real` ou `simulada`), cancelamento ordenado de subscription/timer e fallback determinístico para fonte real em caso de erro da simulação.

## Consequências
### Positivas
- Preserva o comportamento do cliente e do backend, porque a demo usa o mesmo fluxo RTDB de produção.
- Evita duplicação de writers e drift de contratos de tracking.
- Limita impacto arquitetural a um ponto de injeção (DI dev-only) e a serviços de preferências/UI dev.
- Melhora troubleshooting com logs dedicados de ativação, seed, troca de fonte e chegada simulada.

### Negativas
- A lógica do decorator exige disciplina para evitar leaks de stream/timer.
- A simulação usa trajetória simplificada (linha reta), não uma rota real.
- Requer manutenção adicional de tooling dev (toggle persistido + strings de definições).

## Implementação de referência
- `lib/app/di/provider_overrides.dart`
- `lib/app/presentation/screens/settings_screen.dart`
- `lib/app/presentation/providers/driver_location_simulation_controller.dart`
- `lib/core/services/preferences/driver_location_simulation_preferences_service.dart`
- `lib/features/driver/data/repositories/dev_driver_device_location_repository_decorator.dart`
- `lib/features/driver/data/repositories/driver_location_simulation_motion.dart`
- `lib/features/driver/data/repositories/driver_location_simulation_target.dart`
