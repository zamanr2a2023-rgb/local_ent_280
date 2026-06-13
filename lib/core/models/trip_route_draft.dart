/// Pickup + destination entered on the home screen.
class TripRouteDraft {
  const TripRouteDraft({
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationAddress,
    this.destinationPlaceId,
    this.destinationLat,
    this.destinationLng,
  });

  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String destinationAddress;
  final String? destinationPlaceId;
  final double? destinationLat;
  final double? destinationLng;

  /// Demo Lisbon route used by legacy navigation entry points.
  factory TripRouteDraft.demo() {
    return const TripRouteDraft(
      pickupAddress: 'Avenida da Liberdade, 110',
      pickupLat: 38.7201,
      pickupLng: -9.1458,
      destinationAddress: 'Lisbon Airport (LIS)',
      destinationLat: 38.7756,
      destinationLng: -9.1354,
    );
  }
}
