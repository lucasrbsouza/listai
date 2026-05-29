import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../shopping_list/domain/entities/shopping_list.dart';
import 'export_service.dart';

class PdfFormatter implements ExportFormatter {
  @override
  ExportFormat get format => ExportFormat.pdf;

  @override
  Future<File> export(ShoppingList list) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header / Capa
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        list.name,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (list.marketName != null &&
                          list.marketName!.isNotEmpty)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 4),
                          child: pw.Text(
                            'Mercado: ${list.marketName}',
                            style: const pw.TextStyle(fontSize: 14),
                          ),
                        ),
                    ],
                  ),
                  pw.Text(
                    'Data: ${_formatDate(list.createdAt)}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Tabela de itens
            pw.TableHelper.fromTextArray(
              headers: ['Tipo', 'Nome', 'Qtd', 'Preço Unit', 'Total'],
              data: list.items.map((item) {
                final nameStr = item.brand != null
                    ? '${item.productName} (${item.brand})'
                    : item.productName;
                final qtyStr = item.isWeightBased
                    ? '${item.weightKg!.value} kg'
                    : '${item.quantity.value}';
                final pUnitStr = item.isWeightBased
                    ? 'R\$ ${item.pricePerKg!.reais.toStringAsFixed(2).replaceAll('.', ',')}/kg'
                    : 'R\$ ${item.unitPrice.reais.toStringAsFixed(2).replaceAll('.', ',')}';
                final totalStr =
                    'R\$ ${item.totalPrice.reais.toStringAsFixed(2).replaceAll('.', ',')}';

                return [item.productType, nameStr, qtyStr, pUnitStr, totalStr];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
            ),
            pw.SizedBox(height: 20),

            // Rodapé / Totais
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL GERAL:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                pw.Text(
                  'R\$ ${list.totalPrice.reais.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (list.budgetGoal != null) ...[
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Meta de Orçamento:',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    'R\$ ${list.budgetGoal!.reais.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    list.exceedsBudget ? 'Excesso:' : 'Status:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: list.exceedsBudget
                          ? PdfColors.red
                          : PdfColors.green,
                      fontSize: 12,
                    ),
                  ),
                  pw.Text(
                    list.exceedsBudget
                        ? 'R\$ ${list.amountOverBudget.reais.toStringAsFixed(2).replaceAll('.', ',')}'
                        : 'Dentro do Orçamento',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: list.exceedsBudget
                          ? PdfColors.red
                          : PdfColors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ];
        },
      ),
    );

    final tempDir = Directory.systemTemp;
    final file = File(
      '${tempDir.path}/export_${list.id}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
