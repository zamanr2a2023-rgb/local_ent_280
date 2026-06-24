# DEPRECATED — do not use

Documento arquivado para histórico.
Fonte oficial atual: docs/README.md.

# Plano de testes (manual) das regras do Firestore

## Pré-requisitos
- Ter contas com `role` configurado: `client`, `driver`, `admin`.
- Ter documentos de exemplo em `users`, `trips`, `tariffs`, `vehicles`, `balances` e `tripEvents`.

## Casos principais

### users
1. **Cliente lê o próprio documento** → permitido.
2. **Cliente lê documento de outro utilizador** → bloqueado.
3. **Admin lê e edita qualquer utilizador** → permitido.

### trips
1. **Cliente lê uma viagem onde `clientId` é o seu UID** → permitido.
2. **Motorista lê uma viagem onde `assignedDriverId` é o seu UID** → permitido.
3. **Cliente/motorista tenta ler viagem sem associação** → bloqueado.
4. **Admin lê qualquer viagem** → permitido.

### tariffs e vehicles
1. **Qualquer utilizador autenticado lê** → permitido.
2. **Cliente/motorista tenta escrever** → bloqueado.
3. **Admin escreve** → permitido.

### balances
1. **Cliente lê o próprio saldo** → permitido.
2. **Cliente lê saldo de outro utilizador** → bloqueado.
3. **Motorista lê qualquer saldo** → bloqueado.
4. **Admin escreve saldo** → permitido.

### tripEvents
1. **Admin cria evento** → permitido.
2. **Cliente/motorista cria evento da sua viagem** → permitido.
3. **Admin tenta atualizar/apagar evento** → bloqueado (append-only).
4. **Cliente/motorista lê eventos da sua viagem** → permitido.
