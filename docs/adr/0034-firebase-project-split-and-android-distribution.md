# ADR 0034: Firebase por Ambiente, Distribuição Android e GitHub Releases CI

## Contexto
- O projeto usava um único `google-services.json` Android e um único `firebase_options.dart`, o que deixava `dev` e `prod` acoplados ao mesmo backend.
- O Android ainda usava `applicationId` placeholder e assinatura `release` com debug keystore.
- A equipa precisava de dois ambientes operacionais distintos:
  - `dev` a continuar no projeto Firebase existente `local-transport-482015` (`local-transport-dev`);
  - `prod` no novo projeto Firebase `local-transport-prod`.
- Também era necessário distribuir builds Android assinadas para teste via Firebase App Distribution.
- A equipa precisava ainda de descarregar o APK diretamente a partir de GitHub Releases quando a distribuição automática corre em `main`.

## Decisão
1. Separar Android por flavor nativo:
   - `dev` com package id `com.localtransport.app.dev`;
   - `prod` com package id `com.localtransport.app`.
2. Passar a usar `google-services.json` por flavor:
   - `android/app/src/dev/google-services.json`
   - `android/app/src/prod/google-services.json`
3. Tornar `firebase_options.dart` flavor-aware para Android:
   - `androidDev` aponta para `local-transport-482015`;
   - `androidProd` aponta para `local-transport-prod`.
4. Manter iOS temporariamente no projeto Firebase dev existente até existir Apple app/configuração operacional para `prod`.
5. Remover assinatura `release` com debug keystore e exigir keystore de upload real via:
   - `android/key.properties` local;
   - segredos GitHub para CI.
6. Distribuir Android por Firebase App Distribution através de workflow dedicado:
   - push em `main` distribui `dev`;
   - `workflow_dispatch` permite distribuir `dev` ou `prod`;
   - suporte opcional a Firebase automated tests/Test Lab quando dispositivos estiverem configurados.
7. Publicar também o APK Android em GitHub Releases no mesmo workflow de distribuição Android:
   - apenas em `push` para `main`;
   - se a versão em `pubspec.yaml` ainda não tiver release, criar tag/release nova versionada;
   - se a versão já existir, atualizar uma release rolling estável `android-dev-main-latest` com o APK mais recente;
   - manter `workflow_dispatch` como distribuição manual sem publicar GitHub Release.
8. Adicionar workflow dedicado para deploy do backend Firebase:
   - push em `main` publica `dev` quando há mudanças backend;
   - `workflow_dispatch` permite publicar `dev` ou `prod`;
   - o deploy cobre Firestore, Realtime Database, Storage e Cloud Functions.

## Consequências
- Android deixa de misturar backends entre `dev` e `prod`.
- O package id de produção deixa de depender de `com.example.*`.
- A distribuição para testers passa a usar APK `release` assinado e rastreável em Firebase.
- O APK `dev` distribuído automaticamente em `main` passa também a ficar descarregável em GitHub Releases.
- Mudanças de versão criam histórico versionado em GitHub Releases; builds subsequentes da mesma versão reutilizam uma release rolling estável.
- O repositório passa a ter caminho CI reprodutível para publicar backend Firebase sem passos manuais locais.
- O repositório fica preparado para CI de distribuição sem guardar material sensível versionado.
- O ambiente `prod` fica operacional para Android com Firestore, Realtime Database, Storage, Functions e App Distribution.
- iOS continua dependente de registo/configuração da app Apple no projeto Firebase `prod`.
