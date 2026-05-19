import 'package:flutter_test/flutter_test.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';

ShoppingItem _item({
  String id = 'item-1',
  Money? unitPrice,
  Quantity? quantity,
  int position = 0,
}) {
  return ShoppingItem(
    id: id,
    productType: 'Mercearia',
    productName: 'Produto',
    quantity: quantity ?? Quantity.unit(),
    unitPrice: unitPrice ?? Money.fromReais(10.00),
    position: position,
    createdAt: DateTime(2024),
  );
}

ShoppingList _list({
  List<ShoppingItem> items = const [],
  Money? budgetGoal,
}) {
  return ShoppingList(
    id: 'list-1',
    name: 'Compra do mês',
    items: items,
    budgetGoal: budgetGoal,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

void main() {
  group('ShoppingList total', () {
    test('empty list totalPrice is zero', () {
      expect(_list().totalPrice, equals(const Money.zero()));
    });

    test('sums totalPrice of all items', () {
      final items = [
        _item(id: 'a', unitPrice: Money.fromReais(10), quantity: Quantity(2), position: 0),
        _item(id: 'b', unitPrice: Money.fromReais(5), quantity: Quantity(1), position: 1),
      ];
      expect(_list(items: items).totalPrice.cents, 2500);
    });

    test('mixes weight-based and retail items', () {
      final retail = ShoppingItem(
        id: 'a',
        productType: 'T',
        productName: 'P',
        quantity: Quantity(2),
        unitPrice: Money.fromReais(5.00),
        position: 0,
        createdAt: DateTime(2024),
      );
      final byKg = ShoppingItem(
        id: 'b',
        productType: 'T',
        productName: 'Carne',
        quantity: Quantity.unit(),
        unitPrice: const Money.zero(),
        isWeightBased: true,
        pricePerKg: Money.fromReais(40.00),
        weightKg: Quantity(0.5),
        position: 1,
        createdAt: DateTime(2024),
      );
      expect(_list(items: [retail, byKg]).totalPrice.cents, 3000);
    });
  });

  group('ShoppingList budget', () {
    test('exceedsBudget false when no budget set', () {
      expect(_list().exceedsBudget, isFalse);
    });

    test('exceedsBudget false when within budget', () {
      final items = [_item(unitPrice: Money.fromReais(5))];
      final list = _list(items: items, budgetGoal: Money.fromReais(10));
      expect(list.exceedsBudget, isFalse);
    });

    test('exceedsBudget true when total exceeds goal', () {
      final items = [_item(unitPrice: Money.fromReais(15))];
      final list = _list(items: items, budgetGoal: Money.fromReais(10));
      expect(list.exceedsBudget, isTrue);
    });

    test('amountOverBudget is zero when within budget', () {
      expect(_list(budgetGoal: Money.fromReais(100)).amountOverBudget, equals(const Money.zero()));
    });

    test('amountOverBudget correct when exceeded', () {
      final items = [_item(unitPrice: Money.fromReais(15))];
      final list = _list(items: items, budgetGoal: Money.fromReais(10));
      expect(list.amountOverBudget.cents, 500);
    });

    test('amountOverBudget zero when no budget set', () {
      final items = [_item(unitPrice: Money.fromReais(100))];
      expect(_list(items: items).amountOverBudget, equals(const Money.zero()));
    });
  });

  group('ShoppingList immutable operations', () {
    test('addItem returns new instance', () {
      final list = _list();
      final newList = list.addItem(_item());
      expect(identical(list, newList), isFalse);
      expect(list.items.isEmpty, isTrue);
      expect(newList.items.length, 1);
    });

    test('removeItem returns new instance without item', () {
      final list = _list(items: [_item(id: 'x', position: 0)]);
      final newList = list.removeItem('x');
      expect(newList.items.isEmpty, isTrue);
    });

    test('removeItem with unknown id throws StateError', () {
      expect(() => _list().removeItem('nonexistent'), throwsStateError);
    });

    test('updateItem replaces item by id', () {
      final original = _item(id: 'x', unitPrice: Money.fromReais(5));
      final list = _list(items: [original]);
      final updated = original.copyWith(productName: 'Novo');
      final newList = list.updateItem(updated);
      expect(newList.items.first.productName, 'Novo');
    });

    test('updateItem with unknown id throws StateError', () {
      final list = _list(items: [_item(id: 'x')]);
      final foreign = _item(id: 'unknown');
      expect(() => list.updateItem(foreign), throwsStateError);
    });

    test('reorder moves item to new position', () {
      final items = [
        _item(id: 'a', position: 0),
        _item(id: 'b', position: 1),
        _item(id: 'c', position: 2),
      ];
      final list = _list(items: items);
      final reordered = list.reorder('a', 2);
      expect(reordered.items[0].id, 'b');
      expect(reordered.items[1].id, 'c');
      expect(reordered.items[2].id, 'a');
    });

    test('reorder reindexes positions', () {
      final items = [
        _item(id: 'a', position: 0),
        _item(id: 'b', position: 1),
        _item(id: 'c', position: 2),
      ];
      final reordered = _list(items: items).reorder('c', 0);
      for (var i = 0; i < 3; i++) {
        expect(reordered.items[i].position, i);
      }
    });
  });

  group('ShoppingList validation', () {
    test('empty name throws', () {
      expect(
        () => ShoppingList(
          id: 'l',
          name: '',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
        throwsArgumentError,
      );
    });

    test('duplicate item IDs throw', () {
      final dup = [_item(id: 'same', position: 0), _item(id: 'same', position: 1)];
      expect(() => _list(items: dup), throwsArgumentError);
    });

    test('itemCount reflects items length', () {
      final list = _list(items: [_item(id: 'a'), _item(id: 'b', position: 1)]);
      expect(list.itemCount, 2);
    });
  });
}
