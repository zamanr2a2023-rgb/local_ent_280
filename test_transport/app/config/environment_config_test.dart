import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/app/config/environment_config.dart';
import 'package:local_transport/app/config/environment_flavor_resolver.dart';

void main() {
  tearDown(EnvironmentConfig.debugResetForTests);

  test('uses native flavor when resolver returns dev', () async {
    await EnvironmentConfig.initialize(
      flavorResolver: const _FakeEnvironmentFlavorResolver('dev'),
    );

    expect(EnvironmentConfig.flavorName, 'dev');
    expect(EnvironmentConfig.isDev, isTrue);
  });

  test('keeps compiled flavor when resolver returns null', () async {
    await EnvironmentConfig.initialize(
      flavorResolver: const _FakeEnvironmentFlavorResolver(null),
    );

    expect(EnvironmentConfig.flavorName, 'prod');
    expect(EnvironmentConfig.isDev, isFalse);
  });
}

class _FakeEnvironmentFlavorResolver implements EnvironmentFlavorResolver {
  const _FakeEnvironmentFlavorResolver(this._flavorName);

  final String? _flavorName;

  @override
  Future<String?> resolveFlavorName() async => _flavorName;
}
