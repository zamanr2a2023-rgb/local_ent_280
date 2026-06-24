import 'dart:io';

void main() {
  const ignoredFiles = {'lib/app/presentation/navigation/app_routes.dart'};
  const routePrefixes = [
    '/admin/',
    '/client/',
    '/driver/',
    '/manager/',
    '/onboarding',
    '/welcome',
    '/login',
    '/forgot-password',
    '/settings',
    '/role-router',
  ];
  final literalRoutePattern = RegExp(r'''(["'])(/[^"']+)\1''');
  final violations = <String>[];

  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }

    final normalizedPath = entity.path.replaceAll('\\', '/');
    if (ignoredFiles.contains(normalizedPath)) {
      continue;
    }

    final lines = entity.readAsLinesSync();
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      for (final match in literalRoutePattern.allMatches(line)) {
        final literal = match.group(2);
        if (literal == null) {
          continue;
        }
        final isAppRouteLiteral = routePrefixes.any(literal.startsWith);
        if (!isAppRouteLiteral) {
          continue;
        }
        violations.add('$normalizedPath:${index + 1}: $literal');
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln(
      'OK: não foram encontradas rotas literais fora do AppRoutes.',
    );
    return;
  }

  stderr.writeln(
    'Foram encontradas rotas literais. Use AppRoutes em vez de strings diretas:',
  );
  for (final violation in violations) {
    stderr.writeln(' - $violation');
  }
  exitCode = 1;
}
