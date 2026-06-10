import 'package:flutter/material.dart';

/// Web stub: local filesystem photos don't exist on the web build.
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
    return Container(
      height: height,
      width: width,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported),
    );
  }
}
