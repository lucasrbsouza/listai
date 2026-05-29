import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../features/shopping_list/data/repositories/local_shopping_list_repository.dart';
import '../../features/shopping_list/data/repositories/remote_shopping_list_repository.dart';
import '../../features/shopping_list/domain/entities/shopping_list.dart';
import '../errors/failures.dart';

class SyncManager {
  SyncManager({
    required this.localRepository,
    required this.remoteRepository,
    required this.isOnline,
    required this.getCurrentUserId,
  });

  final LocalShoppingListRepository localRepository;
  final RemoteShoppingListRepository remoteRepository;
  final Future<bool> Function() isOnline;
  final String? Function() getCurrentUserId;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _periodicTimer;
  final List<DateTime> _uploadTimestamps = [];

  void startListening() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) async {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection && await isOnline()) {
        await sync();
      }
    });
  }

  void stopListening() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  void startPeriodicSync({
    final Duration interval = const Duration(minutes: 15),
  }) {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(interval, (_) async {
      if (await isOnline()) {
        await sync();
      }
    });
  }

  void stopPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  bool _canUpload() {
    final now = DateTime.now();
    _uploadTimestamps.removeWhere(
      (t) => now.difference(t) > const Duration(minutes: 1),
    );
    return _uploadTimestamps.length < 100;
  }

  void _recordUpload() {
    _uploadTimestamps.add(DateTime.now());
  }

  Future<void> sync() async {
    final userId = getCurrentUserId();
    if (userId == null) return; // Security: do not sync if not logged in

    if (!await isOnline()) return;

    try {
      final pending = await localRepository.getPendingUploads();
      if (pending.isEmpty) return;

      for (final localList in pending) {
        if (!_canUpload()) {
          // Rate limit exceeded: pause sync for this cycle
          break;
        }

        try {
          ShoppingList? remoteList;
          try {
            remoteList = await remoteRepository.getListById(localList.id);
          } on NotFoundFailure {
            remoteList = null;
          }

          if (remoteList == null) {
            // Remote does not exist: upload local list
            final authenticatedList = localList.copyWith(userId: userId);
            _recordUpload();
            await remoteRepository.saveCurrentList(authenticatedList);
            await localRepository.updateSyncStatus(localList.id, 'synced');
          } else {
            // Conflict exists: resolve using Last-Write-Wins (LWW)
            if (localList.updatedAt.isAtSameMomentAs(remoteList.updatedAt) &&
                (localList.name != remoteList.name ||
                    localList.marketName != remoteList.marketName)) {
              // Critical conflict: identical updatedAt but different details
              await localRepository.updateSyncStatus(localList.id, 'conflict');
            } else if (localList.updatedAt.isAfter(remoteList.updatedAt)) {
              // Local is newer: upload local list
              final authenticatedList = localList.copyWith(userId: userId);
              _recordUpload();
              await remoteRepository.saveCurrentList(authenticatedList);
              await localRepository.updateSyncStatus(localList.id, 'synced');
            } else {
              // Remote is newer: overwrite local with remote list
              await localRepository.saveCurrentList(remoteList);
              await localRepository.updateSyncStatus(localList.id, 'synced');
            }
          }
        } catch (_) {
          // Ignore list-specific failures to proceed with remaining lists
          continue;
        }
      }
    } catch (_) {
      // Global sync error handling
    }
  }

  Future<void> migrateLocalToCloud() async {
    final userId = getCurrentUserId();
    if (userId == null) return;

    try {
      final pending = await localRepository.getPendingUploads();
      for (final localList in pending) {
        if (!_canUpload()) break;

        final authenticatedList = localList.copyWith(userId: userId);
        _recordUpload();
        await remoteRepository.saveCurrentList(authenticatedList);
        await localRepository.saveCurrentList(authenticatedList);
        await localRepository.updateSyncStatus(localList.id, 'synced');
      }
    } catch (_) {
      // Migration error handling
    }
  }
}
