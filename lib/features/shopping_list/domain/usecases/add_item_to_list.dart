import '../entities/shopping_item.dart';
import '../entities/shopping_list.dart';

class AddItemToList {
  ShoppingList call(final ShoppingList list, final ShoppingItem item) {
    final nextPosition =
        list.items.isEmpty ? 0 : list.items.last.position + 1;
    final positioned = item.copyWith(position: nextPosition);
    return list.addItem(positioned);
  }
}
