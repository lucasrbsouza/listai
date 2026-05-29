import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/export_service.dart';
import '../../domain/pdf_formatter.dart';
import '../../domain/txt_formatter.dart';
import '../../domain/docx_formatter.dart';
import '../../domain/pptx_formatter.dart';

final exportFormattersProvider = Provider<List<ExportFormatter>>((ref) {
  return [
    PdfFormatter(),
    TxtFormatter(),
    DocxFormatter(),
    PptxFormatter(),
  ];
});

final exportServiceProvider = Provider<ExportService>((ref) {
  final formatters = ref.watch(exportFormattersProvider);
  return ExportService(
    formatters: formatters,
    shareFile: (filePath) async {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Minha Lista de Compras',
      );
    },
  );
});
