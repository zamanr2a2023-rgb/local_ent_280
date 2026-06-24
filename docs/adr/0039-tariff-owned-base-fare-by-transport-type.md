# ADR 0039: Tariff-Owned Base Fare by Transport Type

## Status
Accepted

## Context
- O modelo anterior usava `Tariff.base` global e `transport_types/{id}.multiplier`.
- Esse multiplicador de transporte afetava a tarifa inteira, o que tornava o pricing menos explícito, menos auditável e mais difícil de editar no backoffice.
- O produto pretende simplificar o modelo ativo para um MVP com pricing previsível, explicável e facilmente configurável por admin/manager.

## Decision
- Remover o multiplicador do catálogo de tipos de transporte.
- Substituir `Tariff.base` por `Tariff.baseByTransportType`.
- O tipo de transporte passa a escolher apenas a tarifa base da viagem.
- Os únicos multiplicadores dinâmicos ativos passam a ser:
  - `time_range`
  - `holiday`
- `admin_default` mantém-se como única fonte editável de tarifário e `public_default` continua a ser uma projeção espelhada por backend.
- Writes privilegiados de tarifário passam por callable autenticado; Firestore Rules bloqueiam writes diretos em `tariffs/*`.
- `TripPricingSnapshot` sobe para schema `3` e passa a persistir:
  - `resolvedBaseTransportTypeId`
  - `resolvedBaseSource = "tariff.baseByTransportType"`

## Consequences
- Esta alteração é uma mudança deliberada de política de pricing, não uma migração que preserve a economia antiga da tarifa inteira.
- Tipos de transporte tornam-se catálogo puro (`id`, `name`, `description`) e deixam de ser fonte de cálculo monetário global.
- A ausência de `baseByTransportType[selectedTransportTypeId]` passa a ser erro explícito; não existe fallback monetário em runtime ativo.
- Reporting histórico deve ler sempre do `TripPricingSnapshot` persistido; snapshots v2 continuam legíveis, mas não são reinterpretados a partir do tarifário atual.
