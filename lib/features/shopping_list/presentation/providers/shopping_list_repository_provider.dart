import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import '../../data/repositories/local_shopping_list_repository.dart';
import 'database_provider.dart';

final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalShoppingListRepository(db);
});
