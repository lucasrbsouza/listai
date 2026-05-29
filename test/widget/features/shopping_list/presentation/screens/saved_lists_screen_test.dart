import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/domain/repositories/shopping_list_repository.dart';
import 'package:listai/features/shopping_list/presentation/providers/shopping_list_repository_provider.dart';
import 'package:listai/features/shopping_list/presentation/providers/saved_lists_provider.dart';
import 'package:listai/features/shopping_list/presentation/providers/current_list_provider.dart';
import 'package:listai/features/shopping_list/presentation/screens/saved_lists_screen.dart';
import 'package:listai/core/utils/money.dart';

class MockShoppingListRepository extends Mock
    implements ShoppingListRepository {}

class FakeCurrentListNotifier extends StateNotifier<AsyncValue<ShoppingList?>>
    implements CurrentListNotifier {
  FakeCurrentListNotifier(super.state);

  ShoppingList? activatedList;
  ShoppingList? duplicatedList;
  String? duplicatedNewName;

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
  @override
  Future<void> replaceWithTemplate(ShoppingList template) async {}
  @override
  Future<void> activateList(ShoppingList list) async {
    activatedList = list;
  }

  @override
  Future<void> duplicateAndUseList(ShoppingList list, {String? newName}) async {
    duplicatedList = list;
    duplicatedNewName = newName;
  }

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
}

void main() {
  late MockShoppingListRepository mockRepository;

  setUp(() {
    mockRepository = MockShoppingListRepository();
    registerFallbackValue(
      ShoppingList(
        id: 'fallback-id',
        name: 'Fallback',
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    when(() => mockRepository.deleteList(any())).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest({
    required List<ShoppingList> lists,
    FakeCurrentListNotifier? currentListNotifier,
  }) {
    final notifier =
        currentListNotifier ??
        FakeCurrentListNotifier(const AsyncValue.data(null));
    return ProviderScope(
      overrides: [
        shoppingListRepositoryProvider.overrideWithValue(mockRepository),
        savedListsProvider.overrideWith((ref) => Future.value(lists)),
        currentListProvider.overrideWith((ref) => notifier),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/saved',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) =>
                  const Scaffold(body: Text('Home Screen')),
            ),
            GoRoute(
              path: '/saved',
              builder: (context, state) => const SavedListsScreen(),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('renders tabs and shows empty active lists state by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest(lists: []));
    await tester.pumpAndSettle();

    expect(find.text('Minhas Listas'), findsOneWidget);
    expect(find.text('Modelos / Templates'), findsOneWidget);
    expect(find.text('Nenhuma lista em andamento ainda.'), findsOneWidget);
  });

  testWidgets('renders active lists and allows opening and duplicating', (
    WidgetTester tester,
  ) async {
    final lists = [
      ShoppingList(
        id: 'active-1',
        name: 'Feira Semanal',
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    final notifier = FakeCurrentListNotifier(const AsyncValue.data(null));

    await tester.pumpWidget(
      createWidgetUnderTest(lists: lists, currentListNotifier: notifier),
    );
    await tester.pumpAndSettle();

    expect(find.text('Feira Semanal'), findsOneWidget);

    // Tap "Abrir Lista"
    final abrirButton = find.text('Abrir Lista');
    expect(abrirButton, findsOneWidget);
    await tester.tap(abrirButton);
    await tester.pumpAndSettle();

    expect(notifier.activatedList, isNotNull);
    expect(notifier.activatedList!.id, 'active-1');
  });

  testWidgets(
    'renders templates tab when clicked and allows creating list from it',
    (WidgetTester tester) async {
      final lists = [
        ShoppingList(
          id: 'tmpl-1',
          name: 'Modelo Churrasco',
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

      // Switch to Modelos / Templates tab
      final templateTab = find.text('Modelos / Templates');
      expect(templateTab, findsOneWidget);
      await tester.tap(templateTab);
      await tester.pumpAndSettle();

      expect(find.text('Modelo Churrasco'), findsOneWidget);

      final useButton = find.text('Criar lista deste modelo');
      expect(useButton, findsOneWidget);
      await tester.tap(useButton);
      await tester.pumpAndSettle();

      expect(notifier.duplicatedList, isNotNull);
      expect(notifier.duplicatedList!.id, 'tmpl-1');
      expect(notifier.duplicatedNewName, 'Modelo Churrasco');
    },
  );

  testWidgets('shows delete confirmation dialog and deletes list on confirm', (
    WidgetTester tester,
  ) async {
    final lists = [
      ShoppingList(
        id: 'active-1',
        name: 'Feira Semanal',
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    await tester.pumpWidget(createWidgetUnderTest(lists: lists));
    await tester.pumpAndSettle();

    final deleteButton = find.byIcon(Icons.delete);
    expect(deleteButton, findsOneWidget);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.text('Excluir lista?'), findsOneWidget);

    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    verify(() => mockRepository.deleteList('active-1')).called(1);
  });
}
