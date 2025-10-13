// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupMessagesHash() => r'e17c27bfc88f28632c31f76e01924a96070d7740';

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

/// Stream provider for recent messages in a specific group (limit: 20)
///
/// Copied from [groupMessages].
@ProviderFor(groupMessages)
const groupMessagesProvider = GroupMessagesFamily();

/// Stream provider for recent messages in a specific group (limit: 20)
///
/// Copied from [groupMessages].
class GroupMessagesFamily extends Family<AsyncValue<List<Message>>> {
  /// Stream provider for recent messages in a specific group (limit: 20)
  ///
  /// Copied from [groupMessages].
  const GroupMessagesFamily();

  /// Stream provider for recent messages in a specific group (limit: 20)
  ///
  /// Copied from [groupMessages].
  GroupMessagesProvider call(String groupId) {
    return GroupMessagesProvider(groupId);
  }

  @override
  GroupMessagesProvider getProviderOverride(
    covariant GroupMessagesProvider provider,
  ) {
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
  String? get name => r'groupMessagesProvider';
}

/// Stream provider for recent messages in a specific group (limit: 20)
///
/// Copied from [groupMessages].
class GroupMessagesProvider extends AutoDisposeStreamProvider<List<Message>> {
  /// Stream provider for recent messages in a specific group (limit: 20)
  ///
  /// Copied from [groupMessages].
  GroupMessagesProvider(String groupId)
    : this._internal(
        (ref) => groupMessages(ref as GroupMessagesRef, groupId),
        from: groupMessagesProvider,
        name: r'groupMessagesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupMessagesHash,
        dependencies: GroupMessagesFamily._dependencies,
        allTransitiveDependencies:
            GroupMessagesFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupMessagesProvider._internal(
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
  Override overrideWith(
    Stream<List<Message>> Function(GroupMessagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupMessagesProvider._internal(
        (ref) => create(ref as GroupMessagesRef),
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
  AutoDisposeStreamProviderElement<List<Message>> createElement() {
    return _GroupMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupMessagesProvider && other.groupId == groupId;
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
mixin GroupMessagesRef on AutoDisposeStreamProviderRef<List<Message>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupMessagesProviderElement
    extends AutoDisposeStreamProviderElement<List<Message>>
    with GroupMessagesRef {
  _GroupMessagesProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupMessagesProvider).groupId;
}

String _$messageUserHash() => r'1e85734a1d44d6917c4e18f71208df82122f05b6';

/// Provider to get user details for a message
///
/// Copied from [messageUser].
@ProviderFor(messageUser)
const messageUserProvider = MessageUserFamily();

/// Provider to get user details for a message
///
/// Copied from [messageUser].
class MessageUserFamily extends Family<AsyncValue<User?>> {
  /// Provider to get user details for a message
  ///
  /// Copied from [messageUser].
  const MessageUserFamily();

  /// Provider to get user details for a message
  ///
  /// Copied from [messageUser].
  MessageUserProvider call(String userId) {
    return MessageUserProvider(userId);
  }

  @override
  MessageUserProvider getProviderOverride(
    covariant MessageUserProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageUserProvider';
}

/// Provider to get user details for a message
///
/// Copied from [messageUser].
class MessageUserProvider extends AutoDisposeFutureProvider<User?> {
  /// Provider to get user details for a message
  ///
  /// Copied from [messageUser].
  MessageUserProvider(String userId)
    : this._internal(
        (ref) => messageUser(ref as MessageUserRef, userId),
        from: messageUserProvider,
        name: r'messageUserProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageUserHash,
        dependencies: MessageUserFamily._dependencies,
        allTransitiveDependencies: MessageUserFamily._allTransitiveDependencies,
        userId: userId,
      );

  MessageUserProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<User?> Function(MessageUserRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageUserProvider._internal(
        (ref) => create(ref as MessageUserRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<User?> createElement() {
    return _MessageUserProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageUserProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageUserRef on AutoDisposeFutureProviderRef<User?> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _MessageUserProviderElement
    extends AutoDisposeFutureProviderElement<User?>
    with MessageUserRef {
  _MessageUserProviderElement(super.provider);

  @override
  String get userId => (origin as MessageUserProvider).userId;
}

String _$messageCommentsHash() => r'0fb14e74cfcd0f5f13038f86a2cb3d4054da69a9';

/// Stream provider for comments on a specific message
///
/// Copied from [messageComments].
@ProviderFor(messageComments)
const messageCommentsProvider = MessageCommentsFamily();

/// Stream provider for comments on a specific message
///
/// Copied from [messageComments].
class MessageCommentsFamily extends Family<AsyncValue<List<Comment>>> {
  /// Stream provider for comments on a specific message
  ///
  /// Copied from [messageComments].
  const MessageCommentsFamily();

  /// Stream provider for comments on a specific message
  ///
  /// Copied from [messageComments].
  MessageCommentsProvider call(String messageId) {
    return MessageCommentsProvider(messageId);
  }

  @override
  MessageCommentsProvider getProviderOverride(
    covariant MessageCommentsProvider provider,
  ) {
    return call(provider.messageId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageCommentsProvider';
}

/// Stream provider for comments on a specific message
///
/// Copied from [messageComments].
class MessageCommentsProvider extends AutoDisposeStreamProvider<List<Comment>> {
  /// Stream provider for comments on a specific message
  ///
  /// Copied from [messageComments].
  MessageCommentsProvider(String messageId)
    : this._internal(
        (ref) => messageComments(ref as MessageCommentsRef, messageId),
        from: messageCommentsProvider,
        name: r'messageCommentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageCommentsHash,
        dependencies: MessageCommentsFamily._dependencies,
        allTransitiveDependencies:
            MessageCommentsFamily._allTransitiveDependencies,
        messageId: messageId,
      );

  MessageCommentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.messageId,
  }) : super.internal();

  final String messageId;

  @override
  Override overrideWith(
    Stream<List<Comment>> Function(MessageCommentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageCommentsProvider._internal(
        (ref) => create(ref as MessageCommentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        messageId: messageId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Comment>> createElement() {
    return _MessageCommentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageCommentsProvider && other.messageId == messageId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, messageId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageCommentsRef on AutoDisposeStreamProviderRef<List<Comment>> {
  /// The parameter `messageId` of this provider.
  String get messageId;
}

class _MessageCommentsProviderElement
    extends AutoDisposeStreamProviderElement<List<Comment>>
    with MessageCommentsRef {
  _MessageCommentsProviderElement(super.provider);

  @override
  String get messageId => (origin as MessageCommentsProvider).messageId;
}

String _$messageStreamHash() => r'5b6831735c43f19c4cc73c76985b4b71f1f34dd6';

/// Stream provider for a single message (real-time updates)
///
/// Copied from [messageStream].
@ProviderFor(messageStream)
const messageStreamProvider = MessageStreamFamily();

/// Stream provider for a single message (real-time updates)
///
/// Copied from [messageStream].
class MessageStreamFamily extends Family<AsyncValue<Message?>> {
  /// Stream provider for a single message (real-time updates)
  ///
  /// Copied from [messageStream].
  const MessageStreamFamily();

  /// Stream provider for a single message (real-time updates)
  ///
  /// Copied from [messageStream].
  MessageStreamProvider call(String messageId) {
    return MessageStreamProvider(messageId);
  }

  @override
  MessageStreamProvider getProviderOverride(
    covariant MessageStreamProvider provider,
  ) {
    return call(provider.messageId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageStreamProvider';
}

/// Stream provider for a single message (real-time updates)
///
/// Copied from [messageStream].
class MessageStreamProvider extends AutoDisposeStreamProvider<Message?> {
  /// Stream provider for a single message (real-time updates)
  ///
  /// Copied from [messageStream].
  MessageStreamProvider(String messageId)
    : this._internal(
        (ref) => messageStream(ref as MessageStreamRef, messageId),
        from: messageStreamProvider,
        name: r'messageStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageStreamHash,
        dependencies: MessageStreamFamily._dependencies,
        allTransitiveDependencies:
            MessageStreamFamily._allTransitiveDependencies,
        messageId: messageId,
      );

  MessageStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.messageId,
  }) : super.internal();

  final String messageId;

  @override
  Override overrideWith(
    Stream<Message?> Function(MessageStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageStreamProvider._internal(
        (ref) => create(ref as MessageStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        messageId: messageId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Message?> createElement() {
    return _MessageStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageStreamProvider && other.messageId == messageId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, messageId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageStreamRef on AutoDisposeStreamProviderRef<Message?> {
  /// The parameter `messageId` of this provider.
  String get messageId;
}

class _MessageStreamProviderElement
    extends AutoDisposeStreamProviderElement<Message?>
    with MessageStreamRef {
  _MessageStreamProviderElement(super.provider);

  @override
  String get messageId => (origin as MessageStreamProvider).messageId;
}

String _$messageViewModelHash() => r'86240117da4260e904b450470e66f13772486432';

/// ViewModel for message actions (posting, liking, commenting)
///
/// Copied from [MessageViewModel].
@ProviderFor(MessageViewModel)
final messageViewModelProvider =
    AutoDisposeAsyncNotifierProvider<MessageViewModel, void>.internal(
      MessageViewModel.new,
      name: r'messageViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$messageViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MessageViewModel = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
