import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    });
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    String? unitNumber,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final userCredential = await ref.read(authServiceProvider).createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final user = User(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          unitNumber: unitNumber,
          createdAt: DateTime.now(),
        );

        await ref.read(userServiceProvider).createUser(user);
        
        await userCredential.user!.updateDisplayName(name);
        await ref.read(authServiceProvider).sendEmailVerification();
      }
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).signOut();
    });
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
    });
  }
}

@riverpod
Stream<firebase_auth.User?> authState(Ref ref) {
  return ref.watch(authServiceProvider).authStateChanges;
}

@riverpod
firebase_auth.User? currentFirebaseUser(Ref ref) {
  return ref.watch(authServiceProvider).currentUser;
}

@riverpod
Stream<User?> currentAppUser(Ref ref) async* {
  final authUser = ref.watch(currentFirebaseUserProvider);
  
  if (authUser != null) {
    yield* ref.watch(userServiceProvider).getUserStream(authUser.uid);
  } else {
    yield null;
  }
}