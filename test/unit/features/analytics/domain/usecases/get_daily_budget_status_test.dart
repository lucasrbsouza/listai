import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/features/analytics/domain/entities/analytics_entities.dart';
import 'package:listai/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:listai/features/analytics/domain/usecases/get_daily_budget_status.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

List<DayStatus> _fixture365(DateTime end) {
  return List.generate(364, (i) {
    final date = end.subtract(Duration(days: 363 - i));
    return DayStatus(date: date);
  });
}

void main() {
  late MockAnalyticsRepository repo;
  late GetDailyBudgetStatus useCase;
  final refDate = DateTime(2024, 6, 15);

  setUp(() {
    repo = MockAnalyticsRepository();
    useCase = GetDailyBudgetStatus(repo);
  });

  test('queries exactly 364 days ending at endDate', () async {
    when(() => repo.getDailyBudgetStatus(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        )).thenAnswer((_) async => []);

    await useCase(endDate: refDate);

    final captured = verify(() => repo.getDailyBudgetStatus(
          startDate: captureAny(named: 'startDate'),
          endDate: captureAny(named: 'endDate'),
        )).captured;

    final start = captured[0] as DateTime;
    final end = captured[1] as DateTime;

    expect(end, equals(refDate));
    expect(start, equals(DateTime(2023, 6, 18)));
    expect(end.difference(start).inDays, equals(363));
  });

  test('returns statuses from repository', () async {
    final statuses = _fixture365(refDate);
    when(() => repo.getDailyBudgetStatus(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        )).thenAnswer((_) async => statuses);

    final result = await useCase(endDate: refDate);

    expect(result.length, equals(364));
  });

  test('empty result when no purchases', () async {
    when(() => repo.getDailyBudgetStatus(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        )).thenAnswer((_) async => []);

    final result = await useCase(endDate: refDate);

    expect(result, isEmpty);
  });

  test('day with purchase within budget has hasPurchase=true exceeded=false', () async {
    final day = DayStatus(
      date: refDate,
      totalSpent: Money.fromReais(50),
      budgetGoal: Money.fromReais(100),
    );
    when(() => repo.getDailyBudgetStatus(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        )).thenAnswer((_) async => [day]);

    final result = await useCase(endDate: refDate);

    expect(result.first.hasPurchase, isTrue);
    expect(result.first.exceeded, isFalse);
  });

  test('day with purchase exceeding budget has exceeded=true', () async {
    final day = DayStatus(
      date: refDate,
      totalSpent: Money.fromReais(150),
      budgetGoal: Money.fromReais(100),
    );
    when(() => repo.getDailyBudgetStatus(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        )).thenAnswer((_) async => [day]);

    final result = await useCase(endDate: refDate);

    expect(result.first.exceeded, isTrue);
  });

  test('day with no purchase has hasPurchase=false', () {
    final day = DayStatus(date: refDate);
    expect(day.hasPurchase, isFalse);
    expect(day.exceeded, isFalse);
  });

  test('uses today when endDate not provided', () async {
    when(() => repo.getDailyBudgetStatus(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        )).thenAnswer((_) async => []);

    // Should not throw
    await useCase();
  });
}
