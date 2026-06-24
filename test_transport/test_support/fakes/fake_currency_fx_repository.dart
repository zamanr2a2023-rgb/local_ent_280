import 'dart:async';

import 'package:local_transport/features/currency/domain/entities/currency_fx_config.dart';
import 'package:local_transport/features/currency/domain/repositories/currency_fx_repository.dart';

class FakeCurrencyFxRepository implements CurrencyFxRepository {
  FakeCurrencyFxRepository({CurrencyFxConfig? initialConfig})
    : _config = initialConfig;

  CurrencyFxConfig? _config;
  final StreamController<CurrencyFxConfig?> _controller =
      StreamController<CurrencyFxConfig?>.broadcast();

  @override
  Future<CurrencyFxConfig?> fetchConfig() async => _config;

  @override
  Future<void> saveConfig(CurrencyFxConfigDraft draft) async {
    _config = CurrencyFxConfig(
      cveToEur: draft.cveToEur,
      cveToUsd: draft.cveToUsd,
      updatedBy: draft.updatedBy,
      updatedAt: DateTime.now(),
      version: draft.version,
    );
    _controller.add(_config);
  }

  @override
  Stream<CurrencyFxConfig?> watchConfig() async* {
    yield _config;
    yield* _controller.stream;
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
