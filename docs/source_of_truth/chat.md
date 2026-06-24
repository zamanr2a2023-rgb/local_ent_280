# Source of Truth: Chat

## Objetivo do domínio
- Manter duas conversas distintas durante uma viagem ativa:
  - chat cliente-motorista para coordenação operacional imediata;
  - chat cliente-suporte ligado a um ticket finito em `supportRequests`.
- Centralizar atendimento de suporte no módulo `Tickets de suporte`.

## Tipos canónicos de thread
- `trip_client_driver`
  - uma thread por viagem: `trip_{tripId}`;
  - escrita por cliente e motorista atribuídos durante os estados ativos permitidos;
  - leitura por `admin` e `manager` com permissão `ch` a partir do detalhe da viagem.
- `support_client_ops`
  - uma thread por ticket: `support_request_{requestId}`;
  - escrita por cliente dono do ticket, `admin` e `manager` com permissão `vs`;
  - tickets de viagem ativa usam `sourceType=active_trip` e guardam contexto da viagem.

## Modelo de dados canónico
- `supportRequests/{requestId}`
  - `sourceType`: `general`, `active_trip` ou `forgot_password`;
  - `chatThreadId`: `support_request_{requestId}`;
  - `tripId?`;
  - `tripSnapshot?` com moradas, estado, transporte, motorista e viatura disponíveis no momento da abertura;
  - `status`, `requestedAt`, `requestedBy`, `updatedAt`, `resolvedAt?`, `resolvedBy?`.
- `chatThreads/{threadId}`
  - `type`, `status`, `clientId`, `tripId?`, `driverId?`, `supportRequestId?`;
  - `createdAt`, `updatedAt`, `lastMessageAt`, `lastMessageText`;
  - `lastSenderUserId`, `lastSenderRole`, `needsOpsAttention`.
- `chatThreads/{threadId}/chatMessages/{messageId}`
  - `threadId`, `senderUserId`, `senderRole`, `senderDisplayName`, `body`, `createdAt`, `clientMessageId`.

## Lifecycle canónico
- Chat cliente-motorista:
  - abre lazy no primeiro envio elegível;
  - fecha no primeiro estado terminal da viagem;
  - não cria ticket de suporte.
- Chat de suporte em viagem ativa:
  - primeira mensagem do cliente cria ou reutiliza um ticket aberto para o mesmo `clientId + tripId`;
  - mensagens seguintes usam o mesmo `chatThreadId` até o ticket ser resolvido;
  - ticket resolvido pode ser reaberto por nova mensagem no mesmo ticket.
- Tickets gerais:
  - são criados por `requestSupportTicket`;
  - respostas acontecem no chat `support_request_{requestId}`.

## Regras de leitura, escrita e notificações
- Escrita de mensagens apenas por callable:
  - `sendTripChatMessage`;
  - `sendSupportTicketMessage`.
- Idempotência por `clientMessageId`.
- Push inclui sempre `type` e `threadId`; inclui `tripId` e/ou `requestId` quando aplicável.
- A app suprime banner/local notification apenas quando a thread aberta tem o mesmo `threadId`; outras conversas continuam a notificar.

## Fora de escopo
- Anexos, áudio, editar/apagar mensagens, reações, read receipts, pesquisa global e atribuição individual de operador.
- Migração de threads antigas `support_client_{clientId}`.
