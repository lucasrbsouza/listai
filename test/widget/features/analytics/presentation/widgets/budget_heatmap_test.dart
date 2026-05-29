import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/features/analytics/domain/entities/analytics_entities.dart';
import 'package:listai/features/analytics/presentation/widgets/budget_heatmap.dart';

List<DayStatus> _buildStatuses({
  int count = 364,
  DayStatus? Function(int index)? override,
}) {
  final end = DateTime(2024, 6, 15);
  return List.generate(count, (i) {
    final date = end.subtract(Duration(days: count - 1 - i));
    return override?.call(i) ?? DayStatus(date: date);
  });
}

void main() {
  testWidgets('renders without overflow', (tester) async {
    final statuses = _buildStatuses();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BudgetHeatmap(statuses: statuses),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders CustomPaint for grid', (tester) async {
    final statuses = _buildStatuses();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BudgetHeatmap(statuses: statuses),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // CustomPaint is used for the heatmap grid
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
  });

  testWidgets('wraps in horizontal scroll for small screens', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final statuses = _buildStatuses();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BudgetHeatmap(statuses: statuses),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('all cells have Semantics', (tester) async {
    final statuses = _buildStatuses(count: 7);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BudgetHeatmap(statuses: statuses),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label != null && w.properties.label!.isNotEmpty,
      ),
      findsNWidgets(7),
    );
  });

  testWidgets('tap calls onDayTap with correct status', (tester) async {
    DayStatus? tapped;
    final end = DateTime(2024, 6, 15);
    final statuses = List.generate(7, (i) {
      final date = end.subtract(Duration(days: 6 - i));
      return DayStatus(
        date: date,
        totalSpent: i == 3 ? Money.fromReais(50) : null,
        budgetGoal: i == 3 ? Money.fromReais(100) : null,
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BudgetHeatmap(
            statuses: statuses,
            onDayTap: (s) => tapped = s,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // tap 4th cell (index 3, col=0, row=3)
    await tester.tap(find.byType(GestureDetector).at(3));
    await tester.pumpAndSettle();

    expect(tapped, isNotNull);
    expect(tapped!.date, equals(statuses[3].date));
  });

  testWidgets('semantic label contains date for day without purchase', (tester) async {
    final date = DateTime(2024, 6, 15);
    final statuses = [DayStatus(date: date)];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BudgetHeatmap(statuses: statuses),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(RegExp(r'15/06.*Sem compra')),
      findsOneWidget,
    );
  });

  testWidgets('semantic label shows budget for day with exceeded purchase', (tester) async {
    final date = DateTime(2024, 6, 15);
    final statuses = [
      DayStatus(
        date: date,
        totalSpent: Money.fromReais(150),
        budgetGoal: Money.fromReais(100),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BudgetHeatmap(statuses: statuses),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(RegExp(r'15/06.*R\$')),
      findsOneWidget,
    );
  });

  testWidgets('empty statuses renders without error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BudgetHeatmap(statuses: []),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
