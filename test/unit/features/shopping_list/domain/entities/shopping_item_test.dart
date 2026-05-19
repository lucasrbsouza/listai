import 'package:flutter_test/flutter_test.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';

ShoppingItem _makeItem({
  String id = 'item-1',
  String productType = 'Mercearia',
  String productName = 'Arroz',
  String? brand,
  Quantity? quantity,
  Money? unitPrice,
  bool isWholesale = false,
  bool isWeightBased = false,
  Money? pricePerKg,
  Quantity? weightKg,
  int position = 0,
}) {
  return ShoppingItem(
    id: id,
    productType: productType,
    productName: productName,
    brand: brand,
    quantity: quantity ?? Quantity.unit(),
    unitPrice: unitPrice ?? Money.fromReais(5.00),
    isWholesale: isWholesale,
    isWeightBased: isWeightBased,
    pricePerKg: pricePerKg,
    weightKg: weightKg,
    position: position,
    createdAt: DateTime(2024),
  );
}

void main() {
  group('ShoppingItem construction — retail', () {
    test('creates valid retail item', () {
      final item = _makeItem();
      expect(item.productName, 'Arroz');
      expect(item.isWeightBased, isFalse);
      expect(item.isWholesale, isFalse);
    });

    test('totalPrice retail = unitPrice * quantity', () {
      final item = _makeItem(
        quantity: Quantity(3),
        unitPrice: Money.fromReais(5.00),
      );
      expect(item.totalPrice.cents, 1500);
    });
  });

  group('ShoppingItem construction — wholesale', () {
    test('creates valid wholesale item', () {
      final item = _makeItem(isWholesale: true, quantity: Quantity(3));
      expect(item.isWholesale, isTrue);
    });

    test('totalPrice wholesale = unitPrice * quantity', () {
      final item = _makeItem(
        isWholesale: true,
        quantity: Quantity(3),
        unitPrice: Money.fromReais(10.00),
      );
      expect(item.totalPrice.cents, 3000);
    });
  });

  group('ShoppingItem construction — weight-based', () {
    test('creates valid weight-based item', () {
      final item = _makeItem(
        isWeightBased: true,
        pricePerKg: Money.fromReais(20.00),
        weightKg: Quantity(0.5),
      );
      expect(item.isWeightBased, isTrue);
    });

    test('totalPrice weight-based = pricePerKg * weightKg', () {
      final item = _makeItem(
        isWeightBased: true,
        pricePerKg: Money.fromReais(20.00),
        weightKg: Quantity(0.5),
      );
      expect(item.totalPrice.cents, 1000);
    });

    test('weight-based without pricePerKg throws', () {
      expect(
        () => _makeItem(isWeightBased: true, weightKg: Quantity(1.0)),
        throwsArgumentError,
      );
    });

    test('weight-based without weightKg throws', () {
      expect(
        () => _makeItem(
          isWeightBased: true,
          pricePerKg: Money.fromReais(10.00),
        ),
        throwsArgumentError,
      );
    });
  });

  group('ShoppingItem validation', () {
    test('empty productName throws', () {
      expect(() => _makeItem(productName: ''), throwsArgumentError);
    });

    test('empty productType throws', () {
      expect(() => _makeItem(productType: ''), throwsArgumentError);
    });

    test('productName over 200 chars throws', () {
      expect(() => _makeItem(productName: 'a' * 201), throwsArgumentError);
    });

    test('productType over 100 chars throws', () {
      expect(() => _makeItem(productType: 'a' * 101), throwsArgumentError);
    });

    test('brand over 100 chars throws', () {
      expect(() => _makeItem(brand: 'a' * 101), throwsArgumentError);
    });

    test('isWeightBased AND isWholesale simultaneously throws', () {
      expect(
        () => _makeItem(
          isWeightBased: true,
          isWholesale: true,
          pricePerKg: Money.fromReais(10.00),
          weightKg: Quantity(1.0),
        ),
        throwsArgumentError,
      );
    });

    test('position negative throws', () {
      expect(() => _makeItem(position: -1), throwsArgumentError);
    });
  });

  group('ShoppingItem copyWith', () {
    test('preserves unchanged fields', () {
      final item = _makeItem(productName: 'Arroz', position: 2);
      final copy = item.copyWith(productType: 'Frutas');
      expect(copy.productName, 'Arroz');
      expect(copy.position, 2);
      expect(copy.productType, 'Frutas');
    });

    test('can set nullable brand to null', () {
      final item = _makeItem(brand: 'Marca');
      final copy = item.copyWith(brand: null, clearBrand: true);
      expect(copy.brand, isNull);
    });

    test('copyWith returns new instance', () {
      final item = _makeItem();
      final copy = item.copyWith(productName: 'Feijão');
      expect(identical(item, copy), isFalse);
    });
  });
}
