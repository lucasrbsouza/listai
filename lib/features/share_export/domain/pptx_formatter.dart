import 'dart:io';
import 'package:archive/archive.dart';
import '../../shopping_list/domain/entities/shopping_list.dart';
import '../../shopping_list/domain/entities/shopping_item.dart';
import 'export_service.dart';

class PptxFormatter implements ExportFormatter {
  @override
  ExportFormat get format => ExportFormat.pptx;

  @override
  Future<File> export(ShoppingList list) async {
    // 1. Chunk items into groups of 10
    final chunks = <List<ShoppingItem>>[];
    for (var i = 0; i < list.items.length; i += 10) {
      final end = (i + 10 < list.items.length) ? i + 10 : list.items.length;
      chunks.add(list.items.sublist(i, end));
    }

    final totalSlides = 1 + chunks.length; // 1 capa + N content slides

    final outputArchive = Archive();

    // 2. [Content_Types].xml
    final contentTypesSb = StringBuffer();
    contentTypesSb.writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    contentTypesSb.writeln('<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">');
    contentTypesSb.writeln('  <Default Extension="xml" ContentType="application/xml"/>');
    contentTypesSb.writeln('  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>');
    contentTypesSb.writeln('  <Override PartName="/ppt/presentation.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"/>');
    for (var i = 1; i <= totalSlides; i++) {
      contentTypesSb.writeln('  <Override PartName="/ppt/slides/slide$i.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.slide+xml"/>');
    }
    contentTypesSb.writeln('</Types>');
    final contentTypesStr = contentTypesSb.toString();
    outputArchive.addFile(ArchiveFile('[Content_Types].xml', contentTypesStr.codeUnits.length, contentTypesStr.codeUnits));

    // 3. _rels/.rels
    const relsStr = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\n'
        '  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="ppt/presentation.xml"/>\n'
        '</Relationships>';
    outputArchive.addFile(ArchiveFile('_rels/.rels', relsStr.codeUnits.length, relsStr.codeUnits));

    // 4. ppt/presentation.xml
    final presentationSb = StringBuffer();
    presentationSb.writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    presentationSb.writeln('<p:presentation xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">');
    presentationSb.writeln('  <p:sldIdLst>');
    for (var i = 1; i <= totalSlides; i++) {
      presentationSb.writeln('    <p:sldId id="${255 + i}" r:id="rId$i"/>');
    }
    presentationSb.writeln('  </p:sldIdLst>');
    presentationSb.writeln('</p:presentation>');
    final presentationStr = presentationSb.toString();
    outputArchive.addFile(ArchiveFile('ppt/presentation.xml', presentationStr.codeUnits.length, presentationStr.codeUnits));

    // 5. ppt/_rels/presentation.xml.rels
    final presentationRelsSb = StringBuffer();
    presentationRelsSb.writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    presentationRelsSb.writeln('<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">');
    for (var i = 1; i <= totalSlides; i++) {
      presentationRelsSb.writeln('  <Relationship Id="rId$i" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide" Target="slides/slide$i.xml"/>');
    }
    presentationRelsSb.writeln('</Relationships>');
    final presentationRelsStr = presentationRelsSb.toString();
    outputArchive.addFile(ArchiveFile('ppt/_rels/presentation.xml.rels', presentationRelsStr.codeUnits.length, presentationRelsStr.codeUnits));

    // 6. ppt/slides/slide1.xml (Capa)
    final marketStr = list.marketName != null && list.marketName!.isNotEmpty ? 'Mercado: ${list.marketName}' : '';
    final dateStr = '${list.createdAt.day.toString().padLeft(2, '0')}/${list.createdAt.month.toString().padLeft(2, '0')}/${list.createdAt.year}';
    final capaContent = 'LISTA: ${list.name}\\n$marketStr\\nData: $dateStr\\nTotal: R\$ ${list.totalPrice.reais.toStringAsFixed(2).replaceAll('.', ',')}';
    final slide1Xml = _buildSlideXml(capaContent);
    outputArchive.addFile(ArchiveFile('ppt/slides/slide1.xml', slide1Xml.codeUnits.length, slide1Xml.codeUnits));

    // 7. ppt/slides/slide2.xml, slide3.xml, etc. (Content slides)
    for (var i = 0; i < chunks.length; i++) {
      final chunk = chunks[i];
      final chunkSb = StringBuffer();
      chunkSb.writeln('ITENS (Parte ${i + 1} de ${chunks.length}):');
      for (final item in chunk) {
        final nameStr = item.brand != null ? '${item.productName} (${item.brand})' : item.productName;
        final qtyStr = item.isWeightBased ? '${item.weightKg!.value} kg' : '${item.quantity.value}';
        final totalStr = 'R\$ ${item.totalPrice.reais.toStringAsFixed(2).replaceAll('.', ',')}';
        chunkSb.writeln('- $nameStr | Qtd: $qtyStr | Total: $totalStr');
      }
      final slideXml = _buildSlideXml(chunkSb.toString());
      outputArchive.addFile(ArchiveFile('ppt/slides/slide${i + 2}.xml', slideXml.codeUnits.length, slideXml.codeUnits));
    }

    final encoded = ZipEncoder().encode(outputArchive);
    if (encoded == null) {
      throw StateError('Could not encode output PPTX zip');
    }

    final tempDir = Directory.systemTemp;
    final outputFile = File('${tempDir.path}/export_${list.id}_${DateTime.now().millisecondsSinceEpoch}.pptx');
    await outputFile.writeAsBytes(encoded);
    return outputFile;
  }

  String _buildSlideXml(String content) {
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<p:sld xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">\n'
        '  <p:cSld>\n'
        '    <p:spTree>\n'
        '      <p:sp>\n'
        '        <p:txBody>\n'
        '          <p:p>\n'
        '            <p:r>\n'
        '              <p:t>$content</p:t>\n'
        '            </p:r>\n'
        '          </p:p>\n'
        '        </p:txBody>\n'
        '      </p:sp>\n'
        '    </p:spTree>\n'
        '  </p:cSld>\n'
        '</p:sld>';
  }
}
