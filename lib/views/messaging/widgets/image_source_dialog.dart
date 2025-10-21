import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom sheet dialog for selecting image source (camera or gallery)
class ImageSourceDialog extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const ImageSourceDialog({
    super.key,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () {
              context.pop();
              onGallery();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a photo'),
            onTap: () {
              context.pop();
              onCamera();
            },
          ),
        ],
      ),
    );
  }

  /// Show the image source dialog
  static void show(
    BuildContext context, {
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ImageSourceDialog(
        onCamera: onCamera,
        onGallery: onGallery,
      ),
    );
  }
}
