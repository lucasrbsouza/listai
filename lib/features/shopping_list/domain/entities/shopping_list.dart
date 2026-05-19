import 'package:meta/meta.dart';

import '../../../../core/utils/money.dart';
import 'shopping_item.dart';

@immutable
class ShoppingList {

  factory ShoppingList({
    required final String id,
    final String? userId,
    required final String name,
    final String? marketName,
    final Money? budgetGoal,
    final List<ShoppingItem> items = const [],
    final bool isCompleted = false,
    final bool isTemplate = false,
    final DateTime? completedAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) {
    if (name.isEmpty) throw ArgumentError('name cannot be empty');
    if (name.length > 100) throw ArgumentError('name max 100 chars');
    if (marketName != null && marketName.length > 100) {
      throw ArgumentError('marketName max 100 chars');
    }
    final ids = items.map((e) => e.id).toSet();
    if (ids.length != items.length) {
      throw ArgumentError('items cannot have duplicate IDs');
    }
    final sorted = [...items]..sort((a, b) => a.position.compareTo(b.position));
    return ShoppingList._(
      id: id,
      userId: userId,
      name: name,
      marketName: marketName,
      budgetGoal: budgetGoal,
      items: List.unmodifiable(sorted),
      isCompleted: isCompleted,
      isTemplate: isTemplate,
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
  const ShoppingList._({
    required this.id,
    required this.userId,
    required this.name,
    required this.marketName,
    required this.budgetGoal,
    required this.items,
    required this.isCompleted,
    required this.isTemplate,
    required this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? userId;
  final String name;
  final String? marketName;
  final Money? budgetGoal;
  final List<ShoppingItem> items;
  final bool isCompleted;
  final bool isTemplate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Money get totalPrice => items.fold(
        const Money.zero(),
        (final total, final item) => total + item.totalPrice,
      );

  int get itemCount => items.length;

  bool get exceedsBudget =>
      budgetGoal != null && totalPrice > budgetGoal!;

  Money get amountOverBudget {
    if (!exceedsBudget) return const Money.zero();
    return totalPrice - budgetGoal!;
  }

  ShoppingList addItem(final ShoppingItem item) {
    return copyWith(items: [...items, item]);
  }

  ShoppingList removeItem(final String itemId) {
    final idx = items.indexWhere((i) => i.id == itemId);
    if (idx == -1) throw StateError('Item not found: $itemId');
    final remaining = [...items]..removeAt(idx);
    final reindexed = remaining
        .asMap()
        .entries
        .map((e) => e.value.copyWith(position: e.key))
        .toList();
    return copyWith(items: reindexed);
  }

  ShoppingList updateItem(final ShoppingItem item) {
    final idx = items.indexWhere((i) => i.id == item.id);
    if (idx == -1) throw StateError('Item not found: ${item.id}');
    final updated = [...items]..[idx] = item;
    return copyWith(items: updated);
  }

  ShoppingList reorder(final String itemId, final int newPosition) {
    final idx = items.indexWhere((i) => i.id == itemId);
    if (idx == -1) throw StateError('Item not found: $itemId');
    final mutable = [...items]..removeAt(idx);
    final clamped = newPosition.clamp(0, mutable.length);
    mutable.insert(clamped, items[idx]);
    final reindexed = mutable
        .asMap()
        .entries
        .map((e) => e.value.copyWith(position: e.key))
        .toList();
    return copyWith(items: reindexed);
  }

  ShoppingList copyWith({
    final String? id,
    final String? userId,
    final bool clearUserId = false,
    final String? name,
    final String? marketName,
    final bool clearMarketName = false,
    final Money? budgetGoal,
    final bool clearBudgetGoal = false,
    final List<ShoppingItem>? items,
    final bool? isCompleted,
    final bool? isTemplate,
    final DateTime? completedAt,
    final bool clearCompletedAt = false,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      userId: clearUserId ? null : (userId ?? this.userId),
      name: name ?? this.name,
      marketName: clearMarketName ? null : (marketName ?? this.marketName),
      budgetGoal: clearBudgetGoal ? null : (budgetGoal ?? this.budgetGoal),
      items: items ?? this.items,
      isCompleted: isCompleted ?? this.isCompleted,
      isTemplate: isTemplate ?? this.isTemplate,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(final Object other) =>
      other is ShoppingList && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
