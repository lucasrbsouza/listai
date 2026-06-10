import 'dart:io';
import 'package:intl/intl.dart';
import '../../shopping_list/domain/entities/shopping_list.dart';
import 'export_service.dart';

class TxtFormatter implements ExportFormatter {
  @override
  ExportFormat get format => ExportFormat.txt;

  @override
  Future<File> export(ShoppingList list) async {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final formattedDate = dateFormat.format(list.createdAt);

    final sb = StringBuffer();
    sb.writeln('==================================================');
    sb.writeln('LISTA: ${list.name}');
    if (list.marketName != null && list.marketName!.isNotEmpty) {
      sb.writeln('MERCADO: ${list.marketName}');
    }
    sb.writeln('DATA: $formattedDate');
    sb.writeln('==================================================');
    sb.writeln();

    // Table Header
    sb.writeln(
      '${_pad('TIPO', 12)} | ${_pad('NOME', 25)} | ${_pad('QTD', 6)} | ${_pad('P. UNIT', 10)} | TOTAL',
    );
    sb.writeln(
      '--------------------------------------------------------------------------------',
    );

    for (final item in list.items) {
      final tipo = item.productType;
      final nome = item.brand != null
          ? '${item.productName} (${item.brand})'
          : item.productName;
      final qtd = item.isWeightBased
          ? '${item.weightKg!.value} kg'
          : '${item.quantity.value}';
      final pUnit = item.isWeightBased
          ? (item.pricePerKg != null
                ? 'R\$ ${item.pricePerKg!.reais.toStringAsFixed(2).replaceAll('.', ',')}/kg'
                : 'sem preço')
          : (item.unitPrice != null
                ? 'R\$ ${item.unitPrice!.reais.toStringAsFixed(2).replaceAll('.', ',')}'
                : 'sem preço');
      final total = item.hasPrice
          ? 'R\$ ${item.totalPrice.reais.toStringAsFixed(2).replaceAll('.', ',')}'
          : 'sem preço';

      sb.writeln(
        '${_pad(tipo, 12)} | ${_pad(nome, 25)} | ${_pad(qtd, 6)} | ${_pad(pUnit, 10)} | $total',
      );
    }

    sb.writeln(
      '--------------------------------------------------------------------------------',
    );
    sb.writeln(
      'TOTAL GERAL: R\$ ${list.totalPrice.reais.toStringAsFixed(2).replaceAll('.', ',')}',
    );
    if (list.budgetGoal != null) {
      sb.writeln(
        'META DE ORÇAMENTO: R\$ ${list.budgetGoal!.reais.toStringAsFixed(2).replaceAll('.', ',')}',
      );
      if (list.exceedsBudget) {
        sb.writeln(
          'EXCESSO: R\$ ${list.amountOverBudget.reais.toStringAsFixed(2).replaceAll('.', ',')}',
        );
      } else {
        sb.writeln('DENTRO DO ORÇAMENTO');
      }
    }
    sb.writeln('==================================================');

    final tempDir = Directory.systemTemp;
    final file = File(
      '${tempDir.path}/export_${list.id}_${DateTime.now().millisecondsSinceEpoch}.txt',
    );
    await file.writeAsString(sb.toString());
    return file;
  }

  String _pad(String text, int length) {
    if (text.length > length) {
      return text.substring(0, length - 3) + '...';
    }
    return text.padRight(length);
  }
}
