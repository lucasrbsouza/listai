import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../shopping_list/domain/entities/shopping_list.dart';
import 'export_service.dart';

class DocxFormatter implements ExportFormatter {
  @override
  ExportFormat get format => ExportFormat.docx;

  @override
  Future<File> export(ShoppingList list) async {
    List<int> bytes;
    try {
      final file = File('assets/templates/list_template.docx');
      if (file.existsSync()) {
        bytes = file.readAsBytesSync();
      } else {
        final data = await rootBundle.load(
          'assets/templates/list_template.docx',
        );
        bytes = data.buffer.asUint8List();
      }
    } catch (_) {
      final data = await rootBundle.load('assets/templates/list_template.docx');
      bytes = data.buffer.asUint8List();
    }

    final archive = ZipDecoder().decodeBytes(bytes);
    if (archive == null) {
      throw StateError('Invalid DOCX template zip archive');
    }

    // Format items table and total
    final tableSb = StringBuffer();
    for (final item in list.items) {
      final nameStr = item.brand != null
          ? '${item.productName} (${item.brand})'
          : item.productName;
      final qtyStr = item.isWeightBased
          ? '${item.weightKg!.value} kg'
          : '${item.quantity.value}';
      final pUnitStr = item.isWeightBased
          ? (item.pricePerKg != null
                ? 'R\$ ${item.pricePerKg!.reais.toStringAsFixed(2).replaceAll('.', ',')}/kg'
                : 'sem preço')
          : (item.unitPrice != null
                ? 'R\$ ${item.unitPrice!.reais.toStringAsFixed(2).replaceAll('.', ',')}'
                : 'sem preço');
      final totalStr = item.hasPrice
          ? 'R\$ ${item.totalPrice.reais.toStringAsFixed(2).replaceAll('.', ',')}'
          : 'sem preço';
      tableSb.writeln(
        '${item.productType} | $nameStr | $qtyStr | $pUnitStr | $totalStr',
      );
    }

    final itemsTableString = tableSb.toString();
    final totalString =
        'R\$ ${list.totalPrice.reais.toStringAsFixed(2).replaceAll('.', ',')}';

    final outputArchive = Archive();

    for (final file in archive.files) {
      if (file.name == 'word/document.xml') {
        final content = String.fromCharCodes(file.content as List<int>);
        final replaced = content
            .replaceAll('{{list_name}}', list.name)
            .replaceAll('{{items_table}}', itemsTableString)
            .replaceAll('{{total}}', totalString);

        outputArchive.addFile(
          ArchiveFile(file.name, replaced.codeUnits.length, replaced.codeUnits),
        );
      } else {
        outputArchive.addFile(file);
      }
    }

    final encoded = ZipEncoder().encode(outputArchive);
    if (encoded == null) {
      throw StateError('Could not encode output DOCX zip');
    }

    final tempDir = Directory.systemTemp;
    final outputFile = File(
      '${tempDir.path}/export_${list.id}_${DateTime.now().millisecondsSinceEpoch}.docx',
    );
    await outputFile.writeAsBytes(encoded);
    return outputFile;
  }
}
