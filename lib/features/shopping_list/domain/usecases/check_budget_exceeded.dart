import '../../../../core/utils/money.dart';
import '../entities/shopping_list.dart';

sealed class BudgetCheckResult {
  const BudgetCheckResult();
}

final class WithinBudget extends BudgetCheckResult {
  const WithinBudget();
}

final class NoBudgetSet extends BudgetCheckResult {
  const NoBudgetSet();
}

final class ExceededBy extends BudgetCheckResult {
  const ExceededBy(this.amount);
  final Money amount;
}

class CheckBudgetExceeded {
  BudgetCheckResult call(final ShoppingList list) {
    if (list.budgetGoal == null) return const NoBudgetSet();
    if (list.exceedsBudget) return ExceededBy(list.amountOverBudget);
    return const WithinBudget();
  }
}
