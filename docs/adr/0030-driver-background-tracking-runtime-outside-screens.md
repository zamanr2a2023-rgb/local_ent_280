# ADR 0030: Runtime Global de Tracking do Motorista Fora dos Ecrãs

## Contexto
- O tracking do motorista era coordenado por `DriverHomeController` e `DriverActiveTripController`.
- Ao ir para background, o controller do ecrã de viagem ativa desligava listeners de viagem, o que deixava o pipeline dependente do ecrã aberto.
- O produto passou a exigir continuidade de tracking com a app viva em background durante viagem operacional ativa, sem arrancar foreground services proibidos em background no Android.

## Decisão
1. Criar um runtime global do papel `driver`, montado ao nível da app, como única autoridade para:
   - `setDriverContext`;
   - sincronização de `tripState -> DriverLocationSharingCoordinator`;
   - lifecycle foreground/background;
   - reconciliação ao regressar a foreground.
2. Manter `DriverLocationStreamer` como único writer canónico para RTDB/presença/heartbeat.
3. Separar perfis de stream do dispositivo e perfis de publicação:
   - foreground/background de uma viagem ativa mudam apenas o throttling de publicação;
   - não reiniciar o stream só por transição de lifecycle.
4. Exigir `Always` apenas para tracking em background:
   - foreground continua com o fluxo normal de localização;
   - sem `Always`, mostrar disclosure + gate explícita no UI do motorista.
5. Em background, nunca tentar arrancar um stream novo se ele não estiver armado:
   - marcar `pendingStartOnResume`;
   - armar apenas no próximo `resumed`.

## Consequências
- O tracking deixa de depender do `DriverActiveTripScreen` estar montado.
- O pipeline fica alinhado com as restrições de foreground service do Android moderno.
- A UX do motorista passa a expor claramente quando falta permissão `Always`.
- `DriverHomeController` e `DriverActiveTripController` deixam de ser donos da sincronização de `tripState -> tracking`, mantendo apenas responsabilidades de UI/ação operacional.
