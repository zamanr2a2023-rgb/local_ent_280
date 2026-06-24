# As-Is: Funcionalidades Implementadas

## Âmbito e método
- Fonte: código atual em `lib/`, `functions/`, `firestore.rules`, `database.rules.json` e documentação existente.
- Objetivo: descrever o que está implementado hoje, sem projetar alvo futuro.

## Domínios e estado atual

### Trips
- Pedido de viagem via callable `requestTrip`.
- Atribuição automática de motorista/viatura por trigger `assignDriverOnTripCreation`.
- Transições críticas via callables (`transitionTripState`, `cancelTrip`, `requestTripExtension`, `respondTripExtension`, `handleTripFinancialAction`).
- Acompanhamento de viagem ativa para cliente e motorista.
- Eventos de viagem em `tripEvents/{tripId}/events`.
- Persistência de path points em `trips/{tripId}/pathPoints`.

### Reservations
- Criação/edição de reservas pelo cliente.
- Ativação diária por scheduler (`activateReservationsForDay`).
- Conversão de reserva em viagem com snapshot operacional.

### Pricing
- Tarifas com objeto monetário em vários fluxos (`base`, `perKm`, `perWaitMinute`).
- Multiplicadores por agenda (`pricingSchedules`) e dia especial (`specialDays`).
- Estimativa no app e cálculo final no backend.

### Users/Roles
- Papéis ativos: `client`, `driver`, `manager`, `admin`.
- Resolução de papel por custom claims com fallback para `users/{uid}.role`.
- Shell de navegação role-based no app.

### Balances
- Leitura de saldo do cliente.
- Gestão admin de ajustes e saldo.
- Backend usa regra de limite com `LIMIT_EXCEEDED`.
- Contrato principal em `money` (`amountMinor` + `currency`) nos fluxos críticos.
- Leitura de schema inválido em Firestore falha explicitamente (sem fallback de normalização).

### Notifications
- Registo de token FCM em `users/{uid}/fcmTokens`.
- Inicialização de FCM no app.
- Envio por Functions para eventos e updates operacionais.

### Location/Tracking
- Localização do motorista em RTDB (`driverLocations/{driverId}`).
- Presença/heartbeat de motorista com monitorização agendada.
- Consumo de localização em ecrãs cliente/motorista.

### Admin
- Gestão de utilizadores, frota, tarifas, transport types, saldos, auditoria, eventos e relatórios.
- Ação admin crítica: `adminDeleteUser`.

## Funcionalidades parciais, duplicadas ou com risco
- `SM-015` (audit action type) permanece aberto como principal risco funcional transversal.

## Notas do snapshot
- Snapshot atualizado após cleanup MVP v3 (PR1-PR3).
- Esta secção descreve implementação atual; decisões de desenho ficam em `docs/adr/`.
