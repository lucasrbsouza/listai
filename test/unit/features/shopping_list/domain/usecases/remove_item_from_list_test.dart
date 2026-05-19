import 'package:flutter_test/flutter_test.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/domain/usecases/add_item_to_list.dart';
import 'package:listai/features/shopping_list/domain/usecases/remove_item_from_list.dart';

ShoppingItem _item(String id) => ShoppingItem(
      id: id,
      productType: 'T',
      productName: 'P',
      quantity: Quantity.unit(),
      unitPrice: Money.fromReais(1),
      position: 0,
      createdAt: DateTime(2024),
    );

void main() {
  final add = AddItemToList();
  final remove = RemoveItemFromList();

  test('removes item from list', () {
    var list = ShoppingList(
      id: 'l',
      name: 'L',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
    list = add(list, _item('a'));
    list = add(list, _item('b'));
    final result = remove(list, 'a');
    expect(result.items.any((i) => i.id == 'a'), isFalse);
    expect(result.items.length, 1);
  });

  test('positions are reindexed after removal', () {
    var list = ShoppingList(
      id: 'l',
      name: 'L',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
    list = add(list, _item('a'));
    list = add(list, _item('b'));
    list = add(list, _item('c'));
    final result = remove(list, 'b');
    expect(result.items[0].position, 0);
    expect(result.items[1].position, 1);
  });

  test('remove from empty list throws StateError', () {
    final list = ShoppingList(
      id: 'l',
      name: 'L',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
    expect(() => remove(list, 'nonexistent'), throwsStateError);
  });

  test('remove unknown id throws StateError', () {
    var list = ShoppingList(
      id: 'l',
      name: 'L',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
    list = add(list, _item('a'));
    expect(() => remove(list, 'unknown'), throwsStateError);
  });

  test('original list is not mutated', () {
    var list = ShoppingList(
      id: 'l',
      name: 'L',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
    list = add(list, _item('a'));
    remove(list, 'a');
    expect(list.items.length, 1);
  });
}
