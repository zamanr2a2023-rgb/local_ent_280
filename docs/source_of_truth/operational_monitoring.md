# Source of Truth: Operational Monitoring

## Objetivo do domínio
- Detetar, rever e auditar desvios operacionais e uso não autorizado de viaturas da empresa durante contexto operacional/on-duty.
- Fornecer evidência explicável para `admin` e `manager`, sem penalizações automáticas nem bloqueios em tempo real.

## Guardrails de produto
- Monitorização ativa apenas em contexto operacional válido:
  - `driverStatus.isActive != false`
  - `driverStatus.availabilityEnabled != false`
  - viatura atribuída
  - e pelo menos um de:
    - viagem ativa
    - motorista disponível/on-duty
    - extensão pós-cobrança ativa
    - exceção operacional ativa
- Fora desse contexto, o estado canónico é `off_duty`, a monitorização fica suprimida e não são criados incidentes.
- O MVP é framed como controlo operacional de viaturas de serviço.
- O MVP não cria penalizações automáticas, scoring nem enforcement punitivo.
- A UI do motorista expõe apenas copy neutra de transparência junto da disponibilidade.

## Janelas e estados operacionais
- Tipos de janela canónicos:
  - `active_trip`
  - `post_dropoff`
  - `no_trip_operational`
- Formato canónico de `operationalWindowId`:
  - `trip:{tripId}:active`
  - `trip:{tripId}:postdropoff:{arrivedDestinationAtEpochMs}`
  - `driver:{driverId}:idle:{windowStartedAtEpochMs}`
- Estados operacionais canónicos:
  - `on_active_trip`
  - `post_dropoff_waiting`
  - `returning_to_base`
  - `at_base`
  - `approved_reposition`
  - `operational_idle`
  - `off_duty`
- `driverOperationalStates/{driverId}` mantém no máximo uma janela ativa por motorista.

## Data contracts
- Config canónica em `config/operations_monitoring`:
  - `enabled` (default `false`; monitorização operacional full só corre quando explicitamente ativada)
  - `baseGeofence`
  - `serviceGeofences[]`
  - `dropoffWaitingRadiusMeters`
  - `postDropoffGracePeriodMinutes`
  - `routeDeviationCorridorMeters`
  - `sustainedDeviationThresholdSeconds`
  - tolerâncias km/%
  - limiares de stale telemetry
  - limiares de clearance
  - parâmetros de downsampling/replay
  - esta configuração é editável na app por `admin` e por `manager` com permissão `ts`
- Escritas RTDB em `driverLocations/{driverId}` só carregam a configuração depois de confirmar que existe janela operacional ativa no `driverOperationalStates/{driverId}`.
- Estado corrente por motorista em `driverOperationalStates/{driverId}`:
  - `operationalWindowId`
  - `operationalWindowType`
  - `currentState`
  - `latestLocation`
  - `lastProcessedRtdbTimestamp`
  - `currentOpenIncidentId`
  - `activeApprovalSummary`
  - `cachedExpectedRoute`
  - `replaySamples` limitados
  - `actualWindowDistanceKm`
  - timestamps relevantes de janela/compliance
- Métricas agregadas por viagem em `tripOperationalMetrics/{tripId}`:
  - `activeTripOperationalWindowId`
  - `postDropoffOperationalWindowId`
  - `latestNoTripOperationalWindowId`
  - `expectedTripDistanceKm`, `actualTripDistanceKm`, `tripDistanceVarianceKm`, `tripDistanceVariancePct`
  - `expectedPostDropoffDistanceKm`, `actualPostDropoffDistanceKm`, `postDropoffVarianceKm`, `postDropoffVariancePct`
  - `expectedNoTripDistanceKm`, `actualNoTripDistanceKm`, `noTripVarianceKm`, `noTripVariancePct`
  - total do ciclo operacional
  - `expectedTripPolyline`
  - `expectedPostDropoffPolyline`
  - boundaries temporais
- Incidentes em `operationalIncidents/{incidentId}`:
  - `operationalWindowId`
  - `operationalWindowType`
  - `driverId`, `vehicleId`, `tripId`
  - `incidentType = active_trip_route_deviation | post_dropoff_unauthorized_movement`
  - `subreason`
  - `status = open | acknowledged | approved | dismissed | confirmed`
  - `startedAt`, `resolvedAt`
  - `resolutionSource = system | reviewer`
  - `resolutionReason`
  - `originCoordinates`, `latestCoordinates`
  - `expectedPolyline`
  - `actualPathSamples` limitados
  - blocos de evidência km
  - timestamps-chave
  - `reviewNote`
- Trilho de auditoria do incidente em `operationalIncidents/{incidentId}/events/{eventId}`.
- Aprovações temporárias em `operationalMovementApprovals/{approvalId}`:
  - `operationalWindowId`
  - `operationalWindowType`
  - `driverId`, `vehicleId`, `tripId`
  - `reason`
  - `expiresAt`
  - destino opcional ou `allowedArea` opcional
  - `approvedBy`, `approvedByRole`
  - `status = active | expired | completed | revoked`
  - `incidentId` opcional

## Fontes de evidência
- Fonte high-frequency: RTDB `driverLocations/{driverId}`.
- Não existe arquivo bruto Firestore always-on de telemetria.
- Evidência de viagem ativa reutiliza:
  - `trips/{tripId}.meteringSnapshot.totalDistanceKm`
  - `trips/{tripId}/pathPoints`
- Evidência pós-dropoff / no-trip é acumulada server-side a partir do RTDB e persistida apenas como métricas e replay downsampled.
- Rotas esperadas são cacheadas por `operationalWindowId`, não recalculadas a cada minuto.

## Regras de deteção
- `active_trip_route_deviation`:
  - corredor esperado pickup->destination
  - threshold sustentado fora do corredor
  - ausência de progresso útil para o waypoint esperado
  - km variance como sinal forte, nunca como prova única
- `post_dropoff_unauthorized_movement`:
  - grace period após `ARRIVED_DESTINATION`
  - permitido esperar na zona do drop-off
  - permitido regressar pela rota esperada até à base
  - permitido estar em base, geofence de serviço, nova atribuição ou exceção ativa
  - `abandoned_return_to_base` é subreason dentro do mesmo tipo de incidente
- `post_dropoff_unauthorized_movement` também cobre janela `no_trip_operational`:
  - sem viagem ativa
  - sem próxima atribuição imediata
  - sem exceção ativa
  - sem contexto permitido de base/espera/serviço
  - movimento sustentado além da tolerância local gera/estende incidente com subreason `no_trip_unauthorized_operational_movement`

## Aprovações e revisão
- Aprovação preventiva disponível apenas quando existe janela operacional ativa elegível:
  - `post_dropoff`
  - `no_trip_operational`
- Nunca é permitida em `active_trip`.
- Motivo obrigatório, expiração obrigatória, nunca open-ended.
- Duração permitida: `5..240` minutos a partir da criação.
- `destination` e `allowedArea` são mutuamente exclusivos.
- Ações de revisão:
  - `acknowledge`
  - `dismiss`
  - `confirm`
  - `approve_exception`
- `approve_exception` resolve o incidente e pode criar aprovação ligada.

## Auto-resolução
- Só incidentes com `status in {open, acknowledged}` e `resolvedAt == null` podem auto-resolver.
- Requer ausência contínua da condição de incumprimento durante `incidentClearanceThresholdSeconds`.
- Razões canónicas:
  - `returned_to_compliant_path`
  - `entered_waiting_zone`
  - `entered_base`
  - `entered_service_geofence`
  - `next_assignment_started`
  - `approval_became_active`
  - `went_off_duty`
  - `monitoring_suppressed_due_to_stale_telemetry`
- Auto-resolução mantém `status` atual (`open` ou `acknowledged`) e escreve `resolutionSource=system`.

## Retenção e replay
- `driverOperationalStates.replaySamples`:
  - máximo `60` pontos
  - apenas janela ativa
  - pruning > `6h`
  - reset em transição de janela ou `off_duty`
- `operationalIncidents.actualPathSamples`:
  - máximo `120` pontos downsampled
  - uma polyline esperada
- TTLs canónicos:
  - incidentes e eventos: `90` dias após `resolvedAt`
  - approvals: `90` dias após `expiresAt`
  - tripOperationalMetrics: `90` dias após o fim da última janela ligada

## UX operacional
- `admin` e `manager` têm lista leve de incidentes com:
  - motorista
  - viatura
  - estado atual
  - contexto/tripId
  - tipo/subreason
  - início/duração
  - localização atual
  - status
  - resumo km
- Detalhe do incidente mostra:
  - ação de ajuda no topo com explicação breve de como o incidente é disparado e de que o fluxo é apenas de revisão/auditoria
  - mapa leve, não interativo, com polyline esperada + path amostrado
  - a câmara do mapa ajusta-se automaticamente para enquadrar todos os pontos relevantes no frame disponível
  - quando não existe rota suficiente, o mapa continua disponível e assume fallback explícito para a última posição conhecida
  - labels legíveis para contexto operacional, estado da exceção, viatura e última posição; IDs crus só devem aparecer quando não existir alternativa compreensível
  - identificadores técnicos de viagem/janela e códigos do trilho de auditoria devem ser convertidos para copy legível antes de chegar à UI
  - timestamps-chave
  - blocos `expected vs actual`
  - notas de revisão / motivo de resolução quando existirem
  - trilho de auditoria
  - ações de revisão
- Existe um ecrã dedicado de configuração operacional para ajustar os parâmetros numéricos do documento canónico:
  - raios
  - grace periods
  - tolerâncias km/%
  - thresholds de stale telemetry / clearance
  - downsampling do replay
  - raio de chegada em approvals
  - cada input expõe ajuda contextual por ícone `info`, abrindo bottom sheet curto com explicação do parâmetro e intervalo permitido, em vez de helper text persistente por baixo de todos os campos
  - o resumo no topo mostra metadata de última atualização com identidade legível (preferencialmente email; fallback para identificador técnico quando não há resolução)
  - as geofences continuam a ser lidas do mesmo documento, mas nesta iteração aparecem apenas como estado de configuração e não como editor cartográfico
- O motorista não vê decisões internas de violação.

## Regras de autorização
- Leitura/escrita de `config/operations_monitoring`:
  - `admin`
  - `manager` com `ts`
- Leitura de `driverOperationalStates`, `tripOperationalMetrics`, `operationalIncidents`, eventos e approvals:
  - `admin`
  - `manager` com `vt + vd`
- Ações de revisão/aprovação preventiva:
  - `admin`
  - `manager` com `ts`
- Clientes e motoristas não leem estes documentos.

## Referências de implementação
- `functions/src/operations/`
- `functions/src/index.ts`
- `lib/features/operational_incidents/`
- `firestore.rules`
