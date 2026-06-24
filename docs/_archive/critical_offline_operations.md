# DEPRECATED — do not use

Documento arquivado para histórico.
Fonte oficial atual: docs/README.md.

# Operações críticas e comportamento offline

Este documento define quais operações **podem** ser reexecutadas após reconexão e quais **exigem internet imediata**.

## Operações críticas (não entram em fila)

Quando não há ligação à internet, estas operações são bloqueadas e devolvem erro explícito de offline:

- Criar viagem (`requestTrip`)
- Transição de estado da viagem (`transitionTripState`)
- Cancelar viagem (`cancelTrip`)
- Pedir extensão da viagem (`requestTripExtension`)
- Responder à extensão da viagem (`respondTripExtension`)
- Propor sobretaxa (`handleTripFinancialAction` com `propose_surcharge`)
- Responder à sobretaxa (`handleTripFinancialAction` com `respond_surcharge`)
- Reprocessar pagamento (`handleTripFinancialAction` com `retry_payment`)
- Registar evento de viagem

Estas operações são transacionais e dependem de consistência imediata no servidor.

## Operações reexecutáveis após reconexão

As operações abaixo podem ser enfileiradas e executadas automaticamente quando a ligação voltar:

- Avaliação da viagem (`submitTripRating`)

## Comportamento na UI

- Ações críticas devem ser desativadas quando a aplicação está offline.
- O banner global de conectividade deve permanecer visível em estado “Sem ligação à internet”, servindo como feedback contínuo para o bloqueio das ações.
- Se o utilizador tentar abrir um fluxo crítico enquanto offline, a UI mostra feedback imediato.
