import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/domain/usecases/check_budget_exceeded.dart';
import 'package:listai/features/shopping_list/presentation/providers/current_list_provider.dart';

final budgetProvider = StreamProvider<BudgetCheckResult>((ref) {
  final checkBudget = CheckBudgetExceeded();
  final controller = StreamController<BudgetCheckResult>();

  final sub = ref.listen<AsyncValue<ShoppingList?>>(currentListProvider, (
    previous,
    next,
  ) {
    next.when(
      data: (list) {
        if (list == null) {
          controller.add(const NoBudgetSet());
        } else {
          controller.add(checkBudget(list));
        }
      },
      error: (_, __) {
        controller.add(const NoBudgetSet());
      },
      loading: () {},
    );
  }, fireImmediately: true);

  ref.onDispose(() {
    sub.close();
    controller.close();
  });

  return controller.stream;
});

// A simple state provider to keep track of whether the exceeded budget dialog has been shown in the current session.
final hasShownBudgetDialogProvider = StateProvider<bool>((ref) => false);
