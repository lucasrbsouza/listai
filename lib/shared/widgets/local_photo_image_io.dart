import 'dart:io';

import 'package:flutter/material.dart';

/// Renders a photo stored on the local filesystem.
class LocalPhotoImage extends StatelessWidget {
  const LocalPhotoImage({
    super.key,
    required this.path,
    this.height,
    this.width,
    this.fit,
  });

  final String path;
  final double? height;
  final double? width;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: width,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported),
        );
      },
    );
  }
}
