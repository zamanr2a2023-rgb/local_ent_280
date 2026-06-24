# List Filters Matrix (Fases 1 e 2)

## Objetivo
Matriz operacional para QA e troubleshooting dos filtros/pesquisa/ordenação nas listas críticas das Fases 1 e 2.

## Cliente — Viagens (`client_trips_screen.dart`)
- Pesquisa local: `tripId`, `pickup.address`, `destination.address`, `driverSummary.displayName`
- Chips rápidos: `Todas`, `Próximas`, `Em curso`, `Concluídas`
- Filtros avançados: `dateRange`
- Ordenação: `createdAt desc` (default), `createdAt asc`
- Persistência: `SharedPreferences` (`scope=clientTrips`)
- Query Firestore:
  - base: `where(clientId == uid).orderBy(createdAt, asc|desc)`
  - opcional: `where(status in ... )`, `createdAt >= start`, `createdAt <= end`
- Índices necessários:
  - `trips(clientId, createdAt ASC|DESC)`
  - `trips(clientId, status, createdAt ASC|DESC)`

## Motorista — Viagens (`driver_trips_screen.dart`)
- Pesquisa local: `tripId`, cliente (nome), `pickup.address`, `destination.address`
- Chips rápidos: `Todas`, `Finalizadas`, `Canceladas`
- Filtros avançados: `dateRange`
- Ordenação: `createdAt desc` (default), `createdAt asc`
- Persistência: `SharedPreferences` (`scope=driverTrips`)
- Query Firestore:
  - base: `where(assignedDriverId == uid).orderBy(createdAt, asc|desc)`
  - opcional: `where(status in ... )`, `createdAt >= start`, `createdAt <= end`
- Índices necessários:
  - `trips(assignedDriverId, createdAt ASC|DESC)`
  - `trips(assignedDriverId, status, createdAt ASC|DESC)`

## Cliente — Reservas (`client_reservations_screen.dart`)
- Pesquisa local: `reservationId`, `pickup.address`, `destination.address`, `transportType.name`, `seriesName`
- Chips rápidos: `Todas`, `Próximas`, `Passadas`
- Filtros avançados: `status`, `weekday`, `dateRange`
- Ordenação: `scheduledAt asc` (default), `scheduledAt desc`
- Persistência: `SharedPreferences` (`scope=clientReservations`)
- Query Firestore:
  - base: `where(clientId == uid).orderBy(scheduledAt, asc|desc)`
  - opcional: `where(status == ...)`, `scheduledAt >= start`, `scheduledAt <= end`
- Índices necessários:
  - `reservations(clientId, scheduledAt ASC|DESC)`
  - `reservations(clientId, status, scheduledAt ASC|DESC)`

## Admin — Relatórios (`admin_reports_screen.dart`)
- Pesquisa local/agregada: `driverSearchText`, `vehicleSearchText` (filtragem no pipeline de rows)
- Chips rápidos: tipo de relatório (`cliente`, `motorista`, `viatura`, `período`)
- Filtros avançados: `dateRange`, `debtFilter`, pesquisa contextual
- Ordenação: `totalCost`, `tripCount`, `totalDuration`, `label` com `asc|desc`
- Persistência: `SharedPreferences` (`scope=adminReports`)
- Query Firestore (records): `status in [COMPLETED, CHARGE_APPLIED]` + período obrigatório por `completedAt` em janela `[from, to)` + `orderBy(completedAt)`; filtros de dívida/motorista/viatura aplicados após carga para agregação
- Índices necessários:
  - `trips(status, completedAt ASC)` para a query base de relatórios concluídos
  - `trips(status, startedAt ASC)` mantido para compatibilidade operacional de troubleshooting

## Admin — Auditoria (`admin_audit_screen.dart`)
- Pesquisa local: não aplicável nesta fase
- Chips rápidos: `Todas`, `Ajustes de saldo`, `Edições de tarifa`, `Sobretaxas`
- Filtros avançados: `dateRange`, `adminId`
- Ordenação: `createdAt desc` (default), `createdAt asc` (local)
- Persistência: `SharedPreferences` (`scope=adminAudit`)
- Query Firestore:
  - base: filtros por `actionType`, `adminId`, `createdAt` no intervalo
  - ordenação asc aplicada localmente para evitar índice adicional de auditoria
- Índices necessários:
  - mantêm-se os índices DESC existentes de auditoria

## Manager — Viagens operacionais (`manager_trips_screen.dart`)
- Pesquisa local: `tripId`, cliente, motorista, `pickup.address`, `destination.address`
- Chips rápidos: `Todas`, `Em curso`, `Finalizadas`, `Canceladas`
- Filtros avançados: `dateRange`
- Ordenação: `createdAt desc` (default), `createdAt asc`
- Persistência: sessão apenas (sem persistência local na Fase 1)
- Query Firestore:
  - base: `orderBy(createdAt, asc|desc)`
  - opcional: `where(status in ... )`, `createdAt >= start`, `createdAt <= end`
- Índices necessários:
  - `trips(status, createdAt ASC|DESC)`

## Admin — Utilizadores (`admin_users_screen.dart`)
- Pesquisa local: `userId`, `name`, `email`, `phone`, `assignedVehicleId`, `vehicle.plate`, `vehicle.model`
- Chips rápidos:
  - modo admin: `Todas`, `Cliente`, `Motorista`, `Gestor`, `Administrador`
  - modo manager: `Todas`, `Disponível`, `Indisponível`
- Filtros avançados: `status (ativo/inativo)`, `driverAvailability`
- Ordenação: `name asc` (default), `name desc`, `createdAt desc`, `createdAt asc`
- Persistência: `SharedPreferences` (`scope=adminUsers`)
- Query Firestore:
  - mantém stream base atual de utilizadores (`users`) com merge de `driverStatus`
  - enriquece localmente com mapa `driverVehicleAssignments` + lookup local de `vehicles` (sem query adicional por item)
  - filtragem/pesquisa aplicada localmente no ecrã
- Índices necessários: sem novos índices nesta fase (filtragem local)
- UX operacional:
  - card com `nome + contacto + viatura` por defeito;
  - IDs completos apenas em `Detalhes técnicos` com copiar.

## Admin — Frota (`admin_fleet_screen.dart`)
- Pesquisa local: `vehicleId`, `plate`, `model`, `defaultTransportType.name`, dados do motorista atribuído
- Chips rápidos: `Todas`, `Ativas`, `Inativas`
- Filtros avançados: `assignment (com/sem atribuição)`, `transportType`
- Ordenação: `plate asc` (default), `plate desc`, `createdAt desc`, `createdAt asc`
- Persistência: `SharedPreferences` (`scope=adminFleet`)
- Query Firestore:
  - mantém stream base atual de viaturas (`vehicles`) + mapa de atribuições
  - filtragem/pesquisa aplicada localmente no ecrã
- Índices necessários: sem novos índices nesta fase

## Admin — Saldos (`admin_balances_screen.dart`)
- Pesquisa local: `clientId`, `name`, `email`, `phone`
- Chips rápidos: `Todas`, `Saldo negativo`, `No limite`
- Filtros avançados: `status do cliente (ativo/inativo)`
- Ordenação: `name asc` (default), `name desc`, `balance desc`, `balance asc`
- Persistência: `SharedPreferences` (`scope=adminBalances`)
- Query Firestore:
  - mantém stream combinado atual (`users role=client` + `balances`)
  - filtragem/pesquisa aplicada localmente no ecrã
- Índices necessários: sem novos índices nesta fase

## Cliente — Seleção de local (`place_selection_view.dart`)
- Pesquisa local: não aplicável (autocomplete continua remoto via Places)
- Chips rápidos: `Recentes`, `Favoritos` (favoritos persistidos localmente por cliente)
- Filtros avançados: não aplicável nesta fase
- Ordenação: ordem de recentes preservada da origem
- Persistência: sessão apenas (sem persistência local)
- Query Firestore:
  - lista local combinada de favoritos, destino falhado mais recente e destinos recentes concluídos
  - filtro `favoritos` aplicado localmente a partir de `SharedPreferences`
- Índices necessários: sem novos índices nesta fase

## Estados UX obrigatórios (todos os ecrãs)
- `loading`
- `erro` com ação de retry
- `vazio sem dados`
- `vazio com filtros ativos` (`Sem resultados`)
