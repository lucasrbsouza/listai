import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/photo_capture/data/photo_repository.dart';
import 'package:listai/features/shopping_list/presentation/providers/current_list_provider.dart';
import 'package:listai/features/shopping_list/presentation/screens/item_form_screen.dart';

class FakeCurrentListNotifier extends StateNotifier<AsyncValue<ShoppingList?>>
    implements CurrentListNotifier {
  FakeCurrentListNotifier(super.state);

  ShoppingItem? addedItem;
  ShoppingItem? updatedItem;
  ShoppingItem? addedMainItem;
  ShoppingItem? addedSubstituteItem;

  @override
  Future<void> addItem(ShoppingItem item) async {
    addedItem = item;
  }

  Future<void> addItemWithSubstitute({
    required ShoppingItem main,
    required ShoppingItem substitute,
  }) async {
    addedMainItem = main;
    addedSubstituteItem = substitute;
  }

  @override
  Future<void> clearAll() async {}

  @override
  Future<void> finalizePurchase() async {}

  @override
  Future<void> removeItem(String itemId) async {}

  @override
  Future<void> undo() async {}

  @override
  Future<void> updateItem(ShoppingItem updatedItem) async {
    this.updatedItem = updatedItem;
  }

  Future<void> swapWithSubstitute(String mainItemId) async {}

  @override
  Future<void> replaceWithTemplate(ShoppingList template) async {}

  @override
  Future<void> updateBudgetGoal(Money? budgetGoal) async {}

  @override
  void dispose() {
    super.dispose();
  }
}

class FakePhotoRepository implements PhotoRepository {
  FakePhotoRepository({String path = '/tmp/item-photo.jpg'}) : paths = [path];

  FakePhotoRepository.withPaths(this.paths);

  final List<String> paths;
  int captureCount = 0;
  String? capturedItemId;
  String? deletedPath;

  @override
  Future<String> capturePhoto({required String itemId}) async {
    captureCount += 1;
    capturedItemId = itemId;
    final index = captureCount - 1;
    return paths[index < paths.length ? index : paths.length - 1];
  }

  @override
  Future<void> deletePhoto(String path) async {
    deletedPath = path;
  }
}

void main() {
  late FakeCurrentListNotifier notifier;
  late FakePhotoRepository photoRepository;

  setUp(() {
    notifier = FakeCurrentListNotifier(const AsyncValue.data(null));
    photoRepository = FakePhotoRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        currentListProvider.overrideWith((ref) => notifier),
        photoRepositoryProvider.overrideWithValue(photoRepository),
      ],
      child: const MaterialApp(home: ItemFormScreen()),
    );
  }

  Widget createEditWidgetUnderTest(ShoppingItem item) {
    return ProviderScope(
      overrides: [
        currentListProvider.overrideWith((ref) => notifier),
        photoRepositoryProvider.overrideWithValue(photoRepository),
      ],
      child: MaterialApp(home: ItemFormScreen(itemToEdit: item)),
    );
  }

  testWidgets('renders all initial fields with focus on Name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(
      find.byType(DropdownButtonFormField<String>),
      findsOneWidget,
    ); // Type
    expect(
      find.widgetWithText(TextFormField, 'Nome do Produto / Marca'),
      findsOneWidget,
    ); // Name
    expect(find.text('Atacado'), findsOneWidget); // Switch
    expect(find.text('Por peso (KG)'), findsOneWidget); // Switch
    expect(find.widgetWithText(TextFormField, 'Quantidade'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Preço Unitário (R\$)'),
      findsOneWidget,
    );
    expect(find.text('Tirar foto da etiqueta'), findsOneWidget);
    expect(find.text('Adicionar substituto'), findsOneWidget);
    expect(find.text('Salvar'), findsOneWidget);

    // Focus check (the first text field should be focused)
    final FocusScopeNode focusScope = FocusScope.of(
      tester.element(find.byType(ItemFormScreen)),
    );
    expect(focusScope.hasFocus, isTrue); // Something has focus
  });

  testWidgets('captures photo and shows thumbnail', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Tirar foto da etiqueta'));
    await tester.tap(find.text('Tirar foto da etiqueta'));
    await tester.pump();

    expect(photoRepository.captureCount, 1);
    expect(photoRepository.capturedItemId, isNotEmpty);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Remover foto'), findsOneWidget);
  });

  testWidgets('saves photo path and timestamp on new item', (
    WidgetTester tester,
  ) async {
    final beforeCapture = DateTime.now();
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Tirar foto da etiqueta'));
    await tester.tap(find.text('Tirar foto da etiqueta'));
    await tester.pump();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do Produto / Marca'),
      'Arroz',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Preço Unitário (R\$)'),
      '5.50',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Quantidade'),
      '2',
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(notifier.addedItem?.photoUrl, '/tmp/item-photo.jpg');
    expect(notifier.addedItem?.photoCapturedAt, isNotNull);
    expect(notifier.addedItem!.photoCapturedAt!.isAfter(beforeCapture), isTrue);
  });

  testWidgets('removes captured photo before saving', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Tirar foto da etiqueta'));
    await tester.tap(find.text('Tirar foto da etiqueta'));
    await tester.pump();

    await tester.tap(find.text('Remover foto'));
    await tester.pump();

    expect(photoRepository.deletedPath, '/tmp/item-photo.jpg');
    expect(find.byType(Image), findsNothing);
    expect(find.text('Remover foto'), findsNothing);
  });

  testWidgets('retakes photo replacing previous file', (
    WidgetTester tester,
  ) async {
    photoRepository = FakePhotoRepository.withPaths([
      '/tmp/item-photo.jpg',
      '/tmp/item-photo-new.jpg',
    ]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Tirar foto da etiqueta'));
    await tester.tap(find.text('Tirar foto da etiqueta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tirar nova foto'));
    await tester.pumpAndSettle();

    expect(photoRepository.captureCount, 2);
    expect(photoRepository.deletedPath, '/tmp/item-photo.jpg');
  });

  testWidgets('editing item can clear existing photo fields', (
    WidgetTester tester,
  ) async {
    final item = ShoppingItem(
      id: 'item-1',
      productType: 'Mercearia',
      productName: 'Arroz',
      quantity: Quantity(1),
      unitPrice: Money.fromReais(5),
      createdAt: DateTime(2026),
      photoUrl: '/tmp/old-photo.jpg',
      photoCapturedAt: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(createEditWidgetUnderTest(item));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Remover foto'));
    await tester.tap(find.text('Remover foto'));
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(photoRepository.deletedPath, '/tmp/old-photo.jpg');
    expect(notifier.updatedItem?.photoUrl, isNull);
    expect(notifier.updatedItem?.photoCapturedAt, isNull);
  });

  testWidgets('validates empty name field', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Button should be disabled initially
    final saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(saveButton.onPressed, isNull);

    // Enter valid price and quantity but empty name
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Preço Unitário (R\$)'),
      '5.00',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Quantidade'),
      '2',
    );
    await tester.pumpAndSettle();

    final saveButtonAfter = tester.widget<FilledButton>(
      find.byType(FilledButton),
    );
    expect(saveButtonAfter.onPressed, isNull);
  });

  testWidgets('validates negative or zero unit price', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do Produto / Marca'),
      'Arroz',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Preço Unitário (R\$)'),
      '0',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Quantidade'),
      '2',
    );
    await tester.pumpAndSettle();

    final saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(saveButton.onPressed, isNull);
  });

  testWidgets('validates negative or zero quantity', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do Produto / Marca'),
      'Arroz',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Preço Unitário (R\$)'),
      '5.00',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Quantidade'),
      '-1',
    );
    await tester.pumpAndSettle();

    final saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(saveButton.onPressed, isNull);
  });

  testWidgets('enables save button when form is valid', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do Produto / Marca'),
      'Arroz',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Preço Unitário (R\$)'),
      '5.50',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Quantidade'),
      '2',
    );
    await tester.pumpAndSettle();

    final saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(saveButton.onPressed, isNotNull);
  });

  testWidgets('toggle wholesale sets quantity to 3', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Default quantity is usually 1
    final quantityFinder = find.widgetWithText(TextFormField, 'Quantidade');
    expect(
      (tester.widget<TextFormField>(quantityFinder).controller?.text ?? ''),
      '1',
    );

    // Tap on switch
    final switchFinder = find.byWidgetPredicate(
      (widget) =>
          widget is SwitchListTile &&
          widget.title is Text &&
          (widget.title as Text).data == 'Atacado',
    );
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(
      (tester.widget<TextFormField>(quantityFinder).controller?.text ?? ''),
      '3',
    );
  });

  testWidgets('toggle weight hides unit/quantity and shows kg/price_kg', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final switchFinder = find.byWidgetPredicate(
      (widget) =>
          widget is SwitchListTile &&
          widget.title is Text &&
          (widget.title as Text).data == 'Por peso (KG)',
    );
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'Quantidade'), findsNothing);
    expect(
      find.widgetWithText(TextFormField, 'Preço Unitário (R\$)'),
      findsNothing,
    );

    expect(find.widgetWithText(TextFormField, 'Peso (kg)'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Preço por KG (R\$)'),
      findsOneWidget,
    );
  });

  testWidgets('validates weight fields when kg toggle is on', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do Produto / Marca'),
      'Carne',
    );

    final switchFinder = find.byWidgetPredicate(
      (widget) =>
          widget is SwitchListTile &&
          widget.title is Text &&
          (widget.title as Text).data == 'Por peso (KG)',
    );
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Peso (kg)'),
      '0',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Preço por KG (R\$)'),
      '30.00',
    );
    await tester.pumpAndSettle();

    var saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(saveButton.onPressed, isNull);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Peso (kg)'),
      '1.5',
    );
    await tester.pumpAndSettle();

    saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(saveButton.onPressed, isNotNull);
  });

  testWidgets('custom product type opens text field', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(TextFormField, 'Tipo Customizado'),
      findsNothing,
    );

    // Open dropdown
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    // Select Customizar
    await tester.tap(find.text('Customizar').last);
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(TextFormField, 'Tipo Customizado'),
      findsOneWidget,
    );
  });

  testWidgets('submit trims strings and calls provider for retail item', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do Produto / Marca'),
      '  Arroz Branco  ',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Preço Unitário (R\$)'),
      '5.50',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Quantidade'),
      '2',
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(notifier.addedItem, isNotNull);
    expect(notifier.addedItem!.productName, 'Arroz Branco');
    expect(notifier.addedItem!.unitPrice.cents, 550);
    expect(notifier.addedItem!.quantity.value, 2.0);
    expect(notifier.addedItem!.isWeightBased, isFalse);
    expect(notifier.addedItem!.isWholesale, isFalse);
  });

  testWidgets('toggle substitute shows substitute fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Adicionar substituto'));
    await tester.tap(find.text('Adicionar substituto'));
    await tester.pumpAndSettle();

    expect(find.text('Dados do substituto'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Nome do substituto'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextFormField, 'Quantidade do substituto'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextFormField, 'Preço do substituto (R\$)'),
      findsOneWidget,
    );
  });

  testWidgets('submit creates principal and linked substitute', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do Produto / Marca'),
      'Arroz',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Preço Unitário (R\$)'),
      '5.50',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Quantidade'),
      '2',
    );

    await tester.ensureVisible(find.text('Adicionar substituto'));
    await tester.tap(find.text('Adicionar substituto'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do substituto'),
      'Feijão',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Quantidade do substituto'),
      '1',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Preço do substituto (R\$)'),
      '6.25',
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(notifier.addedItem, isNull);
    expect(notifier.addedMainItem, isNotNull);
    expect(notifier.addedSubstituteItem, isNotNull);
    expect(notifier.addedMainItem!.productName, 'Arroz');
    expect(notifier.addedSubstituteItem!.productName, 'Feijão');
    expect(
      notifier.addedMainItem!.substituteItemId,
      notifier.addedSubstituteItem!.id,
    );
  });

  testWidgets('submit uses custom product type and trims it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Customizar').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tipo Customizado'),
      '  Eletrônicos  ',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do Produto / Marca'),
      'Pilha',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Preço Unitário (R\$)'),
      '10.0',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Quantidade'),
      '1',
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(notifier.addedItem, isNotNull);
    expect(notifier.addedItem!.productType, 'Eletrônicos');
  });

  testWidgets('submit calls provider for weight-based item', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do Produto / Marca'),
      'Picanha',
    );

    final switchFinder = find.byWidgetPredicate(
      (widget) =>
          widget is SwitchListTile &&
          widget.title is Text &&
          (widget.title as Text).data == 'Por peso (KG)',
    );
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Peso (kg)'),
      '1.5',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Preço por KG (R\$)'),
      '60.00',
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(notifier.addedItem, isNotNull);
    expect(notifier.addedItem!.productName, 'Picanha');
    expect(notifier.addedItem!.isWeightBased, isTrue);
    expect(notifier.addedItem!.weightKg!.value, 1.5);
    expect(notifier.addedItem!.pricePerKg!.cents, 6000);
    // Unit price and quantity should have fallback values for database compatibility, e.g. price=60, qty=1.5
    expect(notifier.addedItem!.unitPrice.cents, 6000);
    expect(notifier.addedItem!.quantity.value, 1.5);
  });

  testWidgets('keyboard types are numeric for numbers', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final priceField = tester.widget<TextField>(
      find.descendant(
        of: find.widgetWithText(TextFormField, 'Preço Unitário (R\$)'),
        matching: find.byType(TextField),
      ),
    );
    expect(
      priceField.keyboardType,
      const TextInputType.numberWithOptions(decimal: true),
    );

    final qtyField = tester.widget<TextField>(
      find.descendant(
        of: find.widgetWithText(TextFormField, 'Quantidade'),
        matching: find.byType(TextField),
      ),
    );
    expect(
      qtyField.keyboardType,
      const TextInputType.numberWithOptions(decimal: true),
    );
  });
}
