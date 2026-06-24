# ADR 0016: Firestore strict read validation sem compatibilidade legada

- **Estado**: Aceite
- **Data**: 2026-02-17

## Contexto

Após vários incrementos, persistiam mecanismos de compatibilidade de schema em runtime:
- coerção de tipos legados (ex.: `String`/`num` para `bool`);
- parsing de timestamps a partir de `String`;
- fallback monetário para documentos inválidos em leitura.

Isto contrariava a documentação canónica em `docs/source_of_truth/*`, que já definia runtime sem compat mode.
Como a base de dados será reinicializada, não existe necessidade de manter tolerância a formatos antigos.

## Decisão

1. Tornar leitura de schema inválido explicitamente falhada no `FirestoreService` (lançar `FirestoreSchemaValidationException`).
2. Remover coercões legadas e parsing de timestamp por string dos mappers ativos.
3. Remover fallback monetário legado em `balances` e `driverStatus`.
4. Manter apenas fallbacks canónicos documentados (ex.: RBAC via `users/{uid}.role`, reminders `[15]`).
5. Remover aliases de configuração `_legacy*` em `EnvironmentConfig`.

## Consequências

### Positivas

- Contrato de dados único e auditável entre App e Functions.
- Falhas de dados passam a ser visíveis cedo, sem mascaramento.
- Menor complexidade de manutenção e menor risco de drift de schema.

### Trade-offs

- Documentos malformados deixam de ser tolerados e passam a interromper fluxo.
- Requer reset/seed consistente da base para operação sem erros de schema.
