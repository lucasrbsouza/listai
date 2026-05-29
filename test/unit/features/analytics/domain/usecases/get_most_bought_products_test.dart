import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:listai/features/analytics/domain/entities/analytics_entities.dart';
import 'package:listai/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:listai/features/analytics/domain/usecases/get_most_bought_products.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  late MockAnalyticsRepository repo;
  late GetMostBoughtProducts useCase;
  final refDate = DateTime(2024, 6, 15);

  setUp(() {
    repo = MockAnalyticsRepository();
    useCase = GetMostBoughtProducts(repo);
  });

  test('returns most bought products from repository', () async {
    final products = [
      const ProductPurchaseCount(
          productName: 'Arroz', productType: 'Mercearia', count: 10),
      const ProductPurchaseCount(
          productName: 'Feijão', productType: 'Mercearia', count: 8),
    ];
    when(() => repo.getMostBoughtProducts(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => products);

    final result = await useCase(AnalyticsPeriod.monthly, referenceDate: refDate);

    expect(result, equals(products));
  });

  test('empty period returns empty list', () async {
    when(() => repo.getMostBoughtProducts(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => []);

    final result = await useCase(AnalyticsPeriod.weekly, referenceDate: refDate);

    expect(result, isEmpty);
  });

  test('products sorted by count descending', () async {
    final products = [
      const ProductPurchaseCount(
          productName: 'Arroz', productType: 'Mercearia', count: 10),
      const ProductPurchaseCount(
          productName: 'Feijão', productType: 'Mercearia', count: 5),
    ];
    when(() => repo.getMostBoughtProducts(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => products);

    final result = await useCase(AnalyticsPeriod.monthly, referenceDate: refDate);

    expect(result.first.count, greaterThanOrEqualTo(result.last.count));
  });

  test('uses correct date range for monthly period', () async {
    when(() => repo.getMostBoughtProducts(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => []);

    await useCase(AnalyticsPeriod.monthly, referenceDate: refDate);

    final captured = verify(() => repo.getMostBoughtProducts(
          startDate: captureAny(named: 'startDate'),
          endDate: captureAny(named: 'endDate'),
          limit: captureAny(named: 'limit'),
        )).captured;

    final start = captured[0] as DateTime;
    expect(start, equals(DateTime(2024, 5, 17)));
  });
}
