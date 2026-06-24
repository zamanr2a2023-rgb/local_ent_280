# ADR 0014: Reminders configuráveis por offset em eventos administrativos

- **Estado**: Aceite
- **Data**: 2026-02-17

## Contexto

Os lembretes de eventos administrativos estavam hardcoded em duas janelas fixas (`30` e `15` minutos), com campos dedicados (`reminder30SentAt` e `reminder15SentAt`).
Este modelo não permitia ao admin ajustar reminders por evento e criava rigidez no dispatch.

## Decisão

1. Substituir lembretes fixos por `reminderOffsetsMinutes` (`number[]`) em `events/{eventId}`.
2. Persistir deduplicação de envio por offset em `reminderSentAtByOffsetMinutes` (`map<string, timestamp>`).
3. Normalizar offsets com regra canónica:
   - faixa de escrita `1..60`
   - máximo `5` offsets por evento
   - únicos e ordenados descendentemente
   - fallback `[15]` quando ausentes/inválidos
   - leitura runtime tolera dados legacy até `180` para evitar quebra operacional
4. Avaliar envio por bandas de offsets, enviando no máximo um reminder por execução para cada evento.

## Consequências

### Positivas

- Flexibilidade operacional para o admin configurar reminders por evento.
- Contrato extensível sem adicionar novos campos por cada janela.
- Deduplicação explícita por offset, mantendo idempotência do dispatch.

### Trade-offs

- Lógica de avaliação torna-se mais genérica e exige normalização consistente app/backend.
- Janela da query do job mantém tolerância legacy até `180` minutos para não perder lembretes antigos.

## Implementação inicial

- App admin passa a permitir adicionar/remover offsets de reminder no formulário de criação.
- Domínio e mapper Firestore incluem `reminderOffsetsMinutes`.
- Functions passam a usar `dueOffsetMinutes` + `reminderSentAtByOffsetMinutes.<offset>` no trigger e no job agendado.
