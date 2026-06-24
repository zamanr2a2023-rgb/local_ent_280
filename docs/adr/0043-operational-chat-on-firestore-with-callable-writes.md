# ADR 0043: Chat Operacional em Firestore com Writes por Callable

## Contexto
- O produto precisava de um canal simples de comunicação:
  - cliente <-> operações a qualquer momento;
  - cliente <-> condutor apenas durante a viagem ativa.
- O stack atual já usa Firebase Auth, Firestore, Functions e FCM.
- O MVP continua a privilegiar workflow linear e previsível, sem introduzir um sistema de tickets/casos.

## Decisão
1. Criar um domínio `chat` com dois tipos de thread:
   - `support_client_ops`
   - `trip_client_driver`
2. Persistir:
   - summary em `chatThreads/{threadId}`;
   - mensagens em `chatThreads/{threadId}/chatMessages/{messageId}`.
3. Usar ids determinísticos para threads:
   - `support_client_{clientId}`
   - `trip_{tripId}`
4. Usar auto IDs aleatórios para mensagens.
5. Permitir leituras diretas por Firestore SDK e listeners apenas nos ecrãs abertos.
6. Bloquear escritas diretas da app em Firestore e forçar mutações via callables:
   - `sendSupportChatMessage`
   - `sendTripChatMessage`
7. Exigir idempotência por `clientMessageId` em todos os envios.
8. Fechar `trip_client_driver` no backend quando a viagem entra num estado terminal.
9. Manter inbox operacional baseada apenas em `chatThreads`, ordenada por `lastMessageAt`.
10. Introduzir permissão de manager `manageClientChats ('ch')`, dependente de `viewClients ('vc')`.

## Consequências
- O modelo fica simples e coerente com Firestore:
  - summary leve para inbox;
  - subcoleção para mensagens;
  - custo de leitura controlado.
- A política `writes por callable` centraliza:
  - validação de papel;
  - idempotência;
  - atualização atómica do summary;
  - push best-effort.
- A thread da viagem respeita o contrato atual de imutabilidade pós-finalização.
- Operações ganham visibilidade transversal sem abrir já um sistema de atendimento complexo.

## Tradeoffs aceites
- Sem pesquisa global por mensagens na v1.
- Sem unread badges, read receipts, anexos ou atribuição de operador.
- `trip_client_driver` fica legível para operações, mas sem resposta operacional na v1.
- `lastMessageAt` mantém timestamp sequencial sem sharding nesta fase.

## Estado
- Aprovado.
