import 'dart:async';
import '../../domain/entities/shopping_list.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import 'local_shopping_list_repository.dart';
import 'remote_shopping_list_repository.dart';
import '../../../../core/network/sync_manager.dart';

class CompositeShoppingListRepository implements ShoppingListRepository {
  CompositeShoppingListRepository({
    required this.localRepository,
    required this.remoteRepository,
    required this.syncManager,
    required this.isOnline,
  });

  final LocalShoppingListRepository localRepository;
  final RemoteShoppingListRepository remoteRepository;
  final SyncManager syncManager;
  final Future<bool> Function() isOnline;

  @override
  Future<ShoppingList?> getCurrentList() async {
    return await localRepository.getCurrentList();
  }

  @override
  Future<void> saveCurrentList(final ShoppingList list) async {
    await localRepository.saveCurrentList(list);
    if (await isOnline()) {
      unawaited(syncManager.sync());
    }
  }

  @override
  Future<List<ShoppingList>> getSavedLists() async {
    return await localRepository.getSavedLists();
  }

  @override
  Future<ShoppingList> getListById(final String id) async {
    return await localRepository.getListById(id);
  }

  @override
  Future<void> saveAsTemplate(final ShoppingList list) async {
    await localRepository.saveAsTemplate(list);
    if (await isOnline()) {
      unawaited(syncManager.sync());
    }
  }

  @override
  Future<void> deleteList(final String id) async {
    await localRepository.deleteList(id);
    if (await isOnline()) {
      try {
        await remoteRepository.deleteList(id);
      } catch (_) {
        // Ignore remote deletion errors, relying on sync resolution if any
      }
    }
  }

  @override
  Future<void> finalizePurchase(final ShoppingList list) async {
    await localRepository.finalizePurchase(list);
    if (await isOnline()) {
      unawaited(syncManager.sync());
    }
  }

  @override
  Stream<ShoppingList?> watchCurrentList() {
    return localRepository.watchCurrentList();
  }
}
