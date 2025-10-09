// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesHash() => r'85e42f4675b5fc9b31b27974a9e40261731c4f1c';

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

/// Stream provider for messages in a specific group
///
/// Copied from [messages].
@ProviderFor(messages)
const messagesProvider = MessagesFamily();

/// Stream provider for messages in a specific group
///
/// Copied from [messages].
class MessagesFamily extends Family<AsyncValue<List<Message>>> {
  /// Stream provider for messages in a specific group
  ///
  /// Copied from [messages].
  const MessagesFamily();

  /// Stream provider for messages in a specific group
  ///
  /// Copied from [messages].
  MessagesProvider call(String groupId) {
    return MessagesProvider(groupId);
  }

  @override
  MessagesProvider getProviderOverride(covariant MessagesProvider provider) {
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
  String? get name => r'messagesProvider';
}

/// Stream provider for messages in a specific group
///
/// Copied from [messages].
class MessagesProvider extends AutoDisposeStreamProvider<List<Message>> {
  /// Stream provider for messages in a specific group
  ///
  /// Copied from [messages].
  MessagesProvider(String groupId)
    : this._internal(
        (ref) => messages(ref as MessagesRef, groupId),
        from: messagesProvider,
        name: r'messagesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messagesHash,
        dependencies: MessagesFamily._dependencies,
        allTransitiveDependencies: MessagesFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  MessagesProvider._internal(
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
    Stream<List<Message>> Function(MessagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessagesProvider._internal(
        (ref) => create(ref as MessagesRef),
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
    return _MessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesProvider && other.groupId == groupId;
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
mixin MessagesRef on AutoDisposeStreamProviderRef<List<Message>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _MessagesProviderElement
    extends AutoDisposeStreamProviderElement<List<Message>>
    with MessagesRef {
  _MessagesProviderElement(super.provider);

  @override
  String get groupId => (origin as MessagesProvider).groupId;
}

String _$allMessagesHash() => r'e7d4cce4c0c7e29d02e18c92ce20b60df7649ee8';

/// Stream provider for all messages (across all groups)
///
/// Copied from [allMessages].
@ProviderFor(allMessages)
final allMessagesProvider = AutoDisposeStreamProvider<List<Message>>.internal(
  allMessages,
  name: r'allMessagesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allMessagesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllMessagesRef = AutoDisposeStreamProviderRef<List<Message>>;
String _$messageUserHash() => r'f7468a409d0332a7e5abed438d638bce345ec905';

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

String _$messageCommentsHash() => r'1ea7d4e93db47c586b645d3c3c0b84a53a9521dd';

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

String _$messageViewModelHash() => r'8c2b85cf2fb7e2f75bd197598ed85722838d1e6a';

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
