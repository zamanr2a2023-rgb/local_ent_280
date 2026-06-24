import 'dart:convert';
import 'dart:io';

const Map<String, String> _arbFiles = <String, String>{
  'pt_PT': 'lib/l10n/app_pt_PT.arb',
  'pt': 'lib/l10n/app_pt.arb',
  'en': 'lib/l10n/app_en.arb',
  'es': 'lib/l10n/app_es.arb',
};

void main() {
  final reference = _readArb(_arbFiles['pt_PT']!);
  final referenceKeys = _messageKeys(reference);

  final issues = <String>[];
  for (final entry in _arbFiles.entries) {
    final locale = entry.key;
    final path = entry.value;
    final candidate = _readArb(path);
    final candidateKeys = _messageKeys(candidate);

    final missing = referenceKeys.difference(candidateKeys).toList()..sort();
    final extra = candidateKeys.difference(referenceKeys).toList()..sort();

    for (final key in missing) {
      issues.add('[$locale] Missing key: $key');
    }
    for (final key in extra) {
      issues.add('[$locale] Extra key: $key');
    }

    for (final key in referenceKeys) {
      _validatePlaceholderParity(
        locale: locale,
        key: key,
        reference: reference,
        candidate: candidate,
        issues: issues,
      );
    }
  }

  if (issues.isNotEmpty) {
    stderr.writeln('L10n parity check failed:');
    for (final issue in issues) {
      stderr.writeln(' - $issue');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('L10n parity check passed for pt_PT, pt, en, es.');
}

Map<String, dynamic> _readArb(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('Missing ARB file: $path');
    exit(1);
  }
  final content = file.readAsStringSync();
  final decoded = jsonDecode(content);
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln('Invalid ARB JSON object: $path');
    exit(1);
  }
  return decoded;
}

Set<String> _messageKeys(Map<String, dynamic> arb) {
  return arb.keys.where((key) => !key.startsWith('@')).toSet();
}

void _validatePlaceholderParity({
  required String locale,
  required String key,
  required Map<String, dynamic> reference,
  required Map<String, dynamic> candidate,
  required List<String> issues,
}) {
  final refMeta = reference['@$key'];
  final candidateMeta = candidate['@$key'];
  final refPlaceholders = _placeholderMap(refMeta);
  final candidatePlaceholders = _placeholderMap(candidateMeta);

  final refNames = refPlaceholders.keys.toSet();
  final candidateNames = candidatePlaceholders.keys.toSet();
  final missingNames = refNames.difference(candidateNames).toList()..sort();
  final extraNames = candidateNames.difference(refNames).toList()..sort();

  for (final placeholder in missingNames) {
    issues.add('[$locale] Key "$key" missing placeholder "$placeholder".');
  }
  for (final placeholder in extraNames) {
    issues.add('[$locale] Key "$key" extra placeholder "$placeholder".');
  }

  for (final placeholder in refNames.intersection(candidateNames)) {
    final refType = _placeholderType(refPlaceholders[placeholder]);
    final candidateType = _placeholderType(candidatePlaceholders[placeholder]);
    if (refType != candidateType) {
      issues.add(
        '[$locale] Key "$key" placeholder "$placeholder" type mismatch: '
        'expected "$refType" got "$candidateType".',
      );
    }
  }
}

Map<String, dynamic> _placeholderMap(dynamic metadata) {
  if (metadata is! Map<String, dynamic>) {
    return const <String, dynamic>{};
  }
  final placeholders = metadata['placeholders'];
  if (placeholders is! Map<String, dynamic>) {
    return const <String, dynamic>{};
  }
  return placeholders;
}

String _placeholderType(dynamic placeholderMetadata) {
  if (placeholderMetadata is! Map<String, dynamic>) {
    return 'dynamic';
  }
  final type = placeholderMetadata['type'];
  if (type is! String || type.trim().isEmpty) {
    return 'dynamic';
  }
  return type.trim();
}
