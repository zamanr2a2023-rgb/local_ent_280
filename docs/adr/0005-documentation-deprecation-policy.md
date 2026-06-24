# ADR 0005: Política de Deprecação Documental

- Data: 2026-02-16
- Estado: aceite

## Contexto
- Existiam documentos antigos e contraditórios, usados como fonte informal de verdade.
- Isso gerava decisões baseadas em informação desatualizada.

## Decisão
- Definir `docs/source_of_truth/` como conjunto canónico oficial por domínio.
- Para documentação antiga:
  - marcar topo com `DEPRECATED — do not use`;
  - remover de navegação oficial (`docs/README.md`);
  - incluir referência explícita para o documento canónico substituto.
- Quando necessário para preservar histórico:
  - mover conteúdo legado para `docs/_archive/`.

## Consequências
- Redução de conflito entre documentos.
- Leitura operacional passa a ter uma única fonte por domínio.
- Decisões futuras deixam de depender de documentação ambígua.
