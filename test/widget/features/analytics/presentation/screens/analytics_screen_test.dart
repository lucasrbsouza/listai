import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/features/analytics/domain/entities/analytics_entities.dart';
import 'package:listai/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:listai/features/analytics/presentation/screens/analytics_screen.dart';

AnalyticsData _emptyData() => const AnalyticsData(
      spendingPoints: [],
      topMarkets: [],
      mostBoughtProducts: [],
      topSpendingProducts: [],
      budgetExceededResult: BudgetExceededResult(
        exceededCount: 0,
        totalPurchases: 0,
      ),
    );

AnalyticsData _dataWithContent() => AnalyticsData(
      spendingPoints: [
        SpendingPoint(
            date: DateTime(2024, 6, 14), total: Money.fromReais(100)),
        SpendingPoint(
            date: DateTime(2024, 6, 15), total: Money.fromReais(200)),
      ],
      topMarkets: [
        MarketSpending(
            marketName: 'Mercado A', total: Money.fromReais(300)),
      ],
      mostBoughtProducts: const [
        ProductPurchaseCount(
            productName: 'Arroz', productType: 'Mercearia', count: 5),
      ],
      topSpendingProducts: [
        ProductSpendingTotal(
            productName: 'Carne',
            productType: 'Carnes',
            total: Money.fromReais(200)),
      ],
      budgetExceededResult: const BudgetExceededResult(
        exceededCount: 2,
        totalPurchases: 5,
      ),
    );

Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: [
      heatmapDataProvider.overrideWith((ref) async => const []),
      ...overrides,
    ],
    child: MaterialApp(home: child),
  );
}

Finder _textOffstage(String text) =>
    find.text(text, skipOffstage: false);

void main() {
  testWidgets('shows loading indicator while fetching', (tester) async {
    final completer = Completer<AnalyticsData>();

    await tester.pumpWidget(
      _wrap(
        const AnalyticsScreen(),
        overrides: [
          analyticsDataProvider.overrideWith((ref, period) {
            return completer.future;
          }),
        ],
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete so no pending timer
    completer.complete(_emptyData());
    await tester.pumpAndSettle();
  });

  testWidgets('shows empty state when no data', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AnalyticsScreen(),
        overrides: [
          analyticsDataProvider.overrideWith((ref, period) async {
            return _emptyData();
          }),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhum dado disponível'), findsOneWidget);
    expect(
      find.text('Finalize compras para visualizar\nsuas estatísticas aqui.'),
      findsOneWidget,
    );
  });

  testWidgets('shows period dropdown', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AnalyticsScreen(),
        overrides: [
          analyticsDataProvider.overrideWith((ref, period) async {
            return _emptyData();
          }),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButton<AnalyticsPeriod>), findsOneWidget);
  });

  testWidgets('renders data sections when content available', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AnalyticsScreen(),
        overrides: [
          analyticsDataProvider.overrideWith((ref, period) async {
            return _dataWithContent();
          }),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(_textOffstage('Gastos no Período'), findsOneWidget);
    expect(_textOffstage('Top Mercados'), findsOneWidget);
    expect(_textOffstage('Produtos Mais Comprados'), findsOneWidget);
    expect(_textOffstage('Maior Gasto por Produto'), findsOneWidget);
  });

  testWidgets('shows product names in lists', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AnalyticsScreen(),
        overrides: [
          analyticsDataProvider.overrideWith((ref, period) async {
            return _dataWithContent();
          }),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(_textOffstage('Arroz'), findsOneWidget);
    expect(_textOffstage('Carne'), findsOneWidget);
    expect(_textOffstage('Mercado A'), findsOneWidget);
  });

  testWidgets('shows budget exceeded indicator', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AnalyticsScreen(),
        overrides: [
          analyticsDataProvider.overrideWith((ref, period) async {
            return _dataWithContent();
          }),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Ultrapassou meta 2', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('shows no purchases message when total is 0', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AnalyticsScreen(),
        overrides: [
          analyticsDataProvider.overrideWith((ref, period) async {
            return AnalyticsData(
              spendingPoints: [
                SpendingPoint(
                    date: DateTime(2024), total: Money.fromReais(10)),
              ],
              topMarkets: [],
              mostBoughtProducts: [],
              topSpendingProducts: [],
              budgetExceededResult: const BudgetExceededResult(
                exceededCount: 0,
                totalPurchases: 0,
              ),
            );
          }),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(
        find.text('Nenhuma compra no período', skipOffstage: false),
        findsOneWidget);
  });

  testWidgets('shows error state on failure', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AnalyticsScreen(),
        overrides: [
          analyticsDataProvider.overrideWith((ref, period) async {
            throw Exception('Falha de rede');
          }),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Erro ao carregar'), findsOneWidget);
  });

  testWidgets('period dropdown changes state', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AnalyticsScreen(),
        overrides: [
          analyticsDataProvider.overrideWith((ref, period) async {
            return _emptyData();
          }),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<AnalyticsPeriod>));
    await tester.pumpAndSettle();

    expect(find.text('Semanal'), findsWidgets);
    expect(find.text('Anual'), findsWidgets);
  });
}
