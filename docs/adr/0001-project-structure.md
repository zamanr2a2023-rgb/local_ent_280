# ADR 0001: Estrutura do Projeto

- Data: 2026-02-16
- Estado: aceite

## Contexto
- O repositório tinha documentação e organização parcialmente divergentes.
- A manutenção ficou mais difícil por falta de fronteiras explícitas entre UI, domínio e integrações.

## Decisão
- Adotar estrutura **feature-first** com camadas explícitas por feature:
  - `lib/features/<feature>/presentation`
  - `lib/features/<feature>/application`
  - `lib/features/<feature>/domain`
  - `lib/features/<feature>/data`
- Manter `lib/core` para capacidades transversais (serviços base, value objects, abstrações partilhadas).
- Manter `lib/app` para bootstrap, shell, navegação e composição global.
- Providers de DI deixam de viver em `domain/providers` e passam para `application/providers`.

## Consequências
- Responsabilidades ficam mais previsíveis e auditáveis.
- Reduz-se acoplamento acidental do domínio a frameworks de UI/DI.
- Mudanças futuras podem ser feitas por feature sem espalhar alterações por todo o projeto.
