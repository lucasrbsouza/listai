import 'dart:async';
import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/entities/shopping_list.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import 'shopping_list_repository_provider.dart';
import '../../../../core/utils/money.dart';

final currentListProvider =
    StateNotifierProvider<CurrentListNotifier, AsyncValue<ShoppingList?>>((
      ref,
    ) {
      final repository = ref.watch(shoppingListRepositoryProvider);
      return CurrentListNotifier(repository);
    });

class CurrentListNotifier extends StateNotifier<AsyncValue<ShoppingList?>> {
  CurrentListNotifier(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  final ShoppingListRepository _repository;
  StreamSubscription<ShoppingList?>? _subscription;

  final Queue<ShoppingList> _history = Queue<ShoppingList>();
  static const int _maxHistorySize = 5;

  bool _isUndoing = false;

  void _init() {
    _subscription = _repository.watchCurrentList().listen(
      (list) {
        // If we are currently undoing or making local changes, we don't want to clear our state
        // if this was just a reflection of our own save. Actually, updating state is fine.
        // We only append to history in explicit actions.
        if (!_isUndoing) {
          state = AsyncValue.data(list);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _pushHistory(ShoppingList current) {
    if (_history.length >= _maxHistorySize) {
      _history.removeFirst();
    }
    _history.addLast(current);
  }

  Future<void> addItem(ShoppingItem item) async {
    final currentList = state.value;
    if (currentList == null) return;

    _pushHistory(currentList);

    final updatedItems = List<ShoppingItem>.from(currentList.items)..add(item);
    final updatedList = currentList.copyWith(items: updatedItems);

    await _updateStateAndRepository(updatedList);
  }

  Future<void> addItemWithSubstitute({
    required ShoppingItem main,
    required ShoppingItem substitute,
  }) async {
    final currentList = state.value;
    if (currentList == null) return;

    _pushHistory(currentList);

    final mainPosition = currentList.items.length;
    final linkedMain = main.copyWith(
      substituteItemId: substitute.id,
      position: mainPosition,
    );
    final linkedSubstitute = substitute.copyWith(
      clearSubstituteItemId: true,
      position: mainPosition + 1,
    );
    final updatedItems = List<ShoppingItem>.from(currentList.items)
      ..add(linkedMain)
      ..add(linkedSubstitute);
    final updatedList = currentList.copyWith(items: updatedItems);

    await _updateStateAndRepository(updatedList);
  }

  Future<void> removeItem(String itemId) async {
    final currentList = state.value;
    if (currentList == null) return;

    _pushHistory(currentList);

    final itemIndex = currentList.items.indexWhere((i) => i.id == itemId);
    final item = itemIndex == -1 ? null : currentList.items[itemIndex];
    final removedIds = <String>{itemId};
    if (item?.substituteItemId != null) {
      removedIds.add(item!.substituteItemId!);
    }

    final updatedItems = currentList.items
        .where((i) => !removedIds.contains(i.id))
        .map((i) {
          if (i.substituteItemId != null &&
              removedIds.contains(i.substituteItemId)) {
            return i.copyWith(clearSubstituteItemId: true);
          }
          return i;
        })
        .toList();
    final updatedList = currentList.copyWith(items: updatedItems);

    await _updateStateAndRepository(updatedList);
  }

  Future<void> updateItem(ShoppingItem updatedItem) async {
    final currentList = state.value;
    if (currentList == null) return;

    _pushHistory(currentList);

    final updatedItems = currentList.items.map((i) {
      return i.id == updatedItem.id ? updatedItem : i;
    }).toList();
    final updatedList = currentList.copyWith(items: updatedItems);

    await _updateStateAndRepository(updatedList);
  }

  Future<void> swapWithSubstitute(String mainItemId) async {
    final currentList = state.value;
    if (currentList == null) return;

    final mainIndex = currentList.items.indexWhere(
      (item) => item.id == mainItemId,
    );
    if (mainIndex == -1) return;

    final main = currentList.items[mainIndex];
    final substituteId = main.substituteItemId;
    if (substituteId == null) return;

    final substituteIndex = currentList.items.indexWhere(
      (item) => item.id == substituteId,
    );
    if (substituteIndex == -1) return;

    _pushHistory(currentList);

    final substitute = currentList.items[substituteIndex];
    final newMain = substitute.copyWith(
      substituteItemId: main.id,
      position: main.position,
    );
    final newSubstitute = main.copyWith(
      clearSubstituteItemId: true,
      position: substitute.position,
    );

    final updatedItems = currentList.items.map((item) {
      if (item.id == main.id) return newSubstitute;
      if (item.id == substitute.id) return newMain;
      return item;
    }).toList();

    final updatedList = currentList.copyWith(items: updatedItems);

    await _updateStateAndRepository(updatedList);
  }

  Future<void> clearAll() async {
    final currentList = state.value;
    if (currentList == null) return;

    _pushHistory(currentList);

    final updatedList = currentList.copyWith(items: []);

    await _updateStateAndRepository(updatedList);
  }

  Future<void> finalizePurchase() async {
    final currentList = state.value;
    if (currentList == null) return;

    try {
      await _repository.finalizePurchase(currentList);
      state = const AsyncValue.data(null);
      _history.clear();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> replaceWithTemplate(ShoppingList template) async {
    final currentList = state.value;
    if (currentList != null) {
      _pushHistory(currentList);
    } else {
      // If no current list, we just push an empty one to history if we want
      // but null cannot be pushed since _history is Queue<ShoppingList>.
      // Actually it's fine, we just replace it.
    }

    // A template might share item IDs. To be safe, we might need to recreate them,
    // but the backend/drift layer will just upsert. Still, we should probably generate a new List ID.
    // However, if we just use the UUID from Uuid(), we'd need to import it.
    // For now, let's just create a new list with the same name and items.
    // Wait, let's use the template as is, but change its id, isTemplate to false,
    // and createdAt to now.

    // We need uuid to generate list ID. Let's add it to import later or use a temporary approach.
    // Wait, the repository's `saveCurrentList` might not care if we reuse the template's ID?
    // No, if it's the same ID, it overwrites the template!
    // It must be a new ID.
    final DateTime now = DateTime.now();
    const uuid = Uuid();

    // Also, we must assign new UUIDs to the items, otherwise they might overwrite the template's items
    // depending on the DB schema. If the DB links items to a listId, they might need new IDs anyway.
    final newItems = template.items
        .map((i) => i.copyWith(id: uuid.v4()))
        .toList();

    final newList = ShoppingList(
      id: uuid.v4(),
      name: template.name,
      items: newItems,
      isTemplate: false,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );

    await _updateStateAndRepository(newList);
  }

  Future<void> updateBudgetGoal(Money? budgetGoal) async {
    final currentList = state.value;
    if (currentList == null) return;

    _pushHistory(currentList);

    final updatedList = currentList.copyWith(
      budgetGoal: budgetGoal,
      clearBudgetGoal: budgetGoal == null,
    );

    await _updateStateAndRepository(updatedList);
  }

  Future<void> saveAsTemplate() async {
    final currentList = state.value;
    if (currentList == null) return;
    try {
      await _repository.saveAsTemplate(currentList);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> undo() async {
    if (_history.isEmpty) return;

    _isUndoing = true;
    final previousState = _history.removeLast();

    try {
      await _repository.saveCurrentList(previousState);
      state = AsyncValue.data(previousState);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } finally {
      _isUndoing = false;
    }
  }

  Future<void> _updateStateAndRepository(ShoppingList updatedList) async {
    try {
      state = AsyncValue.data(updatedList);
      await _repository.saveCurrentList(updatedList);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
