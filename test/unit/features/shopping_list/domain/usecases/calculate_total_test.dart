import 'package:flutter_test/flutter_test.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/domain/usecases/calculate_total.dart';

ShoppingItem _item(String id, Money price, {int position = 0}) => ShoppingItem(
      id: id,
      productType: 'T',
      productName: 'P',
      quantity: Quantity.unit(),
      unitPrice: price,
      position: position,
      createdAt: DateTime(2024),
    );

void main() {
  final useCase = CalculateTotal();

  test('empty list returns zero', () {
    final list = ShoppingList(
      id: 'l',
      name: 'L',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
    expect(useCase(list), equals(const Money.zero()));
  });

  test('sums all item prices', () {
    final list = ShoppingList(
      id: 'l',
      name: 'L',
      items: [
        _item('a', Money.fromReais(10), position: 0),
        _item('b', Money.fromReais(5), position: 1),
        _item('c', Money.fromReais(3), position: 2),
      ],
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
    expect(useCase(list).cents, 1800);
  });

  test('single item returns that item totalPrice', () {
    final list = ShoppingList(
      id: 'l',
      name: 'L',
      items: [_item('a', Money.fromReais(7.50))],
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
    expect(useCase(list).cents, 750);
  });

  test('result matches list.totalPrice', () {
    final list = ShoppingList(
      id: 'l',
      name: 'L',
      items: [
        _item('a', Money.fromReais(10), position: 0),
        _item('b', Money.fromReais(20), position: 1),
      ],
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
    expect(useCase(list), equals(list.totalPrice));
  });
}
