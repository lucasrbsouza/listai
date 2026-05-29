import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/local_analytics_repository.dart';
import '../../domain/entities/analytics_entities.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../domain/usecases/get_spending_by_period.dart';
import '../../domain/usecases/get_top_markets.dart';
import '../../domain/usecases/get_most_bought_products.dart';
import '../../domain/usecases/get_top_spending_products.dart';
import '../../domain/usecases/get_budget_exceeded_count.dart';
import '../../domain/usecases/get_daily_budget_status.dart';
import '../../../shopping_list/presentation/providers/database_provider.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalAnalyticsRepository(db);
});

final selectedPeriodProvider = StateProvider<AnalyticsPeriod>(
  (ref) => AnalyticsPeriod.monthly,
);

class AnalyticsData {
  const AnalyticsData({
    required this.spendingPoints,
    required this.topMarkets,
    required this.mostBoughtProducts,
    required this.topSpendingProducts,
    required this.budgetExceededResult,
  });

  final List<SpendingPoint> spendingPoints;
  final List<MarketSpending> topMarkets;
  final List<ProductPurchaseCount> mostBoughtProducts;
  final List<ProductSpendingTotal> topSpendingProducts;
  final BudgetExceededResult budgetExceededResult;
}

final heatmapDataProvider = FutureProvider<List<DayStatus>>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  final useCase = GetDailyBudgetStatus(repo);
  return useCase();
});

final analyticsDataProvider =
    FutureProvider.family<AnalyticsData, AnalyticsPeriod>((ref, period) async {
      final repo = ref.watch(analyticsRepositoryProvider);

      final getSpending = GetSpendingByPeriod(repo);
      final getMarkets = GetTopMarkets(repo);
      final getMostBought = GetMostBoughtProducts(repo);
      final getTopSpending = GetTopSpendingProducts(repo);
      final getBudgetExceeded = GetBudgetExceededCount(repo);

      final results = await Future.wait([
        getSpending(period),
        getMarkets(period),
        getMostBought(period),
        getTopSpending(period),
        getBudgetExceeded(period),
      ]);

      return AnalyticsData(
        spendingPoints: results[0] as List<SpendingPoint>,
        topMarkets: results[1] as List<MarketSpending>,
        mostBoughtProducts: results[2] as List<ProductPurchaseCount>,
        topSpendingProducts: results[3] as List<ProductSpendingTotal>,
        budgetExceededResult: results[4] as BudgetExceededResult,
      );
    });
