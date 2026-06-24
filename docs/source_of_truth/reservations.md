# Source of Truth: Reservations

## Objetivo do domínio
- Manter `reservations` como contrato operacional agendado, separado do estado comercial do booking.
- Suportar duas origens ativas:
  - `internal_staff`
  - `package`

## Modelo canónico
- Coleção ativa: `reservations/{reservationId}`.
- Estados ativos:
  - `scheduled`
  - `pending`
  - `confirmed`
  - `cancelled`
  - `failed`
  - `completed`

## Contrato ativo
- Campos obrigatórios para todas as reservas:
  - `source`
  - `clientId`
  - `scheduledAt`
  - `scheduledDayKey`
  - `scheduledMinutesLocal`
  - `pickup`
  - `destination`
  - `transportType`
  - `status`
  - `createdAt`
  - `updatedAt`
- Campos opcionais por reserva:
  - `assignedDriverId`
  - `vehicleId`
  - `tripId`
- `pickup` e `destination` usam `TripLocation`.
- `transportType` usa snapshot leve `{ id, name }`.

## Regras por origem
- `internal_staff`
  - exige `createdByUserId`
  - exige `createdByRole`
  - normalmente nasce já com `assignedDriverId`
- `package`
  - exige `packageId`
  - exige `packageBookingId`
  - pode nascer sem `assignedDriverId`
  - pode nascer sem `vehicleId`
  - não usa `packageLegType`

## Workflow canónico
1. `internal_staff` continua a ser criado por operações internas.
2. `package` é criado imediatamente após checkout bem sucedido do package.
3. Antes da compra, o backend do package valida viabilidade operacional mínima conservadora.
4. Após compra confirmada, a `reservation` package fica persistida com:
   - `source = package`
   - `status = scheduled`
   - `assignedDriverId = null`
   - `vehicleId = null`
   - `tripId = null`
5. A ativação operacional dedicada do package corre em `scheduledAt - 15min` ou imediatamente quando esse threshold já foi atingido.
6. Na ativação:
   - seleciona `driver` e `vehicle`;
   - atualiza a `reservation`;
   - cria `Trip` package-covered.
7. Se a ativação falhar antes da execução:
   - `reservation.status = cancelled`
   - o booking comercial é cancelado e reembolsado integralmente.

## Tempo canónico
- `scheduledAt`, `scheduledDayKey` e `scheduledMinutesLocal` são derivados com timezone operacional canónico `Europe/Lisbon`.
- O produto não deve depender de `toLocal()` implícito para reservas de package.

## Ownership e UX
- `client` não cria, lê nem manipula `reservations` diretamente.
- `client` interage apenas com o booking comercial do package.
- O workspace operacional mostra reservas `internal_staff` e `package`.
- Reservas `package` aparecem primeiro como compromissos operacionais sem atribuição final.

## Invariantes
- Cada reserva ativa tem sempre `clientId`, `scheduledAt`, localizações válidas e `transportType`.
- `internal_staff` tem sempre identidade explícita do criador.
- `package` tem sempre `packageId` e `packageBookingId`.
- A ativação não cria `Trip` duplicado para o mesmo `reservationId`.
- `packageLegType` não faz parte do contrato ativo.

## Regras de autorização
- `client`: sem acesso direto a `reservations`.
- `driver`: pode ler apenas reservas onde `assignedDriverId == request.auth.uid`.
- `admin`: pode ler e gerir reservas `internal_staff` e ver reservas `package`.
- `manager`: pode ler e gerir reservas `internal_staff` com claims adequadas e consultar reservas `package` no workspace operacional.

## Integrações e dependências
- Firestore:
  - `reservations`
  - `tripPackageBookings`
  - `trips`
  - `audit`
- Functions:
  - `activateReservationsForDay` para `internal_staff`
  - ativação dedicada de package para `source = package`

## Fora de escopo
- Recorrência.
- Gestão self-service de reservas pelo cliente.
- Legs `outbound/return`.

## Referências de implementação
- `lib/features/trips/domain/entities/reservation.dart`
- `lib/features/trips/domain/entities/reservation_source.dart`
- `lib/features/trips/data/mappers/reservation_firestore_mapper.dart`
- `functions/src/trips/buildTripsFunctions.ts`
- `functions/src/trip_packages/buildTripPackageFunctions.ts`
- `firestore.rules`
