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

  void setVehicle({
    required String id,
    required String label,
    String? category,
    double? pricePerDayEur,
  }) {
    vehicleId = id;
    vehicleLabel = label;
    vehicleCategory = category;
    if (pricePerDayEur != null) {
      this.pricePerDayEur = pricePerDayEur;
    }
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
