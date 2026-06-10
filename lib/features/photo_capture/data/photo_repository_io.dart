import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract class PhotoRepository {
  Future<String> capturePhoto({required String itemId});

  Future<void> deletePhoto(String path);
}

typedef PickImage =
    Future<XFile?> Function({
      required ImageSource source,
      double? maxWidth,
      double? maxHeight,
      int? imageQuality,
    });

typedef AppDirectoryProvider = Future<Directory> Function();

class PhotoTooLargeException implements Exception {
  const PhotoTooLargeException(this.sizeBytes);

  final int sizeBytes;

  @override
  String toString() => 'PhotoTooLargeException: $sizeBytes bytes';
}

class LocalPhotoRepository implements PhotoRepository {
  LocalPhotoRepository({
    PickImage? picker,
    AppDirectoryProvider? appDirectoryProvider,
  }) : _picker = picker ?? ImagePicker().pickImage,
       _appDirectoryProvider =
           appDirectoryProvider ?? getApplicationDocumentsDirectory;

  static const int maxPhotoBytes = 5 * 1024 * 1024;

  final PickImage _picker;
  final AppDirectoryProvider _appDirectoryProvider;

  @override
  Future<String> capturePhoto({required String itemId}) async {
    final pickedFile = await _picker(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFile == null) return '';

    final appDirectory = await _appDirectoryProvider();
    final photoDirectory = Directory(p.join(appDirectory.path, 'item_photos'));
    if (!await photoDirectory.exists()) {
      await photoDirectory.create(recursive: true);
    }

    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final safeItemId = itemId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final destination = File(
      p.join(photoDirectory.path, '${safeItemId}_$timestamp.jpg'),
    );

    await File(pickedFile.path).copy(destination.path);

    final size = await destination.length();
    if (size > maxPhotoBytes) {
      await destination.delete();
      throw PhotoTooLargeException(size);
    }

    return destination.path;
  }

  @override
  Future<void> deletePhoto(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return LocalPhotoRepository();
});
