import 'package:local_ent_280/features/catalog/data/catalog_repository.dart';
import 'package:local_ent_280/features/rental/data/rental_vehicle_repository.dart';

enum CatalogSearchResultKind { package, vehicle }

class CatalogSearchResult {
  const CatalogSearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
  });

  final String id;
  final String title;
  final String subtitle;
  final CatalogSearchResultKind kind;
}

abstract final class CatalogSearchService {
  static List<CatalogSearchResult> filter({
    required String query,
    required List<CatalogPackage> packages,
    required List<RentalVehicleRecord> vehicles,
  }) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return const [];

    final results = <CatalogSearchResult>[];

    for (final package in packages) {
      if (_matches(normalized, package.title, package.description, package.destination)) {
        results.add(
          CatalogSearchResult(
            id: package.id,
            title: package.title,
            subtitle: package.destination,
            kind: CatalogSearchResultKind.package,
          ),
        );
      }
    }

    for (final vehicle in vehicles) {
      if (_matches(
        normalized,
        vehicle.name,
        vehicle.categoryLabel,
        vehicle.notes,
      )) {
        results.add(
          CatalogSearchResult(
            id: vehicle.id,
            title: vehicle.name,
            subtitle: '${vehicle.categoryLabel} • ${vehicle.pricePerDay}€/dia',
            kind: CatalogSearchResultKind.vehicle,
          ),
        );
      }
    }

    return results;
  }

  static bool _matches(
    String query,
    String title,
    String description,
    String extra,
  ) {
    if (title.toLowerCase().contains(query)) return true;
    if (description.toLowerCase().contains(query)) return true;
    if (extra.toLowerCase().contains(query)) return true;
    return false;
  }
}
