# ADR 0021: Targeting multi-motorista para eventos administrativos

- **Estado**: Aceite
- **Data**: 2026-03-04

## Contexto

O fluxo de eventos administrativos suportava apenas dois destinos:

1. `broadcast` (todos os motoristas)
2. `driver` com um único `targetId`

Esta limitação impedia operações intermédias (ex.: alertar 3, 10 ou 50 motoristas específicos) e forçava escolhas binárias no backoffice.

## Decisão

1. Substituir `targetId` por `targetIds` (`string[]`) no contrato de `events/{eventId}`.
2. Manter apenas dois modos no produto:
   - `broadcast`
   - `driver` com lista explícita de destinatários.
3. Remover compatibilidade runtime com `targetId` (sem fallback legado).
4. Limitar seleção direcionada a `200` motoristas por evento.
5. Garantir leitura segura para motorista com duas queries separadas:
   - `targetType == "broadcast"`
   - `targetType == "driver" && targetIds arrayContains <driverId>`
6. Atualizar dispatch backend para enviar reminders a todos os IDs em `targetIds`.
7. Fazer chunk de envio FCM em lotes de até `500` tokens por chamada.

## Consequências

### Positivas

- Fluxo administrativo mais flexível sem aumentar complexidade de papéis/segmentos.
- Contrato explícito e determinístico para destinatários.
- Menor risco de erro de segurança por query inválida (`rules are not filters`).
- Dispatch backend resiliente para listas grandes de tokens.

### Trade-offs

- Mudança não compatível com documentos antigos que tenham apenas `targetId`.
- Esquema e índices Firestore precisam de atualização coordenada.
- UI requer picker com pesquisa e gestão de limite.

## Implementação inicial

- App:
  - contrato de domínio/dados migrado para `targetIds`;
  - selector admin multi-motorista com pesquisa/checklist e limite `200`;
  - validação estrita de schema/consistência para `events`.
- Backend:
  - trigger e job de reminders usam `targetIds`;
  - alertas de sistema para um motorista passam a gravar `targetIds: [driverId]`;
  - envio multicast com chunking de tokens.
- Plataforma:
  - regras de leitura de `events` passam a validar membership por `targetIds`;
  - índice composto para query com `arrayContains(targetIds)`.
