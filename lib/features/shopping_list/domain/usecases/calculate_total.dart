import '../../../../core/utils/money.dart';
import '../entities/shopping_list.dart';

class CalculateTotal {
  Money call(final ShoppingList list) => list.totalPrice;
}
