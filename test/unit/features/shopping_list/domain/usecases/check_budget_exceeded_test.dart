import 'package:flutter_test/flutter_test.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/domain/usecases/check_budget_exceeded.dart';

ShoppingItem _item(String id, Money price, {int position = 0}) => ShoppingItem(
  id: id,
  productType: 'T',
  productName: 'P',
  quantity: Quantity.unit(),
  unitPrice: price,
  position: position,
  createdAt: DateTime(2024),
);

ShoppingList _list({List<ShoppingItem> items = const [], Money? budgetGoal}) =>
    ShoppingList(
      id: 'l',
      name: 'L',
      items: items,
      budgetGoal: budgetGoal,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

void main() {
  final useCase = CheckBudgetExceeded();

  test('NoBudgetSet when no budget set', () {
    final result = useCase(_list(items: [_item('a', Money.fromReais(100))]));
    expect(result, isA<NoBudgetSet>());
  });

  test('WithinBudget when total below goal', () {
    final result = useCase(
      _list(
        items: [_item('a', Money.fromReais(5))],
        budgetGoal: Money.fromReais(10),
      ),
    );
    expect(result, isA<WithinBudget>());
  });

  test('WithinBudget when total equals goal', () {
    final result = useCase(
      _list(
        items: [_item('a', Money.fromReais(10))],
        budgetGoal: Money.fromReais(10),
      ),
    );
    expect(result, isA<WithinBudget>());
  });

  test('ExceededBy when total above goal', () {
    final result = useCase(
      _list(
        items: [_item('a', Money.fromReais(15))],
        budgetGoal: Money.fromReais(10),
      ),
    );
    expect(result, isA<ExceededBy>());
    expect((result as ExceededBy).amount.cents, 500);
  });

  test('NoBudgetSet on empty list without budget', () {
    expect(useCase(_list()), isA<NoBudgetSet>());
  });

  test('WithinBudget on empty list with budget', () {
    expect(
      useCase(_list(budgetGoal: Money.fromReais(100))),
      isA<WithinBudget>(),
    );
  });
}
