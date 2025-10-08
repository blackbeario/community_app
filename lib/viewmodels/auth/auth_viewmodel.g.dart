// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateHash() => r'0b877a6620b9dad541fb53829cc6285756eb383c';

/// See also [authState].
@ProviderFor(authState)
final authStateProvider =
    AutoDisposeStreamProvider<firebase_auth.User?>.internal(
      authState,
      name: r'authStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeStreamProviderRef<firebase_auth.User?>;
String _$currentFirebaseUserHash() =>
    r'a209de17ed0e39269c8dac3aafba9e1d8b7a5105';

/// See also [currentFirebaseUser].
@ProviderFor(currentFirebaseUser)
final currentFirebaseUserProvider =
    AutoDisposeProvider<firebase_auth.User?>.internal(
      currentFirebaseUser,
      name: r'currentFirebaseUserProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentFirebaseUserHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentFirebaseUserRef = AutoDisposeProviderRef<firebase_auth.User?>;
String _$currentAppUserHash() => r'547503eba2b4e1ebab71a0d96b0ae543f1336efc';

/// See also [currentAppUser].
@ProviderFor(currentAppUser)
final currentAppUserProvider = AutoDisposeStreamProvider<User?>.internal(
  currentAppUser,
  name: r'currentAppUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentAppUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentAppUserRef = AutoDisposeStreamProviderRef<User?>;
String _$authViewModelHash() => r'd39e11c7382aea59c7790b856c703fbcd6f0b51e';

/// See also [AuthViewModel].
@ProviderFor(AuthViewModel)
final authViewModelProvider =
    AutoDisposeAsyncNotifierProvider<AuthViewModel, void>.internal(
      AuthViewModel.new,
      name: r'authViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthViewModel = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
