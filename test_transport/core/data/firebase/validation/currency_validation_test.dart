import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/data/firebase/validation/firestore_write_action.dart';
import 'package:local_transport/core/data/firebase/validation/validators/audit_entry_validator.dart';
import 'package:local_transport/core/data/firebase/validation/validators/cancellation_policy_validator.dart';
import 'package:local_transport/core/data/firebase/validation/validators/event_validator.dart';
import 'package:local_transport/core/data/firebase/validation/validators/reservation_validator.dart';
import 'package:local_transport/core/data/firebase/validation/validators/tariff_validator.dart';
import 'package:local_transport/core/data/firebase/validation/validators/transport_type_validator.dart';
import 'package:local_transport/core/data/firebase/validation/validators/trip_package_validator.dart';
import 'package:local_transport/core/data/firebase/validation/validators/trip_validator.dart';
import 'package:local_transport/core/data/firebase/validation/validators/user_validator.dart';

void main() {
  const legacyWeekdayRuleType =
      'day'
      '_of_'
      'week';
  const legacyWeekdaysField =
      'days'
      'Of'
      'Week';

  group('UserValidator uiCurrency', () {
    final validator = UserValidator();

    test('accepts partial uiCurrency update without role', () {
      final result = validator.validateWrite(
        'users/user_1',
        {
          'uiCurrency': 'USD',
          'updatedAt': DateTime(2026, 3, 5),
        },
        FirestoreWriteAction.update,
      );

      expect(result.isValid, isTrue);
    });

    test('accepts allowed uiCurrency values on update', () {
      final result = validator.validateWrite(
        'users/user_1',
        {
          'role': 'client',
          'uiCurrency': 'USD',
          'updatedAt': DateTime(2026, 3, 5),
        },
        FirestoreWriteAction.update,
      );

      expect(result.isValid, isTrue);
    });

    test('rejects unsupported uiCurrency', () {
      final result = validator.validateWrite(
        'users/user_1',
        {
          'role': 'client',
          'uiCurrency': 'BRL',
          'updatedAt': DateTime(2026, 3, 5),
        },
        FirestoreWriteAction.update,
      );

      expect(result.isValid, isFalse);
      expect(
        result.criticalIssues.any((issue) => issue.contains('uiCurrency')),
        isTrue,
      );
    });

    test('requires role on create', () {
      final result = validator.validateWrite(
        'users/user_1',
        {
          'name': 'Teste',
          'phone': '912345678',
          'isActive': true,
          'createdAt': DateTime(2026, 3, 5),
          'updatedAt': DateTime(2026, 3, 5),
        },
        FirestoreWriteAction.create,
      );

      expect(result.isValid, isFalse);
      expect(
        result.criticalIssues.any((issue) => issue.contains('role em falta')),
        isTrue,
      );
    });

    test('accepts documented manager permissions mt and tp', () {
      final result = validator.validateRead(
        'users/user_manager',
        {
          'role': 'manager',
          'name': 'Gestor',
          'phone': '+351910000000',
          'isActive': true,
          'createdAt': DateTime(2026, 3, 5),
          'updatedAt': DateTime(2026, 3, 5),
          'managerPermissions': {
            'mt': true,
            'tp': true,
          },
        },
      );

      expect(result.isValid, isTrue);
      expect(result.hasWarnings, isFalse);
    });
  });

  group('CancellationPolicyValidator currency config', () {
    final validator = CancellationPolicyValidator();

    test('accepts valid config/currency create payload', () {
      final result = validator.validateWrite(
        'config/currency',
        {
          'cveToEur': '0.00907',
          'cveToUsd': '0.0101',
          'updatedAt': DateTime(2026, 3, 5),
          'updatedBy': 'admin_1',
          'version': 1,
        },
        FirestoreWriteAction.create,
      );

      expect(result.isValid, isTrue);
    });

    test('rejects config/currency create payload missing required fields', () {
      final result = validator.validateWrite(
        'config/currency',
        {
          'cveToEur': '0.00907',
          'updatedAt': DateTime(2026, 3, 5),
          'updatedBy': 'admin_1',
        },
        FirestoreWriteAction.create,
      );

      expect(result.isValid, isFalse);
      expect(result.criticalIssues.isNotEmpty, isTrue);
    });
  });

  group('Reminder offset validators', () {
    test('EventValidator write rejects offsets above 60', () {
      final validator = EventValidator();
      final result = validator.validateWrite(
        'events/event_1',
        {
          'reminderOffsetsMinutes': <int>[61],
        },
        FirestoreWriteAction.update,
      );

      expect(result.isValid, isFalse);
      expect(
        result.criticalIssues.any(
          (issue) => issue.contains('reminderOffsetsMinutes'),
        ),
        isTrue,
      );
    });

    test('EventValidator read keeps legacy offsets >60 as warning', () {
      final validator = EventValidator();
      final result = validator.validateRead(
        'events/event_legacy',
        {
          'targetType': 'driver',
          'title': 'Alerta',
          'message': 'Mensagem',
          'scheduledAt': DateTime(2026, 3, 5, 12, 0),
          'createdByAdminId': 'admin_1',
          'status': 'scheduled',
          'createdAt': DateTime(2026, 3, 5, 10, 0),
          'updatedAt': DateTime(2026, 3, 5, 10, 0),
          'targetIds': const ['driver_1'],
          'reminderOffsetsMinutes': const <int>[120],
        },
      );

      expect(result.isValid, isTrue);
      expect(result.hasWarnings, isTrue);
    });

    test('ReservationValidator requires internal_staff creator metadata', () {
      final validator = ReservationValidator();
      final result = validator.validateWrite(
        'reservations/res_internal',
        {
          'source': 'internal_staff',
          'clientId': 'client_1',
          'assignedDriverId': 'driver_1',
          'scheduledAt': DateTime(2026, 3, 5, 12, 0),
          'scheduledDayKey': '2026-03-05',
          'scheduledMinutesLocal': 720,
          'status': 'scheduled',
          'pickup': {
            'latitude': 38.7,
            'longitude': -9.1,
            'address': 'Origem',
          },
          'destination': {
            'latitude': 38.71,
            'longitude': -9.12,
            'address': 'Destino',
          },
          'transportType': {
            'id': 'standard',
            'name': 'Standard',
          },
          'createdAt': DateTime(2026, 3, 5, 10, 0),
          'updatedAt': DateTime(2026, 3, 5, 10, 0),
        },
        FirestoreWriteAction.create,
      );

      expect(result.isValid, isFalse);
      expect(
        result.criticalIssues.any(
          (issue) => issue.contains('createdByUserId'),
        ),
        isTrue,
      );
    });

    test('ReservationValidator accepts package source without createdBy', () {
      final validator = ReservationValidator();
      final result = validator.validateWrite(
        'reservations/res_package',
        {
          'source': 'package',
          'clientId': 'client_1',
          'assignedDriverId': 'driver_1',
          'scheduledAt': DateTime(2026, 3, 5, 12, 0),
          'scheduledDayKey': '2026-03-05',
          'scheduledMinutesLocal': 720,
          'status': 'scheduled',
          'pickup': {
            'latitude': 38.7,
            'longitude': -9.1,
            'address': 'Origem',
          },
          'destination': {
            'latitude': 38.71,
            'longitude': -9.12,
            'address': 'Destino',
          },
          'transportType': {
            'id': 'standard',
            'name': 'Standard',
          },
          'vehicleId': 'vehicle_1',
          'packageId': 'package_1',
          'packageBookingId': 'booking_1',
          'createdAt': DateTime(2026, 3, 5, 10, 0),
          'updatedAt': DateTime(2026, 3, 5, 10, 0),
        },
        FirestoreWriteAction.create,
      );

      expect(result.isValid, isTrue);
    });
  });

  group('AuditEntryValidator actor identity', () {
    final validator = AuditEntryValidator();

    test('accepts create payload with adminEmail and no adminName', () {
      final result = validator.validateWrite(
        'audit/audit_1',
        {
          'actionType': 'tariff_edit',
          'adminId': 'admin_1',
          'adminEmail': 'admin@example.com',
          'reason': 'Atualização de tarifário',
          'before': <String, dynamic>{},
          'after': <String, dynamic>{},
          'createdAt': DateTime(2026, 3, 10),
        },
        FirestoreWriteAction.create,
      );

      expect(result.isValid, isTrue);
    });
  });

  group('TariffValidator multiplier rules', () {
    final validator = TariffValidator();

    test('accepts holiday multiplier rule', () {
      final result = validator.validateWrite(
        'tariffs/admin_default',
        {
          'multiplierRules': [
            {
              'id': 'holiday',
              'type': 'holiday',
              'multiplier': 1.3,
              'holidayDates': ['2026-12-25'],
            },
          ],
        },
        FirestoreWriteAction.update,
      );

      expect(result.isValid, isTrue);
    });

    test('rejects legacy weekday multiplier rule', () {
      final result = validator.validateWrite(
        'tariffs/admin_default',
        {
          'multiplierRules': [
            {
              'id': legacyWeekdayRuleType,
              'type': legacyWeekdayRuleType,
              'multiplier': 1.2,
              legacyWeekdaysField: [1, 5],
            },
          ],
        },
        FirestoreWriteAction.update,
      );

      expect(result.isValid, isFalse);
      expect(
        result.criticalIssues.any(
          (issue) => issue.contains('semanal legado não é suportado'),
        ),
        isTrue,
      );
    });
  });

  group('TripValidator post-charge extension duration', () {
    final validator = TripValidator();

    test('warns when requestedMinutes is below the active range', () {
      final result = validator.validateWrite(
        'trips/trip_1',
        {
          'postChargeExtension': {
            'currentCycle': {
              'requestedMinutes': 10,
              'chargeStatus': 'pending',
            },
            'history': const [],
          },
        },
        FirestoreWriteAction.update,
      );

      expect(result.hasWarnings, isTrue);
      expect(
        result.warnings.any(
          (issue) =>
              issue.contains('requestedMinutes deve estar entre 15 e 60'),
        ),
        isTrue,
      );
    });
  });

  group('Trip package legacy multiplier reads', () {
    test('TripPackageValidator warns instead of failing legacy templates', () {
      final validator = TripPackageValidator();
      final result = validator.validateRead(
        'tripPackages/package_legacy',
        {
          'name': 'Tarrafal',
          'photoUrl': 'https://example.com/tarrafal.jpg',
          'description': 'Praia e passeio.',
          'destination': {
            'latitude': 15.2788,
            'longitude': -23.7519,
            'address': 'Tarrafal',
          },
          'price': {
            'amountMinor': 2500,
            'currency': 'EUR',
          },
          'allowedTransportTypes': const [
            {
              'id': 'standard',
              'name': 'Standard',
            },
          ],
          'isActive': true,
          'snapshotVersion': 1,
          'createdAt': DateTime(2026, 3, 5),
          'updatedAt': DateTime(2026, 3, 5),
        },
      );

      expect(result.isValid, isTrue);
      expect(result.hasWarnings, isTrue);
    });

    test(
      'TripPackageValidator still rejects new templates without multiplier',
      () {
        final validator = TripPackageValidator();
        final result = validator.validateWrite(
          'tripPackages/package_new',
          {
            'name': 'Tarrafal',
            'photoUrl': 'https://example.com/tarrafal.jpg',
            'description': 'Praia e passeio.',
            'destination': {
              'latitude': 15.2788,
              'longitude': -23.7519,
              'address': 'Tarrafal',
            },
            'price': {
              'amountMinor': 2500,
              'currency': 'EUR',
            },
            'allowedTransportTypes': const [
              {
                'id': 'standard',
                'name': 'Standard',
              },
            ],
            'isActive': true,
            'snapshotVersion': 1,
            'createdAt': DateTime(2026, 3, 5),
            'updatedAt': DateTime(2026, 3, 5),
          },
          FirestoreWriteAction.create,
        );

        expect(result.isValid, isFalse);
        expect(
          result.criticalIssues.any(
            (issue) => issue.contains('packagePriceMultiplierBasisPoints'),
          ),
          isTrue,
        );
      },
    );

    test('TransportTypeValidator warns instead of failing legacy types', () {
      final validator = TransportTypeValidator();
      final result = validator.validateRead(
        'transport_types/standard',
        {
          'name': 'Standard',
          'description': '',
          'createdAt': DateTime(2026, 3, 5),
          'updatedAt': DateTime(2026, 3, 5),
        },
      );

      expect(result.isValid, isTrue);
      expect(result.hasWarnings, isTrue);
    });
  });
}
