# As-Is: Workflows Implementados

## 1) Autenticação e roteamento por papel
1. Utilizador autentica via Firebase Auth.
2. Papel é resolvido por claims; fallback em `users/{uid}`.
3. App redireciona para shell do papel (`client`, `driver`, `manager`, `admin`).

## 2) Pedido de viagem até cobrança
1. Cliente submete pedido via callable `requestTrip`.
2. Backend valida elegibilidade financeira e cria `trips/{tripId}` com `REQUESTED`.
3. Trigger atribui motorista/viatura e move para `DRIVER_ASSIGNED_WAITING_ACCEPTANCE`.
4. Motorista aceita/recusa por callable de transição.
5. Fluxo progride até `COMPLETED`.
6. Trigger de finalização processa cobrança e tenta fechar em `CHARGE_APPLIED`.
7. Paridade de transições entre Dart e TS é validada por `scripts/check_trip_state_parity.dart`.

## 3) Cancelamento, extensão e sobretaxa
- Cancelamento via callable `cancelTrip` com ator/tipo e registo de evento/auditoria.
- Extensão: cliente pede e motorista responde por callables dedicados.
- Sobretaxa manual: motorista propõe, cliente responde.

## 4) Reservas
1. Cliente cria reserva.
2. Scheduler diário ativa reservas do dia.
3. Sistema cria viagem operacional derivada da reserva.

## 5) Localização operacional do motorista
- Motorista escreve localização no RTDB.
- Cliente lê dados de tracking durante viagem ativa.
- Scheduler monitoriza heartbeat e gera alertas operacionais.

## 6) Gestão administrativa
- Admin gere entidades principais (users, fleet, pricing, balances, events, audit, reports).
- Manager tem permissões operacionais restritas em múltiplos fluxos.

## 7) Offline crítico
- Operações críticas (trip lifecycle/financeiro) exigem internet.
- Apenas operações não críticas específicas podem ser reexecutadas após reconexão.

## Divergências observadas no workflow
- Contrato monetário ainda coexistente com nomes legacy `*Cents` em partes não críticas.
- Pré-validação de elegibilidade no cliente continua auxiliar; decisão final é sempre backend.
