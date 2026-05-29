import 'package:meta/meta.dart';

import '../../../../core/utils/money.dart';

enum AnalyticsPeriod { weekly, monthly, yearly }

@immutable
class SpendingPoint {
  const SpendingPoint({required this.date, required this.total});

  final DateTime date;
  final Money total;

  @override
  bool operator ==(Object other) =>
      other is SpendingPoint && other.date == date && other.total == total;

  @override
  int get hashCode => Object.hash(date, total);
}

@immutable
class MarketSpending {
  const MarketSpending({required this.marketName, required this.total});

  final String marketName;
  final Money total;

  @override
  bool operator ==(Object other) =>
      other is MarketSpending &&
      other.marketName == marketName &&
      other.total == total;

  @override
  int get hashCode => Object.hash(marketName, total);
}

@immutable
class ProductPurchaseCount {
  const ProductPurchaseCount({
    required this.productName,
    required this.productType,
    required this.count,
  });

  final String productName;
  final String productType;
  final int count;

  @override
  bool operator ==(Object other) =>
      other is ProductPurchaseCount &&
      other.productName == productName &&
      other.count == count;

  @override
  int get hashCode => Object.hash(productName, count);
}

@immutable
class ProductSpendingTotal {
  const ProductSpendingTotal({
    required this.productName,
    required this.productType,
    required this.total,
  });

  final String productName;
  final String productType;
  final Money total;

  @override
  bool operator ==(Object other) =>
      other is ProductSpendingTotal &&
      other.productName == productName &&
      other.total == total;

  @override
  int get hashCode => Object.hash(productName, total);
}

@immutable
class DayStatus {
  const DayStatus({
    required this.date,
    this.totalSpent,
    this.budgetGoal,
  });

  final DateTime date;
  final Money? totalSpent;
  final Money? budgetGoal;

  bool get hasPurchase => totalSpent != null;

  bool get exceeded =>
      totalSpent != null &&
      budgetGoal != null &&
      totalSpent! > budgetGoal!;

  @override
  bool operator ==(Object other) =>
      other is DayStatus && other.date == date;

  @override
  int get hashCode => date.hashCode;
}

@immutable
class BudgetExceededResult {
  const BudgetExceededResult({
    required this.exceededCount,
    required this.totalPurchases,
  });

  final int exceededCount;
  final int totalPurchases;

  @override
  bool operator ==(Object other) =>
      other is BudgetExceededResult &&
      other.exceededCount == exceededCount &&
      other.totalPurchases == totalPurchases;

  @override
  int get hashCode => Object.hash(exceededCount, totalPurchases);
}
