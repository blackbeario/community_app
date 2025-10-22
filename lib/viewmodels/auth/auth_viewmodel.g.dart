// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateHash() => r'876788cb4d58790b139a3c3c4dd45497d4165259';

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
    r'a9aa96898b8d19554bf0e10ea883198d558d5e38';

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
String _$currentAppUserHash() => r'6df262f33b823e059f548160ac6437c3c86a83a6';

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
String _$authViewModelHash() => r'8059e8b4b801129b13a6368f75181a61986f7851';

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
