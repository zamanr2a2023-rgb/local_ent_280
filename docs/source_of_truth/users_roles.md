# Source of Truth: Users & Roles

## Objetivo do domínio
- Definir identidade, papel e permissões operacionais por utilizador autenticado.

## Entidades e contratos
- Papel de domínio: `ProfileRole` (`client`, `driver`, `manager`, `admin`).
- Estado de autenticação usa `AuthStatus` com papel resolvido.
- Papel é resolvido por custom claims com fallback para `users/{uid}.role`.
- Perfil de utilizador inclui preferência opcional `uiCurrency` (`CVE`/`EUR`/`USD`), com default funcional em `CVE`.
- Preferência de idioma da app é local (dispositivo), com suporte explícito a `en`, `pt_PT` e `es`.
  Sem override local, a app segue o idioma preferido do dispositivo; se não suportado, fallback fixo `pt_PT`.
- Mudança de idioma aplica-se a copy owned pela app (UI, estados vazios/loading/error, tooltips e labels operacionais).
  Conteúdo criado por utilizadores, administradores ou vindo já persistido no backend é apresentado como foi guardado e não é traduzido automaticamente.

## Matriz de papéis e permissões
- `client`: pedir viagem, acompanhar viagem, consultar saldo, pacotes e histórico.
  Pode submeter avaliação de viagem concluída (write restrito de `rating` em `trips/{tripId}`).
  Pode usar:
  - tickets de suporte geral (`supportRequests`);
  - chat da viagem durante a janela operacional da trip.
  No dashboard, a saudação no topo é personalizada com o nome do cliente (`Olá, {nome}`).
  O dashboard do cliente expõe dois atalhos primários em largura total:
  `Minhas viagens` e `Pedir viagem`.
  O dashboard também expõe a entrada secundária `Pacotes`, onde o cliente pode navegar o catálogo, confirmar pacotes e consultar os próprios bookings.
  No detalhe do booking de package, a UI separa explicitamente `estado comercial` de `estado operacional`.
  No detalhe da viagem, quando existe recibo pago, a UI expõe `Recibo` com ação `Exportar PDF`; não expõe `Cobrança` nem `Detalhes técnicos`.
- `driver`: gerir disponibilidade, aceitar/recusar viagens, executar estados operacionais.
  Pode persistir metering vivo em `trips/{tripId}/metering/current` quando é o motorista atribuído; o write direto legado para `trips/{tripId}.meteringSnapshot` só permanece como fallback de migração.
  Pode usar o chat da viagem durante a janela operacional da trip.
  No dashboard, o atalho `Eventos do dia` mostra badge vermelha sem número quando há eventos/reservas pendentes de hoje com horário `>= agora`.
  No dashboard, a app mostra copy neutra a informar que a viatura de serviço é monitorizada apenas em contexto operacional/on-duty, com acesso restrito e sem penalizações automáticas neste MVP.
  No detalhe da viagem, a UI não expõe `Detalhes técnicos`.
- `manager`: operações administrativas restritas (especialmente suporte, operações de frota/driver, reservas operacionais, relatórios filtráveis e receção de alertas de `NO_DRIVERS_AVAILABLE`).
  Também pode consultar e resolver tickets de suporte e pedidos de recuperação de password via `supportRequests` sem leitura global da coleção `users`.
  Pode gerir tarifário apenas quando a claim de permissões incluir `mt`.
  Pode gerir `tripPackages` apenas quando a claim de permissões incluir `tp`.
  A gestão de `tripPackages` é comercial: template, preço fixo, destino fixo, `allowedTransportTypes`, ativação/desativação, arquivo e delete que bloqueia apenas novas vendas.
  Pode gerir reservas `internal_staff` apenas quando a claim incluir em simultâneo `vt`, `vd` e `vc`.
  Pode aceder ao módulo `Chats de viagem` apenas quando a claim incluir `ch`.
  Pode consultar incidentes operacionais quando a claim incluir `vt` e `vd`.
  Pode rever incidentes operacionais e aprovar reposicionamentos temporários quando a claim incluir `ts`.
  O módulo `Motoristas` permanece sempre limitado a utilizadores `driver`, mesmo quando outras permissões permitem carregar clientes para superfícies operacionais distintas.
  A permissão `av` permite criar, atualizar e remover atribuições em `driverVehicleAssignments` para suportar reatribuição de viaturas entre motoristas.
  No detalhe operacional da viagem, a UI mantém `Detalhes técnicos`.
- `admin`: gestão completa de utilizadores, pricing, frota, saldos, auditoria, relatórios e reservas operacionais.
  Na lista de motoristas partilhada com o `manager`, a identidade apresentada é human-friendly
  (nome/contacto/matrícula), com IDs completos apenas em contexto técnico explícito.

## Regras de autenticação e autorização
- Sessão via Firebase Auth.
- Utilizador autenticado pode alterar a palavra-passe em `Definições > Mudar palavra-passe`, com reautenticação obrigatória e tratamento explícito de `requires-recent-login`.
- Fluxo `Esqueci-me da palavra-passe` é operacional (sem email reset): callable público `requestPasswordHelp` com App Check enforcement, resposta invariável `{ok: true}` e mensagem final com `config/support.supportPhone` quando disponível.
  Em builds debug, o teste mantém o mesmo enforcement e usa App Check debug provider com token registado na Firebase Console; não existe bypass backend no projeto partilhado.
- Pedidos de ajuda ficam visíveis para `admin|manager` em `supportRequests/{id}` e são espelhados em `users/{uid}.support.passwordHelp` quando o perfil existe.
- Firestore Rules aplicam autorização por papel e ownership.
- Self-update de `users/{uid}` é restrito por allowlist a `uiCurrency` e `updatedAt` (sem edição de outros campos por write direto do próprio utilizador).
- Idioma não é persistido em `users/{uid}` nesta fase (apenas storage local), preservando a política de allowlist atual.
- Presentation state não deve persistir strings localizadas; providers/controllers expõem códigos/estados tipados e a tradução final acontece nos widgets.
- Leitura de `trips/{tripId}/driverContactSnapshots/{snapshotId}` é permitida para participantes da viagem e operações.
- Contacto do motorista no lado cliente usa snapshot de viagem (`driverContactSnapshots`) gerado pelo backend no momento de atribuição.
- Documentos de monitorização operacional (`driverOperationalStates`, `tripOperationalMetrics`, `operationalIncidents`, `operationalMovementApprovals`) são estritamente operacionais:
  - `admin` lê tudo;
  - `manager` lê com `vt + vd`;
  - mutações de revisão/aprovação passam sempre por callable;
  - `driver` e `client` não leem estes documentos.
- Fluxos críticos de negócio usam callables autenticadas para validação transacional.
- Navegação no app é role-based com redireção por destino autenticado.
- Shortcut de definições (ícone engrenagem) aparece apenas no landing autenticado por papel:
  - `clientDashboard`, `driverHome`, `managerHome`, `adminHome`.
- Em rotas internas (detalhe/listas/formulários), o ícone fica oculto.
- Exceção explícita: `Welcome` mantém atalho de definições apenas em `kDebugMode`.

## Permissões configuráveis de manager (claims `mp`)
- Autoridade de segurança: custom claims Firebase Auth (`request.auth.token.mp`).
- Espelho informativo em Firestore: `users/{uid}.managerPermissions` (UI/admin), sem autoridade de segurança.
- Catálogo canónico:
  - Leitura: `vt` (trips), `vr` (reports), `va` (audit), `vd` (drivers), `vc` (clients), `vs` (supportRequests).
  - Ações: `cs` (cancelTripBySupport), `ts` (updateTripSupport), `rp` (resolvePasswordHelpRequest), `me` (manageEvents), `av` (assignVehicleToDriver), `ed` (editDriverStatus).
  - Catálogo/Produto: `mt` (manageTariffs), `tp` (manageTripPackages), `ch` (manageClientChats).
- Dependências normalizadas no backend:
  - `cs => vt`
  - `ts => vt`
  - `rp => vs`
  - `av => vd`
  - `me => vd`
  - `ch => vc`
  - `mt` não tem dependências adicionais.
  - `tp` não tem dependências adicionais.
- Manager sem `mp` válido fica bloqueado por defeito:
  - o home operacional continua a mostrar o catálogo completo de módulos, todos em estado bloqueado;
  - surge um banner de recuperação “Permissões por configurar” com ações `Atualizar permissões` (refresh manual) e `Terminar sessão`.
- Manager com `mp` configurado mas permissões parciais:
  - continua a ver todos os módulos do catálogo;
  - módulos sem permissão aparecem desativados com a nota `Bloqueado pelo administrador`;
  - toque em módulo bloqueado abre apenas feedback informativo, sem navegação.
- Manager com `mp` configurado mas zero permissões ativas:
  - vê o catálogo completo bloqueado;
  - surge um banner leve `Sem acesso a módulos` com ação `Atualizar permissões`.
- Refresh de claims:
  - manual: força `getIdToken(true)`;
  - foreground: refresh com debounce de 10 minutos;
  - quando hash de permissões muda, providers operacionais são invalidados para reinício real dos listeners.

## Integrações e dependências
- Firebase Auth para identidade.
- Firestore `users/{uid}` para fallback de papel e perfil.
- App shell para routing por papel.

## Estados de erro e edge cases
- Perfil ausente ou papel inválido redireciona para estado de recuperação.
- Claims e perfil podem divergir temporariamente; fallback reduz quebra de fluxo.

## Fora de escopo
- Multi-tenant por organização.
- Delegação avançada de permissões por feature granular.

## Desvios do baseline MVP
- Papel `manager` está ativo no produto atual, com permissões operacionais intermédias.

## Referências de implementação
- `lib/features/auth/domain/entities/profile_role.dart`
- `lib/features/auth/domain/entities/auth_status.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/app/presentation/role_based_home_shell.dart`
- `firestore.rules`
