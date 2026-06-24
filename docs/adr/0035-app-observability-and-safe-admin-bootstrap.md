# ADR 0035: Observabilidade da App e Bootstrap Seguro de Admin

## Contexto
- A app já usava Firebase como backend principal, mas não tinha telemetria operacional mínima no cliente:
  - sem Crashlytics para crashes fatais/não fatais;
  - sem Analytics básico para login e screen views;
  - sem ligação consistente entre sessão autenticada e contexto de observabilidade.
- O único script existente que criava um admin bootstrap no backend era `reset_seed_basic`, mas esse fluxo era destrutivo e incompatível com produção porque limpava Firestore, Realtime Database, Storage e Auth antes de recriar o admin.

## Decisão
1. Introduzir duas abstrações de observabilidade injetadas:
   - `AnalyticsService`
   - `CrashReportingService`
2. Implementar essas abstrações com Firebase:
   - `firebase_analytics` para login e `screen_view`;
   - `firebase_crashlytics` para crashes fatais, erros Flutter e erros não fatais capturados no bootstrap.
3. Inicializar telemetria no arranque através de um bootstrap dedicado e instalar handlers globais de erro:
   - `FlutterError.onError`
   - `PlatformDispatcher.instance.onError`
4. Associar a sessão autenticada à telemetria via binder de app:
   - `userId` e `role` em Analytics;
   - `userIdentifier` e custom key `auth_role` em Crashlytics.
5. Ativar recolha de telemetria apenas fora de `kDebugMode`:
   - builds `release/profile` de `dev` e `prod` recolhem dados;
   - debug local continua sem ruído operacional em Firebase.
6. Adicionar script não destrutivo `seed:admin` para bootstrap/upsert de admin:
   - cria ou atualiza apenas Auth + `users/{uid}`;
   - garante custom claim `role=admin`;
   - preserva o resto do ambiente.

## Consequências
- `dev` e `prod` passam a ter observabilidade básica no cliente Android sem acoplar UI diretamente aos SDKs Firebase.
- Crashes fatais deixam de depender apenas de logs locais e passam a ficar visíveis no Firebase Crashlytics.
- Analytics passa a ter dados mínimos de navegação e autenticação para troubleshooting operacional.
- O bootstrap de admin para produção deixa de depender de scripts destrutivos.
- A observabilidade continua limitada pelo setup nativo/plataforma disponível:
  - Android usa Crashlytics + Analytics nas duas flavors;
  - iOS só usará o projeto Firebase `prod` quando a app Apple correspondente existir.
