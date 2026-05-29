import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:listai/core/utils/money.dart';
import 'package:listai/core/utils/quantity.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/share_export/domain/export_service.dart';
import 'package:listai/features/share_export/domain/pdf_formatter.dart';
import 'package:listai/features/share_export/domain/txt_formatter.dart';

void main() {
  late ShoppingList testList;

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

    testList = ShoppingList(
      id: 'list-123',
      name: 'Lista de Compras Semanal',
      marketName: 'Supermercado Nova Era',
      budgetGoal: Money.fromCents(5000), // R$ 50.00
      items: [item1, item2],
      createdAt: DateTime(2026, 5, 29),
      updatedAt: DateTime(2026, 5, 29),
    );
  });

  group('TxtFormatter', () {
    test('generates valid txt format and content', () async {
      final formatter = TxtFormatter();
      expect(formatter.format, equals(ExportFormat.txt));

      final file = await formatter.export(testList);
      expect(file.path.endsWith('.txt'), isTrue);

      final contents = await file.readAsString();
      expect(contents, contains('Lista de Compras Semanal'));
      expect(contents, contains('Supermercado Nova Era'));
      expect(contents, contains('Arroz integral'));
      expect(contents, contains('Suco de Maçã'));
      expect(contents, contains('Marca A'));
      expect(contents, contains('5,50'));
      expect(contents, contains('8,00'));
      expect(contents, contains('TOTAL GERAL: R\$ 35,00'));
      expect(contents, contains('META DE ORÇAMENTO: R\$ 50,00'));

      // Clean up
      if (await file.exists()) {
        await file.delete();
      }
    });
  });

  group('PdfFormatter', () {
    test('generates valid pdf file', () async {
      final formatter = PdfFormatter();
      expect(formatter.format, equals(ExportFormat.pdf));

      final file = await formatter.export(testList);
      expect(file.path.endsWith('.pdf'), isTrue);

      final bytes = await file.readAsBytes();
      expect(bytes.length, greaterThan(0));

      // PDF files always start with '%PDF' signature in ASCII bytes: 0x25, 0x50, 0x44, 0x46
      expect(bytes[0], equals(0x25)); // %
      expect(bytes[1], equals(0x50)); // P
      expect(bytes[2], equals(0x44)); // D
      expect(bytes[3], equals(0x46)); // F

      // Clean up
      if (await file.exists()) {
        await file.delete();
      }
    });
  });
}
