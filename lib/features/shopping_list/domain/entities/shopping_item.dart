import 'package:meta/meta.dart';

import '../../../../core/utils/money.dart';
import '../../../../core/utils/quantity.dart';

@immutable
class ShoppingItem {
  factory ShoppingItem({
    required final String id,
    required final String productType,
    required final String productName,
    final String? brand,
    required final Quantity quantity,
    final Money? unitPrice,
    final bool isWholesale = false,
    final bool isWeightBased = false,
    final Money? pricePerKg,
    final Quantity? weightKg,
    final String? photoUrl,
    final DateTime? photoCapturedAt,
    final String? substituteItemId,
    final int position = 0,
    required final DateTime createdAt,
  }) {
    if (productType.isEmpty) {
      throw ArgumentError('productType cannot be empty');
    }
    if (productType.length > 100) {
      throw ArgumentError('productType max 100 chars');
    }
    if (productName.isEmpty) {
      throw ArgumentError('productName cannot be empty');
    }
    if (productName.length > 200) {
      throw ArgumentError('productName max 200 chars');
    }
    if (brand != null && brand.length > 100) {
      throw ArgumentError('brand max 100 chars');
    }
    if (position < 0) {
      throw ArgumentError('position must be >= 0: $position');
    }
    if (isWeightBased && isWholesale) {
      throw ArgumentError('isWeightBased and isWholesale cannot both be true');
    }
    if (isWeightBased && weightKg == null) {
      throw ArgumentError('weightKg required when isWeightBased=true');
    }

    return ShoppingItem._(
      id: id,
      productType: productType,
      productName: productName,
      brand: brand,
      quantity: quantity,
      unitPrice: unitPrice,
      isWholesale: isWholesale,
      isWeightBased: isWeightBased,
      pricePerKg: pricePerKg,
      weightKg: weightKg,
      photoUrl: photoUrl,
      photoCapturedAt: photoCapturedAt,
      substituteItemId: substituteItemId,
      position: position,
      createdAt: createdAt,
    );
  }
  const ShoppingItem._({
    required this.id,
    required this.productType,
    required this.productName,
    required this.brand,
    required this.quantity,
    required this.unitPrice,
    required this.isWholesale,
    required this.isWeightBased,
    required this.pricePerKg,
    required this.weightKg,
    required this.photoUrl,
    required this.photoCapturedAt,
    required this.substituteItemId,
    required this.position,
    required this.createdAt,
  });

  final String id;
  final String productType;
  final String productName;
  final String? brand;
  final Quantity quantity;
  final Money? unitPrice;
  final bool isWholesale;
  final bool isWeightBased;
  final Money? pricePerKg;
  final Quantity? weightKg;
  final String? photoUrl;
  final DateTime? photoCapturedAt;
  final String? substituteItemId;
  final int position;
  final DateTime createdAt;

  /// Whether the item has a known price (unit price or price per kg).
  bool get hasPrice => isWeightBased ? pricePerKg != null : unitPrice != null;

  /// Total for the item; items without a price contribute zero.
  Money get totalPrice {
    if (isWeightBased) {
      final perKg = pricePerKg;
      if (perKg == null) return const Money.zero();
      return perKg * weightKg!.value;
    }
    final price = unitPrice;
    if (price == null) return const Money.zero();
    return price * quantity.value;
  }

  ShoppingItem copyWith({
    final String? id,
    final String? productType,
    final String? productName,
    final String? brand,
    final bool clearBrand = false,
    final Quantity? quantity,
    final Money? unitPrice,
    final bool clearUnitPrice = false,
    final bool? isWholesale,
    final bool? isWeightBased,
    final Money? pricePerKg,
    final bool clearPricePerKg = false,
    final Quantity? weightKg,
    final bool clearWeightKg = false,
    final String? photoUrl,
    final bool clearPhotoUrl = false,
    final DateTime? photoCapturedAt,
    final bool clearPhotoCapturedAt = false,
    final String? substituteItemId,
    final bool clearSubstituteItemId = false,
    final int? position,
    final DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      productType: productType ?? this.productType,
      productName: productName ?? this.productName,
      brand: clearBrand ? null : (brand ?? this.brand),
      quantity: quantity ?? this.quantity,
      unitPrice: clearUnitPrice ? null : (unitPrice ?? this.unitPrice),
      isWholesale: isWholesale ?? this.isWholesale,
      isWeightBased: isWeightBased ?? this.isWeightBased,
      pricePerKg: clearPricePerKg ? null : (pricePerKg ?? this.pricePerKg),
      weightKg: clearWeightKg ? null : (weightKg ?? this.weightKg),
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      photoCapturedAt: clearPhotoCapturedAt
          ? null
          : (photoCapturedAt ?? this.photoCapturedAt),
      substituteItemId: clearSubstituteItemId
          ? null
          : (substituteItemId ?? this.substituteItemId),
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(final Object other) =>
      other is ShoppingItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
