/// Dummy destinations/services for premium home search.
class PremiumSearchItem {
  const PremiumSearchItem({
    required this.title,
    required this.subtitle,
    required this.keywords,
  });

  final String title;
  final String subtitle;
  final List<String> keywords;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return false;
    if (title.toLowerCase().contains(q)) return true;
    if (subtitle.toLowerCase().contains(q)) return true;
    return keywords.any((k) => k.contains(q));
  }
}

abstract final class PremiumSearchItems {
  static const List<PremiumSearchItem> all = [
    PremiumSearchItem(
      title: 'Tesla Model 3 Performance',
      subtitle: 'Premium Rental • Lisbon Airport',
      keywords: ['tesla', 'model', 'performance', 'rental', 'car', 'electric'],
    ),
    PremiumSearchItem(
      title: 'Lisbon Airport (LIS)',
      subtitle: 'Vehicle pickup and drop-off',
      keywords: ['lisbon', 'airport', 'lis', 'pickup', 'drop-off'],
    ),
    PremiumSearchItem(
      title: 'Car Rental',
      subtitle: 'Reservation review • 5 days',
      keywords: ['rental', 'vehicle', 'reservation', 'car'],
    ),
    PremiumSearchItem(
      title: 'Porto — Campanhã Station',
      subtitle: 'Destination and mobility services',
      keywords: ['porto', 'campanha', 'train', 'destination'],
    ),
    PremiumSearchItem(
      title: 'Fast Delivery',
      subtitle: 'Grocery & Pharmacy',
      keywords: ['delivery', 'grocery', 'pharmacy', 'shopping'],
    ),
    PremiumSearchItem(
      title: 'Jet Ski',
      subtitle: 'Premium marina rental',
      keywords: ['jetski', 'jet', 'ski', 'marina'],
    ),
    PremiumSearchItem(
      title: 'Island Guide',
      subtitle: 'Exclusive experiences and itineraries',
      keywords: ['islands', 'guide', 'explore', 'itinerary'],
    ),
  ];

  static List<PremiumSearchItem> filter(String query) {
    if (query.trim().isEmpty) return const [];
    return all.where((item) => item.matches(query)).toList();
  }
}
