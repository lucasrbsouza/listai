import 'package:drift/drift.dart' show Value;

import '../../../../core/utils/money.dart';
import '../../../../core/utils/quantity.dart';
import '../datasources/local/app_database.dart';
import '../../domain/entities/shopping_item.dart';

abstract class ShoppingItemMapper {
  static ShoppingItem toEntity(ShoppingItemsTableData row) {
    return ShoppingItem(
      id: row.id,
      productType: row.productType,
      productName: row.productName,
      brand: row.brand,
      quantity: Quantity(row.quantityValue),
      unitPrice: Money.fromCents(row.unitPriceCents),
      isWholesale: row.isWholesale,
      isWeightBased: row.isWeightBased,
      pricePerKg: row.pricePerKgCents != null
          ? Money.fromCents(row.pricePerKgCents!)
          : null,
      weightKg: row.weightKg != null ? Quantity(row.weightKg!) : null,
      photoUrl: row.photoUrl,
      photoCapturedAt: row.photoCapturedAt,
      substituteItemId: row.substituteItemId,
      position: row.position,
      createdAt: row.createdAt,
    );
  }

  static ShoppingItemsTableCompanion toCompanion(
    ShoppingItem entity, {
    required String listId,
  }) {
    return ShoppingItemsTableCompanion(
      id: Value(entity.id),
      listId: Value(listId),
      productType: Value(entity.productType),
      productName: Value(entity.productName),
      brand: Value(entity.brand),
      quantityValue: Value(entity.quantity.value),
      unitPriceCents: Value(entity.unitPrice.cents),
      isWholesale: Value(entity.isWholesale),
      isWeightBased: Value(entity.isWeightBased),
      pricePerKgCents: Value(entity.pricePerKg?.cents),
      weightKg: Value(entity.weightKg?.value),
      photoUrl: Value(entity.photoUrl),
      photoCapturedAt: Value(entity.photoCapturedAt),
      substituteItemId: Value(entity.substituteItemId),
      position: Value(entity.position),
      createdAt: Value(entity.createdAt),
    );
  }
}
