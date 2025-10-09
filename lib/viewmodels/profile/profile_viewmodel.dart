import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../services/image_picker_service.dart';
import 'package:image_picker/image_picker.dart';

part 'profile_viewmodel.g.dart';

@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  @override
  FutureOr<void> build() {}

  Future<void> updateProfilePhoto(String userId, ImageSource source) async {
    state = await AsyncValue.guard(() async {
      try {
        final file = await ref.read(imagePickerServiceProvider).pickProfilePhoto(source);
        if (file == null) return;

        final photoUrl = await _uploadImage(file, 'users/$userId/profile/photo.jpg', userId);
        await ref.read(userServiceProvider).updateUserFields(userId, {'photoUrl': photoUrl});

        await FirebaseAnalytics.instance.logEvent(
          name: 'profile_photo_updated',
          parameters: {'user_id': userId, 'source': source.name},
        );
      } catch (error, stackTrace) {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Failed to update profile photo',
          information: ['userId: $userId', 'source: ${source.name}'],
        );
        rethrow;
      }
    });
  }

  Future<void> updateCoverPhoto(String userId, ImageSource source) async {
    state = await AsyncValue.guard(() async {
      try {
        final file = await ref.read(imagePickerServiceProvider).pickCoverPhoto(source);
        if (file == null) return;

        final coverPhotoUrl = await _uploadImage(file, 'users/$userId/profile/cover.jpg', userId);
        await ref.read(userServiceProvider).updateUserFields(userId, {'coverPhotoUrl': coverPhotoUrl});

        await FirebaseAnalytics.instance.logEvent(
          name: 'cover_photo_updated',
          parameters: {'user_id': userId, 'source': source.name},
        );
      } catch (error, stackTrace) {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Failed to update cover photo',
          information: ['userId: $userId', 'source: ${source.name}'],
        );
        rethrow;
      }
    });
  }

  Future<void> updateBio(String userId, String bio) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      try {
        await ref.read(userServiceProvider).updateUserFields(userId, {'bio': bio});

        await FirebaseAnalytics.instance.logEvent(
          name: 'bio_updated',
          parameters: {'user_id': userId},
        );
      } catch (error, stackTrace) {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Failed to update bio',
          information: ['userId: $userId'],
        );
        rethrow;
      }
    });
  }

  Future<String> _uploadImage(File file, String path, String userId) async {
    try {
      final fileBytes = await file.readAsBytes();
      final storageRef = FirebaseStorage.instance.ref().child(path);

      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final uploadTask = storageRef.putData(fileBytes, metadata);

      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();

      return url;
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Failed to upload image',
        information: ['path: $path', 'userId: $userId'],
      );
      rethrow;
    }
  }
}
