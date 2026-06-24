# ADR 0041: Hybrid Test Matrix With Emulator E2E

## Estado
Aceite

## Contexto
- O repositório já tinha testes unitários/widget em Flutter, testes unitários/wrapped em `functions`, e uma lane parcial de rules para Firestore/RTDB.
- A designação informal de "end-to-end" estava a misturar cenários mockados com cenários que realmente exercem Firebase.
- O produto depende de Auth, Firestore, Realtime Database, Functions, Storage, App Check e apresentação local de notificações, mas FCM não tem emulador na Local Emulator Suite.
- A app inicializava Firebase/App Check/messaging diretamente em `main()`, o que impedia uma seam estável para testes app-level.

## Decisão
- Adotar uma matriz de testes em quatro lanes:
  - `flutter test` para unit/domain/provider/widget offline.
  - `integration_test/mocked` para fluxos UI com Riverpod overrides e fakes.
  - `integration_test/emulator` para fluxos Flutter contra Auth, Firestore, RTDB, Functions e Storage em emuladores Firebase.
  - smoke suite `dev` muito pequena, executada apenas on-demand/release candidate.
- Tratar apenas a lane com Firebase emulador como "realistic end-to-end". Fluxos com overrides continuam explicitamente "mocked app integration".
- Introduzir bootstrap dedicado da app para testes:
  - permite arrancar a app com overrides;
  - permite inicializar Firebase e ligar SDKs aos emuladores antes de construir providers.
- Fixar portas de emuladores em `firebase.json` e usar um único project id demo (`demo-local-transport`) em todas as lanes de emulador.
- Em lanes de emulador:
  - desativar persistência local do Firestore para evitar cache stale entre resets do emulador;
  - usar App Check debug provider também na lane Flutter emulator E2E, com token debug registado no projeto demo e exposto ao Android CI por `APP_CHECK_DEBUG_TOKEN_FROM_CI` via `firebaseAppCheckDebugSecret`;
  - validar notificações apenas por efeitos observáveis no app/store/callable, nunca por entrega FCM real.
- Na app Android debug usada pela lane de emulador:
  - remover `FirebaseInitProvider` para que a bootstrap Flutter seja dona da app Firebase por omissão;
  - permitir cleartext traffic apenas em `src/debug`, porque Auth/Firestore/RTDB emulados são expostos por HTTP local.
- A primeira milestone da lane `integration_test/emulator` fica deliberadamente estreita:
  - arranque não autenticado até welcome;
  - login real no Auth emulator;
  - routing por perfil/claims reais;
  - renderização de dados seed em Firestore;
  - leitura RTDB via providers/serviços reais da app.

## Consequências
- CI passa a separar confiança rápida e confiança alta:
  - PRs executam `flutter test`, mocked app flows, `functions` tests e `rules-test`.
  - merge/nightly executam a lane Flutter emulator E2E.
- O bootstrap da app ganha configuração explícita para runtime Firebase live vs emulator.
- As suites deixam de depender de `main()` para testes de UI.
- Storage rules passam a fazer parte da baseline de regressão, juntamente com Firestore e RTDB.
- A lane Flutter emulator E2E passa a depender de um seed determinístico (`seed:emulator:e2e`) e de um secret CI adicional para o debug provider do App Check.
- Para estabilidade de CI, a execução principal da lane Flutter emulator E2E importa um baseline exportado dos emuladores (`integration_test/emulator/baseline`) em vez de recriar dados ao vivo com triggers/functions ativos.
- Workflows que arrancam a Local Emulator Suite passam a fixar Java 21 para acompanhar os requisitos atuais do `firebase-tools`.
- A smoke suite `dev` continua deliberadamente pequena para não transformar backend real na baseline de regressão.

## Trade-offs
- Mais infraestrutura de teste e workflows GitHub.
- As lanes `integration_test` passam a exigir dispositivo/emulador Android em CI.
- Há duplicação intencional entre fakes rápidos e cenários com emuladores para equilibrar velocidade e confiança.
