import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_picker_service.g.dart';

@Riverpod(keepAlive: true)
ImagePickerService imagePickerService(Ref ref) {
  return ImagePickerService._();
}

class ImagePickerService {
  ImagePickerService._();

  static final ImagePicker _picker = ImagePicker();

  /// Show bottom sheet to select image from camera or gallery
  Future<File?> pickImage({
    required ImageSource source,
    int imageQuality = 85,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Pick profile photo with optimized dimensions
  Future<File?> pickProfilePhoto(ImageSource source) async {
    return pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 90,
    );
  }

  /// Pick cover photo with optimized dimensions
  Future<File?> pickCoverPhoto(ImageSource source) async {
    return pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 600,
      imageQuality: 85,
    );
  }
}
