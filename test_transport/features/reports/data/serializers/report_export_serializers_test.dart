import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/reports/data/serializers/report_csv_serializer.dart';
import 'package:local_transport/features/reports/data/serializers/report_xlsx_serializer.dart';
import 'package:local_transport/features/reports/domain/entities/report_export_document.dart';
import 'package:xml/xml.dart';

void main() {
  const document = ReportExportDocument(
    title: 'Panorama Operacional',
    baseFileName: 'panorama-operacional',
    metadata: [
      ReportExportMetadataEntry(label: 'reportId', value: 'report-1'),
      ReportExportMetadataEntry(
        label: 'generatedBy',
        value: 'admin@example.com',
      ),
      ReportExportMetadataEntry(label: 'rowCount', value: '2'),
    ],
    sections: [
      ReportExportSection(
        title: 'Resumo executivo',
        columns: [
          ReportExportColumn(
            key: 'metric',
            label: 'Indicador',
            type: ReportExportCellType.text,
          ),
          ReportExportColumn(
            key: 'value',
            label: 'Valor',
            type: ReportExportCellType.text,
          ),
        ],
        rows: [
          {
            'metric': 'Conclusão',
            'value': '80%',
          },
        ],
      ),
    ],
    columns: [
      ReportExportColumn(
        key: 'client',
        label: 'Cliente',
        type: ReportExportCellType.text,
      ),
      ReportExportColumn(
        key: 'note',
        label: 'Nota',
        type: ReportExportCellType.text,
      ),
      ReportExportColumn(
        key: 'amountMinor',
        label: 'Valor',
        type: ReportExportCellType.integer,
      ),
      ReportExportColumn(
        key: 'distanceKm',
        label: 'Km',
        type: ReportExportCellType.decimal,
      ),
      ReportExportColumn(
        key: 'paid',
        label: 'Pago',
        type: ReportExportCellType.boolean,
      ),
    ],
    rows: [
      {
        'client': 'Cliente A',
        'note': '=2+2',
        'amountMinor': 1250,
        'distanceKm': 12.5,
        'paid': true,
      },
      {
        'client': 'Cliente "B"',
        'note': 'sem risco',
        'amountMinor': 0,
        'distanceKm': 0.0,
        'paid': false,
      },
    ],
  );

  test('CSV serializer writes metadata, BOM and neutralizes formula cells', () {
    final bytes = ReportCsvSerializer().serialize(document);
    final content = utf8.decode(bytes.sublist(3));

    expect(bytes.take(3).toList(), <int>[0xEF, 0xBB, 0xBF]);
    expect(content, contains('"reportId";"report-1"'));
    expect(content, contains('"generatedBy";"admin@example.com"'));
    expect(content, contains('"Resumo executivo"'));
    expect(content, contains('"Indicador";"Valor"'));
    expect(content, contains('"Conclusão";"80%"'));
    expect(content, contains('"Dados"'));
    expect(content, contains('"Cliente";"Nota";"Valor";"Km";"Pago"'));
    expect(content, contains('"Cliente A";"\'=2+2";"1250";"12.5";"true"'));
    expect(content, contains('"Cliente ""B""";"sem risco";"0";"0.0";"false"'));
  });

  test(
    'XLSX serializer creates Metadata/Data sheets with freeze and autofilter',
    () {
      final bytes = ReportXlsxSerializer().serialize(document);
      final archive = ZipDecoder().decodeBytes(bytes, verify: true);
      final workbookXml = utf8.decode(
        archive.findFile('xl/workbook.xml')!.content as List<int>,
      );
      final sharedStringsXml = utf8.decode(
        archive.findFile('xl/sharedStrings.xml')!.content as List<int>,
      );
      final dataSheetXml = utf8.decode(
        archive.findFile(_resolveSheetPath(archive, 'Data'))!.content
            as List<int>,
      );
      final summarySheetXml = utf8.decode(
        archive
                .findFile(
                  _resolveSheetPath(archive, 'Resumo executivo'),
                )!
                .content
            as List<int>,
      );

      expect(bytes, isNotEmpty);
      expect(workbookXml, contains('name="Metadata"'));
      expect(workbookXml, contains('name="Resumo executivo"'));
      expect(workbookXml, contains('name="Data"'));
      expect(dataSheetXml, contains('state="frozen"'));
      expect(dataSheetXml, contains('topLeftCell="A2"'));
      expect(dataSheetXml, contains('autoFilter ref="A1:E3"'));
      expect(summarySheetXml, contains('autoFilter ref="A1:B2"'));
      expect(
        sharedStringsXml.contains('&apos;=2+2') ||
            sharedStringsXml.contains("'=2+2"),
        isTrue,
      );
    },
  );
}

String _resolveSheetPath(Archive archive, String sheetName) {
  final workbook = XmlDocument.parse(
    utf8.decode(archive.findFile('xl/workbook.xml')!.content as List<int>),
  );
  final relationships = XmlDocument.parse(
    utf8.decode(
      archive.findFile('xl/_rels/workbook.xml.rels')!.content as List<int>,
    ),
  );
  final dataSheet = workbook
      .findAllElements('sheet')
      .firstWhere(
        (sheet) => sheet.getAttribute('name') == sheetName,
      );
  final relationshipId = dataSheet.attributes
      .firstWhere(
        (attribute) => attribute.name.local == 'id',
      )
      .value;
  final relationship = relationships
      .findAllElements('Relationship')
      .firstWhere(
        (element) => element.getAttribute('Id') == relationshipId,
      );
  final target = relationship.getAttribute('Target')!;
  return target.startsWith('xl/') ? target : 'xl/$target';
}
