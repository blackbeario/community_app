// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_detail_screen_wrapper.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageHash() => r'ae7ea91171207e02207ed4f77a88c7756c82018a';

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

/// Provider to fetch a single message by ID
///
/// Copied from [message].
@ProviderFor(message)
const messageProvider = MessageFamily();

/// Provider to fetch a single message by ID
///
/// Copied from [message].
class MessageFamily extends Family<AsyncValue<Message?>> {
  /// Provider to fetch a single message by ID
  ///
  /// Copied from [message].
  const MessageFamily();

  /// Provider to fetch a single message by ID
  ///
  /// Copied from [message].
  MessageProvider call(String messageId) {
    return MessageProvider(messageId);
  }

  @override
  MessageProvider getProviderOverride(covariant MessageProvider provider) {
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
  String? get name => r'messageProvider';
}

/// Provider to fetch a single message by ID
///
/// Copied from [message].
class MessageProvider extends AutoDisposeFutureProvider<Message?> {
  /// Provider to fetch a single message by ID
  ///
  /// Copied from [message].
  MessageProvider(String messageId)
    : this._internal(
        (ref) => message(ref as MessageRef, messageId),
        from: messageProvider,
        name: r'messageProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageHash,
        dependencies: MessageFamily._dependencies,
        allTransitiveDependencies: MessageFamily._allTransitiveDependencies,
        messageId: messageId,
      );

  MessageProvider._internal(
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
    FutureOr<Message?> Function(MessageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageProvider._internal(
        (ref) => create(ref as MessageRef),
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
  AutoDisposeFutureProviderElement<Message?> createElement() {
    return _MessageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageProvider && other.messageId == messageId;
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
mixin MessageRef on AutoDisposeFutureProviderRef<Message?> {
  /// The parameter `messageId` of this provider.
  String get messageId;
}

class _MessageProviderElement extends AutoDisposeFutureProviderElement<Message?>
    with MessageRef {
  _MessageProviderElement(super.provider);

  @override
  String get messageId => (origin as MessageProvider).messageId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
