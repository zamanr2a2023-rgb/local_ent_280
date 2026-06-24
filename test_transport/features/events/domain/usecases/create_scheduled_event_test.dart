import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/events/domain/entities/scheduled_event.dart';
import 'package:local_transport/features/events/domain/entities/scheduled_event_draft.dart';
import 'package:local_transport/features/events/domain/entities/scheduled_event_status.dart';
import 'package:local_transport/features/events/domain/entities/scheduled_event_target_type.dart';
import 'package:local_transport/features/events/domain/repositories/scheduled_event_repository.dart';
import 'package:local_transport/features/events/domain/services/scheduled_event_id_generator.dart';
import 'package:local_transport/features/events/domain/usecases/create_scheduled_event.dart';

void main() {
  group('CreateScheduledEvent reminder offsets policy', () {
    test(
      'accepts offsets in range 1..60 and keeps descending unique values',
      () async {
        final repository = _FakeScheduledEventRepository();
        final useCase = CreateScheduledEvent(
          repository,
          const _FixedEventIdGenerator('event_1'),
        );

        final result = await useCase(
          ScheduledEventDraft(
            targetType: ScheduledEventTargetType.driver,
            targetIds: const ['driver_1'],
            title: 'Alerta',
            message: 'Mensagem',
            scheduledAt: DateTime(2026, 3, 5, 12, 0),
            reminderOffsetsMinutes: const [1, 60, 60, 15],
            createdByAdminId: 'admin_1',
            status: ScheduledEventStatus.scheduled,
          ),
        );

        expect(result.reminderOffsetsMinutes, const [60, 15, 1]);
        expect(repository.lastCreated?.reminderOffsetsMinutes, const [
          60,
          15,
          1,
        ]);
      },
    );

    test('applies default offset when list is empty', () async {
      final repository = _FakeScheduledEventRepository();
      final useCase = CreateScheduledEvent(
        repository,
        const _FixedEventIdGenerator('event_2'),
      );

      final result = await useCase(
        ScheduledEventDraft(
          targetType: ScheduledEventTargetType.broadcast,
          title: 'Alerta',
          message: 'Mensagem',
          scheduledAt: DateTime(2026, 3, 5, 12, 0),
          reminderOffsetsMinutes: const [],
          createdByAdminId: 'admin_1',
          status: ScheduledEventStatus.scheduled,
        ),
      );

      expect(result.reminderOffsetsMinutes, const [15]);
    });

    test('rejects offsets greater than 60', () async {
      final repository = _FakeScheduledEventRepository();
      final useCase = CreateScheduledEvent(
        repository,
        const _FixedEventIdGenerator('event_3'),
      );

      await expectLater(
        useCase(
          ScheduledEventDraft(
            targetType: ScheduledEventTargetType.driver,
            targetIds: const ['driver_1'],
            title: 'Alerta',
            message: 'Mensagem',
            scheduledAt: DateTime(2026, 3, 5, 12, 0),
            reminderOffsetsMinutes: const [61],
            createdByAdminId: 'admin_1',
            status: ScheduledEventStatus.scheduled,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rejects more than 5 unique offsets', () async {
      final repository = _FakeScheduledEventRepository();
      final useCase = CreateScheduledEvent(
        repository,
        const _FixedEventIdGenerator('event_4'),
      );

      await expectLater(
        useCase(
          ScheduledEventDraft(
            targetType: ScheduledEventTargetType.driver,
            targetIds: const ['driver_1'],
            title: 'Alerta',
            message: 'Mensagem',
            scheduledAt: DateTime(2026, 3, 5, 12, 0),
            reminderOffsetsMinutes: const [60, 50, 40, 30, 20, 10],
            createdByAdminId: 'admin_1',
            status: ScheduledEventStatus.scheduled,
          ),
        ),
        throwsArgumentError,
      );
    });
  });
}

class _FakeScheduledEventRepository implements ScheduledEventRepository {
  ScheduledEvent? lastCreated;

  @override
  Future<void> createEvent(ScheduledEvent event) async {
    lastCreated = event;
  }

  @override
  Future<List<ScheduledEvent>> fetchBroadcastEvents({
    required DateTime start,
    required DateTime end,
  }) async {
    return const <ScheduledEvent>[];
  }

  @override
  Future<List<ScheduledEvent>> fetchDriverEvents({
    required String driverId,
    required DateTime start,
    required DateTime end,
  }) async {
    return const <ScheduledEvent>[];
  }
}

class _FixedEventIdGenerator implements ScheduledEventIdGenerator {
  const _FixedEventIdGenerator(this.id);

  final String id;

  @override
  String generateEventId() => id;
}
