import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/presentation/providers/saved_lists_provider.dart';
import 'package:listai/features/shopping_list/presentation/providers/current_list_provider.dart';
import 'package:listai/features/shopping_list/presentation/screens/saved_lists_screen.dart';

class FakeCurrentListNotifier extends StateNotifier<AsyncValue<ShoppingList?>>
    implements CurrentListNotifier {
  FakeCurrentListNotifier(super.state);

  ShoppingList? replacedList;

  @override
  Future<void> addItem(item) async {}
  @override
  Future<void> addItemWithSubstitute({
    required ShoppingItem main,
    required ShoppingItem substitute,
  }) async {}
  @override
  Future<void> clearAll() async {}
  @override
  Future<void> finalizePurchase() async {}
  @override
  Future<void> removeItem(itemId) async {}
  @override
  Future<void> undo() async {}
  @override
  Future<void> updateItem(updatedItem) async {}
  @override
  Future<void> swapWithSubstitute(String mainItemId) async {}

  // Custom method needed for replacing list
  Future<void> replaceWithTemplate(ShoppingList template) async {
    replacedList = template;
  }
}

void main() {
  Widget createWidgetUnderTest({
    required List<ShoppingList> lists,
    FakeCurrentListNotifier? currentListNotifier,
  }) {
    return ProviderScope(
      overrides: [
        savedListsProvider.overrideWith((ref) => Future.value(lists)),
        if (currentListNotifier != null)
          currentListProvider.overrideWith((ref) => currentListNotifier),
      ],
      child: const MaterialApp(home: SavedListsScreen()),
    );
  }

  testWidgets('renders tabs correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(lists: []));
    await tester.pumpAndSettle();

    expect(find.text('Templates'), findsOneWidget);
    expect(find.text('Histórico'), findsOneWidget);
  });

  testWidgets('shows empty state when no templates exist', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest(lists: []));
    await tester.pumpAndSettle();

    expect(find.text('Nenhum template salvo ainda.'), findsOneWidget);
  });

  testWidgets('shows empty state when no history exists', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest(lists: []));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma compra finalizada ainda.'), findsOneWidget);
  });

  testWidgets('renders templates and history in correct tabs', (
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
        name: 'Festa',
        items: [],
        isCompleted: true,
        marketName: 'Supermercado',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    await tester.pumpWidget(createWidgetUnderTest(lists: lists));
    await tester.pumpAndSettle();

    // Template tab
    expect(find.text('Compras Mês'), findsOneWidget);
    expect(find.text('Festa'), findsNothing);

    // Switch to history tab
    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();

    expect(find.text('Compras Mês'), findsNothing);
    expect(find.text('Festa'), findsOneWidget);
    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
        .toList();
    print('FOUND TEXTS: $texts');
    expect(
      find.textContaining('Supermercado'),
      findsOneWidget,
    ); // Shows market name
  });

  testWidgets(
    'shows confirmation dialog when replacing list and calls provider on confirm',
    (WidgetTester tester) async {
      final lists = [
        ShoppingList(
          id: '1',
          name: 'Compras Mês',
          items: [],
          isTemplate: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      final notifier = FakeCurrentListNotifier(const AsyncValue.data(null));

      await tester.pumpWidget(
        createWidgetUnderTest(lists: lists, currentListNotifier: notifier),
      );
      await tester.pumpAndSettle();

      final loadButton = find.text('Carregar como lista atual');
      expect(loadButton, findsOneWidget);
      await tester.tap(loadButton);
      await tester.pumpAndSettle();

      // Dialog appears
      expect(find.text('Substituir lista atual?'), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(notifier.replacedList, isNull);

      // Tap load again
      await tester.tap(loadButton);
      await tester.pumpAndSettle();

      // Tap confirm
      await tester.tap(find.text('Substituir'));
      await tester.pumpAndSettle();

      expect(notifier.replacedList, isNotNull);
      expect(notifier.replacedList!.name, 'Compras Mês');
    },
  );
}
