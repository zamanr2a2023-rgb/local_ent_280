import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/client/domain/entities/transport_type.dart';
import 'package:local_transport/features/client/domain/repositories/transport_type_repository.dart';
import 'package:local_transport/features/client/domain/usecases/get_default_transport_type.dart';
import 'package:local_transport/features/client/domain/usecases/get_transport_types.dart';
import 'package:local_transport/features/client/presentation/providers/transport_step_provider.dart';

void main() {
  test(
    'shows the standard card when no remote transport types exist',
    () async {
      final controller = _buildController(remoteTypes: const <TransportType>[]);

      await controller.loadTypes(null);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.types, <TransportType>[_standard]);
      expect(controller.state.selectedType, _standard);
      expect(controller.state.fallbackType, _standard);
      expect(controller.state.shouldApplyFallback, isFalse);
      expect(controller.state.failure, isNull);
    },
  );

  test('keeps created remote transport types visible', () async {
    const van = TransportType(
      id: 'van',
      name: 'Van',
      description: 'Mais espaço para grupos.',
      packagePriceMultiplierBasisPoints: 12000,
    );
    final controller = _buildController(
      remoteTypes: const <TransportType>[van],
    );

    await controller.loadTypes(null);

    expect(controller.state.types, const <TransportType>[van]);
    expect(controller.state.selectedType, van);
    expect(controller.state.fallbackType, isNull);
  });

  test('shows standard as a recoverable option when loading fails', () async {
    final controller = _buildController(loadError: Exception('offline'));

    await controller.loadTypes(null);

    expect(controller.state.types, <TransportType>[_standard]);
    expect(controller.state.selectedType, _standard);
    expect(controller.state.failure, TransportStepFailure.loadFailed);
  });
}

TransportStepController _buildController({
  List<TransportType> remoteTypes = const <TransportType>[],
  Exception? loadError,
}) {
  final repository = _FakeTransportTypeRepository(
    remoteTypes: remoteTypes,
    loadError: loadError,
  );
  return TransportStepController(
    GetTransportTypes(repository),
    GetDefaultTransportType(repository),
  );
}

const _standard = TransportType(
  id: 'standard',
  name: 'Standard',
  description: '',
  packagePriceMultiplierBasisPoints: 10000,
);

class _FakeTransportTypeRepository implements TransportTypeRepository {
  const _FakeTransportTypeRepository({
    required this.remoteTypes,
    required this.loadError,
  });

  final List<TransportType> remoteTypes;
  final Exception? loadError;

  @override
  Future<List<TransportType>> fetchTransportTypes() async {
    final error = loadError;
    if (error != null) {
      throw error;
    }
    return remoteTypes;
  }

  @override
  Future<TransportType> getDefaultTransportType() async {
    return _standard;
  }
}
