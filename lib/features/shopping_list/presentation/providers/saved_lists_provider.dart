import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/presentation/providers/shopping_list_repository_provider.dart';

final savedListsProvider = FutureProvider<List<ShoppingList>>((ref) async {
  final repository = ref.watch(shoppingListRepositoryProvider);
  return await repository.getSavedLists();
});
