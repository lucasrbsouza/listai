import '../entities/shopping_list.dart';

class RemoveItemFromList {
  ShoppingList call(final ShoppingList list, final String itemId) {
    return list.removeItem(itemId);
  }
}
