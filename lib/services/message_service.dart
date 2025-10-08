import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<List<Message>> searchMessages(String groupId, String searchTerm) async {
    final querySnapshot = await _firestore
        .collection(_messagesCollection)
        .where('groupId', isEqualTo: groupId)
        .where('content', isGreaterThanOrEqualTo: searchTerm)
        .where('content', isLessThan: '$searchTerm\uf8ff')
        .orderBy('content')
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => Message.fromJson(doc.data()))
        .toList();
  }
}

@riverpod
MessageService messageService(MessageServiceRef ref) {
  return MessageService(ref.watch(firebaseFirestoreProvider));
}