import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/admin/presentation/formatters/report_export_metadata_builder.dart';

void main() {
  const builder = ReportExportMetadataBuilder();

  test('build includes exportScope and complete sourceState', () {
    final metadata = builder.build(
      reportId: 'report-1',
      schemaVersion: 'reports_v2',
      workspace: 'Panorama Operacional',
      mode: 'Detalhe',
      selectedEntity: 'Âmbito global',
      periodStart: DateTime(2026, 4, 1),
      periodEnd: DateTime(2026, 4, 7),
      timezone: 'WEST (+01:00)',
      generatedAt: DateTime(2026, 4, 7, 10),
      generatedBy: 'admin@example.com',
      filtersApplied: 'Sem filtros adicionais',
      rowCount: 12,
      isDatasetComplete: true,
      disclaimer: 'internal only',
    );

    expect(
      metadata.any(
        (entry) =>
            entry.label == 'exportScope' &&
            entry.value == 'complete_filtered_dataset',
      ),
      isTrue,
    );
    expect(
      metadata.any(
        (entry) =>
            entry.label == 'sourceState' &&
            entry.value ==
                'dataset materializado completo até ao teto operacional',
      ),
      isTrue,
    );
  });

  test('build marks blocked exports for incomplete datasets', () {
    final metadata = builder.build(
      reportId: 'report-2',
      schemaVersion: 'reports_v2',
      workspace: 'Panorama Operacional',
      mode: 'Detalhe',
      selectedEntity: 'Âmbito global',
      periodStart: DateTime(2026, 4, 1),
      periodEnd: DateTime(2026, 4, 7),
      timezone: 'WEST (+01:00)',
      generatedAt: DateTime(2026, 4, 7, 10),
      generatedBy: 'admin@example.com',
      filtersApplied: 'estado=Concluída',
      rowCount: 5000,
      isDatasetComplete: false,
      disclaimer: 'internal only',
    );

    expect(
      metadata.any(
        (entry) =>
            entry.label == 'exportScope' &&
            entry.value == 'blocked_incomplete_dataset',
      ),
      isTrue,
    );
  });
}
