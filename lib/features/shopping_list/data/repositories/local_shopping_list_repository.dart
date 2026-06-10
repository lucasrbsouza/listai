import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../datasources/local/app_database.dart';
import '../models/shopping_item_mapper.dart';
import '../models/shopping_list_mapper.dart';
import '../../domain/entities/shopping_list.dart';
import '../../domain/repositories/shopping_list_repository.dart';

class LocalShoppingListRepository implements ShoppingListRepository {
  LocalShoppingListRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  @override
  Future<ShoppingList?> getCurrentList() async {
    final rows =
        await (_db.select(_db.shoppingListsTable)
              ..where(
                (t) => t.isCompleted.equals(false) & t.isTemplate.equals(false),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
              ..limit(1))
            .get();

    if (rows.isEmpty) return null;
    return _loadListWithItems(rows.first);
  }

  @override
  Future<void> saveCurrentList(final ShoppingList list) async {
    await _db.transaction(() async {
      final companion = ShoppingListMapper.toCompanion(list);
      await _db.into(_db.shoppingListsTable).insertOnConflictUpdate(companion);

      await (_db.delete(
        _db.shoppingItemsTable,
      )..where((t) => t.listId.equals(list.id))).go();

      for (final item in list.items) {
        final itemCompanion = ShoppingItemMapper.toCompanion(
          item,
          listId: list.id,
        );
        await _db.into(_db.shoppingItemsTable).insert(itemCompanion);
      }
    });
  }

  @override
  Future<List<ShoppingList>> getSavedLists() async {
    final rows = await (_db.select(
      _db.shoppingListsTable,
    )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();

    return Future.wait(rows.map(_loadListWithItems));
  }

  @override
  Future<ShoppingList> getListById(final String id) async {
    final row = await (_db.select(
      _db.shoppingListsTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();

    if (row == null) throw NotFoundFailure('List not found: $id');
    return _loadListWithItems(row);
  }

  @override
  Future<void> saveAsTemplate(final ShoppingList list) async {
    final template = list.copyWith(isTemplate: true);
    await saveCurrentList(template);
  }

  @override
  Future<void> deleteList(final String id) async {
    final count = await (_db.delete(
      _db.shoppingListsTable,
    )..where((t) => t.id.equals(id))).go();

    if (count == 0) throw NotFoundFailure('List not found: $id');
  }

  @override
  Future<void> finalizePurchase(final ShoppingList list) async {
    await _db.transaction(() async {
      final purchaseId = _uuid.v4();
      final totalCents = list.totalPrice.cents;
      final exceeds = list.exceedsBudget;

      await _db
          .into(_db.purchasesTable)
          .insert(
            PurchasesTableCompanion.insert(
              id: purchaseId,
              userId: list.userId ?? 'offline',
              listId: list.id,
              marketName: Value(list.marketName),
              totalAmountCents: totalCents,
              budgetGoalCents: Value(list.budgetGoal?.cents),
              exceededBudget: Value(exceeds),
              completedAt: DateTime.now(),
            ),
          );

      for (final item in list.items) {
        await _db
            .into(_db.purchaseItemsTable)
            .insert(
              PurchaseItemsTableCompanion.insert(
                id: _uuid.v4(),
                purchaseId: purchaseId,
                productType: item.productType,
                productName: item.productName,
                quantityValue: item.quantity.value,
                unitPriceCents: item.unitPrice?.cents ?? 0,
                totalPriceCents: item.totalPrice.cents,
              ),
            );
      }

      await (_db.update(
        _db.shoppingListsTable,
      )..where((t) => t.id.equals(list.id))).write(
        ShoppingListsTableCompanion(
          isCompleted: const Value(true),
          completedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  @override
  Stream<ShoppingList?> watchCurrentList() {
    return (_db.select(_db.shoppingListsTable)
          ..where(
            (t) => t.isCompleted.equals(false) & t.isTemplate.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(1))
        .watch()
        .asyncMap((rows) async {
          if (rows.isEmpty) return null;
          return _loadListWithItems(rows.first);
        });
  }

  Future<ShoppingList> _loadListWithItems(
    final ShoppingListsTableData row,
  ) async {
    final itemRows =
        await (_db.select(_db.shoppingItemsTable)
              ..where((t) => t.listId.equals(row.id))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();

    return ShoppingListMapper.toEntity(row, itemRows);
  }
}
