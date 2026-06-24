# Source of Truth: Notifications

## Objetivo do domínio
- Entregar notificações relevantes de viagem, package e operações sem depender de polling manual.
- Garantir que push é um efeito secundário observável, nunca a fonte de verdade do workflow.
- Garantir que notificações de package são emitidas apenas depois de o estado canónico ter sido persistido.

## Eventos ativos
- Viagem para motorista:
  - `driver.new_trip_assigned`
  - `driver.client_extension_requested`
  - `driver.trip_chat_message`
- Viagem para cliente:
  - `client.driver_assigned`
  - `client.driver_arrived`
  - `client.trip_unfulfilled`
  - `client.trip_completed_charged`
  - `client.trip_chat_message`
- Packages para cliente:
  - `client.package_booking_pending_approval`
  - `client.package_booking_approved`
  - `client.package_booking_cancelled`
  - `client.package_booking_refunded_pre_execution_failure`
  - `client.package_operational_update`
- Packages para motorista:
  - `driver.package_booking_acceptance_requested`
  - `driver.package_booking_assigned`
- Packages para operações:
  - `ops.package_booking_pending_approval`
  - `ops.package_booking_approved`
  - `ops.package_booking_rejected`
  - `ops.package_booking_awaiting_driver_acceptance`
  - `ops.package_booking_driver_assigned`
  - `ops.package_booking_driver_accepted`
  - `ops.package_booking_driver_acceptance_failed`
  - `ops.package_booking_activation_started`
  - `ops.package_booking_activation_failed`
  - `ops.package_booking_cancelled`
  - `ops.package_booking_refunded_pre_execution_failure`
  - `ops.package_booking_completed`
- Reserva one-off:
  - `client.reservation_failed`
- Operações genéricas:
  - `ops.trip_unfulfilled`
  - `ops.password_help_request`
  - `ops.support_ticket`
  - `ops.chat_message`

## Workflow canónico
1. A app inicializa FCM e regista/atualiza tokens em `users/{uid}/fcmTokens/{token}`.
   O backend sincroniza esse contrato legado para `notificationTargets/{uid}` e `notificationTargets/{uid}/tokens/{tokenHash}` para fanout barato por papel/permissão.
2. O backend dispara notificações apenas depois de a transição de negócio ter sido confirmada em Firestore.
3. Falha de envio nunca reverte compra, cancelamento, refund, aprovação nem conclusão.
4. Jobs e handlers mantêm idempotência para evitar duplicados em retries.
5. Tokens inválidos/stale são limpos por rotina agendada.
6. Quando o utilizador abre a app a partir de uma push, a navegação usa o contrato `type` do payload; para `driver.new_trip_assigned`, o motorista é levado ao dashboard do motorista, onde o pedido atribuído fica visível para aceitar/recusar.
7. `ops.support_ticket` é emitida uma vez por ticket recém-criado e deve incluir `requestId`; quando existir conversa ligada, inclui também `threadId`; quando vier de suporte em viagem ativa, inclui `tripId`.
8. `ops.support_ticket` abre o chat do ticket quando `requestId` existe; sem `requestId`, abre a lista de tickets de suporte.

## Packages governados
- Checkout:
  - cliente recebe `client.package_booking_pending_approval`;
  - operações recebem `ops.package_booking_pending_approval`.
- Aprovação:
  - cliente recebe `client.package_booking_approved`;
  - operações recebem `ops.package_booking_approved`;
  - se a janela operacional já estiver aberta, operações recebem também `ops.package_booking_awaiting_driver_acceptance`.
- Rejeição:
  - operações recebem `ops.package_booking_rejected`;
  - cliente vê o outcome através do booking persistido e das notificações de cancelamento/refund quando aplicáveis.
- Atribuição:
  - motorista recebe `driver.package_booking_assigned`;
  - operações recebem `ops.package_booking_driver_assigned`.
- Aceitação/avanço operacional:
  - motorista recebe `driver.package_booking_acceptance_requested` quando a ativação exige ação;
  - operações recebem `ops.package_booking_driver_accepted` quando a viagem transita para aceitação do motorista.
- Falhas operacionais:
  - operações recebem `ops.package_booking_driver_acceptance_failed` para ausência/timeout/recusa no path de driver;
  - operações recebem `ops.package_booking_activation_failed` para falhas de ativação;
  - cliente e operações recebem os eventos de refund/cancelamento aplicáveis.
- Conclusão:
  - operações recebem `ops.package_booking_completed`.

## Regras de entrega
- Tokens ativos usam o contrato canónico `enabled == true`.
- Fanout privilegiado tenta primeiro `notificationTargets`; `users/{uid}/fcmTokens` fica como fallback temporário de migração/reparação.
- Dispatch multicast e fanout são backend-only.
- Para packages, o público de operações é:
  - todos os `admin`
  - todos os `manager` com permissão `tp`
- Cada utilizador só manipula os próprios tokens.

## Fora de escopo
- Marketing/campanhas.
- Preferências avançadas de canal por tipo de notificação.
- Reminders próprios do modelo antigo de departures.
- Push dedicado para meeting point, porque esse conceito não existe no produto ativo.

## Referências de implementação
- `lib/core/data/firebase/firebase_messaging_initializer.dart`
- `lib/features/notifications/domain/entities/notification_event_type.dart`
- `lib/features/notifications/data/mappers/notification_event_mapper.dart`
- `lib/features/notifications/presentation/widgets/notification_banner_listener.dart`
- `lib/features/notifications/data/repositories/notification_token_repository_impl.dart`
- `functions/src/trip_packages/buildTripPackageFunctions.ts`
- `functions/src/notifications/buildNotificationsFunctions.ts`
