import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/config/firebase_providers.dart';
import '../models/message.dart';

part 'message_service.g.dart';

class MessageService {
  final FirebaseFirestore _firestore;
  static const String _messagesCollection = 'messages';
  static const String _commentsCollection = 'comments';

  MessageService(this._firestore);

  Future<void> postMessage(Message message) async {
    await _firestore
        .collection(_messagesCollection)
        .doc(message.id)
        .set(message.toJson());
  }

  Stream<List<Message>> getMessages(String groupId) {
    return _firestore
        .collection(_messagesCollection)
        .where('groupId', isEqualTo: groupId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromJson(doc.data()))
            .toList());
  }

  Stream<List<Message>> getAllMessages({int? limit}) {
    Query query = _firestore
        .collection(_messagesCollection)
        .orderBy('timestamp', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<Message>> getMessagesLimit(String groupId, int limit) {
    return _firestore
        .collection(_messagesCollection)
        .where('groupId', isEqualTo: groupId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromJson(doc.data()))
            .toList());
  }

  Future<List<Message>> getMessagesPaginated({
    required String groupId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    Query query = _firestore
        .collection(_messagesCollection)
        .where('groupId', isEqualTo: groupId)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<QuerySnapshot> getAllMessagesPaginated({
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    Query query = _firestore
        .collection(_messagesCollection)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return await query.get();
  }

  Future<QuerySnapshot> getGroupMessagesPaginated({
    required String groupId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    Query query = _firestore
        .collection(_messagesCollection)
        .where('groupId', isEqualTo: groupId)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return await query.get();
  }

  Future<Message?> getMessage(String messageId) async {
    final doc = await _firestore
        .collection(_messagesCollection)
        .doc(messageId)
        .get();

    if (doc.exists && doc.data() != null) {
      return Message.fromJson(doc.data()!);
    }
    return null;
  }

  Stream<Message?> getMessageStream(String messageId) {
    return _firestore
        .collection(_messagesCollection)
        .doc(messageId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return Message.fromJson(doc.data()!);
      }
      return null;
    });
  }

  Future<void> likeMessage(String messageId, String userId) async {
    await _firestore
        .collection(_messagesCollection)
        .doc(messageId)
        .update({
      'likes': FieldValue.arrayUnion([userId])
    });
  }

  Future<void> unlikeMessage(String messageId, String userId) async {
    await _firestore
        .collection(_messagesCollection)
        .doc(messageId)
        .update({
      'likes': FieldValue.arrayRemove([userId])
    });
  }

  Future<void> deleteMessage(String messageId) async {
    await _firestore
        .collection(_messagesCollection)
        .doc(messageId)
        .delete();
  }

  Future<void> addComment(Comment comment) async {
    final batch = _firestore.batch();

    batch.set(
      _firestore.collection(_commentsCollection).doc(comment.id),
      comment.toJson(),
    );

    batch.update(
      _firestore.collection(_messagesCollection).doc(comment.messageId),
      {'commentCount': FieldValue.increment(1)},
    );

    await batch.commit();
  }

  Stream<List<Comment>> getComments(String messageId) {
    return _firestore
        .collection(_commentsCollection)
        .where('messageId', isEqualTo: messageId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromJson(doc.data()))
            .toList());
  }

  Future<void> deleteComment(String commentId, String messageId) async {
    final batch = _firestore.batch();

    batch.delete(_firestore.collection(_commentsCollection).doc(commentId));

    batch.update(
      _firestore.collection(_messagesCollection).doc(messageId),
      {'commentCount': FieldValue.increment(-1)},
    );

    await batch.commit();
  }

  /// Search messages in a specific group
  /// Note: This fetches recent messages and filters client-side since Firestore
  /// doesn't support full-text search. For better performance with large datasets,
  /// consider using the MessageCacheService with SQLite FTS5.
  Future<List<Message>> searchMessages(String groupId, String searchTerm) async {
    // Fetch recent messages from the group (limit to avoid excessive reads)
    final querySnapshot = await _firestore
        .collection(_messagesCollection)
        .where('groupId', isEqualTo: groupId)
        .orderBy('timestamp', descending: true)
        .limit(100) // Limit to recent 100 messages to control costs
        .get();

    // Filter client-side for case-insensitive search
    final searchLower = searchTerm.toLowerCase();
    final results = querySnapshot.docs
        .map((doc) => Message.fromJson(doc.data()))
        .where((message) => message.content.toLowerCase().contains(searchLower))
        .toList();

    return results;
  }
}

@riverpod
MessageService messageService(Ref ref) {
  return MessageService(ref.watch(firebaseFirestoreProvider));
}