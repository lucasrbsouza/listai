import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:listai/core/errors/failures.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/data/repositories/local_shopping_list_repository.dart';
import 'package:listai/features/shopping_list/data/repositories/remote_shopping_list_repository.dart';
import 'package:listai/core/network/sync_manager.dart';

class MockLocalRepository extends Mock implements LocalShoppingListRepository {}

class MockRemoteRepository extends Mock
    implements RemoteShoppingListRepository {}

class FakeShoppingList extends Fake implements ShoppingList {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeShoppingList());
  });

  late MockLocalRepository mockLocalRepository;
  late MockRemoteRepository mockRemoteRepository;
  late SyncManager syncManager;
  late bool isOnlineMock;
  late String? userIdMock;

  setUp(() {
    mockLocalRepository = MockLocalRepository();
    mockRemoteRepository = MockRemoteRepository();
    isOnlineMock = true;
    userIdMock = 'user-123';

    syncManager = SyncManager(
      localRepository: mockLocalRepository,
      remoteRepository: mockRemoteRepository,
      isOnline: () async => isOnlineMock,
      getCurrentUserId: () => userIdMock,
    );
  });

  ShoppingList createTestList({
    required String id,
    required DateTime updatedAt,
  }) {
    return ShoppingList(
      id: id,
      userId: userIdMock,
      name: 'Lista Teste',
      createdAt: DateTime.now(),
      updatedAt: updatedAt,
      items: [],
    );
  }

  group('SyncManager - Offline to Online Upload', () {
    test('uploads pending lists to remote when online', () async {
      final list = createTestList(id: 'list-1', updatedAt: DateTime.now());

      when(
        () => mockLocalRepository.getPendingUploads(),
      ).thenAnswer((_) async => [list]);
      when(
        () => mockRemoteRepository.getListById('list-1'),
      ).thenThrow(NotFoundFailure('Not found'));
      when(
        () => mockRemoteRepository.saveCurrentList(list),
      ).thenAnswer((_) async {});
      when(
        () => mockLocalRepository.updateSyncStatus('list-1', 'synced'),
      ).thenAnswer((_) async {});

      await syncManager.sync();

      verify(() => mockRemoteRepository.saveCurrentList(list)).called(1);
      verify(
        () => mockLocalRepository.updateSyncStatus('list-1', 'synced'),
      ).called(1);
    });

    test('does not upload anything when offline', () async {
      isOnlineMock = false;

      await syncManager.sync();

      verifyNever(() => mockLocalRepository.getPendingUploads());
      verifyNever(() => mockRemoteRepository.saveCurrentList(any()));
    });
  });

  group('SyncManager - Conflict Resolution', () {
    test('resolves conflict with Last-Write-Wins (Local is Newer)', () async {
      final now = DateTime.now();
      final localList = createTestList(
        id: 'list-1',
        updatedAt: now.add(const Duration(minutes: 5)),
      );
      final remoteList = createTestList(id: 'list-1', updatedAt: now);

      when(
        () => mockLocalRepository.getPendingUploads(),
      ).thenAnswer((_) async => [localList]);
      when(
        () => mockRemoteRepository.getListById('list-1'),
      ).thenAnswer((_) async => remoteList);
      when(
        () => mockRemoteRepository.saveCurrentList(localList),
      ).thenAnswer((_) async {});
      when(
        () => mockLocalRepository.updateSyncStatus('list-1', 'synced'),
      ).thenAnswer((_) async {});

      await syncManager.sync();

      verify(() => mockRemoteRepository.saveCurrentList(localList)).called(1);
      verify(
        () => mockLocalRepository.updateSyncStatus('list-1', 'synced'),
      ).called(1);
    });

    test(
      'resolves conflict with Last-Write-Wins (Remote is Newer) - Marks local as synced and overwrites local',
      () async {
        final now = DateTime.now();
        final localList = createTestList(id: 'list-1', updatedAt: now);
        final remoteList = createTestList(
          id: 'list-1',
          updatedAt: now.add(const Duration(minutes: 5)),
        );

        when(
          () => mockLocalRepository.getPendingUploads(),
        ).thenAnswer((_) async => [localList]);
        when(
          () => mockRemoteRepository.getListById('list-1'),
        ).thenAnswer((_) async => remoteList);
        when(
          () => mockLocalRepository.saveCurrentList(remoteList),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalRepository.updateSyncStatus('list-1', 'synced'),
        ).thenAnswer((_) async {});

        await syncManager.sync();

        verify(() => mockLocalRepository.saveCurrentList(remoteList)).called(1);
        verify(
          () => mockLocalRepository.updateSyncStatus('list-1', 'synced'),
        ).called(1);
        verifyNever(() => mockRemoteRepository.saveCurrentList(any()));
      },
    );
  });

  group('SyncManager - Local Data Migration', () {
    test('migrates local offline data to cloud', () async {
      final list = createTestList(
        id: 'list-offline',
        updatedAt: DateTime.now(),
      ).copyWith(userId: null);

      when(
        () => mockLocalRepository.getPendingUploads(),
      ).thenAnswer((_) async => [list]);
      when(
        () => mockRemoteRepository.saveCurrentList(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockLocalRepository.saveCurrentList(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockLocalRepository.updateSyncStatus(any(), any()),
      ).thenAnswer((_) async {});

      await syncManager.migrateLocalToCloud();

      verify(() => mockRemoteRepository.saveCurrentList(any())).called(1);
    });
  });
}
