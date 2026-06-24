# ADR 0042: Trip Packages Governados com Aprovação, Fila Ops Dedicada e Ativação Separada

## Contexto
- O produto ativo de packages já não usa `tripPackageDepartures`, lotação nem legs.
- A decisão anterior de separar booking comercial de reservation/trip operacional mantém-se correta.
- O novo requisito acrescenta governação explícita:
  - compra cobra imediatamente;
  - operação não pode arrancar sem aprovação explícita de `admin` ou `manager(tp)`;
  - admin/manager precisam de visibilidade sobre todas as fases críticas do workflow.

## Decisão
1. Manter a governação do package fora do `TripState` partilhado.
2. Formalizar `tripPackageBookings` como lifecycle próprio:
   - `pendingApproval`
   - `approved`
   - `awaitingDriverAcceptance`
   - `driverAssigned`
   - `activationInProgress`
   - `cancelled`
   - `rejected`
   - `completed`
3. Tratar `approved` como estado durável:
   - existe quando a equipa já aprovou, mas a janela operacional ainda não abriu.
4. Cobrar o cliente no checkout e criar logo o booking + reservation, mas com booking em `pendingApproval`.
5. Reutilizar o path transacional existente de cancelamento/refund para rejeição e falhas pré-execução.
6. Persistir auditoria explícita de decisão em `approval.*`.
7. Persistir campos orientados à fila operacional em `tripPackageBookings`:
   - `opsQueueBucket`
   - `opsNextActionAt`
   - `opsIsActionable`
   - `opsLastIssueCode`
8. Introduzir uma fila operacional dedicada de packages no backoffice em vez de tratar `/ops/reservations` como surface final.
9. Emitir notificações de package apenas depois da transição commitada.
10. Alinhar backend, Flutter e documentação para o novo contrato de eventos de package.

## Consequências
- A governação comercial fica isolada no domínio certo, sem contaminar a state machine core de viagens.
- O checkout fica simples para o cliente, mas seguro para a operação.
- A observabilidade operacional melhora:
  - aprovação pendente
  - próxima ação
  - incidentes precisos
  - audit trail da decisão
- Refunds continuam com semântica financeira separada do lifecycle principal.
- A fila dedicada de package ops evita sobrecarregar `reservations` com semântica comercial específica.

## Estado
- Este ADR substitui a semântica anterior de `booking confirmed -> assignment window` como modelo canónico de packages.
