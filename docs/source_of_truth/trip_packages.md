# Source of Truth: Trip Packages

## Objetivo do domínio
- Vender um produto comercial fixo para um destino fixo.
- Cobrar o package no checkout, mas bloquear qualquer ação operacional até existir decisão explícita de `admin` ou `manager(tp)`.
- Manter separação estrita entre:
  - governação comercial do booking em `tripPackageBookings`
  - execução operacional em `reservations` e `trips`
  - observabilidade operacional numa fila dedicada de package ops

## Modelo canónico
- Template comercial: `tripPackages/{packageId}`
  - `name`
  - `photoUrl`
  - `description`
  - `destination: TripLocation`
  - `price: Money`
  - `allowedTransportTypes[{ id, name, packagePriceMultiplierBasisPoints }]`
  - `isActive`, `archivedAt`, `snapshotVersion`, `createdAt`, `updatedAt`
- Booking comercial governado: `tripPackageBookings/{bookingId}`
  - `clientId`, `packageId`, `reservationId`, `tripId?`
  - `assignedDriverId?`, `assignedVehicleId?`
  - `packageSnapshot`
  - `pickup`
  - `destinationSnapshot`
  - `scheduledAt`
  - `transportType`
  - `price`
  - `priceAdjustmentMinor`
  - `chargedAmount`
  - `refundedAmount`
  - `clientCancellationClosesAt`
  - `status = pendingApproval | approved | awaitingDriverAcceptance | driverAssigned | activationInProgress | cancelled | rejected | completed`
  - `refundStatus = none | full`
  - `assignmentStatus = pending | assigned | failed`
  - `assignmentWindowStartsAt`
  - `nextAssignmentAttemptAt?`
  - `lastAssignmentAttemptAt?`
  - `assignmentAttemptsCount`
  - `approval = { requestedAt?, decidedAt?, decidedByUserId?, decidedByRole?, decision, reason? }`
  - `opsQueueBucket = pendingApproval | approvedWaitingOpsWindow | awaitingDriverAcceptance | activationIssues | finalized`
  - `opsNextActionAt?`
  - `opsIsActionable`
  - `opsLastIssueCode = none | noEligibleDriversFound | driverAcceptanceTimedOut | driverAcceptanceDeclinedAll | activationWindowMissed | activationCreationFailed | operationalPreExecutionFailed`
  - `cancellation = { reasonCode, reasonLabel?, cancelledAt, cancelledBy }`
  - `createdAt`, `updatedAt`
- Operação idempotente de checkout: `tripPackageBookingOperations/{operationId}`
  - `clientId`, `idempotencyKey`, `requestHash`
  - `status = pending | succeeded | failed`
  - `bookingId?`, `errorCode?`
  - `createdAt`, `updatedAt`

## Campos e conceitos removidos do produto ativo
- Não existe `tripPackageDepartures`.
- Não existe `seatCount`.
- Não existe ocupação partilhada.
- Não existe número mínimo de participantes.
- Não existem `operatingWeekdays`, `slotDefinitions`, horários fixos, reminders próprios, meeting point tardio nem legs `outbound/return`.
- `allowedTransportTypes` é obrigatório e não pode estar vazio.
- `packagePriceMultiplierBasisPoints` é obrigatório em cada transporte permitido.
- `packagePriceMultiplierBasisPoints` usa semântica `10000 = 1.0000x`, com intervalo canónico `5000..30000`.
- Leituras de templates/tipos de transporte legados sem `packagePriceMultiplierBasisPoints`
  são toleradas para não bloquear o backoffice: a app e as Functions usam `10000`
  como multiplicador neutro e registam aviso. Escritas novas continuam obrigadas a
  persistir o campo.

## Workflow canónico
1. `admin` ou `manager(tp)` cria/edita um template comercial simples em `tripPackages`.
2. O cliente vê apenas templates ativos e não arquivados no catálogo.
3. No detalhe do package, o cliente escolhe:
   - `pickup`
   - `scheduledAt`
   - `transportType` dentro de `allowedTransportTypes`
4. `confirmTripPackageBooking` valida:
   - package ativo e não arquivado;
   - `allowedTransportTypes` não vazio;
   - `scheduledAt >= now + 15min`;
   - `transportType` permitido;
   - `transportType.packagePriceMultiplierBasisPoints` presente e no intervalo canónico;
   - se `scheduledAt - now <= 60min`, executa apenas um probe de viabilidade imediata para rejeitar compras claramente inviáveis.
5. O checkout canónico executa numa operação idempotente:
   - recálculo server-side de `chargedAmount = roundHalfUp(price.amountMinor * packagePriceMultiplierBasisPoints / 10000)`;
   - débito imediato do package pelo `chargedAmount`;
   - criação do `tripPackageBooking`;
   - criação da `reservation` com `source = package` e sem `assignedDriverId`;
   - persistência do booking em `pendingApproval`;
   - persistência de `approval.decision = pending`;
   - persistência dos campos da fila ops.
6. Enquanto o booking estiver `pendingApproval` ou `rejected`:
   - jobs operacionais não fazem atribuição;
   - não há notificação para motorista;
   - não há criação de `Trip`;
   - a `reservation` existe apenas como contexto operacional não acionável.
7. `approveTripPackageBooking` e `rejectTripPackageBooking` só podem ser executados por `admin` ou `manager(tp)`:
   - `approve` grava auditoria em `approval.*` e move o booking para `approved`;
   - se a janela operacional já abriu, `approve` avança logo para `awaitingDriverAcceptance`;
   - `reject` move o booking para `rejected` e reutiliza o mesmo path transacional de cancelamento + refund pré-execução.
8. Depois da aprovação:
   - `approved` é estado durável quando a janela operacional ainda não abriu;
   - `awaitingDriverAcceptance` é o primeiro estado operacional acionável;
   - retries de atribuição continuam de `15 em 15` minutos enquanto `now < scheduledAt`.
9. Quando a atribuição acontece:
   - a `reservation` passa a ter `assignedDriverId` e `vehicleId`;
   - o booking espelha `driverAssigned`;
   - o motorista recebe notificação best-effort;
   - a `Trip` ainda não é criada nesse momento.
10. A ativação operacional final continua separada da atribuição:
   - usa a reserva já atribuída;
   - marca o booking como `activationInProgress`;
   - cria `Trip` package-covered sem nova cobrança;
   - persiste o linkage `booking -> reservation -> trip`.
11. Se a operação falhar antes da execução, o outcome canónico é:
   - booking `cancelled` ou `rejected`, conforme a origem da decisão;
   - reservation `cancelled`;
   - refund `full`;
   - `reasonCode = operational_pre_execution_failed` para o outcome externo;
   - `opsLastIssueCode` preserva o motivo interno mais preciso.
12. Quando a execução termina com sucesso, o booking transita para `completed`.

## Política de cancelamento
- Compra permitida apenas para `scheduledAt >= now + 15min`.
- `clientCancellationClosesAt = scheduledAt - 1h`.
- O cliente pode cancelar enquanto `now < clientCancellationClosesAt` e o booking não estiver num estado terminal.
- Entre `15` e `60` minutos antes da viagem:
  - a compra continua permitida;
  - exige probe imediato de viabilidade;
  - a UI mostra explicitamente que a compra pode ficar sem cancelamento pelo cliente.
- Dentro da última hora o cliente não pode cancelar.
- Cancelamento administrativo explícito de booking futuro segue o mesmo path canónico de pré-execução com refund full.

## Política de snapshots
- `tripPackageBookings` guarda snapshots autoritativos após a compra:
  - `packageSnapshot`
  - `destinationSnapshot`
  - `transportType`
  - `price`
  - `priceAdjustmentMinor`
  - `chargedAmount`
- Depois da compra, refunds, reporting, suporte e leitura operacional dependem apenas destes snapshots persistidos; alterações posteriores em `transport_types` não reavaliam bookings já comprados.
- `reservations` guardam snapshots operacionais suficientes na criação.
- `trips` guardam snapshots suficientes na ativação.
- Alterações posteriores ao template do package ou aos metadados do transporte não reescrevem histórico.

## Tempo canónico
- O timezone operacional canónico é `Europe/Lisbon`.
- `scheduledAt`, `clientCancellationClosesAt`, `assignmentWindowStartsAt`, retries de atribuição e threshold de ativação final usam a mesma base temporal canónica.
- A UI do cliente e do backoffice não deve depender de `toLocal()` implícito para lógica de negócio.

## Regras financeiras
- O package é cobrado uma única vez no checkout.
- `price` é o preço base comercial do template.
- `priceAdjustmentMinor = chargedAmount.amountMinor - price.amountMinor`.
- `chargedAmount` é o valor final canónico cobrado no checkout.
- O `Trip` criado na ativação não gera novo débito.
- IDs de ledger são determinísticos:
  - débito: `trip_package_booking_${bookingId}_charge`
  - refund full: `trip_package_booking_${bookingId}_refund_full`

## Fila operacional dedicada
- A gestão operacional de packages vive numa fila dedicada e não em `/ops/reservations`.
- Buckets primários:
  - `pendingApproval`
  - `approvedWaitingOpsWindow`
  - `awaitingDriverAcceptance`
  - `activationIssues`
  - `finalized`
- O objetivo da fila é mostrar, sem inferência ad-hoc de UI:
  - decisão pendente;
  - próxima ação operacional;
  - linkage com reservation/trip;
  - auditoria de aprovação;
  - incidentes operacionais precisos.

## Permissões e superfícies
- `admin` e `manager(tp)`
  - criam, editam, ativam/desativam, arquivam e eliminam templates;
  - aprovam e rejeitam bookings;
  - consultam a fila operacional dedicada de packages;
  - podem cancelar bookings futuros explicitamente.
- `client`
  - lê catálogo ativo;
  - confirma bookings próprios;
  - acompanha estados comerciais e operacionais do próprio booking;
  - cancela os próprios bookings dentro da janela permitida.
- Firebase Storage
  - fotografias de templates usam `tripPackages/{packageId}/{fileName}`;
  - escrita é exclusiva de `admin` ou `manager(tp)`.

## Fora de escopo
- Qualquer conceito de package partilhado por departures.
- Ocupação, lugares, acompanhantes nominalizados ou capacidade persistida.
- Meeting point tardio.
- Legs `outbound/return`.
- Compatibilidade runtime com o modelo antigo, exceto normalização de leitura de `confirmed -> approved`.

## Referências de implementação
- `lib/features/trip_packages/`
- `functions/src/trip_packages/buildTripPackageFunctions.ts`
- `functions/src/trip_packages/tripPackagePolicy.ts`
- `functions/src/trip_packages/tripPackageTime.ts`
- `firestore.rules`
- `storage.rules`
- `firestore.indexes.json`
