import 'package:drift/drift.dart' show Value;

import '../../../../core/utils/money.dart';
import '../datasources/local/app_database.dart';
import '../../domain/entities/shopping_list.dart';
import 'shopping_item_mapper.dart';

abstract class ShoppingListMapper {
  static ShoppingList toEntity(
    ShoppingListsTableData row,
    List<ShoppingItemsTableData> itemRows,
  ) {
    return ShoppingList(
      id: row.id,
      userId: row.userId,
      name: row.name,
      marketName: row.marketName,
      budgetGoal: row.budgetGoalCents != null
          ? Money.fromCents(row.budgetGoalCents!)
          : null,
      items: itemRows.map(ShoppingItemMapper.toEntity).toList(),
      isCompleted: row.isCompleted,
      isTemplate: row.isTemplate,
      completedAt: row.completedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static ShoppingListsTableCompanion toCompanion(ShoppingList entity) {
    return ShoppingListsTableCompanion(
      id: Value(entity.id),
      userId: Value(entity.userId),
      name: Value(entity.name),
      marketName: Value(entity.marketName),
      budgetGoalCents: Value(entity.budgetGoal?.cents),
      isCompleted: Value(entity.isCompleted),
      isTemplate: Value(entity.isTemplate),
      completedAt: Value(entity.completedAt),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }
}
