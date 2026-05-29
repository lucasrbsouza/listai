import 'package:drift/drift.dart';

import '../../../../core/utils/money.dart';
import '../../domain/entities/analytics_entities.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../../shopping_list/data/datasources/local/app_database.dart';

class LocalAnalyticsRepository implements AnalyticsRepository {
  LocalAnalyticsRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<SpendingPoint>> getSpendingPoints({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final rows = await _db
        .customSelect(
          '''
      SELECT date(completed_at, 'unixepoch') AS day,
             SUM(total_amount_cents) AS total
      FROM purchases_table
      WHERE completed_at >= ? AND completed_at <= ?
      GROUP BY day
      ORDER BY day ASC
      ''',
          variables: [
            Variable.withInt(startDate.millisecondsSinceEpoch ~/ 1000),
            Variable.withInt(endDate.millisecondsSinceEpoch ~/ 1000),
          ],
          readsFrom: {_db.purchasesTable},
        )
        .get();

    return rows.map((row) {
      final dayStr = row.read<String>('day');
      final parts = dayStr.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final total = Money.fromCents(row.read<int>('total'));
      return SpendingPoint(date: date, total: total);
    }).toList();
  }

  @override
  Future<List<MarketSpending>> getTopMarkets({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5,
  }) async {
    final rows = await _db
        .customSelect(
          '''
      SELECT market_name, SUM(total_amount_cents) AS total
      FROM purchases_table
      WHERE completed_at >= ? AND completed_at <= ?
        AND market_name IS NOT NULL AND market_name != ''
      GROUP BY market_name
      ORDER BY total DESC
      LIMIT ?
      ''',
          variables: [
            Variable.withInt(startDate.millisecondsSinceEpoch ~/ 1000),
            Variable.withInt(endDate.millisecondsSinceEpoch ~/ 1000),
            Variable.withInt(limit),
          ],
          readsFrom: {_db.purchasesTable},
        )
        .get();

    return rows
        .map(
          (row) => MarketSpending(
            marketName: row.read<String>('market_name'),
            total: Money.fromCents(row.read<int>('total')),
          ),
        )
        .toList();
  }

  @override
  Future<List<ProductPurchaseCount>> getMostBoughtProducts({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5,
  }) async {
    final rows = await _db
        .customSelect(
          '''
      SELECT pi.product_name, pi.product_type, COUNT(*) AS cnt
      FROM purchase_items_table pi
      JOIN purchases_table p ON pi.purchase_id = p.id
      WHERE p.completed_at >= ? AND p.completed_at <= ?
      GROUP BY pi.product_name
      ORDER BY cnt DESC
      LIMIT ?
      ''',
          variables: [
            Variable.withInt(startDate.millisecondsSinceEpoch ~/ 1000),
            Variable.withInt(endDate.millisecondsSinceEpoch ~/ 1000),
            Variable.withInt(limit),
          ],
          readsFrom: {_db.purchaseItemsTable, _db.purchasesTable},
        )
        .get();

    return rows
        .map(
          (row) => ProductPurchaseCount(
            productName: row.read<String>('product_name'),
            productType: row.read<String>('product_type'),
            count: row.read<int>('cnt'),
          ),
        )
        .toList();
  }

  @override
  Future<List<ProductSpendingTotal>> getTopSpendingProducts({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 5,
  }) async {
    final rows = await _db
        .customSelect(
          '''
      SELECT pi.product_name, pi.product_type,
             SUM(pi.total_price_cents) AS total
      FROM purchase_items_table pi
      JOIN purchases_table p ON pi.purchase_id = p.id
      WHERE p.completed_at >= ? AND p.completed_at <= ?
      GROUP BY pi.product_name
      ORDER BY total DESC
      LIMIT ?
      ''',
          variables: [
            Variable.withInt(startDate.millisecondsSinceEpoch ~/ 1000),
            Variable.withInt(endDate.millisecondsSinceEpoch ~/ 1000),
            Variable.withInt(limit),
          ],
          readsFrom: {_db.purchaseItemsTable, _db.purchasesTable},
        )
        .get();

    return rows
        .map(
          (row) => ProductSpendingTotal(
            productName: row.read<String>('product_name'),
            productType: row.read<String>('product_type'),
            total: Money.fromCents(row.read<int>('total')),
          ),
        )
        .toList();
  }

  @override
  Future<List<DayStatus>> getDailyBudgetStatus({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final rows = await _db
        .customSelect(
          '''
      SELECT
        date(completed_at, 'unixepoch') AS day,
        SUM(total_amount_cents) AS total_spent,
        SUM(CASE WHEN budget_goal_cents IS NOT NULL THEN budget_goal_cents ELSE 0 END) AS total_budget,
        MAX(CASE WHEN budget_goal_cents IS NOT NULL THEN 1 ELSE 0 END) AS has_budget
      FROM purchases_table
      WHERE completed_at >= ? AND completed_at <= ?
      GROUP BY day
      ORDER BY day ASC
      ''',
          variables: [
            Variable.withInt(startDate.millisecondsSinceEpoch ~/ 1000),
            Variable.withInt(endDate.millisecondsSinceEpoch ~/ 1000),
          ],
          readsFrom: {_db.purchasesTable},
        )
        .get();

    final purchaseByDay = <String, ({Money totalSpent, Money? budgetGoal})>{};
    for (final row in rows) {
      final day = row.read<String>('day');
      final totalSpent = Money.fromCents(row.read<int>('total_spent'));
      final hasBudget = row.read<int>('has_budget') == 1;
      final budgetGoal = hasBudget
          ? Money.fromCents(row.read<int>('total_budget'))
          : null;
      purchaseByDay[day] = (totalSpent: totalSpent, budgetGoal: budgetGoal);
    }

    final totalDays = endDate.difference(startDate).inDays + 1;
    return List.generate(totalDays, (i) {
      final date = startDate.add(Duration(days: i));
      final key =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final purchase = purchaseByDay[key];
      return DayStatus(
        date: date,
        totalSpent: purchase?.totalSpent,
        budgetGoal: purchase?.budgetGoal,
      );
    });
  }

  @override
  Future<BudgetExceededResult> getBudgetExceededCount({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final rows = await _db
        .customSelect(
          '''
      SELECT
        COUNT(*) AS total_purchases,
        COALESCE(SUM(CASE WHEN exceeded_budget = 1 AND budget_goal_cents IS NOT NULL THEN 1 ELSE 0 END), 0) AS exceeded_count
      FROM purchases_table
      WHERE completed_at >= ? AND completed_at <= ?
      ''',
          variables: [
            Variable.withInt(startDate.millisecondsSinceEpoch ~/ 1000),
            Variable.withInt(endDate.millisecondsSinceEpoch ~/ 1000),
          ],
          readsFrom: {_db.purchasesTable},
        )
        .get();

    if (rows.isEmpty) {
      return const BudgetExceededResult(exceededCount: 0, totalPurchases: 0);
    }

    final row = rows.first;
    return BudgetExceededResult(
      exceededCount: row.read<int>('exceeded_count'),
      totalPurchases: row.read<int>('total_purchases'),
    );
  }
}
