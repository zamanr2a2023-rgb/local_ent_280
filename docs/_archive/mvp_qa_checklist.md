# DEPRECATED — do not use

Documento arquivado para histórico.
Fonte oficial atual: docs/README.md.

# Checklist QA MVP

## Preparação

- [ ] Garantir credenciais Firebase disponíveis (emulador ou projeto real).
- [ ] Instalar dependências das Cloud Functions:
  - `npm --prefix functions install`
- [ ] Semear dados MVP (Firestore + Auth):
  - `npm --prefix functions run seed:mvp`
- [ ] Confirmar que as contas foram criadas com sucesso.

### Contas de teste

| Papel | Email | Palavra-passe | Notas |
| --- | --- | --- | --- |
| Admin | `admin.qa@localtransport.test` | `Admin123!@#` | Gestão de tarifas e utilizadores. |
| Motorista 1 | `driver1.qa@localtransport.test` | `Driver123!@#` | Disponível + veículo associado. |
| Motorista 2 | `driver2.qa@localtransport.test` | `Driver123!@#` | Disponível + sem veículo dedicado. |
| Cliente 1 | `cliente1.qa@localtransport.test` | `Cliente123!@#` | Saldo positivo. |
| Cliente 2 | `cliente2.qa@localtransport.test` | `Cliente123!@#` | Saldo perto do limite de dívida. |

## Checklist de QA

### 1) Fluxo completo do cliente (end-to-end)

- [ ] Entrar como **Cliente 1**.
- [ ] Criar pedido de viagem com origem e destino válidos.
- [ ] Validar que a estimativa aparece com a tarifa ativa.
- [ ] Entrar como **Motorista 1** e aceitar a viagem.
- [ ] Verificar que o cliente recebe confirmação de atribuição.
- [ ] Avançar estados: chegada → início → chegada ao destino.
- [ ] Verificar que a viagem entra na janela de extensão.
- [ ] Concluir a viagem e validar resumo/recibo.

### 2) Cancelamento, no-show e extensão

- [ ] Criar uma nova viagem com **Cliente 1**.
- [ ] Antes do motorista chegar, cancelar no cliente.
- [ ] Confirmar estado “cancelado” e cobrança conforme política.
- [ ] Criar nova viagem com **Cliente 1**.
- [ ] No motorista, marcar chegada e aguardar janela de no-show.
- [ ] Confirmar aplicação de taxa de no-show (quando aplicável).
- [ ] Criar nova viagem com **Cliente 1**.
- [ ] Na janela de extensão, solicitar extensão no cliente.
- [ ] No motorista, aceitar a extensão.
- [ ] Confirmar que a extensão é aplicada e viagem continua.

### 3) Aceitação/recusa e reatribuição de motorista

- [ ] Criar viagem com **Cliente 1**.
- [ ] Entrar como **Motorista 1** e recusar a viagem.
- [ ] Confirmar que a viagem é reatribuída ao **Motorista 2**.
- [ ] Entrar como **Motorista 2** e aceitar a viagem.
- [ ] Confirmar que o cliente vê o novo motorista.

### 4) Tarifa atualizada (admin → cliente)

- [ ] Entrar como **Admin** e atualizar a tarifa base ou por km.
- [ ] Guardar alterações.
- [ ] Voltar ao **Cliente 1** e criar nova estimativa.
- [ ] Confirmar que a estimativa reflete a tarifa atualizada.

## Limitações conhecidas

- A seed utiliza datas de feriado com base no dia UTC; em timezone local pode exigir ajustar a data no painel de tarifas.
- A gravação de localizações no Realtime Database depende de `FIREBASE_DATABASE_URL` (ou do emulador configurado). Sem isto, apenas a localização em Firestore é semeada.
- As custom claims podem demorar alguns minutos a propagar em ambientes reais.
