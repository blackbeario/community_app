import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/config/firebase_providers.dart';
import '../models/user.dart';

part 'user_service.g.dart';

class UserService {
  final FirebaseFirestore _firestore;
  static const String _collection = 'users';

  UserService(this._firestore);

  Future<void> createUser(User user) async {
    await _firestore
        .collection(_collection)
        .doc(user.id)
        .set(user.toJson());
  }

  Future<User?> getUser(String userId) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(userId)
        .get();

    if (doc.exists && doc.data() != null) {
      return User.fromJson(doc.data()!);
    }
    return null;
  }

  Stream<User?> getUserStream(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return User.fromJson(doc.data()!);
      }
      return null;
    });
  }

  Future<void> updateUser(User user) async {
    await _firestore
        .collection(_collection)
        .doc(user.id)
        .update(user.toJson());
  }

  Future<void> updateUserFields(String userId, Map<String, dynamic> fields) async {
    await _firestore
        .collection(_collection)
        .doc(userId)
        .update(fields);
  }

  Future<void> deleteUser(String userId) async {
    await _firestore
        .collection(_collection)
        .doc(userId)
        .delete();
  }

  Future<List<User>> getAllUsers() async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .get();

    return querySnapshot.docs
        .map((doc) => User.fromJson(doc.data()))
        .toList();
  }

  Stream<List<User>> getAllUsersStream() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => User.fromJson(doc.data()))
            .toList());
  }

  Future<List<User>> searchUsers(String searchTerm) async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThan: searchTerm + '\uf8ff')
        .get();

    return querySnapshot.docs
        .map((doc) => User.fromJson(doc.data()))
        .toList();
  }

  Future<void> addUserToGroup(String userId, String groupId) async {
    await _firestore
        .collection(_collection)
        .doc(userId)
        .update({
      'groups': FieldValue.arrayUnion([groupId])
    });
  }

  Future<void> removeUserFromGroup(String userId, String groupId) async {
    await _firestore
        .collection(_collection)
        .doc(userId)
        .update({
      'groups': FieldValue.arrayRemove([groupId])
    });
  }

  Future<List<User>> getUsersByGroup(String groupId) async {
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('groups', arrayContains: groupId)
        .get();

    return querySnapshot.docs
        .map((doc) => User.fromJson(doc.data()))
        .toList();
  }
}

@riverpod
UserService userService(UserServiceRef ref) {
  return UserService(ref.watch(firebaseFirestoreProvider));
}