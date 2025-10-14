// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupServiceHash() => r'ee74ae771cb622b53d71ec394da7fd3871233e0e';

/// See also [groupService].
@ProviderFor(groupService)
final groupServiceProvider = AutoDisposeProvider<GroupService>.internal(
  groupService,
  name: r'groupServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groupServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroupServiceRef = AutoDisposeProviderRef<GroupService>;
String _$allGroupsHash() => r'44ba07697a67201628dbd1c57e44655a23051b50';

/// Provider to get all groups as a stream
///
/// Copied from [allGroups].
@ProviderFor(allGroups)
final allGroupsProvider = AutoDisposeStreamProvider<List<Group>>.internal(
  allGroups,
  name: r'allGroupsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allGroupsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllGroupsRef = AutoDisposeStreamProviderRef<List<Group>>;
String _$publicGroupsHash() => r'82e85cb4accd8b1f5d120df10a72bb400425f85b';

/// Provider to get public groups only
///
/// Copied from [publicGroups].
@ProviderFor(publicGroups)
final publicGroupsProvider = AutoDisposeStreamProvider<List<Group>>.internal(
  publicGroups,
  name: r'publicGroupsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$publicGroupsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PublicGroupsRef = AutoDisposeStreamProviderRef<List<Group>>;
String _$groupHash() => r'2122ee19dcdf50ab2a6efd982de972c36cefa1b4';

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

/// Provider to get a specific group by ID
///
/// Copied from [group].
@ProviderFor(group)
const groupProvider = GroupFamily();

/// Provider to get a specific group by ID
///
/// Copied from [group].
class GroupFamily extends Family<AsyncValue<Group?>> {
  /// Provider to get a specific group by ID
  ///
  /// Copied from [group].
  const GroupFamily();

  /// Provider to get a specific group by ID
  ///
  /// Copied from [group].
  GroupProvider call(String groupId) {
    return GroupProvider(groupId);
  }

  @override
  GroupProvider getProviderOverride(covariant GroupProvider provider) {
    return call(provider.groupId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupProvider';
}

/// Provider to get a specific group by ID
///
/// Copied from [group].
class GroupProvider extends AutoDisposeStreamProvider<Group?> {
  /// Provider to get a specific group by ID
  ///
  /// Copied from [group].
  GroupProvider(String groupId)
    : this._internal(
        (ref) => group(ref as GroupRef, groupId),
        from: groupProvider,
        name: r'groupProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupHash,
        dependencies: GroupFamily._dependencies,
        allTransitiveDependencies: GroupFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Override overrideWith(Stream<Group?> Function(GroupRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: GroupProvider._internal(
        (ref) => create(ref as GroupRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Group?> createElement() {
    return _GroupProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupRef on AutoDisposeStreamProviderRef<Group?> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupProviderElement extends AutoDisposeStreamProviderElement<Group?>
    with GroupRef {
  _GroupProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupProvider).groupId;
}

String _$selectableGroupsHash() => r'080ae0cf2949bfc54e424d7affb61c48b853d2b5';

/// Provider to get selectable groups (all except 'all')
///
/// Copied from [selectableGroups].
@ProviderFor(selectableGroups)
final selectableGroupsProvider =
    AutoDisposeStreamProvider<List<Group>>.internal(
      selectableGroups,
      name: r'selectableGroupsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectableGroupsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectableGroupsRef = AutoDisposeStreamProviderRef<List<Group>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
