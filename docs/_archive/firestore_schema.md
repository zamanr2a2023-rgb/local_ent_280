# DEPRECATED — do not use

Documento arquivado para histórico.
Fonte oficial atual: docs/README.md.

# Esquema Firestore (atualizado)

## Coleções

### users/{uid}
- uid (string, id do documento)
- role (string: `client`, `driver`, `admin`)
- name (string)
- phone (string)
- email (string?)
- photoUrl (string?)
- isActive (bool)
- discountPercentGlobal (double?)
- discountPercentByTime (double?)
- discountPercentByDistance (double?)
- discountFixedCents (int?)
- createdAt (timestamp)
- updatedAt (timestamp)

Para condutores, `isActive`, `availabilityEnabled` e `isAvailable` vivem em
`driverStatus/{uid}`.

#### users/{uid}/fcmTokens/{token}
- token (string)
- platform (string: `android`, `ios`, `web`, etc.)
- appVersion (string?, opcional)
- enabled (bool)
- createdAt (timestamp)
- updatedAt (timestamp)
- lastSeenAt (timestamp)
- tokenExpiresAt (timestamp, TTL para limpeza automática de tokens inativos/obsoletos)


### driversPublic/{driverId}
- initials (string)
- displayName (string, versão pública para cliente)
- photoUrl (string?, opcional)
- rating (double?, opcional)
- vehicleSummary (map?, opcional)
  - plate (string?)
  - model (string?)
- updatedAt (timestamp)

### vehicles/{vehicleId}
- plate (string)
- model (string)
- capacity (int)
- isActive (bool)
- notes (string)
- defaultTransportType (map?)
  - id (string)
  - name (string)
- photoUrl (string?)
- createdAt (timestamp)
- updatedAt (timestamp)

### driverVehicleAssignments/{driverId} (fonte de verdade)
- vehicleId (string)
- updatedAt (timestamp)

Esta coleção é a **única** fonte de verdade para atribuições condutor → viatura.
Os campos `users/{driverId}.vehicleId` e `vehicles/{vehicleId}.driverId` estão
**descontinuados** e não devem ser escritos.

### driverStatus/{driverId}
- isActive (bool)
- availabilityEnabled (bool)
- isAvailable (bool)
- vehicleId (string?)
- lastSeenAt (timestamp)
- currentTripId (string?)
- isBusy (bool?)
- lastHeartbeatAlertAt (timestamp?, opcional)
- updatedAt (timestamp)

Localização do condutor é mantida apenas no Realtime Database em
`driverLocations/{driverId}`.

### transport_types/{transportTypeId}
- name (string)
- description (string)
- multiplier (double)
- createdAt (timestamp)
- updatedAt (timestamp)

### tariffs/{tariffId}
- base (money)
- perKm (money)
- perMinute (money)
- perWaitMinute (money)
- penaltyFees (map)
  - lateCancellation (money)
  - noShow (money)
- multiplierRules (array<map>)
  - id (string)
  - type (string: `day_of_week`, `time_range`, `holiday`)
  - multiplier (double)
  - daysOfWeek (array<int>, opcional)
  - timeRange (map, opcional)
    - startMinutes (int)
    - endMinutes (int)
  - holidayDates (array<string YYYY-MM-DD>, opcional)
- createdAt (timestamp)
- updatedAt (timestamp)

### settings/global
- operationCurrency (string, obrigatório, ex: `EUR`)

`money` = map obrigatório no formato `{ amountMinor: int, currency: string }`.

### pricingSchedules/{scheduleId}
- dateFrom (timestamp)
- dateTo (timestamp)
- hourStart (int)
- hourEnd (int)
- coefficient (double)
- label (string)
- isActive (bool)

### specialDays/{specialDayId}
- date (timestamp)
- coefficientOverride (double)
- label (string)

### balances/{clientId}
- balance (money)
- debtLimit (money, default `{amountMinor: -2000, currency: settings/global.operationCurrency}`)
- createdAt (timestamp)
- updatedAt (timestamp)

Regra de autorização de débito no servidor (contrato):
- `creditLimitMinor = abs(debtLimit.amountMinor)`
- `balanceAfterMinor = balance.amountMinor - debitAmountMinor`
- A cobrança/pedido só é aceite quando `balanceAfterMinor >= -creditLimitMinor`.
- Em violação, APIs devolvem `failed-precondition` com `details.reason = LIMIT_EXCEEDED`.

### balance_adjustments/{adjustmentId}
- clientId (string)
- adminId (string)
- delta (money)
- reason (string)
- tripId (string?, opcional)
- createdAt (timestamp)

### audit/{entryId}
- actionType (string: `balance_adjustment`, `tariff_edit`, `trip_surcharge`)
- adminId (string)
- adminName (string)
- reason (string)
- before (map)
- after (map)
- subject (string?)
- createdAt (timestamp)

### events/{eventId}
- targetType (string: `driver`, `client`, `vehicle`, `broadcast`)
- targetId (string?, quando não for broadcast)
- title (string)
- message (string)
- scheduledAt (timestamp)
- createdByAdminId (string)
- status (string: `scheduled`, `cancelled`, `completed`)
- createdAt (timestamp)
- updatedAt (timestamp)

### trips/{tripId}
- **Autorização**: leitura para participantes (cliente/condutor) e admin; escrita direta apenas para admin. Alterações de estado e campos financeiros por cliente/condutor devem ser feitas via Cloud Functions/callables.
- status (string, ver estados abaixo)
- isActive (bool)
- clientId (string)
- assignedDriverId (string?)
- vehicleId (string?)
- acceptedDriverId (string?)
- declinedByDriverId (string?)
- driverDeclineReason (string?)
- assignmentAttempts (int?)
- reservationId (string?, opcional)
- finalCost (money?, opcional)
- pickup (map)
  - latitude (double)
  - longitude (double)
  - address (string)
- destination (map)
  - latitude (double)
  - longitude (double)
  - address (string)
- transportType (map)
  - id (string)
  - name (string)
- clientSummary (map?)
  - displayName (string)
  - photoUrl (string?)
- driverSummary (map?)
  - displayName (string)
  - photoUrl (string?)
- vehicleSummary (map?)
  - plate (string)
- pricingSnapshot (map)
  - base (money)
  - perKm (money)
  - perMinute (money)
  - perWaitMinute (money)
  - lateCancellationFee (money)
  - noShowFee (money)
  - appliedMultiplierId (string?, regra aplicada)
  - appliedMultiplier (double)
  - pricingScheduleId (string?, opcional)
  - specialDayId (string?, opcional)
  - multipliers (map<string,double>)
  - estimatedTotal (money?)
- meteringSnapshot (map?)
  - totalMinutes (int)
  - totalWaitMinutes (int)
  - totalDistanceKm (double)
  - estimatedCostCents (int)
  - activeMultiplierId (string?)
  - lastUpdatedAt (timestamp?)
- extensionRequestStatus (string: `NONE`, `REQUESTED`, `ACCEPTED`, `DECLINED`)
- extensionRequestedAt (timestamp?)
- extensionRespondedAt (timestamp?)
- cancellation (map?)
  - actor (string: `CLIENT`, `DRIVER`, `SYSTEM`)
  - type (string: `PRE_ARRIVAL`, `POST_ARRIVAL`, `NO_SHOW`, `DRIVER`)
  - fee (money)
  - reason (string?)
- manualSurcharge (map?)
  - status (string: `none`, `requested`, `approved`, `rejected`)
  - amount (money)
  - reason (string?)
  - requestedAt (timestamp?)
  - respondedAt (timestamp?)
  - requestedBy (string?)
  - respondedBy (string?)
- paymentStatus (string: `NONE`, `PENDING`, `PAID`, `FAILED`)
- paymentPendingAt (timestamp?)
- paymentPaidAt (timestamp?)
- paymentFailedAt (timestamp?)
- paymentFailureReason (string?, opcional para observabilidade)
- receipt (map?)
  - baseCents (int)
  - distanceCents (int)
  - timeCents (int)
  - waitCents (int)
  - penaltiesCents (int)
  - surchargeCents (int)
  - subtotalCents (int)
  - discountCents (int)
  - multiplierValue (double)
  - multiplierChargeCents (int)
  - totalCents (int)
  - totalDistanceKm (double)
  - totalMinutes (int)
  - totalWaitMinutes (int)
  - hasMeteringData (bool)
  - calculatedFrom (string?, `metering` ou `estimate`)
  - discountBreakdown (map?)
    - discountPercentGlobal (double?)
    - discountPercentByTime (double?)
    - discountPercentByDistance (double?)
    - discountFixedCents (int?)
    - discountGlobalCents (int)
    - discountTimeCents (int)
    - discountDistanceCents (int)
    - discountFixedCentsApplied (int)
    - discountTotalCents (int)
- rating (map?)
  - stars (int)
  - feedback (string?)
  - clientId (string?)
  - createdAt (timestamp?)
- createdAt (timestamp)
- requestedAt (timestamp)
- updatedAt (timestamp)
- driverAssignedAt (timestamp?)
- acceptedAt (timestamp?)
- driverEnRouteAt (timestamp?)
- driverDeclinedAt (timestamp?)
- arrivedAt (timestamp?)
- startedAt (timestamp?)
- arrivedDestinationAt (timestamp?)
- extensionWindowAt (timestamp?)
- completedAt (timestamp?)
- cancelledAt (timestamp?)
- chargeAppliedAt (timestamp?)

### tripEvents/{tripId}/events/{eventId}
- tripEventExpiresAt (timestamp, TTL para retenção limitada de histórico operacional)
- fromState (string)
- toState (string)
- actorId (string)
- eventType (string: `state_transition`, `surcharge_proposed`,
  `surcharge_approved`, `surcharge_rejected`)
- metadata (map?, opcional)
- createdAt (timestamp)

### trips/{tripId}/pathPoints/{pointId}
- latitude (double)
- longitude (double)
- timestamp (timestamp)
- pathPointExpiresAt (timestamp, TTL para limpeza automática de pontos históricos de rota)

### trips/{tripId}/driverContactSnapshots/{tripId}
- driverId (string)
- name (string)
- phone (string)

### reservations/{reservationId}
- clientId (string)
- scheduledAt (timestamp)
- scheduledDayKey (string, `YYYY-MM-DD` em Europe/Lisbon)
- scheduledMinutesLocal (int?, minutos desde 00:00 no fuso Europe/Lisbon)
- status (string: `scheduled`, `pending`, `confirmed`, `cancelled`, `failed`,
  `completed`)
- pickup (map)
  - latitude (double)
  - longitude (double)
  - address (string)
- destination (map)
  - latitude (double)
  - longitude (double)
  - address (string)
- transportType (map)
  - id (string)
  - name (string)
- assignedDriverId (string?)
- tripId (string?, opcional)
- activatedAt (timestamp?, opcional)
- failedAt (timestamp?, opcional)
- failureReason (string?, opcional)
- createdAt (timestamp)
- updatedAt (timestamp)

### config/cancellation_policy
- preArrivalFeeCents (int)
- postArrivalFeeCents (int)
- noShowFeeCents (int)
- noShowMinutes (int)

### jobs/{lockId}
- status (string: `running`, `completed`, `failed`)
- scheduledDayKey (string?, opcional para locks de scheduler)
- operationType (string?, opcional para locks de operação)
- tripId (string?, opcional)
- createdAt (timestamp)
- updatedAt (timestamp?)
- releasedAt (timestamp?)
- expiresAt (timestamp, TTL para limpeza automática de locks operacionais)

## Estados da viagem

`requested → driver_assigned_waiting_acceptance → driver_accepted → driver_en_route
→ driver_arrived → in_trip → arrived_destination → extension_window
→ completed → charge_applied`

`no_drivers_available`, `driver_declined`, `cancelled_by_client`,
`cancelled_by_driver` e `no_show` podem surgir conforme o fluxo.

Os estados de `trips.status` e `paymentStatus` são tratados de forma
**case-insensitive** (a escrita canónica é em maiúsculas).

## Estratégia de timestamps do servidor

- Todos os documentos com `createdAt`/`updatedAt` usam
  `FieldValue.serverTimestamp()` na criação.
- Atualizações usam `FieldValue.serverTimestamp()` apenas em `updatedAt`.
- Ao ler, os timestamps devem ser convertidos para `DateTime`.

## Realtime Database

### driverLocations/{driverId}
- l (array<double>, [lat, lng])
- g (string, geohash)
- heading (double?)
- speed (double?)
- ts (epoch em milissegundos)

## Migração
- Script idempotente: `scripts/migrate_money_fields.ts`.
- Regista alterações de `settings/global.operationCurrency` em `audit` com `actionType=operation_currency_update`.
