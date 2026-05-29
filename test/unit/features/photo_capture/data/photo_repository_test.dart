import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:listai/features/photo_capture/data/photo_repository.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('listai_photo_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Future<XFile> createSourcePhoto(List<int> bytes) async {
    final source = File('${tempDir.path}/source.jpg');
    await source.writeAsBytes(bytes);
    return XFile(source.path);
  }

  test('captures photo with camera compression parameters', () async {
    double? capturedMaxWidth;
    double? capturedMaxHeight;
    int? capturedImageQuality;

    final repository = LocalPhotoRepository(
      appDirectoryProvider: () async => tempDir,
      picker: ({required source, maxWidth, maxHeight, imageQuality}) async {
        capturedMaxWidth = maxWidth;
        capturedMaxHeight = maxHeight;
        capturedImageQuality = imageQuality;
        return createSourcePhoto(List.filled(1024, 1));
      },
    );

    await repository.capturePhoto(itemId: 'item-1');

    expect(capturedMaxWidth, 1024);
    expect(capturedMaxHeight, 1024);
    expect(capturedImageQuality, 80);
  });

  test('saves captured photo inside app directory', () async {
    final repository = LocalPhotoRepository(
      appDirectoryProvider: () async => tempDir,
      picker: ({required source, maxWidth, maxHeight, imageQuality}) {
        return createSourcePhoto([1, 2, 3]);
      },
    );

    final path = await repository.capturePhoto(itemId: 'item-1');

    expect(path, startsWith('${tempDir.path}/item_photos/'));
    expect(await File(path).readAsBytes(), [1, 2, 3]);
  });

  test('returns empty string when camera is cancelled', () async {
    final repository = LocalPhotoRepository(
      appDirectoryProvider: () async => tempDir,
      picker: ({required source, maxWidth, maxHeight, imageQuality}) async =>
          null,
    );

    final path = await repository.capturePhoto(itemId: 'item-1');

    expect(path, isEmpty);
  });

  test('rejects final photos larger than five megabytes', () async {
    final repository = LocalPhotoRepository(
      appDirectoryProvider: () async => tempDir,
      picker: ({required source, maxWidth, maxHeight, imageQuality}) {
        return createSourcePhoto(List.filled(5 * 1024 * 1024 + 1, 1));
      },
    );

    expect(
      () => repository.capturePhoto(itemId: 'item-1'),
      throwsA(isA<PhotoTooLargeException>()),
    );
  });

  test('deletePhoto removes an existing file', () async {
    final file = File('${tempDir.path}/photo.jpg');
    await file.writeAsBytes([1, 2, 3]);

    final repository = LocalPhotoRepository(
      appDirectoryProvider: () async => tempDir,
      picker: ({required source, maxWidth, maxHeight, imageQuality}) async =>
          null,
    );

    await repository.deletePhoto(file.path);

    expect(await file.exists(), isFalse);
  });
}
