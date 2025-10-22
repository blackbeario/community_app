// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationImpl _$$ConversationImplFromJson(Map<String, dynamic> json) =>
    _$ConversationImpl(
      id: json['id'] as String,
      participants: (json['participants'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      lastMessage: json['lastMessage'] as String,
      lastMessageTimestamp: const TimestampConverter().fromJson(
        json['lastMessageTimestamp'],
      ),
      unreadCount: Map<String, int>.from(json['unreadCount'] as Map),
      lastMessageSenderId: json['lastMessageSenderId'] as String?,
      isTyping: json['isTyping'] as bool? ?? false,
      typingUserId: json['typingUserId'] as String?,
    );

Map<String, dynamic> _$$ConversationImplToJson(_$ConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'participants': instance.participants,
      'lastMessage': instance.lastMessage,
      'lastMessageTimestamp': const TimestampConverter().toJson(
        instance.lastMessageTimestamp,
      ),
      'unreadCount': instance.unreadCount,
      'lastMessageSenderId': instance.lastMessageSenderId,
      'isTyping': instance.isTyping,
      'typingUserId': instance.typingUserId,
    };
