import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/presentation/providers/current_list_provider.dart';
import 'package:listai/features/shopping_list/presentation/providers/saved_lists_provider.dart';
import 'package:listai/features/shopping_list/presentation/screens/history_screen.dart';

class FakeCurrentListNotifier extends StateNotifier<AsyncValue<ShoppingList?>>
    implements CurrentListNotifier {
  FakeCurrentListNotifier() : super(const AsyncValue.data(null));

  ShoppingList? duplicatedList;
  String? duplicatedNewName;

  @override
  Future<void> duplicateAndUseList(ShoppingList list, {String? newName}) async {
    duplicatedList = list;
    duplicatedNewName = newName;
  }

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
  Future<void> finalizePurchase() async {}
  @override
  Future<void> removeItem(String itemId) async {}
  @override
  Future<void> undo() async {}
  @override
  Future<void> updateItem(ShoppingItem updatedItem) async {}
  @override
  Future<void> swapWithSubstitute(String mainItemId) async {}
  @override
  Future<void> replaceWithTemplate(ShoppingList template) async {}
  @override
  Future<void> updateBudgetGoal(Money? budgetGoal) async {}
  @override
  Future<void> saveAsTemplate() async {}
  @override
  Future<void> createNewList(String name) async {}
  @override
  Future<void> renameList(String newName) async {}
  @override
  Future<void> updateMarketName(String? marketName) async {}
  @override
  Future<void> activateList(ShoppingList list) async {}
}

void main() {
  Widget createWidgetUnderTest({
    required List<ShoppingList> lists,
    FakeCurrentListNotifier? notifier,
  }) {
    final router = GoRouter(
      initialLocation: '/history',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/saved/:id',
          builder: (context, state) => const Scaffold(body: Text('Detail')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        savedListsProvider.overrideWith((ref) => Future.value(lists)),
        if (notifier != null)
          currentListProvider.overrideWith((ref) => notifier),
      ],
      child: MaterialApp.router(routerConfig: router),
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

  testWidgets('shows item count and total for each purchase', (
    WidgetTester tester,
  ) async {
    final item = ShoppingItem(
      id: 'i1',
      productType: 'Mercearia',
      productName: 'Arroz',
      quantity: Quantity(2),
      unitPrice: Money.fromReais(5.00),
      createdAt: DateTime(2024),
    );
    final lists = [
      ShoppingList(
        id: '2',
        name: 'Compra do mês',
        items: [item],
        isCompleted: true,
        completedAt: DateTime(2024, 3, 15, 10, 30),
        createdAt: DateTime(2024, 3, 1),
        updatedAt: DateTime(2024, 3, 15),
      ),
    ];

    await tester.pumpWidget(createWidgetUnderTest(lists: lists));
    await tester.pumpAndSettle();

    expect(find.text('1 item'), findsOneWidget);
    expect(find.textContaining('R\$ 10,00'), findsOneWidget);
    expect(find.textContaining('15/03/2024'), findsOneWidget);
  });

  testWidgets('reuse button duplicates the purchase as new active list', (
    WidgetTester tester,
  ) async {
    final notifier = FakeCurrentListNotifier();
    final lists = [
      ShoppingList(
        id: '2',
        name: 'Festa Completada',
        items: [],
        isCompleted: true,
        completedAt: DateTime(2024, 3, 15),
        createdAt: DateTime(2024, 3, 1),
        updatedAt: DateTime(2024, 3, 15),
      ),
    ];

    await tester.pumpWidget(
      createWidgetUnderTest(lists: lists, notifier: notifier),
    );
    await tester.pumpAndSettle();

    final reuseButton = find.text('Reutilizar lista');
    expect(reuseButton, findsOneWidget);

    await tester.tap(reuseButton);
    await tester.pumpAndSettle();

    expect(notifier.duplicatedList, isNotNull);
    expect(notifier.duplicatedList!.id, '2');
    expect(notifier.duplicatedNewName, 'Festa Completada');
  });
}
