import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:listai/core/errors/failures.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/domain/repositories/shopping_list_repository.dart';
import 'package:listai/features/shopping_list/data/repositories/local_shopping_list_repository.dart';
import 'package:listai/features/shopping_list/data/repositories/remote_shopping_list_repository.dart';
import 'package:listai/features/shopping_list/data/repositories/composite_shopping_list_repository.dart';
import 'package:listai/core/network/sync_manager.dart';

class MockLocalRepository extends Mock implements LocalShoppingListRepository {}

class MockRemoteRepository extends Mock
    implements RemoteShoppingListRepository {}

class MockSyncManager extends Mock implements SyncManager {}

class FakeShoppingList extends Fake implements ShoppingList {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeShoppingList());
  });

  late MockLocalRepository mockLocalRepository;
  late MockRemoteRepository mockRemoteRepository;
  late MockSyncManager mockSyncManager;
  late CompositeShoppingListRepository compositeRepository;
  late bool isOnlineMock;

  setUp(() {
    mockLocalRepository = MockLocalRepository();
    mockRemoteRepository = MockRemoteRepository();
    mockSyncManager = MockSyncManager();
    isOnlineMock = true;

    compositeRepository = CompositeShoppingListRepository(
      localRepository: mockLocalRepository,
      remoteRepository: mockRemoteRepository,
      syncManager: mockSyncManager,
      isOnline: () async => isOnlineMock,
    );
  });

  ShoppingList createTestList() {
    return ShoppingList(
      id: 'list-1',
      name: 'Lista Teste',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: [],
    );
  }

  group('CompositeShoppingListRepository - Reads', () {
    test('getCurrentList delegates to local repository', () async {
      final list = createTestList();
      when(
        () => mockLocalRepository.getCurrentList(),
      ).thenAnswer((_) async => list);

      final result = await compositeRepository.getCurrentList();

      expect(result, list);
      verify(() => mockLocalRepository.getCurrentList()).called(1);
      verifyNever(() => mockRemoteRepository.getCurrentList());
    });

    test('getSavedLists delegates to local repository', () async {
      final lists = [createTestList()];
      when(
        () => mockLocalRepository.getSavedLists(),
      ).thenAnswer((_) async => lists);

      final result = await compositeRepository.getSavedLists();

      expect(result, lists);
      verify(() => mockLocalRepository.getSavedLists()).called(1);
    });

    test('watchCurrentList streams from local repository', () async {
      final list = createTestList();
      when(
        () => mockLocalRepository.watchCurrentList(),
      ).thenAnswer((_) => Stream.value(list));

      final stream = compositeRepository.watchCurrentList();

      expect(await stream.first, list);
      verify(() => mockLocalRepository.watchCurrentList()).called(1);
    });
  });

  group('CompositeShoppingListRepository - Writes', () {
    test(
      'saveCurrentList saves locally and triggers background sync when online',
      () async {
        final list = createTestList();
        when(
          () => mockLocalRepository.saveCurrentList(list),
        ).thenAnswer((_) async {});
        when(() => mockSyncManager.sync()).thenAnswer((_) async {});

        await compositeRepository.saveCurrentList(list);

        verify(() => mockLocalRepository.saveCurrentList(list)).called(1);
        verify(() => mockSyncManager.sync()).called(1);
      },
    );

    test(
      'saveCurrentList saves locally but does NOT trigger sync when offline',
      () async {
        isOnlineMock = false;
        final list = createTestList();
        when(
          () => mockLocalRepository.saveCurrentList(list),
        ).thenAnswer((_) async {});

        await compositeRepository.saveCurrentList(list);

        verify(() => mockLocalRepository.saveCurrentList(list)).called(1);
        verifyNever(() => mockSyncManager.sync());
      },
    );

    test(
      'deleteList deletes locally and deletes remotely when online',
      () async {
        when(
          () => mockLocalRepository.deleteList('list-1'),
        ).thenAnswer((_) async {});
        when(
          () => mockRemoteRepository.deleteList('list-1'),
        ).thenAnswer((_) async {});

        await compositeRepository.deleteList('list-1');

        verify(() => mockLocalRepository.deleteList('list-1')).called(1);
        verify(() => mockRemoteRepository.deleteList('list-1')).called(1);
      },
    );

    test(
      'deleteList deletes locally and does NOT delete remotely when offline',
      () async {
        isOnlineMock = false;
        when(
          () => mockLocalRepository.deleteList('list-1'),
        ).thenAnswer((_) async {});

        await compositeRepository.deleteList('list-1');

        verify(() => mockLocalRepository.deleteList('list-1')).called(1);
        verifyNever(() => mockRemoteRepository.deleteList(any()));
      },
    );
  });
}
