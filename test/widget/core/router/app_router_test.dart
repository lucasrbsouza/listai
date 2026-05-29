import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listai/core/router/app_router.dart';
import 'package:listai/features/auth/presentation/providers/auth_providers.dart';
import 'package:listai/features/shopping_list/presentation/screens/current_list_screen.dart';
import 'package:listai/features/shopping_list/presentation/screens/item_form_screen.dart';
import 'package:listai/features/settings/presentation/screens/settings_screen.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/presentation/providers/current_list_provider.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';

class FakeCurrentListNotifier extends StateNotifier<AsyncValue<ShoppingList?>>
    implements CurrentListNotifier {
  FakeCurrentListNotifier(super.state);

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
  void dispose() {
    super.dispose();
  }
}

class FakeOfflineNotifier extends OfflineModeNotifier {
  FakeOfflineNotifier(final bool initial) {
    state = initial;
  }
  @override
  Future<void> _loadState() async {}
  @override
  Future<void> setOfflineMode(final bool offline) async {
    state = offline;
  }
}

void main() {
  Widget createWidgetUnderTest(FakeCurrentListNotifier notifier) {
    return ProviderScope(
      overrides: [
        currentListProvider.overrideWith((ref) => notifier),
        isOfflineModeProvider.overrideWith((ref) => FakeOfflineNotifier(true)),
      ],
      child: Consumer(
        builder: (context, ref, child) {
          final goRouter = ref.watch(appRouterProvider);
          return MaterialApp.router(routerConfig: goRouter);
        },
      ),
    );
  }

  testWidgets('initial route is CurrentListScreen', (
    WidgetTester tester,
  ) async {
    final notifier = FakeCurrentListNotifier(const AsyncValue.data(null));
    await tester.pumpWidget(createWidgetUnderTest(notifier));
    await tester.pumpAndSettle();

    expect(find.byType(CurrentListScreen), findsOneWidget);
  });

  testWidgets('tap on FAB navigates to ItemFormScreen in creation mode', (
    WidgetTester tester,
  ) async {
    final notifier = FakeCurrentListNotifier(const AsyncValue.data(null));
    await tester.pumpWidget(createWidgetUnderTest(notifier));
    await tester.pumpAndSettle();

    final fab = find.byType(FloatingActionButton);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    expect(find.byType(ItemFormScreen), findsOneWidget);
    expect(find.text('Adicionar Item'), findsOneWidget);
  });

  testWidgets('back button from ItemFormScreen returns to CurrentListScreen', (
    WidgetTester tester,
  ) async {
    final notifier = FakeCurrentListNotifier(const AsyncValue.data(null));
    await tester.pumpWidget(createWidgetUnderTest(notifier));
    await tester.pumpAndSettle();

    // Go to ItemFormScreen
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Tap back button
    final backButton = find.byTooltip('Back');
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(find.byType(CurrentListScreen), findsOneWidget);
    expect(find.byType(ItemFormScreen), findsNothing);
  });

  testWidgets('tap on item navigates to ItemFormScreen in edit mode', (
    WidgetTester tester,
  ) async {
    final item = ShoppingItem(
      id: '123',
      productType: 'Mercearia',
      productName: 'Feijão',
      quantity: Quantity(1.0),
      unitPrice: Money.fromReais(8.0),
      createdAt: DateTime.now(),
    );
    final list = ShoppingList(
      id: '1',
      name: 'Lista',
      items: [item],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final notifier = FakeCurrentListNotifier(AsyncValue.data(list));
    await tester.pumpWidget(createWidgetUnderTest(notifier));
    await tester.pumpAndSettle();

    // Tap on the item card (ListTile)
    await tester.tap(find.text('Feijão'));
    await tester.pumpAndSettle();

    expect(find.byType(ItemFormScreen), findsOneWidget);
    expect(find.text('Editar Item'), findsOneWidget);

    // Check if fields are pre-filled
    expect(find.text('Feijão'), findsWidgets);
  });

  testWidgets('tap on settings icon navigates to SettingsScreen', (
    WidgetTester tester,
  ) async {
    final notifier = FakeCurrentListNotifier(const AsyncValue.data(null));
    await tester.pumpWidget(createWidgetUnderTest(notifier));
    await tester.pumpAndSettle();

    final settingsButton = find.byIcon(Icons.settings);
    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Versão do App'), findsOneWidget);
  });
}
