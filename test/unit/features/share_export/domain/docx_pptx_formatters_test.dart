import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/share_export/domain/export_service.dart';
import 'package:listai/features/share_export/domain/docx_formatter.dart';
import 'package:listai/features/share_export/domain/pptx_formatter.dart';

void main() {
  late ShoppingList smallList;
  late ShoppingList largeList;

  setUp(() {
    final item1 = ShoppingItem(
      id: 'item-1',
      productType: 'Alimento',
      productName: 'Arroz integral',
      brand: 'Marca A',
      quantity: Quantity(2.0),
      unitPrice: Money.fromCents(550), // R$ 5.50
      createdAt: DateTime(2026, 1, 1),
    );

    final item2 = ShoppingItem(
      id: 'item-2',
      productType: 'Bebida',
      productName: 'Suco de Maçã',
      quantity: Quantity(3.0),
      unitPrice: Money.fromCents(800), // R$ 8.00
      createdAt: DateTime(2026, 1, 1),
    );

    smallList = ShoppingList(
      id: 'list-small',
      name: 'Lista Pequena',
      marketName: 'Super Nova Era',
      budgetGoal: Money.fromCents(5000), // R$ 50.00
      items: [item1, item2],
      createdAt: DateTime(2026, 5, 29),
      updatedAt: DateTime(2026, 5, 29),
    );

    // Create 15 items for the pagination test (should generate 1 capa + 2 slides = 3 slides total)
    final largeListItems = List.generate(15, (index) {
      return ShoppingItem(
        id: 'item-$index',
        productType: 'Tipo $index',
        productName: 'Produto $index',
        quantity: Quantity(1.0),
        unitPrice: Money.fromCents(100), // R$ 1.00
        createdAt: DateTime(2026, 1, 1),
      );
    });

    largeList = ShoppingList(
      id: 'list-large',
      name: 'Lista Grande',
      marketName: 'Atacadão Grande',
      items: largeListItems,
      createdAt: DateTime(2026, 5, 29),
      updatedAt: DateTime(2026, 5, 29),
    );
  });

  group('DocxFormatter', () {
    test('generates valid docx file and replaces placeholders', () async {
      final formatter = DocxFormatter();
      expect(formatter.format, equals(ExportFormat.docx));

      final file = await formatter.export(smallList);
      expect(file.path.endsWith('.docx'), isTrue);

      final bytes = await file.readAsBytes();
      expect(bytes.length, greaterThan(0));

      // ZIP / DOCX magic signature: 'PK\x03\x04' -> 0x50, 0x4B, 0x03, 0x04
      expect(bytes[0], equals(0x50));
      expect(bytes[1], equals(0x4B));
      expect(bytes[2], equals(0x03));
      expect(bytes[3], equals(0x04));

      // Decode and check document.xml content
      final archive = ZipDecoder().decodeBytes(bytes);
      expect(archive, isNotNull);

      final docXmlFile = archive!.findFile('word/document.xml');
      expect(docXmlFile, isNotNull);

      final content = String.fromCharCodes(docXmlFile!.content as List<int>);
      expect(content, contains('Lista Pequena'));
      expect(content, contains('Arroz integral'));
      expect(content, contains('Suco de Maçã'));
      expect(content, contains('35,00'));

      // Clean up
      if (await file.exists()) {
        await file.delete();
      }
    });
  });

  group('PptxFormatter', () {
    test('generates valid pptx and pages slides correctly (10 items per slide)', () async {
      final formatter = PptxFormatter();
      expect(formatter.format, equals(ExportFormat.pptx));

      // Test with small list (2 items -> 1 capa + 1 content slide = 2 slides total)
      final fileSmall = await formatter.export(smallList);
      expect(fileSmall.path.endsWith('.pptx'), isTrue);

      final bytesSmall = await fileSmall.readAsBytes();
      final archiveSmall = ZipDecoder().decodeBytes(bytesSmall);
      expect(archiveSmall, isNotNull);

      // Verify slides exist
      expect(archiveSmall!.findFile('ppt/slides/slide1.xml'), isNotNull);
      expect(archiveSmall.findFile('ppt/slides/slide2.xml'), isNotNull);
      expect(archiveSmall.findFile('ppt/slides/slide3.xml'), isNull); // Only 2 slides

      final capaContent = String.fromCharCodes(archiveSmall.findFile('ppt/slides/slide1.xml')!.content as List<int>);
      expect(capaContent, contains('Lista Pequena'));
      expect(capaContent, contains('Super Nova Era'));
      expect(capaContent, contains('35,00'));

      final slide2Content = String.fromCharCodes(archiveSmall.findFile('ppt/slides/slide2.xml')!.content as List<int>);
      expect(slide2Content, contains('Arroz integral'));
      expect(slide2Content, contains('Suco de Maçã'));

      // Test with large list (15 items -> 1 capa + 2 content slides = 3 slides total)
      final fileLarge = await formatter.export(largeList);
      final bytesLarge = await fileLarge.readAsBytes();
      final archiveLarge = ZipDecoder().decodeBytes(bytesLarge);
      expect(archiveLarge, isNotNull);

      expect(archiveLarge!.findFile('ppt/slides/slide1.xml'), isNotNull);
      expect(archiveLarge.findFile('ppt/slides/slide2.xml'), isNotNull);
      expect(archiveLarge.findFile('ppt/slides/slide3.xml'), isNotNull);
      expect(archiveLarge.findFile('ppt/slides/slide4.xml'), isNull); // Exactly 3 slides

      final slide2LargeContent = String.fromCharCodes(archiveLarge.findFile('ppt/slides/slide2.xml')!.content as List<int>);
      expect(slide2LargeContent, contains('Produto 0'));
      expect(slide2LargeContent, contains('Produto 9'));
      expect(slide2LargeContent, isNot(contains('Produto 10')));

      final slide3LargeContent = String.fromCharCodes(archiveLarge.findFile('ppt/slides/slide3.xml')!.content as List<int>);
      expect(slide3LargeContent, contains('Produto 10'));
      expect(slide3LargeContent, contains('Produto 14'));
      expect(slide3LargeContent, isNot(contains('Produto 9')));

      // Clean up
      if (await fileSmall.exists()) {
        await fileSmall.delete();
      }
      if (await fileLarge.exists()) {
        await fileLarge.delete();
      }
    });
  });
}
