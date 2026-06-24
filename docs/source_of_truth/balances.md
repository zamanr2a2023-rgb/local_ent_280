# Source of Truth: Balances

## Objetivo do domínio
- Controlar saldo e limite de dívida do cliente com regra financeira única.
- Garantir que o backend é autoridade final em elegibilidade e cobrança.

## Contrato monetário
- `balances/{clientId}`:
  - `balance: Money`
  - `debtLimit: Money`
- `balance_adjustments/{id}`:
  - `delta: Money`
  - `clientId: string`
  - `createdAt: timestamp`
  - `reason: string?`
  - `adminId: string?`
  - `tripId: string?`
  - `cycleIndex: int?`
- Contrato obrigatório: `{ amountMinor, currency }`.
- `currency` é obrigatória e operações exigem same-currency.
- Sem compat mode em runtime ativo.
- Leitura inválida de schema é erro explícito (não há normalização nem fallback de runtime).
- `createdAt` e `updatedAt` são obrigatórios e devem ser `timestamp`.

## Ledger e extrato do cliente
- `balance_adjustments` é o ledger base canónico do extrato do cliente.
- Packages pré-pagos usam o mesmo ledger:
  - débito imediato na confirmação do booking;
  - reembolso total antes da execução quando houver cancelamento elegível ou falha operacional pré-execução.
- IDs determinísticos de ledger para packages:
  - `trip_package_booking_${bookingId}_charge`
  - `trip_package_booking_${bookingId}_refund_full`
- Quando o movimento estiver ligado a uma viagem:
  - `tripId` liga o movimento ao contexto operacional e financeiro da viagem;
  - `cycleIndex` identifica a cobrança de um ciclo específico de extensão pós-cobrança quando existir.
- Tipos de movimento do extrato são derivados de `reason` + presença de `tripId` + `cycleIndex`.
- O extrato administrativo do cliente é reconciliação de período, não snapshot arbitrário da UI.
- O workspace `Extrato do Cliente` suporta dois âmbitos reproduzíveis:
  - consolidado de `todos os clientes`;
  - cliente exato selecionado como filtro adicional;
- O âmbito ativo altera KPIs, tabela e exportação de forma consistente.
- A tabela e a exportação expõem `runningBalanceAfter` como coluna derivada; este valor não é persistido em Firestore.
- A exportação do extrato usa o dataset filtrado completo até `5000` movimentos e nunca depende apenas das linhas atualmente visíveis.
- O enriquecimento relacional do extrato usa snapshot leve da viagem ligada (`driver`, `viatura`, moradas e `receipt.totalMinor`) para evitar acoplamento ao agregado `Trip` completo.
- Fórmula canónica de reconciliação:
  - `openingBalance`: saldo imediatamente antes do primeiro movimento do período;
  - `creditsTotal`: soma de `delta > 0`;
  - `debitsTotal`: soma absoluta de `delta < 0`;
  - `closingBalance = openingBalance + creditsTotal - debitsTotal`;
  - `debtAtPeriodEnd = max(0, -closingBalance.amountMinor)`.

## Regra de limite
- Regra canónica: `balanceAfterMinor >= -creditLimitMinor`.
- `creditLimitMinor = abs(debtLimit.amountMinor)`.
- Boundary default do sistema: `debtLimit.amountMinor = -2000` (`-20,00 EUR`) quando não existir override administrativo do cliente.
- Violação gera `failed-precondition` com `details`:
  - `reason: "LIMIT_EXCEEDED"`
  - `operation`
  - `currency`
  - `balanceBeforeMinor`
  - `debitAmountMinor`
  - `balanceAfterMinor`
  - `creditLimitMinor`

## Autoridade backend
- Cliente pode fazer apenas pre-check informativo.
- Cliente não bloqueia decisão de negócio de saldo/limite.
- A decisão final vem sempre dos callables/backend.
- `confirmTripPackageBooking` usa exatamente a mesma regra canónica de limite e não introduz bypass específico para packages.
- Se `balances/{clientId}` não existir ou estiver inválido, a compra do package falha.
- O refund canónico pré-execução de package é atómico:
  - booking `cancelled`
  - `refundStatus = full`
  - `refundedAmount = chargedAmount`
- Backend e app assumem dados válidos após reset/seed; documentos inválidos são rejeitados.

## Referências de implementação
- `lib/features/client/domain/entities/balance.dart`
- `lib/features/client/domain/usecases/validate_trip_eligibility.dart`
- `lib/features/client/presentation/providers/trip_request_provider.dart`
- `functions/src/trips/buildTripsFunctions.ts`
- `docs/adr/0003-money-contract-and-minor-units.md`
- `docs/adr/0016-firestore-strict-read-validation.md`
