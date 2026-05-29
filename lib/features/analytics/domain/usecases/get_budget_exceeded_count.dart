import '../entities/analytics_entities.dart';
import '../repositories/analytics_repository.dart';

class GetBudgetExceededCount {
  GetBudgetExceededCount(this._repository);

  final AnalyticsRepository _repository;

  Future<BudgetExceededResult> call(
    AnalyticsPeriod period, {
    DateTime? referenceDate,
  }) {
    final ref = referenceDate ?? DateTime.now();
    final (start, end) = _dateRange(period, ref);
    return _repository.getBudgetExceededCount(startDate: start, endDate: end);
  }

  (DateTime, DateTime) _dateRange(AnalyticsPeriod period, DateTime ref) {
    return switch (period) {
      AnalyticsPeriod.weekly => (ref.subtract(const Duration(days: 6)), ref),
      AnalyticsPeriod.monthly => (ref.subtract(const Duration(days: 29)), ref),
      AnalyticsPeriod.yearly => (
        DateTime(ref.year - 1, ref.month, ref.day),
        ref,
      ),
    };
  }
}
