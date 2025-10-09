import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/message.dart';
import '../../models/user.dart';
import '../../services/message_service.dart';
import '../../services/user_service.dart';

part 'message_viewmodel.g.dart';

/// Stream provider for messages in a specific group
@riverpod
Stream<List<Message>> messages(Ref ref, String groupId) {
  final service = ref.watch(messageServiceProvider);
  return service.getMessages(groupId);
}

/// Stream provider for all messages (across all groups)
@riverpod
Stream<List<Message>> allMessages(Ref ref) {
  final service = ref.watch(messageServiceProvider);
  // For now, we'll fetch from a general "all" group or you can modify this
  // to aggregate multiple groups
  return service.getMessages('all');
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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(messageServiceProvider).likeMessage(messageId, userId);
    });
  }

  /// Unlike a message
  Future<void> unlikeMessage(String messageId, String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(messageServiceProvider).unlikeMessage(messageId, userId);
    });
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(messageServiceProvider).deleteMessage(messageId);
    });
  }

  /// Add a comment to a message
  Future<void> addComment({required String messageId, required String userId, required String content}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final comment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        messageId: messageId,
        userId: userId,
        content: content,
        timestamp: DateTime.now(),
      );
      await ref.read(messageServiceProvider).addComment(comment);
    });
  }
}

/// Stream provider for comments on a specific message
@riverpod
Stream<List<Comment>> messageComments(Ref ref, String messageId) {
  final service = ref.watch(messageServiceProvider);
  return service.getComments(messageId);
}
