import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Web stub: photo capture is disabled on the web build (no filesystem).
/// Mirrors the public API of `photo_repository_io.dart`.
abstract class PhotoRepository {
  Future<String> capturePhoto({required String itemId});

  Future<void> deletePhoto(String path);
}

class PhotoTooLargeException implements Exception {
  const PhotoTooLargeException(this.sizeBytes);

  final int sizeBytes;

  @override
  String toString() => 'PhotoTooLargeException: $sizeBytes bytes';
}

class UnsupportedPhotoRepository implements PhotoRepository {
  @override
  Future<String> capturePhoto({required String itemId}) async => '';

  @override
  Future<void> deletePhoto(String path) async {}
}

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return UnsupportedPhotoRepository();
});
