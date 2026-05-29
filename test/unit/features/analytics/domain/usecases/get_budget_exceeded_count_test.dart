import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:listai/features/analytics/domain/entities/analytics_entities.dart';
import 'package:listai/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:listai/features/analytics/domain/usecases/get_budget_exceeded_count.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  late MockAnalyticsRepository repo;
  late GetBudgetExceededCount useCase;
  final refDate = DateTime(2024, 6, 15);

  setUp(() {
    repo = MockAnalyticsRepository();
    useCase = GetBudgetExceededCount(repo);
  });

  test('returns exceeded count from repository', () async {
    const result = BudgetExceededResult(exceededCount: 3, totalPurchases: 10);
    when(
      () => repo.getBudgetExceededCount(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((_) async => result);

    final res = await useCase(AnalyticsPeriod.monthly, referenceDate: refDate);

    expect(res.exceededCount, equals(3));
    expect(res.totalPurchases, equals(10));
  });

  test('zero purchases returns zero counts', () async {
    const result = BudgetExceededResult(exceededCount: 0, totalPurchases: 0);
    when(
      () => repo.getBudgetExceededCount(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((_) async => result);

    final res = await useCase(AnalyticsPeriod.weekly, referenceDate: refDate);

    expect(res.exceededCount, equals(0));
    expect(res.totalPurchases, equals(0));
  });

  test('exceeded cannot be greater than total', () async {
    const result = BudgetExceededResult(exceededCount: 5, totalPurchases: 10);
    when(
      () => repo.getBudgetExceededCount(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((_) async => result);

    final res = await useCase(AnalyticsPeriod.yearly, referenceDate: refDate);

    expect(res.exceededCount, lessThanOrEqualTo(res.totalPurchases));
  });

  test('uses correct date range for weekly period', () async {
    when(
      () => repo.getBudgetExceededCount(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer(
      (_) async =>
          const BudgetExceededResult(exceededCount: 0, totalPurchases: 0),
    );

    await useCase(AnalyticsPeriod.weekly, referenceDate: refDate);

    final captured = verify(
      () => repo.getBudgetExceededCount(
        startDate: captureAny(named: 'startDate'),
        endDate: captureAny(named: 'endDate'),
      ),
    ).captured;

    final start = captured[0] as DateTime;
    expect(start, equals(DateTime(2024, 6, 9)));
  });

  test('uses correct date range for monthly period', () async {
    when(
      () => repo.getBudgetExceededCount(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer(
      (_) async =>
          const BudgetExceededResult(exceededCount: 0, totalPurchases: 0),
    );

    await useCase(AnalyticsPeriod.monthly, referenceDate: refDate);

    final captured = verify(
      () => repo.getBudgetExceededCount(
        startDate: captureAny(named: 'startDate'),
        endDate: captureAny(named: 'endDate'),
      ),
    ).captured;

    final start = captured[0] as DateTime;
    expect(start, equals(DateTime(2024, 5, 17)));
  });
}
