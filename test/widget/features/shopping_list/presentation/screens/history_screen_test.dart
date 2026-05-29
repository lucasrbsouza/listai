import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/presentation/providers/saved_lists_provider.dart';
import 'package:listai/features/shopping_list/presentation/screens/history_screen.dart';

void main() {
  Widget createWidgetUnderTest({required List<ShoppingList> lists}) {
    return ProviderScope(
      overrides: [
        savedListsProvider.overrideWith((ref) => Future.value(lists)),
      ],
      child: const MaterialApp(home: HistoryScreen()),
    );
  }

  testWidgets(
    'renders completed purchases and shows empty state when none exist',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(lists: []));
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma compra finalizada ainda.'), findsOneWidget);
    },
  );

  testWidgets('renders history items and does not render templates', (
    WidgetTester tester,
  ) async {
    final lists = [
      ShoppingList(
        id: '1',
        name: 'Compras Mês',
        items: [],
        isTemplate: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ShoppingList(
        id: '2',
        name: 'Festa Completada',
        items: [],
        isCompleted: true,
        marketName: 'Supermercado Nova Era',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    await tester.pumpWidget(createWidgetUnderTest(lists: lists));
    await tester.pumpAndSettle();

    expect(find.text('Festa Completada'), findsOneWidget);
    expect(find.text('Compras Mês'), findsNothing);
    expect(find.textContaining('Supermercado Nova Era'), findsOneWidget);
  });
}
