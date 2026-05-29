import '../entities/analytics_entities.dart';
import '../repositories/analytics_repository.dart';

class GetDailyBudgetStatus {
  GetDailyBudgetStatus(this._repository);

  final AnalyticsRepository _repository;

  Future<List<DayStatus>> call({DateTime? endDate}) {
    final end = endDate ?? DateTime.now();
    final start = end.subtract(const Duration(days: 363));
    return _repository.getDailyBudgetStatus(startDate: start, endDate: end);
  }
}
