// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authServiceHash() => r'ac0fb87c9db72a1b3f29aaf90428ac20b82a7b4e';

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
String _$authStateChangesHash() => r'605276926fb9b414f1ef8f4cbddede20b37a871b';

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
String _$currentUserHash() => r'543cbe253c4f2951b4cb25c26f626e05e2a715d3';

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
