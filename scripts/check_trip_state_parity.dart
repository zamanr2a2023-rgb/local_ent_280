import 'dart:convert';
import 'dart:io';

const _canonicalPath = 'contracts/trip_state_machine/transitions.json';
const _dartStateMachinePath =
    'lib/features/trips/domain/services/trip_state_machine.dart';
const _tsStateMachinePath = 'functions/src/trips/tripStateMachineCallables.ts';

void main() {
  final canonical = _readCanonicalTransitions();
  final dart = _parseDartTransitions();
  final ts = _parseTsTransitions();

  final issues = <String>[];
  issues.addAll(_compareTransitions(canonical, dart, 'Dart'));
  issues.addAll(_compareTransitions(canonical, ts, 'TypeScript'));

  if (issues.isEmpty) {
    stdout.writeln('Trip state machine parity check passed.');
    exit(0);
  }

  stderr.writeln('Trip state machine parity check failed:');
  for (final issue in issues) {
    stderr.writeln('- $issue');
  }
  exit(1);
}

Map<String, Set<String>> _readCanonicalTransitions() {
  final file = File(_canonicalPath);
  if (!file.existsSync()) {
    throw StateError('Canonical transitions file not found: $_canonicalPath');
  }
  final content = file.readAsStringSync();
  final decoded = jsonDecode(content);
  if (decoded is! Map<String, dynamic>) {
    throw StateError('Canonical transitions must be a JSON object.');
  }

  final transitions = <String, Set<String>>{};
  for (final entry in decoded.entries) {
    final value = entry.value;
    if (value is! List) {
      throw StateError('Canonical transition ${entry.key} must be a list.');
    }
    transitions[entry.key] = value.map((item) => item.toString()).toSet();
  }
  return transitions;
}

Map<String, Set<String>> _parseTsTransitions() {
  final file = File(_tsStateMachinePath);
  if (!file.existsSync()) {
    throw StateError(
      'TypeScript state machine not found: $_tsStateMachinePath',
    );
  }
  final source = file.readAsStringSync();

  final entryRegex = RegExp(
    r'([A-Z_]+)\s*:\s*new Set\(\s*(?:\[(.*?)\])?\s*\)',
    dotAll: true,
  );
  final valueRegex = RegExp('"([A-Z_]+)"');

  final transitions = <String, Set<String>>{};
  for (final match in entryRegex.allMatches(source)) {
    final from = match.group(1)!;
    final valuesChunk = match.group(2) ?? '';
    final values = valueRegex
        .allMatches(valuesChunk)
        .map((m) => m.group(1)!)
        .toSet();
    transitions[from] = values;
  }

  if (transitions.isEmpty) {
    throw StateError('Unable to parse TypeScript state machine transitions.');
  }

  return transitions;
}

Map<String, Set<String>> _parseDartTransitions() {
  final file = File(_dartStateMachinePath);
  if (!file.existsSync()) {
    throw StateError('Dart state machine not found: $_dartStateMachinePath');
  }
  final source = file.readAsStringSync();

  // Regex extraction keeps the check lightweight and avoids coupling to a
  // build step for this verification script.
  final entryRegex = RegExp(
    r'TripState\.([a-zA-Z0-9]+)\s*:\s*\{(.*?)\}',
    dotAll: true,
  );
  final valueRegex = RegExp(r'TripState\.([a-zA-Z0-9]+)');

  final transitions = <String, Set<String>>{};
  for (final match in entryRegex.allMatches(source)) {
    final fromCamel = match.group(1)!;
    final valuesChunk = match.group(2)!;
    final values = valueRegex
        .allMatches(valuesChunk)
        .map((m) => _camelToUpperSnake(m.group(1)!))
        .toSet();
    transitions[_camelToUpperSnake(fromCamel)] = values;
  }

  if (transitions.isEmpty) {
    throw StateError('Unable to parse Dart state machine transitions.');
  }

  return transitions;
}

List<String> _compareTransitions(
  Map<String, Set<String>> canonical,
  Map<String, Set<String>> candidate,
  String label,
) {
  final issues = <String>[];
  final canonicalKeys = canonical.keys.toSet();
  final candidateKeys = candidate.keys.toSet();

  final missingStates = canonicalKeys.difference(candidateKeys).toList()
    ..sort();
  final extraStates = candidateKeys.difference(canonicalKeys).toList()..sort();

  if (missingStates.isNotEmpty) {
    issues.add('$label missing states: ${missingStates.join(', ')}');
  }
  if (extraStates.isNotEmpty) {
    issues.add('$label has extra states: ${extraStates.join(', ')}');
  }

  final comparableKeys = canonicalKeys.intersection(candidateKeys).toList()
    ..sort();
  for (final state in comparableKeys) {
    final expected = canonical[state]!;
    final actual = candidate[state]!;
    if (expected.length == actual.length && expected.containsAll(actual)) {
      continue;
    }
    final missingTransitions = expected.difference(actual).toList()..sort();
    final extraTransitions = actual.difference(expected).toList()..sort();
    final details = <String>[];
    if (missingTransitions.isNotEmpty) {
      details.add('missing: ${missingTransitions.join(', ')}');
    }
    if (extraTransitions.isNotEmpty) {
      details.add('extra: ${extraTransitions.join(', ')}');
    }
    issues.add(
      '$label transitions mismatch for $state (${details.join(' | ')})',
    );
  }

  return issues;
}

String _camelToUpperSnake(String value) {
  final buffer = StringBuffer();
  for (var i = 0; i < value.length; i++) {
    final rune = value.codeUnitAt(i);
    final isUppercase = rune >= 65 && rune <= 90;
    if (isUppercase && i > 0) {
      buffer.write('_');
    }
    buffer.writeCharCode(isUppercase ? rune : rune - 32);
  }
  return buffer.toString();
}
