import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/features/analytics/domain/entities/analytics_entities.dart';
import 'package:listai/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:listai/features/analytics/domain/usecases/get_top_spending_products.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  late MockAnalyticsRepository repo;
  late GetTopSpendingProducts useCase;
  final refDate = DateTime(2024, 6, 15);

  setUp(() {
    repo = MockAnalyticsRepository();
    useCase = GetTopSpendingProducts(repo);
  });

  test('returns top spending products from repository', () async {
    final products = [
      ProductSpendingTotal(
        productName: 'Carne',
        productType: 'Carnes',
        total: Money.fromReais(300),
      ),
      ProductSpendingTotal(
        productName: 'Queijo',
        productType: 'Laticínios',
        total: Money.fromReais(100),
      ),
    ];
    when(
      () => repo.getTopSpendingProducts(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => products);

    final result = await useCase(
      AnalyticsPeriod.monthly,
      referenceDate: refDate,
    );

    expect(result, equals(products));
  });

  test('empty period returns empty list', () async {
    when(
      () => repo.getTopSpendingProducts(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => []);

    final result = await useCase(
      AnalyticsPeriod.yearly,
      referenceDate: refDate,
    );

    expect(result, isEmpty);
  });

  test('products sorted by total descending', () async {
    final products = [
      ProductSpendingTotal(
        productName: 'Carne',
        productType: 'Carnes',
        total: Money.fromReais(300),
      ),
      ProductSpendingTotal(
        productName: 'Pão',
        productType: 'Padaria',
        total: Money.fromReais(50),
      ),
    ];
    when(
      () => repo.getTopSpendingProducts(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => products);

    final result = await useCase(
      AnalyticsPeriod.monthly,
      referenceDate: refDate,
    );

    expect(
      result.first.total.cents,
      greaterThanOrEqualTo(result.last.total.cents),
    );
  });

  test('uses correct date range for yearly period', () async {
    when(
      () => repo.getTopSpendingProducts(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => []);

    await useCase(AnalyticsPeriod.yearly, referenceDate: refDate);

    final captured = verify(
      () => repo.getTopSpendingProducts(
        startDate: captureAny(named: 'startDate'),
        endDate: captureAny(named: 'endDate'),
        limit: captureAny(named: 'limit'),
      ),
    ).captured;

    final start = captured[0] as DateTime;
    expect(start, equals(DateTime(2023, 6, 15)));
  });
}
