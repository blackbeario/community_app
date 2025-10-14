import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/config/firebase_providers.dart';
import '../models/group.dart';

part 'group_service.g.dart';

class GroupService {
  final FirebaseFirestore _firestore;
  static const String _collection = 'groups';

  GroupService(this._firestore);

  /// Create a new group
  Future<void> createGroup(Group group) async {
    await _firestore
        .collection(_collection)
        .doc(group.id)
        .set(group.toJson());
  }

  /// Get a single group by ID
  Future<Group?> getGroup(String groupId) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(groupId)
        .get();

    if (doc.exists && doc.data() != null) {
      return Group.fromJson(doc.data()!);
    }
    return null;
  }

  /// Get a group stream (real-time updates)
  Stream<Group?> getGroupStream(String groupId) {
    return _firestore
        .collection(_collection)
        .doc(groupId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return Group.fromJson(doc.data()!);
      }
      return null;
    });
  }

  /// Get all groups
  Stream<List<Group>> getAllGroups() {
    return _firestore
        .collection(_collection)
        .orderBy('name', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Group.fromJson(doc.data()))
            .toList());
  }

  /// Get public groups only
  Stream<List<Group>> getPublicGroups() {
    return _firestore
        .collection(_collection)
        .where('isPublic', isEqualTo: true)
        .orderBy('name', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Group.fromJson(doc.data()))
            .toList());
  }

  /// Update an existing group
  Future<void> updateGroup(Group group) async {
    await _firestore
        .collection(_collection)
        .doc(group.id)
        .update(group.toJson());
  }

  /// Delete a group
  Future<void> deleteGroup(String groupId) async {
    await _firestore
        .collection(_collection)
        .doc(groupId)
        .delete();
  }

  /// Increment member count
  Future<void> incrementMemberCount(String groupId) async {
    await _firestore
        .collection(_collection)
        .doc(groupId)
        .update({
      'memberCount': FieldValue.increment(1),
    });
  }

  /// Decrement member count
  Future<void> decrementMemberCount(String groupId) async {
    await _firestore
        .collection(_collection)
        .doc(groupId)
        .update({
      'memberCount': FieldValue.increment(-1),
    });
  }

  /// Initialize groups with provided seed data (one-time setup)
  /// Call this once to populate Firestore with initial groups
  Future<void> seedGroups(List<Group> groups) async {
    final batch = _firestore.batch();

    for (final group in groups) {
      final docRef = _firestore.collection(_collection).doc(group.id);
      batch.set(docRef, group.toJson());
    }

    await batch.commit();
  }

  /// Check if groups collection is empty (for initial setup)
  Future<bool> isGroupsCollectionEmpty() async {
    final snapshot = await _firestore
        .collection(_collection)
        .limit(1)
        .get();
    return snapshot.docs.isEmpty;
  }
}

@riverpod
GroupService groupService(Ref ref) {
  return GroupService(ref.watch(firebaseFirestoreProvider));
}

/// Provider to get all groups as a stream
@riverpod
Stream<List<Group>> allGroups(Ref ref) {
  return ref.watch(groupServiceProvider).getAllGroups();
}

/// Provider to get public groups only
@riverpod
Stream<List<Group>> publicGroups(Ref ref) {
  return ref.watch(groupServiceProvider).getPublicGroups();
}

/// Provider to get a specific group by ID
@riverpod
Stream<Group?> group(Ref ref, String groupId) {
  return ref.watch(groupServiceProvider).getGroupStream(groupId);
}

/// Provider to get selectable groups (all except 'all')
@riverpod
Stream<List<Group>> selectableGroups(Ref ref) {
  return ref.watch(groupServiceProvider).getAllGroups().map((groups) {
    return groups.where((group) => group.id != 'all').toList();
  });
}
