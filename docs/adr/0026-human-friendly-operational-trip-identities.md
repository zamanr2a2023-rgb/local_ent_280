# ADR 0026: Human-Friendly Identities in Operational Trip UI

## Status
Accepted

## Context
- Ecrãs operacionais de viagem exibiam identificadores técnicos (`tripId`, `driverId`, `vehicleId`) em contexto primário.
- Isso aumentava carga cognitiva para operações de cliente, motorista, manager e admin.
- A app precisa manter suporte técnico sem expor IDs completos por defeito.

## Decision
- Aplicar padrão único de identidade human-friendly em ecrãs operacionais:
  - pessoa: `displayName/name` -> `email` -> `phone` -> `Referência ABCD...WXYZ`;
  - viatura: `plate` -> `model/tipo` -> `Referência ABCD...WXYZ`.
- IDs completos ficam apenas em secção colapsável `Detalhes técnicos` com ação de copiar.
- Estratégia de dados desta entrega é `snapshot-only`:
  - sem novos lookups de `users/vehicles`;
  - sem mudanças de rules/permissões.

## Consequences
- UX operacional melhora em leitura rápida e contexto.
- Menor risco de falhas por permissões em flows de manager/admin.
- Quando snapshots estiverem incompletos, UI mantém robustez via referência curta.
- Não há alteração de regras de negócio nem de contratos financeiros.

## Related
- `docs/source_of_truth/trips.md`
- `docs/source_of_truth/admin.md`
- `docs/ops/operational_trip_ui_identity_matrix.md`
