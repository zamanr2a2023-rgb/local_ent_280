# Source of Truth: Location & Tracking

## Objetivo do domínio
- Disponibilizar tracking operacional de motorista em tempo real para execução da viagem.

## Entidades e contratos
- Localização do motorista em RTDB `driverLocations/{driverId}`.
- Presença do motorista em RTDB `driverPresence/{driverId}`.
- Entidade de domínio de localização no app: `DriverLocation`.
- `driverStatus/{driverId}` no Firestore usa schema estrito para campos operacionais (`isAvailable`, `isActive`, `availabilityEnabled`, `updatedAt`).

## Workflow canónico
1. Driver inicia sessão operacional e o runtime global do papel `driver` arma o pipeline canónico de tracking.
2. App publica updates de localização/presença no RTDB com cadência adaptativa:
   - modo idle disponível em foreground: menor frequência (`45s`) e envio condicional por mudança relevante;
   - viagem ativa em foreground: keepalive operacional (`30s`) com `distanceFilter=15m` e threshold de movimento `15m`;
   - viagem ativa em background vivo: keepalive económico (`45s`) com o mesmo stream de dispositivo já armado e threshold de movimento `50m`.
3. App atualiza `driverStatus.lastSeenAt` no Firestore com limitação de frequência (máximo 1 escrita por `120s` por motorista) para controlo de custos.
4. Cliente consome localização do motorista durante viagem ativa.
   - A UI mantém o último ponto válido recebido quando a stream fica temporariamente sem localização, incluindo localização stale, para o veículo não desaparecer do mapa.
   - Quando a localização volta a atualizar depois de uma pausa, o marcador do veículo anima do último ponto apresentado até ao novo ponto em vez de saltar instantaneamente.
5. Backend usa localização/presença para atribuição, monitorização de heartbeat e avaliação de monitorização operacional.
6. A atribuição backend aplica pesquisa por raios progressivos (`12km` → `24km` → `40km` → `60km` → `80km` → `100km`) e seleciona o melhor candidato dentro do primeiro raio com elegíveis.
7. O trigger backend de monitorização operacional consome o RTDB como fonte high-frequency, atualiza `driverOperationalStates/{driverId}` e persiste apenas replay limitado + métricas agregadas, sem arquivo bruto always-on em Firestore.
8. Se o motorista ativar disponibilidade mas a app não conseguir armar uma sessão RTDB/stream de localização válida, a disponibilidade é revertida para `false` no `driverStatus` para evitar falso positivo de despacho.
9. Quando uma escrita RTDB de tracking falha com `permission-denied`, a app tenta refrescar o token Firebase uma vez; se a sessão continuar inválida, termina sessão local e exige novo login antes de voltar a prometer disponibilidade operacional.
10. O backend monitoriza `driverStatus.lastSeenAt` com query direta sobre motoristas ativos/disponíveis e força `isAvailable=false` quando o heartbeat fica stale ou ausente, para impedir que um motorista continue elegível para despacho com tracking morto.
11. Se a publicação crítica RTDB falhar depois do stream já estar armado, a app trata a sessão de tracking como inválida, pára o stream e persiste imediatamente `isAvailable=false` para não deixar motoristas stale marcados como disponíveis.
12. Se a localização inicial do dispositivo não puder ser obtida dentro da janela operacional de arranque, a ativação de disponibilidade falha rapidamente e a UI reverte para indisponível em vez de ficar presa em estado intermédio.
13. No ecrã cliente de seleção de recolha, o mapa distingue o pin editável da recolha da posição real autorizada do cliente. O pin continua a definir a morada/ponto de recolha confirmado; a posição real do cliente é apenas contexto visual para reduzir erros quando o pin é ajustado.

## Invariantes de negócio
- Tracking ativo apenas em contexto operacional válido.
- O RTDB continua a ser a única fonte high-frequency de localização do motorista; o Firestore guarda apenas evidência limitada e agregados para auditoria operacional.
- Tracking em background vivo é permitido apenas durante viagem operacional do motorista nos estados `driverAccepted`, `driverEnRoute`, `driverArrived`, `inTrip`, `arrivedDestination` e `extensionWindow`.
- Sem permissão `Always`, a app não promete tracking em background e mostra gate explícita no dashboard/ecrã de viagem do motorista.
- Localização stale pode excluir motorista de atribuições automáticas.
- Janela stale canónica de localização RTDB para matching: `180s`.
- Heartbeat stale em Firestore é avaliado com margem operacional superior ao throttling do app para evitar falsos positivos de offline.
- Heartbeat stale ou ausente em `driverStatus.lastSeenAt` invalida a disponibilidade operacional no backend e remove o motorista da pool de despacho até novo heartbeat válido.
- Falha crítica de autorização RTDB durante tracking invalida imediatamente a disponibilidade operacional no cliente, mesmo que o toggle já estivesse ativo.
- Encerramento de sessão remove/atualiza presença para evitar falso disponível.
- O toggle de disponibilidade do motorista só pode permanecer ativo quando a partilha operacional consegue armar presença RTDB e stream de localização compatíveis com despacho.
- Paths RTDB canónicos (`driverLocations/{driverId}` e `driverPresence/{driverId}`) e contrato de `onDisconnect` mantêm-se.
- O stream de dispositivo não é reiniciado apenas por transição foreground/background; a mudança de lifecycle altera apenas o perfil de publicação/throttling.
- A posição real do cliente no mapa de recolha não altera automaticamente o ponto confirmado quando o utilizador move o pin; a confirmação usa sempre o centro/pin escolhido.
- A UI do cliente usa a rota ativa para mostrar tempo estimado restante, não tempo decorrido:
  - antes da recolha, em `driverAssignedWaitingAcceptance`, `driverAccepted` e `driverEnRoute`, mostra ETA motorista -> recolha quando a rota `driverToPickup` existe;
  - depois da recolha, em `inTrip`, mostra ETA motorista -> destino quando a rota `driverToDestination` existe;
  - quando não há motorista atribuído, rota aplicável ou estado compatível, não deve cair para temporizador de estado "decorrido".

## Regras de autorização
- Escrita de localização/presença é ownership-based por `driverId`.
- Leitura por cliente é condicionada a participação na viagem ativa.
- Operações globais de monitorização são backend/admin.

## Integrações e dependências
- RTDB para coordenadas e presença.
- Firestore para estado de viagem e relação cliente-motorista, incluindo heartbeat resumido (`lastSeenAt`) com write throttling.
- Cloud Functions para heartbeat monitor e dispatch operacional.

## Estados de erro e edge cases
- Permissão de localização negada no dispositivo.
- Permissão `While In Use` sem `Always`: foreground continua possível, background tracking fica bloqueado com aviso explícito.
- App pode não receber o evento de fim de viagem enquanto está suspensa em background; ao regressar a foreground, o runtime reconcilia a viagem ativa e limpa tracking pendente.
- Falha de stream de localização ou conectividade.
- Obtenção da posição inicial sem fix útil: a app tenta usar a última posição conhecida e, se continuar sem coordenadas válidas, falha o armamento do tracking com timeout explícito.
- Escritas RTDB de tracking com sessão Firebase inválida: a app tenta refresh forçado uma vez e, se continuar sem autenticação válida, termina sessão para evitar falso disponível e novas escritas negadas.
- Dados stale e inconsistentes entre presença e estado real da viagem.
- Documento `driverStatus` inválido é tratado como erro explícito (sem coerção de tipos legados).

## Suporte a demo (debug/dev apenas)
- Existe suporte de simulação de movimento do motorista para demos, disponível apenas em builds debug ou ambiente `dev` e exposto por toggle em definições de programador.
- A simulação substitui apenas a fonte de localização do dispositivo no app do motorista (decorator de `DriverDeviceLocationRepository`), preservando o pipeline canónico: `DriverLocationStreamer` -> RTDB/heartbeat/presença.
- A simulação publica movimento em direção à recolha apenas em estados de aproximação (`driverAccepted`/`driverEnRoute`) e pára junto à recolha.
- A simulação **não** executa transições de estado da viagem (ex.: não marca chegada automaticamente).
- A cadência de emissão para demo é limitada explicitamente e continua sujeita ao throttling/keepalive do pipeline canónico para controlo de writes.

## Fora de escopo
- Replaying histórico avançado de trajetos para analytics.
- Arquivo telemático bruto e permanente por motorista para monitorização operacional.
- Navegação turn-by-turn nativa no domínio de tracking.

## Desvios do baseline MVP
- Nenhum desvio funcional intencional relevante identificado neste domínio.

## Referências de implementação
- `lib/features/driver/domain/services/driver_location_sharing_coordinator.dart`
- `lib/features/driver/presentation/providers/driver_background_tracking_runtime_controller.dart`
- `lib/features/driver/data/repositories/driver_location_repository_impl.dart`
- `lib/features/driver/data/services/geolocator_driver_tracking_permission_service.dart`
- `lib/features/driver/data/repositories/dev_driver_device_location_repository_decorator.dart`
- `lib/features/driver/data/repositories/driver_presence_store_impl.dart`
- `functions/src/trips/buildTripsFunctions.ts` (despacho por localização RTDB)
- `functions/src/drivers/buildDriversFunctions.ts` (monitorização heartbeat/sync público)
- `functions/src/operations/buildOperationalMonitoringFunctions.ts`
- `functions/src/index.ts` (composition root/export surface)
- `docs/adr/0016-firestore-strict-read-validation.md`
