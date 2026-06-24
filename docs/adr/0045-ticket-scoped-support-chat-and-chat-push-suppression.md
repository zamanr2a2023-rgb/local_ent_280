# ADR 0045: Ticket-scoped support chat and chat push suppression

## Status
Accepted

## Context
Trip chat was being used for two different jobs: client-motorist coordination and operational support visibility. Support tickets also existed separately, which forced admins to follow support context across ticket and chat sections.

## Decision
- Keep client-motorist chat as `trip_client_driver` with thread id `trip_{tripId}`.
- Move support conversations to ticket-scoped `support_client_ops` threads with id `support_request_{requestId}`.
- Active-trip support creates or reuses one open `supportRequests` document for the same client and trip.
- Remove the standalone operational chat inbox. Support is handled in `Tickets de suporte`; trip chat is read-only from trip detail.
- Chat push payloads include `threadId` and, when available, `tripId` and `requestId`.
- Newly created support tickets emit `ops.support_ticket` once; later messages in
  the same ticket use chat-message notifications.
- Foreground notification UI is suppressed only when the currently visible chat thread matches the incoming `threadId`.

## Consequences
- Operators get one support workflow centered on tickets.
- Client-driver chat remains available for time-sensitive coordination.
- Old `support_client_{clientId}` threads are historical and are not migrated.
