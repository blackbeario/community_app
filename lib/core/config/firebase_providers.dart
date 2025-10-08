import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_providers.g.dart';

/// Provider for FirebaseAuth instance
@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

/// Provider for FirebaseFirestore instance
@riverpod
FirebaseFirestore firebaseFirestore(FirebaseFirestoreRef ref) {
  return FirebaseFirestore.instance;
}

/// Provider for FirebaseStorage instance
@riverpod
FirebaseStorage firebaseStorage(FirebaseStorageRef ref) {
  return FirebaseStorage.instance;
}

/// Provider for FirebaseMessaging instance
@riverpod
FirebaseMessaging firebaseMessaging(FirebaseMessagingRef ref) {
  return FirebaseMessaging.instance;
}

/// Provider for current auth state
@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
}

/// Provider for current user
@riverpod
User? currentUser(CurrentUserRef ref) {
  return ref.watch(firebaseAuthProvider).currentUser;
}
