import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/config/firebase_providers.dart';
import '../models/user.dart' as app_user;

part 'auth_service.g.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  bool get isSignedIn => currentUser != null;

  Future<firebase_auth.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<firebase_auth.UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> reloadUser() async {
    await currentUser?.reload();
  }

  AuthException _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('No user found with this email address.');
      case 'wrong-password':
        return AuthException('Incorrect password.');
      case 'email-already-in-use':
        return AuthException('An account already exists with this email address.');
      case 'weak-password':
        return AuthException('Password is too weak.');
      case 'invalid-email':
        return AuthException('Invalid email address.');
      case 'user-disabled':
        return AuthException('This account has been disabled.');
      case 'too-many-requests':
        return AuthException('Too many failed attempts. Please try again later.');
      default:
        return AuthException('Authentication failed: ${e.message}');
    }
  }
}

class AuthException implements Exception {
  final String message;
  
  const AuthException(this.message);
  
  @override
  String toString() => message;
}

@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
}

@riverpod
Stream<firebase_auth.User?> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authServiceProvider).authStateChanges;
}

@riverpod
firebase_auth.User? currentUser(CurrentUserRef ref) {
  return ref.watch(authServiceProvider).currentUser;
}