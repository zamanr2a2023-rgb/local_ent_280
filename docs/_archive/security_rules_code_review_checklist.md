# DEPRECATED — do not use

Documento arquivado para histórico.
Fonte oficial atual: docs/README.md.

# Checklist formal de code review para Security Rules

Este checklist define um processo repetível para revisão de regras de segurança do Firebase (Firestore + Realtime Database).

## 1) Modelo de ameaça e superfícies de escrita
- [ ] Inventariar todas as coleções/nós com `allow write` / `.write`.
- [ ] Confirmar que ações críticas (estado, finanças, permissões) não têm caminhos de bypass pelo cliente.
- [ ] Garantir princípio de menor privilégio por papel (admin, client, driver).

## 2) Firestore: autorização e validação
- [ ] Evitar condições amplas (`isParticipant`) para `update` sem validação por campo.
- [ ] Se escrita do cliente for permitida, restringir por campos permitidos e validar diffs.
- [ ] Validar invariantes de domínio: transições de estado, ownership, imutabilidade de IDs e timestamps sensíveis.
- [ ] Bloquear deletes não necessários por padrão (`allow delete: if false`).
- [ ] Garantir que `get()` em regras não abre escalada de privilégios.

## 3) Realtime Database: autorização e estrutura
- [ ] Definir `.read` e `.write` globais como `false` por omissão.
- [ ] Aplicar ownership explícito por nó (`auth.uid === $id`) quando aplicável.
- [ ] Adicionar `.validate` para formato, tipo e intervalos de valores.
- [ ] Confirmar que nós sensíveis não são sobrescrevíveis por terceiros autenticados.

## 4) Testes obrigatórios por regra alterada
- [ ] Caso permitido (assertSucceeds) para cada papel autorizado.
- [ ] Caso negado (assertFails) para cada papel não autorizado.
- [ ] Caso negado para utilizador não autenticado.
- [ ] Casos de validação estrutural (payload inválido) para RTDB e Firestore quando aplicável.
- [ ] Testes executados via emulador no CI (PR gate).

## 5) Observabilidade e operação
- [ ] Logs de inicialização dos testes incluem host/porta/projeto para troubleshooting.
- [ ] Falhas de configuração de emulador têm fallback seguro e aviso explícito.
- [ ] Documentação do contrato de escrita (callables vs escrita direta) atualizada.

## 6) Critérios de aprovação
- [ ] Nenhum caminho crítico permite bypass do state machine/backend.
- [ ] Todos os testes de regras passam em CI.
- [ ] Mudança está documentada e coerente com arquitetura do sistema.
