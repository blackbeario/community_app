import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/config/firebase_providers.dart';
import '../models/conversation.dart';
import '../models/direct_message.dart';

part 'dm_service.g.dart';

class DmService {
  final FirebaseFirestore _firestore;
  static const String _conversationsCollection = 'conversations';
  static const String _dmMessagesCollection = 'dm_messages';

  DmService(this._firestore);

  /// Generate a consistent conversation ID from two user IDs
  String _generateConversationId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  /// Get or create a conversation between two users
  Future<Conversation> getOrCreateConversation(
      String currentUserId, String otherUserId) async {
    final conversationId = _generateConversationId(currentUserId, otherUserId);
    final docRef =
        _firestore.collection(_conversationsCollection).doc(conversationId);

    // Create new conversation object
    final newConversation = Conversation(
      id: conversationId,
      participants: [currentUserId, otherUserId],
      lastMessage: '',
      lastMessageTimestamp: DateTime.now(),
      unreadCount: {currentUserId: 0, otherUserId: 0},
    );

    // Use a transaction to get or create atomically
    final result = await _firestore.runTransaction<Conversation>((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (snapshot.exists && snapshot.data() != null) {
        // Conversation exists, return it
        return Conversation.fromJson(snapshot.data()!);
      } else {
        // Create new conversation
        transaction.set(docRef, newConversation.toJson());
        return newConversation;
      }
    });

    return result;
  }

  /// Get all conversations for a user
  Stream<List<Conversation>> getUserConversations(String userId) {
    return _firestore
        .collection(_conversationsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Conversation.fromJson(doc.data()))
            .toList());
  }

  /// Get a specific conversation
  Stream<Conversation?> getConversation(String conversationId) {
    return _firestore
        .collection(_conversationsCollection)
        .doc(conversationId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return Conversation.fromJson(doc.data()!);
      }
      return null;
    });
  }

  /// Send a direct message
  Future<void> sendMessage(DirectMessage message, String otherUserId) async {
    final batch = _firestore.batch();

    // Add the message to the subcollection
    final messageRef = _firestore
        .collection(_conversationsCollection)
        .doc(message.conversationId)
        .collection(_dmMessagesCollection)
        .doc(message.id);
    batch.set(messageRef, message.toJson());

    // Update the conversation
    final conversationRef = _firestore
        .collection(_conversationsCollection)
        .doc(message.conversationId);
    batch.update(conversationRef, {
      'lastMessage': message.content,
      'lastMessageTimestamp': message.timestamp.millisecondsSinceEpoch,
      'lastMessageSenderId': message.senderId,
      'unreadCount.$otherUserId': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Get messages for a conversation
  Stream<List<DirectMessage>> getMessages(String conversationId) {
    return _firestore
        .collection(_conversationsCollection)
        .doc(conversationId)
        .collection(_dmMessagesCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DirectMessage.fromJson(doc.data()))
            .toList());
  }

  /// Get paginated messages for a conversation
  Future<List<DirectMessage>> getMessagesPaginated({
    required String conversationId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    Query query = _firestore
        .collection(_conversationsCollection)
        .doc(conversationId)
        .collection(_dmMessagesCollection)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => DirectMessage.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(
      String conversationId, String userId, List<String> messageIds) async {
    final batch = _firestore.batch();

    // Mark individual messages as read
    for (final messageId in messageIds) {
      final messageRef = _firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .collection(_dmMessagesCollection)
          .doc(messageId);
      batch.update(messageRef, {
        'isRead': true,
        'readAt': DateTime.now().millisecondsSinceEpoch,
      });
    }

    // Reset unread count for this user
    final conversationRef =
        _firestore.collection(_conversationsCollection).doc(conversationId);
    batch.update(conversationRef, {
      'unreadCount.$userId': 0,
    });

    await batch.commit();
  }

  /// Set typing indicator
  Future<void> setTypingIndicator(
      String conversationId, String userId, bool isTyping) async {
    await _firestore
        .collection(_conversationsCollection)
        .doc(conversationId)
        .update({
      'isTyping': isTyping,
      'typingUserId': isTyping ? userId : null,
    });
  }

  /// Delete a message
  Future<void> deleteMessage(String conversationId, String messageId) async {
    await _firestore
        .collection(_conversationsCollection)
        .doc(conversationId)
        .collection(_dmMessagesCollection)
        .doc(messageId)
        .delete();
  }

  /// Delete a conversation and all its messages
  Future<void> deleteConversation(String conversationId) async {
    // Note: In a real app, you might want to just hide it for the user
    // rather than actually deleting it to preserve message history

    final batch = _firestore.batch();

    // First, get all messages in the conversation
    final messagesSnapshot = await _firestore
        .collection(_conversationsCollection)
        .doc(conversationId)
        .collection(_dmMessagesCollection)
        .get();

    // Delete all messages in batches (Firestore batch limit is 500 operations)
    for (final doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete the conversation document itself
    final conversationRef = _firestore
        .collection(_conversationsCollection)
        .doc(conversationId);
    batch.delete(conversationRef);

    // Commit the batch
    await batch.commit();
  }

  /// Get unread message count for a user across all conversations
  Future<int> getUnreadCount(String userId) async {
    final snapshot = await _firestore
        .collection(_conversationsCollection)
        .where('participants', arrayContains: userId)
        .get();

    int totalUnread = 0;
    for (final doc in snapshot.docs) {
      final conversation = Conversation.fromJson(doc.data());
      totalUnread += conversation.unreadCount[userId] ?? 0;
    }

    return totalUnread;
  }

  /// Search messages in a conversation
  Future<List<DirectMessage>> searchMessages(
      String conversationId, String searchTerm) async {
    // Fetch recent messages (limit to avoid excessive reads)
    final querySnapshot = await _firestore
        .collection(_conversationsCollection)
        .doc(conversationId)
        .collection(_dmMessagesCollection)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();

    // Filter client-side for case-insensitive search
    final searchLower = searchTerm.toLowerCase();
    final results = querySnapshot.docs
        .map((doc) => DirectMessage.fromJson(doc.data()))
        .where((message) => message.content.toLowerCase().contains(searchLower))
        .toList();

    return results;
  }
}

@riverpod
DmService dmService(Ref ref) {
  return DmService(ref.watch(firebaseFirestoreProvider));
}
