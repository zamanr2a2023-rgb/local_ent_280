# ADR 0037: Reservas one-off source-aware com ownership interno

- **Estado**: Aceite
- **Data**: 2026-03-22

## Contexto

O produto deixou de suportar criação e gestão de reservas pelo cliente dentro da app. Ao mesmo tempo, o domínio já reutilizava `reservations` para packages, o que impedia simplificar o contrato para um único shape rígido orientado apenas a staff interno.

Era necessário:

- remover por completo o fluxo client-owned;
- manter packages sobre o mesmo core de reserva;
- preservar ativação diária e consumo do motorista;
- remover recorrência da superfície ativa para reduzir complexidade operacional.

## Decisão

1. Reservas manuais da app passam a existir apenas com `source = internal_staff`.
2. O modelo `Reservation` mantém-se source-aware, com `source` obrigatório.
3. O contrato partilhado ativo exige:
   - `source`
   - `clientId`
   - `assignedDriverId`
   - `scheduledAt`
   - `scheduledDayKey`
   - `scheduledMinutesLocal`
   - `pickup`
   - `destination`
   - `transportType`
   - `status`
   - `createdAt`
   - `updatedAt`
4. `internal_staff` exige adicionalmente:
   - `createdByUserId`
   - `createdByRole`
5. `package` mantém os seus metadados próprios (`vehicleId`, `packageId`, `packageBookingId`, `packageLegType`) sem ser forçado a `createdBy*`.
6. `assignedDriverId` é tratado como motorista planeado/preferido, não como hard assignment universal.
7. `activateReservationsForDay` tenta primeiro o `assignedDriverId` para `internal_staff`; se ficar indisponível, usa o fallback atual de auto-seleção.
8. Recorrência é removida da superfície ativa:
   - sem `reservationSeries`
   - sem callables de recorrência
   - sem reminder pipeline de recorrência
   - sem UI client-side de reservas
9. O workspace operacional de reservas é partilhado por `admin` e `manager` com `vt + vd + vc`.

## Consequências

### Positivas

- Fluxo de reservas muito mais simples e alinhado com a decisão de negócio.
- Menos superfícies client-side e menos regras/notifications de recorrência.
- Packages continuam compatíveis com o core partilhado.
- Ativação diária preserva o comportamento atual com preferência pelo motorista escolhido.

### Trade-offs

- O modelo partilhado continua a precisar de validação source-aware.
- Alguns artefactos documentais históricos sobre recorrência deixam de representar o produto ativo.
- Admin pode continuar a ler reservas fora do workspace operacional para observabilidade, mesmo que só `internal_staff` seja gerido manualmente na app.
