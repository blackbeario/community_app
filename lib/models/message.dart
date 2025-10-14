import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String groupId,
    required String userId,
    required String content,
    String? imageUrl,
    @TimestampConverter() required DateTime timestamp,
    @Default([]) List<String> likes,
    @Default(0) int commentCount,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}

@freezed
class Comment with _$Comment {
  const factory Comment({
    required String id,
    required String messageId,
    required String userId,
    required String content,
    String? imageUrl,
    @TimestampConverter() required DateTime timestamp,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
}

class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    } else if (json is DateTime) {
      return json;
    }
    throw ArgumentError('Cannot convert $json to DateTime');
  }

  @override
  dynamic toJson(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}