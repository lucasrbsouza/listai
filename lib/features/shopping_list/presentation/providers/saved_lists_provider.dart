import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/presentation/providers/shopping_list_repository_provider.dart';

// autoDispose so the list is re-queried every time the screen is opened.
// Without it the FutureProvider caches its first result and a purchase
// finalized afterwards never shows up in the history tab.
final savedListsProvider = FutureProvider.autoDispose<List<ShoppingList>>((
  ref,
) async {
  final repository = ref.watch(shoppingListRepositoryProvider);
  return await repository.getSavedLists();
});
