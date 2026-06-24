import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/core/domain/value_objects/money.dart';
import 'package:local_transport/core/services/currency_formatter.dart';
import 'package:local_transport/features/client/presentation/widgets/client_trip_preview_summary_sheet.dart';
import 'package:local_transport/features/client/presentation/widgets/trip_preview_price_details_panel.dart';
import 'package:local_transport/features/pricing/domain/entities/tariff.dart';
import 'package:local_transport/features/pricing/domain/entities/tariff_penalty_fees.dart';
import 'package:local_transport/features/pricing/domain/entities/trip_price_breakdown.dart';
import 'package:local_transport/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'summary sheet shows essential info and recalculate only when stale',
    (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClientTripPreviewSummarySheet(
              pickupAddress: 'Praça',
              destinationAddress: 'Aeroporto',
              transportType: 'Standard',
              distanceText: '8.4 km',
              etaText: '18 min',
              priceText: '€12,30',
              priceLabel: 'Preço estimado total',
              summaryTitle: 'Resumo da viagem',
              pickupLabel: 'Recolha',
              destinationLabel: 'Destino',
              transportTypeLabel: 'Tipo de transporte',
              distanceLabel: 'Distância estimada',
              etaLabel: 'Duração estimada',
              contextText: 'Estimativa baseada na rota sugerida.',
              requestTimeLabel: 'Horário do pedido',
              requestTimeText: 'Hoje, 10:30',
              confirmLabel: 'Confirmar pedido de viagem',
              errorMessage: null,
              onConfirm: () {},
            ),
          ),
        ),
      );

      expect(find.text('Preço estimado total'), findsOneWidget);
      expect(find.text('Distância estimada'), findsOneWidget);
      expect(find.text('Duração estimada'), findsOneWidget);
      expect(find.text('Horário do pedido'), findsOneWidget);
      expect(find.text('Recalcular'), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClientTripPreviewSummarySheet(
              pickupAddress: 'Praça',
              destinationAddress: 'Aeroporto',
              transportType: 'Standard',
              distanceText: '8.4 km',
              etaText: '18 min',
              priceText: '€12,30',
              priceLabel: 'Preço estimado total',
              summaryTitle: 'Resumo da viagem',
              pickupLabel: 'Recolha',
              destinationLabel: 'Destino',
              transportTypeLabel: 'Tipo de transporte',
              distanceLabel: 'Distância estimada',
              etaLabel: 'Duração estimada',
              contextText: 'Estimativa baseada na rota sugerida.',
              requestTimeLabel: 'Horário do pedido',
              requestTimeText: 'Hoje, 10:30',
              updatedAgoText: 'Atualizado há 2 min',
              recalculateLabel: 'Recalcular',
              confirmLabel: 'Confirmar pedido de viagem',
              errorMessage: null,
              onConfirm: () {},
              onRecalculate: () {},
            ),
          ),
        ),
      );

      expect(find.text('Atualizado há 2 min'), findsOneWidget);
      expect(find.text('Recalcular'), findsOneWidget);
    },
  );

  testWidgets('price details panel expands and collapses', (tester) async {
    final tariff = Tariff(
      id: 'tariff_1',
      baseByTransportType: const {
        'standard': Money(amountMinor: 200, currency: CurrencyCode.eur),
      },
      perKm: const Money(amountMinor: 150, currency: CurrencyCode.eur),
      perWaitMinute: const Money(amountMinor: 5, currency: CurrencyCode.eur),
      penaltyFees: const TariffPenaltyFees.empty(),
    );
    final breakdown = TripPriceBreakdown(
      baseMinor: 200,
      distanceMinor: 1260,
      subtotalMinor: 1460,
      multiplier: 1.2,
      multiplierId: 'transport:standard|time:time_range_1|holiday:none',
      transportTypeId: 'standard',
      timeRangeRuleId: 'time_range_1',
      timeRangeMultiplier: 1.2,
      holidayRuleId: null,
      holidayMultiplier: null,
      evaluationTimestamp: DateTime.utc(2026, 3, 20, 8, 30),
      evaluationTimeZone: 'Europe/Lisbon',
      multiplierChargeMinor: 292,
      totalMinor: 1752,
      distanceKm: 8.4,
      durationMinutes: 18,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt', 'PT'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TripPreviewPriceDetailsPanel(
                breakdown: breakdown,
                tariff: tariff,
                multiplierLabel: 'Faixa horária',
                locale: 'pt_PT',
                moneyFormatter: euroCurrencyFormatter,
                l10n: AppLocalizations.of(context),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Ver detalhe do preço'), findsOneWidget);
    expect(find.text('Tarifa base do tipo selecionado'), findsNothing);

    await tester.tap(find.text('Ver detalhe do preço'));
    await tester.pumpAndSettle();

    expect(find.text('Tarifa base do tipo selecionado'), findsOneWidget);
    expect(
      find.text('Ajuste ao preço por Faixa horária (×1,20)'),
      findsOneWidget,
    );
    expect(find.text('Total estimado'), findsOneWidget);

    await tester.tap(find.text('Ver detalhe do preço'));
    await tester.pumpAndSettle();

    expect(find.text('Tarifa base do tipo selecionado'), findsNothing);
  });

  testWidgets(
    'price details panel hides multiplier row when adjustment is neutral',
    (tester) async {
      final tariff = Tariff(
        id: 'tariff_1',
        baseByTransportType: const {
          'standard': Money(amountMinor: 200, currency: CurrencyCode.eur),
        },
        perKm: const Money(amountMinor: 150, currency: CurrencyCode.eur),
        perWaitMinute: const Money(amountMinor: 5, currency: CurrencyCode.eur),
        penaltyFees: const TariffPenaltyFees.empty(),
      );
      final breakdown = TripPriceBreakdown(
        baseMinor: 200,
        distanceMinor: 1260,
        subtotalMinor: 1460,
        multiplier: 1,
        multiplierId: 'transport:standard|time:time_range_1|holiday:none',
        transportTypeId: 'standard',
        timeRangeRuleId: 'time_range_1',
        timeRangeMultiplier: 1,
        holidayRuleId: null,
        holidayMultiplier: null,
        evaluationTimestamp: DateTime.utc(2026, 3, 20, 8, 30),
        evaluationTimeZone: 'Europe/Lisbon',
        multiplierChargeMinor: 0,
        totalMinor: 1460,
        distanceKm: 8.4,
        durationMinutes: 18,
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('pt', 'PT'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TripPreviewPriceDetailsPanel(
                  breakdown: breakdown,
                  tariff: tariff,
                  multiplierLabel: 'Faixa horária',
                  locale: 'pt_PT',
                  moneyFormatter: euroCurrencyFormatter,
                  l10n: AppLocalizations.of(context),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Ver detalhe do preço'));
      await tester.pumpAndSettle();

      expect(
        find.text('Ajuste ao preço por Faixa horária (×1,00)'),
        findsNothing,
      );
      expect(find.text('0,00 €'), findsNothing);
    },
  );
}
