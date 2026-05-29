import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/features/analytics/data/repositories/local_analytics_repository.dart';
import 'package:listai/features/shopping_list/data/datasources/local/app_database.dart';

import '../../../../../helpers/sqlite_test_helper.dart';

void main() {
  setUpAll(configureSqliteForTests);

  late AppDatabase db;
  late LocalAnalyticsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = LocalAnalyticsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertPurchase({
    required String id,
    required DateTime completedAt,
    required int totalAmountCents,
    String? marketName,
    int? budgetGoalCents,
    bool exceededBudget = false,
  }) async {
    await db.into(db.purchasesTable).insert(
          PurchasesTableCompanion.insert(
            id: id,
            userId: 'user-1',
            listId: 'list-1',
            marketName: Value(marketName),
            totalAmountCents: totalAmountCents,
            budgetGoalCents: Value(budgetGoalCents),
            exceededBudget: Value(exceededBudget),
            completedAt: completedAt,
          ),
        );
  }

  Future<void> insertPurchaseItem({
    required String id,
    required String purchaseId,
    required String productType,
    required String productName,
    required int totalPriceCents,
    double quantityValue = 1,
    int unitPriceCents = 0,
  }) async {
    await db.into(db.purchaseItemsTable).insert(
          PurchaseItemsTableCompanion.insert(
            id: id,
            purchaseId: purchaseId,
            productType: productType,
            productName: productName,
            quantityValue: quantityValue,
            unitPriceCents: unitPriceCents,
            totalPriceCents: totalPriceCents,
          ),
        );
  }

  final start = DateTime(2024, 6, 1);
  final end = DateTime(2024, 6, 30, 23, 59, 59);

  group('getSpendingPoints', () {
    test('returns empty when no purchases', () async {
      final result =
          await repo.getSpendingPoints(startDate: start, endDate: end);
      expect(result, isEmpty);
    });

    test('groups spending by day', () async {
      await insertPurchase(
        id: 'p1',
        completedAt: DateTime(2024, 6, 10, 12),
        totalAmountCents: 5000,
      );
      await insertPurchase(
        id: 'p2',
        completedAt: DateTime(2024, 6, 10, 18),
        totalAmountCents: 3000,
      );
      await insertPurchase(
        id: 'p3',
        completedAt: DateTime(2024, 6, 15, 9),
        totalAmountCents: 2000,
      );

      final result =
          await repo.getSpendingPoints(startDate: start, endDate: end);

      expect(result, hasLength(2));
      expect(result.first.total.cents, 8000);
      expect(result.last.total.cents, 2000);
    });
  });

  group('getTopMarkets', () {
    test('aggregates and orders markets by total desc', () async {
      await insertPurchase(
        id: 'p1',
        completedAt: DateTime(2024, 6, 5),
        totalAmountCents: 10000,
        marketName: 'Mercado A',
      );
      await insertPurchase(
        id: 'p2',
        completedAt: DateTime(2024, 6, 6),
        totalAmountCents: 25000,
        marketName: 'Mercado B',
      );
      await insertPurchase(
        id: 'p3',
        completedAt: DateTime(2024, 6, 7),
        totalAmountCents: 5000,
        marketName: 'Mercado A',
      );

      final result = await repo.getTopMarkets(startDate: start, endDate: end);

      expect(result, hasLength(2));
      expect(result.first.marketName, 'Mercado B');
      expect(result.first.total.cents, 25000);
      expect(result.last.marketName, 'Mercado A');
      expect(result.last.total.cents, 15000);
    });

    test('ignores purchases without market name', () async {
      await insertPurchase(
        id: 'p1',
        completedAt: DateTime(2024, 6, 5),
        totalAmountCents: 10000,
      );

      final result = await repo.getTopMarkets(startDate: start, endDate: end);
      expect(result, isEmpty);
    });
  });

  group('getMostBoughtProducts', () {
    test('counts product occurrences across purchases', () async {
      await insertPurchase(
        id: 'p1',
        completedAt: DateTime(2024, 6, 5),
        totalAmountCents: 10000,
      );
      await insertPurchase(
        id: 'p2',
        completedAt: DateTime(2024, 6, 6),
        totalAmountCents: 10000,
      );
      await insertPurchaseItem(
        id: 'i1',
        purchaseId: 'p1',
        productType: 'Mercearia',
        productName: 'Arroz',
        totalPriceCents: 2000,
      );
      await insertPurchaseItem(
        id: 'i2',
        purchaseId: 'p2',
        productType: 'Mercearia',
        productName: 'Arroz',
        totalPriceCents: 2000,
      );
      await insertPurchaseItem(
        id: 'i3',
        purchaseId: 'p1',
        productType: 'Padaria',
        productName: 'Pão',
        totalPriceCents: 500,
      );

      final result =
          await repo.getMostBoughtProducts(startDate: start, endDate: end);

      expect(result, hasLength(2));
      expect(result.first.productName, 'Arroz');
      expect(result.first.count, 2);
    });
  });

  group('getTopSpendingProducts', () {
    test('sums product spending and orders desc', () async {
      await insertPurchase(
        id: 'p1',
        completedAt: DateTime(2024, 6, 5),
        totalAmountCents: 10000,
      );
      await insertPurchaseItem(
        id: 'i1',
        purchaseId: 'p1',
        productType: 'Carnes',
        productName: 'Carne',
        totalPriceCents: 30000,
      );
      await insertPurchaseItem(
        id: 'i2',
        purchaseId: 'p1',
        productType: 'Padaria',
        productName: 'Pão',
        totalPriceCents: 500,
      );

      final result =
          await repo.getTopSpendingProducts(startDate: start, endDate: end);

      expect(result, hasLength(2));
      expect(result.first.productName, 'Carne');
      expect(result.first.total.cents, 30000);
    });
  });

  group('getBudgetExceededCount', () {
    test('counts exceeded purchases vs total', () async {
      await insertPurchase(
        id: 'p1',
        completedAt: DateTime(2024, 6, 5),
        totalAmountCents: 12000,
        budgetGoalCents: 10000,
        exceededBudget: true,
      );
      await insertPurchase(
        id: 'p2',
        completedAt: DateTime(2024, 6, 6),
        totalAmountCents: 8000,
        budgetGoalCents: 10000,
        exceededBudget: false,
      );
      await insertPurchase(
        id: 'p3',
        completedAt: DateTime(2024, 6, 7),
        totalAmountCents: 5000,
      );

      final result =
          await repo.getBudgetExceededCount(startDate: start, endDate: end);

      expect(result.totalPurchases, 3);
      expect(result.exceededCount, 1);
    });

    test('zero when no purchases', () async {
      final result =
          await repo.getBudgetExceededCount(startDate: start, endDate: end);
      expect(result.totalPurchases, 0);
      expect(result.exceededCount, 0);
    });
  });

  group('getDailyBudgetStatus', () {
    test('returns full day range with nulls for empty days', () async {
      final rangeStart = DateTime(2024, 6, 1);
      final rangeEnd = DateTime(2024, 6, 7);

      await insertPurchase(
        id: 'p1',
        completedAt: DateTime(2024, 6, 3, 10),
        totalAmountCents: 5000,
        budgetGoalCents: 10000,
      );

      final result = await repo.getDailyBudgetStatus(
        startDate: rangeStart,
        endDate: rangeEnd,
      );

      expect(result, hasLength(7));

      final dayWithPurchase =
          result.firstWhere((d) => d.date.day == 3);
      expect(dayWithPurchase.hasPurchase, isTrue);
      expect(dayWithPurchase.totalSpent!.cents, 5000);
      expect(dayWithPurchase.budgetGoal!.cents, 10000);
      expect(dayWithPurchase.exceeded, isFalse);

      final emptyDay = result.firstWhere((d) => d.date.day == 1);
      expect(emptyDay.hasPurchase, isFalse);
    });

    test('marks exceeded day correctly', () async {
      await insertPurchase(
        id: 'p1',
        completedAt: DateTime(2024, 6, 3, 10),
        totalAmountCents: 15000,
        budgetGoalCents: 10000,
        exceededBudget: true,
      );

      final result = await repo.getDailyBudgetStatus(
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 7),
      );

      final day = result.firstWhere((d) => d.date.day == 3);
      expect(day.exceeded, isTrue);
    });
  });

  // Regression guard: ensures the raw SQL references the real generated
  // table names (purchases_table / purchase_items_table). Previously the
  // queries used 'purchases' / 'purchase_items' which threw
  // "no such table" at runtime while mocked unit tests stayed green.
  test('all queries execute against real schema without SQL errors', () async {
    expect(
      () => repo.getSpendingPoints(startDate: start, endDate: end),
      returnsNormally,
    );
    await repo.getSpendingPoints(startDate: start, endDate: end);
    await repo.getTopMarkets(startDate: start, endDate: end);
    await repo.getMostBoughtProducts(startDate: start, endDate: end);
    await repo.getTopSpendingProducts(startDate: start, endDate: end);
    await repo.getBudgetExceededCount(startDate: start, endDate: end);
    await repo.getDailyBudgetStatus(startDate: start, endDate: end);
  });
}
