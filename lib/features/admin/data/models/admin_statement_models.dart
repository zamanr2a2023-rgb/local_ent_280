class ClientStatementEntry {
  const ClientStatementEntry({
    required this.date,
    required this.description,
    required this.debitMinor,
    required this.creditMinor,
    required this.reference,
  });

  final DateTime? date;
  final String description;
  final int debitMinor;
  final int creditMinor;
  final String reference;
}

class ClientStatementSummary {
  const ClientStatementSummary({
    required this.clientId,
    required this.clientName,
    required this.currentBalanceMinor,
    required this.totalDebitsMinor,
    required this.totalCreditsMinor,
    required this.entries,
  });

  static const empty = ClientStatementSummary(
    clientId: '',
    clientName: '',
    currentBalanceMinor: 0,
    totalDebitsMinor: 0,
    totalCreditsMinor: 0,
    entries: [],
  );

  final String clientId;
  final String clientName;
  final int currentBalanceMinor;
  final int totalDebitsMinor;
  final int totalCreditsMinor;
  final List<ClientStatementEntry> entries;
}

class DriverStatementEntry {
  const DriverStatementEntry({
    required this.date,
    required this.tripId,
    required this.destination,
    required this.distanceKm,
    required this.minutes,
    required this.grossMinor,
    required this.status,
  });

  final DateTime? date;
  final String tripId;
  final String destination;
  final double distanceKm;
  final int minutes;
  final int grossMinor;
  final String status;
}

class DriverStatementSummary {
  const DriverStatementSummary({
    required this.driverId,
    required this.driverName,
    required this.tripCount,
    required this.totalDistanceKm,
    required this.totalMinutes,
    required this.totalGrossMinor,
    required this.entries,
  });

  static const empty = DriverStatementSummary(
    driverId: '',
    driverName: '',
    tripCount: 0,
    totalDistanceKm: 0,
    totalMinutes: 0,
    totalGrossMinor: 0,
    entries: [],
  );

  final String driverId;
  final String driverName;
  final int tripCount;
  final double totalDistanceKm;
  final int totalMinutes;
  final int totalGrossMinor;
  final List<DriverStatementEntry> entries;
}
