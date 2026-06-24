# ADR 0036: Package Bookings sobre o Core Partilhado de Reservations

> SUPERSEDED by `docs/adr/0040-shared-departure-trip-packages.md`

## Contexto
- O produto precisava de vender pacotes pré-pagos com preço fixo, destino fixo e possibilidade de ida ou ida e volta.
- O agregado `Trip` já tinha um state machine operacional fechado para pedido imediato e ativação de reservas.
- Criar um segundo motor de scheduling/dispatch para packages duplicaria regras críticas:
  - disponibilidade de motorista;
  - disponibilidade de viatura;
  - overlap temporal;
  - ativação de reserva para trip;
  - idempotência operacional.
- O fluxo também exigia cobrança imediata e segurança contra replays/retries em Functions e Tasks.

## Decisão
1. Introduzir um agregado comercial dedicado:
   - `tripPackages/{packageId}` para catálogo;
   - `tripPackageBookings/{bookingId}` para a compra confirmada.
2. Modelar cada leg do package como reserva operacional real no core existente:
   - `reservations/pkg_${bookingId}_${legType}`;
   - mesma matriz de overlap e mesmas invariantes de `reservations`.
3. Usar `tripPackageBookings/{bookingId}/legs/{legId}` apenas como espelho do booking:
   - útil para detalhe comercial/UI;
   - não substitui a reserva autoritativa.
4. Ativar cada leg por Cloud Tasks agendada:
   - uma task por leg;
   - idempotência por ids determinísticos;
   - sem poller minutely dedicado para packages.
5. Gerar `Trip` canónico determinístico por leg:
   - `trips/pkg_${bookingId}_${legType}`
   - metadata comercial mínima no `Trip`
   - o resto da verdade comercial permanece no booking.
6. Cobrar o package na confirmação:
   - débito imediato em `balances`;
   - ledger determinístico em `balance_adjustments`;
   - `finalizeTripPayment` ignora novo débito quando `fareCoverage = included`.

## Consequências
- O produto ganha packages sem transformar `Trip` num mega-modelo de agendamento futuro.
- A disponibilidade operacional continua centralizada num único core (`reservations`).
- A superfície crítica fica mais robusta a replays e retries:
  - booking;
  - refunds;
  - tasks;
  - criação de trip.
- O detalhe financeiro e de produto fica isolado do detalhe operacional.
- A complexidade operacional aumenta de forma controlada:
  - mais uma coleção de domínio (`tripPackageBookings`);
  - espelho de legs;
  - tasks agendadas por leg;
  - sincronização booking/leg baseada no estado final do `Trip`.
- `opsException` passa a ser um estado explícito do booking quando a ativação ou a operação do leg falha fora dos caminhos normais.
