import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listai/features/shopping_list/data/datasources/local/app_database.dart';

import '../../../../../helpers/sqlite_test_helper.dart';

void main() {
  setUpAll(configureSqliteForTests);

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('ShoppingListsTable', () {
    test('inserts and retrieves a list', () async {
      final now = DateTime.now();
      await db.into(db.shoppingListsTable).insert(
            ShoppingListsTableCompanion.insert(
              id: 'list-1',
              name: 'Compra do mês',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final rows = await db.select(db.shoppingListsTable).get();
      expect(rows, hasLength(1));
      expect(rows.first.id, 'list-1');
      expect(rows.first.name, 'Compra do mês');
      expect(rows.first.syncStatus, 'synced');
      expect(rows.first.isCompleted, false);
      expect(rows.first.isTemplate, false);
    });

    test('nullable fields default to null', () async {
      final now = DateTime.now();
      await db.into(db.shoppingListsTable).insert(
            ShoppingListsTableCompanion.insert(
              id: 'list-2',
              name: 'Lista simples',
              createdAt: now,
              updatedAt: now,
            ),
          );

      final row =
          await (db.select(db.shoppingListsTable)..where((t) => t.id.equals('list-2')))
              .getSingle();
      expect(row.userId, isNull);
      expect(row.marketName, isNull);
      expect(row.budgetGoalCents, isNull);
      expect(row.completedAt, isNull);
    });

    test('updates a list', () async {
      final now = DateTime.now();
      await db.into(db.shoppingListsTable).insert(
            ShoppingListsTableCompanion.insert(
              id: 'list-3',
              name: 'Lista original',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await (db.update(db.shoppingListsTable)..where((t) => t.id.equals('list-3')))
          .write(const ShoppingListsTableCompanion(name: Value('Lista atualizada')));

      final row =
          await (db.select(db.shoppingListsTable)..where((t) => t.id.equals('list-3')))
              .getSingle();
      expect(row.name, 'Lista atualizada');
    });

    test('deletes a list', () async {
      final now = DateTime.now();
      await db.into(db.shoppingListsTable).insert(
            ShoppingListsTableCompanion.insert(
              id: 'list-4',
              name: 'Para deletar',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await (db.delete(db.shoppingListsTable)..where((t) => t.id.equals('list-4'))).go();

      final rows = await db.select(db.shoppingListsTable).get();
      expect(rows, isEmpty);
    });

    test('retrieves multiple lists', () async {
      final now = DateTime.now();
      for (var i = 1; i <= 3; i++) {
        await db.into(db.shoppingListsTable).insert(
              ShoppingListsTableCompanion.insert(
                id: 'list-$i',
                name: 'Lista $i',
                createdAt: now,
                updatedAt: now,
              ),
            );
      }

      final rows = await db.select(db.shoppingListsTable).get();
      expect(rows, hasLength(3));
    });
  });

  group('ShoppingItemsTable', () {
    late String listId;

    setUp(() async {
      listId = 'list-items-1';
      final now = DateTime.now();
      await db.into(db.shoppingListsTable).insert(
            ShoppingListsTableCompanion.insert(
              id: listId,
              name: 'Lista com itens',
              createdAt: now,
              updatedAt: now,
            ),
          );
    });

    test('inserts and retrieves an item', () async {
      final now = DateTime.now();
      await db.into(db.shoppingItemsTable).insert(
            ShoppingItemsTableCompanion.insert(
              id: 'item-1',
              listId: listId,
              productType: 'Padaria',
              productName: 'Pão de forma',
              quantityValue: 2.0,
              unitPriceCents: 599,
              position: 0,
              createdAt: now,
            ),
          );

      final rows = await db.select(db.shoppingItemsTable).get();
      expect(rows, hasLength(1));
      expect(rows.first.productName, 'Pão de forma');
      expect(rows.first.unitPriceCents, 599);
      expect(rows.first.syncStatus, 'synced');
    });

    test('item nullable fields default to null', () async {
      final now = DateTime.now();
      await db.into(db.shoppingItemsTable).insert(
            ShoppingItemsTableCompanion.insert(
              id: 'item-2',
              listId: listId,
              productType: 'Carnes',
              productName: 'Frango',
              quantityValue: 1.0,
              unitPriceCents: 1500,
              position: 0,
              createdAt: now,
            ),
          );

      final row =
          await (db.select(db.shoppingItemsTable)..where((t) => t.id.equals('item-2')))
              .getSingle();
      expect(row.brand, isNull);
      expect(row.pricePerKgCents, isNull);
      expect(row.weightKg, isNull);
      expect(row.photoUrl, isNull);
      expect(row.photoCapturedAt, isNull);
      expect(row.substituteItemId, isNull);
    });

    test('cascade deletes items when list is deleted', () async {
      final now = DateTime.now();
      for (var i = 1; i <= 3; i++) {
        await db.into(db.shoppingItemsTable).insert(
              ShoppingItemsTableCompanion.insert(
                id: 'item-cascade-$i',
                listId: listId,
                productType: 'Mercado',
                productName: 'Item $i',
                quantityValue: 1.0,
                unitPriceCents: 100,
                position: i - 1,
                createdAt: now,
              ),
            );
      }

      expect(await db.select(db.shoppingItemsTable).get(), hasLength(3));

      await (db.delete(db.shoppingListsTable)..where((t) => t.id.equals(listId))).go();

      final items = await db.select(db.shoppingItemsTable).get();
      expect(items, isEmpty);
    });

    test('weight-based item stores pricePerKgCents and weightKg', () async {
      final now = DateTime.now();
      await db.into(db.shoppingItemsTable).insert(
            ShoppingItemsTableCompanion.insert(
              id: 'item-kg',
              listId: listId,
              productType: 'Carnes',
              productName: 'Picanha',
              quantityValue: 1.0,
              unitPriceCents: 0,
              isWeightBased: const Value(true),
              pricePerKgCents: const Value(8000),
              weightKg: const Value(0.5),
              position: 0,
              createdAt: now,
            ),
          );

      final row =
          await (db.select(db.shoppingItemsTable)..where((t) => t.id.equals('item-kg')))
              .getSingle();
      expect(row.isWeightBased, true);
      expect(row.pricePerKgCents, 8000);
      expect(row.weightKg, 0.5);
    });
  });

  group('PurchasesTable', () {
    late String listId;

    setUp(() async {
      listId = 'list-purchase-1';
      final now = DateTime.now();
      await db.into(db.shoppingListsTable).insert(
            ShoppingListsTableCompanion.insert(
              id: listId,
              name: 'Compra finalizada',
              createdAt: now,
              updatedAt: now,
            ),
          );
    });

    test('inserts and retrieves a purchase', () async {
      final now = DateTime.now();
      await db.into(db.purchasesTable).insert(
            PurchasesTableCompanion.insert(
              id: 'purchase-1',
              userId: 'user-1',
              listId: listId,
              totalAmountCents: 5000,
              completedAt: now,
            ),
          );

      final rows = await db.select(db.purchasesTable).get();
      expect(rows, hasLength(1));
      expect(rows.first.totalAmountCents, 5000);
      expect(rows.first.exceededBudget, false);
    });
  });

  group('PurchaseItemsTable', () {
    late String purchaseId;

    setUp(() async {
      final now = DateTime.now();
      const listId = 'list-pi-1';
      await db.into(db.shoppingListsTable).insert(
            ShoppingListsTableCompanion.insert(
              id: listId,
              name: 'Lista',
              createdAt: now,
              updatedAt: now,
            ),
          );
      purchaseId = 'purchase-pi-1';
      await db.into(db.purchasesTable).insert(
            PurchasesTableCompanion.insert(
              id: purchaseId,
              userId: 'user-1',
              listId: listId,
              totalAmountCents: 2000,
              completedAt: now,
            ),
          );
    });

    test('inserts purchase items linked to a purchase', () async {
      await db.into(db.purchaseItemsTable).insert(
            PurchaseItemsTableCompanion.insert(
              id: 'pi-1',
              purchaseId: purchaseId,
              productType: 'Padaria',
              productName: 'Pão',
              quantityValue: 1.0,
              unitPriceCents: 500,
              totalPriceCents: 500,
            ),
          );

      final rows = await db.select(db.purchaseItemsTable).get();
      expect(rows, hasLength(1));
      expect(rows.first.productName, 'Pão');
      expect(rows.first.totalPriceCents, 500);
    });
  });
}
