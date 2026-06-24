# Source of Truth: Trips

## Objetivo do domínio
- Orquestrar ciclo de vida da viagem do pedido ao fecho financeiro.
- Garantir paridade de regras entre app e backend.

## Estados canónicos
- `requested`
- `driverAssignedWaitingAcceptance`
- `driverAccepted`
- `driverDeclined`
- `noDriversAvailable`
- `driverEnRoute`
- `driverArrived`
- `inTrip`
- `arrivedDestination`
- `extensionWindow` (legado; fluxo de produto ativo usa `postChargeExtension`)
- `completed`
- `chargeApplied`
- `cancelledByClient`
- `cancelledByDriver`
- `noShow`

## Fases canónicas de UI (interpretação)
- `pending`: `requested`, `driverAssignedWaitingAcceptance`, `driverDeclined`.
- `inProgress`: `driverAccepted`, `driverEnRoute`, `driverArrived`, `inTrip`.
- `postTripPendingPayment`: `arrivedDestination`, `extensionWindow`.
- `finalized`: `completed`, `chargeApplied`, `noDriversAvailable`, `cancelledByClient`, `cancelledByDriver`, `noShow`.

## Regra de viagem ativa por papel
- Cliente: viagem ativa enquanto fase != `finalized`.
- Motorista (ecrã de viagem ativa): apenas fases `inProgress` e `postTripPendingPayment`.
- Quando uma viagem de cliente ou motorista entra em `completed` ou `chargeApplied`,
  a UI não deve redirecionar bruscamente para dashboard. Deve preservar o último
  snapshot conhecido e abrir um ecrã full-screen de fim de viagem.
- O ecrã de fim de viagem é orientado por estado de apresentação:
  - `loadingSnapshot`
  - `chargingPending`
  - `chargedExtensionEligible`
  - `clientPrompt`
  - `driverPending`
  - `extensionActive`
  - `extensionChargeApplying`
  - `extensionClosed`
  - `ratingAvailable`
  - `ratingSubmitted`
  - `errorMissingTrip`
  - `errorTripNotFound`
- No cliente, a prioridade visual do ecrã final é:
  1. estado da cobrança;
  2. decisão de prolongamento pós-cobrança;
  3. resumo compacto da cobrança aplicada ao saldo;
  4. avaliação opcional;
  5. saída explícita para início ou detalhe da viagem.
- Enquanto a viagem está em `completed` sem `chargeApplied`, a UI mostra
  “A finalizar a viagem”, não mostra rating e não oferece prolongamento.
- Em `cancelledByClient` e `cancelledByDriver`, cliente e motorista seguem para
  o ecrã de conclusão com estado de cancelamento; a UI não mostra prolongamento
  pós-cobrança nem rating.
- Em `chargeApplied`, a copy deve usar “cobrança aplicada ao saldo”, evitando
  “pagamento” quando a operação representa débito no saldo interno.
- No motorista, o ecrã final deve comunicar disponibilidade operacional e manter
  o prolongamento visível se o cliente pedir tempo extra. Sair para dashboard não
  cancela nem oculta o pedido ativo.
- Se o handoff preservado falhar, o motorista continua a abrir o ecrã final para
  `completed`, `chargeApplied`, `cancelledByClient` e `cancelledByDriver` usando
  o último snapshot local da viagem; dashboard direto fica reservado para no-show
  ou ausência real de viagem.
- O ecrã final do motorista apresenta recolha, destino, cliente quando conhecido,
  estado de cobrança e o estado do `postChargeExtension` (`clientPrompt`,
  `driverPending`, `active`, `chargeApplying`, `closed`) enquanto observar a viagem.
- Android back / iOS swipe back no ecrã final não deve voltar ao ecrã de viagem
  ativa; deve levar para dashboard/home do papel.
- Chat de viagem:
  - disponível para cliente e motorista em `driverAccepted`, `driverEnRoute`, `driverArrived`, `inTrip`, `arrivedDestination` e `extensionWindow`;
  - fechado quando a viagem entra em qualquer estado terminal;
  - histórico continua legível depois do fecho.
- No ecrã dedicado do motorista (`/driver/trip/current`), o dispositivo mantém-se acordado enquanto a fase for `inProgress` ou `postTripPendingPayment`; ao sair do ecrã ou ao entrar em estado finalizado, o wakelock é removido.
- Quando uma notificação push de viagem chega com a app aberta em foreground, a UI mostra banner interno e também publica uma notificação Android visível no sistema, para evitar pedidos de recolha silenciosos.
- No mapa da viagem ativa do motorista, a câmara arranca em modo automático por contexto:
  - antes do início da viagem, enquadra a rota para a recolha;
  - ao entrar em `inTrip`, faz um enquadramento único para a rota até ao destino.
- Depois de o motorista mover ou ampliar o mapa manualmente, a app deixa de recentrar em updates normais de localização/rota até o utilizador tocar em `Centrar mapa`.
- No `driverHome`, o atalho `Eventos do dia` mostra badge vermelha sem número quando existirem eventos/reservas pendentes de hoje (`scheduledAt >= now`).
- Esta interpretação é de domínio e não altera transições do state machine backend.

## Monitorização operacional associada à viagem
- Cada viagem pode abrir janelas operacionais monitorizadas:
  - `trip:{tripId}:active`
  - `trip:{tripId}:postdropoff:{arrivedDestinationAtEpochMs}`
- `tripOperationalMetrics/{tripId}` guarda a evidência km agregada da viagem e da janela pós-dropoff:
  - `expectedTripDistanceKm`, `actualTripDistanceKm`, `tripDistanceVarianceKm`, `tripDistanceVariancePct`
  - `expectedPostDropoffDistanceKm`, `actualPostDropoffDistanceKm`, `postDropoffVarianceKm`, `postDropoffVariancePct`
  - total do ciclo operacional e boundaries temporais
- A viagem ativa reutiliza:
  - `meteringSnapshot.totalDistanceKm` como km real autoritativo da viagem
  - `trips/{tripId}/pathPoints` como replay leve do percurso real
- O backend pode abrir incidentes de monitorização operacional ligados à viagem, mas isso não altera o state machine canónico da viagem nem aplica penalizações automáticas.

## Política de minimização de writes em `trips/{tripId}`
- Campos UI-críticos (estado/workflow) permanecem no documento principal e continuam a atualizar `updatedAt`:
  - `status`, `statusEnteredAt`, timestamps de transição (`acceptedAt`, `arrivedAt`, `startedAt`, `completedAt`, etc.).
  - `cancellation`, `manualSurcharge`, `extensionRequest*`, `payment*`, `receipt`.
- Campos operacionais de alta frequência:
  - metering vivo é persistido em `trips/{tripId}/metering/current`.
  - consumidores leem `metering/current` primeiro e fazem fallback temporário para `trips/{tripId}.meteringSnapshot` durante a migração.
  - o backend escreve o snapshot final em `trips/{tripId}.meteringSnapshot` apenas em transições canónicas relevantes (`ARRIVED_DESTINATION`, `COMPLETED`, `CHARGE_APPLIED`).
- Objetivo: reduzir frequência de updates no doc principal durante viagem ativa sem alterar transições canónicas.

## Runtime por utilizador
- `userRuntime/{uid}` é um read model backend-owned para reduzir queries de descoberta em sessão.
- Campos canónicos:
  - `role`, `activeClientTripId`, `activeClientTripStatus`
  - `activeDriverAssignmentTripId`, `activeDriverTripId`, `activeDriverTripStatus`
  - `activePostChargeExtensionTripId`, `currentReservationId`
  - `unreadSupportChatCount`, `unreadTripChatCount`, `updatedAt`
- A app observa `userRuntime/{uid}` e, quando existe ponteiro, observa a viagem por path direto. Durante rollout mantém fallback para as queries antigas.

## Política de paginação de listas de viagens
- Queries de histórico (`cliente`, `motorista`, `operacional`) usam cursor sem offsets.
- Page size canónico: `20`.
- Ordenação canónica suportada: `createdAt desc` (default) e `createdAt asc`.
- Cursor de paginação é aplicado com `startAfterDocument(lastDoc)` no repositório de dados.

## Filtros, pesquisa e ordenação (Fase 1)
- Padrão UX único nas listas de viagens:
  - barra superior com pesquisa textual, chips rápidos e menu de ordenação;
  - filtros avançados em bottom sheet (`Mais filtros`) com ações `Limpar` e `Aplicar`.
  - quando existirem filtros ativos, a `FilterBar` expõe ação inline `Repor filtros`.
- Estratégia híbrida:
  - Firestore aplica filtros indexáveis (`status`, `dateRange`, `orderBy(createdAt)`).
  - Pesquisa textual (`tripId`, nomes e moradas) é local sobre o dataset carregado.
- Persistência de estado de filtros:
  - `clientTrips`: persistido localmente.
  - `driverTrips`: persistido localmente.
  - `managerTrips`: apenas sessão (sem persistência nesta fase).
- Estados vazios:
  - sem dados;
  - sem resultados para filtros ativos.
  - quando o vazio é causado por filtros ativos, a via de recuperação mantém-se sempre visível:
    - `FilterBar` continua renderizada;
    - empty state expõe `Repor filtros` e `Ajustar filtros`.

## Sugestões de destino no pedido imediato
- Antes de o cliente escrever no campo de destino, a UI pode sugerir destinos locais do cliente, combinando favoritos persistidos, destinos confirmados localmente, o destino mais recente de uma viagem não concretizada e até `3` destinos recentes concluídos.
- Fonte de dados: viagens do cliente em `TripState.completed` e `TripState.chargeApplied`, ordenadas por `createdAt desc`.
- Destinos repetidos são removidos por morada normalizada (`trim` + lowercase + espaços internos normalizados).
- O cliente pode remover explicitamente um destino recente da lista local de sugestões; esta ação apenas oculta a sugestão no dispositivo atual e não altera o histórico canónico da viagem.
- Quando o cliente confirma um destino no mapa, esse destino é guardado localmente por cliente e deve aparecer em `Recentes` na próxima interação, mesmo que a viagem ainda não tenha sido criada ou concluída.
- Quando um pedido não se concretiza antes da criação da viagem ou termina em `noDriversAvailable`, o destino é guardado localmente por cliente para aparecer na próxima interação de escolha de destino.
- Assim que o cliente começa a escrever (`query` não vazia), a lista de recentes deixa de ser mostrada e o fluxo passa a usar autocomplete de Places.
- O autocomplete textual de moradas usa o endpoint legacy de Places Autocomplete.
- Em `prod`, restringe a pesquisa a `Cabo Verde`.
- Em builds `debug` e no flavor `dev`, restringe a pesquisa a `Cabo Verde` e `Portugal` e, quando a app já tem localização autorizada/disponível, aplica as coordenadas como bias de ranking.
- Em `prod`, quando a app já tem localização autorizada/disponível, as sugestões usam essas coordenadas apenas como bias de ranking dentro dos países permitidos no ambiente ativo.
- O fluxo de autocomplete do destino não pede nova permissão de localização; sem localização disponível, continua apenas com a restrição por país do ambiente ativo.
- O painel de seleção inclui filtro local por cliente:
  - `Recentes` (sugestões locais combinadas);
  - `Favoritos` (destinos guardados com estrela, persistidos no dispositivo atual).

## Trip Preview do pedido imediato
- O ecrã de pré-visualização mostra sempre, sem expansão:
  - total estimado;
  - distância estimada;
  - duração estimada;
  - horário de referência do cálculo (`Hoje, HH:mm` ou `dd/MM, HH:mm`);
  - badge de ajuste dinâmico apenas quando o multiplicador altera efetivamente o preço estimado; o texto deve explicar o motivo aplicado (`faixa horária`, `feriado`, ou ambos).
- O breakdown completo do preço é exibido numa secção expandível `Ver detalhe do preço`.
- No breakdown, a linha de ajuste dinâmico é omitida quando o multiplicador não altera o preço (`x1,00` / valor `0`).
- O objetivo é progressive disclosure: manter o ecrã limpo em mobile sem perder transparência de cálculo.
- O cálculo do preview usa `referenceAt = now()` no momento de avaliação do tarifário/multiplicador.
- Quando o pedido é confirmado, o pricing lock da viagem imediata é persistido no snapshot com base em `requestedAt`; a cobrança e o receipt reutilizam esse lock sem reavaliação temporal.
- Staleness:
  - após `120s`, a estimativa é marcada como desatualizada;
  - a UI mostra `Atualizado há X min` e ação manual `Recalcular`;
  - não existe recálculo automático em background.
- Escopo atual: apenas pedido imediato. No fluxo de reserva, o rótulo de referência deve evoluir para `Agendado para` usando o timestamp agendado.

## Repetição rápida de pedido
- Quando o cliente decide cancelar no ecrã de viagem atual, a confirmação inclui a ação `Cancelar e pedir novamente`.
- Quando a viagem entra em `driverDeclined` no ecrã de espera, a UI expõe a ação `Pedir novamente`.
- Quando o `requestTrip` falha antes de criar a viagem por limite, indisponibilidade operacional, offline ou erro backend, a UI mantém a mensagem inline com `Tentar novamente` e apresenta um diálogo explícito com a razão da falha; se `config/support.supportPhone` existir, o diálogo expõe ação direta para chamada telefónica.
- Quando a viagem entra em `noDriversAvailable` no ecrã de espera, a UI mantém o estado visível até perfazer `10` segundos desde a abertura do ecrã antes de encerrar o fluxo.
- Ao fim desses `10` segundos, a UI apresenta um diálogo explícito com orientação de suporte; se `config/support.supportPhone` existir, a ação principal permite iniciar chamada telefónica direta.
- Em ambos os casos, o fluxo rápido reaproveita `pickup` e `destination` da viagem anterior no `tripDraft`.
- O tipo de transporte é selecionado no passo de transporte para garantir tarifa base e pricing consistentes com o catálogo ativo.
- Se o catálogo remoto de tipos de transporte estiver vazio ou indisponível no passo cliente, o fluxo expõe `Standard` como opção visível e selecionada, permitindo continuar sem mostrar um estado vazio.

## Contratos críticos (callables)
- `requestTrip`:
  - exige `tripData.pricingSnapshot.estimatedTotal: Money`.
  - aceita `tripData.pricingSnapshot.distanceTiers` (faixas em metros) e persiste no snapshot da viagem.
  - cria `trips/{tripId}` e o evento inicial `tripEvents/{tripId}/events/requested` na mesma transação backend.
  - o cliente não escreve evento inicial após o callable; falhas de timeline não podem marcar um pedido já criado como falhado.
- `cancelTrip`:
  - exige `fee: Money`.
  - `feeMinor` é rejeitado.
- `handleTripFinancialAction` com `action="propose_surcharge"`:
  - exige `amount: Money`.
  - `amountMinor` é rejeitado.
- `retryTripPayment` e `finalizeTripPayment`:
  - aplicam regra de limite com erro canónico `LIMIT_EXCEEDED`.
- Idempotência em callables críticas:
  - Chave canónica: `${tripId}:${action}:${eventId}`.
  - Se `idempotencyKey` for enviado no payload, tem prioridade sobre a chave derivada.
  - `eventId` é opcional; na ausência, o backend faz fallback para `${tripId}:${action}:${requesterId}`.
  - Endpoints com guard explícito de eventos processados:
    - `transitionTripState`, `cancelTrip`, `requestTripExtension`, `respondTripExtension`.
    - `handleTripFinancialAction` para `propose_surcharge` e `respond_surcharge`.
  - `handleTripFinancialAction` para `retry_payment` reutiliza resposta previamente processada por `idempotencyKey` e grava audit com docId determinístico por chave.

## Regras de escrita/leitura do cliente e motorista em Firestore
- `trips/{tripId}`:
  - cliente **não** pode alterar estado operacional da viagem por write direto;
  - cliente pode submeter avaliação (`rating`) por update direto **apenas uma vez** quando a viagem está em `completed` ou `chargeApplied`;
  - update permitido limita campos alterados a `rating`.
  - motorista pode atualizar apenas `meteringSnapshot` por write direto quando é o motorista atribuído e o estado da viagem está entre `driverArrived` e `chargeApplied`;
  - write de `meteringSnapshot` não pode alterar outros campos do documento.
- `trips/{tripId}/driverContactSnapshots/{snapshotId}`:
  - leitura permitida para participantes da viagem (`client`/`driver`) e operações (`manager`/`admin`);
  - escrita reservada a `admin`;
  - snapshot é criado/atualizado automaticamente pelo backend quando há atribuição inicial de motorista, reatribuição (`driverDeclined`) e ativação de reserva para viagem;
  - `snapshotId` canónico é o próprio `tripId`.

## Relação com trip packages
- No produto ativo, `tripPackages` é um domínio comercial separado do `Trip`.
- O package é comprado primeiro como booking comercial; o `Trip` nasce apenas na ativação operacional posterior.
- A ativação de um package confirmado cria um `Trip` package-covered sem nova cobrança.
- O `Trip` package-covered guarda metadata operacional mínima para correlação e reporting:
  - `packageBookingId`
  - `packageId`
  - `packageSnapshotVersion`
  - `fareCoverage = included`
- O estado comercial continua no booking; `Trip` não substitui nem reinterpreta o booking.
- Não existem `tripPackageDepartures` nem legs `outbound/return` no contrato ativo.

## Persistência financeira ativa
- `trips.finalCost` é `Money`.
- `trips.cancellation.fee` é `Money`.
- `trips.manualSurcharge.amount` é `Money`.
- `balance_adjustments.delta` é `Money`.
- `balance_adjustments.tripId` e `balance_adjustments.cycleIndex` são persistidos quando o movimento pertence a cobrança de viagem ou de extensão, para enriquecimento relacional do extrato e reporting.
- `trips.pricingSnapshot.distanceTiers` é persistido para congelar regras de distância no momento do pedido.
- `trips.pricingSnapshot.estimatedTotal` é persistido para suportar reconciliação operacional entre estimativa e valor final.
- `trips.pricingSnapshot.tariffId` e `trips.pricingSnapshot.tariffUpdatedAt` são guardados para rastreabilidade operacional.
- `trips.pricingSnapshot.perWaitMinute` é persistido para congelar a tarifa de espera da viagem e da extensão pós-cobrança.
- `trips.pricingSnapshot.pricingSchemaVersion = 3` identifica snapshots com tarifa base por tipo de transporte e multiplicadores dinâmicos.
- `trips.pricingSnapshot.appliedMultiplier` representa o valor combinado final de `time_range × holiday`.
- `trips.pricingSnapshot.appliedMultiplierId` é um id combinado determinístico:
  - `transport:{transportTypeId}|time:{timeRangeRuleId or none}|holiday:{holidayRuleId or none}`.
- `trips.pricingSnapshot.resolvedBaseTransportTypeId` e `resolvedBaseSource` são persistidos para auditoria do base fare congelado.
- `trips.pricingSnapshot.pricingScheduleId`, `specialDayId`, `timeRangeMultiplier`, `holidayMultiplier`, `evaluationTimestamp` e `evaluationTimeZone` são persistidos para auditoria e reporting.
- `transportMultiplier` é apenas legado de snapshots históricos v2; novos locks não o escrevem.
- Cobranças de extensão pós-cobrança são persistidas em `balance_adjustments` com docId determinístico por ciclo:
  - `trip_{tripId}_extension_{cycleIndex}`.
- Reporting administrativo deriva projeções ricas de viagem com quatro blocos consistentes:
  - operacional;
  - financeiro;
  - relacional;
  - auditoria.
- `Panorama Operacional` consome este contrato para:
  - `Detalhe` por viagem;
  - agrupamentos `Por Cliente`, `Por Motorista`, `Por Viatura` e `Por Período`.
- O export do modo `Detalhe` inclui, quando disponíveis no contrato canónico:
  - identificadores técnicos (`tripId`, `clientId`, `driverId`, `vehicleId`);
  - labels legíveis das entidades;
  - cadeia temporal operacional (`requestedAt`, `driverAssignedAt`, `acceptedAt`, `arrivedAt`, `startedAt`, `arrivedDestinationAt`, `completedAt`, `cancelledAt`);
  - contexto de estado/cancelamento/no-show;
  - evidência de localização (`pickup`, `destination`, latitude e longitude);
  - evidência financeira (`estimatedTotal`, breakdown do recibo, dívida, payment status);
  - proveniência tarifária (`tariffId`, `tariffUpdatedAt`, `resolvedBaseTransportTypeId`, `resolvedBaseSource`, `pricingScheduleId`, `specialDayId`, `appliedMultiplierId`, `pricingSchemaVersion`, `timeRangeMultiplier`, `holidayMultiplier`, `evaluationTimestamp`, `evaluationTimeZone`).
- Os modos agrupados agregam a partir do mesmo dataset canónico e suportam drill-through para `Detalhe` com filtro exato da entidade.
- ETA previsto vs real não faz parte do contrato canónico atual; o reporting não deve inferir esse desvio heurísticamente.
- A UI/reporting depende destes contratos de apresentação e não da shape Firestore crua, para permitir troca futura para read model dedicado.

## Matriz estado -> componente faturável
- `requested`, `driverAssignedWaitingAcceptance`, `driverAccepted`, `driverDeclined`, `noDriversAvailable`, `driverEnRoute`: não acumulam componentes faturáveis.
- `driverArrived`: só pode acumular `waitCharge` quando a espera for elegível; não acumula distância nem custo temporal de deslocação.
- `inTrip`: acumula apenas `distanceCharge`; `totalMinutes` continua operacional e não altera preço.
- `arrivedDestination`: congela base, distância e espera para fecho; não cria nova componente temporal.
- `extensionWindow`: estado apenas operacional legado; não gera `waitCharge`, `extensionCharge` nem qualquer custo temporal.
- `completed`: aplica no backend `baseFare + distanceCharge + waitCharge`, multiplicador e fees aplicáveis.
- `chargeApplied`: receipt principal fechado; só o sub-workflow `postChargeExtension` pode gerar novos débitos separados.
- `cancelledByClient`, `cancelledByDriver`, `noShow`: não usam minute pricing; mantêm apenas penalizações/regras existentes.

## Sub-workflow de extensão pós-cobrança (`postChargeExtension`)
- A extensão repetível após a cobrança principal é modelada em `trips/{tripId}.postChargeExtension` (não altera `TripState` canónico).
- O fluxo só é elegível quando a viagem está em `CHARGE_APPLIED`.
- Viagens canceladas nunca são elegíveis para extensão pós-cobrança. Se existir
  um snapshot legado com `postChargeExtension.isActive = true` e estado
  `cancelledByClient`/`cancelledByDriver`, clientes, motoristas e backend devem
  tratar o prolongamento como encerrado e não apresentá-lo no dashboard.
- Estados canónicos do sub-workflow:
  - `clientPrompt`
  - `driverPending`
  - `active`
  - `chargeApplying`
  - `closed`
- Campos canónicos mínimos:
  - `schemaVersion`, `isActive`, `status`, `maxCycles`, `completedCyclesCount`, `nextActionAt`, `currentCycle`, `history`, `closedReason`, `lastErrorCode`, `createdAt`, `updatedAt`.
- Regras:
  - semântica explícita: a extensão representa apenas ocupação/espera pós-chegada e pós-cobrança;
  - `cycleIndex` é `1-based`;
  - `maxCycles` default `6`;
  - duração pedida por ciclo no contrato ativo: `15..60` minutos;
  - UI do cliente sugere `15`, `30`, `45` e `60` minutos (`1 h`);
  - `driverPending` timeout default `60s`;
  - o motorista só fica `busy/currentTripId` após aceitar;
  - `active` acumula apenas `chargedAmount = billedMinutes * waitRateApplied`;
  - `waitRateApplied` é snapshotado de `pricingSnapshot.perWaitMinute`;
  - o cliente vê uma estimativa informativa por ciclo antes do pedido e durante `driverPending`/`active`, calculada como `requestedMinutes * waitRateApplied`;
  - a estimativa tem copy explícita de que a cobrança final depende do tempo efetivamente utilizado;
  - `updatedAt` da viagem e do sub-workflow é sempre escrito pelo backend;
  - idempotência é obrigatória (callables + scheduler assumem `at least once`);
  - lock lógico de cobrança: `active -> chargeApplying` em transaction; concorrência secundária vira no-op;
  - Cloud Tasks são o mecanismo primário para timeouts `driverPending`/`active`;
  - scheduler de recuperação (`*/15min`) processa apenas itens vencidos por query:
    - `postChargeExtension.status == X`
    - `postChargeExtension.nextActionAt <= now`
    - `orderBy(postChargeExtension.nextActionAt)`.

## Autoridade de decisão
- Backend é autoridade em elegibilidade e débito.
- Pre-check no cliente é apenas informativo.
- UI usa `failed-precondition` + `details.reason == "LIMIT_EXCEEDED"` para UX consistente.
- Cobrança final usa sempre o `pricingSnapshot` da viagem (não a tarifa corrente) para evitar drift após alterações de tarifário.
- Reporting e reconstrução histórica leem sempre do `TripPricingSnapshot` persistido; não reinterpretam viagens antigas a partir do tarifário atual nem do catálogo atual de tipos de transporte.
- Para viagens package-covered, suporte e reporting correlacionam `tripPackageBooking`, `reservation` e `trip` através dos snapshots persistidos; alterações posteriores ao template do package ou ao transporte não reescrevem este histórico.
- Depois do pricing lock, o multiplicador da viagem principal não é reavaliado em `acceptedAt`, `startedAt`, `completedAt` nem no fecho financeiro.

## Runtime de Callables (custos/latência)
- Endpoints críticos e não críticos usam `minInstances: 0` para eliminar custo base reservado:
  - críticos: `requestTrip`, `transitionTripState`, `cancelTrip`.
  - não críticos: `retryTripPayment`, `requestTripExtension`, `respondTripExtension`, `closeTripExtensionFlow`, `endTripExtensionEarly`, `handleTripFinancialAction`.
- O tiering mantém-se por organização/configuração, mas sem reserva mínima ativa.
- `concurrency` mantém-se em `40` para ambos os perfis; rollout deve ser faseado com monitorização de p95.

## Invariantes
- Transições só são válidas se `from -> to` existir no contrato canónico.
- Moeda é obrigatória e validada em paths críticos.
- Operações entre moedas diferentes falham explicitamente.
- A classificação de fase (`TripPhase`) é a única fonte para decisões de "ativo vs não ativo" em listeners e UI.
- Quando uma viagem entra em estado terminal (`COMPLETED`, `CHARGE_APPLIED`, cancelamentos, `NO_SHOW`, `NO_DRIVERS_AVAILABLE`), o backend deve libertar sempre o `driverStatus` do motorista associado (`isBusy=false`, limpar `currentTripId`) e restaurar disponibilidade quando aplicável antes de tarefas secundárias poderem bloquear o listener.
- A sincronização final de metering é best-effort no listener de status: uma falha de snapshot/validação não pode impedir limpeza de ocupação do motorista nem restauração de disponibilidade.
- Sempre que uma viagem entra em `NO_DRIVERS_AVAILABLE`, o backend:
  - persiste o estado final em `trips/{tripId}`;
  - grava evento de transição em `tripEvents/{tripId}/events/{eventId}` com `eventType=state_transition`, `actorId=system` e `metadata.reason`;
  - dispara alerta operacional para utilizadores com papel `manager`.
- A seleção de motorista em `REQUESTED`/reassign:
  - tenta raios progressivos (`12km` → `24km` → `40km` → `60km` → `80km` → `100km`);
  - se não houver elegíveis num raio, expande para o próximo;
  - no esgotamento, grava `unfulfilledReason` explícito (ex.: `no_locations_within_100km`, `no_available_drivers_near_pickup_within_100km`, `no_vehicle_assignment_for_nearby_drivers`, `nearby_drivers_busy`).

## Observabilidade operacional de recusa de motorista
- A recusa do motorista é canonicamente representada por evento `tripEvents` com `toState=driverDeclined`.
- Admin e manager consultam essas recusas no detalhe operacional da viagem (timeline operacional).
- A timeline operacional deve exibir, no mínimo, `actorId` (motorista), `createdAt` e `metadata.reason` quando disponível.
- Quando a viagem entra em `NO_DRIVERS_AVAILABLE`, a UI operacional de `manager` deve exibir `unfulfilledReason` em formato legível (pt-PT) com código técnico visível para diagnóstico.

## Identidade operacional human-friendly
- Ecrãs operacionais não devem expor IDs técnicos por defeito (`tripId`, `clientId`, `driverId`, `vehicleId`).
- A UI deve priorizar identidade legível:
  - pessoas: `displayName`/`name` -> `email` -> `phone`;
  - viatura: `plate` -> `model`/tipo.
- Em listas/superfícies operacionais, quando dados legíveis faltarem, usar fallback determinístico `Referência ABCD...WXYZ`.
- Nos detalhes de viagem (`client`, `driver`, `manager`), a secção `Participantes` usa o mesmo critério human-friendly, mas o fallback final passa a `Indisponível`.
- IDs completos ficam restritos à secção colapsável `Detalhes técnicos` com ação de copiar.
- Exceção de superfície:
  - detalhe de viagem do `client`: não mostra `Detalhes técnicos`; quando a viagem está paga e existe recibo, mostra `Recibo` com ação `Exportar PDF`; a secção `Cobrança` deixa de ser exposta.
  - detalhe de viagem do `driver`: não mostra `Detalhes técnicos`.
  - detalhe de viagem do `manager`: mantém `Detalhes técnicos`.
- Nesta entrega a política é `snapshot-only`: identidade é resolvida apenas com dados já presentes no snapshot da viagem, sem lookups adicionais.

## Timeline do cliente
- A linha temporal do detalhe da viagem usa apenas eventos `eventType=state_transition`.
- Eventos de transição adjacentes com o mesmo par `fromState -> toState` são deduplicados no consumo para evitar repetição visual causada por writes redundantes.

## Validação de inputs operacionais (UI)
- Avanços críticos do motorista durante a viagem exigem confirmação explícita antes de chamar o backend:
  - `DRIVER_EN_ROUTE -> DRIVER_ARRIVED`: confirmação de chegada à recolha, ação visual warning.
  - `DRIVER_ARRIVED -> IN_TRIP`: confirmação de cliente na viatura, ação visual sucesso.
  - `IN_TRIP -> ARRIVED_DESTINATION/COMPLETED`: confirmação de chegada ao destino com aviso de cobrança, ação visual erro/crítica.
- Os botões principais do motorista não devem reutilizar a mesma cor/ícone entre etapas consecutivas; cada etapa precisa de semântica visual distinta para reduzir toques acidentais e facilitar uso com baixa atenção.
- Cancelamento por motorista e sobretaxa manual usam validação inline com submit bloqueado até valores válidos.
- Inputs monetários operacionais aceitam `,` e `.` no teclado e convertem para minor units sem `double`.
- Ecrã operacional de manager valida `supportStatus`, `supportNote` e motivo de cancelamento com foco no primeiro erro no submit.
- `supportStatus` está fechado em enum (persistido como código string):
  - `open`
  - `in_analysis`
  - `waiting_client`
  - `resolved`
  - `escalated`
- Valores legacy de `supportStatus` fora da política são legíveis, mas exigem seleção válida do enum antes de guardar.
- Cancelamento por suporte (manager/admin com `actor=support`) é permitido apenas até `DRIVER_ARRIVED`:
  - permitidos: `REQUESTED`, `DRIVER_ASSIGNED_WAITING_ACCEPTANCE`, `DRIVER_ACCEPTED`, `DRIVER_DECLINED`, `DRIVER_EN_ROUTE`, `DRIVER_ARRIVED`;
  - bloqueados: `IN_TRIP`, `ARRIVED_DESTINATION`, `EXTENSION_WINDOW`, `COMPLETED`, `CHARGE_APPLIED`, `CANCELLED_BY_CLIENT`, `CANCELLED_BY_DRIVER`, `NO_SHOW`, `NO_DRIVERS_AVAILABLE`.
- O bloqueio de cancelamento por suporte é aplicado em duas camadas:
  - UI (botão indisponível e mensagem explícita);
  - callable backend (`failed-precondition` com `reason=cannot_cancel_after_trip_started`).

## Estado operacional no gestor (chips)
- Lista e detalhe operacional do gestor usam chip com:
  - label textual (obrigatório para acessibilidade);
  - ícone semântico por categoria;
  - cor de foreground/background com contraste.
- Semântica de cor:
  - sucesso (verde): `COMPLETED`, `CHARGE_APPLIED`;
  - erro (vermelho): `CANCELLED_BY_CLIENT`, `CANCELLED_BY_DRIVER`, `NO_SHOW`;
  - warning (laranja): `NO_DRIVERS_AVAILABLE`;
  - ativo/info (azul): restantes estados operacionais ativos.

## Referências de implementação
- `contracts/trip_state_machine/transitions.json`
- `scripts/check_trip_state_parity.dart`
- `functions/src/trips/tripStateMachineCallables.ts`
- `functions/src/trips/buildTripsFunctions.ts`
- `lib/features/trips/data/repositories/trip_repository_impl.dart`
- `lib/features/trips/domain/usecases/derive_trip_phase.dart`
- `lib/features/trips/domain/usecases/get_recent_client_completed_destinations.dart`
