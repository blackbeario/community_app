import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/conversation.dart';
import '../../models/direct_message.dart';
import '../../models/user.dart';
import '../../services/dm_service.dart';
import '../../services/user_service.dart';
import '../navigation/screen_tracking_viewmodel.dart';

part 'dm_viewmodel.g.dart';

/// Stream provider for all conversations for the current user
@riverpod
Stream<List<Conversation>> userConversations(Ref ref, String userId) {
  final service = ref.watch(dmServiceProvider);
  return service.getUserConversations(userId);
}

/// Stream provider for a specific conversation
@riverpod
Stream<Conversation?> conversation(Ref ref, String conversationId) {
  final service = ref.watch(dmServiceProvider);
  return service.getConversation(conversationId);
}

/// Stream provider for messages in a conversation
@riverpod
Stream<List<DirectMessage>> conversationMessages(Ref ref, String conversationId) {
  final service = ref.watch(dmServiceProvider);
  return service.getMessages(conversationId);
}

/// Provider to get the other user in a conversation
@riverpod
Future<User?> conversationOtherUser(Ref ref, String conversationId, String currentUserId) async {
  final conversationAsync = await ref.watch(conversationProvider(conversationId).future);

  if (conversationAsync == null) return null;

  final otherUserId = conversationAsync.participants
      .firstWhere((id) => id != currentUserId, orElse: () => '');

  if (otherUserId.isEmpty) return null;

  final userService = ref.watch(userServiceProvider);
  return userService.getUser(otherUserId);
}

/// Provider for total unread count (one-time fetch)
@riverpod
Future<int> totalUnreadCount(Ref ref, String userId) async {
  final service = ref.watch(dmServiceProvider);
  return service.getUnreadCount(userId);
}

/// Stream provider for real-time unread DM count
/// Automatically adjusts count when user is viewing a conversation to prevent badge flash
@riverpod
Stream<int> unreadDmCount(Ref ref, String userId) {
  final service = ref.watch(dmServiceProvider);
  final currentScreen = ref.watch(currentScreenProvider);

  return service.watchUnreadCount(userId).asyncMap((totalCount) async {
    // If user is viewing a conversation, subtract that conversation's unread count
    if (currentScreen != null && currentScreen.startsWith('/direct-messages/conversation/')) {
      final conversationId = currentScreen.split('/').last;

      // Get the conversation to check its unread count
      final conversationSnapshot = await service.getConversation(conversationId).first;
      if (conversationSnapshot != null) {
        final unreadForThisConvo = conversationSnapshot.unreadCount[userId] ?? 0;
        // Subtract this conversation's unread from total to prevent badge flash
        return (totalCount - unreadForThisConvo).clamp(0, double.infinity).toInt();
      }
    }

    return totalCount;
  });
}

/// ViewModel for direct message actions
@riverpod
class DmViewModel extends _$DmViewModel {
  @override
  FutureOr<void> build() {}

  /// Get or create a conversation with another user
  Future<Conversation> getOrCreateConversation(
    String currentUserId,
    String otherUserId,
  ) async {
    final service = ref.read(dmServiceProvider);
    return service.getOrCreateConversation(currentUserId, otherUserId);
  }

  /// Send a direct message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String otherUserId,
    required String content,
    File? attachmentFile,
    String? attachmentType,
  }) async {
    state = await AsyncValue.guard(() async {
      try {
        String? attachmentUrl;

        // Upload attachment if provided
        if (attachmentFile != null && attachmentType != null) {
          attachmentUrl = await _uploadAttachment(
            attachmentFile,
            conversationId,
            senderId,
            attachmentType,
          );
        }

        final message = DirectMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          conversationId: conversationId,
          senderId: senderId,
          content: content,
          attachmentUrl: attachmentUrl,
          attachmentType: attachmentType,
          timestamp: DateTime.now(),
        );

        await ref.read(dmServiceProvider).sendMessage(message, otherUserId);
      } catch (error, stackTrace) {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Failed to send direct message',
          information: ['conversationId: $conversationId', 'senderId: $senderId'],
        );
        rethrow;
      }
    });
  }

  /// Upload attachment to Firebase Storage
  Future<String> _uploadAttachment(
    File file,
    String conversationId,
    String senderId,
    String attachmentType,
  ) async {
    try {
      final fileBytes = await file.readAsBytes();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = attachmentType == 'image' ? 'jpg' : 'pdf';
      final path = 'dm_attachments/$conversationId/$senderId-$timestamp.$extension';
      final storageRef = FirebaseStorage.instance.ref().child(path);

      final contentType = attachmentType == 'image' ? 'image/jpeg' : 'application/pdf';
      final metadata = SettableMetadata(contentType: contentType);
      final uploadTask = storageRef.putData(fileBytes, metadata);

      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();

      return url;
    } catch (error, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Failed to upload DM attachment',
        information: [
          'conversationId: $conversationId',
          'senderId: $senderId',
          'attachmentType: $attachmentType',
        ],
      );
      rethrow;
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(
    String conversationId,
    String userId,
    List<String> messageIds,
  ) async {
    state = await AsyncValue.guard(() async {
      await ref.read(dmServiceProvider).markMessagesAsRead(
        conversationId,
        userId,
        messageIds,
      );
    });
  }

  /// Set typing indicator
  Future<void> setTypingIndicator(
    String conversationId,
    String userId,
    bool isTyping,
  ) async {
    // Don't use AsyncValue.guard for typing indicators to avoid state changes
    try {
      await ref.read(dmServiceProvider).setTypingIndicator(
        conversationId,
        userId,
        isTyping,
      );
    } catch (error) {
      // Silently fail for typing indicators
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String conversationId, String messageId) async {
    state = await AsyncValue.guard(() async {
      await ref.read(dmServiceProvider).deleteMessage(conversationId, messageId);
    });
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    state = await AsyncValue.guard(() async {
      await ref.read(dmServiceProvider).deleteConversation(conversationId);
    });
  }

  /// Search messages in a conversation
  Future<List<DirectMessage>> searchMessages(
    String conversationId,
    String searchTerm,
  ) async {
    final service = ref.read(dmServiceProvider);
    return service.searchMessages(conversationId, searchTerm);
  }
}
