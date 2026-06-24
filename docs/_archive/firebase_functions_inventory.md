# DEPRECATED — do not use

Documento arquivado para histórico.
Fonte oficial atual: docs/README.md.

# Inventário de Cloud Functions

Este documento lista as funções exportadas em `functions/src/index.ts`, o respetivo trigger, o fluxo de consumo e a validação de necessidade.

## Funções HTTPS (callable)

### `requestTrip`
- **Trigger**: `onCall` (região `europe-southwest1`).
- **Fluxo de consumo**:
  1. App cliente chama `FunctionsService.call('requestTrip')`.
  2. `TripRepositoryImpl` envia o pedido e recebe `tripId`.
  3. A função valida o saldo projetado com a regra única `balanceAfter >= -creditLimitMinor`, cria o documento em `trips/{tripId}` e inicia o fluxo de atribuição do motorista.
- **Necessária**: **Sim**. É o ponto de entrada para pedidos de viagem no cliente.

#### Contrato de limite de crédito (estável)
- Regra única para validação financeira: `balanceAfterMinor >= -creditLimitMinor`.
- `creditLimitMinor = abs(debtLimit.amountMinor)` (ou `abs(debtLimitCents)` no formato legado).
- Quando a regra falha, o erro devolvido é sempre:
  - `code`: `failed-precondition`
  - `details.reason`: `LIMIT_EXCEEDED`

Exemplo de erro (`requestTrip`):

```json
{
  "error": {
    "status": "FAILED_PRECONDITION",
    "message": "Limite de crédito excedido.",
    "details": {
      "reason": "LIMIT_EXCEEDED",
      "operation": "request_trip",
      "balanceBeforeMinor": 500,
      "debitAmountMinor": 1200,
      "balanceAfterMinor": -700,
      "creditLimitMinor": 600
    }
  }
}
```

## Funções Firestore (document triggers)

### `assignDriverOnTripCreation`
- **Trigger**: `onDocumentCreated` em `trips/{tripId}`.
- **Fluxo de consumo**:
  1. Criada viagem via `requestTrip` ou ativação de reserva.
  2. A função procura motoristas disponíveis, escolhe veículo e atribui o motorista.
  3. Atualiza o estado para `DRIVER_ASSIGNED_WAITING_ACCEPTANCE`.
- **Necessária**: **Sim**. Automatiza atribuição inicial e evita viagens sem motorista.

### `handleTripStatusUpdates`
- **Trigger**: `onDocumentUpdated` em `trips/{tripId}`.
- **Fluxo de consumo**:
  1. Aplicação/operador atualiza estado do documento da viagem.
  2. A função notifica o motorista atribuído e gere aceitação/recusa.
  3. Caso exista recusa, tenta nova atribuição.
- **Necessária**: **Sim**. Gere o ciclo de aceitação do motorista e reatribuições.

### `finalizeTripOnCompletion`
- **Trigger**: `onDocumentUpdated` em `trips/{tripId}`.
- **Fluxo de consumo**:
  1. Viagem passa a `COMPLETED` ou entra em pagamento pendente.
  2. A função calcula custos, aplica descontos e revalida limite dentro da transação antes de cobrar saldo.
  3. Atualiza `balances`, `balance_adjustments` e eventos de cobrança.
- **Necessária**: **Sim**. É o fecho financeiro da viagem e evita inconsistências de saldo.

Exemplo de erro (`retryTripPayment`/cobrança manual quando excede limite):

```json
{
  "error": {
    "status": "FAILED_PRECONDITION",
    "message": "Limite de crédito excedido.",
    "details": {
      "reason": "LIMIT_EXCEEDED",
      "operation": "finalize_trip_payment",
      "balanceBeforeMinor": -300,
      "debitAmountMinor": 500,
      "balanceAfterMinor": -800,
      "creditLimitMinor": 500
    }
  }
}
```

### `notifyDriverOnAdminEventCreation`
- **Trigger**: `onDocumentCreated` em `events/{eventId}`.
- **Fluxo de consumo**:
  1. Admin cria evento direcionado a motorista.
  2. A função envia lembrete imediato quando aplicável.
  3. Regista timestamps de lembrete no documento.
- **Necessária**: **Sim**. Mantém motoristas informados sobre eventos administrativos.

## Funções agendadas (scheduler)

### `activateReservationsForDay`
- **Trigger**: `onSchedule` diário às 05:00 (Lisboa).
- **Fluxo de consumo**:
  1. App cliente cria reservas em `reservations`.
  2. A função ativa reservas do dia, cria viagens e atribui motorista/veículo.
  3. Atualiza o estado da reserva e regista falhas quando necessário.
- **Necessária**: **Sim**. Garante a conversão diária de reservas em viagens.

### `sendScheduledEventNotifications`
- **Trigger**: `onSchedule` (a cada minuto).
- **Fluxo de consumo**:
  1. Eventos agendados são consultados em `events`.
  2. A função envia lembretes para motoristas ou broadcast.
  3. Atualiza timestamps de lembrete.
- **Necessária**: **Sim**. Automatiza lembretes de eventos no tempo certo.

### `monitorDriverHeartbeat`
- **Trigger**: `onSchedule` (a cada minuto).
- **Fluxo de consumo**:
  1. Aplicação do motorista atualiza `driverStatus.lastSeenAt`.
  2. A função verifica motoristas disponíveis com heartbeat desatualizado.
  3. Emite alerta e notifica o motorista.
- **Necessária**: **Sim**. Suporta segurança operacional ao detetar perda de ligação.
