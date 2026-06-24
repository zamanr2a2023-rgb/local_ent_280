# ADR 0029: Exportação de relatórios por ficheiro binário via serviço injetado

## Status
- Accepted

## Contexto
- O backoffice passou a exportar `CSV` e `XLSX`.
- A exportação deixou de ser específica de CSV e passou a depender de builders de dataset + serializers por formato.
- A integração com APIs de plataforma (`share_plus`, `path_provider`, ficheiros temporários) não podia contaminar Presentation nem Domain.
- O comportamento fora de mobile precisava de guardar/download o ficheiro sem partilha nativa.

## Decisão
- Introduzir `ReportExportFileService` como contrato puro Dart em Domain, injetado via Riverpod.
- Separar claramente:
  - construção do dataset exportável (`ReportExportDocument`);
  - serialização (`CsvReportSerializer`, `ReportXlsxSerializer`);
  - entrega do ficheiro (`ReportExportFileService`).
- Implementar a entrega em Data:
  - Android/iOS: gravar ficheiro temporário e abrir `Share.shareXFiles(...)`;
  - web/desktop: guardar/download direto com `FileSaver`.
- Modelar o resultado da operação com `ReportExportFileOutcome`:
  - `shared`
  - `sharedUnknown`
  - `dismissed`
  - `saved`
  - `failed`
- Passar a âncora de iPad/macOS via value object puro Dart `ShareAnchorBounds`, convertido para `Rect` apenas em Data.
- Reter exportações temporárias recentes num diretório dedicado (`reports_exports`) com pruning oportunístico:
  - remover ficheiros com mais de 7 dias;
  - manter no máximo os 8 mais recentes;
  - não apagar agressivamente o ficheiro imediatamente após o share regressar.
- Em Presentation:
  - `ReportExportController` gera bytes no formato pedido e delega a entrega ao serviço;
  - o UI apenas apresenta feedback de sucesso/falha, sem fallback de preview textual.

## Consequências
- Positivas:
  - UX nativa em mobile, com acesso a Ficheiros, email, Drive, WhatsApp e apps equivalentes.
  - Desktop/web passam a descarregar/guardar ficheiros reais em vez de depender de preview textual.
  - Clean Architecture preservada: plataforma e file IO ficam encapsulados em Data.
  - Um único boundary de export suporta múltiplos formatos.
- Trade-offs:
  - o fluxo de exportação passa a depender de um serviço adicional injetado.
  - a retenção temporária exige pruning local para evitar acumulação de ficheiros.
  - `CSV` e `XLSX` partilham a mesma semântica de dataset, mas exigem serializers diferentes e manutenção de regras de segurança em ambos.

## Implementação associada
- Domain:
  - `report_export_file_service.dart`
  - `report_export_file_outcome.dart`
  - `report_export_document.dart`
  - `report_export_format.dart`
  - `share_anchor_bounds.dart`
- Data:
  - `report_export_file_service_io.dart`
  - `report_export_file_service_stub.dart`
  - `report_export_file_service_provider.dart`
  - `report_csv_serializer.dart`
  - `report_xlsx_serializer.dart`
- Presentation:
  - `report_export_controller.dart`
  - `admin_reports_screen.dart`
