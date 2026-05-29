import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:listai/core/network/supabase_client.dart';
import 'package:listai/core/network/sync_manager.dart';
import 'package:listai/features/auth/presentation/providers/auth_providers.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import '../../data/repositories/local_shopping_list_repository.dart';
import '../../data/repositories/remote_shopping_list_repository.dart';
import '../../data/repositories/composite_shopping_list_repository.dart';
import 'database_provider.dart';

final localShoppingListRepositoryProvider = Provider<LocalShoppingListRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalShoppingListRepository(db);
});

final remoteShoppingListRepositoryProvider = Provider<RemoteShoppingListRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return RemoteShoppingListRepository(client);
});

final syncManagerProvider = Provider<SyncManager>((ref) {
  final localRepo = ref.watch(localShoppingListRepositoryProvider);
  final remoteRepo = ref.watch(remoteShoppingListRepositoryProvider);
  final authRepo = ref.watch(authRepositoryProvider);

  final syncManager = SyncManager(
    localRepository: localRepo,
    remoteRepository: remoteRepo,
    isOnline: () async {
      final results = await Connectivity().checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    },
    getCurrentUserId: () => authRepo.currentUser?.id,
  );

  // Start listening to connectivity changes and execute background sync
  syncManager.startListening();
  syncManager.startPeriodicSync();

  ref.onDispose(() {
    syncManager.stopListening();
    syncManager.stopPeriodicSync();
  });

  return syncManager;
});

final shoppingListRepositoryProvider = Provider<ShoppingListRepository>((ref) {
  final localRepo = ref.watch(localShoppingListRepositoryProvider);
  final remoteRepo = ref.watch(remoteShoppingListRepositoryProvider);
  final syncManager = ref.watch(syncManagerProvider);

  return CompositeShoppingListRepository(
    localRepository: localRepo,
    remoteRepository: remoteRepo,
    syncManager: syncManager,
    isOnline: () async {
      final results = await Connectivity().checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    },
  );
});
