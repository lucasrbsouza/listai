import 'package:flutter_test/flutter_test.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/shopping_list/data/datasources/local/app_database.dart';
import 'package:listai/features/shopping_list/data/models/shopping_item_mapper.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';

void main() {
  final baseDate = DateTime(2024, 1, 15, 10, 0, 0);

  ShoppingItem makeRetailItem({String id = 'item-1', int position = 0}) =>
      ShoppingItem(
        id: id,
        productType: 'Padaria',
        productName: 'Pão de forma',
        brand: 'Pullman',
        quantity: Quantity(2),
        unitPrice: Money.fromCents(599),
        position: position,
        createdAt: baseDate,
      );

  ShoppingItemsTableData makeRow({
    String id = 'item-1',
    String listId = 'list-1',
    int position = 0,
  }) => ShoppingItemsTableData(
    id: id,
    listId: listId,
    productType: 'Padaria',
    productName: 'Pão de forma',
    brand: 'Pullman',
    quantityValue: 2.0,
    unitPriceCents: 599,
    isWholesale: false,
    isWeightBased: false,
    pricePerKgCents: null,
    weightKg: null,
    photoUrl: null,
    photoCapturedAt: null,
    substituteItemId: null,
    position: position,
    createdAt: baseDate,
  );

  group('ShoppingItemMapper.toEntity', () {
    test('converts retail row to entity correctly', () {
      final row = makeRow();
      final entity = ShoppingItemMapper.toEntity(row);

      expect(entity.id, 'item-1');
      expect(entity.productType, 'Padaria');
      expect(entity.productName, 'Pão de forma');
      expect(entity.brand, 'Pullman');
      expect(entity.quantity.value, 2.0);
      expect(entity.unitPrice, Money.fromCents(599));
      expect(entity.isWholesale, false);
      expect(entity.isWeightBased, false);
      expect(entity.position, 0);
      expect(entity.createdAt, baseDate);
    });

    test('converts null optional fields correctly', () {
      final row = ShoppingItemsTableData(
        id: 'item-2',
        listId: 'list-1',
        productType: 'Carnes',
        productName: 'Frango',
        brand: null,
        quantityValue: 1.0,
        unitPriceCents: 1500,
        isWholesale: false,
        isWeightBased: false,
        pricePerKgCents: null,
        weightKg: null,
        photoUrl: null,
        photoCapturedAt: null,
        substituteItemId: null,
        position: 0,
        createdAt: baseDate,
      );

      final entity = ShoppingItemMapper.toEntity(row);
      expect(entity.brand, isNull);
      expect(entity.pricePerKg, isNull);
      expect(entity.weightKg, isNull);
      expect(entity.photoUrl, isNull);
      expect(entity.photoCapturedAt, isNull);
      expect(entity.substituteItemId, isNull);
    });

    test('converts weight-based row correctly', () {
      final row = ShoppingItemsTableData(
        id: 'item-kg',
        listId: 'list-1',
        productType: 'Carnes',
        productName: 'Picanha',
        brand: null,
        quantityValue: 1.0,
        unitPriceCents: 0,
        isWholesale: false,
        isWeightBased: true,
        pricePerKgCents: 8000,
        weightKg: 0.5,
        photoUrl: null,
        photoCapturedAt: null,
        substituteItemId: null,
        position: 0,
        createdAt: baseDate,
      );

      final entity = ShoppingItemMapper.toEntity(row);
      expect(entity.isWeightBased, true);
      expect(entity.pricePerKg, Money.fromCents(8000));
      expect(entity.weightKg!.value, 0.5);
    });

    test('converts wholesale row correctly', () {
      final row = ShoppingItemsTableData(
        id: 'item-ws',
        listId: 'list-1',
        productType: 'Higiene',
        productName: 'Sabonete',
        brand: null,
        quantityValue: 3.0,
        unitPriceCents: 250,
        isWholesale: true,
        isWeightBased: false,
        pricePerKgCents: null,
        weightKg: null,
        photoUrl: null,
        photoCapturedAt: null,
        substituteItemId: null,
        position: 0,
        createdAt: baseDate,
      );

      final entity = ShoppingItemMapper.toEntity(row);
      expect(entity.isWholesale, true);
      expect(entity.quantity.value, 3.0);
    });

    test('preserves photo fields', () {
      final capturedAt = DateTime(2024, 1, 15, 12, 0, 0);
      final row = ShoppingItemsTableData(
        id: 'item-photo',
        listId: 'list-1',
        productType: 'Outros',
        productName: 'Produto',
        brand: null,
        quantityValue: 1.0,
        unitPriceCents: 100,
        isWholesale: false,
        isWeightBased: false,
        pricePerKgCents: null,
        weightKg: null,
        photoUrl: 'https://example.com/photo.jpg',
        photoCapturedAt: capturedAt,
        substituteItemId: 'sub-1',
        position: 0,
        createdAt: baseDate,
      );

      final entity = ShoppingItemMapper.toEntity(row);
      expect(entity.photoUrl, 'https://example.com/photo.jpg');
      expect(entity.photoCapturedAt, capturedAt);
      expect(entity.substituteItemId, 'sub-1');
    });
  });

  group('ShoppingItemMapper.toCompanion', () {
    test('converts retail entity to companion correctly', () {
      final entity = makeRetailItem();
      final companion = ShoppingItemMapper.toCompanion(
        entity,
        listId: 'list-1',
      );

      expect(companion.id.value, 'item-1');
      expect(companion.listId.value, 'list-1');
      expect(companion.productType.value, 'Padaria');
      expect(companion.productName.value, 'Pão de forma');
      expect(companion.brand.value, 'Pullman');
      expect(companion.quantityValue.value, 2.0);
      expect(companion.unitPriceCents.value, 599);
      expect(companion.isWholesale.value, false);
      expect(companion.isWeightBased.value, false);
    });

    test('converts null optional fields to absent/null', () {
      final entity = ShoppingItem(
        id: 'item-no-brand',
        productType: 'Outros',
        productName: 'Produto',
        quantity: Quantity(1),
        unitPrice: Money.fromCents(100),
        position: 0,
        createdAt: baseDate,
      );

      final companion = ShoppingItemMapper.toCompanion(
        entity,
        listId: 'list-1',
      );
      expect(companion.brand.value, isNull);
      expect(companion.pricePerKgCents.value, isNull);
      expect(companion.weightKg.value, isNull);
    });

    test('converts weight-based entity correctly', () {
      final entity = ShoppingItem(
        id: 'item-kg',
        productType: 'Carnes',
        productName: 'Picanha',
        quantity: Quantity(1),
        unitPrice: Money.fromCents(0),
        isWeightBased: true,
        pricePerKg: Money.fromCents(8000),
        weightKg: Quantity(0.5),
        position: 0,
        createdAt: baseDate,
      );

      final companion = ShoppingItemMapper.toCompanion(
        entity,
        listId: 'list-1',
      );
      expect(companion.isWeightBased.value, true);
      expect(companion.pricePerKgCents.value, 8000);
      expect(companion.weightKg.value, 0.5);
    });
  });

  group('ShoppingItemMapper round-trip', () {
    test('retail item round-trips without data loss', () {
      final original = makeRetailItem();
      final companion = ShoppingItemMapper.toCompanion(
        original,
        listId: 'list-1',
      );
      final row = ShoppingItemsTableData(
        id: companion.id.value,
        listId: companion.listId.value,
        productType: companion.productType.value,
        productName: companion.productName.value,
        brand: companion.brand.value,
        quantityValue: companion.quantityValue.value,
        unitPriceCents: companion.unitPriceCents.value,
        isWholesale: companion.isWholesale.value,
        isWeightBased: companion.isWeightBased.value,
        pricePerKgCents: companion.pricePerKgCents.value,
        weightKg: companion.weightKg.value,
        photoUrl: companion.photoUrl.value,
        photoCapturedAt: companion.photoCapturedAt.value,
        substituteItemId: companion.substituteItemId.value,
        position: companion.position.value,
        createdAt: companion.createdAt.value,
      );
      final restored = ShoppingItemMapper.toEntity(row);

      expect(restored.id, original.id);
      expect(restored.productType, original.productType);
      expect(restored.productName, original.productName);
      expect(restored.brand, original.brand);
      expect(restored.quantity.value, original.quantity.value);
      expect(restored.unitPrice, original.unitPrice);
      expect(restored.isWholesale, original.isWholesale);
      expect(restored.isWeightBased, original.isWeightBased);
      expect(restored.position, original.position);
    });

    test('weight-based item round-trips without data loss', () {
      final original = ShoppingItem(
        id: 'item-kg-rt',
        productType: 'Carnes',
        productName: 'Alcatra',
        quantity: Quantity(1),
        unitPrice: Money.fromCents(0),
        isWeightBased: true,
        pricePerKg: Money.fromCents(6500),
        weightKg: Quantity(1.5),
        position: 0,
        createdAt: baseDate,
      );

      final companion = ShoppingItemMapper.toCompanion(
        original,
        listId: 'list-1',
      );
      final row = ShoppingItemsTableData(
        id: companion.id.value,
        listId: companion.listId.value,
        productType: companion.productType.value,
        productName: companion.productName.value,
        brand: companion.brand.value,
        quantityValue: companion.quantityValue.value,
        unitPriceCents: companion.unitPriceCents.value,
        isWholesale: companion.isWholesale.value,
        isWeightBased: companion.isWeightBased.value,
        pricePerKgCents: companion.pricePerKgCents.value,
        weightKg: companion.weightKg.value,
        photoUrl: companion.photoUrl.value,
        photoCapturedAt: companion.photoCapturedAt.value,
        substituteItemId: companion.substituteItemId.value,
        position: companion.position.value,
        createdAt: companion.createdAt.value,
      );
      final restored = ShoppingItemMapper.toEntity(row);

      expect(restored.isWeightBased, true);
      expect(restored.pricePerKg, original.pricePerKg);
      expect(restored.weightKg!.value, original.weightKg!.value);
    });
  });
}
