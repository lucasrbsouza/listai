import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/features/analytics/domain/entities/analytics_entities.dart';
import 'package:listai/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:listai/features/analytics/domain/usecases/get_spending_by_period.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  late MockAnalyticsRepository repo;
  late GetSpendingByPeriod useCase;
  final refDate = DateTime(2024, 6, 15);

  setUp(() {
    repo = MockAnalyticsRepository();
    useCase = GetSpendingByPeriod(repo);
  });

  test('weekly: queries last 7 days', () async {
    when(
      () => repo.getSpendingPoints(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((_) async => []);

    await useCase(AnalyticsPeriod.weekly, referenceDate: refDate);

    final captured = verify(
      () => repo.getSpendingPoints(
        startDate: captureAny(named: 'startDate'),
        endDate: captureAny(named: 'endDate'),
      ),
    ).captured;

    final start = captured[0] as DateTime;
    final end = captured[1] as DateTime;

    expect(end, equals(refDate));
    expect(start, equals(DateTime(2024, 6, 9)));
  });

  test('monthly: queries last 30 days', () async {
    when(
      () => repo.getSpendingPoints(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((_) async => []);

    await useCase(AnalyticsPeriod.monthly, referenceDate: refDate);

    final captured = verify(
      () => repo.getSpendingPoints(
        startDate: captureAny(named: 'startDate'),
        endDate: captureAny(named: 'endDate'),
      ),
    ).captured;

    final start = captured[0] as DateTime;
    expect(start, equals(DateTime(2024, 5, 17)));
  });

  test('yearly: queries last 365 days', () async {
    when(
      () => repo.getSpendingPoints(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((_) async => []);

    await useCase(AnalyticsPeriod.yearly, referenceDate: refDate);

    final captured = verify(
      () => repo.getSpendingPoints(
        startDate: captureAny(named: 'startDate'),
        endDate: captureAny(named: 'endDate'),
      ),
    ).captured;

    final start = captured[0] as DateTime;
    expect(start, equals(DateTime(2023, 6, 15)));
  });

  test('returns data from repository', () async {
    final points = [
      SpendingPoint(date: DateTime(2024, 6, 14), total: Money.fromReais(50)),
      SpendingPoint(date: DateTime(2024, 6, 15), total: Money.fromReais(30)),
    ];
    when(
      () => repo.getSpendingPoints(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((_) async => points);

    final result = await useCase(
      AnalyticsPeriod.weekly,
      referenceDate: refDate,
    );

    expect(result, equals(points));
  });

  test('empty period returns empty list', () async {
    when(
      () => repo.getSpendingPoints(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((_) async => []);

    final result = await useCase(
      AnalyticsPeriod.weekly,
      referenceDate: refDate,
    );

    expect(result, isEmpty);
  });
}
