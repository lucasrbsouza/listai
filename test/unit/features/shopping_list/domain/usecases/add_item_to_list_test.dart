import 'package:flutter_test/flutter_test.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/domain/usecases/add_item_to_list.dart';

ShoppingItem _item(String id, {int position = 0}) {
  return ShoppingItem(
    id: id,
    productType: 'T',
    productName: 'P',
    quantity: Quantity.unit(),
    unitPrice: Money.fromReais(1),
    position: position,
    createdAt: DateTime(2024),
  );
}

ShoppingList _emptyList() => ShoppingList(
      id: 'list-1',
      name: 'Test',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

void main() {
  final useCase = AddItemToList();

  test('adds item to empty list with position 0', () {
    final result = useCase(_emptyList(), _item('a'));
    expect(result.items.length, 1);
    expect(result.items.first.position, 0);
  });

  test('adds item after existing items with correct position', () {
    final list = useCase(_emptyList(), _item('a'));
    final list2 = useCase(list, _item('b'));
    expect(list2.items.length, 2);
    expect(list2.items.last.position, 1);
  });

  test('adding duplicate id throws', () {
    final list = useCase(_emptyList(), _item('a'));
    expect(() => useCase(list, _item('a')), throwsArgumentError);
  });

  test('original list is not mutated', () {
    final original = _emptyList();
    useCase(original, _item('a'));
    expect(original.items.isEmpty, isTrue);
  });

  test('returns ShoppingList with item included', () {
    final result = useCase(_emptyList(), _item('x'));
    expect(result.items.any((i) => i.id == 'x'), isTrue);
  });
}
