class TripLocation {
  const TripLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String address;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toFirestore() => {
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory TripLocation.fromFirestore(Map<String, dynamic> data) {
    return TripLocation(
      address: data['address'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
    );
  }
}
