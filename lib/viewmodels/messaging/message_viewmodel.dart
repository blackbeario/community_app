import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/message.dart';
import '../../models/user.dart';
import '../../services/message_service.dart';
import '../../services/user_service.dart';
import '../../services/message_cache_service.dart';

part 'message_viewmodel.g.dart';

/// Stream provider for recent messages in a specific group (limit: 20)
/// Automatically caches messages for offline search
@riverpod
Stream<List<Message>> groupMessages(Ref ref, String groupId) {
  final service = ref.watch(messageServiceProvider);
  final cacheService = ref.watch(messageCacheServiceProvider);

  return service.getMessagesLimit(groupId, 20).asyncMap((messages) async {
    // Cache messages in the background for offline search
    if (messages.isNotEmpty) {
      try {
        await cacheService.cacheMessages(messages);
      } catch (e) {
        // Don't block the stream if caching fails
        debugPrint('Failed to cache messages: $e');
      }
    }
    return messages;
  });
}

/// Provider to get user details for a message
@riverpod
Future<User?> messageUser(Ref ref, String userId) async {
  final userService = ref.watch(userServiceProvider);
  return userService.getUser(userId);
}

/// ViewModel for message actions (posting, liking, commenting)
@riverpod
class MessageViewModel extends _$MessageViewModel {
  @override
  FutureOr<void> build() {}

  /// Post a new message to a group
  Future<void> postMessage({
    required String groupId,
    required String userId,
    required String content,
    String? imageUrl,
  }) async {
    state = await AsyncValue.guard(() async {
      try {
        final message = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          groupId: groupId,
          userId: userId,
          content: content,
          imageUrl: imageUrl,
          timestamp: DateTime.now(),
        );
        await ref.read(messageServiceProvider).postMessage(message);
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

  /// Like a message
  Future<void> likeMessage(String messageId, String userId) async {
    state = await AsyncValue.guard(() async {
      await ref.read(messageServiceProvider).likeMessage(messageId, userId);
    });
  }

  /// Unlike a message
  Future<void> unlikeMessage(String messageId, String userId) async {
    state = await AsyncValue.guard(() async {
      await ref.read(messageServiceProvider).unlikeMessage(messageId, userId);
    });
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    state = await AsyncValue.guard(() async {
      await ref.read(messageServiceProvider).deleteMessage(messageId);
    });
  }

  /// Add a comment to a message
  Future<void> addComment({
    required String messageId,
    required String userId,
    required String content,
    File? imageFile,
  }) async {
    state = await AsyncValue.guard(() async {
      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _uploadCommentImage(imageFile, messageId, userId);
      }

      final comment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        messageId: messageId,
        userId: userId,
        content: content,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
      );
      await ref.read(messageServiceProvider).addComment(comment);
    });
  }

  /// Upload comment image to Firebase Storage
  Future<String> _uploadCommentImage(File file, String messageId, String userId) async {
    try {
      final fileBytes = await file.readAsBytes();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'comments/$messageId/$userId-$timestamp.jpg';
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
        reason: 'Failed to upload comment image',
        information: ['messageId: $messageId', 'userId: $userId'],
      );
      rethrow;
    }
  }
}

/// Stream provider for comments on a specific message
@riverpod
Stream<List<Comment>> messageComments(Ref ref, String messageId) {
  final service = ref.watch(messageServiceProvider);
  return service.getComments(messageId);
}

/// Stream provider for a single message (real-time updates)
@riverpod
Stream<Message?> messageStream(Ref ref, String messageId) {
  final service = ref.watch(messageServiceProvider);
  return service.getMessageStream(messageId);
}
