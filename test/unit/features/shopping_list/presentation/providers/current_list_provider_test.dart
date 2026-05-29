import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/domain/repositories/shopping_list_repository.dart';
import 'package:listai/features/shopping_list/presentation/providers/current_list_provider.dart';
import 'package:listai/features/shopping_list/presentation/providers/shopping_list_repository_provider.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';

class MockShoppingListRepository extends Mock
    implements ShoppingListRepository {}

class FakeShoppingList extends Fake implements ShoppingList {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeShoppingList());
  });

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

  ShoppingList _createEmptyList() => ShoppingList(
    id: 'list-1',
    name: 'Minha Lista',
    marketName: 'Mercado',
    items: [],
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
    isCompleted: false,
    isTemplate: false,
  );

  ShoppingItem _createItem(String id) => ShoppingItem(
    id: id,
    productType: 'Type',
    productName: 'Product $id',
    quantity: Quantity.unit(),
    unitPrice: Money.fromReais(1),
    position: 0,
    createdAt: DateTime(2024),
  );

  test('initial state is AsyncLoading and loads current list', () async {
    final list = _createEmptyList();
    when(() => mockRepository.getCurrentList()).thenAnswer((_) async => list);
    when(
      () => mockRepository.watchCurrentList(),
    ).thenAnswer((_) => Stream.value(list));

    final sub = container.listen(currentListProvider, (_, __) {});

    expect(
      container.read(currentListProvider),
      const AsyncValue<ShoppingList?>.loading(),
    );

    await Future.delayed(Duration.zero);

    expect(container.read(currentListProvider).value, list);
    verify(() => mockRepository.watchCurrentList()).called(1);
    sub.close();
  });

  test('addItem updates state and calls repository', () async {
    final list = _createEmptyList();
    when(
      () => mockRepository.watchCurrentList(),
    ).thenAnswer((_) => Stream.value(list));
    when(() => mockRepository.saveCurrentList(any())).thenAnswer((_) async {});

    final sub = container.listen(currentListProvider, (_, __) {});
    await Future.delayed(Duration.zero); // wait for initial load

    final item = _createItem('item-1');
    await container.read(currentListProvider.notifier).addItem(item);

    final currentList = container.read(currentListProvider).value!;
    expect(currentList.items.length, 1);
    expect(currentList.items.first, item);

    verify(() => mockRepository.saveCurrentList(any())).called(1);
    sub.close();
  });

  test(
    'addItemWithSubstitute stores both items and links main to substitute',
    () async {
      final list = _createEmptyList();
      when(
        () => mockRepository.watchCurrentList(),
      ).thenAnswer((_) => Stream.value(list));
      when(
        () => mockRepository.saveCurrentList(any()),
      ).thenAnswer((_) async {});

      final sub = container.listen(currentListProvider, (_, __) {});
      await Future.delayed(Duration.zero);

      final substitute = _createItem('sub-1');
      final main = _createItem(
        'item-1',
      ).copyWith(substituteItemId: substitute.id);

      await container
          .read(currentListProvider.notifier)
          .addItemWithSubstitute(main: main, substitute: substitute);

      final currentList = container.read(currentListProvider).value!;
      expect(currentList.items, hasLength(2));
      expect(
        currentList.items
            .firstWhere((item) => item.id == 'item-1')
            .substituteItemId,
        'sub-1',
      );
      expect(currentList.items.any((item) => item.id == 'sub-1'), isTrue);
      verify(() => mockRepository.saveCurrentList(any())).called(1);
      sub.close();
    },
  );

  test('removeItem updates state and calls repository', () async {
    final item = _createItem('item-1');
    final list = _createEmptyList().copyWith(items: [item]);

    when(
      () => mockRepository.watchCurrentList(),
    ).thenAnswer((_) => Stream.value(list));
    when(() => mockRepository.saveCurrentList(any())).thenAnswer((_) async {});

    final sub = container.listen(currentListProvider, (_, __) {});
    await Future.delayed(Duration.zero);

    await container.read(currentListProvider.notifier).removeItem('item-1');

    final currentList = container.read(currentListProvider).value!;
    expect(currentList.items, isEmpty);

    verify(() => mockRepository.saveCurrentList(any())).called(1);
    sub.close();
  });

  test('removeItem deletes substitute together with principal', () async {
    final substitute = _createItem('sub-1');
    final main = _createItem(
      'item-1',
    ).copyWith(substituteItemId: substitute.id);
    final list = _createEmptyList().copyWith(items: [main, substitute]);

    when(
      () => mockRepository.watchCurrentList(),
    ).thenAnswer((_) => Stream.value(list));
    when(() => mockRepository.saveCurrentList(any())).thenAnswer((_) async {});

    final sub = container.listen(currentListProvider, (_, __) {});
    await Future.delayed(Duration.zero);

    await container.read(currentListProvider.notifier).removeItem('item-1');

    final currentList = container.read(currentListProvider).value!;
    expect(currentList.items.map((item) => item.id), isNot(contains('item-1')));
    expect(currentList.items.map((item) => item.id), isNot(contains('sub-1')));
    verify(() => mockRepository.saveCurrentList(any())).called(1);
    sub.close();
  });

  test('updateItem updates state and calls repository', () async {
    final item = _createItem('item-1');
    final list = _createEmptyList().copyWith(items: [item]);

    when(
      () => mockRepository.watchCurrentList(),
    ).thenAnswer((_) => Stream.value(list));
    when(() => mockRepository.saveCurrentList(any())).thenAnswer((_) async {});

    final sub = container.listen(currentListProvider, (_, __) {});
    await Future.delayed(Duration.zero);

    final updatedItem = item.copyWith(productName: 'Updated');
    await container.read(currentListProvider.notifier).updateItem(updatedItem);

    final currentList = container.read(currentListProvider).value!;
    expect(currentList.items.first.productName, 'Updated');

    verify(() => mockRepository.saveCurrentList(any())).called(1);
    sub.close();
  });

  test('swapWithSubstitute inverts principal and substitute roles', () async {
    final substitute = _createItem('sub-1').copyWith(productName: 'Feijão');
    final main = _createItem(
      'item-1',
    ).copyWith(productName: 'Arroz', substituteItemId: substitute.id);
    final list = _createEmptyList().copyWith(items: [main, substitute]);

    when(
      () => mockRepository.watchCurrentList(),
    ).thenAnswer((_) => Stream.value(list));
    when(() => mockRepository.saveCurrentList(any())).thenAnswer((_) async {});

    final sub = container.listen(currentListProvider, (_, __) {});
    await Future.delayed(Duration.zero);

    await container
        .read(currentListProvider.notifier)
        .swapWithSubstitute('item-1');

    final currentList = container.read(currentListProvider).value!;
    final newMain = currentList.items.firstWhere((item) => item.id == 'sub-1');
    final newSubstitute = currentList.items.firstWhere(
      (item) => item.id == 'item-1',
    );

    expect(newMain.substituteItemId, 'item-1');
    expect(newMain.position, 0);
    expect(newSubstitute.substituteItemId, isNull);
    verify(() => mockRepository.saveCurrentList(any())).called(1);
    sub.close();
  });

  test('clearAll removes all items and calls repository', () async {
    final list = _createEmptyList().copyWith(
      items: [_createItem('item-1'), _createItem('item-2')],
    );

    when(
      () => mockRepository.watchCurrentList(),
    ).thenAnswer((_) => Stream.value(list));
    when(() => mockRepository.saveCurrentList(any())).thenAnswer((_) async {});

    final sub = container.listen(currentListProvider, (_, __) {});
    await Future.delayed(Duration.zero);

    await container.read(currentListProvider.notifier).clearAll();

    final currentList = container.read(currentListProvider).value!;
    expect(currentList.items, isEmpty);

    verify(() => mockRepository.saveCurrentList(any())).called(1);
    sub.close();
  });

  test('undo reverts last action', () async {
    final list = _createEmptyList();
    when(
      () => mockRepository.watchCurrentList(),
    ).thenAnswer((_) => Stream.value(list));
    when(() => mockRepository.saveCurrentList(any())).thenAnswer((_) async {});

    final sub = container.listen(currentListProvider, (_, __) {});
    await Future.delayed(Duration.zero);

    final item = _createItem('item-1');
    await container.read(currentListProvider.notifier).addItem(item);

    expect(container.read(currentListProvider).value!.items.length, 1);

    await container.read(currentListProvider.notifier).undo();

    expect(container.read(currentListProvider).value!.items, isEmpty);

    // Save is called twice: once for add, once for undo
    verify(() => mockRepository.saveCurrentList(any())).called(2);
    sub.close();
  });

  test('undo maintains maximum 5 history states', () async {
    final list = _createEmptyList();
    when(
      () => mockRepository.watchCurrentList(),
    ).thenAnswer((_) => Stream.value(list));
    when(() => mockRepository.saveCurrentList(any())).thenAnswer((_) async {});

    final sub = container.listen(currentListProvider, (_, __) {});
    await Future.delayed(Duration.zero);

    // Add 6 items
    for (int i = 0; i < 6; i++) {
      await container
          .read(currentListProvider.notifier)
          .addItem(_createItem('item-$i'));
    }

    expect(container.read(currentListProvider).value!.items.length, 6);

    // Undo 6 times (should only go back 5 times)
    for (int i = 0; i < 6; i++) {
      await container.read(currentListProvider.notifier).undo();
    }

    // Original list was 0 items, then we added 1, 2, 3, 4, 5, 6
    // The history only keeps 5 states. Before 6th add, state had 5 items.
    // So 5 undo steps take us back to state with 1 item.
    expect(container.read(currentListProvider).value!.items.length, 1);
    sub.close();
  });

  test(
    'finalizePurchase calls repository and clears state if needed',
    () async {
      final list = _createEmptyList();
      when(
        () => mockRepository.watchCurrentList(),
      ).thenAnswer((_) => Stream.value(list));
      when(
        () => mockRepository.finalizePurchase(any()),
      ).thenAnswer((_) async {});

      final sub = container.listen(currentListProvider, (_, __) {});
      await Future.delayed(Duration.zero);

      await container.read(currentListProvider.notifier).finalizePurchase();

      verify(() => mockRepository.finalizePurchase(list)).called(1);
      sub.close();
    },
  );

  test('repository errors convert to AsyncError', () async {
    final list = _createEmptyList();
    when(
      () => mockRepository.watchCurrentList(),
    ).thenAnswer((_) => Stream.value(list));
    when(
      () => mockRepository.saveCurrentList(any()),
    ).thenThrow(Exception('DB Error'));

    final sub = container.listen(currentListProvider, (_, __) {});
    await Future.delayed(Duration.zero);

    await container
        .read(currentListProvider.notifier)
        .addItem(_createItem('item-1'));

    expect(container.read(currentListProvider).hasError, true);
    expect(
      container.read(currentListProvider).error.toString(),
      contains('DB Error'),
    );
    sub.close();
  });

  test(
    'replaceWithTemplate updates state with new id and false isTemplate',
    () async {
      final list = _createEmptyList();
      when(
        () => mockRepository.watchCurrentList(),
      ).thenAnswer((_) => Stream.value(list));
      when(
        () => mockRepository.saveCurrentList(any()),
      ).thenAnswer((_) async {});

      final sub = container.listen(currentListProvider, (_, __) {});
      await Future.delayed(Duration.zero);

      final templateItem = _createItem('template-item-1');
      final template = ShoppingList(
        id: 'template-1',
        name: 'My Template',
        isTemplate: true,
        items: [templateItem],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await container
          .read(currentListProvider.notifier)
          .replaceWithTemplate(template);

      final currentList = container.read(currentListProvider).value!;

      expect(currentList.id, isNot('template-1'));
      expect(currentList.name, 'My Template');
      expect(currentList.isTemplate, false);
      expect(currentList.isCompleted, false);
      expect(currentList.items.length, 1);
      expect(
        currentList.items.first.id,
        isNot('template-item-1'),
      ); // item ID should be newly generated
      expect(currentList.items.first.productName, 'Product template-item-1');

      verify(() => mockRepository.saveCurrentList(any())).called(1);
      sub.close();
    },
  );

  test('createNewList creates a list with the given name', () async {
    when(
      () => mockRepository.watchCurrentList(),
    ).thenAnswer((_) => Stream.value(null));
    when(() => mockRepository.saveCurrentList(any())).thenAnswer((_) async {});

    final sub = container.listen(currentListProvider, (_, __) {});
    await Future<void>.delayed(Duration.zero);

    // State should initially be null (no list)
    expect(container.read(currentListProvider).value, isNull);

    await container
        .read(currentListProvider.notifier)
        .createNewList('Compras da semana');

    final newList = container.read(currentListProvider).value!;
    expect(newList.name, 'Compras da semana');
    expect(newList.items, isEmpty);
    verify(() => mockRepository.saveCurrentList(any())).called(1);
    sub.close();
  });

  test('renameList updates the list name', () async {
    final list = _createEmptyList();
    when(
      () => mockRepository.watchCurrentList(),
    ).thenAnswer((_) => Stream.value(list));
    when(() => mockRepository.saveCurrentList(any())).thenAnswer((_) async {});

    final sub = container.listen(currentListProvider, (_, __) {});
    await Future<void>.delayed(Duration.zero);

    expect(container.read(currentListProvider).value!.name, 'Minha Lista');

    await container
        .read(currentListProvider.notifier)
        .renameList('Lista do Mês');

    final renamed = container.read(currentListProvider).value!;
    expect(renamed.name, 'Lista do Mês');
    verify(() => mockRepository.saveCurrentList(any())).called(1);
    sub.close();
  });

  test('renameList does nothing when current list is null', () async {
    when(
      () => mockRepository.watchCurrentList(),
    ).thenAnswer((_) => Stream.value(null));
    when(() => mockRepository.saveCurrentList(any())).thenAnswer((_) async {});

    final sub = container.listen(currentListProvider, (_, __) {});
    await Future<void>.delayed(Duration.zero);

    await container
        .read(currentListProvider.notifier)
        .renameList('Novo Nome');

    verifyNever(() => mockRepository.saveCurrentList(any()));
    sub.close();
  });

  test('updateMarketName sets the market name', () async {
    final list = _createEmptyList();
    when(
      () => mockRepository.watchCurrentList(),
    ).thenAnswer((_) => Stream.value(list));
    when(() => mockRepository.saveCurrentList(any())).thenAnswer((_) async {});

    final sub = container.listen(currentListProvider, (_, __) {});
    await Future<void>.delayed(Duration.zero);

    await container
        .read(currentListProvider.notifier)
        .updateMarketName('Pão de Açúcar');

    final updated = container.read(currentListProvider).value!;
    expect(updated.marketName, 'Pão de Açúcar');
    verify(() => mockRepository.saveCurrentList(any())).called(1);
    sub.close();
  });

  test('updateMarketName clears market name when null', () async {
    final list = _createEmptyList();
    when(
      () => mockRepository.watchCurrentList(),
    ).thenAnswer((_) => Stream.value(list));
    when(() => mockRepository.saveCurrentList(any())).thenAnswer((_) async {});

    final sub = container.listen(currentListProvider, (_, __) {});
    await Future<void>.delayed(Duration.zero);

    await container
        .read(currentListProvider.notifier)
        .updateMarketName(null);

    final updated = container.read(currentListProvider).value!;
    expect(updated.marketName, isNull);
    verify(() => mockRepository.saveCurrentList(any())).called(1);
    sub.close();
  });

  test('addItem throws StateError when no list exists', () async {
    when(
      () => mockRepository.watchCurrentList(),
    ).thenAnswer((_) => Stream.value(null));

    final sub = container.listen(currentListProvider, (_, __) {});
    await Future<void>.delayed(Duration.zero);

    final item = _createItem('item-1');
    expect(
      () => container.read(currentListProvider.notifier).addItem(item),
      throwsStateError,
    );
    sub.close();
  });
}
