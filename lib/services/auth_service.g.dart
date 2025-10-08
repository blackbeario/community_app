// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authServiceHash() => r'875fb058fc8477dbc39f3c6cd54751c5cc83660e';

/// See also [authService].
@ProviderFor(authService)
final authServiceProvider = AutoDisposeProvider<AuthService>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthServiceRef = AutoDisposeProviderRef<AuthService>;
String _$authStateChangesHash() => r'e4bf937b0dadc4beb0670493cfe2c65336eaa53f';

/// See also [authStateChanges].
@ProviderFor(authStateChanges)
final authStateChangesProvider =
    AutoDisposeStreamProvider<firebase_auth.User?>.internal(
      authStateChanges,
      name: r'authStateChangesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authStateChangesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateChangesRef = AutoDisposeStreamProviderRef<firebase_auth.User?>;
String _$currentUserHash() => r'76dbb22eebb489fad1f56d689d811a0013bb29d6';

/// See also [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<firebase_auth.User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeProviderRef<firebase_auth.User?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
