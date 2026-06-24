# As-Is: Fontes de Dados e Integrações

## Resumo de fontes

### Firebase Auth
- Sessão, identidade e claims de papel.
- Consumo no app através de abstrações em `core/data/firebase`.

### Cloud Firestore
- Fonte primária de dados transacionais e administrativos.
- Coleções principais: `users`, `trips`, `reservations`, `balances`, `tariffs`, `pricingSchedules`, `specialDays`, `events`, `audit`, `driverStatus`, `driverVehicleAssignments`, `vehicles`, `transport_types`, `tripEvents`.

### Realtime Database
- Tracking/presença de motorista em tempo real.
- Nós principais: `driverLocations`, `driverPresence`.

### Cloud Functions
- Orquestração de fluxos críticos (trip request, transições, cancelamentos, cobrança, scheduler).
- Envio de notificações e rotinas operacionais.

### Firebase Messaging
- Gestão de tokens por utilizador.
- Entrega de notificações push por backend.

### Firebase Storage
- Upload de media (ex.: fotos utilizador/viatura) em fluxos administrativos.

### APIs externas
- Google Maps/Places/Directions (visualização, pesquisa de locais, rotas).

## Responsabilidade por camada (estado real)

### Presentation
- Ecrãs/widgets/providers Riverpod para renderização e coordenação de estado UI.

### Application
- Providers de wiring e composição de dependências por feature (`application/providers`).

### Domain
- Entidades, use cases e interfaces de repositório.
- Sem dependência direta de Flutter/Firebase.

### Data
- Repositórios concretos, mappers e acesso Firebase/APIs.

## Smells de data ownership identificados
- Contrato monetário ativo convergido para `Money` (`{ amountMinor, currency }`).
- Campos legados `*Cents` removidos dos paths ativos (`lib/`, `functions/src/`, `contracts/`).
- Validadores ativos de pricing/balances/trips/reporting sem compatibilidade legacy em runtime.
- Leitura de schema inválido em Firestore é invalidante e gera erro explícito.
- Parsing de timestamp por string foi removido dos mappers ativos.
