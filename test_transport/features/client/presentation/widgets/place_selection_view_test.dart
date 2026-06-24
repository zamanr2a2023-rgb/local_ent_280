import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/client/domain/entities/place_details.dart';
import 'package:local_transport/features/client/presentation/widgets/place_selection_view.dart';
import 'package:local_transport/l10n/app_localizations.dart';

void main() {
  testWidgets('removes a recent destination from the recent list', (
    tester,
  ) async {
    const recentDestination = PlaceDetails(
      latitude: 38.7223,
      longitude: -9.1393,
      formattedAddress: 'Lisboa',
    );
    PlaceDetails? removedDestination;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt', 'PT'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PlaceSearchPanel(
            controller: TextEditingController(),
            focusNode: FocusNode(),
            searchLabel: 'Destino',
            searchHint: 'Pesquisar',
            emptyMessage: 'Sem destinos',
            isLoadingSuggestions: false,
            isLoadingDetails: false,
            suggestions: const [],
            showRecentDestinations: true,
            recentDestinations: const [recentDestination],
            removableRecentDestinationKeys: const {
              '38.72230|-9.13930|lisboa',
            },
            recentDestinationsLabel: 'Destinos recentes',
            onQueryChanged: (_) {},
            onSuggestionSelected: (_) {},
            onRecentDestinationSelected: (_) {},
            onRecentDestinationRemoved: (destination) {
              removedDestination = destination;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(
      removedDestination?.formattedAddress,
      recentDestination.formattedAddress,
    );
  });

  testWidgets('toggles favorite for a local destination', (tester) async {
    const recentDestination = PlaceDetails(
      latitude: 38.7223,
      longitude: -9.1393,
      formattedAddress: 'Lisboa',
    );
    PlaceDetails? favoriteDestination;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt', 'PT'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PlaceSearchPanel(
            controller: TextEditingController(),
            focusNode: FocusNode(),
            searchLabel: 'Destino',
            searchHint: 'Pesquisar',
            emptyMessage: 'Sem destinos',
            isLoadingSuggestions: false,
            isLoadingDetails: false,
            suggestions: const [],
            showRecentDestinations: true,
            recentDestinations: const [recentDestination],
            recentDestinationsLabel: 'Destinos recentes',
            onQueryChanged: (_) {},
            onSuggestionSelected: (_) {},
            onRecentDestinationSelected: (_) {},
            onFavoriteDestinationToggled: (destination) {
              favoriteDestination = destination;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.star_outline));
    await tester.pumpAndSettle();

    expect(
      favoriteDestination?.formattedAddress,
      recentDestination.formattedAddress,
    );
  });

  testWidgets('favorites filter shows only favorite destinations', (
    tester,
  ) async {
    const favoriteDestination = PlaceDetails(
      latitude: 38.7223,
      longitude: -9.1393,
      formattedAddress: 'Lisboa',
    );
    const recentDestination = PlaceDetails(
      latitude: 41.1579,
      longitude: -8.6291,
      formattedAddress: 'Porto',
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt', 'PT'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PlaceSearchPanel(
            controller: TextEditingController(),
            focusNode: FocusNode(),
            searchLabel: 'Destino',
            searchHint: 'Pesquisar',
            emptyMessage: 'Sem destinos',
            isLoadingSuggestions: false,
            isLoadingDetails: false,
            suggestions: const [],
            showRecentDestinations: true,
            recentDestinations: const [
              favoriteDestination,
              recentDestination,
            ],
            favoriteDestinationKeys: const {
              '38.72230|-9.13930|lisboa',
            },
            recentDestinationsLabel: 'Destinos recentes',
            onQueryChanged: (_) {},
            onSuggestionSelected: (_) {},
            onRecentDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();

    expect(find.text('Lisboa'), findsOneWidget);
    expect(find.text('Porto'), findsNothing);
  });
}
