# ADR 0002: Boundaries de State Management e DI

- Data: 2026-02-16
- Estado: aceite

## Contexto
- Existia mistura de responsabilidades entre camadas e providers definidos na camada de domínio.
- Precisávamos de uma direção de dependências clara para reforçar Clean Architecture.

## Decisão
- Padronizar state management e DI com Riverpod.
- Definir fronteiras:
  - `presentation`: widgets, controllers de ecrã e leitura de estado; sem regras de negócio.
  - `application`: providers de composição, wiring de use cases, orquestração de fluxo.
  - `domain`: entidades, use cases e interfaces; sem Flutter/Firebase/Riverpod.
  - `data`: implementações de repositório, mappers e integrações Firebase/APIs.
- Direção obrigatória de dependências:
  - `presentation -> application -> domain`
  - `data -> domain`
  - `domain` não depende de outras camadas.

## Consequências
- Regras de negócio ficam centralizadas e reutilizáveis.
- UI fica mais fina e previsível.
- Substituição de backend/integradores torna-se mais segura, porque o domínio depende de interfaces.
