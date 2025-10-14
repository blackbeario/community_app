// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      timestamp: const TimestampConverter().fromJson(json['timestamp']),
      likes:
          (json['likes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'userId': instance.userId,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
      'likes': instance.likes,
      'commentCount': instance.commentCount,
    };

_$CommentImpl _$$CommentImplFromJson(Map<String, dynamic> json) =>
    _$CommentImpl(
      id: json['id'] as String,
      messageId: json['messageId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      timestamp: const TimestampConverter().fromJson(json['timestamp']),
    );

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'messageId': instance.messageId,
      'userId': instance.userId,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
    };
