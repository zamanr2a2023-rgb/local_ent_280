import 'dart:io';

const List<String> _auditedFiles = <String>[
  'lib/features/manager/presentation/screens/manager_home_shell.dart',
  'lib/features/manager/presentation/screens/manager_trips_screen.dart',
  'lib/features/manager/presentation/mappers/manager_unfulfilled_reason_presenter.dart',
  'lib/features/client/presentation/screens/client_trips_screen.dart',
  'lib/features/client/presentation/screens/client_trip_pickup_screen.dart',
  'lib/features/client/presentation/screens/client_trip_destination_screen.dart',
  'lib/features/client/presentation/widgets/place_selection_view.dart',
  'lib/features/client/presentation/widgets/transport_type_selection_view.dart',
];

final RegExp _stringLiteralPattern = RegExp(
  r"""(['"])([^'"\n]*[A-Za-zÀ-ÿ][^'"\n]*)\1""",
);

final List<RegExp> _allowedLinePatterns = <RegExp>[
  RegExp(r'^\s*import '),
  RegExp(r'^\s*//'),
  RegExp(r'developer\.log\('),
  RegExp(r"name:\s*'"),
  RegExp(r"logContext:\s*'"),
  RegExp(r"value:\s*'[a-z0-9_\/-]+'"),
  RegExp(r"MarkerId\('[a-z0-9_-]+'\)"),
  RegExp(r"^\s*r?'\\^"),
  RegExp(r"RegExp\(r?'\\s\+'\)"),
  RegExp(r"^\s*'[a-z0-9_]+'\s*=>"),
  RegExp(r'\/settings'),
];

void main() {
  final issues = <String>[];

  for (final path in _auditedFiles) {
    final file = File(path);
    if (!file.existsSync()) {
      issues.add('Missing audited file: $path');
      continue;
    }
    final lines = file.readAsLinesSync();
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      final previousLine = index > 0 ? lines[index - 1] : '';
      final nextLine = index + 1 < lines.length ? lines[index + 1] : '';
      if (_allowedLinePatterns.any((pattern) => pattern.hasMatch(line))) {
        continue;
      }
      if (previousLine.contains('developer.log(') ||
          nextLine.contains("name: '") ||
          line.contains(r'${') ||
          line.contains("case '") ||
          line.contains("pushNamed('/") ||
          line.contains("r'^") ||
          line.contains('x\$')) {
        continue;
      }
      if (_stringLiteralPattern.hasMatch(line)) {
        issues.add('$path:${index + 1} ${line.trim()}');
      }
    }
  }

  if (issues.isNotEmpty) {
    stderr.writeln('Presentation copy guard failed. Hardcoded literals found:');
    for (final issue in issues) {
      stderr.writeln(' - $issue');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Presentation copy guard passed for audited surfaces.');
}
