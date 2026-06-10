import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:listai/shared/widgets/local_photo_image.dart';

class PhotoViewerArgs {
  const PhotoViewerArgs({required this.photoPath, this.capturedAt});

  final String photoPath;
  final DateTime? capturedAt;
}

class PhotoViewerScreen extends StatelessWidget {
  const PhotoViewerScreen({
    super.key,
    required this.photoPath,
    this.capturedAt,
  });

  final String photoPath;
  final DateTime? capturedAt;

  @override
  Widget build(BuildContext context) {
    final formattedDate = capturedAt == null
        ? 'Data da foto indisponível'
        : DateFormat('dd/MM/yyyy HH:mm').format(capturedAt!);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            child: Center(
              child: LocalPhotoImage(path: photoPath, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        formattedDate,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Fechar',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
