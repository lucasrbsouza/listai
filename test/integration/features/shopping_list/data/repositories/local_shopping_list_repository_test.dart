import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listai/core/errors/failures.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/shopping_list/data/datasources/local/app_database.dart';
import 'package:listai/features/shopping_list/data/repositories/local_shopping_list_repository.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';

import '../../../../../helpers/sqlite_test_helper.dart';

void main() {
  setUpAll(configureSqliteForTests);

  late AppDatabase db;
  late LocalShoppingListRepository repo;

  final baseDate = DateTime(2024, 1, 15, 10, 0, 0);

  ShoppingList makeList({
    String id = 'list-1',
    String name = 'Minha lista',
    List<ShoppingItem> items = const [],
    bool isCompleted = false,
    bool isTemplate = false,
    Money? budgetGoal,
  }) => ShoppingList(
    id: id,
    name: name,
    items: items,
    isCompleted: isCompleted,
    isTemplate: isTemplate,
    budgetGoal: budgetGoal,
    createdAt: baseDate,
    updatedAt: baseDate,
  );

  ShoppingItem makeItem({
    String id = 'item-1',
    String name = 'Pão',
    int position = 0,
  }) => ShoppingItem(
    id: id,
    productType: 'Padaria',
    productName: name,
    quantity: Quantity(2),
    unitPrice: Money.fromCents(500),
    position: position,
    createdAt: baseDate,
  );

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = LocalShoppingListRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('getCurrentList', () {
    test('returns null when no current list exists', () async {
      final result = await repo.getCurrentList();
      expect(result, isNull);
    });

    test('returns the most recently saved non-completed list', () async {
      final list = makeList();
      await repo.saveCurrentList(list);

      final result = await repo.getCurrentList();
      expect(result, isNotNull);
      expect(result!.id, 'list-1');
      expect(result.name, 'Minha lista');
    });

    test('does not return completed lists', () async {
      final completed = makeList(id: 'list-completed', isCompleted: true);
      await repo.saveCurrentList(completed);

      final result = await repo.getCurrentList();
      expect(result, isNull);
    });
  });

  group('saveCurrentList', () {
    test('saves list with items', () async {
      final item = makeItem();
      final list = makeList(items: [item]);
      await repo.saveCurrentList(list);

      final result = await repo.getCurrentList();
      expect(result!.items, hasLength(1));
      expect(result.items.first.id, 'item-1');
      expect(result.items.first.productName, 'Pão');
    });

    test('upserts existing list on second save', () async {
      final list = makeList();
      await repo.saveCurrentList(list);

      final updated = list.copyWith(name: 'Lista atualizada');
      await repo.saveCurrentList(updated);

      final result = await repo.getCurrentList();
      expect(result!.name, 'Lista atualizada');

      // Verify only one row in DB (upsert, not duplicate insert)
      final rows = await db.select(db.shoppingListsTable).get();
      expect(rows, hasLength(1));
    });

    test('saves list with items and replaces old items on update', () async {
      final item1 = makeItem(id: 'item-1', position: 0);
      final item2 = makeItem(id: 'item-2', name: 'Leite', position: 1);
      final list = makeList(items: [item1, item2]);
      await repo.saveCurrentList(list);

      final updatedList = makeList(items: [item1]);
      await repo.saveCurrentList(updatedList);

      final result = await repo.getCurrentList();
      expect(result!.items, hasLength(1));
    });
  });

  group('getSavedLists', () {
    test('returns empty list when none exist', () async {
      final result = await repo.getSavedLists();
      expect(result, isEmpty);
    });

    test('returns all non-current lists (templates and completed)', () async {
      final template = makeList(id: 'tmpl-1', isTemplate: true);
      final toComplete = makeList(id: 'completed-1');
      final current = makeList(id: 'current-1');

      await repo.saveCurrentList(current);
      await repo.saveAsTemplate(template);
      await repo.saveCurrentList(toComplete);
      await repo.finalizePurchase(toComplete);

      final saved = await repo.getSavedLists();
      final ids = saved.map((l) => l.id).toSet();
      expect(ids, contains('tmpl-1'));
      expect(ids, contains('completed-1'));
    });
  });

  group('getListById', () {
    test('returns list when found', () async {
      final list = makeList();
      await repo.saveCurrentList(list);

      final result = await repo.getListById('list-1');
      expect(result.id, 'list-1');
    });

    test('throws NotFoundFailure when not found', () async {
      expect(
        () => repo.getListById('nonexistent'),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  group('deleteList', () {
    test('deletes list and its items', () async {
      final item = makeItem();
      final list = makeList(items: [item]);
      await repo.saveCurrentList(list);

      await repo.deleteList('list-1');

      final result = await repo.getCurrentList();
      expect(result, isNull);
    });

    test('throws NotFoundFailure when deleting nonexistent list', () async {
      expect(
        () => repo.deleteList('nonexistent'),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  group('saveAsTemplate', () {
    test('saves list as template', () async {
      final list = makeList(id: 'tmpl-1', isTemplate: true);
      await repo.saveAsTemplate(list);

      final result = await repo.getListById('tmpl-1');
      expect(result.isTemplate, true);
    });
  });

  group('finalizePurchase', () {
    test('marks list as completed and creates purchase snapshot', () async {
      final item = makeItem();
      final list = makeList(items: [item]);
      await repo.saveCurrentList(list);

      await repo.finalizePurchase(list);

      final result = await repo.getListById('list-1');
      expect(result.isCompleted, true);

      final purchases = await db.select(db.purchasesTable).get();
      expect(purchases, hasLength(1));
      expect(purchases.first.totalAmountCents, item.totalPrice.cents);

      final purchaseItems = await db.select(db.purchaseItemsTable).get();
      expect(purchaseItems, hasLength(1));
      expect(purchaseItems.first.productName, 'Pão');
    });

    test('finalizePurchase preserves original item data in snapshot', () async {
      final item = makeItem(name: 'Chocolate');
      final list = makeList(items: [item]);
      await repo.saveCurrentList(list);
      await repo.finalizePurchase(list);

      final purchaseItems = await db.select(db.purchaseItemsTable).get();
      expect(purchaseItems.first.productName, 'Chocolate');
      expect(purchaseItems.first.unitPriceCents, 500);
    });

    test(
      'finalizePurchase with budgetGoal records exceededBudget flag',
      () async {
        final item = makeItem();
        final list = makeList(items: [item], budgetGoal: Money.fromCents(100));
        await repo.saveCurrentList(list);
        await repo.finalizePurchase(list);

        final purchases = await db.select(db.purchasesTable).get();
        expect(purchases.first.exceededBudget, true);
      },
    );
  });

  group('watchCurrentList', () {
    test('emits null when no list exists', () async {
      final stream = repo.watchCurrentList();
      expect(await stream.first, isNull);
    });

    test('emits list after saving', () async {
      final list = makeList();

      final streamFuture = expectLater(
        repo.watchCurrentList().take(2),
        emitsInOrder([isNull, isA<ShoppingList>()]),
      );

      // Let initial emission happen before saving
      await Future<void>.delayed(Duration.zero);
      await repo.saveCurrentList(list);

      await streamFuture.timeout(const Duration(seconds: 5));
    });

    test('emits updated list on change', () async {
      final list = makeList();
      await repo.saveCurrentList(list);

      // After save, current list exists; next emission updates the name
      final emitted = <String?>[];
      final sub = repo.watchCurrentList().listen((l) => emitted.add(l?.name));

      await Future<void>.delayed(Duration.zero);
      await repo.saveCurrentList(list.copyWith(name: 'Nome novo'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await sub.cancel();

      expect(emitted, contains('Nome novo'));
    });
  });
}
