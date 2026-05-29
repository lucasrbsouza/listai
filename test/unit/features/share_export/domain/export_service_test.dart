import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:listai/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:listai/features/share_export/domain/export_service.dart';

class FakeExportFormatter implements ExportFormatter {
  @override
  final ExportFormat format;
  final Future<File> Function(ShoppingList list) onExport;

  FakeExportFormatter(this.format, this.onExport);

  @override
  Future<File> export(ShoppingList list) => onExport(list);
}

class FakeFile extends Fake implements File {
  @override
  final String path;
  FakeFile(this.path);
}

void main() {
  late FakeExportFormatter fakePdfFormatter;
  late FakeExportFormatter fakeTxtFormatter;
  late ExportService exportService;
  late ShoppingList testList;
  late List<String> sharedFilePaths;
  late List<ShoppingList> pdfExportedLists;
  late List<ShoppingList> txtExportedLists;

  setUp(() {
    pdfExportedLists = [];
    txtExportedLists = [];

    fakePdfFormatter = FakeExportFormatter(
      ExportFormat.pdf,
      (list) async {
        pdfExportedLists.add(list);
        return FakeFile('/path/to/test.pdf');
      },
    );

    fakeTxtFormatter = FakeExportFormatter(
      ExportFormat.txt,
      (list) async {
        txtExportedLists.add(list);
        return FakeFile('/path/to/test.txt');
      },
    );

    sharedFilePaths = [];
    exportService = ExportService(
      formatters: [fakePdfFormatter, fakeTxtFormatter],
      shareFile: (path) async {
        sharedFilePaths.add(path);
      },
    );

    testList = ShoppingList(
      id: 'test-id',
      name: 'Lista de Teste',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  });

  test('delegates to correct formatter and shares the file path', () async {
    await exportService.exportAndShare(testList, ExportFormat.pdf);

    expect(pdfExportedLists.length, equals(1));
    expect(pdfExportedLists.first, equals(testList));
    expect(txtExportedLists, isEmpty);
    expect(sharedFilePaths, equals(['/path/to/test.pdf']));
  });

  test('throws ArgumentError if no formatter found for format', () async {
    expect(
      () => exportService.exportAndShare(testList, ExportFormat.docx),
      throwsArgumentError,
    );
  });
}
