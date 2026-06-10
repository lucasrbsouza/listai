import 'dart:io';
import '../../shopping_list/domain/entities/shopping_list.dart';
import 'export_format.dart';

export 'export_format.dart';

abstract class ExportFormatter {
  ExportFormat get format;
  Future<File> export(ShoppingList list);
}

class ExportService {
  final List<ExportFormatter> formatters;
  final Future<void> Function(String filePath) shareFile;

  ExportService({required this.formatters, required this.shareFile});

  Future<void> exportAndShare(ShoppingList list, ExportFormat format) async {
    final formatter = formatters.firstWhere(
      (f) => f.format == format,
      orElse: () => throw ArgumentError('Formatter not found for $format'),
    );
    final file = await formatter.export(list);
    await shareFile(file.path);
  }
}
