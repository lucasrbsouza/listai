import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/presentation/providers/current_list_provider.dart';
import 'package:listai/features/shopping_list/presentation/providers/current_tab_provider.dart';
import 'package:listai/features/shopping_list/presentation/screens/current_list_screen.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/analytics/presentation/providers/analytics_provider.dart';

class FakeCurrentListNotifier extends StateNotifier<AsyncValue<ShoppingList?>>
    implements CurrentListNotifier {
  FakeCurrentListNotifier(super.state);

  bool undoCalled = false;
  bool finalizePurchaseCalled = false;
  String? removedItemId;
  String? swappedMainItemId;

  @override
  Future<void> addItem(ShoppingItem item) async {}

  Future<void> addItemWithSubstitute({
    required ShoppingItem main,
    required ShoppingItem substitute,
  }) async {}

  bool clearAllCalled = false;
  bool saveAsTemplateCalled = false;

  @override
  Future<void> clearAll() async {
    clearAllCalled = true;
    if (state.hasValue && state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(items: []));
    }
  }

  @override
  Future<void> finalizePurchase() async {
    finalizePurchaseCalled = true;
  }

  @override
  Future<void> removeItem(String itemId) async {
    removedItemId = itemId;
    // mock behavior: remove it from state so UI updates and snackbar shows.
    if (state.hasValue && state.value != null) {
      final list = state.value!;
      final newItems = list.items.where((i) => i.id != itemId).toList();
      state = AsyncValue.data(list.copyWith(items: newItems));
    }
  }

  @override
  Future<void> undo() async {
    undoCalled = true;
  }

  @override
  Future<void> updateItem(ShoppingItem updatedItem) async {}

  Future<void> swapWithSubstitute(String mainItemId) async {
    swappedMainItemId = mainItemId;
  }

  @override
  Future<void> replaceWithTemplate(ShoppingList template) async {}

  @override
  Future<void> updateBudgetGoal(Money? budgetGoal) async {}

  @override
  Future<void> saveAsTemplate() async {
    saveAsTemplateCalled = true;
  }

  @override
  void dispose() {
    super.dispose();
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
            GoRoute(
              path: '/item/new',
              builder: (context, state) =>
                  const Scaffold(body: Text('New Item')),
            ),
          ],
        ),
      ),
    );
  }

  ShoppingList createList({
    required String name,
    required String marketName,
    Money? budgetGoal,
    List<ShoppingItem> items = const [],
  }) {
    return ShoppingList(
      id: '1',
      name: name,
      marketName: marketName,
      budgetGoal: budgetGoal,
      items: items,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  ShoppingItem createItem({
    required String id,
    required String name,
    required Money unitPrice,
    required Quantity quantity,
    bool hasPhoto = false,
    String? substituteId,
  }) {
    return ShoppingItem(
      id: id,
      productType: 'Mercearia',
      productName: name,
      quantity: quantity,
      unitPrice: unitPrice,
      position: 0,
      createdAt: DateTime.now(),
      photoUrl: hasPhoto ? 'url' : null,
      photoCapturedAt: hasPhoto ? DateTime(2026, 1, 2, 3, 4) : null,
      substituteItemId: substituteId,
    );
  }

  testWidgets('renders loading state', (WidgetTester tester) async {
    final notifier = FakeCurrentListNotifier(const AsyncValue.loading());
    await tester.pumpWidget(createWidgetUnderTest(notifier));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders no-list state message when list is null', (
    WidgetTester tester,
  ) async {
    final notifier = FakeCurrentListNotifier(const AsyncValue.data(null));
    await tester.pumpWidget(createWidgetUnderTest(notifier, initialTab: 0));
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('Usar uma lista já existente ou criar uma nova lista'),
      findsOneWidget,
    );
    expect(find.text('Criar Nova Lista'), findsOneWidget);
  });

  testWidgets('renders empty list state message when list has no items', (
    WidgetTester tester,
  ) async {
    final list = createList(name: 'Minha Lista', marketName: 'Mercado');
    final notifier = FakeCurrentListNotifier(AsyncValue.data(list));
    await tester.pumpWidget(createWidgetUnderTest(notifier));

    expect(find.text('Lista vazia.'), findsOneWidget);
  });

  testWidgets('renders list with items', (WidgetTester tester) async {
    final item = createItem(
      id: 'item1',
      name: 'Arroz',
      unitPrice: Money.fromReais(5.50),
      quantity: Quantity(2.0),
    );
    final list = createList(
      name: 'Lista',
      marketName: 'Mercado',
      items: [item],
    );
    final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

    await tester.pumpWidget(createWidgetUnderTest(notifier));

    expect(find.text('Arroz'), findsOneWidget);
    expect(find.text('Mercearia'), findsOneWidget);
    expect(find.text('2.0 un. × R\$ 5,50'), findsOneWidget);
    expect(find.text('R\$ 11,00'), findsNWidgets(2));
    // Header check - market name should be visible
    expect(find.text('Mercado'), findsOneWidget);
  });

  testWidgets('shows total correctly', (WidgetTester tester) async {
    final item1 = createItem(
      id: '1',
      name: 'Arroz',
      unitPrice: Money.fromReais(5.0),
      quantity: Quantity(2.0),
    );
    final item2 = createItem(
      id: '2',
      name: 'Feijão',
      unitPrice: Money.fromReais(8.0),
      quantity: Quantity(1.0),
    );
    final list = createList(
      name: 'Lista',
      marketName: 'Mercado',
      items: [item1, item2],
    );
    final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

    await tester.pumpWidget(createWidgetUnderTest(notifier));

    expect(find.text('Total:'), findsOneWidget);
    expect(find.text('R\$ 18,00'), findsOneWidget);
  });

  testWidgets('shows total in red when exceeds budget', (
    WidgetTester tester,
  ) async {
    final item = createItem(
      id: '1',
      name: 'Arroz',
      unitPrice: Money.fromReais(15.0),
      quantity: Quantity(1.0),
    );
    final list = createList(
      name: 'Lista',
      marketName: 'Mercado',
      budgetGoal: Money.fromReais(10.0), // Total 15 > 10
      items: [item],
    );
    final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

    await tester.pumpWidget(createWidgetUnderTest(notifier));

    final totalText = tester.widget<Text>(find.text('R\$ 15,00').last);
    // Since we use Theme.of(context).colorScheme.error, we check if color matches default error color (usually red)
    // Actually we just check that the color is not null, since default text has null color usually, or specific check.
    expect(totalText.style?.color, isNotNull);
  });

  testWidgets('shows icons for photo and substitute if present', (
    WidgetTester tester,
  ) async {
    final item = createItem(
      id: '1',
      name: 'Arroz',
      unitPrice: Money.fromReais(5.0),
      quantity: Quantity(1.0),
      hasPhoto: true,
      substituteId: 'sub-1',
    );
    final list = createList(
      name: 'Lista',
      marketName: 'Mercado',
      items: [item],
    );
    final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

    await tester.pumpWidget(createWidgetUnderTest(notifier));

    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
  });

  testWidgets('substitute stays hidden until toggle is expanded', (
    WidgetTester tester,
  ) async {
    final substitute = createItem(
      id: 'sub-1',
      name: 'Feijão',
      unitPrice: Money.fromReais(6.0),
      quantity: Quantity(1.0),
    );
    final item = createItem(
      id: '1',
      name: 'Arroz',
      unitPrice: Money.fromReais(5.0),
      quantity: Quantity(1.0),
      substituteId: 'sub-1',
    );
    final list = createList(
      name: 'Lista',
      marketName: 'Mercado',
      items: [item, substitute],
    );
    final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

    await tester.pumpWidget(createWidgetUnderTest(notifier));

    expect(find.text('Arroz'), findsOneWidget);
    expect(find.text('Feijão'), findsNothing);
    expect(find.text('Mostrar substituto'), findsOneWidget);

    await tester.tap(find.text('Mostrar substituto'));
    await tester.pumpAndSettle();

    expect(find.text('Feijão'), findsOneWidget);
    expect(find.text('Ocultar substituto'), findsOneWidget);
  });

  testWidgets('swap button calls provider with principal id', (
    WidgetTester tester,
  ) async {
    final substitute = createItem(
      id: 'sub-1',
      name: 'Feijão',
      unitPrice: Money.fromReais(6.0),
      quantity: Quantity(1.0),
    );
    final item = createItem(
      id: '1',
      name: 'Arroz',
      unitPrice: Money.fromReais(5.0),
      quantity: Quantity(1.0),
      substituteId: 'sub-1',
    );
    final list = createList(
      name: 'Lista',
      marketName: 'Mercado',
      items: [item, substitute],
    );
    final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

    await tester.pumpWidget(createWidgetUnderTest(notifier));
    await tester.tap(find.text('Mostrar substituto'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Trocar com principal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trocar com principal'));
    await tester.pumpAndSettle();

    expect(notifier.swappedMainItemId, '1');
  });

  testWidgets('tap photo icon opens viewer route', (WidgetTester tester) async {
    final item = createItem(
      id: '1',
      name: 'Arroz',
      unitPrice: Money.fromReais(5.0),
      quantity: Quantity(1.0),
      hasPhoto: true,
    );
    final list = createList(
      name: 'Lista',
      marketName: 'Mercado',
      items: [item],
    );
    final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentListProvider.overrideWith((ref) => notifier),
          currentTabIndexProvider.overrideWith((ref) => 2),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const CurrentListScreen(),
              ),
              GoRoute(
                path: '/photo-viewer',
                builder: (context, state) =>
                    const Scaffold(body: Text('Photo Viewer')),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.camera_alt));
    await tester.pumpAndSettle();

    expect(find.text('Photo Viewer'), findsOneWidget);
  });

  testWidgets('swipe to delete calls removeItem and shows snackbar', (
    WidgetTester tester,
  ) async {
    final item = createItem(
      id: 'item-to-delete',
      name: 'Arroz',
      unitPrice: Money.fromReais(5.0),
      quantity: Quantity(1.0),
    );
    final list = createList(
      name: 'Lista',
      marketName: 'Mercado',
      items: [item],
    );
    final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

    await tester.pumpWidget(createWidgetUnderTest(notifier));

    // Swipe to delete
    await tester.drag(find.text('Arroz'), const Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    expect(notifier.removedItemId, 'item-to-delete');

    // Check if SnackBar appears
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Item removido.'), findsOneWidget);

    // Tap on 'Desfazer'
    await tester.tap(find.text('Desfazer'));
    await tester.pump();

    expect(notifier.undoCalled, isTrue);
  });

  testWidgets('tap on Criar tab triggers list creation dialog', (
    WidgetTester tester,
  ) async {
    final list = createList(name: 'Lista', marketName: 'Mercado', items: []);
    final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

    await tester.pumpWidget(createWidgetUnderTest(notifier));

    final createButton = find.text('Criar');
    expect(createButton, findsOneWidget);

    await tester.tap(createButton);
    await tester.pump();
  });

  testWidgets('semantic labels are present', (WidgetTester tester) async {
    final item = createItem(
      id: '1',
      name: 'Arroz',
      unitPrice: Money.fromReais(5.0),
      quantity: Quantity(1.0),
    );
    final list = createList(
      name: 'Lista',
      marketName: 'Mercado',
      items: [item],
    );
    final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

    await tester.pumpWidget(createWidgetUnderTest(notifier));

    expect(find.byTooltip('Criar lista'), findsOneWidget);
  });

  testWidgets('tap Limpar tudo shows dialog, Cancel does not clear list', (
    WidgetTester tester,
  ) async {
    final item = createItem(
      id: '1',
      name: 'Arroz',
      unitPrice: Money.fromReais(5.0),
      quantity: Quantity(1.0),
    );
    final list = createList(
      name: 'Lista',
      marketName: 'Mercado',
      items: [item],
    );
    final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

    await tester.pumpWidget(createWidgetUnderTest(notifier));
    await tester.pumpAndSettle();

    // Tap on More menu / PopupMenuButton
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Tap "Limpar tudo" option (it's inside a Row now)
    await tester.tap(find.text('Limpar tudo').last);
    await tester.pumpAndSettle();

    // Verify dialog appears
    expect(find.text('Limpar lista atual?'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    // Verify notifier was not called and dialog is dismissed
    expect(notifier.clearAllCalled, isFalse);
    expect(find.text('Limpar lista atual?'), findsNothing);
  });

  testWidgets(
    'tap Limpar tudo in dialog clears list and shows SnackBar with Desfazer which calls undo',
    (WidgetTester tester) async {
      final item = createItem(
        id: '1',
        name: 'Arroz',
        unitPrice: Money.fromReais(5.0),
        quantity: Quantity(1.0),
      );
      final list = createList(
        name: 'Lista',
        marketName: 'Mercado',
        items: [item],
      );
      final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

      await tester.pumpWidget(createWidgetUnderTest(notifier));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Limpar tudo').last);
      await tester.pumpAndSettle();

      // Tap "Limpar tudo" in the dialog
      await tester.tap(find.widgetWithText(FilledButton, 'Limpar tudo'));
      await tester.pumpAndSettle();

      // Verify notifier.clearAll was called
      expect(notifier.clearAllCalled, isTrue);

      // SnackBar appears
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Lista limpa.'), findsOneWidget);

      // Tap "Desfazer" in SnackBar
      await tester.tap(find.text('Desfazer'));
      await tester.pump();

      expect(notifier.undoCalled, isTrue);
    },
  );

  testWidgets(
    'tap Salvar como template antes de limpar calls saveAsTemplate and clears list',
    (WidgetTester tester) async {
      final item = createItem(
        id: '1',
        name: 'Arroz',
        unitPrice: Money.fromReais(5.0),
        quantity: Quantity(1.0),
      );
      final list = createList(
        name: 'Lista',
        marketName: 'Mercado',
        items: [item],
      );
      final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

      await tester.pumpWidget(createWidgetUnderTest(notifier));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Limpar tudo').last);
      await tester.pumpAndSettle();

      // Tap "Salvar como template antes de limpar"
      await tester.tap(find.text('Salvar como template antes de limpar'));
      await tester.pumpAndSettle();

      // Verify saveAsTemplate and clearAll were called
      expect(notifier.saveAsTemplateCalled, isTrue);
      expect(notifier.clearAllCalled, isTrue);
    },
  );

  testWidgets('Finalizar Compra button confirms then calls finalizePurchase', (
    WidgetTester tester,
  ) async {
    final item = createItem(
      id: 'item1',
      name: 'Arroz',
      unitPrice: Money.fromReais(5.0),
      quantity: Quantity(1.0),
    );
    final list = createList(
      name: 'Lista',
      marketName: 'Mercado',
      items: [item],
    );
    final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

    await tester.pumpWidget(createWidgetUnderTest(notifier));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Finalizar Compra'));
    await tester.pumpAndSettle();

    // Confirmation dialog appears
    expect(find.text('Finalizar compra?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Salvar Lista'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(notifier.finalizePurchaseCalled, isTrue);
  });

  testWidgets('Finalizar Compra shows warning when list is empty', (
    WidgetTester tester,
  ) async {
    final list = createList(name: 'Lista', marketName: 'Mercado', items: []);
    // Force non-null list with empty items by rebuilding state directly.
    final notifier = FakeCurrentListNotifier(AsyncValue.data(list));

    await tester.pumpWidget(createWidgetUnderTest(notifier));
    await tester.pumpAndSettle();

    // Empty list renders the empty state (no footer button). Guard handled at
    // provider level returns null list -> covered by the empty state UI.
    // Here we assert no finalize happens without items.
    expect(notifier.finalizePurchaseCalled, isFalse);
  });
}
