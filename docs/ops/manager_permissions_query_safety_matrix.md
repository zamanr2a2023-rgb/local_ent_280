# Manager Permissions Query Safety Matrix

## Objetivo
- Garantir que queries de manager nunca pedem documentos que as rules possam negar.
- Regra operacional: “rules are not filters”; evitar queries mistas/broad em contexto manager.

## Matriz por módulo

| Módulo | Permissão | Query segura | Observações |
| --- | --- | --- | --- |
| Manager Trips | `vt` | `trips` no provider operacional já filtrado por intervalo/estado | Sem `vt`, rota bloqueada e query não executa |
| Manager Drivers (Users Screen restrito) | `vd` e opcional `vc` | `vc=false`: `users where role == driver` | Nunca usar `role in [...]` |
| Manager Drivers (Users Screen restrito com clientes) | `vd` + `vc` | Duas queries: `role == driver` e `role == client`; merge local | Merge determinístico por `id`, ordenado por nome |
| Manager Reports | `vr` | Queries de relatórios existentes + guard de rota | Sem `vr`, rota bloqueada |
| Manager Audit | `va` | `audit` com filtros já existentes | Sem `va`, rota bloqueada |
| Manager Events | `me` | `events` com rules por `managerCanMe` | `me` depende de `vd` no backend |
| Support Requests | `vs` | `supportRequests` ordenado por `requestedAt` | Ação resolver exige `rp` adicional |

## Validação de bootstrap
- Manager sem `mp` configurado:
  - ecrã home mostra estado bloqueado;
  - permite apenas `Atualizar permissões` e `Terminar sessão`;
  - não há execução de queries operacionais.

## Refresh operacional
- Manual: `getIdToken(true)` imediato.
- Foreground: debounce 10 minutos.
- Mudança de hash de permissões invalida providers:
  - `managerOperationalTripsProvider`
  - `managerVisibleUsersProvider`
  - `reportsResultsProvider`
  - `adminAuditEntriesProvider`
  - `supportRequestsStreamProvider`
