import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/presentation/providers/current_list_provider.dart';
import 'package:listai/features/shopping_list/presentation/screens/current_list_screen.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:listai/features/shopping_list/presentation/providers/current_tab_provider.dart';

class FakeCurrentListNotifier extends StateNotifier<AsyncValue<ShoppingList?>>
    implements CurrentListNotifier {
  FakeCurrentListNotifier(super.state);

  bool undoCalled = false;
  bool finalizePurchaseCalled = false;
  Money? updatedBudgetGoal;

  @override
  Future<void> addItem(ShoppingItem item) async {}

  @override
  Future<void> addItemWithSubstitute({
    required ShoppingItem main,
    required ShoppingItem substitute,
  }) async {}

  @override
  Future<void> clearAll() async {}

  @override
  Future<void> finalizePurchase() async {
    finalizePurchaseCalled = true;
  }

  @override
  Future<void> removeItem(String itemId) async {}

  @override
  Future<void> undo() async {
    undoCalled = true;
  }

  @override
  Future<void> updateItem(ShoppingItem updatedItem) async {}

  @override
  Future<void> replaceWithTemplate(ShoppingList template) async {}

  @override
  Future<void> swapWithSubstitute(String mainItemId) async {}

  @override
  Future<void> updateBudgetGoal(Money? budgetGoal) async {
    updatedBudgetGoal = budgetGoal;
    if (state.hasValue && state.value != null) {
      state = AsyncValue.data(
        state.value!.copyWith(
          budgetGoal: budgetGoal,
          clearBudgetGoal: budgetGoal == null,
        ),
      );
    }
  }

  @override
  Future<void> saveAsTemplate() async {}

  // mock helper to change state directly in test
  void updateState(ShoppingList newList) {
    state = AsyncValue.data(newList);
  }

  @override
  Future<void> createNewList(String name) async {}

  @override
  Future<void> renameList(String newName) async {}

  @override
  Future<void> updateMarketName(String? marketName) async {}

  @override
  Future<void> activateList(ShoppingList list) async {}

  @override
  Future<void> duplicateAndUseList(
    ShoppingList list, {
    String? newName,
  }) async {}
}

void main() {
  Widget createWidgetUnderTest(
    FakeCurrentListNotifier notifier, {
    int initialTab = 2,
  }) {
    return ProviderScope(
      overrides: [
        currentListProvider.overrideWith((ref) => notifier),
        currentTabIndexProvider.overrideWith((ref) => initialTab),
        heatmapDataProvider.overrideWith((ref) async => const []),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const CurrentListScreen(),
            ),
          ],
        ),
      ),
    );
  }

  ShoppingList createList({
    Money? budgetGoal,
    List<ShoppingItem> items = const [],
  }) {
    return ShoppingList(
      id: 'list-1',
      name: 'Minha Lista',
      marketName: 'Mercado Teste',
      budgetGoal: budgetGoal,
      items: items,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  ShoppingItem createItem({
    required String id,
    required Money price,
    required double quantity,
  }) {
    return ShoppingItem(
      id: id,
      productType: 'Mercearia',
      productName: 'Item Teste',
      unitPrice: price,
      quantity: Quantity(quantity),
      position: 0,
      createdAt: DateTime.now(),
    );
  }

  testWidgets('total changes color to red when budget is exceeded', (
    WidgetTester tester,
  ) async {
    final item = createItem(
      id: 'item-1',
      price: Money.fromCents(1500),
      quantity: 1.0,
    ); // R$ 15,00
    final list = createList(
      budgetGoal: Money.fromCents(1000),
      items: [item],
    ); // Meta R$ 10,00
    final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

    await tester.pumpWidget(createWidgetUnderTest(notifier));
    await tester.pumpAndSettle();

    // The total value "R$ 15,00" should be rendered in red color in the footer
    final totalTextFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == r'R$ 15,00' &&
          widget.style?.fontSize == 22.0,
    );
    expect(totalTextFinder, findsOneWidget);

    final Text textWidget = tester.widget(totalTextFinder);
    final BuildContext context = tester.element(totalTextFinder);
    expect(textWidget.style?.color, Theme.of(context).colorScheme.error);
  });

  testWidgets(
    'dialog appears when budget is exceeded for the first time and handles actions',
    (WidgetTester tester) async {
      // Start within budget
      final list = createList(
        budgetGoal: Money.fromCents(2000),
        items: [],
      ); // Meta R$ 20,00
      final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

      await tester.pumpWidget(createWidgetUnderTest(notifier));
      await tester.pumpAndSettle();

      // Verify no dialog is present
      expect(find.textContaining('Você ultrapassou o orçamento'), findsNothing);

      // Add item that exceeds the budget
      final item = createItem(
        id: 'item-1',
        price: Money.fromCents(2500),
        quantity: 1.0,
      ); // R$ 25,00
      notifier.updateState(list.copyWith(items: [item]));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(
        find.textContaining('Você ultrapassou o orçamento'),
        findsOneWidget,
      );
      expect(find.text('Deseja finalizar as compras?'), findsOneWidget);

      // Tap "Continuar comprando" to dismiss dialog
      await tester.tap(find.text('Continuar comprando'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Você ultrapassou o orçamento'), findsNothing);

      // Add another item - dialog should NOT appear again (session prevention)
      final item2 = createItem(
        id: 'item-2',
        price: Money.fromCents(500),
        quantity: 1.0,
      ); // R$ 5,00
      notifier.updateState(list.copyWith(items: [item, item2]));
      await tester.pumpAndSettle();
      expect(find.textContaining('Você ultrapassou o orçamento'), findsNothing);
    },
  );

  testWidgets('dialog "Finalizar agora" calls finalizePurchase', (
    WidgetTester tester,
  ) async {
    final list = createList(budgetGoal: Money.fromCents(1000), items: []);
    final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

    await tester.pumpWidget(createWidgetUnderTest(notifier));
    await tester.pumpAndSettle();

    final item = createItem(
      id: 'item-1',
      price: Money.fromCents(1500),
      quantity: 1.0,
    );
    notifier.updateState(list.copyWith(items: [item]));
    await tester.pumpAndSettle();

    expect(find.textContaining('Você ultrapassou o orçamento'), findsOneWidget);

    await tester.tap(find.text('Finalizar agora'));
    await tester.pumpAndSettle();

    // Confirmation dialog appears
    expect(find.text('Finalizar compra?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar Lista'));
    await tester.pumpAndSettle();

    expect(notifier.finalizePurchaseCalled, isTrue);
  });

  testWidgets('can edit budget goal from the header', (
    WidgetTester tester,
  ) async {
    final list = createList(
      budgetGoal: Money.fromCents(1000),
      items: [],
    ); // Meta R$ 10,00
    final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

    await tester.pumpWidget(createWidgetUnderTest(notifier));
    await tester.pumpAndSettle();

    // Verify it shows "Meta: R$ 10,00" in the header
    expect(find.text(r'Meta: R$ 10,00'), findsOneWidget);

    // Tap the edit budget element
    await tester.tap(find.text(r'Meta: R$ 10,00'));
    await tester.pumpAndSettle();

    // Verify budget dialog opens
    expect(find.text('Definir Meta de Orçamento'), findsOneWidget);

    // Enter a new budget value
    await tester.enterText(find.byType(TextField), '25.50');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    // Verify provider was called
    expect(notifier.updatedBudgetGoal, Money.fromCents(2550));
  });
}
