// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dm_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userConversationsHash() => r'41e8bc2b670ea977a1eab44ae7ae458e92705a92';

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

/// Stream provider for all conversations for the current user
///
/// Copied from [userConversations].
@ProviderFor(userConversations)
const userConversationsProvider = UserConversationsFamily();

/// Stream provider for all conversations for the current user
///
/// Copied from [userConversations].
class UserConversationsFamily extends Family<AsyncValue<List<Conversation>>> {
  /// Stream provider for all conversations for the current user
  ///
  /// Copied from [userConversations].
  const UserConversationsFamily();

  /// Stream provider for all conversations for the current user
  ///
  /// Copied from [userConversations].
  UserConversationsProvider call(String userId) {
    return UserConversationsProvider(userId);
  }

  @override
  UserConversationsProvider getProviderOverride(
    covariant UserConversationsProvider provider,
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
  String? get name => r'userConversationsProvider';
}

/// Stream provider for all conversations for the current user
///
/// Copied from [userConversations].
class UserConversationsProvider
    extends AutoDisposeStreamProvider<List<Conversation>> {
  /// Stream provider for all conversations for the current user
  ///
  /// Copied from [userConversations].
  UserConversationsProvider(String userId)
    : this._internal(
        (ref) => userConversations(ref as UserConversationsRef, userId),
        from: userConversationsProvider,
        name: r'userConversationsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userConversationsHash,
        dependencies: UserConversationsFamily._dependencies,
        allTransitiveDependencies:
            UserConversationsFamily._allTransitiveDependencies,
        userId: userId,
      );

  UserConversationsProvider._internal(
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
    Stream<List<Conversation>> Function(UserConversationsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserConversationsProvider._internal(
        (ref) => create(ref as UserConversationsRef),
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
  AutoDisposeStreamProviderElement<List<Conversation>> createElement() {
    return _UserConversationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserConversationsProvider && other.userId == userId;
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
mixin UserConversationsRef on AutoDisposeStreamProviderRef<List<Conversation>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserConversationsProviderElement
    extends AutoDisposeStreamProviderElement<List<Conversation>>
    with UserConversationsRef {
  _UserConversationsProviderElement(super.provider);

  @override
  String get userId => (origin as UserConversationsProvider).userId;
}

String _$conversationHash() => r'a0cfb5ed67958f7caaa0570ff4f518cb4ad6e50f';

/// Stream provider for a specific conversation
///
/// Copied from [conversation].
@ProviderFor(conversation)
const conversationProvider = ConversationFamily();

/// Stream provider for a specific conversation
///
/// Copied from [conversation].
class ConversationFamily extends Family<AsyncValue<Conversation?>> {
  /// Stream provider for a specific conversation
  ///
  /// Copied from [conversation].
  const ConversationFamily();

  /// Stream provider for a specific conversation
  ///
  /// Copied from [conversation].
  ConversationProvider call(String conversationId) {
    return ConversationProvider(conversationId);
  }

  @override
  ConversationProvider getProviderOverride(
    covariant ConversationProvider provider,
  ) {
    return call(provider.conversationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'conversationProvider';
}

/// Stream provider for a specific conversation
///
/// Copied from [conversation].
class ConversationProvider extends AutoDisposeStreamProvider<Conversation?> {
  /// Stream provider for a specific conversation
  ///
  /// Copied from [conversation].
  ConversationProvider(String conversationId)
    : this._internal(
        (ref) => conversation(ref as ConversationRef, conversationId),
        from: conversationProvider,
        name: r'conversationProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$conversationHash,
        dependencies: ConversationFamily._dependencies,
        allTransitiveDependencies:
            ConversationFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  ConversationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  Override overrideWith(
    Stream<Conversation?> Function(ConversationRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConversationProvider._internal(
        (ref) => create(ref as ConversationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Conversation?> createElement() {
    return _ConversationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConversationRef on AutoDisposeStreamProviderRef<Conversation?> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _ConversationProviderElement
    extends AutoDisposeStreamProviderElement<Conversation?>
    with ConversationRef {
  _ConversationProviderElement(super.provider);

  @override
  String get conversationId => (origin as ConversationProvider).conversationId;
}

String _$conversationMessagesHash() =>
    r'bfbb6c2b317f43b93df739a97ec61f599914fc0b';

/// Stream provider for messages in a conversation
///
/// Copied from [conversationMessages].
@ProviderFor(conversationMessages)
const conversationMessagesProvider = ConversationMessagesFamily();

/// Stream provider for messages in a conversation
///
/// Copied from [conversationMessages].
class ConversationMessagesFamily
    extends Family<AsyncValue<List<DirectMessage>>> {
  /// Stream provider for messages in a conversation
  ///
  /// Copied from [conversationMessages].
  const ConversationMessagesFamily();

  /// Stream provider for messages in a conversation
  ///
  /// Copied from [conversationMessages].
  ConversationMessagesProvider call(String conversationId) {
    return ConversationMessagesProvider(conversationId);
  }

  @override
  ConversationMessagesProvider getProviderOverride(
    covariant ConversationMessagesProvider provider,
  ) {
    return call(provider.conversationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'conversationMessagesProvider';
}

/// Stream provider for messages in a conversation
///
/// Copied from [conversationMessages].
class ConversationMessagesProvider
    extends AutoDisposeStreamProvider<List<DirectMessage>> {
  /// Stream provider for messages in a conversation
  ///
  /// Copied from [conversationMessages].
  ConversationMessagesProvider(String conversationId)
    : this._internal(
        (ref) => conversationMessages(
          ref as ConversationMessagesRef,
          conversationId,
        ),
        from: conversationMessagesProvider,
        name: r'conversationMessagesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$conversationMessagesHash,
        dependencies: ConversationMessagesFamily._dependencies,
        allTransitiveDependencies:
            ConversationMessagesFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  ConversationMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  Override overrideWith(
    Stream<List<DirectMessage>> Function(ConversationMessagesRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConversationMessagesProvider._internal(
        (ref) => create(ref as ConversationMessagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<DirectMessage>> createElement() {
    return _ConversationMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationMessagesProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConversationMessagesRef
    on AutoDisposeStreamProviderRef<List<DirectMessage>> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _ConversationMessagesProviderElement
    extends AutoDisposeStreamProviderElement<List<DirectMessage>>
    with ConversationMessagesRef {
  _ConversationMessagesProviderElement(super.provider);

  @override
  String get conversationId =>
      (origin as ConversationMessagesProvider).conversationId;
}

String _$conversationOtherUserHash() =>
    r'e563d07a621f9f7e085ad7ed160597cc66832b0c';

/// Provider to get the other user in a conversation
///
/// Copied from [conversationOtherUser].
@ProviderFor(conversationOtherUser)
const conversationOtherUserProvider = ConversationOtherUserFamily();

/// Provider to get the other user in a conversation
///
/// Copied from [conversationOtherUser].
class ConversationOtherUserFamily extends Family<AsyncValue<User?>> {
  /// Provider to get the other user in a conversation
  ///
  /// Copied from [conversationOtherUser].
  const ConversationOtherUserFamily();

  /// Provider to get the other user in a conversation
  ///
  /// Copied from [conversationOtherUser].
  ConversationOtherUserProvider call(
    String conversationId,
    String currentUserId,
  ) {
    return ConversationOtherUserProvider(conversationId, currentUserId);
  }

  @override
  ConversationOtherUserProvider getProviderOverride(
    covariant ConversationOtherUserProvider provider,
  ) {
    return call(provider.conversationId, provider.currentUserId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'conversationOtherUserProvider';
}

/// Provider to get the other user in a conversation
///
/// Copied from [conversationOtherUser].
class ConversationOtherUserProvider extends AutoDisposeFutureProvider<User?> {
  /// Provider to get the other user in a conversation
  ///
  /// Copied from [conversationOtherUser].
  ConversationOtherUserProvider(String conversationId, String currentUserId)
    : this._internal(
        (ref) => conversationOtherUser(
          ref as ConversationOtherUserRef,
          conversationId,
          currentUserId,
        ),
        from: conversationOtherUserProvider,
        name: r'conversationOtherUserProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$conversationOtherUserHash,
        dependencies: ConversationOtherUserFamily._dependencies,
        allTransitiveDependencies:
            ConversationOtherUserFamily._allTransitiveDependencies,
        conversationId: conversationId,
        currentUserId: currentUserId,
      );

  ConversationOtherUserProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
    required this.currentUserId,
  }) : super.internal();

  final String conversationId;
  final String currentUserId;

  @override
  Override overrideWith(
    FutureOr<User?> Function(ConversationOtherUserRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConversationOtherUserProvider._internal(
        (ref) => create(ref as ConversationOtherUserRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
        currentUserId: currentUserId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<User?> createElement() {
    return _ConversationOtherUserProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationOtherUserProvider &&
        other.conversationId == conversationId &&
        other.currentUserId == currentUserId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);
    hash = _SystemHash.combine(hash, currentUserId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConversationOtherUserRef on AutoDisposeFutureProviderRef<User?> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;

  /// The parameter `currentUserId` of this provider.
  String get currentUserId;
}

class _ConversationOtherUserProviderElement
    extends AutoDisposeFutureProviderElement<User?>
    with ConversationOtherUserRef {
  _ConversationOtherUserProviderElement(super.provider);

  @override
  String get conversationId =>
      (origin as ConversationOtherUserProvider).conversationId;
  @override
  String get currentUserId =>
      (origin as ConversationOtherUserProvider).currentUserId;
}

String _$totalUnreadCountHash() => r'c1feaaf3bbd94e48295736869b4ab13b422a3d6a';

/// Provider for total unread count (one-time fetch)
///
/// Copied from [totalUnreadCount].
@ProviderFor(totalUnreadCount)
const totalUnreadCountProvider = TotalUnreadCountFamily();

/// Provider for total unread count (one-time fetch)
///
/// Copied from [totalUnreadCount].
class TotalUnreadCountFamily extends Family<AsyncValue<int>> {
  /// Provider for total unread count (one-time fetch)
  ///
  /// Copied from [totalUnreadCount].
  const TotalUnreadCountFamily();

  /// Provider for total unread count (one-time fetch)
  ///
  /// Copied from [totalUnreadCount].
  TotalUnreadCountProvider call(String userId) {
    return TotalUnreadCountProvider(userId);
  }

  @override
  TotalUnreadCountProvider getProviderOverride(
    covariant TotalUnreadCountProvider provider,
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
  String? get name => r'totalUnreadCountProvider';
}

/// Provider for total unread count (one-time fetch)
///
/// Copied from [totalUnreadCount].
class TotalUnreadCountProvider extends AutoDisposeFutureProvider<int> {
  /// Provider for total unread count (one-time fetch)
  ///
  /// Copied from [totalUnreadCount].
  TotalUnreadCountProvider(String userId)
    : this._internal(
        (ref) => totalUnreadCount(ref as TotalUnreadCountRef, userId),
        from: totalUnreadCountProvider,
        name: r'totalUnreadCountProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$totalUnreadCountHash,
        dependencies: TotalUnreadCountFamily._dependencies,
        allTransitiveDependencies:
            TotalUnreadCountFamily._allTransitiveDependencies,
        userId: userId,
      );

  TotalUnreadCountProvider._internal(
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
    FutureOr<int> Function(TotalUnreadCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TotalUnreadCountProvider._internal(
        (ref) => create(ref as TotalUnreadCountRef),
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
  AutoDisposeFutureProviderElement<int> createElement() {
    return _TotalUnreadCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TotalUnreadCountProvider && other.userId == userId;
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
mixin TotalUnreadCountRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _TotalUnreadCountProviderElement
    extends AutoDisposeFutureProviderElement<int>
    with TotalUnreadCountRef {
  _TotalUnreadCountProviderElement(super.provider);

  @override
  String get userId => (origin as TotalUnreadCountProvider).userId;
}

String _$unreadDmCountHash() => r'2f6a45766e3f5e72f71d9eb5d44b90ebf8d81522';

/// Stream provider for real-time unread DM count
/// Automatically adjusts count when user is viewing a conversation to prevent badge flash
///
/// Copied from [unreadDmCount].
@ProviderFor(unreadDmCount)
const unreadDmCountProvider = UnreadDmCountFamily();

/// Stream provider for real-time unread DM count
/// Automatically adjusts count when user is viewing a conversation to prevent badge flash
///
/// Copied from [unreadDmCount].
class UnreadDmCountFamily extends Family<AsyncValue<int>> {
  /// Stream provider for real-time unread DM count
  /// Automatically adjusts count when user is viewing a conversation to prevent badge flash
  ///
  /// Copied from [unreadDmCount].
  const UnreadDmCountFamily();

  /// Stream provider for real-time unread DM count
  /// Automatically adjusts count when user is viewing a conversation to prevent badge flash
  ///
  /// Copied from [unreadDmCount].
  UnreadDmCountProvider call(String userId) {
    return UnreadDmCountProvider(userId);
  }

  @override
  UnreadDmCountProvider getProviderOverride(
    covariant UnreadDmCountProvider provider,
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
  String? get name => r'unreadDmCountProvider';
}

/// Stream provider for real-time unread DM count
/// Automatically adjusts count when user is viewing a conversation to prevent badge flash
///
/// Copied from [unreadDmCount].
class UnreadDmCountProvider extends AutoDisposeStreamProvider<int> {
  /// Stream provider for real-time unread DM count
  /// Automatically adjusts count when user is viewing a conversation to prevent badge flash
  ///
  /// Copied from [unreadDmCount].
  UnreadDmCountProvider(String userId)
    : this._internal(
        (ref) => unreadDmCount(ref as UnreadDmCountRef, userId),
        from: unreadDmCountProvider,
        name: r'unreadDmCountProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$unreadDmCountHash,
        dependencies: UnreadDmCountFamily._dependencies,
        allTransitiveDependencies:
            UnreadDmCountFamily._allTransitiveDependencies,
        userId: userId,
      );

  UnreadDmCountProvider._internal(
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
    Stream<int> Function(UnreadDmCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnreadDmCountProvider._internal(
        (ref) => create(ref as UnreadDmCountRef),
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
  AutoDisposeStreamProviderElement<int> createElement() {
    return _UnreadDmCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnreadDmCountProvider && other.userId == userId;
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
mixin UnreadDmCountRef on AutoDisposeStreamProviderRef<int> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UnreadDmCountProviderElement
    extends AutoDisposeStreamProviderElement<int>
    with UnreadDmCountRef {
  _UnreadDmCountProviderElement(super.provider);

  @override
  String get userId => (origin as UnreadDmCountProvider).userId;
}

String _$dmViewModelHash() => r'c6d1d3778714685fa3aa6bb838c1d7f4f173ac82';

/// ViewModel for direct message actions
///
/// Copied from [DmViewModel].
@ProviderFor(DmViewModel)
final dmViewModelProvider =
    AutoDisposeAsyncNotifierProvider<DmViewModel, void>.internal(
      DmViewModel.new,
      name: r'dmViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dmViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DmViewModel = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
