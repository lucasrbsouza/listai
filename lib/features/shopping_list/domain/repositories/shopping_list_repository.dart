import '../entities/shopping_list.dart';

abstract class ShoppingListRepository {
  Future<ShoppingList?> getCurrentList();
  Future<void> saveCurrentList(final ShoppingList list);
  Future<List<ShoppingList>> getSavedLists();
  Future<ShoppingList> getListById(final String id);
  Future<void> saveAsTemplate(final ShoppingList list);
  Future<void> deleteList(final String id);
  Future<void> finalizePurchase(final ShoppingList list);
  Stream<ShoppingList?> watchCurrentList();
}
