import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/domain/repositories/shopping_list_repository.dart';
import 'package:listai/features/shopping_list/presentation/providers/shopping_list_repository_provider.dart';
import 'package:listai/features/shopping_list/presentation/providers/saved_lists_provider.dart';

class MockShoppingListRepository extends Mock
    implements ShoppingListRepository {}

void main() {
  late MockShoppingListRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockShoppingListRepository();
    container = ProviderContainer(
      overrides: [
        shoppingListRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('loads saved lists from repository successfully', () async {
    final lists = [
      ShoppingList(
        id: '1',
        name: 'Lista 1',
        items: [],
        isTemplate: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ShoppingList(
        id: '2',
        name: 'Lista 2',
        items: [],
        isCompleted: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    when(() => mockRepository.getSavedLists()).thenAnswer((_) async => lists);

    final savedListsAsync = container.read(savedListsProvider);
    expect(savedListsAsync, const AsyncValue<List<ShoppingList>>.loading());

    final savedLists = await container.read(savedListsProvider.future);

    expect(savedLists, lists);
    verify(() => mockRepository.getSavedLists()).called(1);
  });

  test('returns error state if repository throws exception', () async {
    final exception = Exception('Failed to load lists');
    when(() => mockRepository.getSavedLists()).thenThrow(exception);

    try {
      await container.read(savedListsProvider.future);
      fail('Should have thrown an exception');
    } catch (e) {
      expect(e, exception);
    }
  });
}
