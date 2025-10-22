// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'direct_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DirectMessage _$DirectMessageFromJson(Map<String, dynamic> json) {
  return _DirectMessage.fromJson(json);
}

/// @nodoc
mixin _$DirectMessage {
  String get id => throw _privateConstructorUsedError;
  String get conversationId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get attachmentUrl => throw _privateConstructorUsedError;
  String? get attachmentType =>
      throw _privateConstructorUsedError; // 'image' | 'document'
  @TimestampConverter()
  DateTime get timestamp => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get readAt => throw _privateConstructorUsedError;

  /// Serializes this DirectMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DirectMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DirectMessageCopyWith<DirectMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DirectMessageCopyWith<$Res> {
  factory $DirectMessageCopyWith(
    DirectMessage value,
    $Res Function(DirectMessage) then,
  ) = _$DirectMessageCopyWithImpl<$Res, DirectMessage>;
  @useResult
  $Res call({
    String id,
    String conversationId,
    String senderId,
    String content,
    String? attachmentUrl,
    String? attachmentType,
    @TimestampConverter() DateTime timestamp,
    bool isRead,
    @TimestampConverter() DateTime? readAt,
  });
}

/// @nodoc
class _$DirectMessageCopyWithImpl<$Res, $Val extends DirectMessage>
    implements $DirectMessageCopyWith<$Res> {
  _$DirectMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DirectMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? senderId = null,
    Object? content = null,
    Object? attachmentUrl = freezed,
    Object? attachmentType = freezed,
    Object? timestamp = null,
    Object? isRead = null,
    Object? readAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            conversationId: null == conversationId
                ? _value.conversationId
                : conversationId // ignore: cast_nullable_to_non_nullable
                      as String,
            senderId: null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            attachmentUrl: freezed == attachmentUrl
                ? _value.attachmentUrl
                : attachmentUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            attachmentType: freezed == attachmentType
                ? _value.attachmentType
                : attachmentType // ignore: cast_nullable_to_non_nullable
                      as String?,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
            readAt: freezed == readAt
                ? _value.readAt
                : readAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DirectMessageImplCopyWith<$Res>
    implements $DirectMessageCopyWith<$Res> {
  factory _$$DirectMessageImplCopyWith(
    _$DirectMessageImpl value,
    $Res Function(_$DirectMessageImpl) then,
  ) = __$$DirectMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String conversationId,
    String senderId,
    String content,
    String? attachmentUrl,
    String? attachmentType,
    @TimestampConverter() DateTime timestamp,
    bool isRead,
    @TimestampConverter() DateTime? readAt,
  });
}

/// @nodoc
class __$$DirectMessageImplCopyWithImpl<$Res>
    extends _$DirectMessageCopyWithImpl<$Res, _$DirectMessageImpl>
    implements _$$DirectMessageImplCopyWith<$Res> {
  __$$DirectMessageImplCopyWithImpl(
    _$DirectMessageImpl _value,
    $Res Function(_$DirectMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DirectMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? senderId = null,
    Object? content = null,
    Object? attachmentUrl = freezed,
    Object? attachmentType = freezed,
    Object? timestamp = null,
    Object? isRead = null,
    Object? readAt = freezed,
  }) {
    return _then(
      _$DirectMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        conversationId: null == conversationId
            ? _value.conversationId
            : conversationId // ignore: cast_nullable_to_non_nullable
                  as String,
        senderId: null == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        attachmentUrl: freezed == attachmentUrl
            ? _value.attachmentUrl
            : attachmentUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        attachmentType: freezed == attachmentType
            ? _value.attachmentType
            : attachmentType // ignore: cast_nullable_to_non_nullable
                  as String?,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
        readAt: freezed == readAt
            ? _value.readAt
            : readAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DirectMessageImpl implements _DirectMessage {
  const _$DirectMessageImpl({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.attachmentUrl,
    this.attachmentType,
    @TimestampConverter() required this.timestamp,
    this.isRead = false,
    @TimestampConverter() this.readAt,
  });

  factory _$DirectMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$DirectMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String conversationId;
  @override
  final String senderId;
  @override
  final String content;
  @override
  final String? attachmentUrl;
  @override
  final String? attachmentType;
  // 'image' | 'document'
  @override
  @TimestampConverter()
  final DateTime timestamp;
  @override
  @JsonKey()
  final bool isRead;
  @override
  @TimestampConverter()
  final DateTime? readAt;

  @override
  String toString() {
    return 'DirectMessage(id: $id, conversationId: $conversationId, senderId: $senderId, content: $content, attachmentUrl: $attachmentUrl, attachmentType: $attachmentType, timestamp: $timestamp, isRead: $isRead, readAt: $readAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DirectMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.attachmentUrl, attachmentUrl) ||
                other.attachmentUrl == attachmentUrl) &&
            (identical(other.attachmentType, attachmentType) ||
                other.attachmentType == attachmentType) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.readAt, readAt) || other.readAt == readAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    conversationId,
    senderId,
    content,
    attachmentUrl,
    attachmentType,
    timestamp,
    isRead,
    readAt,
  );

  /// Create a copy of DirectMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DirectMessageImplCopyWith<_$DirectMessageImpl> get copyWith =>
      __$$DirectMessageImplCopyWithImpl<_$DirectMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DirectMessageImplToJson(this);
  }
}

abstract class _DirectMessage implements DirectMessage {
  const factory _DirectMessage({
    required final String id,
    required final String conversationId,
    required final String senderId,
    required final String content,
    final String? attachmentUrl,
    final String? attachmentType,
    @TimestampConverter() required final DateTime timestamp,
    final bool isRead,
    @TimestampConverter() final DateTime? readAt,
  }) = _$DirectMessageImpl;

  factory _DirectMessage.fromJson(Map<String, dynamic> json) =
      _$DirectMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get conversationId;
  @override
  String get senderId;
  @override
  String get content;
  @override
  String? get attachmentUrl;
  @override
  String? get attachmentType; // 'image' | 'document'
  @override
  @TimestampConverter()
  DateTime get timestamp;
  @override
  bool get isRead;
  @override
  @TimestampConverter()
  DateTime? get readAt;

  /// Create a copy of DirectMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DirectMessageImplCopyWith<_$DirectMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
