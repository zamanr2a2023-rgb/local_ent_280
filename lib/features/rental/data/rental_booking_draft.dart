/// Holds the selected vehicle rental context between search → review → Firebase write.
class RentalBookingDraft {
  RentalBookingDraft._();

  static final RentalBookingDraft instance = RentalBookingDraft._();

  String? vehicleId;
  String? vehicleLabel;
  String? vehicleCategory;
  String? pickupLocation;
  String? returnLocation;
  DateTime? pickupDate;
  DateTime? returnDate;
  double pricePerDayEur = 0;
  bool fullInsurance = false;

  String? vehicleImageUrl;
  int? vehicleSeats;
  String? vehicleTransmission;
  bool vehicleIsElectric = false;
  bool vehicleIsPremium = false;

  void setVehicle({
    required String id,
    required String label,
    String? category,
    double? pricePerDayEur,
    String? imageUrl,
    int? seats,
    String? transmission,
    bool? isElectric,
    bool? isPremium,
  }) {
    vehicleId = id;
    vehicleLabel = label;
    vehicleCategory = category;
    if (pricePerDayEur != null) {
      this.pricePerDayEur = pricePerDayEur;
    }
    vehicleImageUrl = imageUrl;
    vehicleSeats = seats;
    vehicleTransmission = transmission;
    if (isElectric != null) vehicleIsElectric = isElectric;
    if (isPremium != null) vehicleIsPremium = isPremium;
  }

  void setRentalSchedule({
    String? pickup,
    String? returnLocation,
    DateTime? pickupDate,
    DateTime? returnDate,
  }) {
    if (pickup != null && pickup.trim().isNotEmpty) {
      pickupLocation = pickup.trim();
    }
    if (returnLocation != null && returnLocation.trim().isNotEmpty) {
      this.returnLocation = returnLocation.trim();
    }
    if (pickupDate != null) this.pickupDate = pickupDate;
    if (returnDate != null) this.returnDate = returnDate;
  }

  void clear() {
    vehicleId = null;
    vehicleLabel = null;
    vehicleCategory = null;
    pickupLocation = null;
    returnLocation = null;
    pickupDate = null;
    returnDate = null;
    pricePerDayEur = 0;
    fullInsurance = false;
    vehicleImageUrl = null;
    vehicleSeats = null;
    vehicleTransmission = null;
    vehicleIsElectric = false;
    vehicleIsPremium = false;
  }

  int get rentalDays {
    final start = pickupDate;
    final end = returnDate;
    if (start == null || end == null) return 1;
    final days = end.difference(start).inDays;
    return days < 1 ? 1 : days;
  }

  double get estimatedTotalEur {
    final base = pricePerDayEur * rentalDays;
    return fullInsurance ? base + 15 : base;
  }
}
