# ADR 0040: Trip Packages por Saída Partilhada Materializada

## Contexto
- O produto deixou de vender packages como legs `outbound/return` encaixados no core de `reservations`.
- O novo requisito é vender lugares em saídas partilhadas com:
  - horário fixo;
  - lugares limitados;
  - threshold mínimo de participantes;
  - reminder configurável;
  - cancelamento automático quando não houver adesão suficiente;
  - cancelamento manual pelo backoffice com refund total.
- O modelo anterior aumentava acoplamento operacional:
  - cada venda tinha de reservar motorista e viatura no momento da compra;
  - o detalhe comercial dependia de legs, tasks e `Trip`;
  - o produto ficava preso a uma semântica de ida/volta que já não existe no requisito ativo.

## Decisão
1. Adotar o modelo canónico:
   - `tripPackages/{packageId}` para templates;
   - `tripPackageDepartures/{departureId}` para ocorrências concretas;
   - `tripPackageBookings/{bookingId}` para reservas por lugares.
2. Tornar `timeZone` obrigatório no template e materializar timestamps UTC por saída:
   - `startsAt`
   - `endsAt`
   - `bookingClosesAt`
   - `minimumConfirmedSeatsDeadlineAt`
   - `reminderAt`
3. Tratar disponibilidade como derivada, não persistida:
   - `open`
   - `soldOut`
   - `closed`
4. Manter writes críticos backend-only:
   - booking confirmado por callable com transação server-side;
   - cancelamento manual;
   - publicação de ponto de encontro;
   - avaliação mínima;
   - reminders;
   - conclusão automática.
5. Introduzir agregado explícito de idempotência:
   - `tripPackageBookingOperations/{operationId}`
   - chave por `clientId + sha256(idempotencyKey)`
6. Congelar snapshots de template e saída no booking.
7. Proibir mutações estruturais em saídas já reservadas:
   - preço;
   - lugares;
   - horário;
   - timezone;
   - cutoff;
   - reminder;
   - texto descritivo.
8. Remover `tripPackages` do core ativo de `reservations` e do contrato ativo de `trips`.

## Consequências
- O produto de packages passa a ser comercialmente autónomo e muito mais próximo do requisito de negócio real.
- O booking concorrente de lugares fica protegido por transação server-side e idempotência explícita.
- Jobs agendados tornam-se timestamp-driven e seguros face a overlap/retry.
- O catálogo administrativo ganha uma superfície mais clara:
  - template;
  - saídas materializadas;
  - ocupação;
  - ponto de encontro;
  - cancelamento.
- `reservations` e `trips` deixam de carregar complexidade de package que não pertence ao produto ativo.
- A integração operacional futura continua possível por seam explícito (`serviceRunId`) sem contaminar já o contrato de packages.

## Estado
- Substituído pelo ADR 0042 para o produto ativo.
