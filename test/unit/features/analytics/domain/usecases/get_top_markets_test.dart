import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/features/analytics/domain/entities/analytics_entities.dart';
import 'package:listai/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:listai/features/analytics/domain/usecases/get_top_markets.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  late MockAnalyticsRepository repo;
  late GetTopMarkets useCase;
  final refDate = DateTime(2024, 6, 15);

  setUp(() {
    repo = MockAnalyticsRepository();
    useCase = GetTopMarkets(repo);
  });

  test('returns top markets from repository', () async {
    final markets = [
      MarketSpending(marketName: 'Supermercado A', total: Money.fromReais(200)),
      MarketSpending(marketName: 'Supermercado B', total: Money.fromReais(150)),
    ];
    when(() => repo.getTopMarkets(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => markets);

    final result = await useCase(AnalyticsPeriod.monthly, referenceDate: refDate);

    expect(result, equals(markets));
  });

  test('empty period returns empty list', () async {
    when(() => repo.getTopMarkets(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => []);

    final result = await useCase(AnalyticsPeriod.weekly, referenceDate: refDate);

    expect(result, isEmpty);
  });

  test('uses correct date range for weekly period', () async {
    when(() => repo.getTopMarkets(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => []);

    await useCase(AnalyticsPeriod.weekly, referenceDate: refDate);

    final captured = verify(() => repo.getTopMarkets(
          startDate: captureAny(named: 'startDate'),
          endDate: captureAny(named: 'endDate'),
          limit: captureAny(named: 'limit'),
        )).captured;

    final start = captured[0] as DateTime;
    expect(start, equals(DateTime(2024, 6, 9)));
  });

  test('uses correct date range for yearly period', () async {
    when(() => repo.getTopMarkets(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => []);

    await useCase(AnalyticsPeriod.yearly, referenceDate: refDate);

    final captured = verify(() => repo.getTopMarkets(
          startDate: captureAny(named: 'startDate'),
          endDate: captureAny(named: 'endDate'),
          limit: captureAny(named: 'limit'),
        )).captured;

    final start = captured[0] as DateTime;
    expect(start, equals(DateTime(2023, 6, 15)));
  });
}
