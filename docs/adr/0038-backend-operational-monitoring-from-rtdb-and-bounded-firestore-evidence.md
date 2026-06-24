# ADR 0038: Backend Operational Monitoring from RTDB with Bounded Firestore Evidence

## Contexto
- O produto precisa de detetar desvios operacionais e uso não autorizado da viatura durante contexto on-duty.
- A empresa quer revisão e auditabilidade primeiro, sem policiamento em tempo real nem arquivo telemático amplo.
- Já existe pipeline canónico de localização do motorista no RTDB e evidência de viagem ativa em `meteringSnapshot` + `pathPoints`.

## Decisão
- A avaliação de incidentes passa a ser backend-authored.
- O backend reutiliza RTDB `driverLocations/{driverId}` como fonte high-frequency.
- O backend persiste em Firestore apenas:
  - estado corrente por motorista (`driverOperationalStates`)
  - métricas agregadas (`tripOperationalMetrics`)
  - incidentes + audit trail (`operationalIncidents`)
  - approvals temporárias (`operationalMovementApprovals`)
- Não é criado arquivo bruto Firestore always-on de movement samples.
- Rotas esperadas são cacheadas por `operationalWindowId`.
- Replay e evidência ficam explicitamente bounded por caps e TTLs.

## Consequências
- Mantém-se auditabilidade suficiente para operações sem transformar o MVP num sistema de telemática histórica.
- A lógica sensível fica trusted server-side e não depende de heurísticas da UI.
- O app do motorista não ganha responsabilidade extra de enforcement.
- O modelo exige configuração seedada (`config/operations_monitoring`) e job periódico backend.
- Falhas de rota/telemetria devem fail-open para evitar falsos positivos agressivos.

## Alternativas rejeitadas
- Policiamento real-time estrito com desvios instantâneos:
  - mais ruído, mais falsos positivos, pior UX operacional.
- Arquivo completo de samples em Firestore por motorista:
  - custo e superfície de privacidade desnecessários para o MVP.
- Avaliação client-side:
  - fraca auditabilidade e menor confiança operacional.
