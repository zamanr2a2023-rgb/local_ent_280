import 'package:local_ent_280/core/constants/app_assets.dart';

class DriverRecentTrip {
  const DriverRecentTrip({
    required this.passengerName,
    required this.destination,
    required this.price,
    required this.hoursAgo,
  });

  final String passengerName;
  final String destination;
  final String price;
  final int hoursAgo;
}

/// Driver home screen demo data (locale-neutral values).
abstract final class DriverHomeData {
  static const profileAvatarImage = AppAssets.driverEnRouteProfileAvatarImage;
  static const mapImage = AppAssets.driverEnRouteMapImage;

  static const vehicleModel = 'Mercedes-Benz EQE';
  static const licensePlate = 'AA-00-XX';
  static const batteryLevel = '82%';

  static const todayEarnings = '€142.50';
  static const tripsCount = '14';
  static const distanceValue = '186 km';

  static const recentTrips = [
    DriverRecentTrip(
      passengerName: 'Ana Martins',
      destination: 'Humberto Delgado Airport',
      price: '€14.50',
      hoursAgo: 2,
    ),
    DriverRecentTrip(
      passengerName: 'Carlos Mendes',
      destination: 'Parque das Nações',
      price: '€9.80',
      hoursAgo: 5,
    ),
  ];
}

/// Incoming trip request demo data.
abstract final class DriverTripRequestData {
  static const pickupAddress = 'Avenida da Liberdade, 110';
  static const pickupDistance = '2.8 km';

  static const destinationAddress = 'Humberto Delgado Airport';
  static const destinationInfo = '8.2 km • 15 min';

  static const passengerName = 'Ana Martins';
  static const passengerRating = '4.9';
  static const passengerPhoto = AppAssets.driverFoundDriverImage;
  static const fare = '€14.50';

  static const acceptCountdownSeconds = 12;
}

/// Post-acceptance trip demo data.
abstract final class DriverTripAcceptedData {
  static const passengerName = 'João Silva';
  static const pickupAddress = 'Rua Augusta, Lisbon';
  static const eta = '5 min';

  static const mapImage = AppAssets.driverEnRouteMapImage;
}

/// Active trip demo data.
abstract final class DriverActiveTripData {
  static const navigationDistance = '450m';
  static const destinationAddress = 'Rua de São Bento, 120';

  static const passengerName = 'Ana Margarida Silva';
  static const passengerRating = '4.9';
  static const passengerPhoto = AppAssets.driverFoundDriverImage;

  static const estimatedTime = '12 min';
  static const distance = '3.2 km';

  static const mapImage = AppAssets.tripInProgressMapImage;
}
