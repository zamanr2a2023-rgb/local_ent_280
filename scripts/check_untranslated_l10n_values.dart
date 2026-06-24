import 'dart:convert';
import 'dart:io';

const String _referencePath = 'lib/l10n/app_pt_PT.arb';
const Map<String, String> _localizedPaths = <String, String>{
  'en': 'lib/l10n/app_en.arb',
  'es': 'lib/l10n/app_es.arb',
};

const List<String> _auditedPrefixes = <String>[
  'clientTrips',
  'clientTripPickup',
  'clientTripLocation',
  'clientTripDestination',
  'clientTripRecent',
  'clientTripTransport',
  'clientDashboardCurrentTripStatus',
  'driverTripsStatus',
  'placeSelection',
  'listFilters',
  'managerHome',
  'managerTrips',
  'managerTrip',
  'managerSupportStatus',
  'clientReservations',
  'clientReservationForm',
  'clientReservationTransport',
  'transportType',
  'reservationStatus',
  'weekday',
];

const Set<String> _auditedExactKeys = <String>{
  'settingsAction',
  'settingsSignOutAction',
  'retryAction',
  'commonEditAction',
  'commonCancelAction',
  'identityReferenceLabel',
  'managerNoPermissionTitle',
  'managerNoPermissionDescription',
  'managerPermissionsRefreshAction',
  'managerPermissionsUnconfiguredDescription',
  'tripParticipantClientLabel',
  'tripParticipantDriverLabel',
  'tripParticipantVehicleLabel',
};

const Set<String> _localeIndependentAllowlist = <String>{
  'listFiltersSortAlphabetical',
  'listFiltersSortReverseAlphabetical',
  'clientReservationFormReminderOffsetLabel',
};

const Set<String> _englishAllowlist = <String>{
  'managerSupportStatusLegacy',
};

const Set<String> _spanishAllowValues = <String>{
  'Aplicar',
  'Editar reserva',
  'Repetir semanalmente',
  'Reservas',
  'Destino',
  'Tipo de transporte',
  'Estado',
  'Filtros',
  'Editar',
  'Cancelar',
  'Cancelar reserva',
  'Reserva cancelada.',
  'Confirmada',
  'Cancelada',
  'Confirmar',
  'Confirmar destino',
  'Transporte',
  'Eventos',
  'Continuar',
  'Favoritos',
  'Cliente',
  'Todas',
  'Próximas',
  'Saldo negativo',
  'Menor saldo',
  'Módulos',
  'Escalado',
  'Nota',
  'Motivo',
  'Código técnico',
  'Sábado',
  'Sáb',
  'Domingo',
  'Dom',
};

void main() {
  final reference = _readArb(_referencePath);
  final auditedKeys = reference.keys.where(_isAuditedKey).toList()..sort();
  final issues = <String>[];

  for (final entry in _localizedPaths.entries) {
    final locale = entry.key;
    final localized = _readArb(entry.value);
    for (final key in auditedKeys) {
      final referenceValue = reference[key];
      final localizedValue = localized[key];
      if (referenceValue is! String || localizedValue is! String) {
        continue;
      }
      if (localizedValue != referenceValue) {
        continue;
      }
      if (_localeIndependentAllowlist.contains(key)) {
        continue;
      }
      if (locale == 'en' && _englishAllowlist.contains(key)) {
        continue;
      }
      if (locale == 'es' && _spanishAllowValues.contains(localizedValue)) {
        continue;
      }
      issues.add('[$locale] Untranslated value for "$key": "$localizedValue"');
    }
  }

  if (issues.isNotEmpty) {
    stderr.writeln('Untranslated l10n guard failed:');
    for (final issue in issues) {
      stderr.writeln(' - $issue');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Untranslated l10n guard passed for audited keys.');
}

Map<String, dynamic> _readArb(String path) {
  final file = File(path);
  final decoded = jsonDecode(file.readAsStringSync());
  return decoded as Map<String, dynamic>;
}

bool _isAuditedKey(String key) {
  if (key.startsWith('@')) {
    return false;
  }
  if (_auditedExactKeys.contains(key)) {
    return true;
  }
  for (final prefix in _auditedPrefixes) {
    if (key.startsWith(prefix)) {
      return true;
    }
  }
  return false;
}
