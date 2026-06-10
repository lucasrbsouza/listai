import 'package:flutter_test/flutter_test.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/shopping_list/data/datasources/local/app_database.dart';
import 'package:listai/features/shopping_list/data/models/shopping_item_mapper.dart';
import 'package:listai/features/shopping_list/data/models/shopping_list_mapper.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';

void main() {
  final baseDate = DateTime(2024, 1, 15, 10, 0, 0);

  ShoppingListsTableData makeListRow({
    String id = 'list-1',
    String name = 'Compra do mês',
    String? userId,
    String? marketName,
    int? budgetGoalCents,
    bool isCompleted = false,
    bool isTemplate = false,
    DateTime? completedAt,
  }) => ShoppingListsTableData(
    id: id,
    userId: userId,
    name: name,
    marketName: marketName,
    budgetGoalCents: budgetGoalCents,
    isCompleted: isCompleted,
    isTemplate: isTemplate,
    completedAt: completedAt,
    createdAt: baseDate,
    updatedAt: baseDate,
  );

  ShoppingItemsTableData makeItemRow({
    String id = 'item-1',
    String listId = 'list-1',
    int position = 0,
  }) => ShoppingItemsTableData(
    id: id,
    listId: listId,
    productType: 'Padaria',
    productName: 'Pão',
    brand: null,
    quantityValue: 1.0,
    unitPriceCents: 500,
    isWholesale: false,
    isWeightBased: false,
    pricePerKgCents: null,
    weightKg: null,
    photoUrl: null,
    photoCapturedAt: null,
    substituteItemId: null,
    position: position,
    createdAt: baseDate,
  );

  group('ShoppingListMapper.toEntity', () {
    test('converts row to entity with no items', () {
      final row = makeListRow();
      final entity = ShoppingListMapper.toEntity(row, []);

      expect(entity.id, 'list-1');
      expect(entity.name, 'Compra do mês');
      expect(entity.items, isEmpty);
      expect(entity.isCompleted, false);
      expect(entity.isTemplate, false);
      expect(entity.userId, isNull);
      expect(entity.marketName, isNull);
      expect(entity.budgetGoal, isNull);
    });

    test('converts row with items correctly', () {
      final row = makeListRow();
      final itemRows = [
        makeItemRow(id: 'item-1', position: 0),
        makeItemRow(id: 'item-2', position: 1),
      ];
      final entity = ShoppingListMapper.toEntity(row, itemRows);

      expect(entity.items, hasLength(2));
      expect(entity.items.first.id, 'item-1');
      expect(entity.items.last.id, 'item-2');
    });

    test('converts budgetGoal from cents correctly', () {
      final row = makeListRow(budgetGoalCents: 10000);
      final entity = ShoppingListMapper.toEntity(row, []);

      expect(entity.budgetGoal, Money.fromCents(10000));
    });

    test('preserves userId and marketName', () {
      final row = makeListRow(userId: 'user-1', marketName: 'Carrefour');
      final entity = ShoppingListMapper.toEntity(row, []);

      expect(entity.userId, 'user-1');
      expect(entity.marketName, 'Carrefour');
    });

    test('converts completed list correctly', () {
      final completedAt = DateTime(2024, 2, 1);
      final row = makeListRow(isCompleted: true, completedAt: completedAt);
      final entity = ShoppingListMapper.toEntity(row, []);

      expect(entity.isCompleted, true);
      expect(entity.completedAt, completedAt);
    });

    test('converts template list correctly', () {
      final row = makeListRow(isTemplate: true);
      final entity = ShoppingListMapper.toEntity(row, []);

      expect(entity.isTemplate, true);
    });
  });

  group('ShoppingListMapper.toCompanion', () {
    test('converts entity to companion correctly', () {
      final entity = ShoppingList(
        id: 'list-1',
        name: 'Lista teste',
        createdAt: baseDate,
        updatedAt: baseDate,
      );

      final companion = ShoppingListMapper.toCompanion(entity);

      expect(companion.id.value, 'list-1');
      expect(companion.name.value, 'Lista teste');
      expect(companion.userId.value, isNull);
      expect(companion.budgetGoalCents.value, isNull);
      expect(companion.isCompleted.value, false);
    });

    test('converts budgetGoal to cents', () {
      final entity = ShoppingList(
        id: 'list-2',
        name: 'Lista com meta',
        budgetGoal: Money.fromCents(15000),
        createdAt: baseDate,
        updatedAt: baseDate,
      );

      final companion = ShoppingListMapper.toCompanion(entity);
      expect(companion.budgetGoalCents.value, 15000);
    });

    test('converts null budgetGoal correctly', () {
      final entity = ShoppingList(
        id: 'list-3',
        name: 'Sem meta',
        createdAt: baseDate,
        updatedAt: baseDate,
      );

      final companion = ShoppingListMapper.toCompanion(entity);
      expect(companion.budgetGoalCents.value, isNull);
    });
  });

  group('ShoppingListMapper round-trip', () {
    test('list without items round-trips without data loss', () {
      final original = ShoppingList(
        id: 'list-rt-1',
        userId: 'user-1',
        name: 'Round trip list',
        marketName: 'Mercadão',
        budgetGoal: Money.fromCents(20000),
        isCompleted: false,
        isTemplate: false,
        createdAt: baseDate,
        updatedAt: baseDate,
      );

      final companion = ShoppingListMapper.toCompanion(original);
      final row = ShoppingListsTableData(
        id: companion.id.value,
        userId: companion.userId.value,
        name: companion.name.value,
        marketName: companion.marketName.value,
        budgetGoalCents: companion.budgetGoalCents.value,
        isCompleted: companion.isCompleted.value,
        isTemplate: companion.isTemplate.value,
        completedAt: companion.completedAt.value,
        createdAt: companion.createdAt.value,
        updatedAt: companion.updatedAt.value,
      );
      final restored = ShoppingListMapper.toEntity(row, []);

      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.name, original.name);
      expect(restored.marketName, original.marketName);
      expect(restored.budgetGoal, original.budgetGoal);
      expect(restored.isCompleted, original.isCompleted);
      expect(restored.createdAt, original.createdAt);
    });

    test('list with items round-trips correctly', () {
      final item = ShoppingItem(
        id: 'item-rt-1',
        productType: 'Padaria',
        productName: 'Croissant',
        quantity: Quantity(3),
        unitPrice: Money.fromCents(450),
        position: 0,
        createdAt: baseDate,
      );
      final original = ShoppingList(
        id: 'list-rt-2',
        name: 'Lista com itens',
        items: [item],
        createdAt: baseDate,
        updatedAt: baseDate,
      );

      final itemCompanion = ShoppingItemMapper.toCompanion(
        item,
        listId: 'list-rt-2',
      );
      final itemRow = ShoppingItemsTableData(
        id: itemCompanion.id.value,
        listId: itemCompanion.listId.value,
        productType: itemCompanion.productType.value,
        productName: itemCompanion.productName.value,
        brand: itemCompanion.brand.value,
        quantityValue: itemCompanion.quantityValue.value,
        unitPriceCents: itemCompanion.unitPriceCents.value,
        isWholesale: itemCompanion.isWholesale.value,
        isWeightBased: itemCompanion.isWeightBased.value,
        pricePerKgCents: itemCompanion.pricePerKgCents.value,
        weightKg: itemCompanion.weightKg.value,
        photoUrl: itemCompanion.photoUrl.value,
        photoCapturedAt: itemCompanion.photoCapturedAt.value,
        substituteItemId: itemCompanion.substituteItemId.value,
        position: itemCompanion.position.value,
        createdAt: itemCompanion.createdAt.value,
      );

      final listCompanion = ShoppingListMapper.toCompanion(original);
      final listRow = ShoppingListsTableData(
        id: listCompanion.id.value,
        userId: listCompanion.userId.value,
        name: listCompanion.name.value,
        marketName: listCompanion.marketName.value,
        budgetGoalCents: listCompanion.budgetGoalCents.value,
        isCompleted: listCompanion.isCompleted.value,
        isTemplate: listCompanion.isTemplate.value,
        completedAt: listCompanion.completedAt.value,
        createdAt: listCompanion.createdAt.value,
        updatedAt: listCompanion.updatedAt.value,
      );

      final restored = ShoppingListMapper.toEntity(listRow, [itemRow]);

      expect(restored.items, hasLength(1));
      expect(restored.items.first.id, item.id);
      expect(restored.items.first.productName, item.productName);
      expect(restored.items.first.unitPrice, item.unitPrice);
    });
  });
}
