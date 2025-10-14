// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_cache_sync_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localUserCacheServiceHash() =>
    r'ea5ff162324e56706bec6560dd1d9b0abfa64bff';

/// Provider for the local user cache service
///
/// Copied from [localUserCacheService].
@ProviderFor(localUserCacheService)
final localUserCacheServiceProvider =
    AutoDisposeProvider<LocalUserCacheService>.internal(
      localUserCacheService,
      name: r'localUserCacheServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$localUserCacheServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalUserCacheServiceRef =
    AutoDisposeProviderRef<LocalUserCacheService>;
String _$allCachedUsersHash() => r'069bee160ed203b52c7d9d750f03ff8a43907846';

/// Provider to get all cached users (for mentions)
///
/// Copied from [allCachedUsers].
@ProviderFor(allCachedUsers)
final allCachedUsersProvider = AutoDisposeFutureProvider<List<User>>.internal(
  allCachedUsers,
  name: r'allCachedUsersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allCachedUsersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllCachedUsersRef = AutoDisposeFutureProviderRef<List<User>>;
String _$userCacheSyncHash() => r'9564ecbff74a71addfbc9a27013ed47493eeb057';

/// Provider for syncing users from Firestore to local cache
///
/// Copied from [UserCacheSync].
@ProviderFor(UserCacheSync)
final userCacheSyncProvider =
    AutoDisposeAsyncNotifierProvider<UserCacheSync, void>.internal(
      UserCacheSync.new,
      name: r'userCacheSyncProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userCacheSyncHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UserCacheSync = AutoDisposeAsyncNotifier<void>;
String _$cachedUserSearchHash() => r'08be382857803ec599521f5ae5bbd08e6303958e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$CachedUserSearch
    extends BuildlessAutoDisposeAsyncNotifier<List<User>> {
  late final String query;

  FutureOr<List<User>> build(String query);
}

/// Provider for searching cached users (offline-capable)
///
/// Copied from [CachedUserSearch].
@ProviderFor(CachedUserSearch)
const cachedUserSearchProvider = CachedUserSearchFamily();

/// Provider for searching cached users (offline-capable)
///
/// Copied from [CachedUserSearch].
class CachedUserSearchFamily extends Family<AsyncValue<List<User>>> {
  /// Provider for searching cached users (offline-capable)
  ///
  /// Copied from [CachedUserSearch].
  const CachedUserSearchFamily();

  /// Provider for searching cached users (offline-capable)
  ///
  /// Copied from [CachedUserSearch].
  CachedUserSearchProvider call(String query) {
    return CachedUserSearchProvider(query);
  }

  @override
  CachedUserSearchProvider getProviderOverride(
    covariant CachedUserSearchProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cachedUserSearchProvider';
}

/// Provider for searching cached users (offline-capable)
///
/// Copied from [CachedUserSearch].
class CachedUserSearchProvider
    extends AutoDisposeAsyncNotifierProviderImpl<CachedUserSearch, List<User>> {
  /// Provider for searching cached users (offline-capable)
  ///
  /// Copied from [CachedUserSearch].
  CachedUserSearchProvider(String query)
    : this._internal(
        () => CachedUserSearch()..query = query,
        from: cachedUserSearchProvider,
        name: r'cachedUserSearchProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cachedUserSearchHash,
        dependencies: CachedUserSearchFamily._dependencies,
        allTransitiveDependencies:
            CachedUserSearchFamily._allTransitiveDependencies,
        query: query,
      );

  CachedUserSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  FutureOr<List<User>> runNotifierBuild(covariant CachedUserSearch notifier) {
    return notifier.build(query);
  }

  @override
  Override overrideWith(CachedUserSearch Function() create) {
    return ProviderOverride(
      origin: this,
      override: CachedUserSearchProvider._internal(
        () => create()..query = query,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<CachedUserSearch, List<User>>
  createElement() {
    return _CachedUserSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CachedUserSearchProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CachedUserSearchRef on AutoDisposeAsyncNotifierProviderRef<List<User>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _CachedUserSearchProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<CachedUserSearch, List<User>>
    with CachedUserSearchRef {
  _CachedUserSearchProviderElement(super.provider);

  @override
  String get query => (origin as CachedUserSearchProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
