import '../entities/analytics_entities.dart';

abstract class AnalyticsRepository {
  Future<List<SpendingPoint>> getSpendingPoints({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<MarketSpending>> getTopMarkets({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5,
  });

  Future<List<ProductPurchaseCount>> getMostBoughtProducts({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5,
  });

  Future<List<ProductSpendingTotal>> getTopSpendingProducts({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5,
  });

  Future<BudgetExceededResult> getBudgetExceededCount({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<DayStatus>> getDailyBudgetStatus({
    required DateTime startDate,
    required DateTime endDate,
  });
}
